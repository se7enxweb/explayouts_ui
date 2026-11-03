{* admin: the template editor (explayouts_ui/template_editor) inside the administration's page: top menu, breadcrumb
   and the Layouts left menu come from the page layout, the title from the box header. The editor is
   design/standard's parts/template_editor_body.tpl (shared admin components, module CSS in
   stylesheets/explayouts_ui_template_editor.css, the script in javascript/explayouts_ui_template_editor.js). *}
{ezcss_require( 'explayouts_ui_template_editor.css' )}
{ezscript_require( 'explayouts_ui_template_editor.js' )}
<div class="context-block a4-page explayouts-te">

<div class="box-header"><div class="box-ml">
<h1 class="context-title">{'Template editor'|i18n( 'design/admin/explayouts_ui/template_editor' )}</h1>
</div></div>

<div class="box-bc"><div class="box-ml"><div class="box-content">
{include uri='design:explayouts_ui/parts/template_editor_body.tpl' editor_json=$editor_json template_count=$template_count designs=$designs design=$design siteaccesses=$siteaccesses siteaccess=$siteaccess groups=$groups selected_path=$selected_path can_edit=$can_edit allow_new_templates=$allow_new_templates}
</div></div></div>
</div>
