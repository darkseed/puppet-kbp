class kbp-postfix inherits postfix {
	include munin::client

        munin::client::plugin { ["postfix_mailqueue", "postfix_mailstats", "postfix_mailvolume"]:
		ensure => present,
	}
}
