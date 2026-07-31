<?php
eZDebug::updateSettings( array( 'debug-enabled' => false ) );
$http = eZHTTPTool::instance();
$module = $Params['Module'];

if ( !eZUser::currentUser()->hasAccessTo( 'explayouts', 'edit' ) )
{
    return $module->handleError( eZError::KERNEL_ACCESS_DENIED, 'kernel' );
}

$db = eZDB::instance();
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
        $error = 'Unsupported database type: ' . $dbType;
}

if ( $schemaFile && $http->hasPostVariable( 'InstallSchema' ) )
{
    $path = eZSys::rootDir() . '/' . $schemaFile;
    if ( !file_exists( $path ) )
    {
        $error = 'Schema file not found: ' . $schemaFile;
    }
    elseif ( in_array( $dbType, array( 'mongo', 'mongodb' ) ) )
    {
        $result = expLayoutsMongoInstaller::install( $path );
        if ( $result['success'] )
            $message = 'MongoDB collections created: ' . $result['created'] . ', indexes: ' . $result['indexes'];
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
                eZDebug::writeError( 'Schema query failed: ' . $query, 'expLayoutsSetup' );
            }
            else
            {
                $executed++;
            }
        }

        if ( $failed > 0 )
            $error = 'Executed ' . $executed . ' queries, ' . $failed . ' failed.';
        else
            $message = 'Database schema installed (' . $executed . ' queries executed).';
    }
}

$tpl = eZTemplate::factory();
$tpl->setVariable( 'db_type', $dbType );
$tpl->setVariable( 'schema_file', $schemaFile );
$tpl->setVariable( 'message', $message );
$tpl->setVariable( 'error', $error );

$Result = array();
$Result['content'] = $tpl->fetch( 'design:explayouts_ui/setup.tpl' );
$Result['path'] = array( array( 'url' => false,
                                'text' => ezpI18n::tr( 'explayouts_ui/setup', 'Setup' ) ) );
return $Result;
