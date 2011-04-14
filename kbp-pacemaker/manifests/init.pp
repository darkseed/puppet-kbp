# Copyright (C) 2010 Kumina bv, Ed Schouten <ed@kumina.nl>
# This works is published under the Creative Commons Attribution-Share 
# Alike 3.0 Unported license - http://creativecommons.org/licenses/by-sa/3.0/
# See LICENSE for the full legal text.

class kbp-pacemaker {
	include pacemaker
	include kbp_pacemaker::monitoring::icinga
}

class kbp_pacemaker::monitoring::icinga {
	kbp_icinga::service { "pacemaker_${fqdn}":
		service_description => "Pacemaker",
		checkcommand        => "check_pacemaker",
		nrpe                => true;
	}
}
