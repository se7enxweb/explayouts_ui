<?php
eZDebug::updateSettings( array( 'debug-enabled' => false ) );
$http = eZHTTPTool::instance();
$module = $Params['Module'];

if ( !eZUser::currentUser()->hasAccessTo( 'explayouts', 'edit' ) )
{
    return $module->handleError( eZError::KERNEL_ACCESS_DENIED, 'kernel' );
}

$layoutId = isset( $Params['LayoutID'] ) ? (int)$Params['LayoutID'] : 0;
if ( $layoutId > 0 )
    $layout = expLayoutsLayout::fetch( $layoutId );
else
    $layout = expLayoutsLayout::create( '' );

if ( !$layout )
    return $module->handleError( eZError::KERNEL_NOT_FOUND, 'kernel' );

$message = '';
$error = '';

function expLayoutEnsureZones( $layout )
{
    $layoutType = $layout->attribute( 'layout_type' );
    if ( $layoutType === '' )
        return;

    $existing = array();
    foreach ( expLayoutsZone::fetchByLayout( $layout->attribute( 'id' ), $layout->attribute( 'status' ) ) as $zone )
    {
        $existing[$zone->attribute( 'identifier' )] = true;
    }

    $position = count( $existing );
    foreach ( expLayoutsLayoutType::getZones( $layoutType ) as $zoneIdentifier )
    {
        if ( isset( $existing[$zoneIdentifier] ) )
            continue;
        $zone = expLayoutsZone::create( $layout->attribute( 'id' ), $zoneIdentifier, $layout->attribute( 'status' ) );
        $zone->setAttribute( 'position', $position );
        $zone->store();
        $position++;
    }
}

function expLayoutDeleteBlock( $blockId )
{
    $block = expLayoutsBlock::fetch( $blockId );
    if ( !$block )
        return;

    $zoneId = (int)$block->attribute( 'zone_id' );
    foreach ( expLayoutsBlockParameter::fetchByBlock( $blockId ) as $param )
        $param->remove();
    $block->remove();

    expLayoutReorderBlocks( $zoneId );
}

function expLayoutReorderBlocks( $zoneId )
{
    $blocks = expLayoutsBlock::fetchByZone( $zoneId );
    if ( !is_array( $blocks ) )
        return;

    usort( $blocks, function( $a, $b )
    {
        return (int)$a->attribute( 'position' ) - (int)$b->attribute( 'position' );
    });

    $position = 0;
    foreach ( $blocks as $block )
    {
        $block->setAttribute( 'position', $position );
        $block->store();
        $position++;
    }
}

if ( $http->hasPostVariable( 'SaveDraft' ) )
{
    $layout->setAttribute( 'identifier', trim( $http->postVariable( 'Identifier' ) ) );
    $layout->setAttribute( 'name', trim( $http->postVariable( 'Name' ) ) );
    $layout->setAttribute( 'layout_type', trim( $http->postVariable( 'LayoutType' ) ) );
    $layout->setAttribute( 'modified', time() );
    if ( (int)$layout->attribute( 'status' ) === 0 )
        $layout->setAttribute( 'status', 1 );
    $layout->store();
    expLayoutEnsureZones( $layout );
    $message = 'Draft saved.';
}

if ( $http->hasPostVariable( 'Publish' ) )
{
    $layout->publish();
    expLayoutEnsureZones( $layout );
    $message = 'Published.';
}

if ( $http->hasPostVariable( 'AddZone' ) )
{
    $zoneIdentifier = trim( $http->postVariable( 'ZoneIdentifier' ) );
    if ( $zoneIdentifier !== '' )
    {
        $zone = expLayoutsZone::create( $layout->attribute( 'id' ), $zoneIdentifier, $layout->attribute( 'status' ) );
        $zone->store();
    }
}

if ( $http->hasPostVariable( 'DeleteZone' ) )
{
    $deleteZoneId = (int)$http->postVariable( 'DeleteZoneID' );
    $zone = expLayoutsZone::fetch( $deleteZoneId );
    if ( $zone && (int)$zone->attribute( 'layout_id' ) === (int)$layout->attribute( 'id' ) )
    {
        foreach ( expLayoutsBlock::fetchByZone( $deleteZoneId ) as $block )
        {
            expLayoutDeleteBlock( (int)$block->attribute( 'id' ) );
        }
        $zone->remove();
        $message = 'Zone deleted.';
    }
    else
    {
        $error = 'Zone not found.';
    }
}

if ( $http->hasPostVariable( 'AddBlock' ) )
{
    $zoneId = (int)$http->postVariable( 'ZoneID' );
    $definition = trim( $http->postVariable( 'DefinitionIdentifier' ) );
    if ( $zoneId > 0 && $definition !== '' )
    {
        $zone = expLayoutsZone::fetch( $zoneId );
        if ( $zone && (int)$zone->attribute( 'layout_id' ) === (int)$layout->attribute( 'id' ) )
        {
            $position = count( expLayoutsBlock::fetchByZone( $zoneId, $layout->attribute( 'status' ) ) );
            $block = expLayoutsBlock::create( $zoneId, $layout->attribute( 'id' ), $definition, $definition );
            $block->setAttribute( 'position', $position );
            $block->store();
        }
    }
}

if ( $http->hasPostVariable( 'DeleteBlock' ) )
{
    $deleteBlockId = (int)$http->postVariable( 'DeleteBlockID' );
    $block = expLayoutsBlock::fetch( $deleteBlockId );
    if ( $block && (int)$block->attribute( 'layout_id' ) === (int)$layout->attribute( 'id' ) )
    {
        expLayoutDeleteBlock( $deleteBlockId );
        $message = 'Block deleted.';
    }
    else
    {
        $error = 'Block not found.';
    }
}

if ( $http->hasPostVariable( 'MoveBlockUp' ) || $http->hasPostVariable( 'MoveBlockDown' ) )
{
    $moveBlockId = (int)$http->postVariable( 'MoveBlockID' );
    $block = expLayoutsBlock::fetch( $moveBlockId );
    if ( $block && (int)$block->attribute( 'layout_id' ) === (int)$layout->attribute( 'id' ) )
    {
        $zoneId = (int)$block->attribute( 'zone_id' );
        $blocks = expLayoutsBlock::fetchByZone( $zoneId, $layout->attribute( 'status' ) );
        usort( $blocks, function( $a, $b ) { return (int)$a->attribute( 'position' ) - (int)$b->attribute( 'position' ); } );
        $index = -1;
        foreach ( $blocks as $i => $b )
        {
            if ( (int)$b->attribute( 'id' ) === $moveBlockId )
            {
                $index = $i;
                break;
            }
        }

        if ( $http->hasPostVariable( 'MoveBlockUp' ) && $index > 0 )
        {
            $swap = $blocks[$index - 1];
            $current = $blocks[$index];
            $tmp = (int)$swap->attribute( 'position' );
            $swap->setAttribute( 'position', (int)$current->attribute( 'position' ) );
            $current->setAttribute( 'position', $tmp );
            $swap->store();
            $current->store();
            $message = 'Block moved up.';
        }
        elseif ( $http->hasPostVariable( 'MoveBlockDown' ) && $index >= 0 && $index < count( $blocks ) - 1 )
        {
            $swap = $blocks[$index + 1];
            $current = $blocks[$index];
            $tmp = (int)$swap->attribute( 'position' );
            $swap->setAttribute( 'position', (int)$current->attribute( 'position' ) );
            $current->setAttribute( 'position', $tmp );
            $swap->store();
            $current->store();
            $message = 'Block moved down.';
        }
    }
    else
    {
        $error = 'Block not found.';
    }
}

if ( $http->hasPostVariable( 'MoveBlockToZone' ) )
{
    $moveBlockId = (int)$http->postVariable( 'MoveBlockID' );
    $targetZoneId = (int)$http->postVariable( 'TargetZoneID' );
    $block = expLayoutsBlock::fetch( $moveBlockId );
    $targetZone = expLayoutsZone::fetch( $targetZoneId );
    if ( $block && $targetZone
        && (int)$block->attribute( 'layout_id' ) === (int)$layout->attribute( 'id' )
        && (int)$targetZone->attribute( 'layout_id' ) === (int)$layout->attribute( 'id' ) )
    {
        $oldZoneId = (int)$block->attribute( 'zone_id' );
        $newPosition = count( expLayoutsBlock::fetchByZone( $targetZoneId, $layout->attribute( 'status' ) ) );
        $block->setAttribute( 'zone_id', $targetZoneId );
        $block->setAttribute( 'position', $newPosition );
        $block->store();
        expLayoutReorderBlocks( $oldZoneId );
        $message = 'Block moved to zone.';
    }
    else
    {
        $error = 'Cannot move block.';
    }
}

$zones = expLayoutsZone::fetchByLayout( $layout->attribute( 'id' ), $layout->attribute( 'status' ) );
$zonesWithBlocks = array();
foreach ( $zones as $zone )
{
    $blocks = expLayoutsBlock::fetchByZone( $zone->attribute( 'id' ), $layout->attribute( 'status' ) );
    usort( $blocks, function( $a, $b ) { return (int)$a->attribute( 'position' ) - (int)$b->attribute( 'position' ); } );
    $zonesWithBlocks[] = array(
        'zone' => $zone,
        'blocks' => $blocks,
    );
}

$availableBlocks = expLayoutsBlockHandlerFactory::getAvailableBlocks();
$blockInfos = array();
foreach ( $availableBlocks as $identifier )
{
    $info = expLayoutsBlockHandlerFactory::getBlockInfo( $identifier );
    if ( $info )
        $blockInfos[] = $info;
}

$tpl = eZTemplate::factory();
$tpl->setVariable( 'layout', $layout );
$tpl->setVariable( 'zones', $zonesWithBlocks );
$tpl->setVariable( 'available_blocks', $blockInfos );
$tpl->setVariable( 'available_types', expLayoutsLayoutType::getAvailableTypes() );
$tpl->setVariable( 'message', $message );
$tpl->setVariable( 'error', $error );

$Result = array();
$Result['content'] = $tpl->fetch( 'design:explayouts_ui/layout_edit.tpl' );
$Result['left_menu'] = 'design:parts/explayouts_ui/menu.tpl';
$Result['path'] = array( array( 'url' => false,
                                'text' => ezpI18n::tr( 'explayouts_ui/layout', $layoutId > 0 ? 'Edit Layout' : 'New Layout' ) ) );
return $Result;
