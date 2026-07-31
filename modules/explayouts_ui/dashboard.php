<?php
eZDebug::updateSettings( array( 'debug-enabled' => false ) );
$module = $Params['Module'];

if ( !eZUser::currentUser()->hasAccessTo( 'explayouts', 'read' ) )
{
    return $module->handleError( eZError::KERNEL_ACCESS_DENIED, 'kernel' );
}

$db = eZDB::instance();

function expLayoutsTableCount( $table )
{
    $db = eZDB::instance();
    $rows = $db->arrayQuery( "SELECT COUNT(*) AS cnt FROM {$table}" );
    return isset( $rows[0]['cnt'] ) ? (int)$rows[0]['cnt'] : 0;
}

$counts = array(
    'layouts' => expLayoutsTableCount( 'explayouts_layout' ),
    'zones' => expLayoutsTableCount( 'explayouts_zone' ),
    'blocks' => expLayoutsTableCount( 'explayouts_block' ),
    'rules' => expLayoutsTableCount( 'explayouts_rule' ),
    'collections' => expLayoutsTableCount( 'explayouts_collection' ),
);

$recentLayouts = eZPersistentObject::fetchObjectList(
    expLayoutsLayout::definition(),
    null,
    null,
    array( 'modified' => 'desc' ),
    array( 'limit' => 5 ),
    true
);

$tpl = eZTemplate::factory();
$tpl->setVariable( 'counts', $counts );
$tpl->setVariable( 'recent_layouts', $recentLayouts );

$Result = array();
$Result['content'] = $tpl->fetch( 'design:explayouts_ui/dashboard.tpl' );
$Result['left_menu'] = 'design:parts/explayouts_ui/menu.tpl';
$Result['path'] = array( array( 'url' => false,
                                'text' => ezpI18n::tr( 'explayouts_ui/dashboard', 'Dashboard' ) ) );
return $Result;
