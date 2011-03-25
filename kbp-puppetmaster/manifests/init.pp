class kbp-puppetmaster {
	include munin::client
	include kbp_vim
	include kbp_vim::addon-manager

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
	}

	# Install vim-puppet syntax higlighting rules and turn them on
	package { "vim-puppet":
		ensure => "latest",
	}
	exec { "Install syntax highlighting for .pp files":
		command => "/usr/bin/vim-addons -w puppet install;",
		creates => "/var/lib/vim/addons/syntax/puppet.vim",
	}

	# Enforce Puppet modules directory permissions.
	file {
		"/srv/puppet":
			ensure => directory,
			owner => puppet,
			group => root,
			require => Package["puppetmaster"],
			mode => 550;
		"/srv/puppet/env":
			ensure => directory,
			require => File["/srv/puppet"];
		"/srv/puppet/generic":
			ensure => directory,
			require => File["/srv/puppet"];
		"/srv/puppet/kbp":
			ensure => directory,
			require => File["/srv/puppet"];
	}

	# Enforce ownership and permissions
	setfacl {
		"Directory permissions in /srv/puppet for group root":
			dir => "/srv/puppet",
			acl => "default:group:root:rwx";
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
