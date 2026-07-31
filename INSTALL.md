# Installing explayouts_ui

## Requirements

- Exponential Legacy / Exponential 6, PHP 8.1+
- `extension/explayouts` — value objects, `explayouts_*` tables, `explayouts/read` policy
- `extension/explayouts_core` — service classes used by the module views
- `extension/explayouts_ui_api` — serves the modern SPA editor that the list screens link to (`/explayouts_ui_api/app`)

## 1. Put the extension in place

```
extension/explayouts_ui
```

## 2. Activate

Add it (after its dependencies) to `settings/override/site.ini.append.php`:

```ini
[ExtensionSettings]
ActiveExtensions[]=explayouts
ActiveExtensions[]=explayouts_core
ActiveExtensions[]=explayouts_ui
ActiveExtensions[]=explayouts_ui_api
```

or per siteaccess via `ActiveAccessExtensions[]` in `settings/siteaccess/<access>/site.ini.append.php`. Activate it for the admin siteaccess — the module views and menu entries are admin-interface screens.

## 3. Regenerate autoloads and clear caches

```bash
php bin/php/ezpgenerateautoloads.php -e
php bin/php/ezcache.php --clear-all --purge --allow-root-user
```

## 4. Settings shipped with the extension

- `settings/module.ini.append.php` — registers the `explayouts_ui` module (`read` and `edit` functions for policies).
- `settings/menu.ini.append.php` — adds the "Exponential Layouts UI" navigation part, top admin menu tab (`explayouts_ui/dashboard`) and left menu links (Layouts, Layout mappings, Shared layouts, Import, Template editor, Setup). The tab requires the `explayouts/read` policy.
- `settings/design.ini.append.php` — registers the design extension so the `design/admin` templates and assets are found.

## 5. Verify

Log into the admin interface and open the "Exponential Layouts UI" tab, or go to `/explayouts_ui/dashboard` directly.
