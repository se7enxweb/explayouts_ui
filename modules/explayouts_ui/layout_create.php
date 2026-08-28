<?php
eZDebug::updateSettings( array( 'debug-enabled' => false ) );
$http = eZHTTPTool::instance();
$module = $Params['Module'];

if ( !eZUser::currentUser()->hasAccessTo( 'explayouts', 'edit' ) )
{
    return $module->handleError( eZError::KERNEL_ACCESS_DENIED, 'kernel' );
}

if ( $http->hasPostVariable( 'CreateLayout' ) )
{
    $name = trim( $http->postVariable( 'Name' ) );
    $identifier = trim( $http->postVariable( 'Identifier' ) );
    $layoutType = trim( $http->postVariable( 'LayoutType' ) );

    if ( $name === '' )
        $name = 'New layout';
    if ( $identifier === '' )
    {
        $identifier = strtolower( trim( preg_replace( '/[^a-zA-Z0-9_-]/', '_', $name ), '_' ) );
        if ( $identifier === '' )
            $identifier = 'new_layout_' . time();
    }

    $layout = expLayoutsLayout::create( $identifier, $name, $layoutType );
    $layout->setAttribute( 'status', 1 );
    $layout->setAttribute( 'created', time() );
    $layout->setAttribute( 'modified', time() );
    $layout->store();

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

    return $module->redirectTo( '/explayouts_ui_api/app#layout/' . $layout->attribute( 'id' ) );
}

$tpl = eZTemplate::factory();
$tpl->setVariable( 'available_types', expLayoutsLayoutType::getAvailableTypes() );
$content = $tpl->fetch( 'design:explayouts_ui/layout_create.tpl' );

$Result = array();
$Result['content'] = $content;
$Result['left_menu'] = 'design:parts/explayouts_ui/menu.tpl';
$Result['path'] = array( array( 'url' => false,
                                'text' => ezpI18n::tr( 'explayouts_ui/layout', 'New Layout' ) ) );
return $Result;
