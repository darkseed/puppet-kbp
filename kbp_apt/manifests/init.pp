class kbp_apt {
	include gen_apt

	# Keys for backports, kumina, cassandra, ksplice, jenkins, rabbitmq (in this order)
	gen_apt::key { ["16BA136C","498B91E6","8D77295D","B6D4038E","D50582E6","056E8E56"]:; }
}
