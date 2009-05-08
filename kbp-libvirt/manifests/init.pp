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

	munin::client::plugin { ["libvirt-blkstat", "libvirt-cputime", "libvirt-ifstat", "libvirt-mem"]:
		require => [Package["python-libvirt"], Package["python-libxml2"]],
	}
}
