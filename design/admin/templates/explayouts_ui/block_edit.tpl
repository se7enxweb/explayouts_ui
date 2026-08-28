<div class="context-block">
    <div class="box-header"><h1 class="context-title">Edit block</h1></div>
    <div class="box-ml">
        {if $message}<div class="message-feedback">{$message|wash}</div>{/if}
        {if $error}<div class="message-error">{$error|wash}</div>{/if}

        <form method="post" action={concat('explayouts_ui/block_edit/',$block.id)|ezurl}>
            <label>Name:</label>
            <input type="text" name="Name" value="{$block.name|wash}" size="60" /><br/><br/>

            <label>View type:</label>
            <select name="ViewType">
                {foreach $view_types as $vt}
                    <option value="{$vt|wash}" {if eq($block.view_type,$vt)}selected="selected"{/if}>{$vt|wash}</option>
                {/foreach}
            </select><br/><br/>

            {foreach $parameters as $name => $definition}
                {def $val=''}
                {if is_set($existing_params[$name])}{set $val=$existing_params[$name]}{/if}
                {if eq($definition.type,'textarea')}
                    <label>{$definition.name|wash}:</label>
                    <textarea name="Parameter_{$name|wash}" rows="10" cols="80">{$val|wash}</textarea>
                {elseif eq($definition.type,'integer')}
                    <label>{$definition.name|wash}:</label>
                    <input type="number" name="Parameter_{$name|wash}" value="{$val|wash}" size="20" />
                {else}
                    <label>{$definition.name|wash}:</label>
                    <input type="text" name="Parameter_{$name|wash}" value="{$val|wash}" size="60" />
                {/if}
                <br/><br/>
            {/foreach}

            {if $has_collection}
                {if $collection}
                    <h3>Collection</h3>
                    <label>Type:</label>
                    <select name="CollectionType">
                        <option value="manual" {if eq($collection.collection_type,'manual')}selected="selected"{/if}>Manual</option>
                        <option value="query" {if eq($collection.collection_type,'query')}selected="selected"{/if}>Query-based</option>
                    </select><br/><br/>

                    <label>Offset:</label>
                    <input type="number" name="CollectionOffset" value="{$collection.offset_value|wash}" size="10" /><br/><br/>

                    <label>Limit:</label>
                    <input type="number" name="CollectionLimit" value="{$collection.limit_value|wash}" size="10" /><br/><br/>
                {else}
                    <input type="hidden" name="CollectionType" value="manual" />
                    <input type="hidden" name="CollectionOffset" value="0" />
                    <input type="hidden" name="CollectionLimit" value="0" />
                {/if}
            {/if}

            <input class="defaultbutton" type="submit" name="SaveBlock" value="Save block" />
            <a class="button" href={concat('explayouts_ui_api/app#layout/',$block.layout_id)|ezurl}>Back to layout</a>
        </form>

        {if $has_collection}
            <hr/>
            {if $collection}
                <h3>Manual items</h3>
                {if count($collection_items)}
                    <table class="list" cellspacing="0">
                        <tr><th>Node ID</th><th>Position</th><th>&nbsp;</th></tr>
                        {foreach $collection_items as $item}
                            <tr>
                                <td>{$item.value_id|wash}</td>
                                <td>{$item.position|wash}</td>
                                <td>
                                    <form method="post" action={concat('explayouts_ui/block_edit/',$block.id)|ezurl} style="display:inline;margin:0;">
                                        <input type="hidden" name="CollectionItemID" value="{$item.id|wash}" />
                                        <button type="submit" name="RemoveCollectionItem" class="button">Remove</button>
                                    </form>
                                </td>
                            </tr>
                        {/foreach}
                    </table>
                {else}
                    <p>No items yet.</p>
                {/if}

                <form method="post" action={concat('explayouts_ui/block_edit/',$block.id)|ezurl}>
                    <label>Add item by Node ID:</label>
                    <input type="number" name="CollectionNodeID" value="" size="10" />
                    <button type="submit" name="AddCollectionItem" class="button">Add</button>
                </form>
            {else}
                <p>Save the block to create a collection.</p>
            {/if}
        {/if}
    </div>
</div>
