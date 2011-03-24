class kbp_sudo {
	include concat::setup
	$sudoers="/etc/sudoers.new" #in squeeze or higher we could use /etc/sudoers.d/ and put all the sudo config there.

	package { "sudo":
		ensure => installed;
	}

	concat{ $sudoers:
		owner 	=> root,
		group 	=> root,
		mode	=> 440,
		notify	=> Exec["check ${sudoers}"],
		require	=> Package["sudo"];
	}

	define add_rule($content="", $order=15, $comment="") {
		if $content == "" {
			$body = $name
		} else {
			$body = $content
		}
		if $comment == "" {
			$the_comment = $name
		} else {
			$the_comment = $comment
		}

		concat::fragment{ "sudoers_fragment_${name}":
			content	=> "#${the_comment}\n${body}\n",
			target	=> "/etc/sudoers.new",
			order	=> $order;
		}
	}

	define add_source ($source="", $order=15) {
		if $source == "" {
			$the_source = $name
		} else {
			$the_source = $source
		}
		concat::fragment {"sudoers_fragment_${name}":
			target	=> "/etc/sudoers.new",
			source	=> $the_source,
			order	=> $order,
		}
	}

	exec { "check ${sudoers}":
		command		=> "/usr/sbin/visudo -c -f $sudoers",
		refreshonly	=> true,
	}
}
