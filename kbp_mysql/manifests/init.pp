class kbp_mysql::server {
	include mysql::server
	include kbp_mysql::monitoring::icinga::server
}

class kbp_mysql::monitoring::icinga::server
{
	kbp_icinga::service { "mysql_${fqdn}":
		service_description => "MySQL service",
		checkcommand        => "check_mysql";
	}
}
