<div class="nl-rule-body-overlay">
    <div class="nl-rule-body">
        <form method="post" action={'explayouts_ui/rule_list'|ezurl}>
            {if ne($ruleId,'new')}<input type="hidden" name="RuleID" value="{$ruleId|wash}" />{/if}
            <div class="nl-grid">
                <div class="col-xs12 sidebar-title">
                    <h1>{if eq($ruleId,'new')}New rule{else}Rule details{/if}</h1>
                    {if $canEdit}
                        <div class="nl-rule-actions">
                            <a href="#" class="nl-btn js-rule-edit" data-action="discard">Cancel</a>
                            <button type="submit" name="{if eq($ruleId,'new')}AddRule{else}SaveRule{/if}" class="nl-btn nl-btn-primary js-rule-edit" data-action="publish">{if eq($ruleId,'new')}Add rule{else}Save changes{/if}</button>
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
                                    {if $layoutType}<img src={concat('/extension/explayouts/design/standard/images/explayouts_standard/layout_types/',$layoutType.icon,'.svg')|ezroot} alt="" class="layout-icon" style="width:100%;display:block;height:auto !important;padding-bottom:0 !important;" />{/if}
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
                    {else}
                        <div class="panel-name" title="No mapped layout"><p>No mapped layout</p></div>
                    {/if}

                    <div style="margin-top:18px;">
                        <label style="display:block;margin-bottom:6px;font-weight:500;">Link layout</label>
                        <select name="LayoutID" style="min-width:260px;padding:8px;">
                            <option value="0" {if eq($rule.layout_id,0)}selected="selected"{/if}>(none)</option>
                            {foreach $layouts as $lo}
                                <option value="{$lo.id|wash}" {if eq($rule.layout_id,$lo.id)}selected="selected"{/if}>{$lo.name|wash} ({$lo.identifier|wash})</option>
                            {/foreach}
                        </select>
                    </div>

                    <div style="margin-top:14px;display:flex;gap:24px;align-items:center;">
                        <label style="font-weight:500;">Priority <input type="text" name="Priority" value="{$rule.priority|wash}" size="6" style="padding:8px;" /></label>
                        <label class="nl-toggle-switch" style="display:inline-flex;align-items:center;gap:8px;cursor:pointer;">
                            <input type="checkbox" id="rule-enabled-{$ruleId|wash}" class="nl-toggle-input" name="Enabled" value="1" {if $rule.enabled}checked="checked"{/if} data-rule-id="{$ruleId|wash}" />
                            <span class="nl-toggle-slider"></span>
                            <span class="nl-toggle-label" data-on="Enabled" data-off="Disabled">{if $rule.enabled}Enabled{else}Disabled{/if}</span>
                        </label>
                    </div>
                </div>

                <div class="col-xs12 nl-rule-body-rules">
                    <div class="nl-grid">
                        <div class="col-xs12 nl-rule-setting">
                            {if count($targets)|gt(0)}
                                {if ne($targetType,'null')}
                                    <div class="sidemenu-subtitle">
                                        <h4>Target ({$targetType|wash}):</h4>
                                        <p class="note">First matching target wins.</p>
                                    </div>
                                {else}
                                    <div class="sidemenu-subtitle">
                                        <h4>Targets:</h4>
                                        <p class="note">First matching target wins.</p>
                                    </div>
                                {/if}
                            {else}
                                <div class="sidemenu-subtitle">
                                    <h4>No targets</h4>
                                    <p class="note">First matching target wins.</p>
                                </div>
                            {/if}

                            <table class="list target-list" id="targets-table-{$ruleId|wash}" cellspacing="0">
                                <tr><th>Type</th><th>Value</th><th></th></tr>
                                {foreach $targets as $t}
                                    <tr>
                                        <td>
                                            <select name="TargetType[]">
                                                {foreach $targetTypes as $tt}
                                                    <option value="{$tt|wash}" {if eq($t.target_type,$tt)}selected="selected"{/if}>{$tt|wash}</option>
                                                {/foreach}
                                            </select>
                                        </td>
                                        <td>
                                            <input type="text" name="TargetValue[]" value="{$t.target_value|wash}" size="40" />
                                            <button type="button" class="nl-btn js-browse-target">Browse</button>
                                            {if and(or(eq($t.target_type,'node'),eq($t.target_type,'subtree')),$t.target_value|is_numeric)}
                                                <a href="{concat('/content/edit/',$t.target_value)|ezurl}" target="_blank" class="nl-btn js-view-target">View in CMS</a>
                                            {else}
                                                <a href="#" target="_blank" class="nl-btn js-view-target" style="display:none;">View in CMS</a>
                                            {/if}
                                        </td>
                                        <td><button type="button" class="nl-btn js-remove-row">Remove</button></td>
                                    </tr>
                                {/foreach}
                            </table>

                            {if $canEdit}
                                <div class="settings-action">
                                    <div class="settings-action-add" style="margin-top:10px;">
                                        <select class="nl-select js-target-type" id="target-type-{$ruleId|wash}">
                                            {foreach $targetTypes as $tt}
                                                <option value="{$tt|wash}">{$tt|wash}</option>
                                            {/foreach}
                                        </select>
                                        <button type="button" class="nl-btn nl-btn-link js-add-target" data-rule-id="{$ruleId|wash}">
                                            <i class="material-icons">add</i> Add target
                                        </button>
                                    </div>
                                </div>
                            {/if}
                        </div>

                        <div class="col-xs12 nl-rule-setting">
                            {if count($conditions)|gt(0)}
                                <div class="sidemenu-subtitle">
                                    <h4>Conditions:</h4>
                                    <p class="note">All conditions must match.</p>
                                </div>
                            {else}
                                <h4>No conditions</h4>
                            {/if}

                            <table class="list condition-list" id="conditions-table-{$ruleId|wash}" cellspacing="0">
                                <tr><th>Type</th><th>Value</th><th></th></tr>
                                {foreach $conditions as $c}
                                    <tr>
                                        <td>
                                            {def $conditionDisplayType = cond(eq($c.condition_type,'ibexa_content_type'),'class',cond(eq($c.condition_type,'content_type'),'class',cond(eq($c.condition_type,'ibexa_site_access'),'siteaccess',$c.condition_type)))}
                                            <select name="ConditionType[]">
                                                {foreach $conditionTypes as $ct}
                                                    <option value="{$ct|wash}" {if eq($conditionDisplayType,$ct)}selected="selected"{/if}>{$ct|wash}</option>
                                                {/foreach}
                                            </select>
                                        </td>
                                        <td><input type="text" name="ConditionValue[]" value="{$c.condition_value|wash}" size="50" /></td>
                                        <td><button type="button" class="nl-btn js-remove-row">Remove</button></td>
                                    </tr>
                                {/foreach}
                            </table>

                            {if $canEdit}
                                <div class="settings-action">
                                    <div class="settings-action-add" style="margin-top:10px;">
                                        <select class="nl-select js-condition-type" id="condition-type-{$ruleId|wash}">
                                            {foreach $conditionTypes as $ct}
                                                <option value="{$ct|wash}">{$ct|wash}</option>
                                            {/foreach}
                                        </select>
                                        <button type="button" class="nl-btn nl-btn-link js-add-condition" data-rule-id="{$ruleId|wash}">
                                            <i class="material-icons">add</i> Add condition
                                        </button>
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
