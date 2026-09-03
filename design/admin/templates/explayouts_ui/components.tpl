{ezcss_load(array('netgen/layouts-admin.css','netgen/layouts-ibexa.css','nglayouts-ui.css'))}
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
{literal}<style>
.components-content { padding: 1.5rem; }
.layouts-header { display: flex; justify-content: space-between; align-items: center; gap: 16px; margin-bottom: 1.5rem; }
.layouts-title { margin: 0; font-size: 1.75rem; font-weight: 500; }
.nl-components-filter-form { display: flex; flex-wrap: wrap; gap: 1.5rem; align-items: flex-end; margin-bottom: 1.5rem; padding: 1rem; background: #f8f9fa; border: 1px solid #e0e0e0; border-radius: 4px; }
.nl-components-filter-form .row-title { font-size: 0.875rem; font-weight: 600; text-transform: uppercase; margin: 0 0 0.5rem; color: #666; }
.nl-components-filter-form .row-input { display: flex; gap: 1rem; flex-wrap: wrap; }
.nl-components-filter-form label { display: block; font-size: 0.8125rem; color: #555; margin-bottom: 0.25rem; }
.nl-components-filter-form select,
.nl-components-filter-form input[type="checkbox"] + label { font-size: 0.875rem; }
.nl-components-filter-form select { padding: 0.375rem 0.5rem; border: 1px solid #ccc; border-radius: 2px; min-width: 160px; background: #fff; }
.nl-components-filter-form .checkbox { display: flex; align-items: center; gap: 0.5rem; }
.nl-components-filter-form .checkbox input { margin: 0; }
.nl-components-filter-form .checkbox label { margin: 0; color: #333; }
.nl-components-filter-form .form-actions { margin-left: auto; }
.nl-btn-primary { background: #FED82F; border: 1px solid #FED82F; color: #1a1a1a; padding: 0.5rem 1rem; font-weight: 500; border-radius: 2px; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 0.25rem; }
.nl-btn-primary:hover { background: #e8c42a; }
.nl-components-list { list-style: none; margin: 0; padding: 0; border: 1px solid #e0e0e0; border-radius: 4px; overflow: hidden; }
.nl-component { display: grid; grid-template-columns: minmax(220px, 1.5fr) minmax(140px, 1fr) 140px 70px minmax(220px, 1.5fr); gap: 1rem; align-items: start; padding: 0.75rem 1rem; border-bottom: 1px solid #e0e0e0; background: #fff; }
.nl-component:last-child { border-bottom: none; }
.nl-component-header { background: #f5f5f5; font-weight: 600; font-size: 0.8125rem; color: #555; text-transform: uppercase; padding: 0.5rem 1rem; }
.nl-component__name a { color: #1a1a1a; text-decoration: none; font-weight: 500; }
.nl-component__name a:hover { text-decoration: underline; }
.nl-component__content-type { color: #666; }
.nl-component__last-modified { color: #666; white-space: nowrap; }
.nl-component__usage-count { text-align: center; }
.nl-component__used-in { display: flex; flex-direction: column; gap: 0.25rem; }
.used-in-item { display: flex; gap: 0.75rem; align-items: baseline; }
.used-in-item-name a { color: #1a1a1a; text-decoration: none; }
.used-in-item-name a:hover { text-decoration: underline; }
.used-in-item-style { color: #888; font-size: 0.875rem; }
.nl-no-items { padding: 2rem; text-align: center; color: #666; background: #fff; border: 1px solid #e0e0e0; border-radius: 4px; }
</style>{/literal}
<div class="ng-layouts-app row">
    <div class="layouts-content components-content">
        <div class="layouts-header">
            <h2 class="layouts-title">Components</h2>
        </div>

        <form method="get" class="layouts-form nl-components-filter-form">
            <div class="filter">
                <h3 class="row-title">Filter</h3>
                <div class="row-input">
                    <div>
                        <label for="component_filter_contentType">Content type</label>
                        <select id="component_filter_contentType" name="component_filter[contentType]">
                            <option value="" {if eq($filter_content_type, '')}selected="selected"{/if}>All content types</option>
                            {foreach $component_classes as $identifier => $class}
                                <option value="{$identifier|wash}" {if eq($filter_content_type, $identifier)}selected="selected"{/if}>{$class.name|wash}</option>
                            {/foreach}
                        </select>
                    </div>
                    <div class="checkbox">
                        <input type="checkbox" id="component_filter_showOnlyUnused" name="component_filter[showOnlyUnused]" value="1" {if $filter_show_only_unused}checked="checked"{/if} />
                        <label for="component_filter_showOnlyUnused">Show only unused</label>
                    </div>
                </div>
            </div>

            <div class="sort">
                <h3 class="row-title">Sort</h3>
                <div class="row-input">
                    <div>
                        <label for="component_filter_sortType">Sort type</label>
                        <select id="component_filter_sortType" name="component_filter[sortType]">
                            <option value="name" {if eq($sort_type, 'name')}selected="selected"{/if}>Name</option>
                            <option value="last_modified" {if eq($sort_type, 'last_modified')}selected="selected"{/if}>Last modified</option>
                        </select>
                    </div>
                    <div>
                        <label for="component_filter_sortDirection">Sort direction</label>
                        <select id="component_filter_sortDirection" name="component_filter[sortDirection]">
                            <option value="ascending" {if eq($sort_direction, 'ascending')}selected="selected"{/if}>Ascending</option>
                            <option value="descending" {if eq($sort_direction, 'descending')}selected="selected"{/if}>Descending</option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="form-actions">
                <button type="submit" class="nl-btn nl-btn-primary">Submit</button>
            </div>
        </form>

        <div class="nl-components">
            {if $components|count}
                <ul class="nl-components-list">
                    <li class="nl-component nl-component-header">
                        <div class="nl-component__name">Name</div>
                        <div class="nl-component__content-type">Content type</div>
                        <div class="nl-component__last-modified">Last modified</div>
                        <div class="nl-component__usage-count">Count</div>
                        <div class="nl-component__used-in">Used in</div>
                    </li>
                    {foreach $components as $component}
                        <li class="nl-component">
                            <div class="nl-component__name" data-cell-title="Name">
                                <a href={concat('content/edit/', $component.id)|ezurl} target="_blank">{$component.name|wash}</a>
                            </div>
                            <div class="nl-component__content-type" data-cell-title="Content type">{$component.class_name|wash}</div>
                            <div class="nl-component__last-modified" data-cell-title="Last modified">{$component.modified|datetime( 'custom', '%M %d, %Y, %h:%i:%s %A' )}</div>
                            <div class="nl-component__usage-count" data-cell-title="Count">{$component.count}</div>
                            <div class="nl-component__used-in" data-cell-title="Used in">
                                {if $component.usages|count}
                                    {foreach $component.usages as $usage}
                                        <div class="used-in-item">
                                            <span class="used-in-item-name"><a href={concat('explayouts_ui_api/app#layout/', $usage.layout_id)|ezurl} target="_blank">{$usage.layout_name|wash}</a></span>
                                            <span class="used-in-item-style">{$usage.style_name|wash}</span>
                                        </div>
                                    {/foreach}
                                {else}
                                    <span class="used-in-item-style">Not used</span>
                                {/if}
                            </div>
                        </li>
                    {/foreach}
                </ul>
            {else}
                <p class="nl-no-items">There are no components matching the selected filters.</p>
            {/if}
        </div>
    </div>
</div>
