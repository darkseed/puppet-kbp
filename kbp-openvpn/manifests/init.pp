class kbp-openvpn::server inherits openvpn::server {
	file { "/etc/munin/plugins/openvpn":
		ensure => link,
		owner => "root",
		group => "root",
		target => "/usr/share/munin/plugins/openvpn",
		notify => Service["munin-node"],
	}
}
