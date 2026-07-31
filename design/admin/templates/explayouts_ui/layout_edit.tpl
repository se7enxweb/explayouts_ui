{ezcss_load(array('netgen/layouts-admin.css','netgen/layouts-ibexa.css','nglayouts-ui.css'))}
{ezscript_load(array('netgen/layouts-admin.js','netgen/layouts-ibexa.js'))}
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
<div class="ng-layouts-app row">
    <div class="layouts-content">
        <div class="nl-edit-layout">
            <h2 class="layouts-title">{$layout.name|wash}</h2>

            {if $message}<div class="message-feedback">{$message|wash}</div>{/if}
            {if $error}<div class="message-error">{$error|wash}</div>{/if}

            <form method="post" action={concat('explayouts_ui/layout_edit/',$layout.id)|ezurl} class="nl-layout-form">
                <label>Identifier</label>
                <input type="text" name="Identifier" value="{$layout.identifier|wash}" />

                <label>Name</label>
                <input type="text" name="Name" value="{$layout.name|wash}" />

                <label>Layout type</label>
                <select name="LayoutType" class="nl-select">
                    <option value="">-- Select --</option>
                    {foreach $available_types as $typeInfo}
                        <option value="{$typeInfo.identifier|wash}" {if eq($layout.layout_type,$typeInfo.identifier)}selected="selected"{/if}>{$typeInfo.name|wash}</option>
                    {/foreach}
                </select>
                <em class="nl-hint">Selecting a type auto-creates zones on save.</em>

                <div class="nl-form-actions">
                    <button type="submit" name="SaveDraft" class="nl-btn"><i class="material-icons">save</i> Save draft</button>
                    <button type="submit" name="Publish" class="nl-btn nl-btn-primary"><i class="material-icons">publish</i> Publish</button>
                    <a class="nl-btn" href={'explayouts_ui/layout_list'|ezurl}>Cancel</a>
                </div>
            </form>

            <div class="nl-zones">
                <h3>Zones</h3>
                {if count($zones)}
                    {foreach $zones as $zoneEntry}
                        {def $zone=$zoneEntry.zone}
                        {def $blocks=$zoneEntry.blocks}
                        <div class="nl-zone">
                            <div class="nl-zone-header">
                                <h4>{$zone.identifier|wash}</h4>
                                <form method="post" action={concat('explayouts_ui/layout_edit/',$layout.id)|ezurl} style="display:inline;margin:0;">
                                    <input type="hidden" name="DeleteZoneID" value="{$zone.id|wash}" />
                                    <button type="submit" name="DeleteZone" class="nl-btn nl-btn-small" onclick="return confirm('Delete this zone and all its blocks?');"><i class="material-icons">delete</i> Delete zone</button>
                                </form>
                            </div>

                            {if count($blocks)}
                                <div class="nl-blocks">
                                    {foreach $blocks as $block}
                                        <div class="nl-block-row">
                                            <span class="nl-block-name">{$block.name|wash}</span>
                                            <span class="nl-block-type">{$block.definition_identifier|wash}</span>
                                            <div class="nl-block-actions">
                                                <a class="nl-btn nl-btn-small" href={concat('explayouts_ui/block_edit/',$block.id)|ezurl}><i class="material-icons">edit</i> Edit</a>
                                                <form method="post" action={concat('explayouts_ui/layout_edit/',$layout.id)|ezurl} style="display:inline;margin:0;">
                                                    <input type="hidden" name="MoveBlockID" value="{$block.id|wash}" />
                                                    <button type="submit" name="MoveBlockUp" class="nl-btn nl-btn-small"><i class="material-icons">arrow_upward</i></button>
                                                    <button type="submit" name="MoveBlockDown" class="nl-btn nl-btn-small"><i class="material-icons">arrow_downward</i></button>
                                                </form>
                                                <form method="post" action={concat('explayouts_ui/layout_edit/',$layout.id)|ezurl} style="display:inline;margin:0;">
                                                    <input type="hidden" name="MoveBlockID" value="{$block.id|wash}" />
                                                    <select name="TargetZoneID" class="nl-select nl-select-small">
                                                        {foreach $zones as $z}
                                                            {if ne($z.zone.id,$zone.id)}
                                                                <option value="{$z.zone.id|wash}">{$z.zone.identifier|wash}</option>
                                                            {/if}
                                                        {/foreach}
                                                    </select>
                                                    <button type="submit" name="MoveBlockToZone" class="nl-btn nl-btn-small">Move</button>
                                                </form>
                                                <form method="post" action={concat('explayouts_ui/layout_edit/',$layout.id)|ezurl} style="display:inline;margin:0;">
                                                    <input type="hidden" name="DeleteBlockID" value="{$block.id|wash}" />
                                                    <button type="submit" name="DeleteBlock" class="nl-btn nl-btn-small" onclick="return confirm('Delete this block?');"><i class="material-icons">delete</i></button>
                                                </form>
                                            </div>
                                        </div>
                                    {/foreach}
                                </div>
                            {else}
                                <p class="nl-no-items">No blocks yet.</p>
                            {/if}

                            {if count($available_blocks)}
                                <form method="post" action={concat('explayouts_ui/layout_edit/',$layout.id)|ezurl} class="nl-add-block">
                                    <input type="hidden" name="ZoneID" value="{$zone.id|wash}" />
                                    <select name="DefinitionIdentifier" class="nl-select nl-select-small">
                                        {foreach $available_blocks as $blockInfo}
                                            <option value="{$blockInfo.identifier|wash}">{$blockInfo.name|wash}</option>
                                        {/foreach}
                                    </select>
                                    <button type="submit" name="AddBlock" class="nl-btn nl-btn-primary nl-btn-small"><i class="material-icons">add</i> Add block</button>
                                </form>
                            {/if}
                        </div>
                    {/foreach}
                {else}
                    <p class="nl-no-items">No zones yet. Choose a layout type and save to auto-create zones.</p>
                {/if}

                <form method="post" action={concat('explayouts_ui/layout_edit/',$layout.id)|ezurl} class="nl-add-zone">
                    <input type="text" name="ZoneIdentifier" value="" placeholder="zone identifier" />
                    <button type="submit" name="AddZone" class="nl-btn nl-btn-primary"><i class="material-icons">add</i> Add custom zone</button>
                </form>
            </div>
        </div>
    </div>
</div>
