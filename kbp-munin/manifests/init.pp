class kbp-munin::client inherits munin::client {
	package { "libnet-snmp-perl":
		ensure => installed,
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

	# Cron job which syncs the RRD files to disk every 30 minutes.
	file { "/etc/cron.d/munin-sync":
		source => "puppet://puppet/munin/server/cron.d/munin-sync",
		owner => "root",
		group => "root",
		require => [Package["munin"], Package["rsync"]];
	}
}
