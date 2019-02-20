<?php

// If this file is called directly, abort.
if ( ! defined( 'ABSPATH' ) ) {
	die;
}

if ( ! class_exists( 'Barebone' ) ) {

	class Barebone {

		protected static $instance = null;
		private $option;
		private static $default_option = 'Hello World';

		public function __construct() {
			add_action( 'init', array( $this, 'init' ) );
			add_action( 'plugins_loaded', array( $this, 'init_localization' ) );
			add_action( 'wp_enqueue_scripts', array( $this, 'enqueue_scripts' ) );
		}

		/**
		 * @return Barebone Returns the current instance of the class
		 */
		public static function get_instance() {

			// If the single instance hasn't been set, set it now.
			if ( null == self::$instance ) {
				self::$instance = new self();
			}

			return self::$instance;
		}

		/**
		 * Initialize localization
		 */
		public function init_localization() {
			load_plugin_textdomain( 'barebone_textdomain' );
		}

		public function init() {
			$this->option = $this->get_option();
		}

		public function enqueue_scripts() {
			// Registering our admin styles and scripts
			wp_register_style( 'barebone', BB_URL . 'public/css/barebone.min.css', array(), BB_VERSION );
			wp_register_script( 'barebone', BB_URL . 'public/js/barebone.min.js', array( 'jquery' ), BB_VERSION, true );

			// Enqueueing our admin styles and scripts
			wp_enqueue_style( 'barebone' );
			wp_enqueue_script( 'barebone' );
		}

		public function get_option() {
			return get_option( BB_SETTINGS_SLUG, self::$default_option );
		}

	}

	Barebone::get_instance();
}
