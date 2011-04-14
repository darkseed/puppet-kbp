class kbp_sphinxsearch::server {
	include sphinxsearch::server
	include kbp_sphinxsearch::monitoring::icinga::server
}

class kbp_sphinxsearch::monitoring::icinga::server {
	kbp_icinga::service { "spinxsearch_server_${fqdn}":
		service_description => "Sphinxsearch service",
		checkcommand        => "check_tcp",
		argument1           => 3312;
	}
}
