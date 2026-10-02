<?php
/**
 * The code of extension/explayouts_ui/modules/explayouts_ui/rule_list.php, moved into a class (#207 stage 1). The file extension/explayouts_ui/modules/explayouts_ui/rule_list.php is one call to it.
 * Guide: doc/bc/6.0/cli_cronjob_view_abstractions.md
 */

namespace Exponential\View\Extension\ExplayoutsUi\ExplayoutsUi
{

class RuleList extends \Exponential\Runnable\ModuleView
{
    public function run( array $scope )
    {
        // the including function's variables ($Params, $Module, $cli, ...)
        foreach ( array_keys( $scope ) as $__name )
            if ( $__name !== 'this' && $__name !== 'scope' )
                ${$__name} = &$scope[$__name];
        unset( $__name );

        require_once( 'extension/explayouts_core/classes/explayoutscoreruleservice.php' );
        \eZDebug::updateSettings( array( 'debug-enabled' => false ) );
        $http = \eZHTTPTool::instance();
        $module = $Params['Module'];

        $readAccess = \eZUser::currentUser()->hasAccessTo( 'explayouts', 'read' );
        $editAccess = \eZUser::currentUser()->hasAccessTo( 'explayouts', 'edit' );
        $canEdit = is_array( $editAccess ) && isset( $editAccess['accessWord'] ) && $editAccess['accessWord'] === 'yes';
        $canRead = is_array( $readAccess ) && isset( $readAccess['accessWord'] ) && $readAccess['accessWord'] === 'yes';

        if ( !$canRead )
        {
            return $this->viewResult( isset( $Result ) ? $Result : null,  $module->handleError( \eZError::KERNEL_ACCESS_DENIED, 'kernel' ) );
        }

        $message = '';
        $error = '';

        $ruleService = new \expLayoutsCoreRuleService();

        // Handle new rule creation (edit permission required)
        if ( $canEdit && $http->hasPostVariable( 'AddRule' ) )
        {
            $layoutId = (int)$http->postVariable( 'LayoutID' );
            $priority = (int)$http->postVariable( 'Priority' );
            $enabled = $http->hasPostVariable( 'Enabled' ) ? 1 : 0;

            $rule = $ruleService->create( $layoutId, $priority, $enabled );

            if ( $rule )
            {
                $ruleId = (int)$rule->attribute( 'id' );

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

                $message = \ezpI18n::tr( 'design/admin/explayouts_ui/rule_list', 'Mapping added.' );
            }
            else
            {
                $error = \ezpI18n::tr( 'design/admin/explayouts_ui/rule_list', 'Mapping could not be created.' );
            }
        }

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

                $message = \ezpI18n::tr( 'design/admin/explayouts_ui/rule_list', 'Mapping saved.' );
            }
            else
            {
                $error = \ezpI18n::tr( 'design/admin/explayouts_ui/rule_list', 'Mapping not found.' );
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
                $message = \ezpI18n::tr( 'design/admin/explayouts_ui/rule_list', 'Mapping enabled.' );
            }
            else
            {
                $error = \ezpI18n::tr( 'design/admin/explayouts_ui/rule_list', 'Mapping not found.' );
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
                $message = \ezpI18n::tr( 'design/admin/explayouts_ui/rule_list', 'Mapping disabled.' );
            }
            else
            {
                $error = \ezpI18n::tr( 'design/admin/explayouts_ui/rule_list', 'Mapping not found.' );
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
                $message = \ezpI18n::tr( 'design/admin/explayouts_ui/rule_list', 'Layout unlinked.' );
            }
            else
            {
                $error = \ezpI18n::tr( 'design/admin/explayouts_ui/rule_list', 'Mapping not found.' );
            }
        }

        // Handle rule deletion (edit permission required)
        if ( $canEdit && $http->hasPostVariable( 'DeleteRule' ) )
        {
            $deleteId = (int)$http->postVariable( 'DeleteRuleID' );
            if ( $ruleService->delete( $deleteId ) )
                $message = \ezpI18n::tr( 'design/admin/explayouts_ui/rule_list', 'Mapping deleted.' );
            else
                $error = \ezpI18n::tr( 'design/admin/explayouts_ui/rule_list', 'Mapping not found.' );
        }

        // Handle rule copy (edit permission required)
        if ( $canEdit && $http->hasPostVariable( 'CopyRule' ) )
        {
            $copyId = (int)$http->postVariable( 'CopyRuleID' );
            if ( $ruleService->copy( $copyId ) )
                $message = \ezpI18n::tr( 'design/admin/explayouts_ui/rule_list', 'Mapping duplicated.' );
            else
                $error = \ezpI18n::tr( 'design/admin/explayouts_ui/rule_list', 'Mapping not found.' );
        }

        // Handle clear layout cache (edit permission required)
        if ( $canEdit && $http->hasPostVariable( 'ClearLayoutCache' ) )
        {
            $clearRuleId = (int)$http->postVariable( 'RuleID' );
            $rule = $ruleService->load( $clearRuleId );
            if ( $rule )
            {
                // Clear resolver caches for this mapping
                if ( method_exists( 'expLayoutsResolver', 'clearCache' ) )
                    \expLayoutsResolver::clearCache();
                $message = \ezpI18n::tr( 'design/admin/explayouts_ui/rule_list', 'Layout cache cleared.' );
            }
            else
            {
                $error = \ezpI18n::tr( 'design/admin/explayouts_ui/rule_list', 'Mapping not found.' );
            }
        }

        $rules = $ruleService->listAll( false );
        $layouts = \expLayoutsLayout::fetchList();

        $contentClasses = array();
        foreach ( \eZContentClass::fetchList( \eZContentClass::VERSION_STATUS_DEFINED, true, false, null, null, false, null ) as $class )
        {
            $contentClasses[(string)$class->attribute( 'identifier' )] = (string)$class->attribute( 'name' );
        }

        $siteIni = \eZINI::instance( 'site.ini' );
        $siteAccessList = $siteIni->hasVariable( 'SiteAccessSettings', 'AvailableSiteAccessList' )
            ? $siteIni->variable( 'SiteAccessSettings', 'AvailableSiteAccessList' )
            : array();

        $newRule = \expLayoutsRule::create( 0 );
        $newRule->setAttribute( 'enabled', 1 );

        // Pre-fill a new rule target when the rule list is opened from a "Map layout" link.
        $newRuleTargetType = 'null';
        $newRuleTargets = array();
        $autoOpenNewRule = false;
        if ( $http->hasGetVariable( 'TargetType' ) && $http->hasGetVariable( 'TargetValue' ) )
        {
            $newRuleTargetType = trim( (string)$http->getVariable( 'TargetType' ) );
            $newRuleTargets[] = array(
                'target_type' => $newRuleTargetType,
                'target_value' => trim( (string)$http->getVariable( 'TargetValue' ) ),
            );
            $autoOpenNewRule = true;
        }

        // Auto-open an existing rule detail when opened from an "Edit mapping" link.
        $autoOpenRuleId = '';
        if ( $http->hasGetVariable( 'RuleID' ) )
        {
            $autoOpenRuleId = (int)$http->getVariable( 'RuleID' );
        }

        $targetTypes = array( 'path', 'path_prefix', 'path_regex', 'node', 'subtree', 'route' );
        $conditionTypes = array(
            'siteaccess',
            'class',
            'query_parameter',
            'route_parameter',
            'time',
        );

        $ruleData = array();
        foreach ( $rules as $rule )
        {
            $ruleId = (int)$rule->attribute( 'id' );
            $layout = false;
            $layoutType = false;
            $layoutId = (int)$rule->attribute( 'layout_id' );
            if ( $layoutId > 0 )
            {
                $layout = \expLayoutsLayout::fetch( $layoutId );
                if ( $layout )
                    $layoutType = \expLayoutsLayoutType::getTypeInfo( $layout->attribute( 'layout_type' ) );
            }

            $ruleData[$ruleId] = array(
                'rule' => $rule,
                'layout' => $layout,
                'layout_type' => $layoutType,
                'targets' => $rule->targets(),
                'conditions' => $rule->conditions(),
            );
        }

        $tpl = \eZTemplate::factory();
        $tpl->setVariable( 'newRule', $newRule );

        // Paged. These lists have no ceiling: an installation with a layout per page,
        // or a rule per site per class, drew every one of them on one screen.
        // expAdminPagination is this fork's kernel helper; the guard keeps the
        // extension working on a kernel that has not got it.
        $pageLimit  = class_exists( 'expAdminPagination' )
                    ? \expAdminPagination::limit( 'explayouts_ui/rule_list' ) : 25;
        $pageOffset = class_exists( 'expAdminPagination' )
                    ? \expAdminPagination::offset( $Params ) : 0;
        $pageCount  = count( $ruleData );
        $ruleData = class_exists( 'expAdminPagination' )
                ? \expAdminPagination::page( $ruleData, $pageOffset, $pageLimit )
                : $ruleData;
        $tpl->setVariable( 'ruleData', $ruleData );
        $tpl->setVariable( 'page_count', $pageCount );
        $tpl->setVariable( 'limit', $pageLimit );
        $tpl->setVariable( 'view_parameters', array( 'offset' => $pageOffset ) );
        $tpl->setVariable( 'layouts', $layouts );
        $tpl->setVariable( 'targetTypes', $targetTypes );
        $tpl->setVariable( 'conditionTypes', $conditionTypes );
        $tpl->setVariable( 'contentClasses', $contentClasses );
        $tpl->setVariable( 'contentClassesJson', json_encode( $contentClasses, JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT ) );
        $tpl->setVariable( 'siteAccessList', $siteAccessList );
        $tpl->setVariable( 'siteAccessListJson', json_encode( $siteAccessList, JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT ) );
        $tpl->setVariable( 'newRuleTargetType', $newRuleTargetType );
        $tpl->setVariable( 'newRuleTargets', $newRuleTargets );
        $tpl->setVariable( 'autoOpenNewRule', $autoOpenNewRule );
        $tpl->setVariable( 'autoOpenRuleId', $autoOpenRuleId );
        $tpl->setVariable( 'canEdit', $canEdit );
        $tpl->setVariable( 'message', $message );
        $tpl->setVariable( 'error', $error );

        $Result = array();
        $Result['content'] = $tpl->fetch( 'design:explayouts_ui/rule_list.tpl' );
        $Result['left_menu'] = 'design:parts/explayouts_ui/menu.tpl';
        $Result['path'] = array( array( 'url' => false,
                                        'text' => \ezpI18n::tr( 'explayouts_ui/rule', 'Layout mappings' ) ) );
        return $this->viewResult( isset( $Result ) ? $Result : null,  $Result );

        return $this->viewResult( isset( $Result ) ? $Result : null, null );
    }
}

}
