<?php
require_once( 'extension/explayouts_core/classes/explayoutscoreruleservice.php' );
eZDebug::updateSettings( array( 'debug-enabled' => false ) );
$http = eZHTTPTool::instance();
$module = $Params['Module'];

if ( !eZUser::currentUser()->hasAccessTo( 'explayouts', 'edit' ) )
{
    return $module->handleError( eZError::KERNEL_ACCESS_DENIED, 'kernel' );
}

$ruleService = new expLayoutsCoreRuleService();

$ruleId = isset( $Params['RuleID'] ) ? (int)$Params['RuleID'] : 0;
if ( $ruleId > 0 )
    $rule = $ruleService->load( $ruleId );
else
    $rule = $ruleService->create( 0, 0, 0 );

if ( !$rule )
    return $module->handleError( eZError::KERNEL_NOT_FOUND, 'kernel' );

$message = '';
$error = '';
$prefillTargets = array();

if ( $ruleId === 0 && isset( $_GET['TargetType'] ) && isset( $_GET['TargetValue'] ) )
{
    $types = (array)$_GET['TargetType'];
    $values = (array)$_GET['TargetValue'];
    for ( $i = 0; $i < count( $types ); $i++ )
    {
        $type = trim( $types[$i] );
        $value = isset( $values[$i] ) ? trim( $values[$i] ) : '';
        if ( $type === '' ) continue;
        $prefillTargets[] = array( 'target_type' => $type, 'target_value' => $value );
    }
}

if ( $http->hasPostVariable( 'SaveRule' ) )
{
    $layoutId = (int)$http->postVariable( 'LayoutID' );
    $priority = (int)$http->postVariable( 'Priority' );
    $enabled = $http->hasPostVariable( 'Enabled' ) ? 1 : 0;

    $rule = $ruleService->update( (int)$rule->attribute( 'id' ), array(
        'layout_id' => $layoutId,
        'priority' => $priority,
        'enabled' => $enabled,
    ) );

    $targetTypes = $http->hasPostVariable( 'TargetType' ) ? $http->postVariable( 'TargetType' ) : array();
    $targetValues = $http->hasPostVariable( 'TargetValue' ) ? $http->postVariable( 'TargetValue' ) : array();
    $targets = array();
    for ( $i = 0; $i < count( $targetTypes ); $i++ )
    {
        $type = trim( $targetTypes[$i] );
        $value = trim( $targetValues[$i] );
        if ( $type === '' ) continue;
        $targets[] = array( 'type' => $type, 'value' => $value );
    }
    $ruleService->setTargets( (int)$rule->attribute( 'id' ), $targets );

    $conditionTypes = $http->hasPostVariable( 'ConditionType' ) ? $http->postVariable( 'ConditionType' ) : array();
    $conditionValues = $http->hasPostVariable( 'ConditionValue' ) ? $http->postVariable( 'ConditionValue' ) : array();
    $conditions = array();
    for ( $i = 0; $i < count( $conditionTypes ); $i++ )
    {
        $type = trim( $conditionTypes[$i] );
        $value = trim( $conditionValues[$i] );
        if ( $type === '' ) continue;
        $conditions[] = array( 'type' => $type, 'value' => $value );
    }
    $ruleService->setConditions( (int)$rule->attribute( 'id' ), $conditions );

    $message = 'Rule saved.';
}

$layouts = expLayoutsLayout::fetchList();
$targets = ( $ruleId === 0 && !empty( $prefillTargets ) ) ? $prefillTargets : $rule->targets();
$conditions = $rule->conditions();

$tpl = eZTemplate::factory();
$tpl->setVariable( 'rule', $rule );
$tpl->setVariable( 'layouts', $layouts );
$tpl->setVariable( 'targets', $targets );
$tpl->setVariable( 'conditions', $conditions );
$tpl->setVariable( 'message', $message );
$tpl->setVariable( 'error', $error );

$Result = array();
$Result['content'] = $tpl->fetch( 'design:explayouts_ui/rule_edit.tpl' );
$Result['left_menu'] = 'design:parts/explayouts_ui/menu.tpl';
$Result['path'] = array( array( 'url' => false,
                                'text' => ezpI18n::tr( 'explayouts_ui/rule', $ruleId > 0 ? 'Edit Rule' : 'New Rule' ) ) );
return $Result;
