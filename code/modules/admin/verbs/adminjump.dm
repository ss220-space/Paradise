#define JUMP_TO_AREA "Area"
#define JUMP_TO_MOB "Mob"
#define JUMP_TO_KEY "Key"
#define JUMP_TO_COORDINATES "Coordinates"

ADMIN_VERB(jump_to, R_ADMIN, "Jump to...", "Area, Mob, Key or Coordinate", ADMIN_CATEGORY_GAME)
	var/list/choices = list(JUMP_TO_AREA, JUMP_TO_MOB, JUMP_TO_KEY, JUMP_TO_COORDINATES)
	var/chosen = tgui_input_list(user, "What to jump to?", "Jump to...", choices)
	if(!chosen)
		return

	var/jumping // Thing to jump to
	switch(chosen)
		if(JUMP_TO_AREA)
			jumping = tgui_input_list(user, "Area to jump to", "Jump to Area", get_sorted_areas())
			if(jumping)
				return SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/jump_to_area, jumping)
		if(JUMP_TO_MOB)
			jumping = tgui_input_list(user, "Mob to jump to", "Jump to Mob", GLOB.mob_list)
			if(jumping)
				return SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/jump_to_mob, jumping)
		if(JUMP_TO_KEY)
			jumping = tgui_input_list(user, "Key to jump to", "Jump to Key", sort_key(GLOB.clients))
			if(jumping)
				return SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/jump_to_key, jumping)
		if(JUMP_TO_COORDINATES)
			var/x = tgui_input_number(user, "X Coordinate", "Jump to Coordinates")
			if(!x)
				return
			var/y = tgui_input_number(user, "Y Coordinate", "Jump to Coordinates")
			if(!y)
				return
			var/z = tgui_input_number(user, "Z Coordinate", "Jump to Coordinates")
			if(!z)
				return
			return SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/jump_to_coord, x, y, z)

#undef JUMP_TO_AREA
#undef JUMP_TO_MOB
#undef JUMP_TO_KEY
#undef JUMP_TO_COORDINATES

ADMIN_VERB(jump_to_area, R_ADMIN, "Jump To Area", "Jumps to the specified area.", ADMIN_CATEGORY_GAME, area/target in world)
	if(!isobserver(user.mob))
		SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/admin_ghost)

	var/turf/drop_location
	top_level:
		for(var/list/zlevel_turfs as anything in target.get_zlevel_turf_lists())
			for(var/turf/area_turf as anything in zlevel_turfs)
				drop_location = area_turf
				break top_level

	if(isnull(drop_location))
		to_chat(user, span_warning("No valid drop location found in the area!"))
		return

	user.mob.abstract_move(drop_location)
	log_admin("[key_name(user)] jumped to [AREACOORD(drop_location)]")
	message_admins("[key_name_admin(user)] jumped to [AREACOORD(drop_location)]")
	BLACKBOX_LOG_ADMIN_VERB("Jump To Area")

ADMIN_VERB_AND_CONTEXT_MENU(jump_to_turf, R_ADMIN, "Jump To Turf", "Jump to any turf in the game. This will lag your client.", ADMIN_CATEGORY_GAME, turf/locale in world)
	if(!isobserver(user.mob))
		SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/admin_ghost)
	log_admin("[key_name(user)] jumped to [AREACOORD(locale)]")
	message_admins("[key_name_admin(user)] jumped to [AREACOORD(locale)]")
	user.mob.abstract_move(locale)
	BLACKBOX_LOG_ADMIN_VERB("Jump To Turf")

ADMIN_VERB_AND_CONTEXT_MENU(jump_to_mob, R_ADMIN, "Jump To Mob", "Jump to any mob in the game.", ADMIN_CATEGORY_GAME, mob/target in world)
	if(!isobserver(user.mob))
		SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/admin_ghost)
	user.mob.abstract_move(target.loc)
	log_admin("[key_name(user)] jumped to [key_name(target)]")
	message_admins("[key_name_admin(user)] jumped to [ADMIN_LOOKUPFLW(target)] at [AREACOORD(target)]")
	BLACKBOX_LOG_ADMIN_VERB("Jump To Mob")

ADMIN_VERB(jump_to_coord, R_ADMIN, "Jump To Coordinate", "Jump to a specific coordinate in the game world.", ADMIN_CATEGORY_GAME, cx as num, cy as num, cz as num)
	if(!isobserver(user.mob))
		SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/admin_ghost)

	var/turf/where_we_droppin = locate(cx, cy, cz)
	if(isnull(where_we_droppin))
		to_chat(user, span_warning("Invalid coordinates."))
		return

	user.mob.abstract_move(where_we_droppin)
	message_admins("[key_name_admin(user)] jumped to coordinates [cx], [cy], [cz]")
	BLACKBOX_LOG_ADMIN_VERB("Jump To Coordiate")

ADMIN_VERB(jump_to_key, R_ADMIN, "Jump To Key", "Jump to a specific player.", ADMIN_CATEGORY_GAME)
	if(!isobserver(user.mob))
		SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/admin_ghost)

	var/list/keys = list()
	for(var/mob/player in GLOB.player_list)
		keys += player.client

	var/client/selection = input(user, "Please, select a player!", "Admin Jumping") as null | anything in sort_key(keys)
	if(!selection)
		to_chat(user, "No keys found.", confidential = TRUE)
		return

	var/mob/target = selection.mob
	log_admin("[key_name(user)] jumped to [key_name(target)]")
	message_admins("[key_name_admin(user)] jumped to [ADMIN_LOOKUPFLW(target)]")
	user.mob.abstract_move(target.loc)
	BLACKBOX_LOG_ADMIN_VERB("Jump To Key")

ADMIN_VERB_AND_CONTEXT_MENU(get_mob, R_ADMIN, "Get Mob", "Teleport a mob to your location.", ADMIN_CATEGORY_GAME, mob/target in world)
	var/atom/loc = get_turf(user.mob)
	target.admin_teleport(loc)
	BLACKBOX_LOG_ADMIN_VERB("Get Mob")

ADMIN_VERB(get_key, R_ADMIN, "Get Key", "Teleport the player with the provided key to you.", ADMIN_CATEGORY_GAME)
	var/list/keys = list()
	for(var/mob/target in GLOB.player_list)
		keys += target.client

	var/client/selection = input(user, "Please, select a player!", "Admin Jumping") as null | anything in sort_key(keys)
	if(!selection)
		return

	var/mob/selected_mob = selection.mob
	if(!selected_mob)
		return

	selected_mob.forceMove(get_turf(user))
	log_admin("[key_name(user)] teleported [key_name(selected_mob)]")
	message_admins("[key_name_admin(usr)] teleported [ADMIN_LOOKUPFLW(selected_mob)]")
	BLACKBOX_LOG_ADMIN_VERB("Get Key")

ADMIN_VERB_AND_CONTEXT_MENU(send_mob, R_ADMIN, "Send Mob", "Teleport the specified mob to an area of your choosing.", ADMIN_CATEGORY_GAME, mob/jumper)
	var/list/sorted_areas = get_sorted_areas()
	if(!length(sorted_areas))
		to_chat(user, "No areas found.", confidential = TRUE)
		return

	var/area/target_area = tgui_input_list(user, "Pick an area", "Send Mob", sorted_areas)
	if(!istype(target_area)) //MONKE EDIT istype basically does isnull as well
		return

	var/list/turfs = get_area_turfs(target_area)
	if(length(turfs) && jumper.forceMove(pick(turfs)))
		log_admin("[key_name(user)] teleported [key_name(jumper)] to [AREACOORD(jumper)]")
		message_admins("[key_name_admin(user)] teleported [ADMIN_LOOKUPFLW(jumper)] to [AREACOORD(jumper)]")
	else
		to_chat(user, "Failed to move mob to a valid location.", confidential = TRUE)

	BLACKBOX_LOG_ADMIN_VERB("Send Mob")

/mob/admin_teleport(atom/new_location)
	var/turf/location = get_turf(new_location)
	message_admins("[key_name_admin(usr)] teleported [ADMIN_LOOKUPFLW(src)] to [isnull(new_location) ? "nullspace" : ADMIN_VERBOSEJMP(location)]")
	return ..()
