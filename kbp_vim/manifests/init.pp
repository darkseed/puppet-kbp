class kbp_vim {
	global_vim_setting {
		"syntax on":;
		"set ai":;
		"set ts=4":;
		"set bg=dark":;
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
