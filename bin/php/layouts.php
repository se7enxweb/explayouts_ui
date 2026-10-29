#!/usr/bin/env php
<?php
/**
 * List, export and import layouts, shared layouts and their mappings (the layouts transfer file)
 *
 * Usage:
 *   ./console exp:layouts list [--drafts] [--json]
 *   ./console exp:layouts export [--all] [--only=<layouts>] [--shared=all|<layouts>] [--rules=none|selected|all] [--drafts] [--output=<file.zip>] [--json]
 *   ./console exp:layouts import <file.zip> [--dry-run] [--strategy=skip|overwrite|copy] [--item=<key>=<strategy>,...] [--only=<layouts>|--all] [--publish] [--unmapped=drop|keep|fail] [--json]
 *   (or php extension/explayouts_ui/bin/php/layouts.php ..., ./console ext:explayouts_ui:layouts ...); --help shows the options.
 *
 * @alias exp:layouts
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package explayouts_ui
 */

require_once dirname( __FILE__ ) . '/../../../../autoload.php';

// The code is in extension/explayouts_ui/classes/runnable/commands/php_layouts.php (#207); this file is the entry point.
\Exponential\Command\Extension\ExplayoutsUi\Layouts::main( __FILE__ );
