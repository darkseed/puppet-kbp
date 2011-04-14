class kbp_monitoring::client::sslcert {
	include kbp_monitoring::client
	include kbp_sudo
	gen_sudo::rule { "check_sslcert sudo rules":
		entity => "nagios",
		as_user => "root",
		password_required => false,
		command =>"/usr/lib/nagios/plugins/check_sslcert";
	}
}
