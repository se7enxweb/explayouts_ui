<?php
/**
 * The code of extension/explayouts_ui/modules/explayouts_ui/transfer_import.php, moved into a class (#207 stage 1). The file extension/explayouts_ui/modules/explayouts_ui/transfer_import.php is one call to it.
 * Guide: doc/bc/6.0/cli_cronjob_view_abstractions.md
 */

namespace Exponential\View\Extension\ExplayoutsUi\ExplayoutsUi
{

class TransferImport extends \Exponential\Runnable\ModuleView
{
    public function run( array $scope )
    {
        // the including function's variables ($Params, $Module, $cli, ...)
        foreach ( array_keys( $scope ) as $__name )
            if ( $__name !== 'this' && $__name !== 'scope' )
                ${$__name} = &$scope[$__name];
        unset( $__name );

        $http = \eZHTTPTool::instance();
        $tpl = \eZTemplate::factory();

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
                    $error = \ezpI18n::tr( 'design/admin/explayouts_ui/transfer_import', 'Invalid JSON file.' );
                }
                else
                {
                    $items = isset( $data['version'] ) ? array( $data ) : $data;
                    $count = 0;
                    foreach ( $items as $item )
                    {
                        if ( !is_array( $item ) )
                            continue;

                        $result = \expLayoutsImporter::import( $item );
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
                $error = \ezpI18n::tr( 'design/admin/explayouts_ui/transfer_import', 'No file uploaded.' );
            }
        }

        $tpl->setVariable( 'message', $message );
        $tpl->setVariable( 'error', $error );

        $Result = array();
        $Result['content'] = $tpl->fetch( 'design:explayouts_ui/transfer_import.tpl' );
        $Result['left_menu'] = 'design:parts/explayouts_ui/menu.tpl';
        $Result['path'] = array( array( 'url' => false, 'text' => 'Import' ) );
        return $this->viewResult( isset( $Result ) ? $Result : null,  $Result );

        return $this->viewResult( isset( $Result ) ? $Result : null, null );
    }
}

}
