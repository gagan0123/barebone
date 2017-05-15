<?php

/*
  Plugin Name: Barebone Plugin
  Plugin URI:  https://gagan0123.com/
  Description: Barebone plugin to get started with WordPress plugin development
  Version:     1.0
  Author:      Gagan Deep Singh
  Author URI:  https://gagan0123.com
  License:     GPLv2
  License URI: https://www.gnu.org/licenses/gpl-2.0.html
  Text Domain: barebone_textdomain
  Domain Path: /languages
 */

// If this file is called directly, abort.
if ( !defined( 'ABSPATH' ) ) {
	die;
}

define( 'BB_PREFIX', 'bb' );
define( 'BB_PATH', trailingslashit( plugin_dir_path( __FILE__ ) ) );
define( 'BB_SETTINGS_SLUG', BB_PREFIX . '_my_setting' );

/**
 * The core plugin class
 */
require_once BB_PATH . 'includes/class-barebone.php';

/**
 * Load the admin class if its the admin dashboard
 */
if ( is_admin() ) {
	require_once BB_PATH . 'admin/class-barebone-admin.php';
}