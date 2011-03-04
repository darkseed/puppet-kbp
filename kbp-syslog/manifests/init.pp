class kbp-syslog::server {
	include "kbp-syslog::server::$lsbdistcodename"
}

class kbp-syslog::client {
	include "kbp-syslog::client::$lsbdistcodename"
}

class kbp-syslog::server::etch inherits syslog-ng::server {
	file { "/etc/logrotate.d/syslog-ng":
		source => "puppet://puppet/kbp-syslog/server/logrotate.d/syslog-ng",
		owner => "root",
		group => "root",
		mode => 644,
	}
}

class kbp-syslog::client::etch inherits sysklogd::client {
}

class kbp-syslog::server::lenny inherits rsyslog::server {
	file { "/etc/logrotate.d/rsyslog":
		source => "puppet://puppet/kbp-syslog/server/logrotate.d/rsyslog",
		owner => "root",
		group => "root",
		mode => 644,
	}
}

class kbp-syslog::client::lenny inherits rsyslog::client {
}

class kbp-syslog::server::squeeze inherits rsyslog::server {
	file { "/etc/logrotate.d/rsyslog":
		source => "puppet://puppet/kbp-syslog/server/logrotate.d/rsyslog",
		owner => "root",
		group => "root",
		mode => 644,
	}
}

class kbp-syslog::client::squeeze inherits rsyslog::client {
}

# Additional options
class kbp-syslog::server::mysql {
	include kbp-syslog::server
	include "kbp-syslog::mysql::$lsbdistcodename"
}

class kbp-syslog::mysql::etch {
	err ("This is not implemented for Etch or earlier!")
}

class kbp-syslog::mysql::lenny inherits rsyslog::mysql {
}
