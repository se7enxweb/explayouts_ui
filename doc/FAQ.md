# explayouts_ui FAQ

## How does this differ from netgen/layouts-ui?

`netgen/layouts-ui` is the JavaScript admin app (Backbone-based) for Netgen Layouts, mounted in a Symfony backend. Here the roles are split: `explayouts_ui` provides classic server-rendered eZ admin module views plus the admin CSS/JS assets, while `explayouts_ui_api` serves the SPA shell and the JSON API the app scripts talk to.

## Do I need explayouts_ui_api as well?

For the legacy screens alone, no — they work against `explayouts_core` directly. But the layout list's "Add new" and "Edit in modern editor" actions link to `/explayouts_ui_api/app`, so without `explayouts_ui_api` those links lead nowhere. Activate both for the intended experience.

## Which policies control access?

The module declares `read` (lists, dashboard, preview, setup) and `edit` (create/edit views) functions on the `explayouts_ui` module. The admin menu tab additionally requires `explayouts/read` (declared in `menu.ini` `PolicyList[]`).

## Which database tables does it own?

None. All data lives in the `explayouts_*` tables owned by the `explayouts` extension and is accessed through the `explayouts_core` services.

## Why do I not see the "Exponential Layouts UI" tab?

Check that the extension is active for the admin siteaccess, that caches were cleared (`php bin/php/ezcache.php --clear-all --purge --allow-root-user`), and that your role includes the `explayouts/read` policy.
