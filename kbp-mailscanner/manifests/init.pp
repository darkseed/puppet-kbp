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

	package { ["zoo", "arj", "cabextract"]:
		ensure => installed,
		notify => Service["amavis"],
	}

	file {
		"/etc/munin/plugins/amavis_time":
			ensure => symlink,
			target => "/usr/local/share/munin/plugins/amavis_",
			notify => Service["munin-node"];
		"/etc/munin/plugins/amavis_cache":
			ensure => symlink,
			target => "/usr/local/share/munin/plugins/amavis_",
			notify => Service["munin-node"];
		"/etc/munin/plugins/amavis_content":
			ensure => symlink,
			target => "/usr/local/share/munin/plugins/amavis_",
			notify => Service["munin-node"];
		"/etc/munin/plugin-conf.d/amavis_":
			source => "puppet://puppet/munin/client/plugin-conf.d/amavis_",
			owner => "root",
			group => "root",
			mode => 644,
			notify => Service["munin-node"];
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

	# Pyzor and Razor work similarly (they both use checksums for detecting
	# spam), but the details differ.
	# http://spamassassinbook.packtpub.com/chapter11.htm has a good
	# description on the differences.
	package { ["pyzor", "razor"]:
		ensure => installed,
	}
}

class kbp-mailscanner::virusscanner inherits clamav {
	user { "clamav":
		require => Package["clamav-daemon"],
		groups => "amavis",
	}
}
