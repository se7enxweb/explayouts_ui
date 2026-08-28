{ezcss_load(array('netgen/layouts-admin.css','netgen/layouts-ibexa.css','nglayouts-ui.css'))}
{ezscript_load(array('netgen/layouts-admin.js','netgen/layouts-ibexa.js'))}
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
{literal}<style>
.nl-rule-content { display: flex; align-items: center; justify-content: space-between; padding: 14px 18px; border-bottom: 1px solid #e0e0e0; }
.nl-rule-info { display: flex; align-items: center; gap: 18px; min-width: 0; flex: 1; }
.nl-rule-main { min-width: 0; flex: 1; }
.nl-rule-name { font-size: 15px; font-weight: 500; color: #333; margin: 0 0 4px; display: flex; gap: 10px; align-items: center; }
.nl-rule-priority { font-size: 12px; color: #777; font-weight: 400; }
.nl-rule-meta { font-size: 12px; color: #777; margin: 0 0 4px; }
.nl-rule-meta .nl-rule-targets, .nl-rule-meta .nl-rule-conditions { display: inline-flex; align-items: center; gap: 4px; margin-right: 16px; }
.nl-rule-layout .layout-name { font-size: 13px; color: #444; font-weight: 500; }
.nl-rule-layout .no-layout { font-size: 13px; color: #999; font-style: italic; }
.nl-rule-actions { display: flex; align-items: center; gap: 8px; }
.nl-rule-status { display: inline-flex; align-items: center; padding: 2px 8px; border-radius: 12px; font-size: 11px; font-weight: 500; text-transform: uppercase; }
.nl-rule-status.enabled { background: #e6f5e6; color: #2e7d32; }
.nl-rule-status.disabled { background: #f5f5f5; color: #777; }
.nl-rule-body { display: none; background: #fafafa; border-bottom: 1px solid #e0e0e0; padding: 0; }
.nl-rule-body-header { display: flex; justify-content: space-between; align-items: center; padding: 14px 18px; border-bottom: 1px solid #e0e0e0; }
.nl-rule-body-header h3 { margin: 0; font-size: 16px; font-weight: 500; }
.nl-rule-body-content { padding: 18px; }
.nl-rule-section { margin-bottom: 18px; }
.nl-rule-section h4 { margin: 0 0 8px; font-size: 14px; font-weight: 500; color: #555; }
.nl-rule-section table.list { width: 100%; }
.nl-rule-section table.list th { text-align: left; font-size: 12px; color: #777; padding: 6px 4px; }
.nl-rule-section table.list td { padding: 4px; }
.nl-rule-section table.list input[type="text"] { width: 100%; box-sizing: border-box; padding: 6px; }
.nl-rule-inline { display: flex; gap: 24px; align-items: center; }
.nl-rule-enabled { display: inline-flex; align-items: center; gap: 6px; }
.nl-dropdown { display: inline-block !important; opacity: 1 !important; visibility: visible !important; }
.nl-dropdown-toggle { visibility: visible !important; }
</style>{/literal}
<div class="ng-layouts-app row">
    <div class="layouts-content">
        <div class="nl-layouts-view-grid" style="display: block;">
            <div class="layouts-header">
                <h2 class="layouts-title">Layout Rules</h2>
                <div class="layouts-controls">
                    <a href={concat('explayouts_ui/rule_edit/')|ezurl} class="nl-btn nl-btn-primary">
                        <i class="material-icons">add</i> New rule
                    </a>
                </div>
            </div>

            {if $message}<div class="message-feedback">{$message|wash}</div>{/if}
            {if $error}<div class="message-error">{$error|wash}</div>{/if}

            <div class="nl-layouts">
                {if count($ruleData)|eq(0)}
                    <p class="nl-no-items" style="display: block;">There are no rules defined</p>
                {else}
                    {foreach $ruleData as $item}
                        {def $rule = $item.rule}
                        {def $layout = $item.layout}
                        {def $targets = $item.targets}
                        {def $conditions = $item.conditions}

                        <div class="nl-rule" id="rule-{$rule.id|wash}">
                            <div class="nl-rule-content">
                                <div class="nl-rule-info">
                                    <div class="nl-rule-main">
                                        <div class="nl-rule-name">
                                            Rule #{$rule.id|wash}
                                            <span class="nl-rule-priority">Priority {$rule.priority|wash}</span>
                                        </div>
                                        <div class="nl-rule-layout">
                                            {if $layout}
                                                <span class="layout-name" title="{$layout.identifier|wash}">{$layout.name|wash}</span>
                                            {else}
                                                <span class="no-layout">No mapped layout</span>
                                            {/if}
                                        </div>
                                        <div class="nl-rule-meta">
                                            <span class="nl-rule-targets">
                                                <i class="material-icons" style="font-size:14px;">my_location</i>
                                                {if count($targets)|eq(0)}
                                                    No targets
                                                {else}
                                                    {foreach $targets as $t}
                                                        <span class="nl-rule-item">{$t.target_type|wash}: {$t.target_value|wash}</span>
                                                    {/foreach}
                                                {/if}
                                            </span>
                                        </div>
                                        <div class="nl-rule-meta">
                                            <span class="nl-rule-conditions">
                                                <i class="material-icons" style="font-size:14px;">filter_list</i>
                                                {if count($conditions)|eq(0)}
                                                    No conditions
                                                {else}
                                                    {foreach $conditions as $c}
                                                        <span class="nl-rule-item">{$c.condition_type|wash}: {$c.condition_value|wash}</span>
                                                    {/foreach}
                                                {/if}
                                            </span>
                                        </div>
                                    </div>
                                </div>
                                <div class="nl-rule-actions">
                                    {if $rule.enabled}<span class="nl-rule-status enabled">Enabled</span>{else}<span class="nl-rule-status disabled">Disabled</span>{/if}
                                    <button type="button" class="nl-btn js-toggle-details" data-rule-id="{$rule.id|wash}">Details</button>
                                    <a href={concat('explayouts_ui/rule_edit/',$rule.id)|ezurl} class="nl-btn" title="Edit"><i class="material-icons">edit</i></a>
                                    <form method="post" action={'explayouts_ui/rule_list'|ezurl} style="display:inline;margin:0;">
                                        <input type="hidden" name="CopyRuleID" value="{$rule.id|wash}" />
                                        <button type="submit" name="CopyRule" class="nl-btn" title="Copy"><i class="material-icons">content_copy</i></button>
                                    </form>
                                    <form method="post" action={'explayouts_ui/rule_list'|ezurl} style="display:inline;margin:0;" onsubmit="return confirm('Delete this rule?');">
                                        <input type="hidden" name="DeleteRuleID" value="{$rule.id|wash}" />
                                        <button type="submit" name="DeleteRule" class="nl-btn" title="Delete"><i class="material-icons">delete</i></button>
                                    </form>
                                </div>
                            </div>

                            <div class="nl-rule-body" id="rule-body-{$rule.id|wash}" style="display:none;">
                                <form method="post" action={'explayouts_ui/rule_list'|ezurl}>
                                    <input type="hidden" name="RuleID" value="{$rule.id|wash}" />
                                    <div class="nl-rule-body-header">
                                        <h3>Rule details</h3>
                                        <div class="nl-rule-actions">
                                            <button type="submit" name="SaveRule" class="nl-btn nl-btn-primary">Save changes</button>
                                            <button type="button" class="nl-btn js-toggle-details" data-rule-id="{$rule.id|wash}">Cancel</button>
                                        </div>
                                    </div>
                                    <div class="nl-rule-body-content">
                                        <div class="nl-rule-section">
                                            <h4>Mapped layout</h4>
                                            <select name="LayoutID" style="min-width: 240px; padding: 6px;">
                                                <option value="0" {if eq($rule.layout_id,0)}selected="selected"{/if}>(none)</option>
                                                {foreach $layouts as $lo}
                                                    <option value="{$lo.id|wash}" {if eq($rule.layout_id,$lo.id)}selected="selected"{/if}>{$lo.name|wash} ({$lo.identifier|wash})</option>
                                                {/foreach}
                                            </select>
                                        </div>
                                        <div class="nl-rule-section nl-rule-inline">
                                            <label>Priority <input type="text" name="Priority" value="{$rule.priority|wash}" size="6" style="padding:6px;" /></label>
                                            <label class="nl-rule-enabled"><input type="checkbox" name="Enabled" value="1" {if $rule.enabled}checked="checked"{/if} /> Enabled</label>
                                        </div>
                                        <div class="nl-rule-section">
                                            <h4>Targets</h4>
                                            <table class="list" id="targets-table-{$rule.id|wash}" cellspacing="0">
                                                <tr><th>Type</th><th>Value</th><th></th></tr>
                                                {foreach $targets as $t}
                                                    <tr>
                                                        <td><input type="text" name="TargetType[]" value="{$t.target_type|wash}" /></td>
                                                        <td><input type="text" name="TargetValue[]" value="{$t.target_value|wash}" size="50" /></td>
                                                        <td><button type="button" class="nl-btn js-remove-row">Remove</button></td>
                                                    </tr>
                                                {/foreach}
                                            </table>
                                            <button type="button" class="nl-btn nl-btn-link js-add-target" data-rule-id="{$rule.id|wash}" style="margin-top:6px;">
                                                <i class="material-icons">add</i> Add target
                                            </button>
                                        </div>
                                        <div class="nl-rule-section">
                                            <h4>Conditions</h4>
                                            <table class="list" id="conditions-table-{$rule.id|wash}" cellspacing="0">
                                                <tr><th>Type</th><th>Value</th><th></th></tr>
                                                {foreach $conditions as $c}
                                                    <tr>
                                                        <td><input type="text" name="ConditionType[]" value="{$c.condition_type|wash}" /></td>
                                                        <td><input type="text" name="ConditionValue[]" value="{$c.condition_value|wash}" size="50" /></td>
                                                        <td><button type="button" class="nl-btn js-remove-row">Remove</button></td>
                                                    </tr>
                                                {/foreach}
                                            </table>
                                            <button type="button" class="nl-btn nl-btn-link js-add-condition" data-rule-id="{$rule.id|wash}" style="margin-top:6px;">
                                                <i class="material-icons">add</i> Add condition
                                            </button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>

                        {undef $rule}
                        {undef $layout}
                        {undef $targets}
                        {undef $conditions}
                    {/foreach}
                {/if}
            </div>
        </div>
    </div>
</div>

{literal}<script>
document.addEventListener('DOMContentLoaded', function() {
    function toggleDetails(id) {
        var panel = document.getElementById('rule-body-' + id);
        if (!panel) return;
        panel.style.display = (panel.style.display === 'block') ? 'none' : 'block';
        if (panel.style.display === 'block') {
            panel.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
    }

    document.querySelectorAll('.js-toggle-details').forEach(function(btn) {
        btn.addEventListener('click', function() {
            toggleDetails(this.getAttribute('data-rule-id'));
        });
    });

    document.querySelectorAll('.js-add-target').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var id = this.getAttribute('data-rule-id');
            var table = document.getElementById('targets-table-' + id);
            if (!table) return;
            var row = table.insertRow(-1);
            row.innerHTML = '<td><input type="text" name="TargetType[]" value="" /></td>' +
                '<td><input type="text" name="TargetValue[]" value="" size="50" /></td>' +
                '<td><button type="button" class="nl-btn js-remove-row">Remove</button></td>';
        });
    });

    document.querySelectorAll('.js-add-condition').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var id = this.getAttribute('data-rule-id');
            var table = document.getElementById('conditions-table-' + id);
            if (!table) return;
            var row = table.insertRow(-1);
            row.innerHTML = '<td><input type="text" name="ConditionType[]" value="" /></td>' +
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
});
</script>{/literal}
