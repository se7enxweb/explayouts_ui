<?php
eZDebug::updateSettings( array( 'debug-enabled' => false ) );
$module = $Params['Module'];

if ( !eZUser::currentUser()->hasAccessTo( 'explayouts', 'read' ) )
{
    return $module->handleError( eZError::KERNEL_ACCESS_DENIED, 'kernel' );
}

$db = eZDB::instance();
$rows = $db->arrayQuery( 'SELECT linked_layout_id, COUNT(*) AS ref_count FROM explayouts_zone WHERE linked_layout_id > 0 GROUP BY linked_layout_id' );
$layoutIds = array();
$sharedCounts = array();
foreach ( $rows as $row )
{
    $lid = (int)$row['linked_layout_id'];
    $layoutIds[] = $lid;
    $sharedCounts[$lid] = (int)$row['ref_count'];
}

$layouts = array();
foreach ( $layoutIds as $id )
{
    $layout = expLayoutsLayout::fetch( $id );
    if ( $layout )
        $layouts[] = $layout;
}

$layoutTypeIcons = array();
foreach ( $layouts as $layout )
{
    $type = (string)$layout->attribute( 'layout_type' );
    if ( !isset( $layoutTypeIcons[$type] ) )
    {
        $zones = expLayoutsLayoutType::getZones( $type );
        $layoutTypeIcons[$type] = generateSharedLayoutIconSvg( $zones );
    }
}

$tpl = eZTemplate::factory();
$tpl->setVariable( 'layouts', $layouts );
$tpl->setVariable( 'shared_counts', $sharedCounts );
$tpl->setVariable( 'layout_type_icons', $layoutTypeIcons );

$Result = array();
$Result['content'] = $tpl->fetch( 'design:explayouts_ui/shared_layouts_list.tpl' );
$Result['left_menu'] = 'design:parts/explayouts_ui/menu.tpl';
$Result['path'] = array( array( 'url' => false,
                                'text' => ezpI18n::tr( 'explayouts_ui/shared_layouts', 'Shared layouts' ) ) );
return $Result;

function generateSharedLayoutIconSvg( $zones )
{
    $header = array();
    $columns = array();
    $footer = array();
    foreach ( $zones as $zone )
    {
        $id = strtolower( (string)$zone );
        if ( strpos( $id, 'top' ) !== false || strpos( $id, 'header' ) !== false )
            $header[] = $zone;
        elseif ( strpos( $id, 'bottom' ) !== false || strpos( $id, 'footer' ) !== false )
            $footer[] = $zone;
        else
            $columns[] = $zone;
    }

    $headerCount = count( $header );
    $footerCount = count( $footer );
    $columnCount = count( $columns );

    if ( $columnCount === 0 )
    {
        $columns = $header;
        $header = array();
        $headerCount = 0;
    }
    if ( $columnCount === 0 )
    {
        $columns = $footer;
        $footer = array();
        $footerCount = 0;
    }
    if ( $columnCount === 0 )
    {
        $columns = array( 'main' );
        $columnCount = 1;
    }

    $width = 80;
    $height = 60;
    $pad = 2;
    $radius = 1;
    $headerHeight = $headerCount > 0 ? 10 : 0;
    $footerHeight = $footerCount > 0 ? 10 : 0;
    $middleHeight = $height - $pad * 2 - $headerCount * ( $headerHeight + $pad ) - $footerCount * ( $footerHeight + $pad );
    if ( $middleHeight < 10 )
        $middleHeight = 10;

    $svg = '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="48" viewBox="0 0 ' . $width . ' ' . $height . '" style="display:block;width:64px;height:48px;background:#fff;border:1px solid #d3d3d3;">';

    $y = $pad;
    for ( $i = 0; $i < $headerCount; $i++ )
    {
        $svg .= '<rect x="' . $pad . '" y="' . $y . '" width="' . ( $width - $pad * 2 ) . '" height="' . $headerHeight . '" rx="' . $radius . '" fill="#e0e0e0" stroke="#b0b0b0" />';
        $y += $headerHeight + $pad;
    }

    $colWidth = ( $width - $pad * 2 - $pad * ( $columnCount - 1 ) ) / $columnCount;
    $x = $pad;
    for ( $i = 0; $i < $columnCount; $i++ )
    {
        $svg .= '<rect x="' . round( $x, 2 ) . '" y="' . $y . '" width="' . round( $colWidth, 2 ) . '" height="' . $middleHeight . '" rx="' . $radius . '" fill="#e9e9e9" stroke="#b0b0b0" />';
        $x += $colWidth + $pad;
    }

    $y += $middleHeight + $pad;
    for ( $i = 0; $i < $footerCount; $i++ )
    {
        $svg .= '<rect x="' . $pad . '" y="' . $y . '" width="' . ( $width - $pad * 2 ) . '" height="' . $footerHeight . '" rx="' . $radius . '" fill="#e0e0e0" stroke="#b0b0b0" />';
        $y += $footerHeight + $pad;
    }

    $svg .= '</svg>';
    return $svg;
}
