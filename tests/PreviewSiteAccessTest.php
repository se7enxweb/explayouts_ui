<?php
/**
 * The layout preview renders in the public siteaccess of the administration in use (expLayoutsPreviewSiteAccess of
 * explayouts), not in site.ini [SiteSettings] DefaultAccess: in an installation serving several sites that is the
 * default of the whole installation, another site's, whose settings and design then ran on this site's database.
 * Where no siteaccess qualifies the preview says so instead of switching. An explayouts too old to say keeps the
 * preview it had, in DefaultAccess.
 *
 * The view runs on stand-ins; eZSiteAccess::load() records the siteaccess and stops the view there.
 *
 * @license GPL-2.0-or-later
 */
use PHPUnit\Framework\Attributes\RunTestsInSeparateProcesses;
use PHPUnit\Framework\TestCase;

if ( !class_exists( 'Exponential\\Runnable\\ModuleView', false ) )
    eval( 'namespace Exponential\\Runnable; abstract class ModuleView { abstract public function run( array $scope ); protected function viewResult( $result, $returned ) { return empty( $result ) ? $returned : $result; } }' );

class PreviewSiteAccessStop extends Exception {}

/**
 * @runTestsInSeparateProcesses
 * @preserveGlobalState disabled
 */
#[RunTestsInSeparateProcesses]
class PreviewSiteAccessTest extends TestCase
{
    /** Stand-ins of the kernel and of explayouts up to the siteaccess switch; $preview: the answer of resolve(), or null for an explayouts without the class */
    protected static function standIns( $preview, $reason = '' )
    {
        if ( !class_exists( 'eZUser', false ) )
            eval( 'class eZUser { public static function currentUser() { return new self(); } public function hasAccessTo( $m, $f = false ) { return true; } }' );
        if ( !class_exists( 'eZDebug', false ) )
            eval( 'class eZDebug { public static $warnings = array(); public static $notices = array(); public static function writeWarning( $m, $l = "" ) { self::$warnings[] = $m; } public static function writeNotice( $m, $l = "" ) { self::$notices[] = $m; } public static function checkDebugByUser() {} }' );
        if ( !class_exists( 'expLayoutsLayout', false ) )
            eval( 'class expLayoutsLayout { public static function fetch( $id, $status = 2 ) { return new self(); } }' );
        if ( !class_exists( 'expLayoutsRenderer', false ) )
            eval( 'class expLayoutsRenderer { public static function prepareLayout( $layout, $status = 2 ) { return array(); } }' );
        if ( !class_exists( 'eZSiteAccess', false ) )
            eval( 'class eZSiteAccess { const TYPE_URI = 2; public static $loaded = array(); public static function load( $access ) { self::$loaded[] = $access["name"]; throw new PreviewSiteAccessStop(); } }' );
        if ( !class_exists( 'eZINI', false ) )
            eval( 'class eZINI { public function variable( $g, $n ) { return $n === "DefaultAccess" ? "other_site" : ""; } public static function instance( $f = "site.ini" ) { return new self(); } }' );
        if ( $preview !== null )
        {
            eval( 'class expLayoutsPreviewSiteAccess { public static $lastError = ""; public static function resolve() { return ' . var_export( $preview, true ) . '; } }' );
            expLayoutsPreviewSiteAccess::$lastError = $reason;
        }
        $GLOBALS['eZCurrentAccess'] = array( 'name' => 'site_admin', 'type' => 1 );
        require_once dirname( __DIR__ ) . '/classes/runnable/views/explayouts_ui/preview.php';
    }

    protected static function preview( ?string &$loaded = null )
    {
        $view = new \Exponential\View\Extension\ExplayoutsUi\ExplayoutsUi\Preview();
        try
        {
            return $view->run( array( 'Params' => array( 'Module' => null, 'LayoutID' => 2 ) ) );
        }
        catch ( PreviewSiteAccessStop $e )
        {
            $loaded = end( eZSiteAccess::$loaded );
            return null;
        }
    }

    public function testThePreviewSwitchesToThePublicSiteaccessOfTheAdministration()
    {
        self::standIns( 'site' );
        $loaded = null;
        self::preview( $loaded );
        $this->assertSame( 'site', $loaded, 'not DefaultAccess (other_site)' );
    }

    public function testWithoutAPublicSiteaccessThePreviewSaysWhyAndDoesNotSwitch()
    {
        self::standIns( false, "The siteaccess 'other_site' uses another database than 'site_admin'." );
        $result = self::preview();
        $this->assertSame( array(), eZSiteAccess::$loaded );
        $this->assertStringContainsString( 'No public siteaccess to preview this layout in.', $result['content'] );
        $this->assertStringContainsString( 'another database than &#039;site_admin&#039;', $result['content'] );
    }

    public function testAnExplayoutsWithoutThePreviewClassKeepsThePreviewInDefaultAccess()
    {
        // without the class: the kernel's autoloader (pulled in by vendor/autoload.php) would find explayouts' one
        foreach ( spl_autoload_functions() as $loader )
        {
            $owner = is_array( $loader ) ? ( is_object( $loader[0] ) ? get_class( $loader[0] ) : $loader[0] ) : '';
            if ( stripos( (string)$owner, 'ezp' ) === 0 )
                spl_autoload_unregister( $loader );
        }
        self::standIns( null );
        $loaded = null;
        self::preview( $loaded );
        $this->assertSame( 'other_site', $loaded );
        $this->assertStringContainsString( 'Update explayouts', implode( "\n", eZDebug::$notices ) );
    }
}
