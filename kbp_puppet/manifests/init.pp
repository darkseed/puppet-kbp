class kbp_puppet {
	include gen_puppet

	line { "Point to the new PM":
		file    => "/etc/hosts",
		ensure  => present,
		content => "85.10.218.243 puppet";
	}
}
