<?php
/**
 * The code of extension/explayouts_ui/modules/explayouts_ui/dashboard.php, moved into a class (#207 stage 1). The file extension/explayouts_ui/modules/explayouts_ui/dashboard.php is one call to it.
 * Guide: doc/bc/6.0/cli_cronjob_view_abstractions.md
 */

namespace
{
if ( !function_exists( 'expLayoutsTableCount' ) ) {
function expLayoutsTableCount( $table )
{
    $db = eZDB::instance();
    $rows = $db->arrayQuery( "SELECT COUNT(*) AS cnt FROM {$table}" );
    return isset( $rows[0]['cnt'] ) ? (int)$rows[0]['cnt'] : 0;
}
}
}

namespace Exponential\View\Extension\ExplayoutsUi\ExplayoutsUi
{

class Dashboard extends \Exponential\Runnable\ModuleView
{
    public function run( array $scope )
    {
        // the including function's variables ($Params, $Module, $cli, ...)
        foreach ( array_keys( $scope ) as $__name )
            if ( $__name !== 'this' && $__name !== 'scope' )
                ${$__name} = &$scope[$__name];
        unset( $__name );

        \eZDebug::updateSettings( array( 'debug-enabled' => false ) );
        $module = $Params['Module'];

        if ( !\eZUser::currentUser()->hasAccessTo( 'explayouts', 'read' ) )
        {
            return $this->viewResult( isset( $Result ) ? $Result : null,  $module->handleError( \eZError::KERNEL_ACCESS_DENIED, 'kernel' ) );
        }

        $db = \eZDB::instance();


        $counts = array(
            'layouts' => expLayoutsTableCount( 'explayouts_layout' ),
            'zones' => expLayoutsTableCount( 'explayouts_zone' ),
            'blocks' => expLayoutsTableCount( 'explayouts_block' ),
            'rules' => expLayoutsTableCount( 'explayouts_rule' ),
            'collections' => expLayoutsTableCount( 'explayouts_collection' ),
        );

        $recentLayouts = \eZPersistentObject::fetchObjectList(
            \expLayoutsLayout::definition(),
            null,
            null,
            array( 'modified' => 'desc' ),
            array( 'limit' => 5 ),
            true
        );

        $tpl = \eZTemplate::factory();
        $tpl->setVariable( 'counts', $counts );
        $tpl->setVariable( 'recent_layouts', $recentLayouts );

        $Result = array();
        $Result['content'] = $tpl->fetch( 'design:explayouts_ui/dashboard.tpl' );
        $Result['left_menu'] = 'design:parts/explayouts_ui/menu.tpl';
        $Result['path'] = array( array( 'url' => false,
                                        'text' => \ezpI18n::tr( 'explayouts_ui/dashboard', 'Dashboard' ) ) );
        return $this->viewResult( isset( $Result ) ? $Result : null,  $Result );

        return $this->viewResult( isset( $Result ) ? $Result : null, null );
    }
}

}
