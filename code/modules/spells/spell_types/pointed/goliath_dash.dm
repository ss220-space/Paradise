/datum/action/cooldown/spell/pointed/goliath_dash
	name = "Goliath Dash"
	desc = "Make a dash followed by an attack with the tentacles of goliath"
	school = SCHOOL_LAVALAND
	cooldown_time = 20 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	invocation = "RAGET'RE BRAN!"
	invocation_type = INVOCATION_SHOUT
	button_icon_state = "goliath_dash"
	var/active = FALSE

/datum/action/cooldown/spell/pointed/goliath_dash/cast(atom/cast_on)
	. = ..()
	if(active)
		return
	active = TRUE
	owner.stop_pulling()
	owner.unbuckle_all_mobs(TRUE)
	owner.buckled?.unbuckle_mob(owner, TRUE)
	owner.pulledby?.stop_pulling()

	owner.layer = LOW_LANDMARK_LAYER

	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, MAGIC_TRAIT)

	for(var/i in 1 to 7)
		if(QDELETED(owner))
			return

		var/direction = get_dir(owner, cast_on)
		var/turf/next_step = get_step(owner, direction)
		owner.face_atom(cast_on)

		if(!is_path_exist(owner, next_step, PASSTABLE|PASSFENCE))
			break

		owner.forceMove(next_step)
		playsound(owner.loc, SFX_HEAVYFOOTSTEP, 100, TRUE)
		sleep(0.05 SECONDS)

	if(QDELETED(owner))
		return

	owner.layer = initial(owner.layer)
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, MAGIC_TRAIT)
	owner.visible_message(span_warning("[owner] unleashes tentacles from the ground around it!"))

	for(var/d in GLOB.alldirs)
		var/turf/E = get_step(owner, d)
		new /obj/effect/temp_visual/goliath_tentacle(E, owner)
	active = FALSE
