class kbp-localbackup {
	package { "rsnapshot":
		ensure => installed,
	}

	file { "/etc/rsnapshot.conf":
		owner => "root",
		group => "root",
		mode => 644,
		content => template("kbp-localbackup/rsnapshot/rsnapshot.conf"),
		require => Package["rsnapshot"],
	}

	file { "/usr/local/bin/rsnapshot_symlinks":
		source => "puppet://puppet/kbp-localbackup/rsnapshot_symlinks",
		owner => "root",
		group => "staff",
		mode => 755,
	}

	file { "/etc/cron.d/rsnapshot":
		source => "puppet://puppet/kbp-localbackup/rsnapshot/cron.d/rsnapshot",
		owner => "root",
		group => "root",
		mode => 644,
		require => File["/etc/rsnapshot.conf"],
	}
}
