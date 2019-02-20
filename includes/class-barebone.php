<?php
/**
 * Main Plugin Class
 *
 * @package Barebone_Plugin
 */

// If this file is called directly, abort.
if ( ! defined( 'ABSPATH' ) ) {
	die;
}

if ( ! class_exists( 'Barebone' ) ) {

	/**
	 * Main plugin class
	 */
	class Barebone {

		/**
		 * The instance of the class Barebone
		 *
		 * @since 1.5
		 *
		 * @access protected
		 *
		 * @var Barebone
		 */
		protected static $instance = null;

		/**
		 * Variable to store options
		 *
		 * @var mixed
		 */
		private $option;

		/**
		 * Default option
		 *
		 * @var string
		 */
		private static $default_option = 'Hello World';

		/**
		 * Constructor for the class
		 */
		public function __construct() {
			add_action( 'init', array( $this, 'init' ) );
			add_action( 'plugins_loaded', array( $this, 'init_localization' ) );
			add_action( 'wp_enqueue_scripts', array( $this, 'enqueue_scripts' ) );
		}

		/**
		 * Returns the current instance of the class
		 *
		 * @return Barebone Returns the current instance of the class
		 */
		public static function get_instance() {

			// If the single instance hasn't been set, set it now.
			if ( null === self::$instance ) {
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

		/**
		 * Init Function
		 */
		public function init() {
			$this->option = $this->get_option();
		}

		/**
		 * Enqueue our scripts and styles
		 */
		public function enqueue_scripts() {
			// Registering our admin styles and scripts.
			wp_register_style( 'barebone', BB_URL . 'public/css/barebone.min.css', array(), BB_VERSION );
			wp_register_script( 'barebone', BB_URL . 'public/js/barebone.min.js', array( 'jquery' ), BB_VERSION, true );

			// Enqueueing our admin styles and scripts.
			wp_enqueue_style( 'barebone' );
			wp_enqueue_script( 'barebone' );
		}

		/**
		 * Returns the option for the plugin
		 *
		 * @return mixed Option for the plugin
		 */
		public function get_option() {
			return get_option( BB_SETTINGS_SLUG, self::$default_option );
		}

	}

	Barebone::get_instance();
}
