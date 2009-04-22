class kbp-zope inherits zope {
	include kbp-nginx

	define site($path, $port, $serveralias=false, $template="kbp-zope/nginx/site.erb") {
		# Set up a virtual host configuration in Nginx which proxies
		# traffic for Zope.
		#
		# Arguments:
		#
		#     $path	      Path of the site in the Zope instances.
		#     $port	      Port on which the Zope instance is listening.
		#     $serveralias    Optional - (Array of) serveralias(es)
		#     $template       Optional - Template to be used for the virtual host
		#		      definition in Nginx.  Should contain the proxy settings.
		#
		# Example:
		#
		#     zope_site { "www.example.org":
		#	    $path => "/example",
		#	    $port => 9673,
		#	    $internal_only => true,
		#    }
		#
		#    Will create a virtual host definition in Nginx for
		#    http://www.example.org/.  All traffic will be proxied to
		#    http://localhost:9673/example.

		$server = "localhost"
		$domain = $name

		nginx::site_config { "$domain":
			content => template($template),
		}

		nginx::site { "$domain":
			ensure => present,
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
			$server = "localhost"
			$path = ""
			$serveralias = $aliases

			nginx::site_config { "$domain":
				content => template("kbp-zope/nginx/site.erb"),
			}

			nginx::site { "$domain":
				ensure => present,
			}
		}

		file {
			"/etc/munin/plugins/zope_cache_status_$port":
				ensure => symlink,
				target => "/usr/local/share/munin/plugins/zope_cache_status",
				notify => Service["munin-node"],
				require => File["/usr/local/share/munin/plugins"];
			"/etc/munin/plugins/zope_db_activity_$port":
				ensure => symlink,
				target => "/usr/local/share/munin/plugins/zope_db_activity",
				notify => Service["munin-node"],
				require => File["/usr/local/share/munin/plugins"];
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

		instance { "$name":
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
}
