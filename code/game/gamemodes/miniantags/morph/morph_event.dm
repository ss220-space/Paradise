/datum/event/spawn_morph
	var/key_of_morph

/datum/event/spawn_morph/proc/get_morph()
	spawn()
		var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a morph?", ROLE_MORPH, TRUE, source = /mob/living/simple_animal/hostile/morph)
		if(!candidates.len)
			key_of_morph = null
			kill()
			return


		var/mob/picked = pick(candidates)
		key_of_morph = picked.key
		if(!key_of_morph)
			kill()
			return

		var/datum/mind/player_mind = new /datum/mind(key_of_morph)
		player_mind.active = 1
		var/obj/machinery/atmospherics/unary/vent_pump/vent = pick(get_valid_vent_spawns(exclude_visible_by_mobs = TRUE))
		if(!vent)
			kill()
			return
		var/mob/living/simple_animal/hostile/morph/morph = new(vent.loc)
		player_mind.transfer_to(morph)
		morph.make_morph_antag()
		morph.move_into_vent(vent, FALSE)
		message_admins("[key_name_admin(morph)] has been made into morph by an event.")
		add_game_logs("was spawned as a morph by an event.", morph)

/datum/event/spawn_morph/start()
	get_morph()
