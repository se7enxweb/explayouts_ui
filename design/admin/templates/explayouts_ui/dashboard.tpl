{ezcss_load(array('netgen/layouts-admin.css','netgen/layouts-ibexa.css','nglayouts-ui.css'))}
{ezscript_load(array('netgen/layouts-admin.js','netgen/layouts-ibexa.js'))}
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">

{literal}<style>
.nl-dashboard-stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 12px; margin-bottom: 24px; }
.nl-stat-card { background: #fff; border: 1px solid #e0e0e0; border-radius: 4px; padding: 16px; text-align: center; }
.nl-stat-card .nl-stat-value { font-size: 28px; font-weight: 500; color: #333; line-height: 1; margin-bottom: 6px; }
.nl-stat-card .nl-stat-label { font-size: 12px; text-transform: uppercase; color: #777; letter-spacing: 0.04em; }
.nl-recent-table { width: 100%; border-collapse: collapse; margin-bottom: 24px; }
.nl-recent-table th,
.nl-recent-table td { text-align: left; padding: 10px 8px; border-bottom: 1px solid #e0e0e0; }
.nl-recent-table th { font-size: 12px; text-transform: uppercase; color: #777; font-weight: 500; }
.nl-recent-table td { font-size: 13px; color: #333; }
.nl-recent-table .nl-status-label { display: inline-block; padding: 2px 6px; border-radius: 12px; font-size: 10px; font-weight: 500; text-transform: uppercase; background: #f5f5f5; color: #777; }
.nl-recent-table .nl-status-label.published { background: #e6f5e6; color: #2e7d32; }
</style>{/literal}

<div class="ng-layouts-app">
    <div class="layouts-content">
        <div class="layouts-header">
            <h2 class="layouts-title">Layouts Dashboard</h2>
            <div class="layouts-controls">
                <a href={concat('explayouts_ui_api/app#layout')|ezurl} class="nl-btn nl-btn-primary">
                    <i class="material-icons">add</i> New layout
                </a>
                <a href={concat('explayouts_ui/layout_list')|ezurl} class="nl-btn">
                    <i class="material-icons">view_list</i> Layouts
                </a>
                <a href={concat('explayouts_ui/rule_list')|ezurl} class="nl-btn">
                    <i class="material-icons">link</i> Rules
                </a>
                <a href={concat('explayouts_ui/template_editor/')|ezurl} class="nl-btn">
                    <i class="material-icons">code</i> Template editor
                </a>
                <a href={concat('explayouts_ui/setup')|ezurl} class="nl-btn">
                    <i class="material-icons">build</i> Setup DB
                </a>
            </div>
        </div>

        <div class="nl-dashboard-stats">
            <div class="nl-stat-card">
                <div class="nl-stat-value">{$counts.layouts|wash}</div>
                <div class="nl-stat-label">Layouts</div>
            </div>
            <div class="nl-stat-card">
                <div class="nl-stat-value">{$counts.zones|wash}</div>
                <div class="nl-stat-label">Zones</div>
            </div>
            <div class="nl-stat-card">
                <div class="nl-stat-value">{$counts.blocks|wash}</div>
                <div class="nl-stat-label">Blocks</div>
            </div>
            <div class="nl-stat-card">
                <div class="nl-stat-value">{$counts.rules|wash}</div>
                <div class="nl-stat-label">Rules</div>
            </div>
            <div class="nl-stat-card">
                <div class="nl-stat-value">{$counts.collections|wash}</div>
                <div class="nl-stat-label">Collections</div>
            </div>
        </div>

        <h3 class="layouts-title" style="font-size:18px;margin-bottom:12px;">Recent layouts</h3>

        {if count($recent_layouts)}
            <table class="nl-recent-table" cellspacing="0">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Identifier</th>
                        <th>Status</th>
                        <th>Modified</th>
                        <th style="width:160px;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $recent_layouts as $layout}
                        <tr>
                            <td>{$layout.name|wash}</td>
                            <td>{$layout.identifier|wash}</td>
                            <td>
                                {if eq($layout.status,2)}
                                    <span class="nl-status-label published">Published</span>
                                {else}
                                    <span class="nl-status-label">Draft</span>
                                {/if}
                            </td>
                            <td>{$layout.modified|datetime( 'custom', '%Y-%m-%d %H:%M' )}</td>
                            <td>
                                <a href={concat('explayouts_ui_api/app#layout/',$layout.id)|ezurl} class="nl-btn nl-btn-small">
                                    <i class="material-icons" style="font-size:18px;">open_in_new</i> Open
                                </a>
                            </td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        {else}
            <p class="nl-no-items">There are no layouts yet</p>
        {/if}
    </div>
</div>
