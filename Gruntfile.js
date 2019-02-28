
module.exports = function ( grunt ) {

	grunt.initConfig( {
		pkg: grunt.file.readJSON( 'package.json' ),
		wp_readme_to_markdown: {
			dist: {
				options: {
					screenshot_url: '<%= pkg.repository.url %>/raw/master/assets/{screenshot}.png',
					post_convert: function ( file ) {
						var travis_badge = "[![Build Status](https://travis-ci.org/gagan0123/barebone.svg?branch=master)](https://travis-ci.org/gagan0123/barebone)";
						var gitlab_badge = "[![Build Status](https://gitlab.com/gagan0123/barebone-plugin/badges/master/build.svg)](https://gitlab.com/gagan0123/barebone-plugin/pipelines)";
						var tested_on_badge = "[![Tested On](https://img.shields.io/badge/Tested%20on-WP%205.1%20%7C%205.0.3%20%7C%204.9.9%20%7C%204.8.8%20%7C%204.7.12%20%7C%204.6.13%20%7C%204.5.16%20%7C%204.4.17%20%7C%204.3.18%20%7C%204.2.22%20%7C%204.1.25%20%7C%204.0.25%20%7C%20nightly-brightgreen.svg?maxAge=2419200)](https://gitlab.com/gagan0123/barebone-plugin/pipelines)";
						var project_icon = "\n<img src='" + grunt.config.get( 'pkg' ).repository.url + "/raw/master/assets/icon-128x128.png' align='right' />\n\n";
						return travis_badge + ' ' + gitlab_badge + ' ' + tested_on_badge + project_icon + file;
					}
				},
				files: {
					'README.md': 'readme.txt'
				}
			}
		},
		sass: {
			dist: {
				options: {
					style: 'compressed'
				},
				files: [ {
						expand: true,
						cwd: 'admin/scss',
						src: [
							'*.scss'
						],
						dest: 'admin/css',
						ext: '.min.css'
					}, {
						expand: true,
						cwd: 'public/scss',
						src: [
							'*.scss'
						],
						dest: 'public/css',
						ext: '.min.css'
					}
				]
			}
		},
		uglify: {
			dist: {
				options: {
					mangle: {
						reserved: [ 'jQuery', '$' ]
					},
					sourceMap: true,
				},
				files: {
					'admin/js/barebone-admin.min.js': [ 'admin/js/barebone-admin.js' ],
					'public/js/barebone.min.js': [ 'public/js/barebone.js' ]
				}
			}
		},
		makepot: {
			target: {
				options: {
					domainPath: '/languages',
					exclude: [ 'node_modules/.*', 'tests/.*' ],
					mainFile: '<%= pkg.main %>',
					potFilename: '<%= pkg.name %>.pot',
					potHeaders: {
						poedit: false,
						'report-msgid-bugs-to': '<%= pkg.bugs.url %>'
					},
					type: 'wp-plugin',
					updateTimestamp: false
				}
			}
		},
		watch: {
			grunt: {
				files: [ 'Gruntfile.js' ]
			},
			sass: {
				files: [ 'admin/scss/*.scss', 'public/scss/*.scss' ],
				tasks: [ 'sass' ]
			},
			uglify: {
				files: [ 'admin/js/*.js', '!admin/js/*.min.js', 'public/js/*.js', '!public/js/*.min.js' ],
				tasks: [ 'uglify' ]
			},
			wp_readme_to_markdown: {
				files: [ 'readme.txt' ],
				tasks: [ 'wp_readme_to_markdown' ]
			}
		}
	} );

	grunt.loadNpmTasks( 'grunt-wp-readme-to-markdown' );
	grunt.loadNpmTasks( 'grunt-contrib-sass' );
	grunt.loadNpmTasks( 'grunt-contrib-uglify' );
	grunt.loadNpmTasks( 'grunt-contrib-watch' );
	grunt.loadNpmTasks( 'grunt-wp-i18n' );

	grunt.registerTask( 'default', [
		'watch'
	] );

};