class kbp-libvirt inherits libvirt {
	include munin::client

	# Munin plugins
	package {
		"python-libxml2":
			ensure => installed;
		"python-libvirt":
			ensure => installed;
	}

	munin::client::plugin {
		["libvirt-blkstat", "libvirt-cputime", "libvirt-ifstat", "libvirt-mem"]:
			require => Package["python-libvirt", "python-libxml2"];
	}
}
