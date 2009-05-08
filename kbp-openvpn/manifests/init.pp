class kbp-openvpn::server inherits openvpn::server {
	include munin::client

	munin::client::plugin { "openvpn":
		require => File["/etc/openvpn/openvpn-status.log"],
	}

	munin::client::plugin::config { "openvpn":
		content => "user root\n",
	}

	# The Munin plugin has hardcoded the location of the status log, so we
	# need this symlink.
	file { "/etc/openvpn/openvpn-status.log":
		ensure => link,
		target => "/var/lib/openvpn/status.log",
	}
}
