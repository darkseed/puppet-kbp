class kbp_twenty-five_mail::monitoring::icinga {
	kbp_icinga::service { "smtp_gateway_${fqdn}":
		service_description => "SMTP gateway",
		checkcommand        => "check_local_smtp",
		nrpe                => true;
	}
}
