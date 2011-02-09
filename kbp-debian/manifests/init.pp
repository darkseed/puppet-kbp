class kbp-debian::etch {
}

class kbp-debian::lenny {
	# Don't pull in Recommends or Suggests dependencies when installing
	# packages with apt.
	file {
		"/etc/apt/apt.conf.d/no-recommends":
			content => "APT::Install-Recommends \"false\";\n",
			owner => "root",
			group => "root",
			mode => 644;
		"/etc/apt/apt.conf.d/no-suggests":
			content => "APT::Install-Suggests \"false\";\n",
			owner => "root",
			group => "root",
			mode => 644;
	}

	apt::source {
		"${lsbdistcodename}-volatile":
			comment => "Repository for volatile packages in $lsbdistcodename, such as SpamAssassin and Clamav",
			sourcetype => "deb",
			uri => "$aptproxy/debian-volatile/",
			distribution => "${lsbdistcodename}/volatile",
			components => "main";
	}

        package { "mailx":
                ensure => installed
        }
}

class kbp-debian::squeeze {
	# Don't pull in Recommends or Suggests dependencies when installing
	# packages with apt.
	file {
		"/etc/apt/apt.conf.d/no-recommends":
			content => "APT::Install-Recommends \"false\";\n",
			owner => "root",
			group => "root",
			mode => 644;
		"/etc/apt/apt.conf.d/no-suggests":
			content => "APT::Install-Suggests \"false\";\n",
			owner => "root",
			group => "root",
			mode => 644;
	}

        package { "bsd-mailx":
                ensure => installed
        }
}

class kbp-debian inherits kbp-base {
        $aptproxy = "http://apt-proxy:9999"

        include apt
	include "kbp-debian::$lsbdistcodename"
	include rng-tools

        define check_alternatives($linkto) {
                exec { "/usr/sbin/update-alternatives --set $name $linkto":
                        unless => "/bin/sh -c '[ -L /etc/alternatives/$name ] && [ /etc/alternatives/$name -ef $linkto ]'"
                }
        }

        # Packages we want to have installed
        $wantedpackages = ["openssh-server", "vim", "less", "lftp", "screen",
          "file", "debsums", "dlocate", "gnupg", "ucf", "elinks", "reportbug",
          "tree", "netcat", "openssh-client", "tcpdump", "iproute", "acl",
          "psmisc", "udev", "lsof", "bzip2", "strace", "pinfo", "lsb-release",
          "ethtool", "host", "socat", "make", "nscd"]
        package { $wantedpackages:
                ensure => installed
        }

        # Packages we do not need, thank you very much!
        $unwantedpackages = ["pidentd", "dhcp3-client",
          "dictionaries-common", "doc-linux-text", "doc-debian", "finger",
           "iamerican", "ibritish", "ispell", "laptop-detect", "libident",
           "mpack", "mtools", "popularity-contest", "procmail", "tcsh",
           "w3m", "wamerican", "ppp", "pppoe", "pppoeconf", "at", "mdetect",
           "tasksel"]
        package { $unwantedpackages:
                ensure => absent
        }

        # Local timezone
        package { "tzdata":
                ensure => installed,
        }

        file { "/etc/timezone":
                owner => "root",
                group => "root",
                mode => 644,
                content => "Europe/Amsterdam\n",
                require => Package["tzdata"],
        }

        file { "/etc/localtime":
                ensure => link,
		target => "/usr/share/zoneinfo/Europe/Amsterdam",
                require => Package["tzdata"],
        }

        # Ensure /tmp always has the correct permissions. (It's a common
        # mistake to forget to do a chmod 1777 /tmp when /tmp is moved to its
        # own filesystem.)
        file { "/tmp":
                mode => 1777,
        }

        service { "ssh":
                ensure => running,
                require => Package["openssh-server"],
        }

        # We want to use pinfo as infobrowser, so when the symlink is not
        # pointing towards pinfo, we need to run update-alternatives
        check_alternatives { "infobrowser":
                linkto => "/usr/bin/pinfo",
                require => Package["pinfo"]
        }

#        # XXX Need to improve check_alternatives so it changes all slave links
#        # for the alternative too. Which means using update-alternatives instead
#        # of just changing the symlink.
#        alternative { "editor":
#                path => "/usr/bin/vim.basic",
#                require => Package["vim"]
#        }

        file { "/etc/skel/.bash_profile":
                owner => "root",
                group => "root",
                mode => 644,
                source => "puppet://puppet/kbp-debian/skel/bash_profile",
        }

        package { "adduser":
                ensure => installed,
        }

        file { "/etc/adduser.conf":
                source => "puppet://puppet/kbp-debian/adduser.conf",
                mode => 644,
                owner => "root",
                group => "root",
                require => Package["adduser"],
        }

        package {
		"locales":
			require => File["/var/cache/debconf/locales.preseed"],
			responsefile => "/var/cache/debconf/locales.preseed",
			ensure => installed;
        }

	file {
		"/var/cache/debconf/locales.preseed":
			source => "puppet://puppet/kbp-debian/locales.preseed",
			owner => "root",
			group => "root",
			mode => 644;
	}

        # Mail on upgrades with cron-apt
        package { "cron-apt":
                ensure => installed,
        }

        file { "/etc/cron-apt/config":
                source => "puppet://puppet/kbp-debian/cron-apt/config",
                owner => "root",
                group => "root",
                mode => 644,
                require => Package["cron-apt"],
        }

	apt::source {
		"${lsbdistcodename}-base":
			comment => "The main repository for the installed Debian release: $lsbdistdescription.",
			sourcetype => "deb",
			uri => "$aptproxy/debian/",
			distribution => "${lsbdistcodename}",
			components => "main non-free";
		"${lsbdistcodename}-security":
			comment => "Security updates for $lsbdistcodename.",
			sourcetype => "deb",
			uri => "$aptproxy/security/",
			distribution => "${lsbdistcodename}/updates",
			components => "main";
		"${lsbdistcodename}-backports":
			comment => "Repository for packages which have been backported to $lsbdistcodename.",
			sourcetype => "deb",
			uri => "$aptproxy/backports",
			distribution => "${lsbdistcodename}-backports",
			components => "main contrib non-free",
			require => Apt::Key["16BA136C"];
		"kumina":
			comment => "Local repository, for packages maintained by Kumina.",
			sourcetype => "deb",
			uri => "$aptproxy/kumina/",
			distribution => "${lsbdistcodename}-kumina",
			components => "main",
			require => Apt::Key["498B91E6"];
        }

	# Kumina repository key
        apt::key { "498B91E6":
                ensure => present,
        }

	# Backports.org repository key
	apt::key { "16BA136C":
		ensure => present,
	}

	# Package which makes sure the installed Kumina repository key is
	# up-to-date.
	package { "kumina-archive-keyring":
		ensure => latest,
	}

	# Package which makes sure the installed Backports.org repository key is
	# up-to-date.
	package { "debian-backports-keyring":
		ensure => installed,
	}

        file { "/etc/apt/preferences":
                content => template("kbp-debian/${lsbdistcodename}/apt/preferences"),
                owner => "root",
                group => "root",
                mode => 644;
        }

	file { "/var/lib/puppet":
		ensure => directory,
		owner => "puppet",
		group => "puppet",
		mode => 751;
	}
}
