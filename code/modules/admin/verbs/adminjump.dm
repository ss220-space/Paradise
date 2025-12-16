ADMIN_VERB(jump_to, R_ADMIN, "Jump to...", "Area, Mob, Key or Coordinate", ADMIN_CATEGORY_GAME)
	var/list/choices = list("Area", "Mob", "Key", "Coordinates")
	var/chosen = tgui_input_list(user, "What to jump to?", "Jump to...", choices)
	if(!chosen)
		return

	var/jumping // Thing to jump to
	switch(chosen)
		if("Area")
			jumping = tgui_input_list(user, "Area to jump to", "Jump to Area", get_sorted_areas())
			if(jumping)
				return user.jump_to_area(jumping)
		if("Mob")
			jumping = tgui_input_list(user, "Mob to jump to", "Jump to Mob", GLOB.mob_list)
			if(jumping)
				return user.jumptomob(jumping)
		if("Key")
			jumping = tgui_input_list(user, "Key to jump to", "Jump to Key", sortKey(GLOB.clients))
			if(jumping)
				return user.jump_to_key(jumping)
		if("Coordinates")
			var/x = tgui_input_number(user, "X Coordinate", "Jump to Coordinates")
			if(!x)
				return
			var/y = tgui_input_number(user, "Y Coordinate", "Jump to Coordinates")
			if(!y)
				return
			var/z = tgui_input_number(user, "Z Coordinate", "Jump to Coordinates")
			if(!z)
				return
			return user.jump_to_coord(x, y, z)

/client/proc/jump_to_area(area/A)
	if(!A || !check_rights(R_ADMIN))
		return

	var/list/turfs = list()
	for(var/turf/T in A)
		if(T.density)
			continue
		if(locate(/obj/structure/grille) in T) // Quick check to not spawn in windows
			continue
		turfs += T

	var/turf/T = safepick(turfs)
	if(!T)
		to_chat(src, "Nowhere to jump to!")
		return

	if(isobj(usr.loc))
		var/obj/O = usr.loc
		O.force_eject_occupant(usr)

	admin_forcemove(usr, T)
	log_admin("[key_name(usr)] jumped to [A]")
	if(!isobserver(usr))
		message_admins("[key_name_admin(usr)] jumped to [A]")
	BLACKBOX_LOG_ADMIN_VERB("Jump To Area")

ADMIN_VERB_ONLY_CONTEXT_MENU(jump_to_turf, R_ADMIN, "Jump To Turf", turf/T in world)
	if(isobj(user.mob.loc))
		var/obj/O = user.mob.loc
		O.force_eject_occupant(user.mob)

	log_admin("[key_name(user)] jumped to [COORD(T)] in [T.loc]")

	if(!isobserver(user.mob))
		message_admins("[key_name_admin(user)] jumped to [COORD(T)] in [T.loc]")

	admin_forcemove(user.mob, T)
	BLACKBOX_LOG_ADMIN_VERB("Jump To Turf")

/client/proc/jumptomob(mob/M)
	if(!M || !check_rights(R_ADMIN))
		return

	log_admin("[key_name(usr)] jumped to [key_name(M)]")
	if(!isobserver(usr))
		message_admins("[key_name_admin(usr)] jumped to [key_name_admin(M)]")
	if(isobj(usr.loc))
		var/obj/O = usr.loc
		O.force_eject_occupant(usr)
	if(src.mob)
		var/mob/A = src.mob
		var/turf/T = get_turf(M)
		if(T && isturf(T))
			BLACKBOX_LOG_ADMIN_VERB("Jump To Mob")
			admin_forcemove(A, M.loc)
		else
			to_chat(A, "This mob is not located in the game world.")

/client/proc/jump_to_coord(tx as num, ty as num, tz as num)
	if(!isobserver(usr) && !check_rights(R_ADMIN)) // Only admins can jump without being a ghost
		return

	var/turf/T = locate(tx, ty, tz)

	if(T)
		if(isobj(usr.loc))
			var/obj/O = usr.loc
			O.force_eject_occupant(usr)

		admin_forcemove(usr, T)

		if(isobserver(usr))
			var/mob/dead/observer/O = usr
			O.ManualFollow(T)

		BLACKBOX_LOG_ADMIN_VERB("Jump To Coordinate")

	if(!isobserver(usr))
		message_admins("[key_name_admin(usr)] jumped to coordinates [COORD(T)]")

/client/proc/jump_to_key(client/C)
	if(!C?.mob || !check_rights(R_ADMIN))
		return
	var/mob/M = C.mob
	log_admin("[key_name(usr)] jumped to [key_name(M)]")
	if(!isobserver(usr))
		message_admins("[key_name_admin(usr)] jumped to [key_name_admin(M)]")
	if(isobj(usr.loc))
		var/obj/O = usr.loc
		O.force_eject_occupant(usr)
	admin_forcemove(usr, M.loc)

	BLACKBOX_LOG_ADMIN_VERB("Jump To Key")

ADMIN_VERB_AND_CONTEXT_MENU(get_mob, R_ADMIN, "Get Mob", "Teleport a mob to your location.", ADMIN_CATEGORY_GAME, mob/target in GLOB.mob_list)
	log_and_message_admins("teleported [key_name_admin(target)]")

	if(isobj(target.loc))
		var/obj/target_loc = target.loc
		target_loc.force_eject_occupant(target)
	admin_forcemove(target, get_turf(user.mob))
	BLACKBOX_LOG_ADMIN_VERB("Get Mob")

ADMIN_VERB(get_key, R_ADMIN, "Get Key", "Teleport the player with the provided key to you.", ADMIN_CATEGORY_GAME)
	var/list/keys = list()
	for(var/mob/M in GLOB.player_list)
		keys += M.client
	var/selection = tgui_input_list(user, "Please, select a player!", "Admin Jumping", sortKey(keys))
	if(!selection)
		return
	var/mob/M = selection:mob

	if(!M)
		return
	log_and_message_admins("teleported [key_name(M)]")
	if(M)
		if(isobj(M.loc))
			var/obj/O = M.loc
			O.force_eject_occupant(M)
		admin_forcemove(M, get_turf(user.mob))
		admin_forcemove(user.mob, M.loc)
		BLACKBOX_LOG_ADMIN_VERB("Get Key")

ADMIN_VERB_AND_CONTEXT_MENU(sendmob, R_ADMIN, "Send Mob", "Teleport the specified mob to an area of your choosing.", ADMIN_CATEGORY_GAME, mob/target in GLOB.mob_list)
	var/area/picked_area = tgui_input_list(user, "Pick an area.", "Pick an area", get_sorted_areas())
	if(!picked_area)
		return

	if(isobj(target.loc))
		var/obj/target_loc = target.loc
		target_loc.force_eject_occupant(target)
	admin_forcemove(target, pick(get_area_turfs(picked_area)))
	log_and_message_admins("teleported [key_name_admin(target)] to [picked_area]")
	BLACKBOX_LOG_ADMIN_VERB("Send Mob")

/proc/admin_forcemove(mob/mover, atom/newloc)
	mover.forceMove(newloc)
	mover.on_forcemove(newloc)

/mob/proc/on_forcemove(atom/newloc)
	return
