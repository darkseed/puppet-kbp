class kbp-puppetmaster {
	include apt

	package { "mongrel":
		ensure => present,
		require => Apt::Source["etch-backports"],
	}

	package { "puppetmaster":
		ensure => present,
	}

	service { "puppetmaster":
		ensure => running,
		enable => true,
		require => Package["puppetmaster"],
		subscribe => File["/etc/default/puppetmaster"],
	}

	file { "/etc/default/puppetmaster":
		source => "puppet://puppet/puppetmaster/default/puppetmaster",
		owner => "root",
		group => "root",
		mode => 644,
		require => Package["puppetmaster"],
	}

	nginx::site_config { "puppet.$domain":
		source => "puppet://puppet/puppetmaster/nginx/sites-available/puppet.$domain",
	}

	nginx::site { "puppet.$domain":
		ensure => present,
	}

	# Needed for the Mongrel package
	apt::source { "etch-backports":
		comment => "Repository for packages which have been backported to Etch.",
		sourcetype => "deb",
		uri => "http://apt-proxy:9999/etch-backports/",
		distribution => "etch-backports",
		components => "main",
		require => Apt::Key["16BA136C"];
	}

        apt::key { "16BA136C":
                ensure => present,
        }
}
