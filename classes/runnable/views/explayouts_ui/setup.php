<?php
/**
 * The code of extension/explayouts_ui/modules/explayouts_ui/setup.php, moved into a class (#207 stage 1). The file extension/explayouts_ui/modules/explayouts_ui/setup.php is one call to it.
 * Guide: doc/bc/6.0/cli_cronjob_view_abstractions.md
 */

namespace Exponential\View\Extension\ExplayoutsUi\ExplayoutsUi
{

class Setup extends \Exponential\Runnable\ModuleView
{
    public function run( array $scope )
    {
        // the including function's variables ($Params, $Module, $cli, ...)
        foreach ( array_keys( $scope ) as $__name )
            if ( $__name !== 'this' && $__name !== 'scope' )
                ${$__name} = &$scope[$__name];
        unset( $__name );

        \eZDebug::updateSettings( array( 'debug-enabled' => false ) );
        $http = \eZHTTPTool::instance();
        $module = $Params['Module'];

        if ( !\eZUser::currentUser()->hasAccessTo( 'explayouts', 'edit' ) )
        {
            return $this->viewResult( isset( $Result ) ? $Result : null,  $module->handleError( \eZError::KERNEL_ACCESS_DENIED, 'kernel' ) );
        }

        $db = \eZDB::instance();
        $dbType = strtolower( $db->databaseName() );

        $message = '';
        $error = '';
        $schemaFile = false;

        switch ( $dbType )
        {
            case 'mysql':
            case 'mysqli':
                $schemaFile = 'extension/explayouts/sql/mysql/schema.sql';
                break;

            case 'postgresql':
            case 'pgsql':
                $schemaFile = 'extension/explayouts/sql/postgresql/schema.sql';
                break;

            case 'sqlite':
            case 'sqlite3':
                $schemaFile = 'extension/explayouts/sql/sqlite/schema.sql';
                break;

            case 'mongo':
            case 'mongodb':
                $schemaFile = 'extension/explayouts/sql/mongodb/schema.json';
                break;

            default:
                $error = \ezpI18n::tr( 'design/admin/explayouts_ui/setup', 'Unsupported database type: %type', null, array( '%type' => $dbType ) );
        }

        if ( $schemaFile && $http->hasPostVariable( 'InstallSchema' ) )
        {
            $path = \eZSys::rootDir() . '/' . $schemaFile;
            if ( !file_exists( $path ) )
            {
                $error = \ezpI18n::tr( 'design/admin/explayouts_ui/setup', 'Schema file not found: %file', null, array( '%file' => $schemaFile ) );
            }
            elseif ( in_array( $dbType, array( 'mongo', 'mongodb' ) ) )
            {
                $result = \expLayoutsMongoInstaller::install( $path );
                if ( $result['success'] )
                    $message = \ezpI18n::tr( 'design/admin/explayouts_ui/setup', 'MongoDB collections created: %created, indexes: %indexes', null, array( '%created' => $result['created'], '%indexes' => $result['indexes'] ) );
                else
                    $error = $result['error'];
            }
            else
            {
                $sql = file_get_contents( $path );
                $queries = array_filter( array_map( 'trim', preg_split( '/;[\s]*$/m', $sql ) ) );
                $executed = 0;
                $failed = 0;
                foreach ( $queries as $query )
                {
                    if ( $query === '' )
                        continue;

                    $result = $db->query( $query );
                    if ( $result === false )
                    {
                        $failed++;
                        \eZDebug::writeError( 'Schema query failed: ' . $query, 'expLayoutsSetup' );
                    }
                    else
                    {
                        $executed++;
                    }
                }

                if ( $failed > 0 )
                    $error = \ezpI18n::tr( 'design/admin/explayouts_ui/setup', 'Executed %executed queries, %failed failed.', null, array( '%executed' => $executed, '%failed' => $failed ) );
                else
                    $message = \ezpI18n::tr( 'design/admin/explayouts_ui/setup', 'Database schema installed (%executed queries executed).', null, array( '%executed' => $executed ) );
            }
        }

        $tpl = \eZTemplate::factory();
        $tpl->setVariable( 'db_type', $dbType );
        $tpl->setVariable( 'schema_file', $schemaFile );
        $tpl->setVariable( 'message', $message );
        $tpl->setVariable( 'error', $error );

        $Result = array();
        $Result['content'] = $tpl->fetch( 'design:explayouts_ui/setup.tpl' );
        $Result['path'] = array( array( 'url' => false,
                                        'text' => \ezpI18n::tr( 'explayouts_ui/setup', 'Setup' ) ) );
        return $this->viewResult( isset( $Result ) ? $Result : null,  $Result );

        return $this->viewResult( isset( $Result ) ? $Result : null, null );
    }
}

}
