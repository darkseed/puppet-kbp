class kbp-varnish inherits varnish {
	include munin::client

	munin::client::plugin { "varnish_ratio":
		script_path => "/usr/local/share/munin/plugins",
		script => "varnish_",
	}
}
