<nav class="nglayouts-sidebar">
    <a href={concat('explayouts_ui/rule_list')|ezurl} class="{if $module_result.uri|extract(1)|eq('explayouts_ui/rule_list')}active{/if}">
        <i class="material-icons">view_list</i>
        <span>Layout mappings</span>
    </a>
    <a href={concat('explayouts_ui/layout_list')|ezurl} class="{if $module_result.uri|extract(1)|eq('explayouts_ui/layout_list')}active{/if}">
        <i class="material-icons">dashboard</i>
        <span>Layouts</span>
    </a>
    <a href={concat('explayouts_ui/shared_layouts_list')|ezurl} class="{if $module_result.uri|extract(1)|eq('explayouts_ui/shared_layouts_list')}active{/if}">
        <i class="material-icons">share</i>
        <span>Shared layouts</span>
    </a>
    <a href={concat('explayouts_ui/components')|ezurl} class="{if $module_result.uri|extract(1)|eq('explayouts_ui/components')}active{/if}">
        <i class="material-icons">extension</i>
        <span>Components</span>
    </a>
    <a href={concat('explayouts_ui/transfer_import')|ezurl} class="{if $module_result.uri|extract(1)|eq('explayouts_ui/transfer_import')}active{/if}">
        <i class="material-icons">file_upload</i>
        <span>Import</span>
    </a>
</nav>
