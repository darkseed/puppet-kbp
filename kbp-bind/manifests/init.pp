class kbp-bind inherits bind {
	include munin::client

	munin::client::plugin { "bind9_rndc":
		ensure => present,
	}

	munin::client::plugin::config { "bind9_rndc":
		content => "env.querystats /var/cache/bind/named.stats\nuser bind",
	}
}
