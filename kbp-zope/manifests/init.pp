class kbp-zope inherits zope {
	define site($path, $port, $serveralias=false, $template=false, $ssl=false) {
		# Set up a virtual host configuration in Nginx or Apache
		# (depending on which is installed), for proxying traffic from
		# and to Zope.
		#
		# Arguments:
		#
		#     $path	      Path of the site in the Zope instances.
		#     $port	      Port on which the Zope instance is listening.
		#     $serveralias    Optional - (Array of) serveralias(es)
		#     $template       Optional - Template to be used for the virtual host
		#		      definition in Nginx or Apache.  Should contain the
		#                     proxy settings.
		#     $ssl            Optional - Enable https for the site?
		#
		# Example:
		#
		#     zope_site { "www.example.org":
		#	    $path => "/example",
		#	    $port => 9673,
		#	    $internal_only => true,
		#    }
		#
		#    Will create a virtual host definition in Nginx or Apache
		#    for http://www.example.org/.  All traffic will be proxied
		#    to http://localhost:9673/example.

		$server = "localhost"
		$domain = $name

		# XXX There must be a way to make this cleaner. E.g.:
		#
		# $webserver = "nginx"
		# $webserver::site_config { $domain:
		#	template => template("kbp-zope/$webserver/site.erb")
		# }
		# $webserver::site { "$domain":
		#		ensure => present,
		# }
		#
		# But that doesn't work. (It would also require making the
		# nginx and apache types more alike.)

		if tagged(nginx) {
			if $template {
				nginx::site_config { "$domain":
					content => template($template),
					serveralias => $serveralias,
				 }
			} else {
				nginx::site_config { "$domain":
					content => template("kbp-zope/nginx/site.erb"),
					serveralias => $serveralias,
				}
			}

			nginx::site { "$domain":
				ensure => present,
			}
		}

		if tagged(apache) {
			if $template {
				apache::site_config { "$domain":
					address => $ipaddress,
					template => $template,
					serveralias => $serveralias,
				 }
			} else {
				apache::site_config { "$domain":
					address => $ipaddress,
					template => "kbp-zope/apache/site.erb",
					serveralias => $serveralias,
				 }
			}

			apache::site { "$domain":
				ensure => present,
			}
		}
	}

	define instance($port, $domain=false, $aliases=false, $debugmode=false,
	                $zodbcachesize=20000, $zeosocket=false, $products_from=false,
			$user="zope", $group="zope") {
		# Set up a local Zope instance
		#
		# Arguments:
		#
		#     $port          TCP port on which the Zope instance should be listening.
		#     $domain        Optional - Domain to use for the ZMI site.
		#     $aliases       Optional - Domain aliases which point to the same ZMI site.
		#     $debugmode     Optional - Run this Zope instance in debug mode?
		#     $zeosocket     Optional - The socket of the ZEO server this instance should use.
		#     $products_from Optional - Use the products from the specified Zope instance.
		#     $user          Optional - User to run the Zope instance as.
		#     $group         Optional - Group to run the Zope instance as.
		#
		# Example:
		#
		#     zope_instance { "dev":
		#         port => 9673,
		#         debugmode => true,
		#         zeosocket => "/srv/zope2.9/zeo/dev/var/zeo.sock",
		#         user => "zopedev",
		#         group => "zopedev";
		#    }
		#
		#    This will create a Zope instance and a ZEO server, both
		#    named "dev". The Zope instance will listen on port 9673,
		#    debug mode will be enabled, and it will run with user and
		#    group "zopedev".

		include zope::server
		include munin::client

		zope::server::instance { "$name":
			port => $port,
			debugmode => $debugmode,
			zodbcachesize => $zodbcachesize,
			zeosocket => $zeosocket,
			products_from => $products_from,
			user => $user,
			group => $group,
		}

		if $domain {
			kbp-zope::site { $domain:
				port => $port,
				path => $path,
				serveralias => $aliases,
			}
		}

		if tagged(apache) {
			# Allow Apache to proxy to the Zope instance
			file { "/etc/apache2/conf.d/zope-$name":
				owner => "root",
				group => "root",
				mode => 644,
				content => template("kbp-zope/apache/proxy.erb"),
				require => Apache::Module["proxy_http"],
			}
		}

		munin::client::plugin {
			"zope_cache_status_$port":
				script_path => "/usr/local/share/munin/plugins",
				script => "zope_cache_status";
			"zope_db_activity_$port":
				script_path => "/usr/local/share/munin/plugins",
				script => "zope_db_activity";
		}
	}

	define instance_with_local_zeo($port, $domain=false, $aliases=false, $debugmode=false, $zodbcachesize=20000, $user="zope", $group="zope") {
		# Set up a local Zope instance, with corresponding ZEO instance.
		#
		# Arguments:
		#
		#     $port       TCP port on which the Zope instance should be listening.
		#     $domain     Optional - Domain to use for the ZMI site.
		#     $aliases    Optional - Domain aliases which point to the same ZMI site.
		#     $debugmode  Optional - Run this Zope instance in debug mode?
		#     $user       Optional - User to run the Zope instance as.
		#     $group      Optional - Group to run the Zope instance as.
		#
		# Example:
		#
		#     zope_instance_with_local_zeo { "dev":
		#         port => 9673,
		#         debugmode => true,
		#         user => "zopedev",
		#         group => "zopedev";
		#    }
		#
		#    This will create a Zope instance and a ZEO server, both
		#    named "dev". The Zope instance will listen on port 9673,
		#    debug mode will be enabled, and it will run with user and
		#    group "dev".

		include zope::zeo

		kbp-zope::instance { "$name":
			port => $port,
			domain => $domain,
			aliases => $aliases,
			debugmode => $debugmode,
			zodbcachesize => $zodbcachesize,
			zeosocket => "/srv/zope2.9/zeo/$name/var/zeo.sock",
			user => $user,
			group => $group,
			require => Zope::Zeo::Instance["$name"],
		}

		zope::zeo::instance { "$name":
			socket => "/srv/zope2.9/zeo/$name/var/zeo.sock",
			user => $user,
			group => $group,
		}
	}

	if tagged(apache) {
		apache::module {
			"proxy":
				ensure => present;
			"proxy_http":
				ensure => present,
				require => Apache::Module["proxy"];
		}
	}
}
