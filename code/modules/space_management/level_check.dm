/proc/is_on_level_name(atom/atom, name)
	var/datum/space_level/level = GLOB.space_manager.get_zlev_by_name(name)
	return atom.z == level.zpos

// For expansion later
/proc/atoms_share_level(atom/first, atom/second)
	return first && second && first.z == second.z
