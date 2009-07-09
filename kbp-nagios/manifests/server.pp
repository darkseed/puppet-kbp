class kbp-nagios::server::plugins inherits nagios::server::plugins {
}

class kbp-nagios::server inherits nagios::server {
	include kbp-nagios::server::plugins

	file { "/etc/nagios3/local.d":
		source => "puppet://puppet/kbp-nagios/nagios3/local.d",
		owner => "root",
		group => "root",
		mode => 644,
		recurse => true,
		ignore => ".*.swp",
		notify => Exec["reload-nagios3"],
	}

	file {
		"/etc/nagios3/conf.d/contacts.cfg":
			source => "puppet://puppet/kbp-nagios/nagios3/conf.d/contacts.cfg",
			owner => "root",
			group => "root",
			mode => 644,
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/generic-host.cfg":
			source => "puppet://puppet/kbp-nagios/nagios3/conf.d/generic-host.cfg",
			owner => "root",
			group => "root",
			mode => 644,
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/generic-service.cfg":
			source => "puppet://puppet/kbp-nagios/nagios3/conf.d/generic-service.cfg",
			owner => "root",
			group => "root",
			mode => 644,
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/hostgroups.cfg":
			source => "puppet://puppet/kbp-nagios/nagios3/conf.d/hostgroups.cfg",
			owner => "root",
			group => "root",
			mode => 644,
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/misc_commands.cfg":
			source => "puppet://puppet/kbp-nagios/nagios3/conf.d/misc_commands.cfg",
			owner => "root",
			group => "root",
			mode => 644,
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/notify_commands.cfg":
			source => "puppet://puppet/kbp-nagios/nagios3/conf.d/notify_commands.cfg",
			owner => "root",
			group => "root",
			mode => 644,
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/passive_services.cfg":
			source => "puppet://puppet/kbp-nagios/nagios3/conf.d/passive_services.cfg",
			owner => "root",
			group => "root",
			mode => 644,
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/servicegroups.cfg":
			source => "puppet://puppet/kbp-nagios/nagios3/conf.d/servicegroups.cfg",
			owner => "root",
			group => "root",
			mode => 644,
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/services.cfg":
			source => "puppet://puppet/kbp-nagios/nagios3/conf.d/services.cfg",
			owner => "root",
			group => "root",
			mode => 644,
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/timeperiods.cfg":
			source => "puppet://puppet/kbp-nagios/nagios3/conf.d/timeperiods.cfg",
			owner => "root",
			group => "root",
			mode => 644,
			notify => Exec["reload-nagios3"];
	}
}
