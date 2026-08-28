{ezcss_load(array('netgen/layouts-admin.css','netgen/layouts-ibexa.css','nglayouts-ui.css'))}
{ezscript_load(array('netgen/layouts-admin.js','netgen/layouts-ibexa.js'))}
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
<div class="ng-layouts-app row">
    <div class="layouts-content">
        <div class="layouts-header">
            <h2 class="layouts-title">{if gt($rule.id,0)}Edit Rule{else}New Rule{/if}</h2>
        </div>

        {if $message}<div class="message-feedback">{$message|wash}</div>{/if}
        {if $error}<div class="message-error">{$error|wash}</div>{/if}

        <form method="post" action={concat('explayouts_ui/rule_edit/',$rule.id)|ezurl}>
            <label for="layout_id">Layout</label>
            <select id="layout_id" name="LayoutID">
                {foreach $layouts as $layout}
                    <option value="{$layout.id|wash}" {if eq($rule.layout_id,$layout.id)}selected="selected"{/if}>{$layout.name|wash} ({$layout.identifier|wash})</option>
                {/foreach}
            </select>

            <label for="priority">Priority</label>
            <input id="priority" type="text" name="Priority" value="{$rule.priority|wash}" size="10" />

            <label>
                <input type="checkbox" name="Enabled" value="1" {if $rule.enabled}checked="checked"{/if} /> Enabled
            </label>

            <h3 style="margin-top:24px;">Targets</h3>
            <p>First matching target wins. Types: <code>path_prefix</code>, <code>path</code>, <code>path_regex</code> (pattern without delimiters), <code>node</code> (node ID or URL alias).</p>
            <table class="list" cellspacing="0">
                <tr><th>Type</th><th>Value</th></tr>
                {foreach $targets as $t}
                    <tr>
                        <td><input type="text" name="TargetType[]" value="{$t.target_type|wash}" /></td>
                        <td><input type="text" name="TargetValue[]" value="{$t.target_value|wash}" size="60" /></td>
                    </tr>
                {/foreach}
                {for 0 to 2 as $i}
                    <tr>
                        <td><input type="text" name="TargetType[]" value="" /></td>
                        <td><input type="text" name="TargetValue[]" value="" size="60" /></td>
                    </tr>
                {/for}
            </table>

            <h3>Conditions</h3>
            <p>All conditions must match. Types: <code>siteaccess</code>.</p>
            <table class="list" cellspacing="0">
                <tr><th>Type</th><th>Value</th></tr>
                {foreach $conditions as $c}
                    <tr>
                        <td><input type="text" name="ConditionType[]" value="{$c.condition_type|wash}" /></td>
                        <td><input type="text" name="ConditionValue[]" value="{$c.condition_value|wash}" size="60" /></td>
                    </tr>
                {/foreach}
                {for 0 to 2 as $i}
                    <tr>
                        <td><input type="text" name="ConditionType[]" value="" /></td>
                        <td><input type="text" name="ConditionValue[]" value="" size="60" /></td>
                    </tr>
                {/for}
            </table>

            <div class="nl-form-actions">
                <button class="nl-btn nl-btn-primary" type="submit" name="SaveRule">Save rule</button>
                <a class="nl-btn" href={'explayouts_ui/rule_list'|ezurl}>Back</a>
            </div>
        </form>
    </div>
</div>
