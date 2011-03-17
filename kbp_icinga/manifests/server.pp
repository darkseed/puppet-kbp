class kbp_icinga::server inherits icinga::server {
        file {
                "/etc/icinga/htpasswd.users":
                        require => Package["icinga", "apache2"],
                        source  => "puppet://puppet/kbp_icinga/server/htpasswd.users",
                        owner   => "root",
                        group   => "www-data",
                        mode    => 640;
                "/etc/icinga/cgi.cfg":
                        require => Package["icinga"],
                        source  => "puppet://puppet/kbp_icinga/server/cgi.cfg",
                        owner   => "root",
                        group   => "root",
                        mode    => 644,
			notify  => Exec["reload-icinga"];
                "/etc/icinga/icinga.cfg":
                        require => Package["icinga"],
                        source  => "puppet://puppet/kbp_icinga/server/icinga.cfg",
                        owner   => "root",
                        group   => "root",
                        mode    => 644,
			notify  => Exec["reload-icinga"];
	}

	service { "icinga":
		ensure     => running,
		hasrestart => true,
		hasstatus  => true,
		require    => Package["icinga"];
	}
}
