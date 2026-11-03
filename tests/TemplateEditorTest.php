<?php
/**
 * The template editor (explayouts_ui/template_editor) without a kernel: the diff shown before saving, the check of
 * block tags the parser lets through, the line of the template engine's messages, where a template lives, the
 * write rules (POST, explayouts_ui/edit, form token) and the page's markup (no inline CSS or script).
 *
 * @license GPL-2.0-or-later
 */
use PHPUnit\Framework\TestCase;

class TemplateEditorTest extends TestCase
{
    // ---- the diff

    public function testIdenticalTextsHaveNoHunks()
    {
        $diff = expLayoutsUiTemplateEditor::diff( "a\nb\n", "a\nb\n" );
        $this->assertSame( array( 'added' => 0, 'removed' => 0, 'hunks' => array() ), $diff );
        // only the line break at the end differs: the same lines
        $this->assertSame( array(), expLayoutsUiTemplateEditor::diff( "a\nb", "a\nb\n" )['hunks'] );
        $this->assertSame( array(), expLayoutsUiTemplateEditor::diff( "a\r\nb\r\n", "a\nb\n" )['hunks'] );
    }

    public function testAChangedLineIsARemovalAndAnAddition()
    {
        $old = implode( "\n", range( 1, 20 ) ) . "\n";
        $new = str_replace( "\n10\n", "\nten\n", $old );
        $diff = expLayoutsUiTemplateEditor::diff( $old, $new );
        $this->assertSame( 1, $diff['added'] );
        $this->assertSame( 1, $diff['removed'] );
        $this->assertCount( 1, $diff['hunks'] );
        $hunk = $diff['hunks'][0];
        $this->assertSame( 7, $hunk['old'] );
        $this->assertSame( 7, $hunk['new'] );
        $this->assertSame( array( ' ', ' ', ' ', '-', '+', ' ', ' ', ' ' ), array_column( $hunk['lines'], 't' ) );
        $this->assertSame( array( 'o' => 10, 'n' => null, 's' => '10' ), array_slice( $hunk['lines'][3], 1 ) );
        $this->assertSame( array( 'o' => null, 'n' => 10, 's' => 'ten' ), array_slice( $hunk['lines'][4], 1 ) );
    }

    public function testChangesFarApartAreSeparateHunksAndNearOnesMerge()
    {
        $old = implode( "\n", range( 1, 30 ) );
        $far = str_replace( array( "\n2\n", "\n28\n" ), array( "\ntwo\n", "\ntwenty-eight\n" ), $old );
        $this->assertCount( 2, expLayoutsUiTemplateEditor::diff( $old, $far )['hunks'] );
        $near = str_replace( array( "\n10\n", "\n14\n" ), array( "\nten\n", "\nfourteen\n" ), $old );
        $this->assertCount( 1, expLayoutsUiTemplateEditor::diff( $old, $near )['hunks'] );
    }

    public function testAddedAndRemovedLinesAtTheEdges()
    {
        $diff = expLayoutsUiTemplateEditor::diff( "b\nc\n", "a\nb\nc\nd\n" );
        $this->assertSame( 2, $diff['added'] );
        $this->assertSame( 0, $diff['removed'] );
        $types = array();
        foreach ( $diff['hunks'] as $hunk )
            foreach ( $hunk['lines'] as $line )
                $types[] = $line['t'] . $line['s'];
        $this->assertSame( array( '+a', ' b', ' c', '+d' ), $types );

        $new = expLayoutsUiTemplateEditor::diff( '', "x\ny\n" );
        $this->assertSame( 2, $new['added'] );
        $this->assertSame( 1, $new['hunks'][0]['new'] );
    }

    /** Applying the diff's lines in order gives the new text back: no line is lost or doubled. */
    public function testTheDiffRebuildsBothTexts()
    {
        mt_srand( 586 );
        for ( $round = 0; $round < 25; $round++ )
        {
            $old = array();
            for ( $i = 0; $i < 60; $i++ )
                $old[] = 'line ' . mt_rand( 0, 15 );
            $new = $old;
            for ( $i = 0; $i < 12; $i++ )
            {
                $at = mt_rand( 0, count( $new ) - 1 );
                if ( mt_rand( 0, 1 ) )
                    array_splice( $new, $at, 1 );
                else
                    array_splice( $new, $at, 0, array( 'new ' . $i ) );
            }
            $diff = expLayoutsUiTemplateEditor::diff( implode( "\n", $old ), implode( "\n", $new ), 1000 );
            $rebuiltOld = array();
            $rebuiltNew = array();
            foreach ( $diff['hunks'] as $hunk )
                foreach ( $hunk['lines'] as $line )
                {
                    if ( $line['t'] !== '+' )
                        $rebuiltOld[] = $line['s'];
                    if ( $line['t'] !== '-' )
                        $rebuiltNew[] = $line['s'];
                }
            $this->assertSame( $old, $rebuiltOld, 'round ' . $round );
            $this->assertSame( $new, $rebuiltNew, 'round ' . $round );
        }
    }

    // ---- the syntax check

    public function testUnclosedAndMismatchedBlockTags()
    {
        $this->assertSame( array(), expLayoutsUiTemplateEditor::unbalancedTags( "{if \$a}\n{foreach \$b as \$c}{\$c}{/foreach}\n{/if}\n" ) );
        $this->assertSame( array( array( 'line' => 2, 'text' => '{if} is not closed' ) ),
                           expLayoutsUiTemplateEditor::unbalancedTags( "<div>\n{if \$a}\nx\n</div>\n" ) );
        $this->assertSame( array( array( 'line' => 3, 'text' => '{/foreach} without a start tag' ) ),
                           expLayoutsUiTemplateEditor::unbalancedTags( "a\nb\n{/foreach}\n" ) );
        $mismatch = expLayoutsUiTemplateEditor::unbalancedTags( "{if \$a}\n{foreach \$b as \$c}\n{/if}\n" );
        $this->assertSame( array( 'line' => 3, 'text' => '{/if} closes {foreach} opened on line 2' ), $mismatch[0] );
        $this->assertSame( array( 'line' => 2, 'text' => '{foreach} is not closed' ), $mismatch[1] );
    }

    public function testCommentsLiteralsAndLookalikesAreIgnored()
    {
        $this->assertSame( array(), expLayoutsUiTemplateEditor::unbalancedTags( "{* {if} is not closed here *}\n{literal}{if}{foreach}{/literal}\n" ) );
        // {ifx}, {iffy ...}, {\$if} are not the if function
        $this->assertSame( array(), expLayoutsUiTemplateEditor::unbalancedTags( "{\$if}{ifx}{def \$for=1}{set-block variable=\$x}y{/set-block}\n" ) );
    }

    public function testTheLineOfAMessage()
    {
        $this->assertSame( 8, expLayoutsUiTemplateEditor::placementLine( array( array( 8, 0, 120 ), array( 8, 10, 130 ), 'file.tpl' ) ) );
        $this->assertSame( 3, expLayoutsUiTemplateEditor::placementLine( 'parser error @ template:3[0] End tag "foreach" without a start tag' ) );
        $this->assertNull( expLayoutsUiTemplateEditor::placementLine( false ) );
        $this->assertNull( expLayoutsUiTemplateEditor::placementLine( 'no place' ) );
    }

    /** The view checks before it saves, and a syntax error stops the save before anything is written. */
    public function testTheViewValidatesBeforeSaving()
    {
        $view = file_get_contents( dirname( __DIR__ ) . '/classes/runnable/views/explayouts_ui/template_editor.php' );
        $save = substr( $view, strpos( $view, "if ( \$action === 'save' )" ) );
        $validate = strpos( $save, 'expLayoutsUiTemplateEditor::validate( $content )' );
        $refuse = strpos( $save, "if ( !\$validation['ok'] )" );
        $write = strpos( $save, 'saveKeepingOriginal(' );
        $this->assertNotFalse( $validate );
        $this->assertTrue( $validate < $refuse && $refuse < $write, 'validate, refuse, then write' );
        $this->assertStringContainsString( "'validation' => \$validation", substr( $save, $refuse, $write - $refuse ) );
    }

    // ---- where a template lives

    public function testLocate()
    {
        $this->assertSame( array( 'extension' => 'explayouts', 'design' => 'standard', 'relative' => 'explayouts/block/list.tpl', 'group' => 'explayouts/block' ),
                           expLayoutsUiTemplateEditor::locate( 'extension/explayouts/design/standard/templates/explayouts/block/list.tpl' ) );
        $this->assertSame( array( 'extension' => '', 'design' => 'admin4', 'relative' => 'pagelayout.tpl', 'group' => '' ),
                           expLayoutsUiTemplateEditor::locate( 'design/admin4/templates/pagelayout.tpl' ) );
        $this->assertSame( 'override', expLayoutsUiTemplateEditor::locate( 'extension/x/design/site/override/templates/override/full.tpl' )['group'] );
        $this->assertSame( '', expLayoutsUiTemplateEditor::locate( 'settings/site.ini' )['design'] );
    }

    // ---- the design chain

    public function testTheFirstBaseOfTheChainWins()
    {
        $bases = array( 'extension/theme/design/media', 'extension/explayouts/design/standard', 'design/standard' );
        $files = array(
            'extension/theme/design/media' => array( 'explayouts/block/about.tpl' ),
            'extension/explayouts/design/standard' => array( 'explayouts/zone.tpl', 'explayouts/block/about.tpl' ),
            'design/standard' => array( 'explayouts/block/about.tpl' ),
        );
        $rows = expLayoutsUiTemplateEditor::chainRows( $bases, $files, function ( $path ) { return strpos( $path, 'extension/theme/' ) === 0; } );
        $byPath = array_column( $rows, null, 'path' );
        $this->assertCount( 4, $rows );

        $media = $byPath['extension/theme/design/media/templates/explayouts/block/about.tpl'];
        $this->assertTrue( $media['winner'] );
        $this->assertSame( array(), $media['overridden_by'] );
        $this->assertSame( array( 'extension/explayouts/design/standard/templates/explayouts/block/about.tpl',
                                  'design/standard/templates/explayouts/block/about.tpl' ), $media['overrides'] );
        $this->assertTrue( $media['writable'] );
        $this->assertSame( array( 'media', 'theme', 'explayouts/block' ), array( $media['design'], $media['extension'], $media['group'] ) );

        $standard = $byPath['extension/explayouts/design/standard/templates/explayouts/block/about.tpl'];
        $this->assertFalse( $standard['winner'] );
        $this->assertSame( array( 'extension/theme/design/media/templates/explayouts/block/about.tpl' ), $standard['overridden_by'] );
        $this->assertSame( array( 'design/standard/templates/explayouts/block/about.tpl' ), $standard['overrides'] );
        $this->assertFalse( $standard['writable'] );

        $this->assertTrue( $byPath['extension/explayouts/design/standard/templates/explayouts/zone.tpl']['winner'] );
        $this->assertSame( 2, $byPath['design/standard/templates/explayouts/block/about.tpl']['base_index'] );
    }

    public function testCleanRelativePaths()
    {
        $this->assertSame( 'design/standard/templates/a.tpl', expLayoutsUiTemplateEditor::cleanRelative( 'design/standard/templates/a.tpl' ) );
        foreach ( array( '', '../x.tpl', 'design/../x.tpl', 'design//x.tpl', 'design/./x.tpl', '/design/x.tpl', "a\0.tpl", 'design\\x.tpl', 'design/.hidden/x.tpl', array( 'x' ) ) as $bad )
            $this->assertSame( '', expLayoutsUiTemplateEditor::cleanRelative( $bad ), var_export( $bad, true ) );
    }

    /** The view takes view parameters only: no query string is read or written. */
    public function testViewParametersOnly()
    {
        $root = dirname( __DIR__ );
        $view = file_get_contents( $root . '/classes/runnable/views/explayouts_ui/template_editor.php' );
        $this->assertStringNotContainsString( '$_GET', $view );
        $this->assertStringNotContainsString( '$_REQUEST', $view );
        $this->assertStringNotContainsString( 'getVariable(', $view );
        $this->assertStringContainsString( "'/(siteaccess)/'", $view );
        $module = file_get_contents( $root . '/modules/explayouts_ui/module.php' );
        $this->assertStringContainsString( "'unordered_params' => array( 'siteaccess' => 'SiteAccess', 'design' => 'Design' )", $module );
        $js = file_get_contents( $root . '/design/standard/javascript/explayouts_ui_template_editor.js' );
        $this->assertStringNotContainsString( 'searchParams', $js );
        $this->assertStringNotContainsString( "'?'", $js );
    }

    // ---- the write rules

    public function testWritesArePostsByEditorsWithTheToken()
    {
        $this->assertSame( 'method', expLayoutsUiTemplateEditor::writeRefusal( 'GET', true, true ) );
        $this->assertSame( 'method', expLayoutsUiTemplateEditor::writeRefusal( 'HEAD', true, true ) );
        $this->assertSame( 'policy', expLayoutsUiTemplateEditor::writeRefusal( 'POST', false, true ) );
        $this->assertSame( 'token', expLayoutsUiTemplateEditor::writeRefusal( 'POST', true, false ) );
        $this->assertSame( 'policy', expLayoutsUiTemplateEditor::writeRefusal( 'post', false, false ) );
        $this->assertNull( expLayoutsUiTemplateEditor::writeRefusal( 'POST', true, true ) );
    }

    public function testTheFormToken()
    {
        $this->assertTrue( expLayoutsUiTemplateEditor::tokenMatches( 'abc123', 'abc123' ) );
        $this->assertFalse( expLayoutsUiTemplateEditor::tokenMatches( 'abc124', 'abc123' ) );
        $this->assertFalse( expLayoutsUiTemplateEditor::tokenMatches( '', 'abc123' ) );
        $this->assertFalse( expLayoutsUiTemplateEditor::tokenMatches( array( 'abc123' ), 'abc123' ) );
        // without the form token extension there is nothing to compare
        $this->assertTrue( expLayoutsUiTemplateEditor::tokenMatches( '', '' ) );
    }

    /** Every write (save, revert) is reached only through handlePost(), which starts with the write rules. */
    public function testEveryWriteGoesThroughTheWriteRules()
    {
        $view = file_get_contents( dirname( __DIR__ ) . '/classes/runnable/views/explayouts_ui/template_editor.php' );
        $post = strpos( $view, 'protected function handlePost()' );
        $rules = strpos( $view, 'expLayoutsUiTemplateEditor::writeRefusal(' );
        $this->assertNotFalse( $post );
        $this->assertGreaterThan( $post, $rules );
        foreach ( array( 'saveKeepingOriginal(', 'revertToOriginal(', '::save(' ) as $write )
        {
            $at = strpos( $view, $write );
            if ( $at !== false )
                $this->assertGreaterThan( $rules, $at, $write . ' after the write rules' );
        }
        // handlePost() only for a POST, and a POST without the script's header is refused, not handled as a page
        $this->assertStringContainsString( "if ( \$method === 'POST' )\n                \$this->handlePost();", $view );
        $this->assertSame( 1, substr_count( $view, '$this->handlePost()' ) );
        // the audit event of every save, revert and new override
        $this->assertSame( 3, substr_count( $view, 'self::afterWrite(' ) );
        $this->assertStringContainsString( 'createOverride(', substr( $view, $rules ) );
        $this->assertStringContainsString( "expAuditHook::emit( 'system.template.change'", $view );
    }

    // ---- the markup

    public function testNoInlineCssOrScript()
    {
        $root = dirname( __DIR__ );
        $files = array( 'design/standard/templates/explayouts_ui/parts/template_editor_body.tpl',
                        'design/admin/templates/explayouts_ui/template_editor.tpl',
                        'design/admin4/templates/explayouts_ui/template_editor.tpl' );
        foreach ( $files as $file )
        {
            $tpl = file_get_contents( $root . '/' . $file );
            $this->assertStringNotContainsString( '<style', $tpl, $file );
            $this->assertDoesNotMatchRegularExpression( '~\sstyle\s*=~i', $tpl, $file );
            $this->assertDoesNotMatchRegularExpression( '~\son[a-z]+\s*=~i', $tpl, $file );
            preg_match_all( '~<script\b([^>]*)>(.*?)</script>~is', $tpl, $m, PREG_SET_ORDER );
            foreach ( $m as $script )
                $this->assertStringContainsString( 'type="application/json"', $script[1], $file );
        }
        $js = file_get_contents( $root . '/design/standard/javascript/explayouts_ui_template_editor.js' );
        $this->assertStringNotContainsString( 'eval(', $js );
        $this->assertStringNotContainsString( '.style.', $js );
    }

    /** The module CSS uses the design's tokens only: no colors of its own. */
    public function testTheStylesheetUsesTokensOnly()
    {
        $css = file_get_contents( dirname( __DIR__ ) . '/design/standard/stylesheets/explayouts_ui_template_editor.css' );
        $this->assertDoesNotMatchRegularExpression( '~#[0-9a-f]{3,8}\b~i', $css );
        $this->assertDoesNotMatchRegularExpression( '~\b(?:rgb|rgba|hsl|hsla)\(~i', $css );
        $this->assertDoesNotMatchRegularExpression( '~--[a-z0-9-]+\s*:~i', $css, 'no custom property of its own' );
        $this->assertDoesNotMatchRegularExpression( '~border-radius:\s*[1-9]~', $css );
        $this->assertDoesNotMatchRegularExpression( '~:\s*(?:white|black)\b~', $css );
    }
}
