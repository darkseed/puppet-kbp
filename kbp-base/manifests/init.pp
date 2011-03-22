class kbp-base {
	include grub
	include kbp_vim
	include kbp_time
	define staff_user($ensure = "present", $fullname, $uid, $password_hash) {
		$username = $name
		user { "$username":
			comment 	=> $fullname,
			ensure 		=> $ensure,
			gid 		=> "kumina",
			uid 		=> $uid,
			groups 		=> ["adm", "staff", "root"],
			membership 	=> minimum,
			shell	 	=> "/bin/bash",
			home 		=> "/home/$username",
			require 	=> File["/etc/skel/.bash_profile"],
			password 	=> $password_hash,
		}

		if $ensure == "present" {
			file { "/home/$username":
				ensure => $ensure ? {
					"present" => directory,
					default   => absent,
				},
				mode 	=> 750,
				owner 	=> "$username",
				group 	=> "kumina",
				require => [User["$username"], Group["kumina"]],
			}

			file { "/home/$username/.ssh":
				ensure 	=> $ensure,
				source 	=> "puppet://puppet/kbp-base/home/$username/.ssh",
				mode 	=> 700,
				owner 	=> "$username",
				group 	=> "kumina",
				require => File["/home/$username"],
			}

			file { "/home/$username/.ssh/authorized_keys":
				ensure 	=> $ensure,
				source 	=> "puppet://puppet/kbp-base/home/$username/.ssh/authorized_keys",
				mode 	=> 644,
				owner 	=> "$username",
				group 	=> "kumina",
				require => File["/home/$username"],
			}

			file { "/home/$username/.bashrc":
				ensure 	=> $ensure,
				content => template("kbp-base/home/$username/.bashrc"),
				mode 	=> 644,
				owner 	=> "$username",
				group 	=> "kumina",
				require => File["/home/$username"],
			}

			file { "/home/$username/.bash_profile":
				ensure 	=> $ensure,
				source 	=> "puppet://puppet/kbp-base/home/$username/.bash_profile",
				mode 	=> 644,
				owner 	=> "$username",
				group 	=> "kumina",
				require => File["/home/$username"],
			}

			file { "/home/$username/.bash_aliases":
				ensure 	=> $ensure,
				source 	=> "puppet://puppet/kbp-base/home/$username/.bash_aliases",
				mode 	=> 644,
				owner 	=> "$username",
				group 	=> "kumina",
				require => File["/home/$username"],
			}

			file { "/home/$username/.darcs":
				ensure => $ensure ? {
					"present" => directory,
					default   => absent,
				},
				mode 	=> 755,
				owner 	=> "$username",
				group 	=> "kumina",
				require => File["/home/$username"],
			}

			file { "/home/$username/.darcs/author":
				ensure => $ensure,
				mode => 644,
				content => "$fullname <$username@kumina.nl>\n",
				group => "kumina",
				require => File["/home/$username/.darcs"],
			}
		} else {
			file { "/home/$username":
				ensure  => absent,
				force   => true,
				recurse => true,
			}
		}
	}

	# Add the Kumina group and users
	# XXX Needs to do a groupmod when a group with gid already exists.
	group { "kumina":
		ensure => present,
		gid => 10000,
	}

	staff_user {
		"tim":
			fullname      => "Tim Stoop",
			uid           => 10001,
			password_hash => "BOGUS";
		"kees":
			fullname      => "Kees Meijs",
			password_hash => "BOGUS",
			uid           => 10002,
			ensure        => absent;
		"mike":
			fullname      => "Mike Huijerjans",
			uid           => 10000,
			password_hash => "BOGUS",
			ensure        => absent;
		"pieter":
			fullname      => "Pieter Lexis",
			uid           => 10005,
			password_hash => "BOGUS";
		"rutger":
			fullname      => "Rutger Spiertz",
			uid           => 10003,
			password_hash => "BOGUS";
		"ed":
			fullname      => "Ed Schouten",
			uid           => 10004,
			password_hash => "BOGUS";
	}

	# Packages we like and want :)
	package {
		"binutils":			ensure => present;
		"diffstat":			ensure => installed;
		"hidesvn":			ensure => latest;
		"tcptraceroute":	ensure => installed;
		"sudo":				ensure => installed;
		"bash-completion":	ensure => latest;
    }

	if versioncmp($lsbdistrelease, 6.0) < 0 {
		package { "tcptrack":
			ensure => latest,
		}
	}

	file {
		"/etc/sudoers":
			source 	=> "puppet://puppet/kbp-base/sudoers",
			mode 	=> 440,
			owner 	=> "root",
			group 	=> "root",
			require => Package["sudo"];
		"/etc/motd.tail":
			source 	=> "puppet://puppet/kbp-base/motd.tail",
			mode 	=> 644,
			owner 	=> "root",
			group 	=> "root";
	}

	exec {
		"uname -snrvm | tee /var/run/motd ; cat /etc/motd.tail >> /var/run/motd":
			refreshonly => true,
			path => ["/usr/bin", "/bin"],
			require => File["/etc/motd.tail"],
			subscribe => File["/etc/motd.tail"];
	}
}
