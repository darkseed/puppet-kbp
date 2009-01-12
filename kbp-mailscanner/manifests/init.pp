class kbp-mailscanner inherits amavisd-new {
	include munin::client
	include kbp-mailscanner::spamchecker
	include kbp-mailscanner::virusscanner

	file { "/etc/amavis/conf.d/40-kbp":
		owner => "root",
		group => "root",
		mode => 644,
		source => "puppet://puppet/kbp-mailscanner/amavis/conf.d/40-kbp",
		notify => Service["amavis"],
	}
}

class kbp-mailscanner::spamchecker inherits spamassassin {
	file { "/etc/spamassassin/local.cf":
		source => "puppet://puppet/kbp-mailscanner/spamassassin/local.cf",
		owner => "root",
		group => "root",
		mode => 644,
		notify => Service["amavis"],
	}
}

class kbp-mailscanner::virusscanner inherits clamav {
	user { "clamav":
		require => Package["clamav-daemon"],
		groups => "amavis",
	}
}
