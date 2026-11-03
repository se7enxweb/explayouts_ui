{* The template editor (explayouts_ui/template_editor) for every admin design: the template list with search and
   filters, the editor (highlighting, line numbers), the review of the changes before saving, revert to original.
   Shared admin components (.a4-*) and the module classes .explayouts-te-* (stylesheets/explayouts_ui_template_editor.css);
   no inline style or script: the values are the JSON data block #explayouts-ui-te-data, read by
   javascript/explayouts_ui_template_editor.js.
   Variables: $editor_json (rows, bases, base_url, siteaccess, design, selected, csrf_token, can_edit, allow_new), $template_count,
   $selected_path (open from the start), $designs (the design chain: base, design, extension), $design, $siteaccesses, $siteaccess,
   $groups, $can_edit, $allow_new_templates. *}

<p class="a4-intro">{'Edit the templates that draw layouts and blocks. Every change is checked by the template engine and shown as a list of differences before it is saved; the first save keeps the original, so it can be put back.'|i18n( 'design/admin/explayouts_ui/template_editor' )}</p>

<div class="explayouts-te-grid">

<section class="a4-card is-flush explayouts-te-list" aria-labelledby="te-list-title">
    <div class="a4-card-head">
        <h2 class="a4-h3" id="te-list-title">{'Templates'|i18n( 'design/admin/explayouts_ui/template_editor' )}</h2>
        <span class="a4-badge">{$template_count|wash}</span>
        {if $allow_new_templates}
        <div class="a4-card-actions"><button type="button" class="a4-btn a4-btn-small" id="te-new">{'New template'|i18n( 'design/admin/explayouts_ui/template_editor' )}</button></div>
        {/if}
    </div>
    <form class="a4-filterbar explayouts-te-filters explayouts-te-siteaccess" method="post" action={'explayouts_ui/template_editor'|ezurl}>
        <div class="a4-field">
            <label class="a4-label" for="te-siteaccess">{'Siteaccess'|i18n( 'design/admin/explayouts_ui/template_editor' )}</label>
            <div class="a4-toolbar explayouts-te-siteaccess-row">
                <select class="a4-input" id="te-siteaccess" name="SiteAccess">
                    {foreach $siteaccesses as $name}<option value="{$name|wash}"{if eq( $name, $siteaccess )} selected="selected"{/if}>{$name|wash}</option>{/foreach}
                </select>
                <button type="submit" class="a4-btn a4-btn-small" name="ChooseSiteAccessButton" value="1">{'Show'|i18n( 'design/admin/explayouts_ui/template_editor' )}</button>
            </div>
        </div>
    </form>
    <div class="a4-filterbar explayouts-te-filters" role="search">
        <div class="a4-field">
            <label class="a4-label" for="te-search">{'Search'|i18n( 'design/admin/explayouts_ui/template_editor' )}</label>
            <input type="search" class="a4-input" id="te-search" autocomplete="off" placeholder="{'Name or path'|i18n( 'design/admin/explayouts_ui/template_editor' )}" />
        </div>
        <div class="a4-field">
            <label class="a4-label" for="te-design">{'Design'|i18n( 'design/admin/explayouts_ui/template_editor' )}</label>
            <select class="a4-input" id="te-design">
                <option value="">{'All designs'|i18n( 'design/admin/explayouts_ui/template_editor' )}</option>
                {foreach $designs as $d}<option value="{$d.base|wash}"{if eq( $d.base, $design )} selected="selected"{/if}>{$d.design|wash}{if $d.extension} ({$d.extension|wash}){/if}</option>{/foreach}
            </select>
        </div>
        <div class="a4-field">
            <label class="a4-label" for="te-group">{'Folder'|i18n( 'design/admin/explayouts_ui/template_editor' )}</label>
            <select class="a4-input" id="te-group">
                <option value="">{'All folders'|i18n( 'design/admin/explayouts_ui/template_editor' )}</option>
                {foreach $groups as $group}<option value="{$group|wash}">{$group|wash}</option>{/foreach}
            </select>
        </div>
        <div class="a4-field">
            <label class="a4-label" for="te-state">{'Show'|i18n( 'design/admin/explayouts_ui/template_editor' )}</label>
            <select class="a4-input" id="te-state">
                <option value="">{'All templates'|i18n( 'design/admin/explayouts_ui/template_editor' )}</option>
                <option value="changed">{'Changed in the editor'|i18n( 'design/admin/explayouts_ui/template_editor' )}</option>
                <option value="overridden">{'Overridden in another design'|i18n( 'design/admin/explayouts_ui/template_editor' )}</option>
                <option value="not-overridden">{'Not overridden'|i18n( 'design/admin/explayouts_ui/template_editor' )}</option>
            </select>
        </div>
        <p class="a4-filter-count" id="te-count" aria-live="polite">{'%count templates'|i18n( 'design/admin/explayouts_ui/template_editor', '', hash( '%count', $template_count ) )}</p>
    </div>
    <ul class="explayouts-te-files" id="te-files" aria-label="{'Templates'|i18n( 'design/admin/explayouts_ui/template_editor' )}"></ul>
</section>

<section class="a4-card is-flush explayouts-te-editor" aria-labelledby="te-file-title">
    <div class="a4-card-head">
        <div class="explayouts-te-filehead">
            <h2 class="a4-h3" id="te-file-title">{if $selected_path}{$selected_path|explode( '/' )|reverse|extract( 0, 1 )|implode( '' )|wash}{else}{'No template selected'|i18n( 'design/admin/explayouts_ui/template_editor' )}{/if}</h2>
            <p class="explayouts-te-path" id="te-file-path">{$selected_path|wash}</p>
            <div class="a4-badges" id="te-facts"></div>
        </div>
        {if $can_edit}
        <div class="a4-card-actions">
            <button type="button" class="a4-btn" id="te-review-open" disabled="disabled">{'Review changes'|i18n( 'design/admin/explayouts_ui/template_editor' )}</button>
            <button type="button" class="a4-btn a4-btn-primary" id="te-save" disabled="disabled" aria-keyshortcuts="Control+S Meta+S">{'Save'|i18n( 'design/admin/explayouts_ui/template_editor' )}</button>
        </div>
        {/if}
    </div>
    <div class="a4-notice is-bad explayouts-te-problems" id="te-problems" role="alert" hidden="hidden"></div>
    {if $can_edit}
    <div class="a4-notice is-info explayouts-te-problems" id="te-readonly" hidden="hidden">
        <p class="a4-notice-title">{'This template is read-only here.'|i18n( 'design/admin/explayouts_ui/template_editor' )}</p>
        <p>{'Its design is not one the editor may change (explayouts.ini [TemplateEditorSettings] AllowedTemplateRoots). To change it, create an override in a design that comes before it for this siteaccess.'|i18n( 'design/admin/explayouts_ui/template_editor' )}</p>
        <div class="a4-toolbar explayouts-te-override" id="te-override-box" hidden="hidden">
            <label class="a4-label" for="te-override-target">{'Create override in'|i18n( 'design/admin/explayouts_ui/template_editor' )}</label>
            <select class="a4-input" id="te-override-target"></select>
            <button type="button" class="a4-btn a4-btn-small a4-btn-primary" id="te-override">{'Create override'|i18n( 'design/admin/explayouts_ui/template_editor' )}</button>
        </div>
    </div>
    {/if}
    <p class="a4-empty explayouts-te-empty" id="te-empty"{if $selected_path} hidden="hidden"{/if}>{'Select a template from the list to start editing.'|i18n( 'design/admin/explayouts_ui/template_editor' )}</p>
    <div class="explayouts-te-code" id="te-code" {if $selected_path|not}hidden="hidden"{/if}>
        <div class="explayouts-te-gutter" id="te-gutter" aria-hidden="true"></div>
        <div class="explayouts-te-stack">
            <pre class="explayouts-te-highlight" id="te-highlight" aria-hidden="true"></pre>
            <textarea class="explayouts-te-text" id="te-text" spellcheck="false" autocapitalize="off" autocomplete="off" wrap="off" aria-label="{'Template text'|i18n( 'design/admin/explayouts_ui/template_editor' )}" aria-describedby="te-help"{if $can_edit|not} readonly="readonly"{/if}></textarea>
        </div>
    </div>
    <div class="a4-card-foot explayouts-te-foot" id="te-foot" {if $selected_path|not}hidden="hidden"{/if}>
        <p class="a4-help" id="te-help">{if $can_edit}{'Ctrl+S or Cmd+S reviews and saves. Tab indents; press Esc, then Tab, to leave the text.'|i18n( 'design/admin/explayouts_ui/template_editor' )}{else}{'You may read the templates, not change them.'|i18n( 'design/admin/explayouts_ui/template_editor' )}{/if}</p>
        <p class="a4-status explayouts-te-status" id="te-status" role="status" aria-live="polite"></p>
        {if $can_edit}
        <details class="a4-confirm explayouts-te-revert" id="te-revert-box" hidden="hidden">
            <summary>{'Revert to original'|i18n( 'design/admin/explayouts_ui/template_editor' )}</summary>
            <div>
                <p>{'The template goes back to the original the editor kept before its first change. The version saved now stays in the backup.'|i18n( 'design/admin/explayouts_ui/template_editor' )}</p>
                <button type="button" class="a4-btn a4-btn-danger" id="te-revert">{'Revert to original'|i18n( 'design/admin/explayouts_ui/template_editor' )}</button>
            </div>
        </details>
        {/if}
    </div>
</section>

</div>

{if $can_edit}
<dialog class="explayouts-te-dialog" id="te-review" aria-labelledby="te-review-title">
    <div class="a4-card-head">
        <h2 class="a4-h3" id="te-review-title">{'Review changes'|i18n( 'design/admin/explayouts_ui/template_editor' )}</h2>
        <p id="te-review-sum"></p>
    </div>
    <div class="a4-field explayouts-te-compare">
        <label class="a4-label" for="te-compare">{'Compare with'|i18n( 'design/admin/explayouts_ui/template_editor' )}</label>
        <select class="a4-input" id="te-compare">
            <option value="saved">{'The saved template'|i18n( 'design/admin/explayouts_ui/template_editor' )}</option>
            <option value="original">{'The original'|i18n( 'design/admin/explayouts_ui/template_editor' )}</option>
        </select>
    </div>
    <div id="te-review-checks"></div>
    <div class="explayouts-te-diff" id="te-review-diff" tabindex="0" role="region" aria-label="{'Differences'|i18n( 'design/admin/explayouts_ui/template_editor' )}"></div>
    <div class="a4-actions explayouts-te-dialog-actions">
        <button type="button" class="a4-btn" id="te-review-close">{'Close'|i18n( 'design/admin/explayouts_ui/template_editor' )}</button>
        <button type="button" class="a4-btn a4-btn-primary" id="te-review-save">{'Save'|i18n( 'design/admin/explayouts_ui/template_editor' )}</button>
    </div>
</dialog>
{/if}

{if $allow_new_templates}
<dialog class="explayouts-te-dialog is-small" id="te-new-dialog" aria-labelledby="te-new-title">
    <div class="a4-card-head"><h2 class="a4-h3" id="te-new-title">{'New template'|i18n( 'design/admin/explayouts_ui/template_editor' )}</h2></div>
    <div class="a4-field">
        <label class="a4-label" for="te-new-path">{'Path'|i18n( 'design/admin/explayouts_ui/template_editor' )}</label>
        <input type="text" class="a4-input" id="te-new-path" autocomplete="off" aria-describedby="te-new-help" />
        <p class="a4-help" id="te-new-help">{'From the installation root, inside one of the folders listed here, ending in .tpl.'|i18n( 'design/admin/explayouts_ui/template_editor' )}</p>
    </div>
    <div class="a4-actions explayouts-te-dialog-actions">
        <button type="button" class="a4-btn" id="te-new-cancel">{'Cancel'|i18n( 'design/admin/explayouts_ui/template_editor' )}</button>
        <button type="button" class="a4-btn a4-btn-primary" id="te-new-create">{'Create'|i18n( 'design/admin/explayouts_ui/template_editor' )}</button>
    </div>
</dialog>
{/if}

{* The values of the editor, one JSON data block (< and > of the whole block as JSON escapes). *}
{set-block variable=$explayouts_ui_te_data}{ldelim}"i18n": {json_encode( hash(
    'count', '%count templates'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'count_of', '%shown of %count templates'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'no_match', 'No templates match.'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'no_file', 'No template selected'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'loading', 'Loading...'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'load_error', 'Load error: %message'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'saved', 'Saved'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'save_error', 'Save error: %message'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'unsaved', 'Unsaved changes'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'no_changes', 'No changes'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'discard', 'This template has unsaved changes. Discard them?'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'changed', 'Changed in the editor'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'overridden', 'Overridden in %count other designs'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'overridden_by', 'Also in: %paths'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'used_blocks', 'Used by %count blocks in %layouts layouts'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'used_layouts', 'Used by %count layouts'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'unused', 'Not used by a published layout'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'summary', 'Lines added: %added, lines removed: %removed'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'identical', 'The text is the same as the version compared with.'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'syntax_ok', 'The template engine found no syntax errors.'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'syntax_errors', 'Syntax errors: fix them before saving.'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'syntax_warnings', 'Please check before saving:'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'line', 'Line %line'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'checking', 'Checking...'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'reverted', 'The original is back.'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'new_tpl', 'The path must end in .tpl'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'new_hint', 'New template, not saved yet'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'winner', 'Drawn for %siteaccess'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'overrides', 'Overrides: %paths'|i18n( 'design/admin/explayouts_ui/template_editor' ),
    'read_only', 'Read-only'|i18n( 'design/admin/explayouts_ui/template_editor' )
) )}, "editor": {$editor_json}{rdelim}{/set-block}
<script type="application/json" id="explayouts-ui-te-data">{$explayouts_ui_te_data|explode( '<' )|implode( '\u003c' )|explode( '>' )|implode( '\u003e' )}</script>
{undef $explayouts_ui_te_data}
