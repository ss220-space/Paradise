/// Place some grappling tentacles underfoot
/obj/effect/proc_holder/spell/basic_goliath_tentacles
	name = "Unleash Tentacles"
	desc = "Unleash burrowed tentacles at a targetted location, grappling targets after a delay."
	action_icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	action_icon_state = "goliath_tentacle_wiggle"
	action_background_icon_state = "bg_demon"
	need_active_overlay = TRUE
	base_cooldown = 12 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	invocation_type = "none"
	/// Furthest range we can activate ability at
	var/max_range = 7

/obj/effect/proc_holder/spell/basic_goliath_tentacles/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom

/obj/effect/proc_holder/spell/basic_goliath_tentacles/before_cast(list/targets, mob/user)
	var/target = get_turf(targets[1])
	if(get_dist(user, target) > max_range)
		if(isliving(target))
			var/mob/living/livivng_target = target
			livivng_target.balloon_alert(user, "цель слишком далеко!")
		return
	return ..()


/obj/effect/proc_holder/spell/basic_goliath_tentacles/cast(list/targets, mob/user = usr)
	. = ..()
	var/target = targets[1]
	new /obj/effect/goliath_tentacle(target)
	var/list/directions = GLOB.cardinal.Copy()
	for(var/i in 1 to 3)
		var/spawndir = pick_n_take(directions)
		var/turf/adjacent_target = get_step(target, spawndir)
		if(adjacent_target)
			new /obj/effect/goliath_tentacle(adjacent_target)
	if(isliving(target))
		var/mob/living/livivng_target = target
		user.visible_message(span_warning("[user.declent_ru(NOMINATIVE)] атакует щупальцами [livivng_target.declent_ru(ACCUSATIVE)]!"))

/// Place grappling tentacles around you to grab attackers
/obj/effect/proc_holder/spell/basic_tentacle_burst
	name = "Tentacle Grasp"
	desc = "Unleash burrowed tentacles in a line towards a targeted location, grappling targets after a delay."
	action_icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	action_icon_state = "goliath_tentacle_wiggle"
	action_background_icon_state = "bg_demon"
	need_active_overlay = TRUE
	base_cooldown = 12 SECONDS
	clothes_req = FALSE
	human_req = FALSE

/obj/effect/proc_holder/spell/basic_tentacle_burst/cast(list/targets, mob/user = usr)
	var/list/directions = GLOB.alldirs.Copy()
	var/target = targets[1]
	for(var/dir in directions)
		var/turf/adjacent_target = get_step(target, dir)
		if(adjacent_target)
			new /obj/effect/goliath_tentacle(adjacent_target)
	user.visible_message(span_warning("[user.declent_ru(NOMINATIVE)] атакует щупальцами местность вокруг себя!"))

/// Summon a line of tentacles towards the target
/obj/effect/proc_holder/spell/basic_tentacle_grasp
	name = "Tentacle Burst"
	desc = "Unleash burrowed tentacles in an area around you, grappling targets after a delay."
	action_icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	action_icon_state = "goliath_tentacle_wiggle"
	action_background_icon_state = "bg_demon"
	need_active_overlay = TRUE
	base_cooldown = 24 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	invocation_type = "none"

/obj/effect/proc_holder/spell/basic_tentacle_grasp/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom

/obj/effect/proc_holder/spell/basic_tentacle_grasp/cast(list/targets, mob/user = usr)
	. = ..()
	var/target = targets[1]
	new /obj/effect/temp_visual/effect_trail/burrowed_tentacle(user.loc, target)
	if(isliving(target))
		var/mob/living/livivng_target = target
		user.visible_message(span_warning("[user.declent_ru(NOMINATIVE)] пытается дотянуться до [livivng_target.declent_ru(ACCUSATIVE)] своими щупальцами!"))
	return TRUE

/// An invisible effect which chases a target, spawning tentacles every so often.
/obj/effect/temp_visual/effect_trail/burrowed_tentacle
	name = "burrowed_tentacle"
	duration = 2 SECONDS
	move_speed = 2
	homing = FALSE
	spawn_interval = 0.1 SECONDS
	spawned_effect = /obj/effect/goliath_tentacle
