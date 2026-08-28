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

// Handle rule save (edit permission required)
if ( eZUser::currentUser()->hasAccessTo( 'explayouts', 'edit' ) && $http->hasPostVariable( 'SaveRule' ) )
{
    $ruleId = (int)$http->postVariable( 'RuleID' );
    $rule = $ruleService->load( $ruleId );

    if ( $rule )
    {
        $layoutId = (int)$http->postVariable( 'LayoutID' );
        $priority = (int)$http->postVariable( 'Priority' );
        $enabled = $http->hasPostVariable( 'Enabled' ) ? 1 : 0;

        $rule = $ruleService->update( $ruleId, array(
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
            $value = isset( $targetValues[$i] ) ? trim( $targetValues[$i] ) : '';
            if ( $type === '' ) continue;
            $targets[] = array( 'type' => $type, 'value' => $value );
        }
        $ruleService->setTargets( $ruleId, $targets );

        $conditionTypes = $http->hasPostVariable( 'ConditionType' ) ? $http->postVariable( 'ConditionType' ) : array();
        $conditionValues = $http->hasPostVariable( 'ConditionValue' ) ? $http->postVariable( 'ConditionValue' ) : array();
        $conditions = array();
        for ( $i = 0; $i < count( $conditionTypes ); $i++ )
        {
            $type = trim( $conditionTypes[$i] );
            $value = isset( $conditionValues[$i] ) ? trim( $conditionValues[$i] ) : '';
            if ( $type === '' ) continue;
            $conditions[] = array( 'type' => $type, 'value' => $value );
        }
        $ruleService->setConditions( $ruleId, $conditions );

        $message = 'Rule saved.';
    }
    else
    {
        $error = 'Rule not found.';
    }
}

// Handle rule deletion (edit permission required)
if ( eZUser::currentUser()->hasAccessTo( 'explayouts', 'edit' ) && $http->hasPostVariable( 'DeleteRule' ) )
{
    $deleteId = (int)$http->postVariable( 'DeleteRuleID' );
    if ( $ruleService->delete( $deleteId ) )
        $message = 'Rule deleted.';
    else
        $error = 'Rule not found.';
}

// Handle rule copy (edit permission required)
if ( eZUser::currentUser()->hasAccessTo( 'explayouts', 'edit' ) && $http->hasPostVariable( 'CopyRule' ) )
{
    $copyId = (int)$http->postVariable( 'CopyRuleID' );
    if ( $ruleService->copy( $copyId ) )
        $message = 'Rule copied.';
    else
        $error = 'Rule not found.';
}

$rules = $ruleService->listAll( false );
$layouts = expLayoutsLayout::fetchList();

$ruleData = array();
foreach ( $rules as $rule )
{
    $ruleId = (int)$rule->attribute( 'id' );
    $layout = false;
    $layoutId = (int)$rule->attribute( 'layout_id' );
    if ( $layoutId > 0 )
        $layout = expLayoutsLayout::fetch( $layoutId );

    $ruleData[$ruleId] = array(
        'rule' => $rule,
        'layout' => $layout,
        'targets' => $rule->targets(),
        'conditions' => $rule->conditions(),
    );
}

$tpl = eZTemplate::factory();
$tpl->setVariable( 'ruleData', $ruleData );
$tpl->setVariable( 'layouts', $layouts );
$tpl->setVariable( 'message', $message );
$tpl->setVariable( 'error', $error );

$Result = array();
$Result['content'] = $tpl->fetch( 'design:explayouts_ui/rule_list.tpl' );
$Result['left_menu'] = 'design:parts/explayouts_ui/menu.tpl';
$Result['path'] = array( array( 'url' => false,
                                'text' => ezpI18n::tr( 'explayouts_ui/rule', 'Layout Rules' ) ) );
return $Result;
