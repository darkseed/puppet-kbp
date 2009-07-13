class kbp-openldap::server inherits openldap::server {
	# Include the Samba schema by default
	openldap::server::schema { "samba":
		source => "puppet://puppet/kbp-openldap/slapd/schema/samba.schema",
	}

	# Circumvent the groupOfNames/posixGroup world of hurt by making the
	# posixGroup objectclass auxiliary
	file { "/etc/ldap/schema/nis.schema":
		source => "puppet://puppet/kbp-openldap/slapd/schema/nis.schema",
		owner => "root",
		group => "root",
		mode => 644,
		require => Package["slapd"],
	}
}
