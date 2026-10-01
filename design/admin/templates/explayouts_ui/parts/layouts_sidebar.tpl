<nav class="explayouts-sidebar">
    <a href={concat('explayouts_ui/rule_list')|ezurl} class="{if eq($current,'mappings')}active{/if}">
        <i class="material-icons">view_list</i>
        <span>{'Layout mappings'|i18n( 'design/admin/explayouts_ui/parts/layouts_sidebar' )}</span>
    </a>
    <a href={concat('explayouts_ui/layout_list')|ezurl} class="{if eq($current,'layouts')}active{/if}">
        <i class="material-icons">dashboard</i>
        <span>{'Layouts'|i18n( 'design/admin/explayouts_ui/parts/layouts_sidebar' )}</span>
    </a>
    <a href={concat('explayouts_ui/layout_list')|ezurl} class="{if eq($current,'shared')}active{/if}">
        <i class="material-icons">share</i>
        <span>{'Shared layouts'|i18n( 'design/admin/explayouts_ui/parts/layouts_sidebar' )}</span>
    </a>
    <a href={concat('explayouts_ui/transfer_import')|ezurl} class="{if eq($current,'import')}active{/if}">
        <i class="material-icons">file_upload</i>
        <span>{'Import'|i18n( 'design/admin/explayouts_ui/parts/layouts_sidebar' )}</span>
    </a>
</nav>
