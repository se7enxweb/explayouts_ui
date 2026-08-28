{ezcss_load(array('netgen/layouts-admin.css','netgen/layouts-ibexa.css','nglayouts-ui.css'))}
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
{literal}<style>
#rules { visibility: visible !important; }
#rules .message-feedback,
#rules .message-error { margin: 14px 18px; }
#rules .nl-rule-body table.list { width: 100%; }
#rules .nl-rule-body table.list th { text-align: left; font-size: 12px; color: #777; padding: 6px 4px; font-weight: 500; }
#rules .nl-rule-body table.list td { padding: 4px; }
#rules .rule-layout .icon-rule,
#rules .rule-layout .icon-rule-disabled { font-family: 'Material Icons' !important; }
#rules .nl-rule-body table.list input[type="text"],
#rules .nl-rule-body table.list select { width: 100%; box-sizing: border-box; padding: 6px; }
#rules .nl-rule-body .nl-rule-setting .settings-action select { min-width: 140px; padding: 6px; }
#rules .nl-rule-body .nl-rule-setting h4 { margin: 0 0 6px; font-size: 15px; }
#rules .nl-rule-body .nl-rule-setting .note { font-size: 12px; color: #777; margin: 0 0 10px; }
#rules .nl-dropdown-menu form { margin: 0; }
#rules .nl-dropdown-menu button { background: none; border: none; width: 100%; text-align: left; padding: 8px 16px; cursor: pointer; font: inherit; color: inherit; }
#rules .nl-dropdown-menu button:disabled { opacity: .5; cursor: not-allowed; }
#rules .nl-dropdown-menu a, #rules .nl-dropdown-menu button { display: block; width: 100%; box-sizing: border-box; }
</style>{/literal}

<div class="ng-layouts-app">
    <div class="layouts-content">
        <div id="rules" class="nl-element">
        <div class="layouts-header">
            <h2 class="layouts-title">Layout Rules</h2>
            <div class="layouts-controls">
                {if $canEdit}
                    <button type="button" class="nl-btn nl-btn-primary js-add-rule">
                        <i class="material-icons">add</i> New rule
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

                                <div class="nl-rule-cell rule-targets">
                                    {if count($targets)|gt(0)}
                                        {if eq($targetType,'null')}
                                            <p>All</p>
                                        {elseif count($targets)|eq(1)}
                                            <p>{$targetType|wash}:</p>
                                            <ul>
                                                {foreach $targets as $t}
                                                    <li>{$t.target_value|wash}</li>
                                                {/foreach}
                                            </ul>
                                        {else}
                                            <p>{$targetType|wash} ({count($targets)|wash})</p>
                                        {/if}
                                    {/if}
                                </div>

                                <div class="nl-rule-cell rule-conditions">
                                    {if count($conditions)|gt(0)}
                                        <ul class="{if count($conditions)|eq(2)}nl-ellipsis{elseif count($conditions)|gt(2)}nl-inline{/if}">
                                            {foreach $conditions as $c}
                                                {def $conditionDisplayType = cond(eq($c.condition_type,'ibexa_content_type'),'content_type',cond(eq($c.condition_type,'ibexa_site_access'),'siteaccess',$c.condition_type))}
                                                <li>{if count($conditions)|lt(3)}{$conditionDisplayType|wash}: {/if}{$c.condition_value|wash}</li>
                                            {/foreach}
                                        </ul>
                                    {/if}
                                </div>

                                <div class="hover-actions">
                                    {if $layout}
                                        <div class="nl-rule-cell rule-edit-layout rule-padded-left">
                                            <a href={concat('explayouts_ui/rule_edit/',$rule.id)|ezurl} class="js-open-ngl">Edit layout</a>
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
                                                <li><a href="#" class="js-toggle-body">Edit rule</a></li>
                                                <li>
                                                    <form method="post" action={'explayouts_ui/rule_list'|ezurl}>
                                                        <input type="hidden" name="CopyRuleID" value="{$rule.id|wash}" />
                                                        <button type="submit" name="CopyRule" class="js-rule-copy-rule">Copy rule</button>
                                                    </form>
                                                </li>
                                            {/if}

                                            {if $canEdit}
                                                <li>
                                                    <form method="post" action={'explayouts_ui/rule_list'|ezurl}>
                                                        <input type="hidden" name="RuleID" value="{$rule.id|wash}" />
                                                        <button type="submit" name="EnableRule" class="js-rule-edit" data-action="enable" {if $rule.enabled}disabled="disabled"{/if}>Enable rule</button>
                                                    </form>
                                                </li>
                                                <li>
                                                    <form method="post" action={'explayouts_ui/rule_list'|ezurl}>
                                                        <input type="hidden" name="RuleID" value="{$rule.id|wash}" />
                                                        <button type="submit" name="DisableRule" class="js-rule-edit" data-action="disable" {if not($rule.enabled)}disabled="disabled"{/if}>Disable rule</button>
                                                    </form>
                                                </li>
                                            {/if}

                                            {if $canEdit}
                                                <li>
                                                    <form method="post" action={'explayouts_ui/rule_list'|ezurl} onsubmit="return confirm('Delete this rule?');">
                                                        <input type="hidden" name="DeleteRuleID" value="{$rule.id|wash}" />
                                                        <button type="submit" name="DeleteRule" class="js-rule-delete">Delete rule</button>
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
                        targetType='null'
                        targets=array()
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
var nglContentBrowserUrl = {'/explayouts_content_browser_ui/browser/'|ezurl};
var nglCmsEditBase = {'/content/edit/'|ezurl};
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

    document.querySelectorAll('.js-add-target').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var id = this.getAttribute('data-rule-id');
            var table = document.getElementById('targets-table-' + id);
            var select = document.getElementById('target-type-' + id);
            var type = select ? select.value : '';
            if (!table) return;
            var options = '';
            var nglTargetTypes = window.nglTargetTypes || [];
            for (var i = 0; i < nglTargetTypes.length; i++) {
                var selected = (nglTargetTypes[i] === type) ? ' selected="selected"' : '';
                options += '<option value="' + nglTargetTypes[i] + '"' + selected + '>' + nglTargetTypes[i] + '</option>';
            }
            var row = table.insertRow(-1);
            row.innerHTML = '<td><select name="TargetType[]">' + options + '</select></td>' +
                '<td><input type="text" name="TargetValue[]" value="" size="40" />' +
                '<button type="button" class="nl-btn js-browse-target">Browse</button>' +
                '<a href="#" target="_blank" class="nl-btn js-view-target" style="display:none;">View in CMS</a></td>' +
                '<td><button type="button" class="nl-btn js-remove-row">Remove</button></td>';
        });
    });

    document.querySelectorAll('.js-add-condition').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var id = this.getAttribute('data-rule-id');
            var table = document.getElementById('conditions-table-' + id);
            var select = document.getElementById('condition-type-' + id);
            var type = select ? select.value : '';
            if (!table) return;
            var options = '';
            var nglConditionTypes = window.nglConditionTypes || [];
            for (var i = 0; i < nglConditionTypes.length; i++) {
                var selected = (nglConditionTypes[i] === type) ? ' selected="selected"' : '';
                options += '<option value="' + nglConditionTypes[i] + '"' + selected + '>' + nglConditionTypes[i] + '</option>';
            }
            var row = table.insertRow(-1);
            row.innerHTML = '<td><select name="ConditionType[]">' + options + '</select></td>' +
                '<td><input type="text" name="ConditionValue[]" value="" size="50" /></td>' +
                '<td><button type="button" class="nl-btn js-remove-row">Remove</button></td>';
        });
    });

    document.addEventListener('click', function(e) {
        if (e.target && e.target.classList.contains('js-remove-row')) {
            var row = e.target.closest ? e.target.closest('tr') : null;
            if (!row) {
                row = e.target;
                while (row && row.tagName !== 'TR') row = row.parentNode;
            }
            if (row && row.parentNode) row.parentNode.removeChild(row);
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

    window.setRuleTargetValue = function(nodeId, name, field) {
        var input = window.nglActiveTargetInput;
        if (!input) return;
        input.value = nodeId;
        var cell = input.parentNode;
        if (cell) {
            var viewLink = cell.querySelector('.js-view-target');
            if (viewLink) {
                viewLink.href = (window.nglCmsEditBase || '/content/edit') + '/' + nodeId;
                viewLink.style.display = '';
            }
        }
        window.nglActiveTargetInput = null;
    };

    window.nglActiveTargetInput = null;

    document.addEventListener('click', function(e) {
        if (e.target && e.target.classList.contains('js-browse-target')) {
            e.preventDefault();
            var cell = e.target.closest ? e.target.closest('td') : null;
            var input = cell ? cell.querySelector('input[name="TargetValue[]"]') : null;
            if (!input) return;
            window.nglActiveTargetInput = input;
            var url = (window.nglContentBrowserUrl || '/explayouts_content_browser_ui/browser/') + '?return_uri=js&field=active';
            window.open(url, 'contentbrowser', 'width=900,height=700,scrollbars=yes,resizable=yes');
        }
    });

    document.addEventListener('input', function(e) {
        if (e.target && e.target.name === 'TargetValue[]') {
            var cell = e.target.parentNode;
            var viewLink = cell ? cell.querySelector('.js-view-target') : null;
            if (viewLink) {
                if (/^\d+$/.test(e.target.value)) {
                    viewLink.href = (window.nglCmsEditBase || '/content/edit') + '/' + e.target.value;
                    viewLink.style.display = '';
                } else {
                    viewLink.style.display = 'none';
                }
            }
        }
    });
});
</script>{/literal}
