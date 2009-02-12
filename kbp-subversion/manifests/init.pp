class kbp-subversion inherits trac {
	include subversion
	include apache

	define repo($group, $svn_via_dav=false, $mode="2755") {
		subversion::repo { $name:
			group => $group,
			path => "/srv/svn/$name",
			svn_via_dav => $svn_via_dav,
			mode => $mode,
		}

		trac::environment { $name:
			group => $group,
			path => "/srv/trac/$name",
			svnrepo => "/srv/svn/$name",
			require => Subversion::Repo[$name],
		}
	}

	package { ["subversion-tools", "db4.4-util", "patch"]:
		ensure => installed,
	}

	# TracWebAdmin plugin
	file { "/usr/local/lib/python2.4/site-packages/TracWebAdmin-0.1.2dev_r4429-py2.4.egg":
		source => "puppet://puppet/kbp-subversion/TracWebAdmin-0.1.2dev_r4429-py2.4.egg",
		owner => "root",
		group => "staff",
		mode => 644,
		require => File["/var/cache/trac"],
	}

	package { "libapache2-mod-python":
		ensure => installed,
	}

        # Use the prefork mpm. The threaded mpms may cause SVN corruption. (See
        # http://www.szakmeister.net/blog/fsfsverify/)
        package { ["apache2-mpm-prefork", "libapache2-svn"]:
                ensure => installed,
        }

	apache::module {
		"mod_python":
			ensure => present,
			require => Package["libapache2-mod-python"];
		"authnz_ldap":
			ensure => present;
		"dav_svn":
			require => Package["libapache2-svn"];
        }
}
