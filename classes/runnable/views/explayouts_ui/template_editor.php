<?php
/**
 * explayouts_ui/template_editor: the template editor of the layout templates, inside the administration's page (top
 * menu, breadcrumb, the Layouts left menu).
 *
 * The address takes view parameters only, as visual/templateedit does: the template's path as the trailing parts,
 * then the siteaccess and the design filter as unordered parameters:
 *
 *   explayouts_ui/template_editor[/<path of the template>][/(siteaccess)/<name>][/(design)/<design base>]
 *
 * The list holds every template in templates/explayouts/ of the design chain of the chosen public siteaccess
 * (eZTemplateDesignResource::allDesignBases: SiteDesign, AdditionalSiteDesignList, StandardDesign, each in the
 * DesignExtensions and in design/), with the file each template is drawn from for that siteaccess and the ones it
 * overrides. A template is changed in place only inside explayouts.ini [TemplateEditorSettings]
 * AllowedTemplateRoots; any other is read-only, and can be copied as an override into an allowed design that comes
 * before it in the chain.
 *
 * GET                               the page: the template list (search and filters) and the editor
 * GET  <path>, XHR                  a template's text and facts (original kept, used by, overrides, writable)
 * POST ChooseSiteAccessButton       the siteaccess chooser: redirects (303) to the address of the chosen siteaccess
 * POST Action=check, XHR            the syntax check and the diff of the editor's text against the saved file (or the
 *                                   original, Compare=original); writes nothing
 * POST Action=save, XHR             checks, then saves (backup and original kept); refused on a syntax error
 * POST Action=revert, XHR           puts the original back
 * POST Action=override, XHR         copies the template into Target (a design base) as an override
 *
 * Every write needs explayouts_ui/edit (the view itself also opens with explayouts_ui/read) and the form token, and
 * is written to the audit log (system.template.change, never the text).
 *
 * The code of extension/explayouts_ui/modules/explayouts_ui/template_editor.php (#207); guide:
 * doc/bc/6.0/cli_cronjob_view_abstractions.md
 */

namespace
{
if ( !function_exists( 'expModuleViewExplayoutsUiTemplateEditorJsonResponse' ) ) {
function expModuleViewExplayoutsUiTemplateEditorJsonResponse( $data, $status = 200 )
{
    if ( $status !== 200 )
        header( 'HTTP/1.1 ' . (int)$status . ' ' . ( $status === 403 ? 'Forbidden' : ( $status === 405 ? 'Method Not Allowed' : 'Unprocessable Entity' ) ) );
    header( 'Content-Type: application/json; charset=utf-8' );
    header( 'Cache-Control: no-store' );
    header( 'X-Content-Type-Options: nosniff' );
    echo json_encode( $data );
    eZExecution::cleanExit();
}
}
}

namespace Exponential\View\Extension\ExplayoutsUi\ExplayoutsUi
{

class TemplateEditor extends \Exponential\Runnable\ModuleView
{
    const CONTEXT = 'design/admin/explayouts_ui/template_editor';

    /** The chosen siteaccess, for the requests of this run */
    protected $siteAccess = '';

    public function run( array $scope )
    {
        // the including function's variables ($Params, $Module, $cli, ...)
        foreach ( array_keys( $scope ) as $__name )
            if ( $__name !== 'this' && $__name !== 'scope' )
                ${$__name} = &$scope[$__name];
        unset( $__name );

        $http = \eZHTTPTool::instance();
        $isXhr = isset( $_SERVER['HTTP_X_REQUESTED_WITH'] ) && $_SERVER['HTTP_X_REQUESTED_WITH'] === 'XMLHttpRequest';
        $method = isset( $_SERVER['REQUEST_METHOD'] ) ? $_SERVER['REQUEST_METHOD'] : 'GET';

        // the view parameters: the path as the trailing parts, (siteaccess) and (design)
        $path = implode( '/', isset( $Params['Parameters'] ) ? array_map( 'strval', (array)$Params['Parameters'] ) : array() );
        $front = \expLayoutsUiTemplateEditor::frontSiteAccesses();
        $asked = isset( $Params['SiteAccess'] ) && is_string( $Params['SiteAccess'] ) ? $Params['SiteAccess'] : '';
        if ( $method === 'POST' && $http->hasPostVariable( 'SiteAccess' ) && is_string( $http->postVariable( 'SiteAccess' ) ) )
            $asked = $http->postVariable( 'SiteAccess' );
        $this->siteAccess = isset( $front[$asked] ) ? $asked : \expLayoutsUiTemplateEditor::defaultSiteAccess( $front );
        $design = isset( $Params['Design'] ) && is_string( $Params['Design'] ) ? $Params['Design'] : '';

        if ( $isXhr )
        {
            \eZDebug::updateSettings( array( 'debug-enabled' => false ) );
            if ( $method === 'POST' )
                $this->handlePost();
            if ( $path !== '' )
                $this->handleRead( $path );
            expModuleViewExplayoutsUiTemplateEditorJsonResponse( array( 'success' => false, 'error' => \ezpI18n::tr( self::CONTEXT, 'Unknown request' ) ), 422 );
        }
        if ( $method === 'POST' )
        {
            // the siteaccess chooser: a form post that goes on to the address of the chosen siteaccess
            if ( $http->hasPostVariable( 'ChooseSiteAccessButton' ) )
            {
                $Module->setRedirectStatus( '303 See Other' );
                return $this->viewResult( null, $Module->redirectTo( self::viewUri( '', $this->siteAccess, '' ) ) );
            }
            // writes go through the page's script only: a plain form post is not a way in
            expModuleViewExplayoutsUiTemplateEditorJsonResponse( array( 'success' => false, 'error' => \ezpI18n::tr( self::CONTEXT, 'Unknown request' ) ), 422 );
        }

        $chain = $this->siteAccess !== '' ? \expLayoutsUiTemplateEditor::chain( $this->siteAccess ) : array( 'bases' => array(), 'rows' => array() );
        $rows = $chain['rows'];
        $groups = array();
        foreach ( $rows as $row )
            if ( $row['group'] !== '' )
                $groups[$row['group']] = true;
        ksort( $groups );
        $designs = array();
        foreach ( $chain['bases'] as $base )
        {
            $where = \expLayoutsUiTemplateEditor::locate( $base . '/templates/x.tpl' );
            $designs[] = array( 'base' => $base, 'design' => $where['design'], 'extension' => $where['extension'] );
        }
        if ( !in_array( $design, $chain['bases'], true ) )
            $design = '';

        $paths = array_column( $rows, 'path' );
        $selected = $path !== '' && \expLayoutsUiTemplateEditor::readableFile( $path, $this->siteAccess ) !== false ? $path : '';
        if ( $selected !== '' && !in_array( $selected, $paths, true ) )
        {
            // a template of AllowedTemplateRoots outside the chain of this siteaccess: still opened, with its row
            $where = \expLayoutsUiTemplateEditor::locate( $selected );
            $rows[] = array( 'path' => $selected, 'base' => '', 'base_index' => -1, 'design' => $where['design'],
                'extension' => $where['extension'], 'relative' => $where['relative'], 'name' => basename( $selected ),
                'folder' => dirname( $selected ), 'group' => $where['group'], 'winner' => null, 'overridden_by' => array(),
                'overrides' => array(), 'writable' => \expLayoutsUiTemplateEditor::isWritable( $selected ),
                'changed' => \expLayoutsUiTemplateEditor::hasOriginal( $selected ) );
        }

        $baseUrl = 'explayouts_ui/template_editor';
        \eZURI::transformURI( $baseUrl );

        $jsonFlags = JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT;
        $data = array(
            'rows' => $rows,
            'bases' => $designs,
            'base_url' => $baseUrl,
            'siteaccess' => $this->siteAccess,
            'design' => $design,
            'selected' => $selected,
            'selected_meta' => $selected !== '' ? $this->meta( $selected ) : null,
            'csrf_token' => class_exists( 'ezxFormToken' ) ? \ezxFormToken::getToken() : '',
            'can_edit' => \expLayoutsUiTemplateEditor::currentUserCanEdit(),
            // an older explayouts without the setting offers no New
            'allow_new' => method_exists( 'expLayoutsTemplateEditor', 'newTemplatesAllowed' ) && \expLayoutsTemplateEditor::newTemplatesAllowed(),
        );
        $dataJson = json_encode( $data, $jsonFlags );

        $tpl = \eZTemplate::factory();
        $tpl->setVariable( 'editor_json', $dataJson === false ? '{}' : $dataJson );
        $tpl->setVariable( 'template_count', count( $rows ) );
        // an open template is drawn open from the start, so the page does not move when the script opens it
        $tpl->setVariable( 'selected_path', $selected );
        $tpl->setVariable( 'designs', $designs );
        $tpl->setVariable( 'design', $design );
        $tpl->setVariable( 'groups', array_keys( $groups ) );
        $tpl->setVariable( 'siteaccesses', array_keys( $front ) );
        $tpl->setVariable( 'siteaccess', $this->siteAccess );
        $tpl->setVariable( 'can_edit', $data['can_edit'] );
        $tpl->setVariable( 'allow_new_templates', $data['can_edit'] && $data['allow_new'] );

        header( 'Cache-Control: no-store, no-cache, must-revalidate, max-age=0' );

        $Result = array();
        $Result['content'] = $tpl->fetch( 'design:explayouts_ui/template_editor.tpl' );
        $Result['left_menu'] = 'design:parts/explayouts_ui/menu.tpl';
        $Result['path'] = array( array( 'url' => 'explayouts_ui/dashboard', 'text' => \ezpI18n::tr( 'explayouts_ui/layout', 'Layouts' ) ),
                                 array( 'url' => false, 'text' => \ezpI18n::tr( self::CONTEXT, 'Template editor' ) ) );
        return $this->viewResult( $Result, $Result );
    }

    /**
     * The address of the view with its view parameters (without the site's prefix).
     */
    public static function viewUri( $path, $siteAccess, $design )
    {
        $uri = '/explayouts_ui/template_editor';
        if ( $path !== '' )
            $uri .= '/' . implode( '/', array_map( 'rawurlencode', explode( '/', $path ) ) );
        if ( $siteAccess !== '' )
            $uri .= '/(siteaccess)/' . rawurlencode( $siteAccess );
        if ( $design !== '' )
            $uri .= '/(design)/' . implode( '/', array_map( 'rawurlencode', explode( '/', $design ) ) );
        return $uri;
    }

    /**
     * The facts of a template the editor shows beside it, for the chosen siteaccess.
     */
    protected function meta( $path )
    {
        $meta = array(
            'path' => $path,
            'has_original' => \expLayoutsUiTemplateEditor::hasOriginal( $path ),
            'used_by' => \expLayoutsUiTemplateEditor::usedBy( $path ),
            'writable' => \expLayoutsUiTemplateEditor::isWritable( $path ),
            'winner' => null,
            'overridden_by' => array(),
            'overrides' => array(),
            'override_targets' => array(),
        );
        if ( $this->siteAccess === '' )
            return $meta;
        $chain = \expLayoutsUiTemplateEditor::chain( $this->siteAccess );
        foreach ( $chain['rows'] as $row )
        {
            if ( $row['path'] !== $path )
                continue;
            $meta['winner'] = $row['winner'];
            $meta['overridden_by'] = $row['overridden_by'];
            $meta['overrides'] = $row['overrides'];
            if ( \expLayoutsUiTemplateEditor::currentUserCanEdit() )
                $meta['override_targets'] = \expLayoutsUiTemplateEditor::overrideTargets( $row, $chain['rows'], $chain['bases'] );
        }
        return $meta;
    }

    protected function handleRead( $path )
    {
        $content = \expLayoutsUiTemplateEditor::readFor( $path, $this->siteAccess );
        if ( $content === false )
            expModuleViewExplayoutsUiTemplateEditorJsonResponse( array( 'success' => false, 'error' => \ezpI18n::tr( self::CONTEXT, 'Unable to read template: %path', null, array( '%path' => $path ) ) ), 422 );
        expModuleViewExplayoutsUiTemplateEditorJsonResponse( array( 'success' => true, 'content' => $content, 'meta' => $this->meta( $path ) ) );
    }

    protected function handlePost()
    {
        $posted = isset( $_POST['ezxform_token'] ) ? $_POST['ezxform_token'] : ( isset( $_SERVER['HTTP_X_CSRF_TOKEN'] ) ? $_SERVER['HTTP_X_CSRF_TOKEN'] : '' );
        $expected = class_exists( 'ezxFormToken' ) ? \ezxFormToken::getToken() : '';
        $refusal = \expLayoutsUiTemplateEditor::writeRefusal( $_SERVER['REQUEST_METHOD'], \expLayoutsUiTemplateEditor::currentUserCanEdit(),
                                                              \expLayoutsUiTemplateEditor::tokenMatches( $posted, $expected ) );
        if ( $refusal !== null )
        {
            $messages = array( 'method' => \ezpI18n::tr( self::CONTEXT, 'Changes must be sent with POST.' ),
                               'policy' => \ezpI18n::tr( self::CONTEXT, 'You are not allowed to change templates.' ),
                               'token' => \ezpI18n::tr( self::CONTEXT, 'The form has expired. Please reload the page and try again.' ) );
            expModuleViewExplayoutsUiTemplateEditorJsonResponse( array( 'success' => false, 'error' => $messages[$refusal] ), $refusal === 'method' ? 405 : 403 );
        }

        $action = isset( $_POST['Action'] ) ? (string)$_POST['Action'] : ( isset( $_POST['SaveTemplate'] ) ? 'save' : '' );
        $path = isset( $_POST['SelectedPath'] ) && is_string( $_POST['SelectedPath'] ) ? $_POST['SelectedPath'] : '';
        $content = isset( $_POST['TemplateContent'] ) && is_string( $_POST['TemplateContent'] ) ? str_replace( "\r\n", "\n", $_POST['TemplateContent'] ) : '';
        $current = $path !== '' ? \expLayoutsUiTemplateEditor::readFor( $path, $this->siteAccess ) : false;

        if ( $action === 'check' )
        {
            $compare = isset( $_POST['Compare'] ) && $_POST['Compare'] === 'original' ? 'original' : 'saved';
            $base = $compare === 'original' ? \expLayoutsUiTemplateEditor::readOriginal( $path ) : $current;
            if ( $base === false )
                $base = $compare === 'original' && $current !== false ? $current : '';
            expModuleViewExplayoutsUiTemplateEditorJsonResponse( array( 'success' => true, 'compare' => $compare,
                'validation' => \expLayoutsUiTemplateEditor::validate( $content ),
                'diff' => \expLayoutsUiTemplateEditor::diff( $base, $content ) ) );
        }

        if ( $action === 'save' )
        {
            $validation = \expLayoutsUiTemplateEditor::validate( $content );
            if ( !$validation['ok'] )
                expModuleViewExplayoutsUiTemplateEditorJsonResponse( array( 'success' => false, 'validation' => $validation,
                    'error' => \ezpI18n::tr( self::CONTEXT, 'Not saved: the template has syntax errors.' ) ), 422 );
            $before = $current === false ? null : hash( 'sha256', $current );
            // saveKeepingOriginal() writes only inside AllowedTemplateRoots and backs the file up first
            if ( !\expLayoutsUiTemplateEditor::saveKeepingOriginal( $path, $content ) )
                expModuleViewExplayoutsUiTemplateEditorJsonResponse( array( 'success' => false, 'error' => \ezpI18n::tr( self::CONTEXT, 'Save failed' ) ), 422 );
            self::afterWrite( $path, $current === false ? 'create' : 'change', $before, hash( 'sha256', $content ) );
            expModuleViewExplayoutsUiTemplateEditorJsonResponse( array( 'success' => true, 'message' => \ezpI18n::tr( self::CONTEXT, 'Saved' ),
                'validation' => $validation, 'meta' => $this->meta( $path ) ) );
        }

        if ( $action === 'revert' )
        {
            if ( !\expLayoutsUiTemplateEditor::hasOriginal( $path ) )
                expModuleViewExplayoutsUiTemplateEditorJsonResponse( array( 'success' => false, 'error' => \ezpI18n::tr( self::CONTEXT, 'This template has no original kept by the editor.' ) ), 422 );
            $before = $current === false ? null : hash( 'sha256', $current );
            if ( !\expLayoutsUiTemplateEditor::revertToOriginal( $path ) )
                expModuleViewExplayoutsUiTemplateEditorJsonResponse( array( 'success' => false, 'error' => \ezpI18n::tr( self::CONTEXT, 'Revert failed' ) ), 422 );
            $now = \expLayoutsTemplateEditor::read( $path );
            self::afterWrite( $path, 'revert', $before, $now === false ? null : hash( 'sha256', $now ) );
            expModuleViewExplayoutsUiTemplateEditorJsonResponse( array( 'success' => true, 'message' => \ezpI18n::tr( self::CONTEXT, 'The original is back.' ),
                'content' => $now === false ? '' : $now, 'meta' => $this->meta( $path ) ) );
        }

        if ( $action === 'override' )
        {
            $target = isset( $_POST['Target'] ) && is_string( $_POST['Target'] ) ? $_POST['Target'] : '';
            $created = $current === false ? false : \expLayoutsUiTemplateEditor::createOverride( $path, $target, $this->siteAccess );
            if ( $created === false )
                expModuleViewExplayoutsUiTemplateEditorJsonResponse( array( 'success' => false, 'error' => \ezpI18n::tr( self::CONTEXT, 'Save failed' ) ), 422 );
            self::afterWrite( $created, 'create', null, hash( 'sha256', $current ), true );
            $url = self::viewUri( $created, $this->siteAccess, '' );
            \eZURI::transformURI( $url );
            expModuleViewExplayoutsUiTemplateEditorJsonResponse( array( 'success' => true, 'path' => $created, 'url' => $url,
                'message' => \ezpI18n::tr( self::CONTEXT, 'Saved' ) ) );
        }

        expModuleViewExplayoutsUiTemplateEditorJsonResponse( array( 'success' => false, 'error' => \ezpI18n::tr( self::CONTEXT, 'Unknown request' ) ), 422 );
    }

    /**
     * The audit event of a save, revert or new override (never the template's text, only its checksums) and the
     * caches that may hold pages drawn with the old template; a new file also changes which file a template name
     * finds, so the template override cache goes too.
     */
    protected static function afterWrite( $path, $verb, $before, $after, $newFile = false )
    {
        if ( class_exists( 'expAuditHook' ) )
            \expAuditHook::emit( 'system.template.change', array( 'object' => array( 'type' => 'template', 'id' => (string)$path ),
                'verb' => $verb, 'before' => array( 'sha256' => $before ), 'after' => array( 'sha256' => $after ),
                'x' => array( 'editor' => 'explayouts_ui/template_editor' ) ) );
        \eZCache::clearByID( $newFile ? array( 'template-block', 'template-override' ) : array( 'template-block' ) );
        if ( $newFile )
            \eZTemplateDesignResource::clearInMemoryCache();
        \eZContentCacheManager::clearAllContentCache();
    }
}

}
