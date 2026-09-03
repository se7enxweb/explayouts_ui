<?php
eZDebug::updateSettings( array( 'debug-enabled' => false ) );
$module = $Params['Module'];

if ( !eZUser::currentUser()->hasAccessTo( 'explayouts', 'read' ) )
{
    return $module->handleError( eZError::KERNEL_ACCESS_DENIED, 'kernel' );
}

$componentClassIdentifiers = array(
    'ng_component_about',
    'ng_component_features',
    'ng_component_hero',
    'ng_component_lead',
    'ng_component_logos',
    'ng_component_quote',
);

$http = eZHTTPTool::instance();

// Filter / sort parameters
$filterContentType = '';
$filterShowOnlyUnused = false;
$sortType = 'name';
$sortDirection = 'ascending';

if ( $http->hasGetVariable( 'component_filter' ) )
{
    $filter = $http->getVariable( 'component_filter' );
    if ( isset( $filter['contentType'] ) )
        $filterContentType = (string)$filter['contentType'];
    if ( isset( $filter['showOnlyUnused'] ) && $filter['showOnlyUnused'] == '1' )
        $filterShowOnlyUnused = true;
    if ( isset( $filter['sortType'] ) && in_array( $filter['sortType'], array( 'name', 'last_modified' ) ) )
        $sortType = (string)$filter['sortType'];
    if ( isset( $filter['sortDirection'] ) && in_array( $filter['sortDirection'], array( 'ascending', 'descending' ) ) )
        $sortDirection = (string)$filter['sortDirection'];
}

$db = eZDB::instance();

// 1) Fetch all ng_component_* classes and their names
$componentClasses = array();
foreach ( $componentClassIdentifiers as $identifier )
{
    $class = eZContentClass::fetchByIdentifier( $identifier );
    if ( $class )
    {
        $componentClasses[$identifier] = $class;
    }
}

// 2) Resolve all ibexa_component_* block usages up front
$blockSql = "SELECT b.id, b.layout_id, b.view_type, b.definition_identifier, bp.value as content_value
             FROM explayouts_block b
             JOIN explayouts_block_parameter bp ON bp.block_id = b.id
             WHERE b.definition_identifier LIKE 'ibexa_component_%'
               AND bp.name = 'content'
               AND b.status = 2";
$blockRows = $db->arrayQuery( $blockSql );

$layoutIds = array();
$rawUsages = array();
foreach ( $blockRows as $row )
{
    $layoutIds[] = (int)$row['layout_id'];
    $rawUsages[] = $row;
}

// Fetch layout names
$layoutNames = array();
if ( !empty( $layoutIds ) )
{
    $layoutIds = array_unique( $layoutIds );
    $layoutSql = "SELECT id, name, identifier FROM explayouts_layout WHERE id IN (" . implode( ',', $layoutIds ) . ")";
    $layoutRows = $db->arrayQuery( $layoutSql );
    foreach ( $layoutRows as $layoutRow )
    {
        $layoutNames[(int)$layoutRow['id']] = array(
            'name' => (string)$layoutRow['name'],
            'identifier' => (string)$layoutRow['identifier'],
        );
    }
}

$usagesByObjectId = array();
foreach ( $rawUsages as $row )
{
    $contentValue = (int)$row['content_value'];
    $object = expComponentsResolveContent( $contentValue );
    if ( !$object )
        continue;

    $objectId = (int)$object->attribute( 'id' );
    $layoutId = (int)$row['layout_id'];
    $layoutName = isset( $layoutNames[$layoutId] ) ? $layoutNames[$layoutId]['name'] : ( 'Layout ' . $layoutId );
    $layoutIdentifier = isset( $layoutNames[$layoutId] ) ? $layoutNames[$layoutId]['identifier'] : '';

    $usagesByObjectId[$objectId][] = array(
        'layout_id' => $layoutId,
        'layout_name' => $layoutName,
        'layout_identifier' => $layoutIdentifier,
        'view_type' => (string)$row['view_type'],
        'style_name' => expComponentsHumanizeStyle( (string)$row['view_type'] ),
    );
}

// 3) Build component list
$components = array();
foreach ( $componentClasses as $identifier => $class )
{
    if ( !empty( $filterContentType ) && $identifier !== $filterContentType )
        continue;

    $conditions = array( 'contentclass_id' => (int)$class->attribute( 'id' ) );
    $objects = eZContentObject::fetchList( true, $conditions );

    foreach ( $objects as $object )
    {
        $objectId = (int)$object->attribute( 'id' );
        $usages = isset( $usagesByObjectId[$objectId] ) ? $usagesByObjectId[$objectId] : array();

        if ( $filterShowOnlyUnused && !empty( $usages ) )
            continue;

        $node = $object->attribute( 'main_node' );
        $nodeId = $node ? (int)$node->attribute( 'node_id' ) : 0;

        // Name links to the object's nice URL (admin siteaccess friendly URL).
        // Fallback to edit for objects with no node assignment.
        if ( $nodeId > 0 )
        {
            $urlAlias = (string)$node->attribute( 'url_alias' );
            $viewUrl = $urlAlias !== '' ? $urlAlias : 'content/view/full/' . $nodeId;
        }
        else
        {
            $viewUrl = 'content/edit/' . $objectId;
        }

        $components[] = array(
            'id' => $objectId,
            'name' => (string)$object->attribute( 'name' ),
            'remote_id' => (string)$object->attribute( 'remote_id' ),
            'class_identifier' => $identifier,
            'class_name' => (string)$class->attribute( 'name' ),
            'modified' => (int)$object->attribute( 'modified' ),
            'node_id' => $nodeId,
            'view_url' => $viewUrl,
            'edit_url' => 'content/edit/' . $objectId,
            'count' => count( $usages ),
            'usages' => $usages,
        );
    }
}

// 4) Sort
usort( $components, function( $a, $b ) use ( $sortType, $sortDirection )
{
    if ( $sortType === 'last_modified' )
    {
        $cmp = $a['modified'] - $b['modified'];
    }
    else
    {
        $cmp = strcasecmp( $a['name'], $b['name'] );
    }
    return $sortDirection === 'descending' ? -$cmp : $cmp;
} );

$tpl = eZTemplate::factory();
$tpl->setVariable( 'components', $components );
$tpl->setVariable( 'component_classes', $componentClasses );
$tpl->setVariable( 'filter_content_type', $filterContentType );
$tpl->setVariable( 'filter_show_only_unused', $filterShowOnlyUnused );
$tpl->setVariable( 'sort_type', $sortType );
$tpl->setVariable( 'sort_direction', $sortDirection );

$Result = array();
$Result['content'] = $tpl->fetch( 'design:explayouts_ui/components.tpl' );
$Result['left_menu'] = 'design:parts/explayouts_ui/menu.tpl';
$Result['path'] = array( array( 'url' => false,
                                'text' => ezpI18n::tr( 'explayouts_ui/components', 'Components' ) ) );
return $Result;

/**
 * Resolves a component block content parameter to the matching eZ content object,
 * using the same fallback logic as sevenxThemesMediaOperators::componentContent().
 */
function expComponentsResolveContent( $value )
{
    $id = (int)$value;
    if ( $id <= 0 )
        return false;

    $object = eZContentObject::fetchByRemoteID( 'media-o-' . ( $id + 776 ) );
    if ( !$object ) $object = eZContentObject::fetchByRemoteID( 'media-o-' . $id );
    if ( !$object ) $object = eZContentObject::fetch( $id + 776 );
    if ( !$object ) $object = eZContentObject::fetch( $id );
    return $object;
}

/**
 * Converts a view_type identifier like "features_style_2" into a human readable style label.
 */
function expComponentsHumanizeStyle( $viewType )
{
    return ucfirst( str_replace( '_', ' ', $viewType ) );
}
