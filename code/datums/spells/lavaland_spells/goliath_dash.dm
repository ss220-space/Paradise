/obj/effect/proc_holder/spell/goliath_dash
	name = "Goliath Dash"
	desc = "Сделайте рывок, после чего атакуйте щупальцами голиафа."
	school = "lavaland"
	base_cooldown = 20 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	invocation = "RAGET'RE BRAN!"
	invocation_type = "shout"
	action_icon_state = "goliath_dash"
	need_active_overlay = TRUE

/obj/effect/proc_holder/spell/goliath_dash/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom

/obj/effect/proc_holder/spell/goliath_dash/cast(list/targets, mob/user = usr)
	var/target = targets[1]

	user.stop_pulling()
	user.unbuckle_all_mobs(TRUE)
	user.buckled?.unbuckle_mob(user, TRUE)
	user.pulledby?.stop_pulling()

	user.layer = LOW_LANDMARK_LAYER

	ADD_TRAIT(user, TRAIT_IMMOBILIZED, UNIQUE_TRAIT_SOURCE(src))

	for(var/i in 1 to 7)
		if(QDELETED(user))
			return

		var/direction = get_dir(user, target)
		var/turf/next_step = get_step(user, direction)
		user.face_atom(target)

		if(!is_path_exist(user, next_step, PASSTABLE|PASSFENCE))
			break

		user.forceMove(next_step)
		playsound(user.loc, pick('sound/effects/footstep/heavy1.ogg', 'sound/effects/footstep/heavy2.ogg'), 100, TRUE)
		sleep(0.05 SECONDS)

	if(QDELETED(user))
		return

	user.layer = initial(user.layer)
	REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, UNIQUE_TRAIT_SOURCE(src))
	visible_message(span_warning("[user] выпускает щупальца из земли вокруг себя!"))

	for(var/d in GLOB.alldirs)
		var/turf/E = get_step(user, d)
		new /obj/effect/temp_visual/goliath_tentacle(E, user)

