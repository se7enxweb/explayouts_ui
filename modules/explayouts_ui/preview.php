<?php
$module = $Params['Module'];

if ( !eZUser::currentUser()->hasAccessTo( 'explayouts', 'read' ) )
{
    return $module->handleError( eZError::KERNEL_ACCESS_DENIED, 'kernel' );
}

$layoutId = isset( $Params['LayoutID'] ) ? (int)$Params['LayoutID'] : 0;
$status = isset( $Params['Status'] ) ? (int)$Params['Status'] : 2;
$layout = expLayoutsLayout::fetch( $layoutId, $status );

if ( !$layout )
    return $module->handleError( eZError::KERNEL_NOT_FOUND, 'kernel' );

$prepared = expLayoutsRenderer::prepareLayout( $layout, $status );

/**
 * Pick a node to preview the layout against.
 *
 * full_view and every content-driven block (the explayouts/tpl_block region
 * templates, and the content/parts/* fragments behind them) resolve their node
 * from $module_result.content_info.node_id and render nothing without it. The
 * layout's own mapping rule says which content it is for, so use that; a
 * catch-all rule such as path_info_prefix "/" resolves to the site index page.
 *
 * ?node_id=N overrides the choice for a one-off preview.
 */
function expLayoutsPreviewNode( $layoutId )
{
    $requested = isset( $_GET['node_id'] ) ? (int)$_GET['node_id'] : 0;
    if ( $requested > 0 )
    {
        $node = eZContentObjectTreeNode::fetch( $requested );
        if ( $node )
            return $node;
    }

    // Highest priority first, matching how the resolver picks a rule.
    $rules = eZPersistentObject::fetchObjectList(
        expLayoutsRule::definition(), null,
        array( 'layout_id' => (int)$layoutId ),
        array( 'priority' => 'desc', 'id' => 'asc' ), null, true
    );
    if ( is_array( $rules ) )
    {
        foreach ( $rules as $rule )
        {
            // A "class" condition says which content types the rule is for, so
            // a subtree target can pick a node the layout is actually meant to
            // render instead of whatever was published there most recently.
            $classFilter = array();
            foreach ( $rule->conditions() as $condition )
            {
                if ( (string)$condition->attribute( 'condition_type' ) !== 'class' )
                    continue;

                $decoded = json_decode( (string)$condition->attribute( 'condition_value' ), true );
                if ( is_array( $decoded ) )
                    $classFilter = array_merge( $classFilter, $decoded );
                elseif ( is_string( $decoded ) && $decoded !== '' )
                    $classFilter[] = $decoded;
            }

            foreach ( $rule->targets() as $target )
            {
                $type = (string)$target->attribute( 'target_type' );
                $value = (string)$target->attribute( 'target_value' );

                if ( $type === 'node' )
                {
                    $node = eZContentObjectTreeNode::fetch( (int)$value );
                    if ( $node )
                        return $node;
                }
                elseif ( $type === 'subtree' )
                {
                    // A subtree rule targets the descendants, so prefer a
                    // descendant of the right class over the container itself.
                    $params = array( 'Limit' => 1, 'SortBy' => array( array( 'published', false ) ) );
                    if ( !empty( $classFilter ) )
                        $params['ClassFilterType'] = 'include';
                    if ( !empty( $classFilter ) )
                        $params['ClassFilterArray'] = $classFilter;

                    $descendants = eZContentObjectTreeNode::subTreeByNodeID( $params, (int)$value );
                    if ( is_array( $descendants ) && !empty( $descendants ) )
                        return $descendants[0];

                    $node = eZContentObjectTreeNode::fetch( (int)$value );
                    if ( $node )
                        return $node;
                }
                elseif ( in_array( $type, array( 'path', 'path_prefix', 'path_info_prefix' ) ) )
                {
                    $node = expLayoutsResolver::nodeFromPath( $value );
                    if ( $node )
                        return $node;
                }
            }
        }
    }

    // No usable target: fall back to the site index page.
    return expLayoutsResolver::nodeFromPath( '' );
}

// Resolved after the siteaccess switch below, so the IndexPage fallback reads
// the public site.ini rather than the admin one.
$previewNode = false;

// Render preview in the default/public siteaccess so it uses the real site styles, scripts and pagelayout.
$siteAccess = eZINI::instance( 'site.ini' )->variable( 'SiteSettings', 'DefaultAccess' );

$access = $GLOBALS['eZCurrentAccess'];
$access['name'] = $siteAccess;
if ( $access['type'] === eZSiteAccess::TYPE_URI )
{
    $access['uri_part'] = array( $siteAccess );
}

eZSiteAccess::load( $access );
eZDebug::checkDebugByUser();

$previewNode = expLayoutsPreviewNode( $layoutId );

$ini = eZINI::instance();
$res = eZTemplateDesignResource::instance();
$res->setDesignSetting( $ini->variable( 'DesignSettings', 'SiteDesign' ), 'site' );
$res->setOverrideAccess( $siteAccess );

// eZINI design.ini may keep admin values after the siteaccess switch; inject the
// public siteaccess extension stylesheet/javascript lists so template operators
// like ezcss_load and ezscript_load output the correct <link>/<script> includes.
$designIni = eZINI::instance( 'design.ini' );
$designExtensions = $designIni->hasVariable( 'ExtensionSettings', 'DesignExtensions' )
    ? $designIni->variable( 'ExtensionSettings', 'DesignExtensions' )
    : array();
$cssFileList = $designIni->hasVariable( 'StylesheetSettings', 'CSSFileList' )
    ? $designIni->variable( 'StylesheetSettings', 'CSSFileList' )
    : array();
$frontendCssFileList = $designIni->hasVariable( 'StylesheetSettings', 'FrontendCSSFileList' )
    ? $designIni->variable( 'StylesheetSettings', 'FrontendCSSFileList' )
    : array();
$jsFileList = $designIni->hasVariable( 'JavaScriptSettings', 'JavaScriptList' )
    ? $designIni->variable( 'JavaScriptSettings', 'JavaScriptList' )
    : array();
$frontendJsFileList = $designIni->hasVariable( 'JavaScriptSettings', 'FrontendJavaScriptList' )
    ? $designIni->variable( 'JavaScriptSettings', 'FrontendJavaScriptList' )
    : array();

eZINI::injectSettings( array(
    'design.ini' => array(
        'ExtensionSettings' => array( 'DesignExtensions' => is_array( $designExtensions ) ? $designExtensions : array() ),
        'StylesheetSettings' => array(
            'CSSFileList' => is_array( $cssFileList ) ? $cssFileList : array(),
            'FrontendCSSFileList' => is_array( $frontendCssFileList ) ? $frontendCssFileList : array(),
        ),
        'JavaScriptSettings' => array(
            'JavaScriptList' => is_array( $jsFileList ) ? $jsFileList : array(),
            'FrontendJavaScriptList' => is_array( $frontendJsFileList ) ? $frontendJsFileList : array(),
        ),
    )
) );

$tpl = eZTemplate::factory();
$tpl->setVariable( 'layout', $prepared );

$contentInfo = array( 'viewmode' => 'layout_preview' );
if ( $previewNode )
{
    $contentInfo['node_id'] = (int)$previewNode->attribute( 'node_id' );
    $contentInfo['object_id'] = (int)$previewNode->attribute( 'contentobject_id' );
    $contentInfo['class_identifier'] = (string)$previewNode->attribute( 'class_identifier' );
}

// The full_view block renders {$module_result.content} — the output of the
// request being previewed, which does not exist here. Render the preview
// node's full view into it so the block is not an empty shell.
$previewContent = '';
if ( $previewNode )
{
    $viewTpl = eZTemplate::factory();
    $viewTpl->setVariable( 'preview_node', $previewNode );
    $previewContent = $viewTpl->fetch( 'design:explayouts_ui/preview_full_view.tpl' );
}

// layout.tpl passes module_result down to every zone and block, so the
// content-driven blocks need it available during this fetch, not only in the
// pagelayout afterwards.
$Result = array();
$Result['content_info'] = $contentInfo;
$Result['content'] = $previewContent;
$tpl->setVariable( 'module_result', $Result );

$Result['pagelayout'] = true;
$Result['content'] = $tpl->fetch( 'design:explayouts/layout.tpl' );
if ( $previewNode )
    $Result['node_id'] = (int)$previewNode->attribute( 'node_id' );
$Result['path'] = array( array( 'url' => false,
                                'text' => ezpI18n::tr( 'explayouts_ui/preview', 'Preview layout' ) ) );
return $Result;
