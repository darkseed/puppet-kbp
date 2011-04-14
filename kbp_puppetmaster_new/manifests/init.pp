class kbp_puppetmaster_new {
	include kbp-apache::passenger
	include kbp_mysql::server
	include kbp_vim::addon-manager

	gen_apt::preference { ["puppetmaster","puppetmaster-common"]:; }
	gen_apt::source { "rabbitmq":
		uri          => "http://www.rabbitmq.com/debian",
		distribution => "testing",
		components   => ["main"];
	}

	kpackage {
		"puppetmaster":
			ensure  => present,
			require => File["/etc/default/puppetmaster","/etc/apt/preferences.d/puppetmaster"];
		["rails","rabbitmq-server","vim-puppet","libmysql-ruby"]:
			ensure  => latest;
	}

	service { "puppetqd":
		hasstatus => true,
		ensure    => running,
		require   => Package["puppetmaster"];
	}

	exec {
		"Install syntax highlighting for .pp files":
			command => "/usr/bin/vim-addons -w install puppet;",
			creates => "/var/lib/vim/addons/syntax/puppet.vim",
			require => Package["vim-puppet","vim-addon-manager"];
		"Install the Stomp gem":
			command => "/usr/bin/gem install stomp",
			creates => "/var/lib/gems/1.8/gems/stomp-1.1.8",
			require => Package["rails"];
		"reload-rabbitmq":
			command     => "/etc/init.d/rabbitmq-server reload",
			refreshonly => true;
	}

	kfile {
		"/etc/puppet/puppet.conf":
			source  => "kbp_puppetmaster_new/puppet.conf",
			require => Package["puppetmaster"];
		"/etc/puppet/fileserver.conf":
			source  => "kbp_puppetmaster_new/fileserver.conf",
			require => Package["puppetmaster"];
		"/etc/default/puppetmaster":
			source => "kbp_puppetmaster_new/default/puppetmaster";
		"/etc/default/puppetqd":
			source => "kbp_puppetmaster_new/default/puppetqd";
		"/etc/rabbitmq/rabbitmq-env.conf":
			source  => "kbp_puppetmaster_new/rabbitmq/rabbitmq-env.conf",
			require => Package["rabbitmq-server"];
		"/etc/apache2/sites-available/puppetmaster":
			source  => "kbp_puppetmaster_new/apache2/sites-available/puppetmaster",
			notify  => Exec["reload-apache2"],
			require => Package["apache2"];
		"/usr/share/puppet":
			ensure  => directory;
		"/usr/share/puppet/rack":
			ensure  => directory;
		"/usr/share/puppet/rack/puppetmasterd":
			ensure  => directory;
		"/usr/share/puppet/rack/puppetmasterd/public":
			ensure  => directory;
		"/usr/share/puppet/rack/puppetmasterd/tmp":
			ensure  => directory;
		"/usr/share/puppet/rack/puppetmasterd/config.ru":
			source  => "kbp_puppetmaster_new/config.ru",
			owner   => "puppet",
			group   => "puppet";
		"/var/lib/puppet/ssl/ca":
			ensure  => directory,
			owner   => "puppet",
			group   => "puppet",
			mode    => 770,
			require => Package["puppetmaster"];
		"/var/lib/puppet/ssl/ca/ca_crl.pem":
			source => "kbp_puppetmaster_new/ssl/ca/ca_crl.pem",
			owner  => "puppet",
			group  => "puppet",
			mode   => 664,
			notify => Exec["reload-apache2"];
		"/var/lib/puppet/ssl/ca/ca_crt.pem":
			source => "kbp_puppetmaster_new/ssl/ca/ca_crt.pem",
			owner  => "puppet",
			group  => "puppet",
			mode   => 660,
			notify => Exec["reload-apache2"];
		"/var/lib/puppet/ssl/ca/ca_key.pem":
			source => "kbp_puppetmaster_new/ssl/ca/ca_key.pem",
			owner  => "puppet",
			group  => "puppet",
			mode   => 660,
			notify => Exec["reload-apache2"];
		"/var/lib/puppet/ssl/ca/ca_pub.pem":
			source => "kbp_puppetmaster_new/ssl/ca/ca_pub.pem",
			owner  => "puppet",
			group  => "puppet",
			mode   => 640,
			notify => Exec["reload-apache2"];
		"/var/lib/puppet/ssl/ca/signed":
			ensure => directory,
			owner  => "puppet",
			group  => "puppet",
			mode   => 770;
		# TODO remove this one once the PM works properly
		"/var/lib/puppet/ssl/ca/signed/icinga.kumina.nl.pem":
			source => "kbp_puppetmaster_new/ssl/ca/signed/icinga.kumina.nl.pem";
		"/var/lib/puppet/ssl/private_keys/puppet.pem":
			source => "kbp_puppetmaster_new/ssl/private_keys/puppet.pem",
			owner  => "puppet",
			mode   => 600,
			notify => Exec["reload-apache2"];
		"/var/lib/puppet/ssl/certs/puppet.pem":
			source => "kbp_puppetmaster_new/ssl/certs/puppet.pem",
			notify => Exec["reload-apache2"];
		"/usr/lib/rabbitmq/lib/rabbitmq_server-2.4.1/plugins/amqp_client-2.4.1.ez":
			source  => "kbp_puppetmaster_new/rabbitmq/plugins/amqp_client-2.4.1.ez",
			require => Package["rabbitmq-server"],
			notify  => Exec["reload-rabbitmq"];
		"/usr/lib/rabbitmq/lib/rabbitmq_server-2.4.1/plugins/rabbit_stomp-2.4.1.ez":
			source  => "kbp_puppetmaster_new/rabbitmq/plugins/rabbit_stomp-2.4.1.ez",
			require => Package["rabbitmq-server"],
			notify  => Exec["reload-rabbitmq"];
	}

	mysql::server::db { "puppet":; }

	mysql::server::grant { "puppet":
		user     => "puppet",
		password => "ui6Nae9Xae4a";
	}

	# Enforce Puppet modules directory permissions.
	kfile {
		"/srv/puppet":
			ensure  => directory,
			owner   => "puppet",
			mode    => 770,
			require => Package["puppetmaster"];
	}

	# Enforce ownership and permissions
	setfacl {
		"Directory permissions in /srv/puppet for group root":
			dir     => "/srv/puppet",
			acl     => "default:group:root:rwx",
			require => File["/srv/puppet"];
		"Directory permissions in /srv/puppet for user puppet":
			dir     => "/srv/puppet",
			acl     => "default:user:puppet:r-x",
			require => File["/srv/puppet"];
	}

	# This is so puppetmaster doesn't congest MySQL connections
	kfile { "/etc/mysql/conf.d/waittimeout.cnf":
		content => "[mysqld]\nwait_timeout = 3600\n",
		notify  => Service["mysql"];
	}
	
	apache::site { "puppetmaster":; }
}
