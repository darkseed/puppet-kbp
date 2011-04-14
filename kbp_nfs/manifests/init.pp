class kbp_nfs {
	include kbp_nfs::monitoring::icinga
}

class kbp_nfs::monitoring::icinga {
	kbp_icinga::service { "nfs_daemon_${fqdn}":
		service_description => "NFS daemon",
		checkcommand        => "check_nfs";
	}
}
