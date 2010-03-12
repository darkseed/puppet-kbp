class kbp-libvirt inherits libvirt {
	include munin::client

	# Munin plugins
	package {
		"python-libxml2":
			ensure => installed;
		"python-libvirt":
			ensure => installed;
	}

	file {
		"/etc/libvirt/qemu/networks/default.xml":
			require => Package["libvirt-bin"],
			ensure => absent;
		"/etc/libvirt/storage":
			ensure => directory,
			require => Package["libvirt-bin"],
			owner => "root",
			group => "root",
			mode => 755;
		"/etc/libvirt/storage/autostart":
			ensure => directory,
			require => File["/etc/libvirt/storage"],
			owner => "root",
			group => "root",
			mode => 755;
		"/etc/libvirt/storage/guest.xml":
			source => "puppet://puppet/kbp-libvirt/libvirt/storage/guest.xml",
			require => File["/etc/libvirt/storage"],
			owner => "root",
			group => "root",
			mode => 644;
		"/etc/libvirt/storage/autostart/guest.xml":
			ensure => "/etc/libvirt/storage/guest.xml",
			require => File["/etc/libvirt/storage/autostart"];
	}

	munin::client::plugin {
		["libvirt-blkstat", "libvirt-cputime", "libvirt-ifstat", "libvirt-mem"]:
			require => Package["python-libvirt", "python-libxml2"],
			script_path => "/usr/local/share/munin/plugins";
	}
}
