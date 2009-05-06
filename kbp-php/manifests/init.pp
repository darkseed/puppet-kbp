class kbp-php::common inherits php::common {
	file { "/etc/php$phpversion/conf.d/security.ini":
		owner => "root",
		group => "root",
		mode => 644,
		source => "puppet://puppet/php/shared/conf.d/security.ini",
	}

	package { "php5-apc":
		ensure => installed,
	}

        file { "/etc/munin/plugins/apc":
                ensure => link,
                target => "/usr/local/share/munin/plugins/apc_",
                require => Package["php-apc"],
                notify => Service["munin-node"],
        }
}

class kbp-php::php5::common inherits php::php5::common {
	include kbp-php::common
}

class kbp-php::php5::modphp inherits php::php5::modphp {
	include kbp-php::php5::common
}

class kbp-php::php5::cgi inherits php::php5::cgi {
	include kbp-php::php5::common
}

class kbp-php::php5::cli inherits php::php5::cli {
	include kbp-php::php5::common
}

class kbp-php::php4::common inherits php::php4::common {
	include kbp-php::common
}

class kbp-php::php4::modphp inherits php::php4::modphp {
	include kbp-php::php4::common
}

class kbp-php::php4::cgi inherits php::php4::cgi {
	include kbp-php::php4::common
}

class kbp-php::php4::cli inherits php::php4::cli {
	include kbp-php::php4::common
}
