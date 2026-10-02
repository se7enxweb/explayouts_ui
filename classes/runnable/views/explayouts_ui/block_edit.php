<?php
/**
 * The code of extension/explayouts_ui/modules/explayouts_ui/block_edit.php, moved into a class (#207 stage 1). The file extension/explayouts_ui/modules/explayouts_ui/block_edit.php is one call to it.
 * Guide: doc/bc/6.0/cli_cronjob_view_abstractions.md
 */

namespace Exponential\View\Extension\ExplayoutsUi\ExplayoutsUi
{

class BlockEdit extends \Exponential\Runnable\ModuleView
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

        $blockId = isset( $Params['BlockID'] ) ? (int)$Params['BlockID'] : 0;
        $block = \expLayoutsBlock::fetch( $blockId );
        if ( !$block )
            return $this->viewResult( isset( $Result ) ? $Result : null,  $module->handleError( \eZError::KERNEL_NOT_FOUND, 'kernel' ) );

        $handler = \expLayoutsBlockHandlerFactory::get( $block->attribute( 'definition_identifier' ) );
        $parameters = $handler ? $handler->getParameters() : array();
        $existingParams = array();
        foreach ( \expLayoutsBlockParameter::fetchByBlock( $blockId ) as $param )
        {
            $existingParams[$param->attribute( 'name' )] = $param->attribute( 'value' );
        }

        $blockInfo = \expLayoutsBlockHandlerFactory::getBlockInfo( $block->attribute( 'definition_identifier' ) );
        $hasCollection = isset( $blockInfo['has_collection'] ) && $blockInfo['has_collection'];

        $collection = false;
        if ( $hasCollection )
            $collection = \expLayoutsCollection::fetchByBlock( $blockId );

        $message = '';
        $error = '';

        if ( $http->hasPostVariable( 'SaveBlock' ) )
        {
            $block->setAttribute( 'name', trim( $http->postVariable( 'Name' ) ) );
            $block->setAttribute( 'view_type', trim( $http->postVariable( 'ViewType' ) ) );
            $block->store();

            foreach ( $parameters as $name => $definition )
            {
                $value = $http->hasPostVariable( 'Parameter_' . $name ) ? $http->postVariable( 'Parameter_' . $name ) : '';
                \expLayoutsBlockParameter::set( $blockId, $name, $value );
            }

            if ( $hasCollection && $http->hasPostVariable( 'CollectionType' ) )
            {
                if ( !$collection )
                {
                    $collection = \expLayoutsCollection::create( $blockId, trim( $http->postVariable( 'CollectionType' ) ) );
                    $collection->store();
                }
                $collection->setAttribute( 'collection_type', trim( $http->postVariable( 'CollectionType' ) ) );
                $collection->setAttribute( 'offset_value', (int)$http->postVariable( 'CollectionOffset' ) );
                $collection->setAttribute( 'limit_value', (int)$http->postVariable( 'CollectionLimit' ) );
                $collection->store();
            }

            $message = \ezpI18n::tr( 'design/admin/explayouts_ui/block_edit', 'Block saved.' );
            $existingParams = array();
            foreach ( \expLayoutsBlockParameter::fetchByBlock( $blockId ) as $param )
            {
                $existingParams[$param->attribute( 'name' )] = $param->attribute( 'value' );
            }
            $collection = \expLayoutsCollection::fetchByBlock( $blockId );
        }

        if ( $http->hasPostVariable( 'AddCollectionItem' ) && $hasCollection )
        {
            if ( !$collection )
            {
                $collection = \expLayoutsCollection::create( $blockId, 'manual' );
                $collection->store();
            }
            $nodeId = (int)$http->postVariable( 'CollectionNodeID' );
            if ( $nodeId > 0 )
            {
                $item = \expLayoutsCollectionItem::create( $collection->attribute( 'id' ), $nodeId );
                $item->store();
                $message = \ezpI18n::tr( 'design/admin/explayouts_ui/block_edit', 'Item added to collection.' );
            }
            else
            {
                $error = \ezpI18n::tr( 'design/admin/explayouts_ui/block_edit', 'Invalid Node ID.' );
            }
        }

        if ( $http->hasPostVariable( 'RemoveCollectionItem' ) && $collection )
        {
            $itemId = (int)$http->postVariable( 'CollectionItemID' );
            $item = \expLayoutsCollectionItem::fetch( $itemId );
            if ( $item && (int)$item->attribute( 'collection_id' ) === (int)$collection->attribute( 'id' ) )
            {
                $item->remove();
                $message = \ezpI18n::tr( 'design/admin/explayouts_ui/block_edit', 'Item removed from collection.' );
            }
        }

        $collectionItems = array();
        if ( $collection )
            $collectionItems = \expLayoutsCollectionItem::fetchByCollection( $collection->attribute( 'id' ) );

        $viewTypes = isset( $blockInfo['view_types'] ) ? $blockInfo['view_types'] : array( 'default' );

        $tpl = \eZTemplate::factory();
        $tpl->setVariable( 'block', $block );
        $tpl->setVariable( 'parameters', $parameters );
        $tpl->setVariable( 'existing_params', $existingParams );
        $tpl->setVariable( 'view_types', $viewTypes );
        $tpl->setVariable( 'has_collection', $hasCollection );
        $tpl->setVariable( 'collection', $collection );
        $tpl->setVariable( 'collection_items', $collectionItems );
        $tpl->setVariable( 'message', $message );
        $tpl->setVariable( 'error', $error );

        $Result = array();
        $Result['content'] = $tpl->fetch( 'design:explayouts_ui/block_edit.tpl' );
        $Result['path'] = array( array( 'url' => false,
                                        'text' => \ezpI18n::tr( 'explayouts_ui/block', 'Edit Block' ) ) );
        return $this->viewResult( isset( $Result ) ? $Result : null,  $Result );

        return $this->viewResult( isset( $Result ) ? $Result : null, null );
    }
}

}
