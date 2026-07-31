# explayouts_ui TODO

- `settings/menu.ini.append.php` points the "Shared layouts" left-menu link at `explayouts_ui/layout_list` although a dedicated `shared_layouts_list` view exists; the link should target `explayouts_ui/shared_layouts_list`.
- The extension overlaps with the `explayouts` extension's own admin module (`/explayouts/layout_list` etc.); consolidate to one legacy UI or clearly deprecate one of them.
- The bundled `layouts-admin.js` / `layouts-ibexa.js` assets retain upstream `netgen`/`nglayouts` naming and paths; align asset naming with the exp prefix or document the mapping.
- Stray backup file `extension.xml~` should be removed from the tree.
- No automated tests for the module views.
