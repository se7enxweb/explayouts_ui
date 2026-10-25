<?php
/**
 * The rule templates of both admin designs: labels from the rules are washed, the controls that act on the page are
 * buttons, every field has a name for assistive technology, and the page script builds its markup without strings.
 *
 * @license GPL-2.0-or-later
 */
use PHPUnit\Framework\TestCase;

class RuleTemplatesTest extends TestCase
{
    public static function designs()
    {
        return array( 'admin' => array( 'admin' ), 'admin4' => array( 'admin4' ) );
    }

    protected function template( $design, $name )
    {
        $file = dirname( __DIR__ ) . '/design/' . $design . '/templates/explayouts_ui/' . $name;
        $this->assertFileExists( $file );
        return file_get_contents( $file );
    }

    #[\PHPUnit\Framework\Attributes\DataProvider( 'designs' )]
    public function testLabelsFromTheRulesAreWashed( $design )
    {
        $tpl = $this->template( $design, 'rule_detail.tpl' ) . $this->template( $design, 'rule_list.tpl' );
        foreach ( array( 'targetLabel', 'targetItemLabel', 'conditionItemLabel', 'targetTypeLabel' ) as $var )
        {
            $this->assertDoesNotMatchRegularExpression( '/\{\$' . $var . '\}/', $tpl, $var . ' is output unwashed' );
            $this->assertDoesNotMatchRegularExpression( '/hash\(\s*\'%\w+\',\s*\$' . $var . '\s*\)/', $tpl, $var . ' goes unwashed into an i18n argument' );
        }
    }

    /**
     * Every label variable of the rule templates falls back to the stored type when it has no translation, so none of
     * them may reach the page unwashed, whatever its name (ruleTargetTypeLabel, rowConditionLabel ...).
     */
    #[\PHPUnit\Framework\Attributes\DataProvider( 'designs' )]
    public function testNoLabelVariableIsOutputUnwashed( $design )
    {
        foreach ( array( 'rule_detail.tpl', 'rule_list.tpl', 'rule_edit.tpl' ) as $name )
        {
            $file = dirname( __DIR__ ) . '/design/' . $design . '/templates/explayouts_ui/' . $name;
            if ( !is_file( $file ) )
                continue;
            preg_match_all( '/\{\$(\w*Label)\s*\}/i', file_get_contents( $file ), $m );
            $this->assertSame( array(), $m[1], $design . '/' . $name . ' prints label variables unwashed' );
        }
    }

    #[\PHPUnit\Framework\Attributes\DataProvider( 'designs' )]
    public function testPageActionsAreButtons( $design )
    {
        $tpl = $this->template( $design, 'rule_detail.tpl' );
        foreach ( array( 'js-rule-edit', 'js-remove-row', 'js-add-target', 'js-add-condition', 'js-toggle-body' ) as $hook )
            $this->assertDoesNotMatchRegularExpression( '/<a\b[^>]*\b' . $hook . '\b/', $tpl, $hook . ' is a link' );
    }

    #[\PHPUnit\Framework\Attributes\DataProvider( 'designs' )]
    public function testTypeSelectsAndTextFieldsHaveNames( $design )
    {
        $tpl = $this->template( $design, 'rule_detail.tpl' );
        foreach ( array( 'js-target-type', 'js-condition-type' ) as $hook )
        {
            $this->assertMatchesRegularExpression( '/<select[^>]*' . $hook . '"[^>]*id="([^"]+)"/', $tpl );
            preg_match( '/<select[^>]*' . $hook . '"[^>]*>/', $tpl, $m );
            preg_match( '/id="([^"]+)"/', $m[0], $id );
            $this->assertTrue( strpos( $m[0], 'aria-label=' ) !== false || strpos( $tpl, '<label class="a4-sr-only" for="' . $id[1] . '"' ) !== false,
                               $hook . ' has no label' );
        }
        preg_match_all( '/<input[^>]*type="text"[^>]*name="(?:Target|Condition)Value\[\]"[^>]*>/', $tpl, $inputs );
        $this->assertNotEmpty( $inputs[0] );
        foreach ( $inputs[0] as $input )
            $this->assertStringContainsString( 'aria-label=', $input );
    }

    public function testThePageScriptBuildsNoMarkupFromStrings()
    {
        // the page script is a file since 1.3.20, printed by parts/rule_list_script.tpl
        $this->assertStringContainsString( "{ezscript( array( 'explayouts_ui_rule_list.js' ) )}", $this->template( 'admin', 'parts/rule_list_script.tpl' ) );
        $script = file_get_contents( dirname( __DIR__ ) . '/design/admin/javascript/explayouts_ui_rule_list.js' );
        $this->assertStringNotContainsString( 'innerHTML', $script );
        $this->assertStringNotContainsString( 'insertAdjacentHTML', $script );
        $this->assertStringNotContainsString( '<a href="#" class="remove-setting', $script );
    }

    public function testANewListConditionOpensItsList()
    {
        // a new class or siteaccess condition has an empty value list: its multiple select opens at once, on adding
        // the condition and on changing its type, instead of waiting for a click on an empty value
        $script = file_get_contents( dirname( __DIR__ ) . '/design/admin/javascript/explayouts_ui_rule_list.js' );
        $this->assertStringContainsString( 'function openConditionList(li)', $script );
        $this->assertStringContainsString( "list.appendChild(li);\n            if (isMulti) openConditionList(li);", $script );
        $this->assertStringContainsString( 'if (multi) openConditionList(li);', $script );
    }
}
