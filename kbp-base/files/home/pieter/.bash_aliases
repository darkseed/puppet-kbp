alias kickpuppet='sudo puppetd --verbose --no-daemonize --no-splay --onetime'
alias runpuppet='sudo puppetd --no-daemonize --no-splay --onetime --logdest console --logdest syslog'
alias twenty_five_get_free_port='sudo grep port /etc/libvirt/qemu/*'
alias twenty_five_get_free_ip='cat /etc/dhcp3/dhcpd.conf'

if [ -d "/srv/puppet" ]; then

	function rgreppuppet {
		no_comments=""
		search_string=""
			while [ "$1" != "" ]; do
				case $1 in
					-n )	no_comments="true" 
							shift
							;;
					* )		search_string="$search_string $1"
							shift 
							;;
				esac
			done
		if [ "$no_comments" == "true" ]; then
			hidesvn rgrep "$search_string" /srv/puppet | grep -v '[[:space:]]*#'
		else
			hidesvn rgrep "$search_string" /srv/puppet
		fi
	}
fi

#alias twenty_five_reset_vm='VPSlv=$1; sudo dd if=/var/lib/media/initial.raw of=/dev/guest/$VPSlv-disk0 ; sudo virsh destroy $VPSlv ; sudo virsh start $VPSlv'


if [ -f ~/.bash_aliases.local ]; then
    . ~/.bash_aliases.local
fi
