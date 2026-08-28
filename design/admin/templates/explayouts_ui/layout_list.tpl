{ezcss_load(array('netgen/layouts-admin.css','netgen/layouts-ibexa.css','nglayouts-ui.css'))}
{ezscript_load(array('netgen/layouts-admin.js','netgen/layouts-ibexa.js'))}
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
{literal}<style>
.nl-layout-type { text-align: center; width: 110px; flex-shrink: 0; }
.nl-layout-type p { margin: 6px 0 0; font-size: 12px; color: #666; text-transform: uppercase; letter-spacing: 0.03em; }
.nl-layout-icon { border: 0px solid #a1a1a1; padding: 4px; margin-bottom: 6px; opacity: .65; }
.nl-layout-icon svg { width: 84px; height: 63px; display: block; }
.nl-layout-info { align-items: flex-start; gap: 18px; }
.nl-layout-text {
  min-width: 0;
  padding-top: 2px;
  padding-left: 13px;
}
.nl-layout-name { line-height: 1.3; margin: 0 0 2px 0; }
.nl-layout-description { margin-bottom: 2px; }
.nl-dropdown { display: inline-block !important; opacity: 1 !important; visibility: visible !important; }
.nl-dropdown-toggle { visibility: visible !important; }
</style>{/literal}
<div class="ng-layouts-app row">
    <div class="layouts-content">
        <div id="layouts" class="nl-layouts-view-grid" style="display: block;">
            <div class="layouts-header">
                <h2 class="layouts-title">Layouts</h2>
                <div class="layouts-controls">
                    <a style="display: none" href="#" class="nl-btn js-export">Export</a>
                    <a href="#" class="nl-btn js-change-layouts-view" style="display: none;"></a>
                    <a href={concat('explayouts_ui_api/app#layout')|ezurl} id="add-new-button" class="nl-btn nl-btn-primary js-open-ngl">
                        <i class="material-icons">add</i> New layout
                    </a>
                    <div class="layout-sorting-controls">
                        <label for="layout-sorting-sort"><i class="material-icons">sort_by_alpha</i></label>
                        <select id="layout-sorting-sort" class="nl-select">
                            <option value="name">Name</option>
                            <option value="description">Description</option>
                            <option value="modified">Last modified</option>
                            <option value="type">Layout type</option>
                            <option value="mappings">Mappings</option>
                        </select>
                        <select id="layout-sorting-direction" class="nl-select">
                            <option value="asc">Ascending</option>
                            <option value="desc">Descending</option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="nl-layouts-head" style="display: none;">
                <div class="nl-layout-info">
                    <div class="nl-layout-type"><a class="js-reorder-layouts" data-sorting="type">Layout type<i class="sort-icon"></i></a></div>
                    <div class="nl-layout-text">
                        <div class="nl-layout-name"><div class="nl-export-checkbox"><input type="checkbox" id="toggleSelectAll"><label for="toggleSelectAll"></label></div><a class="js-reorder-layouts active sorting-asc" data-sorting="name">Name<i class="sort-icon"></i></a></div>
                        <div class="nl-layout-description"><a class="js-reorder-layouts" data-sorting="description">Description<i class="sort-icon"></i></a></div>
                        <div class="nl-layout-modified"><a class="js-reorder-layouts" data-sorting="modified">Last modified<i class="sort-icon"></i></a></div>
                    </div>
                </div>
                <div class="nl-layout-actions">
                    <div class="nl-layout-data"><a class="js-reorder-layouts" data-sorting="mappings">Mappings<i class="sort-icon"></i></a></div>
                </div>
            </div>

            {if $message}<div class="message-feedback">{$message|wash}</div>{/if}
            {if $error}<div class="message-error">{$error|wash}</div>{/if}

            <div class="nl-layouts">
                {foreach $layouts as $layout}
                    <div class="nl-layout" data-name="{$layout.name|wash}" data-identifier="{$layout.identifier|wash}" data-description="{$layout.identifier|wash}" data-modified="{$layout.modified}" data-type="{$layout.layout_type|wash}" data-mappings="{if is_set($mappings_count[$layout.id])}{$mappings_count[$layout.id]}{else}0{/if}">
                        <div class="nl-layout-content">
                            <div class="nl-layout-info">
                                <div class="nl-layout-type">
                                    <p>{$layout.layout_type|wash}</p>
                                    <span class="nl-layout-icon">{$layout_type_icons[$layout.layout_type]}</span>
                                </div>
                                <div class="nl-layout-text">
                                    <div class="nl-layout-name"><a href={concat('explayouts_ui_api/app#layout/',$layout.id)|ezurl}>{$layout.name|wash}</a></div>
                                    <div class="nl-layout-description">{$layout.identifier|wash}</div>
                                    <div class="nl-layout-modified"><p>{$layout.modified|datetime( 'custom', '%Y-%m-%d %H:%M' )}</p></div>
                                    {if ne($layout.status,2)}<span class="unpublished-label">Draft</span>{/if}
                                </div>
                            </div>
                            <div class="nl-layout-actions">
                                <div class="nl-layout-data">
                                    <div class="meta-info">
                                        <i class="material-icons">link</i>
                                        <span>{if is_set($mappings_count[$layout.id])}{$mappings_count[$layout.id]}{else}0{/if} mappings</span>
                                    </div>
                                </div>
                                <div class="nl-dropdown" data-position="right">
                                    <button class="nl-btn nl-dropdown-toggle" type="button"><i class="material-icons">more_horiz</i></button>
                                    <ul class="nl-dropdown-menu main-dropdown">
                                        <li><a href={concat('explayouts_ui/layout_preview/',$layout.id,'/',$layout.status)|ezurl} target="_blank"><i class="material-icons" style="font-size:18px;vertical-align:middle;margin-right:4px;">visibility</i> Preview</a></li>
                                        <li>
                                            <form method="post" action={'explayouts_ui/layout_list'|ezurl} style="display:inline;margin:0;" onsubmit="return confirm('Delete this layout and all its zones/blocks?');">
                                                <input type="hidden" name="DeleteLayoutID" value="{$layout.id|wash}" />
                                                <button type="submit" name="DeleteLayout" style="display:block;width:100%;text-align:left;border:0;background:transparent;cursor:pointer;padding:.6em 1em;">Delete</button>
                                            </form>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                {/foreach}
            </div>

            {if count($layouts)|eq(0)}
                <p class="nl-no-items" style="display: block;">There are no layouts defined</p>
            {/if}
        </div>
    </div>
</div>
{literal}
<script>
(function(){
    var sortSelect = document.getElementById('layout-sorting-sort');
    var dirSelect = document.getElementById('layout-sorting-direction');
    function sortLayouts() {
        var sort = sortSelect.value;
        var dir = dirSelect.value;
        var container = document.querySelector('.nl-layouts');
        if (!container) return;
        var cards = Array.prototype.slice.call(container.children);
        cards.sort(function(a, b) {
            var av = a.getAttribute('data-' + sort) || '';
            var bv = b.getAttribute('data-' + sort) || '';
            if (sort === 'modified' || sort === 'mappings') {
                av = parseInt(av) || 0;
                bv = parseInt(bv) || 0;
            } else {
                av = av.toLowerCase();
                bv = bv.toLowerCase();
            }
            if (av < bv) return -1;
            if (av > bv) return 1;
            return 0;
        });
        if (dir === 'desc') cards.reverse();
        for (var k = 0; k < cards.length; k++) {
            container.appendChild(cards[k]);
        }
    }
    if (sortSelect) sortSelect.addEventListener('change', sortLayouts);
    if (dirSelect) dirSelect.addEventListener('change', sortLayouts);

    var toggles = document.querySelectorAll('.nl-dropdown-toggle');
    for (var i = 0; i < toggles.length; i++) {
        toggles[i].addEventListener('click', function(e){
            e.preventDefault();
            e.stopPropagation();
            var dd = this.parentNode;
            var active = /\bnl-dropdown-active\b/.test(dd.className);
            var all = document.querySelectorAll('.nl-dropdown.nl-dropdown-active');
            for (var j = 0; j < all.length; j++) {
                if (all[j] !== dd) all[j].className = all[j].className.replace(/\bnl-dropdown-active\b/g, '').trim();
            }
            if (!active) {
                dd.className += ' nl-dropdown-active';
            } else {
                dd.className = dd.className.replace(/\bnl-dropdown-active\b/g, '').trim();
            }
        });
    }
    document.addEventListener('click', function(){
        var all = document.querySelectorAll('.nl-dropdown.nl-dropdown-active');
        for (var j = 0; j < all.length; j++) {
            all[j].className = all[j].className.replace(/\bnl-dropdown-active\b/g, '').trim();
        }
    });
})();
</script>
{/literal}
