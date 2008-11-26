class kbp-mailscanner inherits amavisd-new {
	include kbp-mailscanner::spamchecker
	include kbp-mailscanner::virusscanner

	File["/etc/amavis/conf.d/50-user"] {
		source => "puppet://puppet/kbp-mailscanner/amavis/conf.d/50-user",
	}
}

class kbp-mailscanner::spamchecker inherits spamassassin {
}

class kbp-mailscanner::virusscanner inherits clamav {
	user { "clamav":
		require => Package["clamav-daemon"],
		groups => "amavis",
	}
}
