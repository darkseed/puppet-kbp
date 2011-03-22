class kbp_hetzner inherits hetzner {
	include munin::client
	package { "lm-sensors":
		ensure => "latest";
	}

	munin::client::plugin { "sensors_temp":
		require => Package["lm-sensors"],
		script  => "sensors_",
		notify  => Exec["/sbin/modprobe f71882fg"];
	}

	exec { "/sbin/modprobe f71882fg":
		refreshonly => true,
	}

	#can be removed after all hosts have kickpuppet'd
	file { "/etc/modprobe.d/hetzner-sensors.conf":
		content => "f71882fg\n",
		ensure  => "absent",
		notify  => Exec["/sbin/modprobe f71882fg"];
	}

	line { "f71882fg": # Load the module on boot
		file 	=> "/etc/modules",
		ensure 	=> "present",
		content	=> "f71882fg";
	}
}
