{ezcss_load(array('nglayouts-ui.css'))}
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<div class="context-block">
    <div class="box-header"><h1 class="context-title">Exponential Layouts Dashboard</h1></div>
    <div class="box-ml">
        <table class="list" cellspacing="0">
            <tr>
                <th>Resource</th>
                <th>Count</th>
            </tr>
            <tr>
                <td>Layouts</td>
                <td>{$counts.layouts|wash}</td>
            </tr>
            <tr>
                <td>Zones</td>
                <td>{$counts.zones|wash}</td>
            </tr>
            <tr>
                <td>Blocks</td>
                <td>{$counts.blocks|wash}</td>
            </tr>
            <tr>
                <td>Rules</td>
                <td>{$counts.rules|wash}</td>
            </tr>
            <tr>
                <td>Collections</td>
                <td>{$counts.collections|wash}</td>
            </tr>
        </table>

        <h3>Recent layouts</h3>
        {if count($recent_layouts)}
            <table class="list" cellspacing="0">
                <tr><th>ID</th><th>Name</th><th>Identifier</th><th>Modified</th></tr>
                {foreach $recent_layouts as $layout}
                    <tr>
                        <td>{$layout.id|wash}</td>
                        <td><a href={concat('explayouts_ui/layout_edit/',$layout.id)|ezurl}>{$layout.name|wash}</a></td>
                        <td>{$layout.identifier|wash}</td>
                        <td>{$layout.modified|datetime( 'custom', '%Y-%m-%d %H:%M' )}</td>
                    </tr>
                {/foreach}
            </table>
        {else}
            <p>No layouts yet.</p>
        {/if}

        <div class="controlbar">
            <a class="button" href={'explayouts_ui/layout_list'|ezurl}>Layouts</a>
            <a class="button" href={'explayouts_ui/rule_list'|ezurl}>Rules</a>
            <a class="button" href={'explayouts_ui/template_editor/'|ezurl}>Template editor</a>
            <a class="button" href={'explayouts_ui/setup'|ezurl}>Setup DB</a>
        </div>
    </div>
</div>
