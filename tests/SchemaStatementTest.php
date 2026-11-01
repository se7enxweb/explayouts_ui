<?php
/**
 * The setup page skips every statement of a table that exists already; expLayoutsUiSchemaStatement::tableOf() tells
 * it the table, from the statements of each dialect's schema file.
 *
 * @license GPL-2.0-or-later
 */
use PHPUnit\Framework\TestCase;

class SchemaStatementTest extends TestCase
{
    public static function statements()
    {
        return array(
            'mysql table'            => array( 'CREATE TABLE explayouts_zone ( id int )', 'explayouts_zone' ),
            'pgsql table'            => array( 'CREATE TABLE IF NOT EXISTS explayouts_rule_target ( id int )', 'explayouts_rule_target' ),
            'pgsql sequence'         => array( 'CREATE SEQUENCE IF NOT EXISTS explayouts_block_parameter_id_seq', 'explayouts_block_parameter' ),
            'pgsql key'              => array( 'ALTER TABLE ONLY explayouts_block ADD CONSTRAINT explayouts_block_pkey PRIMARY KEY ( id )', 'explayouts_block' ),
            'index named idx_'       => array( 'CREATE UNIQUE INDEX idx_share_token ON explayouts_share ( token )', 'explayouts_share' ),
            'oracle index'           => array( 'CREATE UNIQUE INDEX explayouts_share_idx_token ON explayouts_share ( token )', 'explayouts_share' ),
            'oracle sequence'        => array( 'CREATE SEQUENCE se_explayouts_layout MINVALUE 1', 'explayouts_layout' ),
            'oracle trigger'         => array( "CREATE OR REPLACE TRIGGER explayouts_layout_tr BEFORE INSERT ON explayouts_layout FOR EACH ROW", 'explayouts_layout' ),
            'quoted'                 => array( 'CREATE TABLE `explayouts_rule` ( id int )', 'explayouts_rule' ),
            'kernel table'           => array( 'CREATE TABLE eztags ( id int )', '' ),
        );
    }

    /**
     * @dataProvider statements
     */
    #[\PHPUnit\Framework\Attributes\DataProvider( 'statements' )]
    public function testTheTableOfAStatement( $statement, $table )
    {
        $this->assertSame( $table, expLayoutsUiSchemaStatement::tableOf( $statement ) );
    }

    /** Every own statement of every shipped schema file names its table (run where explayouts sits next to it). */
    public function testEveryStatementOfTheSchemaFilesHasATable()
    {
        $sqlDir = dirname( __DIR__, 2 ) . '/explayouts/sql';
        $install = dirname( __DIR__, 2 ) . '/explayouts/classes/explayoutsinstall.php';
        if ( !is_dir( $sqlDir ) || !is_file( $install ) )
            $this->markTestSkipped( 'explayouts is not installed next to explayouts_ui' );
        require_once $install;
        if ( !is_callable( array( 'expLayoutsInstall', 'ownStatements' ) ) )
            $this->markTestSkipped( 'this explayouts has no expLayoutsInstall::ownStatements()' );
        $files = glob( $sqlDir . '/*/schema.sql' );
        $this->assertNotEmpty( $files );
        foreach ( $files as $file )
            foreach ( expLayoutsInstall::ownStatements( file_get_contents( $file ) ) as $statement )
                $this->assertNotSame( '', expLayoutsUiSchemaStatement::tableOf( $statement ), basename( dirname( $file ) ) . ': ' . substr( $statement, 0, 80 ) );
    }
}
