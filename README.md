# explayouts_ui

Admin user interface extension for Exponential Layouts on Exponential Legacy / Exponential 6. It adds an "Exponential Layouts UI" tab to the admin interface with legacy module views for managing layouts, mapping rules and blocks, and ships the admin app UI assets (JS/CSS shell) used by the layouts editor, including `nglayouts-ui.css` and the `layouts-admin.js` / `layouts-ibexa.js` application scripts under `design/admin`.

Exponential Legacy port inspired by the `netgen/layouts-ui` package. The extension contains no PHP classes of its own: its module views call the `explayouts_core` services and the `explayouts` value objects, and its list screens link into the modern SPA editor served by `explayouts_ui_api` (`/explayouts_ui_api/app#layout/<id>`).

## Module views (`/explayouts_ui/...`)

| View | Purpose |
|------|---------|
| `dashboard` | Entry screen for the Layouts UI navigation part |
| `layout_list`, `shared_layouts_list` | List layouts / shared layouts, link to editors |
| `layout_create`, `layout_edit` | Create and edit a layout |
| `block_edit` | Edit a block |
| `rule_list`, `rule_edit` | List and edit layout mapping rules |
| `transfer_import` | Import layouts/rules from transfer files |
| `template_editor` | Edit layout templates |
| `preview` | Preview a layout |
| `setup` | Setup/status screen |

## Settings shipped

- `settings/module.ini.append.php` — registers the `explayouts_ui` module
- `settings/menu.ini.append.php` — admin navigation part, top menu tab and left menu links
- `settings/design.ini.append.php` — registers the `explayouts_ui` design extension

## Documentation

- [INSTALL.md](INSTALL.md) — activation and dependencies
- [doc/USAGE.md](doc/USAGE.md) — screens, URLs and customization
- [doc/FAQ.md](doc/FAQ.md) — common questions
- [doc/TODO.md](doc/TODO.md) — known gaps
- [doc/SUPPORT.md](doc/SUPPORT.md) — how to get help
