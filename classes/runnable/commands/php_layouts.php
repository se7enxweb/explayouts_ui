<?php
/**
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package explayouts_ui
 */

namespace Exponential\Command\Extension\ExplayoutsUi
{

/**
 * exp:layouts (ext:explayouts_ui:layouts) - list, export and import layouts, shared layouts and their mappings.
 * The same service as the admin pages explayouts_ui/transfer_export and explayouts_ui/transfer_import, with the
 * same choices. Signed in with --login, the user needs the policies explayouts_ui/transfer_export or
 * explayouts_ui/transfer_import; without it the shell account is trusted, as for every console command.
 */
class Layouts extends \Exponential\Runnable\Command
{
    public function run()
    {
        $this->script( array( 'description' => "List, export and import layouts, shared layouts and their mappings.\n\n"
                                                . "  exp:layouts list [--drafts] [--json]\n"
                                                . "  exp:layouts export [--all] [--only=a,b] [--shared=all|a,b] [--rules=none|selected|all] [--drafts] [--output=file.zip] [--json]\n"
                                                . "  exp:layouts import file.zip [--dry-run] [--strategy=skip|overwrite|copy] [--item=key=strategy,...] [--only=a,b|--all] [--publish] [--unmapped=drop|keep|fail] [--json]",
                              'use-session' => false, 'use-modules' => true, 'use-extensions' => true ) );
        $options = $this->startup( '[json][drafts][all][only:][shared:][rules:][output:][dry-run][strategy:][item:][publish][unmapped:]', '[command][file]',
            array( 'json' => 'Print the result as JSON',
                   'drafts' => 'list: show drafts too; export: export the open drafts as well',
                   'all' => 'export: every layout, shared layout and mapping; import: every layout of the file (the default)',
                   'only' => 'Comma-separated layout identifiers (export: these layouts; import: only these layouts of the file)',
                   'shared' => 'export: "all" or comma-separated shared layout identifiers (linked ones are always included)',
                   'rules' => 'export: none, selected (the mappings of the chosen layouts, the default) or all',
                   'output' => 'export: the file to write (default: layouts-<date>.zip in the current directory)',
                   'dry-run' => 'import: show what would be done, write nothing',
                   'strategy' => 'import: skip (default), overwrite or copy, for items that exist already',
                   'item' => 'import: a strategy per item, comma-separated <key>=<strategy> (keys as the dry run prints them)',
                   'publish' => 'import: publish overwritten layouts and copies (otherwise they stay drafts)',
                   'unmapped' => 'import: references without a match here: drop (default), keep or fail' ) );

        $arguments = isset( $options['arguments'] ) ? array_values( (array)$options['arguments'] ) : array();
        $command = isset( $arguments[0] ) ? (string)$arguments[0] : 'list';

        switch ( $command )
        {
            case 'list':
                $code = $this->listLayouts( $options );
                break;
            case 'export':
                $code = $this->allowed( 'transfer_export' ) ? $this->export( $options ) : 1;
                break;
            case 'import':
                $code = $this->allowed( 'transfer_import' ) ? $this->import( $options, isset( $arguments[1] ) ? (string)$arguments[1] : '' ) : 1;
                break;
            default:
                $this->cli()->error( "Unknown command '$command': use list, export or import (--help for the options)." );
                $code = 1;
        }
        $this->shutdown( $code );
        return $code;
    }

    /**
     * Signed in (--login), the user needs the policy; the shell account itself is trusted.
     */
    protected function allowed( $function )
    {
        $user = \eZUser::currentUser();
        if ( !$user->isRegistered() )
            return true;
        $access = $user->hasAccessTo( 'explayouts_ui', $function );
        if ( $access['accessWord'] !== 'no' )
            return true;
        $this->cli()->error( "The user '" . $user->attribute( 'login' ) . "' may not use explayouts_ui/$function." );
        return false;
    }

    protected static function listOption( $value )
    {
        if ( !is_string( $value ) || trim( $value ) === '' )
            return array();
        return array_values( array_filter( array_map( 'trim', explode( ',', $value ) ), 'strlen' ) );
    }

    protected function json( $data )
    {
        $this->cli()->output( json_encode( $data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE ) );
    }

    protected function listLayouts( array $options )
    {
        $rows = \expLayoutsCoreTransferService::listLayouts( (bool)$options['drafts'] );
        if ( $options['json'] )
        {
            $this->json( $rows );
            return 0;
        }
        $this->cli()->output( sprintf( '%-6s %-40s %-36s %-10s %-9s %5s  %s', 'ID', 'Identifier', 'Name', 'Status', 'Shared', 'Rules', 'Links to' ) );
        foreach ( $rows as $row )
            $this->cli()->output( sprintf( '%-6d %-40s %-36s %-10s %-9s %5d  %s', $row['id'], $row['identifier'], mb_strimwidth( $row['name'], 0, 36, '...' ),
                $row['status'], $row['shared'] ? 'shared' : '', $row['rules'], implode( ', ', $row['links'] ) ) );
        $this->cli()->output( count( $rows ) . ' layouts.' );
        return 0;
    }

    protected function export( array $options )
    {
        $only = self::listOption( $options['only'] );
        if ( $options['all'] )
            $selection = array( 'layouts' => 'all', 'shared' => 'all', 'rules' => 'all' );
        else
            $selection = array( 'layouts' => $only ? $only : 'none',
                                'shared' => $options['shared'] === 'all' ? 'all' : ( self::listOption( $options['shared'] ) ?: 'none' ),
                                'rules' => 'selected' );
        if ( $options['rules'] )
            $selection['rules'] = (string)$options['rules'];
        $selection['drafts'] = (bool)$options['drafts'];

        if ( !in_array( $selection['rules'], array( 'none', 'selected', 'all' ), true ) )
        {
            $this->cli()->error( '--rules must be none, selected or all.' );
            return 1;
        }
        if ( $selection['layouts'] === 'none' && $selection['shared'] === 'none' && $selection['rules'] !== 'all' )
        {
            $this->cli()->error( 'Choose what to export: --all, --only=<layouts> or --shared=<layouts>.' );
            return 1;
        }

        $output = $options['output'] ? (string)$options['output'] : 'layouts-' . gmdate( 'Ymd-His' ) . '.zip';
        $service = new \expLayoutsCoreTransferService();
        $result = $service->export( $selection, $output );
        if ( $options['json'] )
            $this->json( $result );
        else
        {
            foreach ( $result['warnings'] as $warning )
                $this->cli()->warning( $warning );
            foreach ( $result['errors'] as $error )
                $this->cli()->error( $error );
            if ( $result['ok'] )
            {
                $counts = $result['manifest']['counts'];
                $this->cli()->output( "Wrote $output: {$counts['layouts']} layouts ({$counts['shared_layouts']} shared, {$counts['drafts']} drafts), "
                                      . "{$counts['blocks']} blocks, {$counts['rules']} mappings, "
                                      . ( $counts['node_references'] + $counts['object_references'] ) . ' content references.' );
            }
        }
        return $result['ok'] ? 0 : 1;
    }

    protected function import( array $options, $file )
    {
        if ( $file === '' || !is_file( $file ) )
        {
            $this->cli()->error( 'Name the file to import: exp:layouts import <file.zip>.' );
            return 1;
        }
        $strategy = $options['strategy'] ? (string)$options['strategy'] : 'skip';
        if ( !in_array( $strategy, \expLayoutsCoreTransferFormat::strategies(), true ) )
        {
            $this->cli()->error( '--strategy must be skip, overwrite or copy.' );
            return 1;
        }
        $unmapped = $options['unmapped'] ? (string)$options['unmapped'] : 'drop';
        if ( !in_array( $unmapped, array( 'drop', 'keep', 'fail' ), true ) )
        {
            $this->cli()->error( '--unmapped must be drop, keep or fail.' );
            return 1;
        }
        $items = array();
        foreach ( self::listOption( $options['item'] ) as $pair )
        {
            $at = strrpos( $pair, '=' );
            $value = $at === false ? '' : substr( $pair, $at + 1 );
            if ( $at === false || !in_array( $value, \expLayoutsCoreTransferFormat::strategies(), true ) )
            {
                $this->cli()->error( "--item takes <key>=<strategy>, not '$pair'." );
                return 1;
            }
            $items[substr( $pair, 0, $at )] = $value;
        }
        $only = $options['all'] ? array() : self::listOption( $options['only'] );

        $service = new \expLayoutsCoreTransferService();
        $result = $service->import( $file, array(
            'strategy' => $strategy, 'items' => $items, 'only' => $only ? $only : null,
            'publish' => (bool)$options['publish'], 'unmapped' => $unmapped, 'dry_run' => (bool)$options['dry-run'],
        ) );

        if ( $options['json'] )
        {
            $this->json( $result );
            return $result['ok'] ? 0 : 1;
        }

        $cli = $this->cli();
        foreach ( $result['warnings'] as $warning )
            $cli->warning( $warning );
        if ( $result['plan'] )
        {
            $source = isset( $result['manifest']['source'] ) ? $result['manifest']['source'] : array();
            $cli->output( 'File: format version ' . $result['manifest']['format_version'] . ', made ' . $result['manifest']['created']
                          . ( !empty( $source['site_url'] ) ? ' on ' . $source['site_url'] : '' ) . '.' );
            $cli->output( sprintf( '%-12s %-11s %-10s %s', 'State', 'Action', 'Kind', 'Key' ) );
            foreach ( array( 'layouts', 'rules' ) as $list )
                foreach ( $result['plan'][$list] as $item )
                {
                    $cli->output( sprintf( '%-12s %-11s %-10s %s%s', $item['state'], $item['action'], $item['kind'], $item['key'],
                        !empty( $item['dependency'] ) ? ' (linked to)' : '' ) );
                    foreach ( $item['reasons'] as $reason )
                        $cli->output( '               ' . $reason );
                    if ( $options['verbose'] ?? false )
                        foreach ( $item['differences'] as $difference )
                            $cli->output( '               differs: ' . $difference );
                }
            $totals = array();
            foreach ( $result['plan']['totals'] as $state => $count )
                $totals[] = "$count $state";
            $cli->output( 'Totals: ' . implode( ', ', $totals ) . '.' );
            foreach ( $result['unmapped'] as $reference )
                $cli->output( "Unmapped: {$reference['kind']} {$reference['id']} (remote ID " . ( $reference['remote_id'] ?: '-' ) . ')' );
            if ( $result['unmapped'] )
                $cli->output( count( $result['unmapped'] ) . " references have no match here (--unmapped=$unmapped)." );
        }
        foreach ( $result['errors'] as $error )
            $cli->error( $error );

        if ( isset( $result['import'] ) )
        {
            if ( $result['import']['ok'] )
            {
                foreach ( $result['import']['written'] as $entry )
                    $cli->output( "Written: {$entry['key']} {$entry['what']} (ID {$entry['id']})" );
                $cli->output( count( $result['import']['written'] ) . ' items written; ' . $result['import']['cache_entries_removed'] . ' resolver cache entries removed.' );
            }
            else
                $cli->error( 'Nothing was written: the import was rolled back.' );
        }
        elseif ( $result['ok'] )
            $cli->output( 'Dry run: nothing was written.' );

        return $result['ok'] ? 0 : 1;
    }
}

}
