class kbp-munin::client {
	include munin::client
}

class kbp-munin::server {
	include munin::server
	include nagios::nsca
}
