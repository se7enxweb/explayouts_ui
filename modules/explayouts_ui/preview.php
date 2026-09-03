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

$Result = array();
$Result['pagelayout'] = true;
$Result['content'] = $tpl->fetch( 'design:explayouts/layout.tpl' );
$Result['content_info'] = array( 'viewmode' => 'layout_preview' );
$Result['path'] = array( array( 'url' => false,
                                'text' => ezpI18n::tr( 'explayouts_ui/preview', 'Preview layout' ) ) );
return $Result;
