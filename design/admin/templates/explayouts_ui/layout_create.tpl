{ezcss_load(array('netgen/layouts-admin.css','netgen/layouts-ibexa.css','nglayouts-ui.css'))}
{ezscript_load(array('netgen/layouts-admin.js','netgen/layouts-ibexa.js'))}
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
<div class="ng-layouts-app row">
    <div class="layouts-content">
        <div class="nl-create-layout">
            <h2 class="layouts-title">New layout</h2>
            <form method="post" action={'explayouts_ui/layout_create'|ezurl}>
                <label>Layout type</label>
                <div class="layout-types">
                    {foreach $available_types as $type}
                        <label class="layout-type-option">
                            <input type="radio" name="LayoutType" value="{$type.identifier|wash}" {if eq($type.identifier,$available_types.0.identifier)}checked="checked"{/if} />
                            <span class="layout-type-thumb"><span class="layout-icon" style="background-color:#a1a1a1;"></span></span>
                            <span class="layout-type-name">{$type.name|wash}</span>
                        </label>
                    {/foreach}
                </div>

                <label for="layout-name">Name</label>
                <input id="layout-name" type="text" name="Name" value="" required="required" />

                <label for="layout-identifier">Identifier (optional)</label>
                <input id="layout-identifier" type="text" name="Identifier" value="" />

                <label for="layout-description">Description</label>
                <textarea id="layout-description" name="Description" rows="4"></textarea>

                <div class="nl-form-actions">
                    <a class="nl-btn" href={'explayouts_ui/layout_list'|ezurl}>Cancel</a>
                    <button class="nl-btn nl-btn-primary" type="submit" name="CreateLayout">Create layout</button>
                </div>
            </form>
        </div>
    </div>
</div>
