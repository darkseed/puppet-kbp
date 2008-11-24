class kbp-puppetmaster {
	include munin::client

        package { ["puppetmaster", "mongrel", "rails"]:
                ensure => present,
        }

        service { "puppetmaster":
                ensure => running,
                enable => true,
                require => Package["puppetmaster"],
                subscribe => File["/etc/default/puppetmaster"],
        }

        file { "/etc/default/puppetmaster":
                source => "puppet://puppet/kbp-puppetmaster/default/puppetmaster",
                owner => "root",
                group => "root",
                mode => 644,
                require => Package["puppetmaster"],
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

        file { "/etc/munin/plugins/puppetmasterd_process_memory":
                ensure => link,
                target => "/usr/local/share/munin/plugins/puppetmasterd_process_memory",
                require => File["/usr/local/share/munin/plugins"],
                notify => Service["munin-node"],
        }
}
