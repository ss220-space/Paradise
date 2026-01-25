ADMIN_VERB_ONLY_CONTEXT_MENU(possess_object, R_POSSESS, "Possess Obj", obj/target in world)
	var/result = user.mob.AddComponent(/datum/component/object_possession, target)

	if(isnull(result)) // trigger a safety movement just in case we yonk
		user.mob.forceMove(get_turf(user.mob))
		return

	var/turf/target_turf = get_turf(target)
	var/message = "[key_name(user)] has possessed [target] ([target.type]) at [AREACOORD(target_turf)]"
	message_admins(message)
	log_admin(message)
	BLACKBOX_LOG_ADMIN_VERB("Possess Object")

ADMIN_VERB_ONLY_CONTEXT_MENU(release_object, R_POSSESS, "Release Obj", obj/target in world)
	var/possess_component = user.mob.GetComponent(/datum/component/object_possession)
	if(!isnull(possess_component))
		qdel(possess_component)

	BLACKBOX_LOG_ADMIN_VERB("Release Object")
