{* Renders the preview node's full view so the layout preview can fill the
   full_view block, which normally echoes $module_result.content from the
   request being previewed. *}
{if $preview_node}{node_view_gui view=full content_node=$preview_node}{/if}
