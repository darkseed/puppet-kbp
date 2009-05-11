class kbp-webalizer inherits webalizer {
	File["/etc/cron.daily/webalizer"] {
		source => "puppet://puppet/kbp-webalizer/cron.daily/webalizer",
		require => File["/usr/local/bin/webalizer-multi"],
	}

	file {
		"/etc/webalizer-multi.conf":
			owner => "root",
			group => "staff",
			mode => 755,
			source => "puppet://puppet/kbp-webalizer/webalizer-multi.conf";
		"/usr/local/bin/webalizer-multi":
			owner => "root",
			group => "staff",
			mode => 755,
			source => "puppet://puppet/kbp-webalizer/webalizer-multi",
			require => [File["/etc/webalizer-multi.conf"], Package["webalizer"]];
	}

	if tagged(apache) {
		file {
			"/etc/apache2/conf.d/webalizer":
				source => "puppet://puppet/kbp-webalizer/apache2/conf.d/webalizer",
				owner => "root",
				group => "root",
				mode => 644,
				require => Package["apache2"],
				notify => Exec["reload-apache2"];
			# Allow www-data to read the files
			"/etc/logrotate.d/apache2":
				source => "puppet://puppet/kbp-webalizer/logrotate.d/apache2",
				owner => "root",
				group => "root",
				mode => 644,
				require => Package["apache2"];
			"/var/log/apache2":
				owner => "root",
				group => "adm",
				mode => 755,
				require => Package["apache2"];
		}
	}
}
