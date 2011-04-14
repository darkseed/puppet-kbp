class kbp-apache inherits apache {
	include kbp-munin::client::apache
	kfile {
		"/etc/apache2/mods-available/deflate.conf":
			source => "kbp-apache/mods-available/deflate.conf",
			require => Package["apache2"],
			notify => Exec["reload-apache2"];
		"/etc/apache2/conf.d/security":
			source => "kbp-apache/conf.d/security",
			require => Package["apache2"],
			notify => Exec["reload-apache2"];
	}

	apache::module { "deflate":
		ensure => present,
	}

	@package { "php5-gd":
		ensure  => latest,
		require => Package["apache2"],
		notify  => Exec["reload-apache2"];
	}
}

class kbp-apache::passenger {
	include kbp-apache

	kpackage { "libapache2-mod-passenger":
		ensure => latest;
	}

	apache::module { "ssl":; }
}
