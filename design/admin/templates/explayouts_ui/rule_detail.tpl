<div class="nl-rule-body-overlay">
    <div class="nl-rule-body">
        <form method="post" action={'explayouts_ui/rule_list'|ezurl}>
            {if ne($ruleId,'new')}<input type="hidden" name="RuleID" value="{$ruleId|wash}" />{/if}
            <div class="nl-grid">
                <div class="col-xs12 sidebar-title">
                    <h1>{if eq($ruleId,'new')}New mapping{else}Mapping details{/if}</h1>
                    {if $canEdit}
                        <div class="nl-rule-actions">
                            <a href="#" class="nl-btn js-rule-edit" data-action="discard">Cancel</a>
                            <button type="submit" name="{if eq($ruleId,'new')}AddRule{else}SaveRule{/if}" class="nl-btn nl-btn-primary js-rule-edit" data-action="publish">{if eq($ruleId,'new')}Add mapping{else}Save changes{/if}</button>
                        </div>
                    {/if}
                    <a href="#" class="js-toggle-body"><i class="material-icons">clear</i></a>
                </div>

                <div class="col-xs12 layout-body">
                    <h4>Mapped layout:</h4>

                    {if is_set($layout)}
                        <div class="rule-layout-info">
                            {if and(is_set($layoutType),is_set($layoutType.zones),count($layoutType.zones)|gt(0))}
                                <div class="rule-layout-info-icon">
                                    {if $layoutType}<i class="layout-icon {if $layoutType.identifier}{$layoutType.identifier|wash}{/if}" {if and($layoutType.icon,ne($layoutType.icon,''))}style="background-image:url('{concat('/extension/explayouts/design/standard/images/explayouts_standard/layout_types/',$layoutType.icon,'.svg')|wash}')"{/if}></i>{/if}
                                </div>
                                <div class="rule-layout-info-text">
                                    <p><strong>{$layout.name|wash}</strong></p>
                                    <p>{if $layoutType}{$layoutType.name|wash}{else}Invalid layout{/if}</p>
                                </div>
                            {else}
                                <div class="rule-layout-info-text">
                                    <p><strong>{$layout.name|wash}</strong></p>
                                    <p>Invalid layout</p>
                                </div>
                            {/if}
                        </div>

                        <div class="nl-layout-options">
                            <a href={concat('explayouts_ui_api/app#layout/',$rule.layout_id)|ezurl} class="js-open-ngl">Edit layout</a>
                        </div>

                        {if and(is_set($rule),$rule.description|ne(''))}
                            <div class="nl-rule-description">
                                <p>{$rule.description|wash}</p>
                            </div>
                        {/if}

                        {if ne($ruleId,'new')}
                            <input type="hidden" name="LayoutID" value="{$rule.layout_id|wash}" />
                            <input type="hidden" name="Priority" value="{$rule.priority|wash}" />
                            <input type="hidden" name="Enabled" value="{if $rule.enabled}1{else}0{/if}" />
                        {/if}
                    {else}
                        <div class="panel-name" title="No mapped layout"><p>No mapped layout</p></div>
                    {/if}

                    {if eq($ruleId,'new')}
                    <div class="nl-rule-new-meta" style="margin-top:18px;">
                        <div style="margin-bottom:14px;">
                            <label style="display:block;margin-bottom:6px;font-weight:500;">Link layout</label>
                            <select name="LayoutID" style="min-width:260px;padding:8px;">
                                <option value="0" {if eq($rule.layout_id,0)}selected="selected"{/if}>(none)</option>
                                {foreach $layouts as $lo}
                                    <option value="{$lo.id|wash}" {if eq($rule.layout_id,$lo.id)}selected="selected"{/if}>{$lo.name|wash} ({$lo.identifier|wash})</option>
                                {/foreach}
                            </select>
                        </div>

                        <div style="display:flex;gap:24px;align-items:center;">
                            <label style="font-weight:500;">Priority <input type="text" name="Priority" value="{$rule.priority|wash}" size="6" style="padding:8px;" /></label>
                            <label class="nl-toggle-switch" style="display:inline-flex;align-items:center;gap:8px;cursor:pointer;">
                                <input type="checkbox" id="rule-enabled-{$ruleId|wash}" class="nl-toggle-input" name="Enabled" value="1" {if $rule.enabled}checked="checked"{/if} data-rule-id="{$ruleId|wash}" />
                                <span class="nl-toggle-slider"></span>
                                <span class="nl-toggle-label" data-on="Enabled" data-off="Disabled">{if $rule.enabled}Enabled{else}Disabled{/if}</span>
                            </label>
                        </div>
                    </div>
                    {/if}
                </div>

                <div class="col-xs12 nl-rule-body-rules">
                    <div class="nl-grid">
                        <div class="col-xs12 nl-rule-setting">
                            {def $targetTypeLabel = cond(eq($targetType,'node'),'Location',cond(eq($targetType,'subtree'),'Subtree',cond(eq($targetType,'path'),'Path',cond(eq($targetType,'path_prefix'),'Path prefix',cond(eq($targetType,'path_regex'),'Path regex',cond(eq($targetType,'route'),'Route',cond(eq($targetType,'null'),'All',$targetType)))))))}

                            {if count($targets)|gt(0)}
                                {if ne($targetType,'null')}
                                    <div class="sidemenu-subtitle">
                                        <h4>Applied to {$targetTypeLabel}:</h4>
                                        <p class="note">NOTE: <strong>Any</strong> target can be met.</p>
                                    </div>
                                {else}
                                    <div class="sidemenu-subtitle">
                                        <h4>Targets:</h4>
                                        <p class="note">NOTE: <strong>Any</strong> target can be met.</p>
                                    </div>
                                {/if}
                            {else}
                                <div class="sidemenu-subtitle">
                                    <h4>No targets</h4>
                                    <p class="note">NOTE: <strong>Any</strong> target can be met.</p>
                                </div>
                            {/if}

                            <ul class="settings-list target-list" id="targets-table-{$ruleId|wash}">
                                {foreach $targets as $t}
                                    {def $targetItemLabel = cond(eq($t.target_type,'node'),'Location',cond(eq($t.target_type,'subtree'),'Subtree',cond(eq($t.target_type,'path'),'Path',cond(eq($t.target_type,'path_prefix'),'Path prefix',cond(eq($t.target_type,'path_regex'),'Path regex',cond(eq($t.target_type,'route'),'Route',$t.target_type))))))}
                                    {def $targetDisplayValue = $t.displayValue}
                                    <li class="nl-rule-setting-item">
                                        <input type="hidden" name="TargetType[]" value="{$t.target_type|wash}" />
                                        {if or(eq($t.target_type,'node'),eq($t.target_type,'subtree'))}
                                            <span class="settings-value editable-value js-setting-edit" data-setting-type="target" data-setting-id=""><strong>{$targetItemLabel}:</strong>
                                                <input type="hidden" name="TargetValue[]" value="{$t.target_value|wash}" />
                                                <span class="target-value-display">{$targetDisplayValue|wash}</span>
                                            </span>
                                            {if $t.target_value|is_numeric}
                                                <a href={concat('/content/view/full/',$t.target_value)|ezurl} target="_blank" class="nl-btn js-view-target">View in CMS</a>
                                            {/if}
                                        {else}
                                            <span class="settings-value editable-value js-setting-edit" data-setting-type="target" data-setting-id=""><strong>{$targetItemLabel}:</strong> <input type="text" name="TargetValue[]" value="{$t.target_value|wash}" size="40" title="{$targetDisplayValue|wash}" /></span>
                                        {/if}
                                        <a href="#" class="remove-setting js-remove-row">Delete</a>
                                    </li>
                                    {undef $targetItemLabel}
                                    {undef $targetDisplayValue}
                                {/foreach}
                            </ul>

                            {if $canEdit}
                                <div class="settings-action">
                                    <div class="settings-action-add" style="margin-top:10px;">
                                        {if or(eq($targetType,'null'),count($targets)|eq(0))}
                                            <select class="nl-select js-target-type" id="target-type-{$ruleId|wash}">
                                                {foreach $targetTypes as $tt}
                                                    {def $targetOptionLabel = cond(eq($tt,'node'),'Location',cond(eq($tt,'subtree'),'Subtree',cond(eq($tt,'path'),'Path',cond(eq($tt,'path_prefix'),'Path prefix',cond(eq($tt,'path_regex'),'Path regex',cond(eq($tt,'route'),'Route',$tt))))))}
                                                    <option value="{$tt|wash}">{$targetOptionLabel|wash}</option>
                                                    {undef $targetOptionLabel}
                                                {/foreach}
                                            </select>
                                        {/if}
                                        <a href="#" class="nl-btn nl-btn-link js-add-target" data-rule-id="{$ruleId|wash}" {if and(ne($targetType,'null'),count($targets)|gt(0))}data-target-type="{$targetType|wash}"{/if}>
                                            <i class="material-icons">add</i> Add target
                                        </a>
                                    </div>
                                </div>
                            {/if}
                        </div>

                        <div class="col-xs12 nl-rule-setting">
                            {if count($conditions)|gt(0)}
                                <div class="sidemenu-subtitle">
                                    <h4>Conditions:</h4>
                                    <p class="note">NOTE: <strong>All</strong> conditions must be met.</p>
                                </div>
                            {else}
                                <h4>No conditions</h4>
                            {/if}

                            <ul class="settings-list condition-list" id="conditions-table-{$ruleId|wash}">
                                {foreach $conditions as $c}
                                    {def $conditionDisplayType = cond(eq($c.condition_type,'content_type'),'class',cond(eq($c.condition_type,'siteaccess'),'siteaccess',$c.condition_type))}
                                    {def $conditionItemLabel = cond(eq($conditionDisplayType,'class'),'Class',cond(eq($conditionDisplayType,'siteaccess'),'Siteaccess',cond(eq($conditionDisplayType,'query_parameter'),'Query parameter',cond(eq($conditionDisplayType,'route_parameter'),'Route parameter',cond(eq($conditionDisplayType,'time'),'Time',$conditionDisplayType)))))}
                                    {def $conditionDisplayValue = $c.displayValue}
                                    <li class="nl-rule-setting-item">
                                        <input type="hidden" name="ConditionType[]" value="{$conditionDisplayType|wash}" />
                                        <span class="settings-value editable-value js-setting-edit" data-setting-type="condition" data-setting-id=""><strong>{$conditionItemLabel}:</strong>
                                            {if or(eq($conditionDisplayType,'class'),eq($conditionDisplayType,'siteaccess'))}
                                                {def $conditionItems = $c.displayItems}
                                                <input type="hidden" name="ConditionValue[]" value="{$c.condition_value|wash}" />
                                                <ul class="condition-items">
                                                    {foreach $conditionItems as $ci}
                                                        <li>{$ci|wash}</li>
                                                    {/foreach}
                                                </ul>
                                                {undef $conditionItems}
                                            {else}
                                                <input type="text" name="ConditionValue[]" value="{$c.condition_value|wash}" size="50" title="{$conditionDisplayValue|wash}" />
                                            {/if}
                                        </span>
                                        <a href="#" class="remove-setting js-remove-row">Delete</a>
                                    </li>
                                    {undef $conditionDisplayType}
                                    {undef $conditionItemLabel}
                                    {undef $conditionDisplayValue}
                                {/foreach}
                            </ul>

                            {if $canEdit}
                                <div class="settings-action">
                                    <div class="settings-action-add" style="margin-top:10px;">
                                        <select class="nl-select js-condition-type" id="condition-type-{$ruleId|wash}">
                                            {foreach $conditionTypes as $ct}
                                                {def $conditionOptionType = cond(eq($ct,'content_type'),'class',cond(eq($ct,'siteaccess'),'siteaccess',$ct))}
                                                {def $conditionOptionLabel = cond(eq($conditionOptionType,'class'),'Class',cond(eq($conditionOptionType,'siteaccess'),'Siteaccess',cond(eq($conditionOptionType,'query_parameter'),'Query parameter',cond(eq($conditionOptionType,'route_parameter'),'Route parameter',cond(eq($conditionOptionType,'time'),'Time',$ct)))))}
                                                <option value="{$ct|wash}">{$conditionOptionLabel|wash}</option>
                                                {undef $conditionOptionType}
                                                {undef $conditionOptionLabel}
                                            {/foreach}
                                        </select>
                                        <a href="#" class="nl-btn nl-btn-link js-add-condition" data-rule-id="{$ruleId|wash}">
                                            <i class="material-icons">add</i> Add condition
                                        </a>
                                    </div>
                                </div>
                            {/if}
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>
