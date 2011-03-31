class kbp_vim {
	global_vim_setting {
		"syntax on":;
		"set ai":;
		"set ts=8":;
		"set bg=dark":;
		"set list":;
		"set listchars=tab:»˙,trail:•":;
		"set backupdir=~/.tmp/":
			require => Global_vim_setting['silent execute "!mkdir -p ~/.tmp"'];
		"set directory=~/.tmp/":
			require => Global_vim_setting['silent execute "!mkdir -p ~/.tmp"'];
		'silent execute "!mkdir -p ~/.tmp"':;
	}

	define global_vim_setting {
		line { "global vim setting ${name}":
			ensure  => "present",
			file    => "/etc/vim/vimrc",
			content => "${name}",
		}
	}
}

class kbp_vim::addon-manager {
	package { "vim-addon-manager":
		ensure => "latest",
	}
}
