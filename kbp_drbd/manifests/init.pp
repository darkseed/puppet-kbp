class kbp_drbd {
	include kbp_drbd::monitoring::icinga
}

class kbp_drbd::monitoring::icinga {
	kbp_icinga::service { "check_drbd_${fqdn}":
		service_description => "DRBD",
		checkcommand        => "check_drbd",
		nrpe                => true;
	}
}
