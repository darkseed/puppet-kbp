class kbp-munin::client inherits munin::client {
}

class kbp-munin::server inherits munin::server {
	include nagios::nsca

	file { "/etc/send_nsca.cfg":
		source => "puppet://puppet/kbp-munin/server/send_nsca.cfg",
		mode => 640,
		owner => "root",
		group => "munin",
		require => Package["nsca"],
	}
}
