class kbp-base {
	include gen_base
	include grub
	include kbp_acpi
	include kbp_apt
	include kbp_puppet
	include kbp_vim
	include kbp_time
	include kbp_sudo
	include kbp_icinga::client

	gen_sudo::rule {
		"User root has total control":
			entity            => "root",
			as_user           => "ALL",
			command           => "ALL",
			password_required => true,
			order             => 10; # legacy, only used on lenny systems
		"Kumina default rule":
			entity            => "%root",
			as_user           => "ALL",
			command           => "ALL",
			password_required => true,
			order             => 10; # legacy, only used on lenny systems
	}

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

			file { "/home/$username/.tmp":
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

			file { "/home/$username/.gitconfig":
				ensure => $ensure,
				mode => 644,
				content => "[user]\n\tname = $fullname\n\temail = $username@kumina.nl\n",
				group => "kumina";
			}

			file { "/home/$username/.reportbugrc":
				ensure => $ensure,
				mode => 644,
				content => "REPORTBUGEMAIL=$username@kumina.nl\n",
				group => "kumina";
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
	kpackage {
		["binutils"]:
			ensure => installed;
		["hidesvn","bash-completion","bc","tcptraceroute","diffstat"]:
			ensure => latest;
    }
	
	if versioncmp($lsbdistrelease, 6.0) < 0 {
		kpackage { "tcptrack":
			ensure => latest,
		}
	}

	file {
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
