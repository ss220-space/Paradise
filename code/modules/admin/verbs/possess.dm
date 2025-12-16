ADMIN_VERB_ONLY_CONTEXT_MENU(possess_object, R_POSSESS, "Possess Obj", obj/target as obj in world)
	user.AddComponent(/datum/component/object_possession, target)

	var/turf/turf = get_turf(target)

	log_and_message_admins("[key_name(user)] has possessed [target] ([target.type]) at [AREACOORD(turf)]")
	BLACKBOX_LOG_ADMIN_VERB("Possess Object")

ADMIN_VERB_ONLY_CONTEXT_MENU(release_object, R_POSSESS, "Release Obj", obj/target as obj in world)
	qdel(user.GetComponent(/datum/component/object_possession))

	BLACKBOX_LOG_ADMIN_VERB("Release Object")
