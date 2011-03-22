class kbp-munin::client inherits munin::client {
	package { "libnet-snmp-perl":
		ensure => installed,
	}
}

class kbp-munin::client::apache {
	# This class is should be included in kbp-apache to collect apache data for munin
	include kbp-munin::client
	
	package { "libwww-perl":
		ensure => installed;
	}

	file {
		"/etc/apache2/conf.d/server-status":
			content => template("kbp-munin/server-status"),
			owner   => "root",
			group   => "root",
			mode    => 644,
			notify  => Exec["reload-apache2"];
	}

	munin::client::plugin {
		"apache_accesses":;
		"apache_processes":;
		"apache_volume":;
	}
}

class kbp-munin::server inherits munin::server {
	include nagios::nsca

	File["/etc/munin/munin.conf"] {
		source => "puppet://puppet/kbp-munin/server/munin.conf",
	}

	file { "/etc/send_nsca.cfg":
		source => "puppet://puppet/kbp-munin/server/send_nsca.cfg",
		mode => 640,
		owner => "root",
		group => "munin",
		require => Package["nsca"],
	}

	package { "rsync":
		ensure => installed,
	}

	# The RRD files for Munin are stored on a memory backed filesystem, so
	# sync it to disk on reboots.
	file { "/etc/init.d/munin-server":
		source => "puppet://puppet/munin/server/init.d/munin-server",
		mode => 755,
		owner => "root",
		group => "root",
		require => [Package["rsync"], Package["munin"]],
	}

	service { "munin-server":
		enable => true,
		require => File["/etc/init.d/munin-server"],
	}

	exec { "/etc/init.d/munin-server start":
		unless => "/bin/sh -c '[ -d /dev/shm/munin ]'",
		require => Service["munin-server"];
	}

	# Cron job which syncs the RRD files to disk every 30 minutes.
	file { "/etc/cron.d/munin-sync":
		source => "puppet://puppet/munin/server/cron.d/munin-sync",
		owner => "root",
		group => "root",
		require => [Package["munin"], Package["rsync"]];
	}
}
