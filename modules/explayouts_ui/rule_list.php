<?php
require_once( 'extension/explayouts_core/classes/explayoutscoreruleservice.php' );
eZDebug::updateSettings( array( 'debug-enabled' => false ) );
$http = eZHTTPTool::instance();
$module = $Params['Module'];

$readAccess = eZUser::currentUser()->hasAccessTo( 'explayouts', 'read' );
$editAccess = eZUser::currentUser()->hasAccessTo( 'explayouts', 'edit' );
$canEdit = is_array( $editAccess ) && isset( $editAccess['accessWord'] ) && $editAccess['accessWord'] === 'yes';
$canRead = is_array( $readAccess ) && isset( $readAccess['accessWord'] ) && $readAccess['accessWord'] === 'yes';

if ( !$canRead )
{
    return $module->handleError( eZError::KERNEL_ACCESS_DENIED, 'kernel' );
}

$message = '';
$error = '';

$ruleService = new expLayoutsCoreRuleService();

// Handle rule save (edit permission required)
if ( $canEdit && $http->hasPostVariable( 'SaveRule' ) )
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

// Handle quick enable (edit permission required)
if ( $canEdit && $http->hasPostVariable( 'EnableRule' ) )
{
    $ruleId = (int)$http->postVariable( 'RuleID' );
    $rule = $ruleService->load( $ruleId );
    if ( $rule )
    {
        $ruleService->update( $ruleId, array( 'enabled' => 1 ) );
        $message = 'Rule enabled.';
    }
    else
    {
        $error = 'Rule not found.';
    }
}

// Handle quick disable (edit permission required)
if ( $canEdit && $http->hasPostVariable( 'DisableRule' ) )
{
    $ruleId = (int)$http->postVariable( 'RuleID' );
    $rule = $ruleService->load( $ruleId );
    if ( $rule )
    {
        $ruleService->update( $ruleId, array( 'enabled' => 0 ) );
        $message = 'Rule disabled.';
    }
    else
    {
        $error = 'Rule not found.';
    }
}

// Handle quick unlink layout (edit permission required)
if ( $canEdit && $http->hasPostVariable( 'UnlinkRule' ) )
{
    $ruleId = (int)$http->postVariable( 'RuleID' );
    $rule = $ruleService->load( $ruleId );
    if ( $rule )
    {
        $ruleService->update( $ruleId, array( 'layout_id' => 0 ) );
        $message = 'Layout unlinked.';
    }
    else
    {
        $error = 'Rule not found.';
    }
}

// Handle rule deletion (edit permission required)
if ( $canEdit && $http->hasPostVariable( 'DeleteRule' ) )
{
    $deleteId = (int)$http->postVariable( 'DeleteRuleID' );
    if ( $ruleService->delete( $deleteId ) )
        $message = 'Rule deleted.';
    else
        $error = 'Rule not found.';
}

// Handle rule copy (edit permission required)
if ( $canEdit && $http->hasPostVariable( 'CopyRule' ) )
{
    $copyId = (int)$http->postVariable( 'CopyRuleID' );
    if ( $ruleService->copy( $copyId ) )
        $message = 'Rule copied.';
    else
        $error = 'Rule not found.';
}

$rules = $ruleService->listAll( false );
$layouts = expLayoutsLayout::fetchList();

$targetTypes = array( 'path', 'path_prefix', 'path_regex', 'content_node', 'subtree', 'route' );
$conditionTypes = array( 'siteaccess', 'content_type' );

$ruleData = array();
foreach ( $rules as $rule )
{
    $ruleId = (int)$rule->attribute( 'id' );
    $layout = false;
    $layoutType = false;
    $layoutId = (int)$rule->attribute( 'layout_id' );
    if ( $layoutId > 0 )
    {
        $layout = expLayoutsLayout::fetch( $layoutId );
        if ( $layout )
            $layoutType = expLayoutsLayoutType::getTypeInfo( $layout->attribute( 'layout_type' ) );
    }

    $ruleData[$ruleId] = array(
        'rule' => $rule,
        'layout' => $layout,
        'layout_type' => $layoutType,
        'targets' => $rule->targets(),
        'conditions' => $rule->conditions(),
    );
}

$tpl = eZTemplate::factory();
$tpl->setVariable( 'ruleData', $ruleData );
$tpl->setVariable( 'layouts', $layouts );
$tpl->setVariable( 'targetTypes', $targetTypes );
$tpl->setVariable( 'conditionTypes', $conditionTypes );
$tpl->setVariable( 'canEdit', $canEdit );
$tpl->setVariable( 'message', $message );
$tpl->setVariable( 'error', $error );

$Result = array();
$Result['content'] = $tpl->fetch( 'design:explayouts_ui/rule_list.tpl' );
$Result['left_menu'] = 'design:parts/explayouts_ui/menu.tpl';
$Result['path'] = array( array( 'url' => false,
                                'text' => ezpI18n::tr( 'explayouts_ui/rule', 'Layout Rules' ) ) );
return $Result;
