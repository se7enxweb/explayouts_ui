{ezcss_require(array('netgen/layouts-admin.css','netgen/layouts-exponential.css','explayouts-ui.css'))}
{* layouts-admin.js is not loaded: its content browser stops at once without Netgen's page tags, so none of it ever ran here, and these pages have their own scripts. *}
{ezscript_load(array('netgen/layouts-exponential.js'))}
<div class="ng-layouts-app row">
    <div class="layouts-content">
        <div class="layouts-import">
            <div class="layouts-header">
                <h2 class="layouts-title">{'Import'|i18n( 'design/admin/explayouts_ui/transfer_import' )}</h2>
                <p>{'Please choose a JSON file containing entities to import'|i18n( 'design/admin/explayouts_ui/transfer_import' )}</p>
            </div>
            {if $message}<div class="message-feedback">{$message|wash}</div>{/if}
            {if $error}<div class="message-error">{$error|wash}</div>{/if}
            <div class="layouts-form">
                <form name="import" method="post" action={'explayouts_ui/transfer_import'|ezurl} novalidate="novalidate" enctype="multipart/form-data">
                    <div class="row-input file-input-group">
                        <label class="nl-btn nl-btn-primary nl-btn-with-icon required" for="import_file">{'Select file'|i18n( 'design/admin/explayouts_ui/transfer_import' )}</label>
                        <span class="filename">{'(No file selected)'|i18n( 'design/admin/explayouts_ui/transfer_import' )}</span>
                        <input type="file" id="import_file" name="import[file]" required="required">
                    </div>
                    <div class="row-input">
                        <label class="required">{'Import mode'|i18n( 'design/admin/explayouts_ui/transfer_import' )}</label>
                        <div id="import_import_mode">
                            <input type="radio" id="import_import_mode_0" name="import[import_mode]" required="required" value="copy" checked="checked">
                            <label for="import_import_mode_0" class="required">{'Copy existing entities'|i18n( 'design/admin/explayouts_ui/transfer_import' )}</label>
                            <input type="radio" id="import_import_mode_1" name="import[import_mode]" required="required" value="overwrite">
                            <label for="import_import_mode_1" class="required">{'Overwrite existing entities'|i18n( 'design/admin/explayouts_ui/transfer_import' )}</label>
                            <input type="radio" id="import_import_mode_2" name="import[import_mode]" required="required" value="skip">
                            <label for="import_import_mode_2" class="required">{'Skip existing entities'|i18n( 'design/admin/explayouts_ui/transfer_import' )}</label>
                        </div>
                    </div>
                    <div class="form-actions">
                        <button type="submit" class="nl-btn nl-btn-primary">{'Import'|i18n( 'design/admin/explayouts_ui/transfer_import' )}</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
