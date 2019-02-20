<?php
/**
 * Class SampleTest
 *
 * @package Barebone
 */

/**
 * Sample test case.
 */
class BareBone_Tests extends WP_UnitTestCase {

	/**
	 * Instance of the plugin class.
	 *
	 * @var Barebone
	 */
	private $barebone;

	/**
	 * Setting up the test set
	 */
	public function setUp() {
		$this->barebone = Barebone::get_instance();
	}

	/**
	 * A single example test.
	 */
	public function test_get_option() {
		$option  = $this->barebone->get_option();
		$default = 'Hello World';
		$this->assertEquals( $option, $default );
	}

}
