{ezcss_require(array('netgen/layouts-admin.css','netgen/layouts-exponential.css','explayouts-ui.css'))}
{* layouts-admin.js is not loaded: its content browser stops at once without Netgen's page tags, so none of it ever ran here, and these pages have their own scripts. *}
{ezscript_load(array('netgen/layouts-exponential.js'))}
<div class="ng-layouts-app row">
    <div class="layouts-content">
        <div class="nl-create-layout">
            <h2 class="layouts-title">{'New layout'|i18n( 'design/admin/explayouts_ui/layout_create' )}</h2>
            <form method="post" action={'explayouts_ui/layout_create'|ezurl}>
                <label>{'Layout type'|i18n( 'design/admin/explayouts_ui/layout_create' )}</label>
                <div class="layout-types">
                    {foreach $available_types as $type}
                        <label class="layout-type-option">
                            <input type="radio" name="LayoutType" value="{$type.identifier|wash}" {if eq($type.identifier,$available_types.0.identifier)}checked="checked"{/if} />
                            <span class="layout-type-thumb"><span class="layout-icon" style="background-color:#a1a1a1;"></span></span>
                            <span class="layout-type-name">{$type.name|wash}</span>
                        </label>
                    {/foreach}
                </div>

                <label for="layout-name">{'Name'|i18n( 'design/admin/explayouts_ui/layout_create' )}</label>
                <input id="layout-name" type="text" name="Name" value="" required="required" />

                <label for="layout-identifier">{'Identifier (optional)'|i18n( 'design/admin/explayouts_ui/layout_create' )}</label>
                <input id="layout-identifier" type="text" name="Identifier" value="" />

                <label for="layout-description">{'Description'|i18n( 'design/admin/explayouts_ui/layout_create' )}</label>
                <textarea id="layout-description" name="Description" rows="4"></textarea>

                <div class="nl-form-actions">
                    <a class="nl-btn" href={'explayouts_ui/layout_list'|ezurl}>{'Cancel'|i18n( 'design/admin/explayouts_ui/layout_create' )}</a>
                    <button class="nl-btn nl-btn-primary" type="submit" name="CreateLayout">{'Create layout'|i18n( 'design/admin/explayouts_ui/layout_create' )}</button>
                </div>
            </form>
        </div>
    </div>
</div>
