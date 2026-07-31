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
.nl-layout-text { min-width: 0; padding-top: 2px; padding-left: 13px; }
.nl-layout-name { line-height: 1.3; margin: 0 0 2px 0; }
.nl-layout-description { margin-bottom: 2px; }
.nl-dropdown { display: inline-block !important; opacity: 1 !important; visibility: visible !important; }
.nl-dropdown-toggle { visibility: visible !important; }
</style>{/literal}
<div class="ng-layouts-app row">
    <div class="layouts-content">
        <div class="nl-layouts-view-grid" style="display: block;">
            <div class="layouts-header">
                <h2 class="layouts-title">Shared layouts</h2>
                <div class="layouts-controls">
                    <a href={concat('explayouts_ui_api/app#layout')|ezurl} id="add-new-button" class="nl-btn nl-btn-primary js-open-ngl">
                        <i class="material-icons">add</i> New shared layout
                    </a>
                </div>
            </div>

            <div class="nl-layouts">
                {foreach $layouts as $layout}
                    <div class="nl-layout" data-name="{$layout.name|wash}" data-identifier="{$layout.identifier|wash}" data-modified="{$layout.modified}" data-type="{$layout.layout_type|wash}">
                        <div class="nl-layout-content">
                            <div class="nl-layout-info">
                                <div class="nl-layout-type">
                                    <p>{$layout.layout_type|wash}</p>
                                    <span class="nl-layout-icon">{$layout_type_icons[$layout.layout_type]}</span>
                                </div>
                                <div class="nl-layout-text">
                                    <div class="nl-layout-name"><a href={concat('explayouts_ui/layout_edit/',$layout.id)|ezurl}>{$layout.name|wash}</a></div>
                                    <div class="nl-layout-description">{$layout.identifier|wash}</div>
                                    <div class="nl-layout-modified"><p>{$layout.modified|datetime( 'custom', '%Y-%m-%d %H:%M' )}</p></div>
                                    {if ne($layout.status,2)}<span class="unpublished-label">Draft</span>{/if}
                                </div>
                            </div>
                            <div class="nl-layout-actions">
                                <div class="nl-layout-data">
                                    <div class="meta-info">
                                        <i class="material-icons">share</i>
                                        <span>{if is_set($shared_counts[$layout.id])}{$shared_counts[$layout.id]}{else}0{/if} references</span>
                                    </div>
                                </div>
                                <div class="nl-dropdown" data-position="right">
                                    <button class="nl-btn nl-dropdown-toggle" type="button"><i class="material-icons">more_horiz</i></button>
                                    <ul class="nl-dropdown-menu main-dropdown">
                                        <li><a href={concat('explayouts_ui_api/app#layout/',$layout.id)|ezurl}>Edit in modern editor</a></li>
                                        <li><a href={concat('explayouts_ui/layout_preview/',$layout.id,'/',$layout.status)|ezurl} target="_blank">Preview</a></li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                {/foreach}
            </div>

            {if count($layouts)|eq(0)}
                <p class="nl-no-items" style="display: block;">There are no shared layouts referenced by other layouts yet.</p>
            {/if}
        </div>
    </div>
</div>
{literal}
<script>
(function(){
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
