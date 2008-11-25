class kbp-base {
        define staff_user($fullname, $uid) {
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
                gid => 1000,
        }

        staff_user {
                "bart":
                        fullname => "Bart Cortooms",
                        uid => 1000;
                "tim":
                        fullname => "Tim Stoop",
                        uid => 1001;
                "kees":
                        fullname => "Kees Meijs",
                        uid => 1002;
        }

        package { "sudo":
                ensure => installed,
        }

        file { "/etc/sudoers":
                source => "puppet://puppet/kbp-base/sudoers",
                mode => 440,
                owner => "root",
                group => "root",
                require => Package["sudo"],
        }
}
