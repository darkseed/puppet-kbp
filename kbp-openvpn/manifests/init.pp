class kbp-openvpn::server inherits openvpn::server {
	file {
		"/etc/munin/plugins/openvpn":
			ensure => link,
			owner => "root",
			group => "root",
			target => "/usr/share/munin/plugins/openvpn",
			require => [File["/etc/openvpn/openvpn-status.log"],
			            File["/etc/munin/plugin-conf.d/openvpn"]],
			notify => Service["munin-node"];
		"/etc/munin/plugin-conf.d/openvpn":
			owner => "root",
			group => "root",
			mode => 644,
			content => "[openvpn]\nuser root\n",
			notify => Service["munin-node"];
	}

	# The Munin plugin has hardcoded the location of the status log, so we
	# need this symlink.
	file { "/etc/openvpn/openvpn-status.log":
		ensure => link,
		target => "/var/lib/openvpn/status.log",
	}
}
