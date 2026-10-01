# explayouts_ui TODO

- `settings/menu.ini.append.php` points the "Shared layouts" left-menu link at `explayouts_ui/layout_list` although a dedicated `shared_layouts_list` view exists; the link should target `explayouts_ui/shared_layouts_list`.
- The extension overlaps with the `explayouts` extension's own admin module (`/explayouts/layout_list` etc.); consolidate to one legacy UI or clearly deprecate one of them.
- The `netgen/` asset folders and `layouts-admin.js` keep their upstream names. The page tags, storage keys and names inside the bundles carry Exponential names; `layouts-admin.js` is shipped but not loaded (its content browser needs Netgen's page tags).
- Stray backup file `extension.xml~` should be removed from the tree.
- No automated tests for the module views.
