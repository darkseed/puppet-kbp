class kbp-bind inherits bind {
	file {
		"/etc/munin/plugins/bind9_rndc":
			ensure => link,
			target => "/usr/share/munin/plugins/bind9_rndc",
			notify => Service["munin-node"];
		"/etc/munin/plugin-conf.d/bind9_rndc":
			source => "puppet://puppet/kbp-bind/munin/plugin-conf.d/bind9_rndc",
			owner => "root",
			group => "root",
			mode => 644,
			notify => Service["munin-node"];
	}

}
