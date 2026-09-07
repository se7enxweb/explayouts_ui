{ezcss_load(array('netgen/layouts-admin.css','netgen/layouts-ibexa.css','nglayouts-ui.css'))}
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
{literal}<style>
#rules { visibility: visible !important; }
#rules .message-feedback,
#rules .message-error { margin: 14px 18px; }
#rules .rule-layout .icon-rule,
#rules .rule-layout .icon-rule-disabled { font-family: 'Material Icons' !important; }
#rules .nl-rule-body .nl-rule-setting h4 { margin: 0 0 6px; font-size: 15px; }
#rules .nl-rule-body .nl-rule-setting .note { font-size: 12px; color: #777; margin: 0 0 10px; }

#rules .nl-rule-body-overlay { position: fixed; top: 0; right: 0; bottom: 0; left: 0; width: 100%; background: rgba(0,0,0,.5); z-index: 100000; }
#rules .nl-rule-body { position: absolute; top: 0; right: 0; left: auto; width: 100%; max-width: 560px; height: 100%; background: #fff; box-shadow: -2px 0 8px rgba(0,0,0,.2); display: flex; flex-direction: column; overflow: hidden; padding: 0 18px; box-sizing: border-box; }
#rules .nl-rule-body form { display: flex; flex-direction: column; flex: 1 1 auto; min-height: 0; width: 100%; background: #fff; margin: 0; padding: 0; }
#rules .nl-rule-body form > .nl-grid { display: flex; flex-direction: column; flex-wrap: nowrap; flex: 1 1 auto; min-height: 0; }
#rules .nl-rule-body form > .nl-grid > .col-xs12 { flex: 0 0 auto; min-height: 0; }
#rules .nl-rule-body form > .nl-grid > .nl-rule-body-rules { flex: 1 1 auto; overflow-y: auto; min-height: 0; }
#rules .nl-rule-body .sidebar-title { flex: 0 0 auto; background: #fff; z-index: 10; padding: 16px 0; margin: 0; border-bottom: 1px solid #e8e8e8; }
#rules .nl-rule-body .sidebar-title h1 { margin: 0; font-size: 24px; }
#rules .nl-rule-body .sidebar-title .nl-rule-actions { display: flex; align-items: center; gap: 8px; }
#rules .nl-rule-body .sidebar-title .js-toggle-body { margin-left: auto; }

#rules .rule-layout-info { display: flex; align-items: center; gap: 12px; margin: 8px 0 12px; }
#rules .rule-layout-info-icon { flex: 0 0 48px; width: 48px; height: 48px; background: #f5f5f5; border-radius: 4px; display: flex; align-items: center; justify-content: center; overflow: hidden; }
#rules .rule-layout-info-icon .layout-icon { display: inline-block; width: 40px; height: 40px; background-size: contain; background-repeat: no-repeat; background-position: center; }
#rules .rule-layout-info-text p { margin: 0; font-size: 14px; }
#rules .rule-layout-info-text p strong { font-weight: 500; }
#rules .nl-layout-options a { font-size: 14px; color: #2196F3; text-decoration: none; }
#rules .nl-layout-options a:hover { text-decoration: underline; }

#rules .nl-rule-body .settings-list { list-style: none; margin: 0; padding: 0; }
#rules .nl-rule-body .settings-list li { display: flex; align-items: center; gap: 12px; padding: 8px 0; border-bottom: 1px solid #e8e8e8; }
#rules .nl-rule-body .settings-list li:last-child { border-bottom: none; }
#rules .nl-rule-body .settings-list .settings-value { flex: 1 1 auto; font-size: 14px; color: #333; position: relative; padding-right: 24px; }
#rules .nl-rule-body .settings-list .settings-value strong { font-weight: 500; }
#rules .nl-rule-body .settings-list .settings-value.editable-value:after { content: 'edit'; font-family: 'Material Icons'; font-size: 18px; color: #999; position: absolute; right: 0; top: 50%; transform: translateY(-50%); }
#rules .nl-rule-body .settings-list .settings-value input[type="text"] { width: auto; min-width: 160px; padding: 4px 6px; border: none; border-bottom: 1px solid transparent; background: transparent; font-size: 14px; margin-left: 4px; }
#rules .nl-rule-body .settings-list .settings-value input[type="text"]:hover { border-bottom-color: #ddd; }
#rules .nl-rule-body .settings-list .settings-value input[type="text"]:focus { border-bottom-color: #2196F3; background: #fff; outline: none; }
#rules .nl-rule-body .settings-list select { min-width: 140px; padding: 6px; border: 1px solid #ddd; border-radius: 2px; font-size: 14px; }
#rules .nl-rule-body .settings-list .remove-setting { flex: 0 0 auto; color: #d32f2f; font-size: 13px; text-decoration: none; }
#rules .nl-rule-body .settings-list .remove-setting:hover { text-decoration: underline; }
#rules .nl-rule-body .settings-list .js-view-target { font-size: 13px; color: #2196F3; text-decoration: none; }
#rules .nl-rule-body .settings-list .js-view-target:hover { text-decoration: underline; }

#rules .nl-rule-body .condition-items { list-style: none; margin: 0; padding: 0; display: flex; flex-wrap: wrap; gap: 6px; }
#rules .nl-rule-body .condition-items li { display: inline-flex; align-items: center; padding: 4px 10px; background: #f0f0f0; border-radius: 12px; font-size: 13px; color: #333; border: 1px solid #e0e0e0; }

#rules .nl-rule-body .settings-list .settings-value.editable-value { cursor: pointer; }
#rules .nl-rule-body .settings-list li.editing .condition-items { display: none; }
#rules .nl-rule-body .settings-list .condition-edit-controls { display: none; }
#rules .nl-rule-body .settings-list li.editing .condition-edit-controls { display: inline; }
#rules .nl-rule-body .settings-list .condition-edit-select { min-width: 240px; padding: 4px; border: 1px solid #ddd; border-radius: 2px; min-height: 80px; }

#rules .nl-rule-body .settings-action { margin-top: 8px; }
#rules .nl-rule-body .settings-action-add { display: flex; align-items: center; gap: 8px; }
#rules .nl-rule-body .settings-action-add .nl-select { min-width: 160px; padding: 6px; border: 1px solid #ddd; border-radius: 2px; }
#rules .nl-rule-body .settings-action-add .nl-btn-link { display: inline-flex; align-items: center; gap: 4px; color: #2196F3; text-decoration: none; font-size: 14px; }
#rules .nl-rule-body .settings-action-add .nl-btn-link:hover { text-decoration: underline; }

#rules .nl-dropdown-menu form { margin: 0; }
#rules .nl-dropdown-menu button { background: none; border: none; width: 100%; text-align: left; padding: 8px 16px; cursor: pointer; font: inherit; color: inherit; }
#rules .nl-dropdown-menu button:disabled { opacity: .5; cursor: not-allowed; }
#rules .nl-dropdown-menu a, #rules .nl-dropdown-menu button { display: block; width: 100%; box-sizing: border-box; }
</style>{/literal}

<div class="ng-layouts-app">
    <div class="layouts-content">
        <div id="rules" class="nl-element">
        <div class="layouts-header">
            <h2 class="layouts-title">Layout mappings</h2>
            <div class="layouts-controls">
                {if $canEdit}
                    <button type="button" class="nl-btn nl-btn-primary js-add-rule">
                        <i class="material-icons">add</i> New mapping
                    </button>
                {/if}
            </div>
        </div>

        {if $message}<div class="message-feedback">{$message|wash}</div>{/if}
        {if $error}<div class="message-error">{$error|wash}</div>{/if}

        <div class="nl-rules-head">
            <div class="nl-rules-head-wrapper">
                <div class="nl-rule-cell"><div class="nl-export-checkbox"><input type="checkbox" id="toggleSelectAll"><label for="toggleSelectAll"></label></div></div>
                <div class="nl-rule-cell rule-priority"></div>
                <div class="nl-rule-cell rule-layout">Mapped layout</div>
                <div class="nl-rule-cell rule-targets">Targets</div>
                <div class="nl-rule-cell rule-conditions">Conditions</div>
            </div>
        </div>

        <div class="nl-rules">
            {if count($ruleData)|eq(0)}
                <p class="nl-no-items">There are no rules defined</p>
            {else}
                {foreach $ruleData as $item}
                    {def $rule = $item.rule}
                    {def $layout = $item.layout}
                    {def $layoutType = $item.layout_type}
                    {def $targets = $item.targets}
                    {def $conditions = $item.conditions}

                    {def $targetType = ''}
                    {if count($targets)|gt(0)}
                        {set $targetType = $targets[0].target_type}
                    {/if}
                    {if eq($targetType,'')}{set $targetType = 'null'}{/if}

                    {def $conditionType = ''}
                    {if count($conditions)|gt(0)}
                        {set $conditionType = $conditions[0].condition_type}
                    {/if}

                    <div class="nl-rule nl-element" id="rule-{$rule.id|wash}" tabindex="0" data-rule-id="{$rule.id|wash}">
                        <div class="nl-rule-content {if not($rule.enabled)}disabled{/if}"
                             data-id="{$rule.id|wash}"
                             data-target-type="{$targetType|wash}"
                             data-layout-id="{$rule.layout_id|wash}"
                             data-enabled="{$rule.enabled|wash}">

                            <div class="nl-rule-head">
                                <div class="nl-rule-cell">
                                    <div class="nl-export-checkbox">
                                        <input type="checkbox" id="export{$rule.id|wash}" {if not($rule.enabled)}disabled="disabled"{/if}>
                                        <label for="export{$rule.id|wash}"></label>
                                    </div>
                                </div>

                                <div class="nl-rule-cell rule-layout">
                                    <div class="rule-priority"><span class="rule-priority-nr">{$rule.priority|sum(1)}</span></div>
                                    <i class="material-icons icon-rule">widgets</i>
                                    <i class="material-icons icon-rule-disabled">error</i>

                                    {if $layout}
                                        <p>{$layout.name|wash}</p>
                                    {else}
                                        <div class="no-layout" title="No mapped layout"><span>No mapped layout</span></div>
                                    {/if}
                                </div>

                                {def $ruleTargetTypeLabel = cond(eq($targetType,'node'),'Location',cond(eq($targetType,'subtree'),'Subtree',cond(eq($targetType,'path'),'Path',cond(eq($targetType,'path_prefix'),'Path prefix',cond(eq($targetType,'path_regex'),'Path regex',cond(eq($targetType,'route'),'Route',cond(eq($targetType,'null'),'All',$targetType)))))))}
                                <div class="nl-rule-cell rule-targets">
                                    {if count($targets)|gt(0)}
                                        {if eq($targetType,'null')}
                                            <p>All</p>
                                        {elseif count($targets)|eq(1)}
                                            {def $ruleTargetValue = $targets[0].displayValue}
                                            <p>{$ruleTargetTypeLabel}:</p>
                                            <ul><li>{$ruleTargetValue|wash}</li></ul>
                                            {undef $ruleTargetValue}
                                        {else}
                                            <p>{$ruleTargetTypeLabel} ({count($targets)|wash})</p>
                                        {/if}
                                    {/if}
                                </div>

                                <div class="nl-rule-cell rule-conditions">
                                    {if count($conditions)|gt(0)}
                                        <ul class="{if count($conditions)|eq(2)}nl-ellipsis{elseif count($conditions)|gt(2)}nl-inline{/if}">
                                            {foreach $conditions as $c}
                                                {def $rowConditionDisplayType = cond(eq($c.condition_type,'content_type'),'class',cond(eq($c.condition_type,'siteaccess'),'siteaccess',$c.condition_type))}
                                                {def $rowConditionLabel = cond(eq($rowConditionDisplayType,'class'),'Class',cond(eq($rowConditionDisplayType,'siteaccess'),'Siteaccess',cond(eq($rowConditionDisplayType,'query_parameter'),'Query parameter',cond(eq($rowConditionDisplayType,'route_parameter'),'Route parameter',cond(eq($rowConditionDisplayType,'time'),'Time',$rowConditionDisplayType)))))}
                                                {def $rowConditionValue = $c.displayValue}
                                                <li>{if count($conditions)|lt(3)}{$rowConditionLabel}: {/if}{$rowConditionValue|wash}</li>
                                                {undef $rowConditionDisplayType}
                                                {undef $rowConditionLabel}
                                                {undef $rowConditionValue}
                                            {/foreach}
                                        </ul>
                                    {/if}
                                </div>

                                <div class="hover-actions">
                                    {if $layout}
                                        <div class="nl-rule-cell rule-edit-layout rule-padded-left">
                                            <a href={concat('explayouts_ui_api/app#layout/',$rule.layout_id)|ezurl} class="js-open-ngl">Edit layout</a>
                                        </div>
                                    {/if}

                                    {if $canEdit}
                                        <div class="nl-rule-cell rule-link-layout {if not($layout)}rule-padded-left{/if}">
                                            <a class="js-link-layout" href="#">{if $layout}Link other layout{else}Link layout{/if}</a>
                                        </div>
                                    {/if}

                                    <div class="nl-rule-cell rule-details">
                                        <a href="#" class="js-toggle-body">Details</a>
                                    </div>

                                    <div class="nl-dropdown" data-position="right">
                                        <button class="nl-btn nl-dropdown-toggle"><i class="material-icons">more_horiz</i></button>
                                        <ul class="nl-dropdown-menu">
                                                    {if $canEdit}
                                                <li><a href="#" class="js-toggle-body">Edit description</a></li>
                                                <li>
                                                    <form method="post" action={'explayouts_ui/rule_list'|ezurl}>
                                                        <input type="hidden" name="CopyRuleID" value="{$rule.id|wash}" />
                                                        <button type="submit" name="CopyRule" class="js-rule-copy-rule">Duplicate mapping</button>
                                                    </form>
                                                </li>
                                            {/if}

                                            {if $canEdit}
                                                <li>
                                                    <form method="post" action={'explayouts_ui/rule_list'|ezurl}>
                                                        <input type="hidden" name="RuleID" value="{$rule.id|wash}" />
                                                        <button type="submit" name="EnableRule" class="js-rule-edit" data-action="enable" {if $rule.enabled}disabled="disabled"{/if}>Enable mapping</button>
                                                    </form>
                                                </li>
                                                <li>
                                                    <form method="post" action={'explayouts_ui/rule_list'|ezurl}>
                                                        <input type="hidden" name="RuleID" value="{$rule.id|wash}" />
                                                        <button type="submit" name="DisableRule" class="js-rule-edit" data-action="disable" {if not($rule.enabled)}disabled="disabled"{/if}>Deactivate mapping</button>
                                                    </form>
                                                </li>
                                            {/if}

                                            {if $canEdit}
                                                <li>
                                                    <form method="post" action={'explayouts_ui/rule_list'|ezurl} onsubmit="return confirm('Delete this mapping?');">
                                                        <input type="hidden" name="DeleteRuleID" value="{$rule.id|wash}" />
                                                        <button type="submit" name="DeleteRule" class="js-rule-delete">Delete mapping</button>
                                                    </form>
                                                </li>
                                            {/if}

                                            {if $canEdit and $layout}
                                                <li>
                                                    <form method="post" action={'explayouts_ui/rule_list'|ezurl}>
                                                        <input type="hidden" name="RuleID" value="{$rule.id|wash}" />
                                                        <button type="submit" name="UnlinkRule" class="js-rule-unlink">Unlink layout</button>
                                                    </form>
                                                </li>
                                                <li>
                                                    <form method="post" action={'explayouts_ui/rule_list'|ezurl}>
                                                        <input type="hidden" name="RuleID" value="{$rule.id|wash}" />
                                                        <button type="submit" name="ClearLayoutCache" class="js-layout-clear-cache">Clear layout cache</button>
                                                    </form>
                                                </li>
                                            {/if}
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {include uri='design:explayouts_ui/rule_detail.tpl'
                            rule=$rule
                            ruleId=$rule.id
                            layout=$layout
                            layoutType=$layoutType
                            targetType=$targetType
                            conditionType=$conditionType
                            targets=$targets
                            conditions=$conditions
                            canEdit=$canEdit
                            layouts=$layouts
                            targetTypes=$targetTypes
                            conditionTypes=$conditionTypes}
                    </div>

                    {undef $rule}
                    {undef $layout}
                    {undef $layoutType}
                    {undef $targets}
                    {undef $conditions}
                    {undef $targetType}
                    {undef $conditionType}
                {/foreach}

                <div class="nl-rule nl-element" id="rule-new" data-rule-id="new">
                    {include uri='design:explayouts_ui/rule_detail.tpl'
                        rule=$newRule
                        ruleId='new'
                        targetType=$newRuleTargetType
                        targets=$newRuleTargets
                        conditions=array()
                        canEdit=$canEdit
                        layouts=$layouts
                        targetTypes=$targetTypes
                        conditionTypes=$conditionTypes}
                </div>
            {/if}
        </div>
    </div>
</div>
</div>

{literal}<style>
.nl-toggle-switch { position: relative; display: inline-flex; align-items: center; gap: 8px; cursor: pointer; font-weight: 500; }
.nl-toggle-input { opacity: 0; width: 0; height: 0; position: absolute; }
.nl-toggle-slider { position: relative; display: inline-block; width: 44px; height: 24px; background: #ccc; border-radius: 24px; transition: background .2s; }
.nl-toggle-slider:before { content: ""; position: absolute; height: 18px; width: 18px; left: 3px; bottom: 3px; background: white; border-radius: 50%; transition: transform .2s; }
.nl-toggle-input:checked + .nl-toggle-slider { background: #2196F3; }
.nl-toggle-input:checked + .nl-toggle-slider:before { transform: translateX(20px); }
.nl-toggle-input:focus + .nl-toggle-slider { box-shadow: 0 0 0 2px rgba(33,150,243,.4); }
</style>{/literal}

<script>
var nglTargetTypes = [{foreach $targetTypes as $tt}'{$tt|wash}'{delimiter},{/delimiter}{/foreach}];
var nglConditionTypes = [{foreach $conditionTypes as $ct}'{$ct|wash}'{delimiter},{/delimiter}{/foreach}];
var nglContentClasses = {$contentClassesJson};
var nglSiteAccessList = {$siteAccessListJson};
var nglContentBrowserUrl = {'/explayouts_content_browser_ui/browser/'|ezurl};
var nglCmsViewBase = {'/content/view/full/'|ezurl};
var nglAutoOpenNewRule = {if $autoOpenNewRule}true{else}false{/if};
var nglAutoOpenRuleId = '{$autoOpenRuleId|wash}';
</script>

{literal}<script>
document.addEventListener('DOMContentLoaded', function() {
    function toggleRule(id) {
        var rule = document.getElementById('rule-' + id);
        if (!rule) return;
        rule.classList.toggle('show-body');
        if (rule.classList.contains('show-body')) {
            var body = rule.querySelector('.nl-rule-body');
            if (body) body.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
    }

    document.querySelectorAll('.js-toggle-body, .js-link-layout').forEach(function(el) {
        el.addEventListener('click', function(e) {
            e.preventDefault();
            var rule = this.closest('.nl-rule');
            if (rule) toggleRule(rule.getAttribute('data-rule-id'));
        });
    });

    document.querySelectorAll('.js-add-rule').forEach(function(btn) {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            // close any open rule detail first
            document.querySelectorAll('.nl-rule.show-body').forEach(function(rule) {
                rule.classList.remove('show-body');
            });
            toggleRule('new');
        });
    });

    document.querySelectorAll('.nl-rule-body-overlay').forEach(function(overlay) {
        overlay.addEventListener('click', function(e) {
            if (e.target === this) {
                var rule = this.closest('.nl-rule');
                if (rule) rule.classList.remove('show-body');
            }
        });
    });

    document.querySelectorAll('.nl-dropdown-toggle').forEach(function(toggle) {
        toggle.addEventListener('click', function(e) {
            e.stopPropagation();
            var dropdown = this.closest('.nl-dropdown');
            if (!dropdown) return;
            var wasActive = dropdown.classList.contains('nl-dropdown-active');
            document.querySelectorAll('.nl-dropdown.nl-dropdown-active').forEach(function(d) { d.classList.remove('nl-dropdown-active'); });
            if (!wasActive) dropdown.classList.add('nl-dropdown-active');
        });
    });

    document.addEventListener('click', function() {
        document.querySelectorAll('.nl-dropdown.nl-dropdown-active').forEach(function(d) { d.classList.remove('nl-dropdown-active'); });
    });

    var targetTypeLabels = {
        'node': 'Location',
        'subtree': 'Subtree',
        'path': 'Path',
        'path_prefix': 'Path prefix',
        'path_regex': 'Path regex',
        'route': 'Route'
    };
    var conditionTypeLabels = {
        'class': 'Class',
        'content_type': 'Class',
        'siteaccess': 'Siteaccess',
        'query_parameter': 'Query parameter',
        'route_parameter': 'Route parameter',
        'time': 'Time'
    };

    function isTargetLocation(type) {
        return ['node', 'subtree'].indexOf(type) !== -1;
    }

    function buildTargetValueControl(type, value, display) {
        var html = '';
        if (isTargetLocation(type)) {
            html = '<input type="hidden" name="TargetValue[]" value="' + (value || '') + '" />' +
                '<span class="target-value-display">' + (display || '') + '</span>';
        } else {
            html = '<input type="text" name="TargetValue[]" value="' + (value || '') + '" size="40" />';
        }
        return html;
    }

    function getTargetViewLink(nodeId) {
        var base = window.nglCmsViewBase || '/content/view/full';
        return base + '/' + (nodeId || '');
    }

    function updateTargetValueControl(li, type, value, display) {
        var holder = li.querySelector('.target-value-holder');
        if (!holder) {
            holder = document.createElement('span');
            holder.className = 'target-value-holder settings-value editable-value js-setting-edit';
            holder.setAttribute('data-setting-type', 'target');
            var typeControl = li.querySelector('input[name="TargetType[]"], select[name="TargetType[]"]');
            if (typeControl && typeControl.nextSibling) li.insertBefore(holder, typeControl.nextSibling);
            else li.appendChild(holder);
        }
        holder.innerHTML = buildTargetValueControl(type, value, display);

        var viewLink = li.querySelector('.js-view-target');
        if (!viewLink) {
            viewLink = document.createElement('a');
            viewLink.href = '#';
            viewLink.target = '_blank';
            viewLink.className = 'nl-btn js-view-target';
            viewLink.textContent = 'View in CMS';
            viewLink.style.display = 'none';
            li.insertBefore(viewLink, holder.nextSibling);
        }

        if (isTargetLocation(type) && value && !isNaN(parseInt(value, 10))) {
            viewLink.href = getTargetViewLink(value);
            viewLink.style.display = '';
        } else {
            viewLink.href = '#';
            viewLink.style.display = 'none';
        }
    }

    function buildConditionValueControl(type, value) {
        var isClass = (type === 'class' || type === 'content_type');
        var isSiteaccess = (type === 'siteaccess');
        if (isClass || isSiteaccess) {
            var items = [];
            try {
                var parsed = JSON.parse(value || '');
                if (Array.isArray(parsed)) items = parsed;
            } catch (err) {}
            return '<input type="hidden" name="ConditionValue[]" value="' + (value || '') + '" />' +
                '<ul class="condition-items">' + items.map(function(it) { return '<li>' + it + '</li>'; }).join('') + '</ul>';
        }
        return '<input type="text" name="ConditionValue[]" value="' + (value || '') + '" size="50" />';
    }

    function buildConditionLabel(type) {
        return conditionTypeLabels[type] || type;
    }

    document.querySelectorAll('.js-add-target').forEach(function(btn) {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            var id = this.getAttribute('data-rule-id');
            var list = document.getElementById('targets-table-' + id);
            var select = document.getElementById('target-type-' + id);
            var fixedType = this.getAttribute('data-target-type');
            var type = fixedType || (select ? select.value : '');
            if (!list || !type) return;
            var typeControl = '';
            var nglTargetTypes = window.nglTargetTypes || [];
            if (fixedType) {
                typeControl = '<input type="hidden" name="TargetType[]" value="' + fixedType + '" />' +
                    '<span class="target-type-label"><strong>' + (targetTypeLabels[fixedType] || fixedType) + ':</strong></span>';
            } else {
                var options = '';
                for (var i = 0; i < nglTargetTypes.length; i++) {
                    var selected = (nglTargetTypes[i] === type) ? ' selected="selected"' : '';
                    options += '<option value="' + nglTargetTypes[i] + '"' + selected + '>' + (targetTypeLabels[nglTargetTypes[i]] || nglTargetTypes[i]) + '</option>';
                }
                typeControl = '<select name="TargetType[]" class="nl-select js-target-type-select">' + options + '</select>';
            }
            var li = document.createElement('li');
            li.className = 'nl-rule-setting-item';
            li.innerHTML = typeControl + ' ' +
                '<span class="target-value-holder settings-value editable-value js-setting-edit" data-setting-type="target">' + buildTargetValueControl(type, '', '') + '</span>' +
                ' <a href="#" target="_blank" class="nl-btn js-view-target" style="display:none;">View in CMS</a>' +
                ' <a href="#" class="remove-setting js-remove-row">Delete</a>';
            list.appendChild(li);

            if (!fixedType) {
                var typeSelect = li.querySelector('.js-target-type-select');
                if (typeSelect) {
                    typeSelect.addEventListener('change', function() {
                        updateTargetValueControl(li, this.value, '', '');
                    });
                }
            }
        });
    });

    document.querySelectorAll('.js-add-condition').forEach(function(btn) {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            var id = this.getAttribute('data-rule-id');
            var list = document.getElementById('conditions-table-' + id);
            var select = document.getElementById('condition-type-' + id);
            var type = select ? select.value : '';
            if (!list || !type) return;
            var nglConditionTypes = window.nglConditionTypes || [];
            var options = '';
            for (var i = 0; i < nglConditionTypes.length; i++) {
                var selected = (nglConditionTypes[i] === type) ? ' selected="selected"' : '';
                options += '<option value="' + nglConditionTypes[i] + '"' + selected + '>' + (conditionTypeLabels[nglConditionTypes[i]] || nglConditionTypes[i]) + '</option>';
            }
            var isMulti = (type === 'class' || type === 'content_type' || type === 'siteaccess');
            var li = document.createElement('li');
            li.className = 'nl-rule-setting-item';
            li.innerHTML = '<select name="ConditionType[]" class="nl-select js-condition-type-select">' + options + '</select> ' +
                '<span class="settings-value editable-value js-setting-edit" data-setting-type="condition" data-setting-id=""><strong>' + buildConditionLabel(type) + ':</strong>' +
                buildConditionValueControl(type, (type === 'class' || type === 'content_type' || type === 'siteaccess') ? '[]' : '') + '</span>' +
                ' <a href="#" class="remove-setting js-remove-row">Delete</a>';
            list.appendChild(li);

            var typeSelect = li.querySelector('.js-condition-type-select');
            if (typeSelect) {
                typeSelect.addEventListener('change', function() {
                    var valueSpan = li.querySelector('.settings-value');
                    if (valueSpan) {
                        valueSpan.innerHTML = '<strong>' + buildConditionLabel(this.value) + ':</strong>' +
                            buildConditionValueControl(this.value, (this.value === 'class' || this.value === 'content_type' || this.value === 'siteaccess') ? '[]' : '');
                    }
                });
            }
        });
    });

    document.addEventListener('click', function(e) {
        if (e.target && e.target.classList.contains('js-remove-row')) {
            e.preventDefault();
            var item = e.target.closest ? e.target.closest('li') : null;
            if (!item) {
                item = e.target;
                while (item && item.tagName !== 'LI') item = item.parentNode;
            }
            if (item && item.parentNode) item.parentNode.removeChild(item);
        }
    });

    document.querySelectorAll('.js-rule-edit[data-action="discard"]').forEach(function(btn) {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            var rule = this.closest('.nl-rule');
            if (rule) rule.classList.remove('show-body');
        });
    });

    window.addEventListener('keyup', function(e) {
        if (e.key === 'Escape') {
            document.querySelectorAll('.nl-rule.show-body').forEach(function(rule) {
                rule.classList.remove('show-body');
            });
        }
    });

    document.querySelectorAll('.nl-toggle-input').forEach(function(input) {
        var label = input.parentNode ? input.parentNode.querySelector('.nl-toggle-label') : null;
        if (label) {
            input.addEventListener('change', function() {
                label.textContent = input.checked ? label.getAttribute('data-on') : label.getAttribute('data-off');
                var ruleId = input.getAttribute('data-rule-id');
                if (ruleId) {
                    var rule = document.getElementById('rule-' + ruleId);
                    if (rule) {
                        var content = rule.querySelector('.nl-rule-content');
                        if (content) {
                            if (input.checked) content.classList.remove('disabled');
                            else content.classList.add('disabled');
                            content.setAttribute('data-enabled', input.checked ? '1' : '0');
                        }
                    }
                }
            });
        }
    });

    window.setRuleTargetValue = function(nodeId, name, pathWithNames, field) {
        var input = window.nglActiveTargetInput;
        if (!input) return;
        input.value = nodeId;
        var item = input.closest ? input.closest('li') : null;
        if (item) {
            var viewLink = item.querySelector('.js-view-target');
            if (viewLink) {
                viewLink.href = (window.nglCmsViewBase || '/content/view/full') + '/' + nodeId;
                viewLink.style.display = '';
            }
            var display = item.querySelector('.target-value-display');
            if (display) display.textContent = pathWithNames || name || nodeId;
        }
        window.nglActiveTargetInput = null;
    };

    window.nglActiveTargetInput = null;

    function getConditionValueArray(raw) {
        try {
            var parsed = JSON.parse(raw);
            return Array.isArray(parsed) ? parsed : [parsed];
        } catch (err) {
            return raw ? [raw] : [];
        }
    }

    function buildMultiSelect(name, options, selected, placeholder) {
        var html = '<select multiple class="nl-select condition-edit-select" data-hidden-name="' + name + '"';
        if (placeholder) html += ' title="' + placeholder + '"';
        html += '>';
        for (var key in options) {
            if (!options.hasOwnProperty(key)) continue;
            var isSelected = selected.indexOf(key) !== -1;
            html += '<option value="' + key + '"' + (isSelected ? ' selected="selected"' : '') + '>' + options[key] + '</option>';
        }
        html += '</select>';
        return html;
    }

    function updateConditionHiddenFromSelect(select) {
        var selected = [];
        for (var i = 0; i < select.options.length; i++) {
            if (select.options[i].selected) selected.push(select.options[i].value);
        }
        var hiddenName = select.getAttribute('data-hidden-name');
        var li = select.closest ? select.closest('li') : null;
        var hidden = li ? li.querySelector('input[type="hidden"][name="' + hiddenName + '"], input[type="hidden"][name="' + (hiddenName || 'ConditionValue[]') + '"]') : null;
        if (!hidden) hidden = select.parentNode.querySelector('input[type="hidden"]');
        if (hidden) hidden.value = JSON.stringify(selected);
    }

    document.addEventListener('click', function(e) {
        var edit = e.target && (e.target.classList.contains('js-setting-edit') || e.target.closest('.js-setting-edit'));
        if (!edit) return;
        var span = e.target.classList.contains('js-setting-edit') ? e.target : e.target.closest('.js-setting-edit');
        if (e.target.tagName === 'INPUT' || e.target.tagName === 'SELECT' || e.target.tagName === 'TEXTAREA') return;
        var li = span.closest('li');
        if (!li) return;
        var isTarget = span.getAttribute('data-setting-type') === 'target';

        if (isTarget) {
            var targetTypeInput = li.querySelector('input[name="TargetType[]"]') || li.querySelector('select[name="TargetType[]"]');
            var targetType = targetTypeInput ? targetTypeInput.value : '';
            var targetValueInput = li.querySelector('input[name="TargetValue[]"]');
            if (!targetValueInput) return;
            var locationTypes = ['node', 'subtree'];
            if (locationTypes.indexOf(targetType) !== -1) {
                window.nglActiveTargetInput = targetValueInput;
                var url = (window.nglContentBrowserUrl || '/explayouts_content_browser_ui/browser/') + '?return_uri=js&field=active';
                window.open(url, 'contentbrowser', 'width=900,height=700,scrollbars=yes,resizable=yes');
            } else if (targetValueInput.type !== 'hidden') {
                targetValueInput.focus();
                targetValueInput.select();
            }
            return;
        }

        // condition edit
        var conditionTypeInput = li.querySelector('input[name="ConditionType[]"]') || li.querySelector('select[name="ConditionType[]"]');
        var conditionType = conditionTypeInput ? conditionTypeInput.value : '';
        var hidden = li.querySelector('input[type="hidden"][name="ConditionValue[]"]');
        var raw = hidden ? hidden.value : '';
        var current = getConditionValueArray(raw);

        var classConditionTypes = ['class', 'content_type'];
        var siteaccessConditionTypes = ['siteaccess'];
        var isClass = classConditionTypes.indexOf(conditionType) !== -1;
        var isSiteaccess = siteaccessConditionTypes.indexOf(conditionType) !== -1;

        if (!isClass && !isSiteaccess) {
            var textInput = li.querySelector('input[type="text"][name="ConditionValue[]"]');
            if (textInput) { textInput.focus(); textInput.select(); }
            return;
        }

        // For class/siteaccess, toggle a multi-select
        var wasEditing = li.classList.contains('editing');
        li.classList.toggle('editing');

        function renderConditionChips(items) {
            var list = li.querySelector('.condition-items');
            if (!list) return;
            list.innerHTML = '';
            for (var i = 0; i < items.length; i++) {
                var name = items[i];
                if (isClass && window.nglContentClasses && window.nglContentClasses[items[i]]) {
                    name = window.nglContentClasses[items[i]];
                }
                var chip = document.createElement('li');
                chip.textContent = name;
                list.appendChild(chip);
            }
        }

        if (wasEditing) {
            var hidden2 = li.querySelector('input[type="hidden"][name="ConditionValue[]"]');
            if (hidden2) renderConditionChips(getConditionValueArray(hidden2.value));
            return;
        }

        var editSelect = li.querySelector('.condition-edit-select');
        if (!editSelect) {
            var wrapper = document.createElement('span');
            wrapper.className = 'condition-edit-controls';
            if (isClass) {
                wrapper.innerHTML = buildMultiSelect('ConditionValue[]', window.nglContentClasses || {}, current, 'Select content classes');
            } else if (isSiteaccess) {
                var options = {};
                var saList = window.nglSiteAccessList || [];
                for (var k = 0; k < saList.length; k++) options[saList[k]] = saList[k];
                wrapper.innerHTML = buildMultiSelect('ConditionValue[]', options, current, 'Select siteaccesses');
            }
            if (hidden) hidden.parentNode.insertBefore(wrapper, hidden.nextSibling);
            else span.appendChild(wrapper);
            editSelect = wrapper.querySelector('.condition-edit-select');
            editSelect.addEventListener('change', function() {
                updateConditionHiddenFromSelect(this);
            });
        }
    });

    document.addEventListener('input', function(e) {
        if (e.target && e.target.name === 'TargetValue[]') {
            var item = e.target.closest ? e.target.closest('li') : null;
            var viewLink = item ? item.querySelector('.js-view-target') : null;
            if (viewLink) {
                if (/^\d+$/.test(e.target.value)) {
                    viewLink.href = (window.nglCmsViewBase || '/content/view/full') + '/' + e.target.value;
                    viewLink.style.display = '';
                } else {
                    viewLink.style.display = 'none';
                }
            }
        }
    });

    if ( window.nglAutoOpenNewRule )
        toggleRule('new');
    else if ( window.nglAutoOpenRuleId )
        toggleRule(window.nglAutoOpenRuleId);
});
</script>{/literal}
