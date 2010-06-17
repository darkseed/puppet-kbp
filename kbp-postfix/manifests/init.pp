class kbp-postfix inherits postfix {
	include munin::client
	include openssl::common

        munin::client::plugin { ["postfix_mailqueue", "postfix_mailstats", "postfix_mailvolume"]:
		ensure => present,
	}

	# The Postfix init script copies /etc/ssl/certs stuff on (re)start, so restart Postfix
	# on changes!
	Service["postfix"] {
		subscribe => File["/etc/ssl/certs"],
	}
}
