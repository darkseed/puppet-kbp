class kbp_vim {
	global_vim_setting {
		"syntax on":;
		"set ai":;
		"set ts=8":;
		"set bg=dark":;
		"set list":;
		"set listchars=tab:»˙,trail:•":;
		"set hlsearch":;
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

	define vim_addon($package=false) {
		# Install and activate a vim addon. Use as follows:
		# kbp_vim::vim_addon { "puppet": package => "vim-puppet"; }
		include kbp_vim::addon-manager
		$the_package = $package ? {
			false   => $name,
			default => $package,
		}
		kpackage { $the_package:
			ensure => latest;
		}
		exec { "/usr/bin/vim-addons -w install ${name}":
			unless  => "/usr/bin/vim-addons -w -q show ${name} | grep 'installed' 2>&1 > /dev/null",
			require => Package["vim-addon-manager", "${the_package}"];
		}
	}
}

class kbp_vim::addon-manager {
	kpackage { "vim-addon-manager":
		ensure => "latest";
	}
}
