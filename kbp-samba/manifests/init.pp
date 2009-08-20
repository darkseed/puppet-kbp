class kbp-samba inherits samba::server {
	package { "smbldap-tools":
		ensure => installed,
	}

	file {
		"/etc/smbldap-tools/smbldap_bind.conf":
			content => template("kbp-samba/smbldap-tools/smbldap_bind.conf"),
			owner => "root",
			group => "root",
			mode => 640,
			require => Package["smbldap-tools"];
		"/etc/smbldap-tools/smbldap.conf":
			content => template("kbp-samba/smbldap-tools/smbldap.conf"),
			owner => "root",
			group => "root",
			mode => 644,
			require => Package["smbldap-tools"];
	}
}
