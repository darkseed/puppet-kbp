class kbp-openldap::server inherits openldap::server {
	# Override openldap::server::database to allow using a custom template
	# for database.conf, which adds configuration (access rules, indexes)
	# for the Samba schema.
	define database($directory="", $suffix="", $admins=false, $storage_type="bdb") {
		# Ugly hack
		if $directory {
			$database_dir = $directory
		} else {
			$database_dir = "/var/lib/ldap/$name"
		}

		file { "/etc/ldap/slapd.db.d/$name.conf":
			owner => "openldap",
			group => "root",
			mode => 640,
			content => template("kbp-openldap/server/database.conf"),
			notify => Exec["update-slapd-conf"],
			require => File["/etc/ldap/slapd.db.d"],
		}

		file { "$database_dir":
			ensure => directory,
			owner => "openldap",
			group => "openldap",
			mode => 750,
		}
	}

	# Include the Samba schema by default
	openldap::server::schema { "samba":
		source => "puppet://puppet/kbp-openldap/slapd/schema/samba.schema",
	}

	# Circumvent the groupOfNames/posixGroup world of hurt by making the
	# posixGroup objectclass auxiliary instead of structural
	file { "/etc/ldap/schema/nis.schema":
		source => "puppet://puppet/kbp-openldap/slapd/schema/nis.schema",
		owner => "root",
		group => "root",
		mode => 644,
		require => Package["slapd"],
	}
}
