alias kickpuppet='sudo puppetd --verbose --no-daemonize --no-splay --onetime'
alias runpuppet='sudo puppetd --no-daemonize --no-splay --onetime --logdest console --logdest syslog'

if [ -f ~/.bash_aliases.local ]; then
    . ~/.bash_aliases.local
fi
