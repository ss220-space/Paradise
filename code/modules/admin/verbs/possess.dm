/proc/possess(obj/target as obj in world)
	set name = "\[Admin\] Possess Obj"

	if(!check_rights(R_POSSESS))
		return

	usr.AddComponent(/datum/component/object_possession, target)

	var/turf/turf = get_turf(target)
	
	log_and_message_admins("[key_name(usr)] has possessed [target] ([target.type]) at [AREACOORD(turf)]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Possess Object") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/proc/release(obj/target in world)
	set name = "\[Admin\] Release Obj"

	if(!check_rights(R_POSSESS))
		return

	qdel(usr.GetComponent(/datum/component/object_possession))

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Release Object") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
