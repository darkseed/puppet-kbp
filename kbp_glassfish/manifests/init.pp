class kbp_glassfish::monitoring::icinga {
	define site () {
		kbp_icinga::host { "${name}":; }

		kbp_icinga::service {
			"glassfish_domain_${name}":
				service_description => "Glassfish domain ${name}",
				check_command       => "check_http_vhost",
				argument1           => $name;
		}
	}
}
