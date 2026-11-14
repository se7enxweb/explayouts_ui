{* admin4: Edit block (explayouts_ui/block_edit): its settings and parameters, then its collection. Same fields and
   button names as design/admin's template. *}
{ezcss_require( 'explayouts_ui_admin4.css' )}
<div class="context-block a4-page explayouts-a4">

<div class="box-header"><div class="box-ml">
<h1 class="context-title">{'Edit block'|i18n( 'design/admin/explayouts_ui/block_edit' )}</h1>
</div></div>

<div class="box-bc"><div class="box-ml"><div class="box-content">

{if $message}<div class="a4-notice is-ok" role="status">{$message|wash}</div>{/if}
{if $error}<div class="a4-notice is-bad" role="alert">{$error|wash}</div>{/if}

<form class="a4-form is-wide" method="post" action={concat( 'explayouts_ui/block_edit/', $block.id )|ezurl}>
    <div class="a4-field">
        <label class="a4-label" for="block-name">{'Name:'|i18n( 'design/admin/explayouts_ui/block_edit' )}</label>
        <input class="a4-input" id="block-name" type="text" name="Name" value="{$block.name|wash}" />
    </div>
    <div class="a4-field">
        <label class="a4-label" for="block-view-type">{'View type:'|i18n( 'design/admin/explayouts_ui/block_edit' )}</label>
        <select class="a4-input" id="block-view-type" name="ViewType">
        {foreach $view_types as $vt}<option value="{$vt|wash}"{if eq( $block.view_type, $vt )} selected="selected"{/if}>{$vt|wash}</option>{/foreach}
        </select>
    </div>
    {* Item view types: every view type offers all of them (the handler's list and ItemViewTypes[]); '' is the view
       type's own, and a stored one the list does not offer stays selected. *}
    {if or( $item_view_types|count, ne( $block.item_view_type, '' ) )}
    <div class="a4-field">
        <label class="a4-label" for="block-item-view-type">{'Item view type:'|i18n( 'design/admin/explayouts_ui/block_edit' )}</label>
        <select class="a4-input" id="block-item-view-type" name="ItemViewType">
        <option value=""{if eq( $block.item_view_type, '' )} selected="selected"{/if}>{'Default of the view type'|i18n( 'design/admin/explayouts_ui/block_edit' )}</option>
        {foreach $item_view_types as $ivt => $ivt_label}<option value="{$ivt|wash}"{if eq( $block.item_view_type, $ivt )} selected="selected"{/if}>{$ivt_label|wash}</option>{/foreach}
        {if and( ne( $block.item_view_type, '' ), is_set( $item_view_types[$block.item_view_type] )|not )}<option value="{$block.item_view_type|wash}" selected="selected">{$block.item_view_type|wash}</option>{/if}
        </select>
    </div>
    {/if}
    {foreach $parameters as $name => $definition}
        {def $val = cond( is_set( $existing_params[$name] ), $existing_params[$name], '' )}
        <div class="a4-field{if eq( $definition.type, 'textarea' )} a4-field-wide{/if}">
            <label class="a4-label" for="block-param-{$name|wash}">{$definition.name|wash}</label>
            {if eq( $definition.type, 'textarea' )}
            <textarea class="a4-input" id="block-param-{$name|wash}" name="Parameter_{$name|wash}" rows="10">{$val|wash}</textarea>
            {elseif eq( $definition.type, 'integer' )}
            <input class="a4-input is-auto" id="block-param-{$name|wash}" type="number" name="Parameter_{$name|wash}" value="{$val|wash}" />
            {else}
            <input class="a4-input" id="block-param-{$name|wash}" type="text" name="Parameter_{$name|wash}" value="{$val|wash}" />
            {/if}
        </div>
        {undef $val}
    {/foreach}
    {if $has_collection}
        {if $collection}
        <fieldset class="a4-field a4-field-wide">
            <legend class="a4-label">{'Collection'|i18n( 'design/admin/explayouts_ui/block_edit' )}</legend>
            <div class="a4-row">
                <label class="a4-label" for="collection-type">{'Type:'|i18n( 'design/admin/explayouts_ui/block_edit' )}</label>
                <select class="a4-input is-auto" id="collection-type" name="CollectionType">
                    <option value="manual"{if eq( $collection.collection_type, 'manual' )} selected="selected"{/if}>{'Manual'|i18n( 'design/admin/explayouts_ui/block_edit' )}</option>
                    <option value="query"{if eq( $collection.collection_type, 'query' )} selected="selected"{/if}>{'Query-based'|i18n( 'design/admin/explayouts_ui/block_edit' )}</option>
                </select>
                <label class="a4-label" for="collection-offset">{'Offset:'|i18n( 'design/admin/explayouts_ui/block_edit' )}</label>
                <input class="a4-input is-auto" id="collection-offset" type="number" name="CollectionOffset" value="{$collection.offset_value|wash}" />
                <label class="a4-label" for="collection-limit">{'Limit:'|i18n( 'design/admin/explayouts_ui/block_edit' )}</label>
                <input class="a4-input is-auto" id="collection-limit" type="number" name="CollectionLimit" value="{$collection.limit_value|wash}" />
            </div>
        </fieldset>
        {else}
        <input type="hidden" name="CollectionType" value="manual" />
        <input type="hidden" name="CollectionOffset" value="0" />
        <input type="hidden" name="CollectionLimit" value="0" />
        {/if}
    {/if}
    <div class="a4-actions">
        <button class="a4-btn a4-btn-primary" type="submit" name="SaveBlock">{'Save block'|i18n( 'design/admin/explayouts_ui/block_edit' )}</button>
        <a class="a4-btn" href={concat( 'explayouts_ui_api/app#layout/', $block.layout_id )|ezurl}>{'Back to layout'|i18n( 'design/admin/explayouts_ui/block_edit' )}</a>
    </div>
</form>

{if $has_collection}
<section class="a4-section" aria-labelledby="block-items-title">
    {if $collection}
    <div class="a4-section-head"><h2 class="a4-h2" id="block-items-title">{'Manual items'|i18n( 'design/admin/explayouts_ui/block_edit' )}</h2></div>
    {if count( $collection_items )}
    <div class="a4-table-wrap"><table class="a4-table is-compact">
        <thead><tr><th scope="col">{'Node ID'|i18n( 'design/admin/explayouts_ui/block_edit' )}</th><th scope="col">{'Position'|i18n( 'design/admin/explayouts_ui/block_edit' )}</th><th scope="col"><span class="a4-sr-only">{'Remove'|i18n( 'design/admin/explayouts_ui/block_edit' )}</span></th></tr></thead>
        <tbody>
        {foreach $collection_items as $item}
        <tr>
            <td class="a4-num">{$item.value_id|wash}</td>
            <td class="a4-num">{$item.position|wash}</td>
            <td class="a4-end">
                <form method="post" action={concat( 'explayouts_ui/block_edit/', $block.id )|ezurl} class="explayouts-a4-inline-form">
                    <input type="hidden" name="CollectionItemID" value="{$item.id|wash}" />
                    <button type="submit" name="RemoveCollectionItem" class="a4-btn a4-btn-small a4-btn-outline-danger">{'Remove'|i18n( 'design/admin/explayouts_ui/block_edit' )}</button>
                </form>
            </td>
        </tr>
        {/foreach}
        </tbody>
    </table></div>
    {else}
    <p class="a4-muted">{'No items yet.'|i18n( 'design/admin/explayouts_ui/block_edit' )}</p>
    {/if}
    <form method="post" action={concat( 'explayouts_ui/block_edit/', $block.id )|ezurl} class="a4-row explayouts-a4-add">
        <label class="a4-label" for="collection-node-id">{'Add item by Node ID:'|i18n( 'design/admin/explayouts_ui/block_edit' )}</label>
        <input class="a4-input is-auto" id="collection-node-id" type="number" name="CollectionNodeID" value="" />
        <button type="submit" name="AddCollectionItem" class="a4-btn a4-btn-small">{'Add'|i18n( 'design/admin/explayouts_ui/block_edit' )}</button>
    </form>
    {else}
    <p class="a4-muted">{'Save the block to create a collection.'|i18n( 'design/admin/explayouts_ui/block_edit' )}</p>
    {/if}
</section>
{/if}

</div></div></div>
</div>
