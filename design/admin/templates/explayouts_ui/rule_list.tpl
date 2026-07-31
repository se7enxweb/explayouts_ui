{ezcss_load(array('netgen/layouts-admin.css','netgen/layouts-ibexa.css','nglayouts-ui.css'))}
{ezscript_load(array('netgen/layouts-admin.js','netgen/layouts-ibexa.js'))}
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
{literal}<style>
.nl-rule-content { display: flex; align-items: center; justify-content: space-between; padding: 14px 18px; border-bottom: 1px solid #e0e0e0; }
.nl-rule-info { display: flex; align-items: center; gap: 18px; min-width: 0; }
.nl-rule-main { min-width: 0; }
.nl-rule-name { font-size: 15px; font-weight: 500; color: #333; margin: 0 0 4px; }
.nl-rule-meta { font-size: 12px; color: #777; margin: 0; }
.nl-rule-meta span { display: inline-flex; align-items: center; gap: 4px; margin-right: 12px; }
.nl-rule-actions { display: flex; align-items: center; gap: 8px; }
.nl-rule-status { display: inline-flex; align-items: center; padding: 2px 8px; border-radius: 12px; font-size: 11px; font-weight: 500; text-transform: uppercase; }
.nl-rule-status.enabled { background: #e6f5e6; color: #2e7d32; }
.nl-rule-status.disabled { background: #f5f5f5; color: #777; }
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
                {foreach $rules as $rule}
                    <div class="nl-layout">
                        <div class="nl-rule-content">
                            <div class="nl-rule-info">
                                <div class="nl-rule-main">
                                    <div class="nl-rule-name">Rule #{$rule.id|wash}</div>
                                    <div class="nl-rule-meta">
                                        <span><i class="material-icons" style="font-size:14px;">format_list_numbered</i> Priority {$rule.priority|wash}</span>
                                        <span><i class="material-icons" style="font-size:14px;">layers</i> Layout #{$rule.layout_id|wash}</span>
                                    </div>
                                </div>
                            </div>
                            <div class="nl-rule-actions">
                                {if $rule.enabled}<span class="nl-rule-status enabled">Enabled</span>{else}<span class="nl-rule-status disabled">Disabled</span>{/if}
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
                    </div>
                {/foreach}
            </div>

            {if count($rules)|eq(0)}
                <p class="nl-no-items" style="display: block;">There are no rules defined</p>
            {/if}
        </div>
    </div>
</div>
