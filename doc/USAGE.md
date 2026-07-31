# Using explayouts_ui

## Screens and URLs

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

## Relationship to the modern editor

This extension is the legacy (server-rendered) UI. For visual drag-and-drop editing, its list screens deep-link into the SPA served by `explayouts_ui_api`:

```
/explayouts_ui_api/app#layout          (create/list in the SPA)
/explayouts_ui_api/app#layout/<id>     (edit a specific layout)
```

Both UIs operate on the same `explayouts_*` data through the `explayouts_core` services, so changes made in one appear in the other.

## Assets

The admin design ships the UI assets under `design/admin`:

- `stylesheets/nglayouts-ui.css` and `stylesheets/netgen/` — app shell CSS
- `javascript/netgen/layouts-admin.js`, `javascript/netgen/layouts-ibexa.js` — application scripts
- `templates/explayouts_ui/` and `templates/parts/` — the module view templates

## Customization

### Settings layer (INI cascade)

Override the shipped INI from outside the extension; priority from lowest to highest: `extension/explayouts_ui/settings/`, `settings/siteaccess/<siteaccess>/`, siteaccess settings shipped in active extensions, `settings/override/`.

- Rename or hide menu entries by overriding `menu.ini` sections `[Topmenu_explayouts_ui_dashboard]` / `[Leftmenu_explayouts_ui_dashboard]` (e.g. set `Shown[default]=false`, or redefine `Links[]`/`LinkNames[]`).
- The tab's visibility is also policy-driven: `PolicyList[]=explayouts/read` — users without that policy do not see it.
- Data-level behavior (available layout types, blocks, template editor roots) comes from `explayouts.ini` of the `explayouts` extension and is overridden there.

### Template layer (design override cascade)

All screens render templates from `design/admin/templates/explayouts_ui/`. To restyle a screen without touching this extension, ship the same relative path in another admin-design extension that is listed later/higher in the design cascade, e.g.:

```
extension/myadmin/design/admin/templates/explayouts_ui/layout_list.tpl
```

The shared partials in `design/admin/templates/parts/` can be overridden the same way. CSS/JS can be replaced by overriding the templates that include them.

### PHP layer (safe extension points)

This extension deliberately contains no PHP classes. Its module view scripts are thin controllers over the `explayouts_core` services — if you need different behavior, the supported route is to build your own module view (in your own extension) against `expLayoutsCoreLayoutService`, `expLayoutsCoreRuleService`, etc., and point the menu links at it via a `menu.ini` override, rather than editing the shipped view scripts.
