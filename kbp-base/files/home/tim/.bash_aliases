alias kickpuppet='sudo puppetd --no-daemonize --no-splay --onetime --logdest console --logdest syslog'
alias runpuppet='sudo puppetd --no-daemonize --no-splay --onetime --logdest console --logdest syslog'

if [ -f ~/.bash_aliases.local ]; then
    . ~/.bash_aliases.local
fi
