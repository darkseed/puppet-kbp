class kbp-apache inherits apache {
	include kbp-munin::client::apache
	file {
		"/etc/apache2/mods-available/deflate.conf":
			source => "puppet://puppet/kbp-apache/mods-available/deflate.conf",
			owner => "root",
			group => "root",
			mode => 644,
			require => Package["apache2"],
			notify => Exec["reload-apache2"];
		"/etc/apache2/conf.d/security":
			source => "puppet://puppet/kbp-apache/conf.d/security",
			owner => "root",
			group => "root",
			mode => 644,
			require => Package["apache2"],
			notify => Exec["reload-apache2"];
	}

	apache::module { "deflate":
		ensure => present,
	}
}
