class kbp_concat {
	include common::concat::setup

	define add_content($target, $content, $order=15) {
		$body = $content ? {
			false   => $name,
			default => $content,
		}
	
		concat::fragment{ "${target}_fragment_${name}":
			content => "${body}\n",
			target  => $target,
			order   => $order;
		}
	}
}
