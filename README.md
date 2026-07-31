Exponential Layouts UI
======================

General description
-------------------

Exponential Layouts UI (`explayouts_ui`) is the admin user interface extension for Exponential Layouts on Exponential 6 / Exponential Legacy. It adds an "Exponential Layouts UI" tab to the admin interface with legacy module views for managing layouts, mapping rules and blocks, and ships the admin app UI assets (JS/CSS shell) used by the layouts editor, including `nglayouts-ui.css` and the `layouts-admin.js` / `layouts-ibexa.js` application scripts under `design/admin`.

It is an Exponential Legacy port inspired by the `netgen/layouts-ui` package. The extension contains no PHP classes of its own: its module views call the `explayouts_core` services and the `explayouts` value objects, and its list screens link into the modern SPA editor served by `explayouts_ui_api` (`/explayouts_ui_api/app#layout/<id>`).

This extension provides the following capabilities:

- Admin navigation - An "Exponential Layouts UI" navigation part, top admin menu tab and left menu links (Layouts, Layout mappings, Shared layouts, Import, Template editor, Setup).
- Layout management - Server-rendered screens to list, create and edit layouts and shared layouts, with deep links into the modern SPA editor.
- Mapping rule management - List and edit layout mapping rules together with their targets and conditions.
- Block editing - A legacy block edit screen backed by the `explayouts_core` block service.
- Transfer import - Import layouts and rules from transfer files.
- Template editing - Edit layout templates from the admin, with editable roots restricted by configuration.
- Preview and setup - Preview a layout and check the suite's setup/status.
- UI assets - The complete admin app CSS/JS shell used by the layouts editor.

Features
--------

The following features are provided by the Exponential Layouts UI extension:

- Full legacy screen set - Twelve module views on the `explayouts_ui` module cover the whole editorial workflow, reachable from the "Exponential Layouts UI" admin tab:

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

- Modern editor integration - The list screens deep-link into the SPA served by `explayouts_ui_api` (`/explayouts_ui_api/app#layout` to create/list, `/explayouts_ui_api/app#layout/<id>` to edit). Both UIs operate on the same `explayouts_*` data through the `explayouts_core` services, so changes made in one appear in the other.
- Policy-driven access - List views use the `read` module function, editing views use `edit`; the admin tab requires the `explayouts/read` policy. Grant matching module policies to editor roles.
- Template editor safety - Editable roots are limited by `explayouts.ini` `[TemplateEditorSettings] AllowedTemplateRoots[]`.
- Shipped admin assets - `design/admin` contains `stylesheets/nglayouts-ui.css` and `stylesheets/netgen/` (app shell CSS), `javascript/netgen/layouts-admin.js` and `javascript/netgen/layouts-ibexa.js` (application scripts), and the module view templates under `templates/explayouts_ui/` and `templates/parts/`.
- Shipped settings - `settings/module.ini.append.php` registers the `explayouts_ui` module (`read` and `edit` functions for policies), `settings/menu.ini.append.php` adds the navigation part, top menu tab (`explayouts_ui/dashboard`) and left menu links, and `settings/design.ini.append.php` registers the design extension.
- No PHP classes by design - The module view scripts are thin controllers over the `explayouts_core` services, keeping the UI replaceable without touching domain logic.

Version
-------

- The current version of Exponential Layouts UI is 1.0.0
- Last Major update: July 30, 2026

Copyright
---------

- Exponential Layouts UI is copyright 1998 - 2026 7x
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
- `extension/explayouts` — value objects, `explayouts_*` tables, `explayouts/read` policy.
- `extension/explayouts_core` — service classes used by the module views.
- `extension/explayouts_ui_api` — serves the modern SPA editor that the list screens link to (`/explayouts_ui_api/app`).

Siteaccess
- Activate the extension for the admin siteaccess — the module views and menu entries are admin-interface screens.

Installation
------------

In short: place the extension in `extension/explayouts_ui`, activate it after its dependencies (`explayouts`, `explayouts_core`, `explayouts_ui_api`) via `site.ini` `[ExtensionSettings] ActiveExtensions[]` (or per siteaccess via `ActiveAccessExtensions[]`) for the admin siteaccess, then regenerate autoloads and clear all caches. Verify by logging into the admin interface and opening the "Exponential Layouts UI" tab, or going to `/explayouts_ui/dashboard` directly.

See [INSTALL.md](INSTALL.md) for the full step-by-step installation instructions, including the settings shipped with the extension (`module.ini`, `menu.ini`, `design.ini`).

Usage
-----

All views live on the `explayouts_ui` module and are reached from the "Exponential Layouts UI" admin tab:

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
| `/explayouts_ui/transfer_import` | Import layouts/rules from a transfer file |
| `/explayouts_ui/template_editor` | Edit layout templates (roots limited by `explayouts.ini` `[TemplateEditorSettings] AllowedTemplateRoots[]`) |
| `/explayouts_ui/preview` | Preview a layout |
| `/explayouts_ui/setup` | Setup/status |

List views use the `read` module function, editing views use `edit` — grant matching module policies to editor roles.

This extension is the legacy (server-rendered) UI. For visual drag-and-drop editing, its list screens deep-link into the SPA served by `explayouts_ui_api`:

```
/explayouts_ui_api/app#layout          (create/list in the SPA)
/explayouts_ui_api/app#layout/<id>     (edit a specific layout)
```

See [doc/USAGE.md](doc/USAGE.md) for exhaustive scenarios: all screens and URLs, the relationship to the modern editor, the shipped assets, and the full customization guide covering the settings layer (INI cascade — renaming/hiding menu entries via `menu.ini` overrides, policy-driven visibility), the template layer (design override cascade for `design/admin/templates/explayouts_ui/` and `templates/parts/`) and the PHP layer (building your own module views on the `explayouts_core` services).

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
