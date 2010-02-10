class kbp-puppetmaster {
	include munin::client

        package {
		"puppetmaster":
			ensure => present;
		"mongrel":
			ensure => present;
		"rails":
			ensure => present;
		"darcs":
			ensure => present;
		# Needed because the default rails connect is crappy
		"libmysql-ruby":
			ensure => present;
        }

        service {
		"puppetmaster":
			ensure => running,
			enable => true,
			require => Package["puppetmaster"],
			subscribe => File["/etc/default/puppetmaster"];
        }

        file {
		"/etc/default/puppetmaster":
                	source => "puppet://puppet/kbp-puppetmaster/default/puppetmaster",
	                owner => "root",
	                group => "root",
	                mode => 644,
	                require => Package["puppetmaster"];
		"/srv/puppet":
			ensure => directory,
			owner => root,
			group => root,
			require => Package["puppetmaster"],
			mode => 755;
		"/srv/puppet/env":
			ensure => directory,
			owner => puppet,
			group => root,
			mode => 2770,
			require => File["/srv/puppet"];
		"/srv/puppet/generic":
			ensure => directory,
			owner => puppet,
			group => root,
			mode => 2770,
			require => File["/srv/puppet"];
		"/srv/puppet/kbp":
			ensure => directory,
			owner => puppet,
			group => root,
			mode => 2770,
			require => File["/srv/puppet"];
	}

        if tagged(nginx) {
                nginx::site_config {
                        "puppet.$domain":
                                template => "kbp-puppetmaster/nginx/puppetmaster.conf";
                        "puppetca.$domain":
                                template => "kbp-puppetmaster/nginx/puppetca.conf";
                }

                nginx::site {
                        "puppet.$domain":
                                ensure => present;
                        "puppetca.$domain":
                                ensure => present;
                }
        }

        if tagged(apache) {
                # Needed for Mongrel
                apache::module { ["ssl", "proxy", "proxy_http", "proxy_balancer", "headers"]:
                        ensure => present,
                }

                apache::site_config { "puppet.$domain":
                        template => "kbp-puppetmaster/apache2/puppetmaster.conf",
                }

                apache::site { "puppet.$domain":
                        ensure => present,
                }
        }

        munin::client::plugin { "puppetmasterd_process_memory":
                script_path => "/usr/local/share/munin/plugins",
        }
}
