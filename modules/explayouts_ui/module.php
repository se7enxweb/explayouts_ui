<?php
$Module = array( 'name' => 'explayouts_ui',
                 'variable_params' => true );

$ViewList = array();

$ViewList['layout_list'] = array(
    'script' => 'layout_list.php',
    'functions' => array( 'read' ),
    'default_navigation_part' => 'ezexplayoutsuinavigationpart',
    'params' => array()
);

$ViewList['layout_create'] = array(
    'script' => 'layout_create.php',
    'functions' => array( 'edit' ),
    'default_navigation_part' => 'ezexplayoutsuinavigationpart',
    'params' => array()
);

$ViewList['layout_edit'] = array(
    'script' => 'layout_edit.php',
    'functions' => array( 'edit' ),
    'default_navigation_part' => 'ezexplayoutsuinavigationpart',
    'params' => array( 'LayoutID' )
);

$ViewList['rule_list'] = array(
    'script' => 'rule_list.php',
    'functions' => array( 'read' ),
    'default_navigation_part' => 'ezexplayoutsuinavigationpart',
    'params' => array()
);

$ViewList['shared_layouts_list'] = array(
    'script' => 'shared_layouts_list.php',
    'functions' => array( 'read' ),
    'default_navigation_part' => 'ezexplayoutsuinavigationpart',
    'params' => array()
);

$ViewList['rule_edit'] = array(
    'script' => 'rule_edit.php',
    'functions' => array( 'edit' ),
    'default_navigation_part' => 'ezexplayoutsuinavigationpart',
    'params' => array( 'RuleID' )
);

$ViewList['block_edit'] = array(
    'script' => 'block_edit.php',
    'functions' => array( 'edit' ),
    'default_navigation_part' => 'ezexplayoutsuinavigationpart',
    'params' => array( 'BlockID' )
);

$ViewList['dashboard'] = array(
    'script' => 'dashboard.php',
    'functions' => array( 'read' ),
    'default_navigation_part' => 'ezexplayoutsuinavigationpart',
    'params' => array()
);

$ViewList['layout_preview'] = array(
    'script' => 'preview.php',
    'functions' => array( 'read' ),
    'default_navigation_part' => 'ezexplayoutsuinavigationpart',
    'params' => array( 'LayoutID', 'Status' )
);

$ViewList['setup'] = array(
    'script' => 'setup.php',
    'functions' => array( 'edit' ),
    'default_navigation_part' => 'ezexplayoutsuinavigationpart',
    'params' => array()
);

$ViewList['template_editor'] = array(
    'script' => 'template_editor.php',
    'functions' => array( 'read', 'edit' ),
    'default_navigation_part' => 'ezexplayoutsuinavigationpart',
    'params' => array( 'FilePath' )
);

$ViewList['transfer_import'] = array(
    'script' => 'transfer_import.php',
    'functions' => array( 'edit' ),
    'default_navigation_part' => 'ezexplayoutsuinavigationpart',
    'params' => array()
);

$ViewList['components'] = array(
    'script' => 'components.php',
    'functions' => array( 'read' ),
    'default_navigation_part' => 'ezexplayoutsuinavigationpart',
    'params' => array()
);

$FunctionList = array();
$FunctionList['read'] = array();
$FunctionList['edit'] = array();
