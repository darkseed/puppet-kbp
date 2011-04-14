class kbp_icinga::client {
	kbp_icinga::configdir { "${environment}/${fqdn}":
		sub => $environment;
	}

	kbp_icinga::host { "${fqdn}":; }

	kbp_icinga::service {
		"ssh_${fqdn}":
			service_description => "SSH connectivity",
			checkcommand        => "check_ssh";
		"disk_space_${fqdn}":
			service_description => "Disk space",
			checkcommand        => "check_disk_space",
			nrpe                => true;
		"ksplice_${fqdn}":
			service_description => "Ksplice update status",
			checkcommand        => "check_ksplice",
			nrpe                => true;
		"puppet_state_${fqdn}":
			service_description => "Puppet state freshness",
			checkcommand        => "check_puppet_state_freshness",
			nrpe                => true;
		"cpu_${fqdn}":
			service_description => "CPU usage",
			checkcommand        => "check_cpu",
			nrpe                => true;
#		"loadtrend_${fqdn}":
#			service_description => "Load average",
#			checkcommand        => "check_loadtrend",
#			nrpe                => true;
		"open_files_${fqdn}":
			service_description => "Open files",
			checkcommand        => "check_open_files",
			nrpe                => true;
		"memory_${fqdn}":
			service_description => "Memory usage",
			checkcommand        => "check_memory",
			nrpe                => true;
		"zombie_processes_${fqdn}":
			service_description => "Zombie processes",
			checkcommand        => "check_zombie_processes",
			nrpe                => true;
	}

	kfile {
		"/usr/lib/nagios/plugins/check_cpu":
			source  => "kbp_icinga/client/check_cpu",
			mode    => 755,
			require => Package["nagios-plugins-kumina"];
		"/usr/lib/nagios/plugins/check_open_files":
			source  => "kbp_icinga/client/check_open_files",
			mode    => 755,
			require => Package["nagios-plugins-kumina"];
		"/usr/lib/nagios/plugins/check_memory":
			source  => "kbp_icinga/client/check_memory",
			mode    => 755,
			require => Package["nagios-plugins-kumina"];
		"/usr/lib/nagios/plugins/check_drbd":
			source  => "kbp_icinga/client/check_drbd",
			mode    => 755,
			require => Package["nagios-plugins-kumina"];
	}
}

class kbp_icinga::server {
	include gen_icinga::server

	kbp_icinga::servercommand {
		["check_ssh","check_smtp"]:
			conf_dir => "generic";
		["check_open_files","check_cpu","check_disk_space","check_ksplice","check_memory","check_puppet_state_freshness","check_zombie_processes","check_local_smtp","check_drbd","check_pacemaker"]:
#		"check_loadtrend"]:
			conf_dir => "generic",
			nrpe     => true;
		"check-host-alive":
			conf_dir => "generic",
			commandname => "check_ping",
			argument1 => "-w 5000,100%",
			argument2 => "-c 5000,100%",
			argument3 => "-p 1";
		"check_http":
			conf_dir    => "generic",
			commandname => "check_http",
			argument1   => '-I $HOSTADDRESS$';
		"check_http_vhost":
			conf_dir      => "generic",
			commandname   => "check_http",
			host_argument => '-I $HOSTADDRESS$',
			argument1     => '-H $ARG1$';
		"check_http_vhost_url_and_response":
			conf_dir      => "generic",
			commandname   => "check_http",
			host_argument => '-I $HOSTADDRESS$',
			argument1     => '-H $ARG1$',
			argument2     => '-u $ARG2$',
			argument3     => '-r $ARG3$';
		"check_tcp":
			conf_dir    => "generic",
			commandname => "check_tcp",
			argument1   => '-p $ARG1$';
		"check_nfs":
			conf_dir    => "generic",
			commandname => "check_rpc",
			argument1   => "-C nfs -c2,3";
		"check_mysql":
			conf_dir  => "generic",
			argument1 => "-u nagios";
		"check_sslcert":
			conf_dir  => "generic",
			argument1 => '$ARG1$',
			nrpe      => true;
	}

	kfile {
		"/etc/icinga/htpasswd.users":
			source  => "kbp_icinga/server/htpasswd.users",
			group   => "www-data",
			mode    => 640,
			require => Package["icinga"];
		"/etc/icinga/cgi.cfg":
			source  => "kbp_icinga/server/cgi.cfg",
#			notify  => Exec["reload-icinga"],
			require => Package["icinga"];
		"/etc/icinga/icinga.cfg":
			source  => "kbp_icinga/server/icinga.cfg",
#			notify  => Exec["reload-icinga"],
			require => Package["icinga"];
		"/etc/icinga/config":
			ensure  => directory,
			require => Package["icinga"];
		"/etc/icinga/config/generic":
			ensure  => directory;
		"/etc/icinga/config/generic/notify_commands.cfg":
			source  => "kbp_icinga/server/config/generic/notify_commands.cfg";
#			notify  => Exec["reload-icinga"];
	}

	kbp_icinga::service {
		"generic_ha_service":
			conf_dir                     => "generic",
			use                          => "false",
			initialstate                 => "u",
			active_checks_enabled        => "1",
			passive_checks_enabled       => "1",
			parallelize_check            => "1",
			obsess_over_service          => "1",
			check_freshness              => "0",
			notifications_enabled        => "1",
			event_handler_enabled        => "1",
			flap_detection_enabled       => "1",
			failure_prediction_enabled   => "1",
			process_perf_data            => "1",
			retain_status_information    => "1",
			retain_nonstatus_information => "1",
			notification_interval        => "0",
			is_volatile                  => "0",
			check_period                 => "24x7",
			normal_check_interval        => "15",
			retry_check_interval         => "1",
			max_check_attempts           => "3",
			notification_period          => "24x7",
			notification_options         => "w,u,c,r",
			contact_groups               => "kumina_email, kumina_sms",
			register                     => "0";
		"generic_wh_service":
			conf_dir            => "generic",
			use                 => "generic_ha_service",
			notification_period => "workhours",
			register            => "0";
		"generic_passive_service":
			conf_dir              => "generic",
			use                   => "generic_ha_service",
			checkcommand          => "return-ok",
			active_checks_enabled => "0",
			max_check_attempts    => "1",
			check_freshness       => "1",
			freshnessthreshold    => "360",
			register              => "0";
	}

	kbp_icinga::host {
		"generic_ha_host":
			conf_dir                      => "generic",
			use                           => "false",
			hostgroups                    => "ha_hosts",
			initialstate                  => "u",
			notifications_enabled         => "1",
			event_handler_enabled         => "0",
			flap_detection_enabled        => "1",
			process_perf_data             => "1",
			retain_status_information     => "1",
			retain_nonstatus_information  => "1",
			check_command                 => "check-host-alive",
			check_interval                => "120",
			notification_period           => "24x7",
			notification_interval         => "36000",
			contact_groups                => "kumina",
			max_check_attempts            => "3",
			register                      => "0";
		"generic_wh_host":
			conf_dir   => "generic",
			use        => "generic_ha_host",
			hostgroups => "wh_hosts",
			register   => "0";
	}

	kbp_icinga::contact {
		"kumina_email":
			conf_dir          => "generic",
			c_alias           => "Kumina bv email",
			notification_type => "email",
			contact_data      => "rutger@kumina.nl";
		"kumina_sms":
			conf_dir          => "generic",
			c_alias           => "Kumina bv SMS",
			notification_type => "sms",
			contactgroups     => "kumina_sms_all",
			contact_data      => "+31653680300";
		"tim_sms":
			conf_dir          => "generic",
			c_alias           => "Tim SMS",
			notification_type => "sms",
			contactgroups     => "kumina_sms_all",
			contact_data      => "+31625300480";
		"rutger_sms":
			conf_dir          => "generic",
			c_alias           => "Rutger SMS",
			notification_type => "sms",
			contactgroups     => "kumina_sms_all",
			contact_data      => "+31627416182";
	}

	kbp_icinga::timeperiod {
		"24x7":
			conf_dir  => "generic",
			tp_alias  => "24 hours a day, 7 days a week",
			monday    => "00:00-24:00",
			tuesday   => "00:00-24:00",
			wednesday => "00:00-24:00",
			thursday  => "00:00-24:00",
			friday    => "00:00-24:00",
			saturday  => "00:00-24:00",
			sunday    => "00:00-24:00";
		"workhours":
			conf_dir  => "generic",
			tp_alias  => "Kumina bv work hours",
			monday    => "08:00-18:00",
			tuesday   => "08:00-18:00",
			wednesday => "08:00-18:00",
			thursday  => "08:00-18:00",
			friday    => "08:00-18:00";
	}

	kbp_icinga::hostgroup {
		"ha_hosts":
			conf_dir => "generic",
			hg_alias => "High availability servers";
		"wh_hosts":
			conf_dir => "generic",
			hg_alias => "Workhours availability servers";
	}

	kbp_icinga::contactgroup {
		"kumina":
			conf_dir => "generic",
			cg_alias => "Kumina bv";
		"kumina_email":
			conf_dir => "generic",
			cg_alias => "Kumina bv email";
		"kumina_sms":
			conf_dir => "generic",
			cg_alias => "Kumina bv SMS";
		"kumina_sms_all":
			conf_dir => "generic",
			cg_alias => "Kumina bv SMS employees";
	}
}

class kbp_icinga {
	define service($conf_dir="false", $use="generic_ha_service", $service_description="false", $hostname=$fqdn, $hostgroup_name="false", $initialstate="false", $active_checks_enabled="false", $passive_checks_enabled="false", $parallelize_check="false", $obsess_over_service="false", $check_freshness="false", $freshnessthreshold="false", $notifications_enabled="false", $event_handler_enabled="false", $flap_detection_enabled="false", $failure_prediction_enabled="false", $process_perf_data="false", $retain_status_information="false", $retain_nonstatus_information="false", $notification_interval="false", $is_volatile="false", $check_period="false", $normal_check_interval="false", $retry_check_interval="false", $notification_period="false", $notification_options="false", $contact_groups="false", $servicegroups="false", $max_check_attempts="false", $checkcommand="false", $argument1=false, $argument2=false, $argument3=false, $register="false", $nrpe=false) {
		$conf_dir_name = $conf_dir ? {
			"false" => "${environment}/${fqdn}",
			default => $conf_dir,
		}

		@@ekfile { "/etc/icinga/config/${conf_dir_name}/service_${name}.cfg;${fqdn}":
			content => template("kbp_icinga/service"),
#			notify  => Exec["reload-icinga"],
			require => File["/etc/icinga/config/${conf_dir_name}"],
			tag     => "icinga_config";
		}

		if $nrpe and !defined(Kfile["/etc/nagios/nrpe.d/${checkcommand}.cfg"]) {
			kfile { "/etc/nagios/nrpe.d/${checkcommand}.cfg":
					source  => "kbp_icinga/client/${checkcommand}.cfg",
					require => Package["nagios-nrpe-server"];
			}
		}
	}

	define host($conf_dir="false", $use="generic_ha_host", $hostgroups="ha_hosts", $parents="false", $address=$ipaddress, $initialstate="false", $notifications_enabled="false", $event_handler_enabled="false", $flap_detection_enabled="false", $process_perf_data="false", $retain_status_information="false", $retain_nonstatus_information="false", $check_command="false", $check_interval="false", $notification_period="false", $notification_interval="false", $contact_groups="false", $max_check_attempts="false", $register="false") {
		$conf_dir_name = $conf_dir ? {
			"false" => "${environment}/${name}",
			default => $conf_dir,
		}

		@@ekfile { "/etc/icinga/config/${conf_dir_name}/host_${name}.cfg;${fqdn}":
			content => template("kbp_icinga/host"),
#			notify  => Exec["reload-icinga"],
			require => File["/etc/icinga/config/${conf_dir_name}"],
			tag     => "icinga_config";
		}
	}
	
	define hostgroup($conf_dir="false", $hg_alias, $members="false") {
		$conf_dir_name = $conf_dir ? {
			"false" => "${environment}/${fqdn}",
			default => $conf_dir,
		}

		@@ekfile { "/etc/icinga/config/${conf_dir_name}/hostgroup_${name}.cfg;${fqdn}":
			content => template("kbp_icinga/hostgroup"),
#			notify  => Exec["reload-icinga"],
			require => File["/etc/icinga/config/${conf_dir_name}"],
			tag     => "icinga_config";
		}
	}

	define contactgroup($conf_dir="false", $customer="generic", $cg_alias) {
		$conf_dir_name = $conf_dir ? {
			"false" => "${environment}/${fqdn}",
			default => $conf_dir,
		}

		@@ekfile { "/etc/icinga/config/${conf_dir_name}/contactgroup_${name}.cfg;${fqdn}":
			content => template("kbp_icinga/contactgroup"),
#			notify  => Exec["reload-icinga"],
			require => File["/etc/icinga/config/${conf_dir_name}"],
			tag     => "icinga_config";
		}
	}

	define contact($conf_dir="false", $c_alias, $timeperiod="24x7", $notification_type, $contactgroups="false", $contact_data) {
		$conf_dir_name = $conf_dir ? {
			"false" => "${environment}/${fqdn}",
			default => $conf_dir,
		}

		@@ekfile { "/etc/icinga/config/${conf_dir_name}/contact_${name}.cfg;${fqdn}":
			content => template("kbp_icinga/contact"),
#			notify  => Exec["reload-icinga"],
			require => File["/etc/icinga/config/${conf_dir_name}"],
			tag     => "icinga_config";
		}
	}

	define timeperiod($conf_dir="false", $tp_alias, $monday="false", $tuesday="false", $wednesday="false", $thursday="false", $friday="false", $saturday="false", $sunday="false") {
		$conf_dir_name = $conf_dir ? {
			"false" => "${environment}/${fqdn}",
			default => $conf_dir,
		}

		@@ekfile { "/etc/icinga/config/${conf_dir_name}/timeperiod_${name}.cfg;${fqdn}":
			content => template("kbp_icinga/timeperiod"),
#			notify  => Exec["reload-icinga"],
			require => File["/etc/icinga/config/${conf_dir_name}"],
			tag     => "icinga_config";
		}
	}

	define configdir($sub=false) {
		@@ekfile { "/etc/icinga/config/${name};${fqdn}":
			ensure  => directory,
			require => $sub ? {
				false   => Package["icinga"],
				default => [Package["icinga"],Kbp_icinga::Configdir["${sub}"]],
			},
			tag     => "icinga_config";
		}
	}

	define servercommand($conf_dir=false, $commandname=false, $host_argument='-H $HOSTADDRESS$', $argument1=false, $argument2=false, $argument3=false, $nrpe=false, $time_out=false) {
		$conf_dir_name = $conf_dir ? {
			false => "${environment}/${fqdn}",
			default => $conf_dir,
		}

		@@ekfile { "/etc/icinga/config/${conf_dir_name}/command_${name}.cfg;${fqdn}":
			content => template("kbp_icinga/command"),
#			notify  => Exec["reload-icinga"],
			require => File["/etc/icinga/config/${conf_dir_name}"],
			tag     => "icinga_config";
		}
	}
}
