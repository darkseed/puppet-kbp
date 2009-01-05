class kbp-postfix inherits postfix {
	include munin::client

        file {
                "/etc/munin/plugins/postfix_mailstats":
			ensure => symlink,
			target => "/usr/share/munin/plugins/postfix_mailstats",
			require => Package["munin-node"],
			notify => Service["munin-node"];
                "/etc/munin/plugins/postfix_mailvolume":
			ensure => symlink,
			target => "/usr/share/munin/plugins/postfix_mailvolume",
			require => Package["munin-node"],
			notify => Service["munin-node"];
                "/etc/munin/plugins/postfix_mailqueue":
			ensure => symlink,
			target => "/usr/share/munin/plugins/postfix_mailqueue",
			require => Package["munin-node"],
			notify => Service["munin-node"];
        }
}
