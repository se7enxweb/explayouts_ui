<?php
$http = eZHTTPTool::instance();
$tpl = eZTemplate::factory();

$message = '';
$error = '';

if ( $http->hasPostVariable( 'import' ) )
{
    $import = $http->postVariable( 'import' );
    $file = isset( $_FILES['import'] ) && isset( $_FILES['import']['tmp_name']['file'] ) ? $_FILES['import']['tmp_name']['file'] : null;

    if ( $file && is_uploaded_file( $file ) )
    {
        $json = file_get_contents( $file );
        $data = json_decode( $json, true );
        if ( !is_array( $data ) )
        {
            $error = 'Invalid JSON file.';
        }
        else
        {
            $items = isset( $data['version'] ) ? array( $data ) : $data;
            $count = 0;
            foreach ( $items as $item )
            {
                if ( !is_array( $item ) )
                    continue;

                $result = expLayoutsImporter::import( $item );
                if ( isset( $result['error'] ) )
                {
                    $error .= $result['error'] . ' ';
                }
                else
                {
                    $count++;
                }
            }
            $message = "Imported $count layout(s).";
        }
    }
    else
    {
        $error = 'No file uploaded.';
    }
}

$tpl->setVariable( 'message', $message );
$tpl->setVariable( 'error', $error );

$Result = array();
$Result['content'] = $tpl->fetch( 'design:explayouts_ui/transfer_import.tpl' );
$Result['left_menu'] = 'design:parts/explayouts_ui/menu.tpl';
$Result['path'] = array( array( 'url' => false, 'text' => 'Import' ) );
return $Result;
