class kbp-apt-proxy inherits approx {
	File["/etc/approx/approx.conf"] {
		source => "puppet://puppet/kbp-apt-proxy/approx/approx.conf",
	}
}
