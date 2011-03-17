class kbp_hetzner inherits hetzner {
	include munin::client

	package { "lm-sensors":
		ensure => "latest";
	}

	munin::client::plugin { "sensors_temp":
		require => Package["lm-sensors"],
		script  => "sensors_",
	}

	exec { "/sbin/modprobe f71882fg":
		
	}

	file { "/etc/modprobe.d/hetzner-sensors.conf":
		content => "f71882fg",
		ensure  => "present",
		notify  => Exec["/sbin/modprobe f71882fg"];
	}


}
