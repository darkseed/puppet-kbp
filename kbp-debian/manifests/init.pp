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
}

class kbp-debian inherits kbp-base {
        include apt
	include "kbp-debian::$lsbdistcodename"

        $aptproxy = "http://apt-proxy:9999"

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
          "ethtool", "mailx", "host"]
        package { $wantedpackages:
                ensure => installed
        }

        # Packages we do not need, thank you very much!
        $unwantedpackages = ["pidentd", "cyrus-sasl2-doc", "dhcp3-client",
          "dhcp3-common", "dictionaries-common", "doc-linux-text",
          "doc-debian", "finger", "iamerican", "ibritish", "ispell",
          "laptop-detect", "libident", "mpack", "mtools", "popularity-contest",
          "procmail", "tcsh", "w3m", "wamerican", "ppp", "pppoe", "pppoeconf",
          "at", "mdetect", "tasksel"]
        package { $unwantedpackages:
                ensure => absent
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

        package { "locales":
                ensure => installed,
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

        if $lsbdistcodename {
                apt::source {
                        "${lsbdistcodename}-base":
                                comment => "The main repository for the installed Debian release: $lsbdistdescription.",
                                sourcetype => "deb",
                                uri => "$aptproxy/debian/",
                                distribution => "${lsbdistcodename}",
                                components => "main";
                        "${lsbdistcodename}-security":
                                comment => "Security updates for $lsbdistcodename.",
                                sourcetype => "deb",
                                uri => "$aptproxy/security/",
                                distribution => "${lsbdistcodename}/updates",
                                components => "main";
                        "${lsbdistcodename}-volatile":
                                comment => "Repository for volatile packages in $lsbdistcodename, such as SpamAssassin and Clamav",
                                sourcetype => "deb",
                                uri => "$aptproxy/debian-volatile/",
                                distribution => "${lsbdistcodename}/volatile",
                                components => "main";
                        "kumina":
                                comment => "Local repository, for packages maintained by Kumina.",
                                sourcetype => "deb",
                                uri => "$aptproxy/kumina/",
                                distribution => "${lsbdistcodename}-kumina",
                                components => "main",
                                require => Apt::Key["498B91E6"];
                }
        }

	# Kumina repository key
        apt::key { "498B91E6":
                ensure => present,
        }

        file { "/etc/apt/preferences":
                content => template("kbp-debian/apt/preferences"),
                owner => "root",
                group => "root",
                mode => 644;
        }
}
