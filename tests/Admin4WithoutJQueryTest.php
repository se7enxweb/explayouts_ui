<?php
/**
 * The Layouts pages of admin4 run without jQuery: their templates (with the parts they include from the designs of
 * this extension) load neither ezjscore's jQuery / jQuery UI nor the exp::core bundle, and the scripts they load
 * use no jQuery. The layout editor (explayouts_ui_api, app.tpl) is not one of these pages: its app bundle is built
 * on Backbone, jQuery UI and Bootstrap 3 and loads jQuery itself.
 *
 * Copyright CJW Network and Exponential Foundation. All rights reserved.
 *
 * @license GPL-2.0-or-later
 */
use PHPUnit\Framework\TestCase;

class Admin4WithoutJQueryTest extends TestCase
{
    /** The scripts the admin4 templates load; a new one has to be added here, and is checked with the others. */
    const SCRIPTS = array( 'explayouts_ui_admin4.js', 'explayouts_ui_rule_list.js', 'explayouts_ui_template_editor.js' );

    /** Designs of this extension in the order admin4 falls back to them. */
    const DESIGNS = array( 'admin4', 'admin', 'standard' );

    /** The template editor's own helper, the only "$(" allowed. */
    const ID_HELPER = 'function $(id) { return document.getElementById(id); }';

    private static function designDir(): string
    {
        return dirname( __DIR__ ) . '/design';
    }

    /** @return string the file of design:$uri in the first design of this extension that has it, or '' */
    private static function resolve( string $kind, string $uri ): string
    {
        foreach ( self::DESIGNS as $design )
        {
            $file = self::designDir() . '/' . $design . '/' . $kind . '/' . $uri;
            if ( is_file( $file ) )
                return $file;
        }
        return '';
    }

    /** @return string[] the admin4 templates and, followed recursively, the templates of this extension they include */
    private static function templates(): array
    {
        $root = self::designDir() . '/admin4/templates';
        $queue = array();
        foreach ( new RecursiveIteratorIterator( new RecursiveDirectoryIterator( $root, FilesystemIterator::SKIP_DOTS ) ) as $file )
        {
            if ( $file->getExtension() === 'tpl' )
                $queue[] = $file->getPathname();
        }
        $seen = array();
        while ( $queue )
        {
            $file = array_shift( $queue );
            if ( isset( $seen[$file] ) )
                continue;
            $seen[$file] = true;
            preg_match_all( "/\\{include\\s+uri='design:([^']+)'/", file_get_contents( $file ), $m );
            foreach ( $m[1] as $uri )
            {
                // Includes of admin4's own design (design:parts/ini_menu.tpl and the like) are not this extension's.
                $included = self::resolve( 'templates', $uri );
                if ( $included !== '' )
                    $queue[] = $included;
            }
        }
        $files = array_keys( $seen );
        sort( $files );
        return $files;
    }

    private static function stripTemplateComments( string $text ): string
    {
        return preg_replace( '/\{\*.*?\*\}/s', '', $text );
    }

    /** Removes block and line comments, leaving string and template literals as they are. */
    private static function stripScriptComments( string $code ): string
    {
        $out = '';
        $n = strlen( $code );
        for ( $i = 0; $i < $n; $i++ )
        {
            $c = $code[$i];
            if ( $c === '"' || $c === "'" || $c === '`' )
            {
                $j = $i + 1;
                while ( $j < $n && $code[$j] !== $c )
                    $j += $code[$j] === '\\' ? 2 : 1;
                $out .= substr( $code, $i, $j - $i + 1 );
                $i = $j;
            }
            elseif ( $c === '/' && $i + 1 < $n && $code[$i + 1] === '*' )
            {
                $end = strpos( $code, '*/', $i + 2 );
                $i = $end === false ? $n : $end + 1;
                $out .= ' ';
            }
            elseif ( $c === '/' && $i + 1 < $n && $code[$i + 1] === '/' )
            {
                $end = strpos( $code, "\n", $i );
                $i = ( $end === false ? $n : $end ) - 1;
            }
            else
                $out .= $c;
        }
        return $out;
    }

    public function testTheTemplatesAndTheIncludedPartsAreFound()
    {
        $files = self::templates();
        $this->assertNotEmpty( $files );
        $names = array_map( function ( $f ) { return substr( $f, strlen( self::designDir() ) + 1 ); }, $files );
        foreach ( array( 'admin4/templates/explayouts_ui/layout_list.tpl', 'admin4/templates/explayouts_ui/rule_list.tpl',
                         'admin4/templates/explayouts_ui/template_editor.tpl', 'admin/templates/explayouts_ui/parts/rule_list_script.tpl',
                         'standard/templates/explayouts_ui/parts/template_editor_body.tpl' ) as $expected )
            $this->assertContains( $expected, $names );
    }

    public function testNoTemplateLoadsJQuery()
    {
        foreach ( self::templates() as $file )
        {
            $text = self::stripTemplateComments( file_get_contents( $file ) );
            $this->assertDoesNotMatchRegularExpression( '/ezjsc::jquery/i', $text, $file . ' loads ezjscore\'s jQuery' );
            $this->assertStringNotContainsString( 'exp::core', $text, $file . ' loads the exp::core bundle with its jQuery' );
            $this->assertDoesNotMatchRegularExpression( '/jquery[\w.-]*\.js/i', $text, $file . ' loads a jQuery file' );
            $this->assertStringNotContainsString( 'jQuery', $text, $file );
        }
    }

    public function testTheTemplatesLoadExactlyTheCheckedScripts()
    {
        $scripts = array();
        foreach ( self::templates() as $file )
        {
            $text = self::stripTemplateComments( file_get_contents( $file ) );
            preg_match_all( '/\{ezscript(?:_require|_load)?\s*\((.*?)\)\s*\}/s', $text, $calls );
            foreach ( $calls[1] as $arguments )
            {
                preg_match_all( "/'([^']+)'/", $arguments, $names );
                $scripts = array_merge( $scripts, $names[1] );
            }
        }
        $scripts = array_values( array_unique( $scripts ) );
        sort( $scripts );
        $this->assertSame( self::SCRIPTS, $scripts );
    }

    public function testTheScriptsUseNoJQuery()
    {
        foreach ( self::SCRIPTS as $name )
        {
            $file = self::resolve( 'javascript', $name );
            $this->assertNotSame( '', $file, $name . ' not found in the designs of explayouts_ui' );
            $code = self::stripScriptComments( file_get_contents( $file ) );
            $this->assertNotSame( '', trim( $code ), $name . ' is empty' );

            if ( $name === 'explayouts_ui_template_editor.js' )
            {
                $this->assertSame( 1, substr_count( $code, self::ID_HELPER ), $name . ': the $() helper changed' );
                $code = str_replace( self::ID_HELPER, '', $code );
                // What is left of "$(" calls the helper with an id.
                $code = preg_replace( "/\\$\\('[\\w-]+'\\)/", 'byId', $code );
            }

            $this->assertStringNotContainsString( 'jQuery', $code, $name );
            $this->assertDoesNotMatchRegularExpression( '/(?<![\w$])\$\s*[(.]/', $code, $name . ' uses $ (jQuery)' );
            $this->assertDoesNotMatchRegularExpression( '/\.fn\./', $code, $name . ' extends jQuery' );
            $this->assertDoesNotMatchRegularExpression(
                '/\.(ajax|getJSON|modal|dropdown|tooltip|popover|collapse|tab|sortable|draggable|droppable|datepicker)\s*\(/',
                $code, $name . ' calls a jQuery, jQuery UI or Bootstrap plugin method' );
        }
    }
}
