class kbp-base {
        define staff_user($fullname, $uid, $password_hash) {
                $username = $name

                user { "$username":
                        comment => $fullname,
                        ensure => present,
                        gid => "kumina",
                        uid => $uid,
                        groups => ["adm", "staff", "root"],
                        membership => minimum,
                        shell => "/bin/bash",
                        home => "/home/$username",
                        require => File["/etc/skel/.bash_profile"],
			password => $password_hash,
                }

                file { "/home/$username":
                        ensure => directory,
                        mode => 750,
                        owner => "$username",
                        group => "kumina",
                        require => [User["$username"], Group["kumina"]],
                }

                file { "/home/$username/.ssh":
                        source => "puppet://puppet/kbp-base/home/$username/.ssh",
                        mode => 700,
                        owner => "$username",
                        group => "kumina",
                        require => File["/home/$username"],
                }

                file { "/home/$username/.ssh/authorized_keys":
                        source => "puppet://puppet/kbp-base/home/$username/.ssh/authorized_keys",
                        mode => 644,
                        owner => "$username",
                        group => "kumina",
                        require => File["/home/$username"],
                }

                file { "/home/$username/.bashrc":
                        content => template("kbp-base/home/$username/.bashrc"),
                        mode => 644,
                        owner => "$username",
                        group => "kumina",
                        require => File["/home/$username"],
                }

                file { "/home/$username/.bash_profile":
                        source => "puppet://puppet/kbp-base/home/$username/.bash_profile",
                        mode => 644,
                        owner => "$username",
                        group => "kumina",
                        require => File["/home/$username"],
                }

                file { "/home/$username/.bash_aliases":
                        source => "puppet://puppet/kbp-base/home/$username/.bash_aliases",
                        mode => 644,
                        owner => "$username",
                        group => "kumina",
                        require => File["/home/$username"],
                }

                file { "/home/$username/.darcs":
                        ensure => directory,
                        mode => 755,
                        owner => "$username",
                        group => "kumina",
                        require => File["/home/$username"],
                }

                file { "/home/$username/.darcs/author":
                        mode => 644,
                        content => "$fullname <$username@kumina.nl>\n",
                        group => "kumina",
                        require => File["/home/$username/.darcs"],
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
                        fullname => "Tim Stoop",
                        uid => 10001;
                "kees":
                        fullname => "Kees Meijs",
                        uid => 10002;
		"rutger":
			fullname => "Mike Huijerjans",
			uid => 10000;
        }

        package { "sudo":
                ensure => installed,
        }

	package {
		"binutils":
			ensure => present;
	}

        file {
		"/etc/sudoers":
			source => "puppet://puppet/kbp-base/sudoers",
			mode => 440,
			owner => "root",
			group => "root",
			require => Package["sudo"];
		"/etc/motd.tail":
			source => "puppet://puppet/kbp-base/motd.tail",
			mode => 644,
			owner => "root",
			group => "root";
        }

	exec {
		"uname -snrvm | tee /var/run/motd ; cat /etc/motd.tail >> /var/run/motd":
			refreshonly => true,
			path => ["/usr/bin", "/bin"],
			require => File["/etc/motd.tail"],
			subscribe => File["/etc/motd.tail"];
	}
}
