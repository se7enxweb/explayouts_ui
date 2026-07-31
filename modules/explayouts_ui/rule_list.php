<?php
require_once( 'extension/explayouts_core/classes/explayoutscoreruleservice.php' );
eZDebug::updateSettings( array( 'debug-enabled' => false ) );
$http = eZHTTPTool::instance();
$module = $Params['Module'];

if ( !eZUser::currentUser()->hasAccessTo( 'explayouts', 'read' ) )
{
    return $module->handleError( eZError::KERNEL_ACCESS_DENIED, 'kernel' );
}

$message = '';
$error = '';

$ruleService = new expLayoutsCoreRuleService();

if ( eZUser::currentUser()->hasAccessTo( 'explayouts', 'edit' ) && $http->hasPostVariable( 'DeleteRule' ) )
{
    $deleteId = (int)$http->postVariable( 'DeleteRuleID' );
    if ( $ruleService->delete( $deleteId ) )
        $message = 'Rule deleted.';
    else
        $error = 'Rule not found.';
}

if ( eZUser::currentUser()->hasAccessTo( 'explayouts', 'edit' ) && $http->hasPostVariable( 'CopyRule' ) )
{
    $copyId = (int)$http->postVariable( 'CopyRuleID' );
    if ( $ruleService->copy( $copyId ) )
        $message = 'Rule copied.';
    else
        $error = 'Rule not found.';
}

$rules = $ruleService->listAll( true );

$tpl = eZTemplate::factory();
$tpl->setVariable( 'rules', $rules );
$tpl->setVariable( 'message', $message );
$tpl->setVariable( 'error', $error );

$Result = array();
$Result['content'] = $tpl->fetch( 'design:explayouts_ui/rule_list.tpl' );
$Result['left_menu'] = 'design:parts/explayouts_ui/menu.tpl';
$Result['path'] = array( array( 'url' => false,
                                'text' => ezpI18n::tr( 'explayouts_ui/rule', 'Layout Rules' ) ) );
return $Result;
