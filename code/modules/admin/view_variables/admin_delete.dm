/client/proc/admin_delete(datum/thing)
	if(istype(thing) && !thing.can_vv_delete())
		to_chat(src, "[thing] rejected your deletion.", confidential = TRUE)
		return

	var/atom/target_atom = thing
	var/coords = ""
	var/jmp_coords = ""
	if(istype(target_atom))
		var/turf/atom_turf = get_turf(target_atom)
		if(atom_turf)
			var/atom/atom_loc = target_atom.loc
			var/is_turf = isturf(atom_loc)
			coords = "[is_turf ? "at" : "from [atom_loc] at"] [AREACOORD(atom_turf)]"
			jmp_coords = "[is_turf ? "at" : "from [atom_loc] at"] [ADMIN_VERBOSEJMP(atom_turf)]"
		else
			jmp_coords = coords = "in nullspace"

	if(tgui_alert(usr, "Are you sure you want to delete:\n[thing]\n[coords]?", "Confirmation", list("Yes", "No")) == "Yes")
		log_admin("[key_name(usr)] deleted [thing] [coords]")
		message_admins("[key_name_admin(usr)] deleted [thing] [jmp_coords]")
		BLACKBOX_LOG_ADMIN_VERB("Delete")
		SEND_SIGNAL(thing, COMSIG_ADMIN_DELETING, src)

		if(isturf(thing))
			var/turf/current_turf = thing
			current_turf.ChangeTurf(current_turf.baseturf)
		else
			vv_update_display(thing, "deleted", VV_MSG_DELETED)
			qdel(thing)
			if(!QDELETED(thing))
				vv_update_display(thing, "deleted", "")
