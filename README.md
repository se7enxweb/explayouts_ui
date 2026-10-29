Exponential Layouts UI
======================

General description
-------------------

Exponential Layouts UI (`explayouts_ui`) is the admin user interface extension for Exponential Layouts on Exponential 6 / Exponential Legacy. It adds a "Layouts" tab to the admin interface with legacy module views for managing layouts, mapping rules and blocks, and ships the admin app UI assets (JS/CSS shell) used by the layouts editor, including `explayouts-ui.css` and the `layouts-exponential.js` application script under `design/admin`.

It is an Exponential Legacy port inspired by the `netgen/layouts-ui` package. Its module views (one class per view under `classes/runnable/views/explayouts_ui/`) are thin controllers over the `explayouts_core` services and the `explayouts` value objects; its own classes are the rule form input (`expLayoutsUiRuleInput`), the schema statements of Setup (`expLayoutsUiSchemaStatement`) and its template operators (`expLayoutsUiTemplateOperators`), and its list screens link into the modern SPA editor served by `explayouts_ui_api` (`/explayouts_ui_api/app#layout/<id>`).

This extension provides the following capabilities:

- Admin navigation - A "Layouts" navigation part, top admin menu tab and left menu links (Layout mappings, Layouts, Shared layouts, Components, Import, Template editor, Setup).
- Layout management - Server-rendered screens to list, create and edit layouts and shared layouts, with deep links into the modern SPA editor.
- Mapping rule management - List and edit layout mapping rules together with their targets and conditions.
- Block editing - A legacy block edit screen backed by the `explayouts_core` block service.
- Layouts transfer - Export layouts, shared layouts and mappings into a versioned ZIP file and import it with a preview, per-item strategies and one transaction (admin pages and `./console exp:layouts`).
- Template editing - Edit layout templates from the admin. Only the folders in `explayouts.ini` `[TemplateEditorSettings] AllowedTemplateRoots[]` are editable; explayouts ships the layout type and block template folders, and new templates are created only with `AllowNewTemplates=enabled`.
- Preview and setup - Preview a layout and check the suite's setup/status.
- UI assets - The complete admin app CSS/JS shell used by the layouts editor.

Features
--------

The following features are provided by the Exponential Layouts UI extension:

- Full legacy screen set - Fourteen module views on the `explayouts_ui` module cover the whole editorial workflow, reachable from the "Layouts" admin tab:

| View | Purpose |
|------|---------|
| `dashboard` | Entry screen for the Layouts UI navigation part |
| `layout_list`, `shared_layouts_list` | List layouts / shared layouts, link to editors |
| `layout_create`, `layout_edit` | Create and edit a layout |
| `block_edit` | Edit a block |
| `rule_list`, `rule_edit` | List and edit layout mapping rules |
| `transfer_export`, `transfer_import` | Export layouts, shared layouts and mappings to a transfer file; preview and import one (see "Layouts transfer" below) |
| `template_editor` | Search, edit, review and save layout templates, revert to the original (needs `read` and `edit`; every change also `edit`) |
| `layout_preview` | Preview a layout |
| `components` | The content component blocks and the content they show |
| `setup` | Setup/status screen |

- Modern editor integration - The list screens deep-link into the SPA served by `explayouts_ui_api` (`/explayouts_ui_api/app#layout` to create/list, `/explayouts_ui_api/app#layout/<id>` to edit). Both UIs operate on the same `explayouts_*` data through the `explayouts_core` services, so changes made in one appear in the other.
- Policy-driven access - The list views, `dashboard`, `layout_preview` and `components` use the `read` module function; `layout_create`, `layout_edit`, `block_edit`, `rule_edit` and `setup` use `edit`, `template_editor` both; `transfer_export` and `transfer_import` have policies of their own, `transfer_export` and `transfer_import` (export and import can be granted apart). The admin tab requires `explayouts_ui/read`, the function of the dashboard it opens. The SPA editor these screens link to has policies of its own: `explayouts_ui_api/read` to open it, `explayouts_ui_api/edit` for every change. Grant matching module policies to editor roles.
- Template editor safety - Editable roots are limited by `explayouts.ini` `[TemplateEditorSettings] AllowedTemplateRoots[]` (shipped: the layout type and block template folders of explayouts; an empty list allows nothing). Every template in a root can be changed by whoever may open the editor, so do not add `design` or `extension` as a whole. The New button is shown only with `AllowNewTemplates=enabled`. Symbolic links inside a root are neither listed nor read or written. Before a save the previous version is copied to `<var directory>/explayouts/template_backup/<path>` (one generation; keep the var directory out of the web server's reach).
- Template editor (since 1.3.24) - An administration page like the others (top menu, breadcrumb, the Layouts left menu), light and dark with the admin design. The template list can be searched by name or path and filtered by design, folder and state (changed in the editor, overridden in another design or not); each template shows which other designs override it and, for block and layout templates, how many published blocks or layouts use its type. The editor highlights template tags, variables, operators, strings, comments and HTML, with line numbers. Ctrl+S (Cmd+S) or "Review changes" shows the differences against the saved template (or the original) and the template engine's syntax check before saving; a syntax error refuses the save and names its line, an unclosed or mismatched block tag is shown as a warning. The first save keeps the original in `<var directory>/explayouts/template_original/<path>`, and "Revert to original" (with a confirmation) puts it back. Leaving or switching templates with unsaved changes asks first. Every change is a POST with the form token, checked against `explayouts_ui/edit` again, and written to the audit log as `system.template.change` (the checksums, never the text). The page has no inline CSS or script: `design/standard/stylesheets/explayouts_ui_template_editor.css` (the `--a4-*` tokens only) and `design/standard/javascript/explayouts_ui_template_editor.js`, through `ezcss_require`/`ezscript_require` and the packer.
- Shipped admin assets - `design/admin` contains `stylesheets/explayouts-ui.css` and `stylesheets/netgen/` (app shell CSS), `javascript/netgen/layouts-admin.js` and `javascript/netgen/layouts-exponential.js` (application scripts), and the module view templates under `templates/explayouts_ui/` and `templates/parts/`.
- Shipped settings - `settings/module.ini.append.php` registers the `explayouts_ui` module (`read` and `edit` functions for policies), `settings/menu.ini.append.php` adds the navigation part, top menu tab (`explayouts_ui/dashboard`) and left menu links, and `settings/design.ini.append.php` registers the design extension.
- Thin controllers by design - The module view classes are thin controllers over the `explayouts_core` services, keeping the UI replaceable without touching domain logic.

Version
-------

- The current version of Exponential Layouts UI is the one in `extension.xml` and `ezinfo.php`
- Last Major update: July 30, 2026

Copyright
---------

- Exponential Layouts UI is Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
- See: [LICENSE.md](LICENSE.md) for more information on the terms of the copyright and license

License
-------

Exponential Layouts UI is licensed under the GNU General Public License.

The complete license agreement is included in the [LICENSE.md](LICENSE.md) file.

Exponential Layouts UI is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License or at your
option a later version.

Exponential Layouts UI is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

The GNU GPL gives you the right to use, modify and redistribute
Exponential Layouts UI under certain conditions. The GNU GPL license
is distributed with the software, see the file LICENSE.md.

It is also available at http://www.gnu.org/licenses/gpl.txt

You should have received a copy of the GNU General Public License
along with Exponential Layouts UI in LICENSE.md. If not, see http://www.gnu.org/licenses/.

Using Exponential Layouts UI under the terms of the GNU GPL is free (as in freedom).

For more information or questions please contact
info@se7enx.com

Requirements
------------

The following requirements exists for using the Exponential Layouts UI extension:

Exponential version
- Make sure you use Exponential 6 / eZ Publish Legacy (required) or higher.

PHP version
- Make sure you have PHP 8.1 or higher.

Sibling extensions
- `extension/explayouts` — value objects, `explayouts_*` tables, the template editor class and its settings.
- `extension/explayouts_core` — service classes used by the module views.
- `extension/explayouts_ui_api` — serves the modern SPA editor that the list screens link to (`/explayouts_ui_api/app`).

Siteaccess
- Activate the extension for the admin siteaccess — the module views and menu entries are admin-interface screens.

Installation
------------

In short: place the extension in `extension/explayouts_ui`, activate it after its dependencies (`explayouts`, `explayouts_core`, `explayouts_ui_api`) via `site.ini` `[ExtensionSettings] ActiveExtensions[]` (or per siteaccess via `ActiveAccessExtensions[]`) for the admin siteaccess, then regenerate autoloads and clear all caches. Verify by logging into the admin interface and opening the "Layouts" tab, or going to `/explayouts_ui/dashboard` directly.

See [INSTALL.md](INSTALL.md) for the full step-by-step installation instructions, including the settings shipped with the extension (`module.ini`, `menu.ini`, `design.ini`).

Usage
-----

All views live on the `explayouts_ui` module and are reached from the "Layouts" admin tab:

| URL | Screen |
|-----|--------|
| `/explayouts_ui/dashboard` | Dashboard (top menu entry point) |
| `/explayouts_ui/layout_list` | Layout list; "Add new" and "Edit in modern editor" link into `/explayouts_ui_api/app#layout/<id>` |
| `/explayouts_ui/shared_layouts_list` | Shared layouts list |
| `/explayouts_ui/layout_create` | Create a layout (`edit` policy function) |
| `/explayouts_ui/layout_edit/(LayoutID)/<id>` | Edit a layout |
| `/explayouts_ui/block_edit/(BlockID)/<id>` | Edit a block |
| `/explayouts_ui/rule_list` | Layout mapping rules |
| `/explayouts_ui/rule_edit/(RuleID)/<id>` | Edit a rule, its targets and conditions |
| `/explayouts_ui/transfer_export` | Export layouts, shared layouts and mappings (`transfer_export` policy function) |
| `/explayouts_ui/transfer_import` | Preview and import a layouts transfer file (`transfer_import` policy function) |
| `/explayouts_ui/template_editor` | Search, edit (syntax check and diff before saving) and revert layout templates (`read` and `edit`; roots limited by `explayouts.ini` `[TemplateEditorSettings] AllowedTemplateRoots[]`, new files only with `AllowNewTemplates=enabled`) |
| `/explayouts_ui/layout_preview/<layout_id>/<status>` | Preview a layout |
| `/explayouts_ui/components` | The content component blocks and the content they show |
| `/explayouts_ui/setup` | Setup/status (`edit` policy function) |

List views, the dashboard, the preview and the components use the `read` module function, the screens that change something use `edit` — grant matching module policies to editor roles. The SPA editor (`explayouts_ui_api`) has its own: `explayouts_ui_api/read` to open it, `explayouts_ui_api/edit` for every change.

This extension is the legacy (server-rendered) UI. For visual drag-and-drop editing, its list screens deep-link into the SPA served by `explayouts_ui_api`:

```
/explayouts_ui_api/app#layout          (create/list in the SPA)
/explayouts_ui_api/app#layout/<id>     (edit a specific layout)
```

See [doc/USAGE.md](doc/USAGE.md) for exhaustive scenarios: all screens and URLs, the relationship to the modern editor, the shipped assets, and the full customization guide covering the settings layer (INI cascade — renaming/hiding menu entries via `menu.ini` overrides, policy-driven visibility), the template layer (design override cascade for `design/admin/templates/explayouts_ui/` and `templates/parts/`) and the PHP layer (building your own module views on the `explayouts_core` services).

Layouts transfer
----------------

`explayouts_ui/transfer_export` and `explayouts_ui/transfer_import` move layouts between installations (or keep a
copy of them). The file format and the import rules are described in `extension/explayouts_core/doc/TRANSFER.md`.

- **Export**: choose layouts (one, several, all), shared layouts, the mappings (none, those of the chosen layouts, all)
  and whether open drafts go along, or "Export everything". The shared layouts a chosen layout links a zone to are
  always included. The download is a ZIP with JSON documents and a `manifest.json` (format version, source site,
  counts, a sha256 per file).
- **Import**: upload the file; it is validated (format, version, checksums, schema) and previewed as a dry run. Each
  layout and mapping is *new*, *identical*, *changed* or *conflicting* (another layout type or shared flag, an open draft
  here, or the same targets mapped to another layout), with the differences. Choose a strategy globally or per item:
  *skip*, *overwrite* (a new draft, published only with "Publish") or *create a copy* (the layout service's `copy()`).
  Node and object ids are mapped by remote id; references without a match are listed and left out, kept or stop the
  import. The import writes in one transaction (rolled back on any error), relinks shared-layout zones by identifier,
  writes audit events (`data.explayouts_core.import`) and removes only the resolver cache entries of the layouts and
  mappings it touched.
- **Console**, with the same choices:

```
./console exp:layouts list [--drafts] [--json]
./console exp:layouts export --all | --only=<id or identifier,...> [--shared=all|<...>] [--rules=none|selected|all] [--drafts] [--output=file.zip] [--json]
./console exp:layouts import file.zip [--dry-run] [--strategy=skip|overwrite|copy] [--item=<key>=<strategy>,...] [--only=<identifiers>|--all] [--publish] [--unmapped=drop|keep|fail] [--json]
```

  (`exp:layouts` is the alias of `ext:explayouts_ui:layouts`.) Signed in with `--login`, the console checks the same
  policies as the pages.
- **Policies**: `explayouts_ui/transfer_export` and `explayouts_ui/transfer_import`. Before 1.3.22 the import page asked
  for `explayouts_ui/edit`; roles that should keep importing need `explayouts_ui/transfer_import` now (roles with
  `explayouts_ui/*` have it).

Documentation
-------------

| Document | Description |
|----------|-------------|
| [INSTALL.md](INSTALL.md) | Step-by-step installation: activation, dependencies, shipped settings, verification |
| [doc/USAGE.md](doc/USAGE.md) | Screens and URLs, modern editor integration, assets, customization layers |
| [doc/FAQ.md](doc/FAQ.md) | Answers to the most common questions and problems |
| [doc/TODO.md](doc/TODO.md) | Known gaps and planned improvements |
| [doc/SUPPORT.md](doc/SUPPORT.md) | How and where to get help |
| [LICENSE.md](LICENSE.md) | The complete GNU General Public License agreement |

Troubleshooting
---------------

Read the FAQ
- Some problems are more common than others. The most common ones are listed in [doc/FAQ.md](doc/FAQ.md).

Use our support systems
- If you have questions not handled by this document or the FAQ, you can reach us via [7x : se7enx.com](https://se7enx.com).
- If you find a bug or defect, please report it to the [Exponential Layouts UI: Issue Tracker](https://github.com/se7enxweb/explayouts_ui/issues).
