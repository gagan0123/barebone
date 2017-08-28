<?php
// If this file is called directly, abort.
if ( ! defined( 'ABSPATH' ) ) {
	die;
}

if ( ! class_exists( 'Barebone_Admin' ) ) {

	class Barebone_Admin {

		/**
		 * Holds the values to be used in the fields callbacks
		 */
		protected static $instance = null;

		/**
		 * Start up
		 */
		public function __construct() {
			add_action( 'admin_init', array( $this, 'page_init' ) );
			add_action( 'admin_enqueue_scripts', array( $this, 'admin_enqueue_scripts' ) );
		}

		/**
		 * @return Barebone_Admin Returns the current instance of the Barebone_Admin class
		 */
		public static function get_instance() {

			// If the single instance hasn't been set, set it now.
			if ( null == self::$instance ) {
				self::$instance = new self;
			}

			return self::$instance;
		}

		/**
		 * Register and add settings
		 */
		public function page_init() {

			// Barebone settings slug
			$setting_id = BB_SETTINGS_SLUG;

			// Barebone Setting Label
			$label = '<label for="' . $setting_id . '">' . __( 'Barebone Setting', 'barebone_textdomain' ) . '</label>';

			// This function will render the input field
			$callback = array( $this, 'render_barebone_field' );

			// Adding the setting field
			add_settings_field( $setting_id, $label, $callback, 'general', 'default' );

			// Registering the setting
			register_setting( 'general', $setting_id, array( $this, 'sanitize' ) );
		}

		public function admin_enqueue_scripts( $hook ) {
			if ( $hook != 'options-general.php' ) {
				return;
			}

			// Registering our admin styles and scripts
			wp_register_style( 'barebone-admin', BB_URL . 'admin/css/barebone-admin.min.css', array(), BB_VERSION );
			wp_register_script( 'barebone-admin', BB_URL . 'admin/js/barebone-admin.min.js', array( 'jquery' ), BB_VERSION, true );

			// Enqueueing our admin styles and scripts
			wp_enqueue_style( 'barebone-admin' );
			wp_enqueue_script( 'barebone-admin' );
		}

		/**
		 * Sanitize the input values
		 *
		 * @param array $input Contains all settings fields as array keys
		 */
		public function sanitize( $input ) {

			$setting_id = BB_SETTINGS_SLUG;

			// Sanitizing the input field
			$sanitized_input = sanitize_title( $input );

			$is_error = false;

			$message = '';

			// You need to add your own logic to check the input values being passed
			if ( $sanitized_input === 'Hello World' ) {
				// Input field is correctly set
				return $sanitized_input;
			} elseif ( empty( $input ) ) {
				// Input is empty
				$is_error    = true;
				$message     = esc_html__( 'Barebone Setting field cannot be empty.', 'barebone_textdomain' );
			} else {
				// Input field is containing something that its not supposed to be
				$is_error    = true;
				$message     = esc_html__( 'You can only write "Hello World" in the Barebone Setting field.', 'barebone_textdomain' );
			}

			if ( $is_error ) {
				add_settings_error( $setting_id, 'settings_updated', $message, 'error' );
				// Returning the previous value of the option instead of saving the new incorrect value
				return Barebone::get_instance()->get_option();
			}

			// I know this line will never execute, but still feel like keeping it here :)
			return $sanitized_input;
		}

		/**
		 * Output the Image Quality setting field in Dashboard
		 */
		public function render_barebone_field() {
			// Lets initialize our variables
			$setting_id      = BB_SETTINGS_SLUG;
			$barebone        = Barebone::get_instance();
			$option_value    = $barebone->get_option();

			echo "<input type='text' name='{$setting_id}' id='{$setting_id}' value='{$option_value}' />";
			?> <span class="description"><?php esc_html_e( 'Description you want to the right side of setting', 'barebone_textdomain' ); ?></span>
			<p class="description"><?php esc_html_e( 'This could be some extra description about the setting.', 'barebone_textdomain' ); ?></p>
														<?php
		}

	}

	Barebone_Admin::get_instance();
}
