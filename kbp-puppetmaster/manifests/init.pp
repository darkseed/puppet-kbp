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

	# Enforce ownership and permissions using find.
	exec {
		"Fix directory permissions in /srv/puppet/env":
			command => "/usr/bin/find /srv/puppet/env -type d -not -perm 2775 -exec /bin/chmod 2775 {} \\;",
			require => File["/srv/puppet/env"];
		"Fix directory permissions in /srv/puppet/generic":
			command => "/usr/bin/find /srv/puppet/generic -type d -not -perm 2775 -exec /bin/chmod 2775 {} \\;",
			require => File["/srv/puppet/generic"];
		"Fix directory permissions in /srv/puppet/kbp":
			command => "/usr/bin/find /srv/puppet/kbp -type d -not -perm 2775 -exec /bin/chmod 2775 {} \\;",
			require => File["/srv/puppet/kbp"];
		"Fix file permissions in /srv/puppet/env":
			command => "/usr/bin/find /srv/puppet/env -type f -not -perm 664 -exec /bin/chmod 664 {} \\;",
			require => File["/srv/puppet/env"];
		"Fix file permissions in /srv/puppet/generic":
			command => "/usr/bin/find /srv/puppet/generic -type f -not -perm 664 -exec /bin/chmod 664 {} \\;",
			require => File["/srv/puppet/generic"];
		"Fix file permissions in /srv/puppet/kbp":
			command => "/usr/bin/find /srv/puppet/kbp -type f -not -perm 664 -exec /bin/chmod 664 {} \\;",
			require => File["/srv/puppet/kbp"];
		"Fix owner in /srv/puppet/env":
			command => "/usr/bin/find /srv/puppet/env -not -uid 0 -exec /bin/chown root {} \\;",
			require => File["/srv/puppet/env"];
		"Fix group in /srv/puppet/env":
			command => "/usr/bin/find /srv/puppet/env -not -gid 0 -exec /bin/chgrp root {} \\;",
			require => File["/srv/puppet/env"];
		"Fix owner in /srv/puppet/generic":
			command => "/usr/bin/find /srv/puppet/generic -not -uid 0 -exec /bin/chown root {} \\;",
			require => File["/srv/puppet/generic"];
		"Fix group in /srv/puppet/generic":
			command => "/usr/bin/find /srv/puppet/generic -not -gid 0 -exec /bin/chgrp root {} \\;",
			require => File["/srv/puppet/generic"];
		"Fix owner in /srv/puppet/kbp":
			command => "/usr/bin/find /srv/puppet/kbp -not -uid 0 -exec /bin/chown root {} \\;",
			require => File["/srv/puppet/kbp"];
		"Fix group in /srv/puppet/kbp":
			command => "/usr/bin/find /srv/puppet/kbp -not -gid 0 -exec /bin/chgrp root {} \\;",
			require => File["/srv/puppet/kbp"];
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
