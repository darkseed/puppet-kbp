class kbp-munin::client inherits munin::client {
}

class kbp-munin::server inherits munin::server {
	include nagios::nsca
}
