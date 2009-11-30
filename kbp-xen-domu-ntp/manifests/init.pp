class kbp-xen-domu-ntp {
	include ntp
	include sysctl

	exec { "/bin/echo 'xen.independent_wallclock = 1' >> '/etc/sysctl.conf'":
		unless => "/bin/grep -Fx 'xen.independent_wallclock = 1' /etc/sysctl.conf";
	}
}
