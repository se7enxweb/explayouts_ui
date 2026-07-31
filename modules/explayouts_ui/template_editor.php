<?php
eZDebug::updateSettings( array( 'debug-enabled' => false ) );
$editorClassFile = eZSys::rootDir() . '/extension/explayouts/classes/explayoutstemplateeditor.php';
if ( function_exists( 'opcache_invalidate' ) && file_exists( $editorClassFile ) )
    opcache_invalidate( $editorClassFile, true );

$httpCharset = eZTextCodec::httpCharset();
$selectedPath = '';
$content = '';

function expTeJsonResponse( $data )
{
    header( 'Content-Type: application/json; charset=utf-8' );
    echo json_encode( $data );
    eZExecution::cleanExit();
}

if ( isset( $_SERVER['HTTP_X_REQUESTED_WITH'] ) && $_SERVER['HTTP_X_REQUESTED_WITH'] === 'XMLHttpRequest' )
{
    if ( isset( $_GET['file'] ) && $_GET['file'] !== '' )
    {
        $selectedPath = $_GET['file'];
        $content = expLayoutsTemplateEditor::read( $selectedPath );
        if ( $content === false )
            expTeJsonResponse( array( 'success' => false, 'error' => 'Unable to read template: ' . $selectedPath ) );
        expTeJsonResponse( array( 'success' => true, 'content' => $content ) );
    }

    if ( $_SERVER['REQUEST_METHOD'] === 'POST' && isset( $_POST['SaveTemplate'] ) )
    {
        $selectedPath = isset( $_POST['SelectedPath'] ) ? $_POST['SelectedPath'] : '';
        $content = isset( $_POST['TemplateContent'] ) ? $_POST['TemplateContent'] : '';
        $content = str_replace( "\r\n", "\n", $content );
        $ok = expLayoutsTemplateEditor::save( $selectedPath, $content );
        expTeJsonResponse( array( 'success' => $ok, 'message' => $ok ? 'Saved' : 'Save failed' ) );
    }

    expTeJsonResponse( array( 'success' => false, 'error' => 'Unknown request' ) );
}

$templates = expLayoutsTemplateEditor::listTemplates();

$jsonFlags = JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT;
$filesJson = json_encode( $templates, $jsonFlags );
if ( $filesJson === false )
    $filesJson = '[]';
$selectedJson = json_encode( $selectedPath, $jsonFlags );
if ( $selectedJson === false )
    $selectedJson = '""';
$initialJson = json_encode( $content, $jsonFlags );
if ( $initialJson === false )
    $initialJson = '""';

$baseUrl = eZSys::indexDir();
if ( $baseUrl === '' || $baseUrl === false )
    $baseUrl = '/';
if ( substr( $baseUrl, -1 ) !== '/' )
    $baseUrl .= '/';
$baseUrl .= 'explayouts_ui/template_editor';
$baseUrl = '/' . ltrim( $baseUrl, '/' );
$baseUrl = json_encode( $baseUrl, $jsonFlags );

$csrfToken = ( class_exists( 'ezxFormToken' ) ? ezxFormToken::getToken() : '' );
$csrfJson = json_encode( $csrfToken, $jsonFlags );

$templateFile = eZSys::rootDir() . '/extension/explayouts_ui/design/admin/templates/explayouts_ui/template_editor.tpl';
if ( !file_exists( $templateFile ) )
{
    $Result = array();
    $Result['pagelayout'] = false;
    $Result['content'] = 'Template not found.';
    return $Result;
}

$html = file_get_contents( $templateFile );
$html = str_replace(
    array( '{$files_json}', '{$selected_json}', '{$initial_content_json}', '{$base_url}', '{$csrf_token}' ),
    array( $filesJson, $selectedJson, $initialJson, $baseUrl, $csrfJson ),
    $html
);

$Result = array();
$Result['pagelayout'] = false;
$Result['content'] = $html;

header( 'Cache-Control: no-store, no-cache, must-revalidate, max-age=0' );
header( 'Pragma: no-cache' );
header( 'Expires: Thu, 1 Jan 1970 00:00:00 GMT' );

return $Result;
