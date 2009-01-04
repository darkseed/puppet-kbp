class kbp-libvirt inherits libvirt {
	include munin::client

	File["/etc/libvirt/libvirtd.conf"] {
		source => undef,
		content => template("kbp-libvirt/libvirt/libvirtd.conf"),
	}

	if ($lsbdistrelease == "4.0") {
		include debian::backports

		Package["libvirt-bin"] {
			require +> Apt::Source["etch-backports"],
		}
	}

	# Munin plugins
	package { ["python-libxml2", "python-libvirt"]:
		ensure => installed,
	}

	file {
		"/etc/munin/plugins/libvirt-blkstat":
			ensure => symlink,
			target => "/usr/local/share/munin/plugins/libvirt-blkstat",
			require => [Package["python-libvirt"], Package["python-libxml2"]],
			notify => Service["munin-node"];
		"/etc/munin/plugins/libvirt-cputime":
			ensure => symlink,
			target => "/usr/local/share/munin/plugins/libvirt-cputime",
			require => [Package["python-libvirt"], Package["python-libxml2"]],
			notify => Service["munin-node"];
		"/etc/munin/plugins/libvirt-ifstat":
			ensure => symlink,
			target => "/usr/local/share/munin/plugins/libvirt-ifstat",
			require => [Package["python-libvirt"], Package["python-libxml2"]],
			notify => Service["munin-node"];
		"/etc/munin/plugins/libvirt-mem":
			ensure => symlink,
			target => "/usr/local/share/munin/plugins/libvirt-mem",
			require => [Package["python-libvirt"], Package["python-libxml2"]],
			notify => Service["munin-node"];
	}
}
