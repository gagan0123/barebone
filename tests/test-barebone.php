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

	private $barebone;

	/**
	 * Setting up the test set
	 */
	function setUp() {
		$this->barebone = Barebone::get_instance();
	}

	/**
	 * A single example test.
	 */
	function test_get_option() {
		$option  = $this->barebone->get_option();
		$default = 'Hello World';
		$this->assertEquals( $option, $default );
	}

}
