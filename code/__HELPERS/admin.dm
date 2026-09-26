/proc/get_holders_with_rights(rights)
	var/list/valid_holders = list()
	for(var/client/holder as anything in GLOB.admins)
		if(check_rights_for(holder, rights))
			valid_holders += holder

	return valid_holders
