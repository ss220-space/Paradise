///Returns the src and all recursive contents as a list.
/atom/proc/get_all_contents(ignore_flag_1)
	. = list(src)
	var/idx = 0
	while(idx < length(.))
		var/atom/checked_atom = .[++idx]
		if(checked_atom.flags_1 & ignore_flag_1)
			continue
		. += checked_atom.contents
