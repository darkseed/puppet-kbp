class kbp-tomcat inherits tomcat {
	include apache
	include kbp-java

	# Sets up a Tomcat instance, the Apache configuration, and adds
	# optional Nagios checks.
	#
	# Arguments:
	# [+projectid+]
	#   A number which is used to generate some other settings, such as the
	#   port number Tomcat will listen on. Needs to be unique for this
	#   reason. Start with 8 for the first Tomcat instance, then increase
	#   for each additional instance.
	# [+domain+]
	#   The canonical domain name which points to the website.
	# [+serveralias+]
	#   Domain aliases which also point to this site. This can either be a
	#   string or an array.
	# [+path+]
	#   The path where the application lives. This is "/" by default, which
	#   means the application will receive all requests for the domain.
	# [+documentroot+]
	#   Optional directory where files which need to be served by Apache
	#   can be placed. This is useful if most of the site is static, and
	#   only +path+ contains the dynamically generated HTML. All requests
	#   which do not fall under +path+ will get served from +documentroot+
	#   by Apache. It only makes sense to set this when +path+ is not "/".
	# [+ipaddress+]
	#   IP address of the host. It's usually okay to leave this at the
	#   default.
	# [+ssl+]
	#   Configure HTTPS for this site.
	# [+ensure+]
	#   Determines if the Tomcat instance should be started on bootups and
	#   whether monitoring should be enabled. Valid values are +running+
	#   and +stopped+. Setting +ensure+ to +running+ will not prevent you
	#   from stopping it manually: the Tomcat instance is only restarted
	#   when the server boots.
	# [+heap_size+]
	#   JVM heap size. +256M+ by default, which may need to be increased
	#   for high traffic sites.
	# [+permgen_size+]
	#   Permanent Generation memory size, +128M+ by default. Sometimes it's
	#   needed to increase this for certain applications. We only set the
	#   maximum permgen space and leave the rest up to the VM.
	# [+clustering+]
	#   If +true+, this will enable Tomcat session replication, which is
	#   useful when using a cluster of Tomcat instances with round-robin
	#   load-balancing. Default is +false+.
	# [+remote_debugging+]
	#   If +true+, allow connecting to port ${project_id}012 for a remote
	#   debugging session.
	# [+extra_java_opts+]
	#   Optional string which will be passed to the Java command as a
	#   command line argument.
	# [+check_path+]
	#   The path that contains the check page for Nagios. Default is
	#   +/live.html+.
	# [+check_response+]
	#   The string that should be in the file refered to in check_path.
	# [+check_priority+]
	#   Priority for the check that checks Tomcat for availability. The
	#   default (+important+) is good for sites in the production
	#   environment. Valid options are "optional", "important" and
	#   "critical".
	#
	define project($projectid, $domain, $serveralias=false, $path="/",
		       $documentroot=false, $group=$customer,
		       $ipaddress=$ipaddress, $ssl=false,
		       $ensure="running",
		       $heap_size="256M", $clustering=false,
		       $permgen_size="128M",
		       $remote_debugging=false,
		       $tomcat_http_port="", $war="",
		       $check_path="/live.html", $check_response="",
		       $check_priority="important",
		       $extra_java_opts=false) {
		$tomcatinstance = $name

		# Make sure the multicast addresses which are used are unique
		# for the Tomcat projects.
		$env_id = $environment ? {
			production	=> "1",
			staging		=> "2",
			development	=> "3",
			default		=> undef,
		}

		if $clustering {
			if ($env_id > 0) and ($customer_id > 0) and ($projectid > 0) {
				$session_replication_mcast_addr = "229.${customer_id}.${env_id}.${projectid}"

				# The port needs to be unique, but it only
				# needs to be unique for all Tomcats on this
				# host, as long as each project uses a
				# different multicast address. See
				# http://jboss.org/community/docs/DOC-11710 for
				# details.
				#
				# Setting mcastBindAddress to the multicast
				# address doesn't work, although
				# http://www.jboss.org/community/docs/DOC-9469
				# seems to imply it should.
				$session_replication_mcast_port = 45560 + $projectid
				$enable_clustering = true
			} else {
				warning("No valid environment, customer_id or projectid found: disabling clustering.")
				$session_replication_mcast_addr = "auto"
				$session_replication_mcast_port = "45564"
				$enable_clustering = false
			}
		} else {
			$session_replication_mcast_addr = "auto"
			$session_replication_mcast_port = "45564"
			$enable_clustering = false
		}

		if $tomcat_http_port {
			$http_port = $tomcat_http_port
		} else {
			$http_port = "${projectid}180"
		}

		$ajp13_connector_port = "${projectid}009"
		apache_proxy_ajp_site { "$domain":
			ssl => $ssl,
			port => $ajp13_connector_port,
			serveralias => $serveralias,
			documentroot => $documentroot,
			path => $path,
			require => Tomcat::Instance[$tomcatinstance],
			ensure => $ensure ? {
				running => "present",
				stopped => "absent",
			}
		}

		$jmx_port = "${projectid}016"
		$remote_debugging_port = "${projectid}012"

		tomcat::instance { $tomcatinstance:
			ensure => $ensure,
			group => $group,
			heap_size => $heap_size,
			permgen_size => $permgen_size,
			clustering => $clustering,
			remote_debugging => $remote_debugging,
			shutdown_port => "${projectid}005",
			session_replication_port => "${projectid}006",
			session_replication_mcast_addr => $session_replication_mcast_addr,
			http_connector_port => $http_port,
			ajp13_connector_port => $ajp13_connector_port,
			jmx_port => $jmx_port,
			remote_debugging_port => $remote_debugging_port,
			session_replication_mcast_domain => "$tomcatinstance.$environment.$customer",
		}

		# This is needed to be able to create some pretty graphs of the
		# Tomcat instance resource usage with Munin through JMX.
		file {
			"/etc/munin/plugins/jmx_${name}_${jmx_port}_java_process_memory":
				ensure => $ensure ? {
					running => "/usr/local/share/munin/plugins/jmx_",
					stopped => "absent",
				},
				notify => Service["munin-node"];
			"/etc/munin/plugins/jmx_${name}_${jmx_port}_java_threads":
				ensure => $ensure ? {
					running => "/usr/local/share/munin/plugins/jmx_",
					stopped => "absent",
				},
				notify => Service["munin-node"];
		}

		# Keep the logfiles cleaned up
		tidy { "/srv/tomcat/$tomcatinstance/logs/":
			matches => "*",
			age     => "4w",
			recurse => 1,
		}
	}

	# Sets the Apache virtual host definition.
	#
	# Arguments:
	# [+port+]
	#   The port number on which the Tomcat AJP connector is listening.
	# [+ssl+]
	#   Configure HTTPS for this site.
	# [+serveralias+]
	#   Domain aliases which also point to this site. This can either be a
	#   string or an array.
	# [+path+]
	#   The path where the application lives. This is "/" by default, which
	#   means the application will receive all requests for the domain.
	# [+documentroot+]
	#   Optional directory where files which need to be served by Apache
	#   can be placed. This is useful if most of the site is static, and
	#   only +path+ contains the dynamically generated HTML. All requests
	#   which do not fall under +path+ will get served from +documentroot+
	#   by Apache. It only makes sense to set this when +path+ is not "/".
	# [+ipaddress+]
	#   IP address of the host. It's usually okay to leave this at the
	#   default.
	#
	define apache_proxy_ajp_site($port,
		                     $ssl=false,	
		                     $serveralias=false,
				     $path="/",
		                     $documentroot=false,
				     $ipaddress=$ipaddress,
				     $ensure="present") {

		apache::site_config { $name:
			ssl => $ssl,
			serveralias => $serveralias,
			ipaddress => $ipaddress,
			documentroot => $documentroot,
			template => "kbp-tomcat/apache/mod-proxy-ajp.conf",
			require => Apache::Module["proxy_ajp"],
		}

		apache::site { $name:
			ensure => $ensure,
		}
	}

	# Enable mod-proxy-ajp
	apache::module { "proxy_ajp":
		ensure => present,
	}

	# Enable the Munin plugins for Apache
	file {
		"/etc/munin/plugins/apache_accesses":
			ensure => "/usr/share/munin/plugins/apache_accesses",
			notify => Service["munin-node"],
			require => Package["libwww-perl"];
		"/etc/munin/plugins/apache_processes":
			ensure => "/usr/share/munin/plugins/apache_processes",
			notify => Service["munin-node"],
			require => Package["libwww-perl"];
		"/etc/munin/plugins/apache_volume":
			ensure => "/usr/share/munin/plugins/apache_volume",
			notify => Service["munin-node"],
			require => Package["libwww-perl"];
	}

	# libwww-perl is needed for the above Munin plugins
	package { "libwww-perl":
		ensure => installed,
	}

	# JARs which are needed
	package { "libmysql-java":
		ensure => installed,
	}

	file { "/usr/share/tomcat5.5/common/lib/mysql-connector-java.jar":
		ensure => "/usr/share/java/mysql-connector-java.jar",
		require => Package["libmysql-java"],
        }

        # This is a housekeeping define, it needs to be set explicitly to allow for logfile
        # archiving and removal
        define keepclean ($ensure = present, $compress_after_days = 30, $remove_after_days = 60) {
                file { "/etc/cron.daily/archive-tomcat-logfiles":
                        ensure => $ensure,
                        mode => 755,
                        content => template("kbp-tomcat/cron.daily/archive-tomcat-logfiles.erb"),
                }
        }
}
