/proc/is_on_level_name(atom/A,name)
  var/datum/space_level/S = GLOB.space_manager.get_zlev_by_name(name)
  return A.z == S.zpos

// For expansion later
/proc/atoms_share_level(atom/A, atom/B)
  return A && B && A.z == B.z

/**
 * Checks if source_loc and checking_loc is both on the station, or on the same z level.
 * This is because the station's several levels aren't considered the same z, so multi-z stations need this special case.
 * returns TRUE if connection is valid, FALSE otherwise.
 */
/proc/is_valid_z_level(turf/source_loc, turf/checking_loc)
	// if we're both on "station", regardless of multi-z, we'll pass by.
	if(is_station_level(source_loc.z) && is_station_level(checking_loc.z))
		return TRUE
	if(source_loc.z == checking_loc.z)
		return TRUE
	return FALSE
