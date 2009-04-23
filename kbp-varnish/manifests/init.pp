class kbp-varnish inherits varnish {
	file { "/etc/munin/plugins/varnish_ratio":
		ensure => link,
		target => "/usr/local/share/munin/plugins/varnish_",
		notify => Service["munin-node"],
	}
}
