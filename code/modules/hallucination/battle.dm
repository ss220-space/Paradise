/// Battle hallucination — makes it sound like there is a shootout or battle going on nearby.
/datum/hallucination/battle
	abstract_hallucination_parent = /datum/hallucination/battle
	random_hallucination_weight = 3
	hallucination_tier = HALLUCINATION_TIER_COMMON
	var/turf/source_turf

/datum/hallucination/battle/start()
	if(HAS_TRAIT(hallucinator, TRAIT_DEAF))
		return FALSE
	return TRUE

/datum/hallucination/battle/proc/pick_source_turf()
	var/list/valid = list()
	for(var/turf/simulated/floor/floor_in_view in view(hallucinator, 4))
		if(floor_in_view.density || isspaceturf(floor_in_view))
			continue
		valid += floor_in_view

	if(!length(valid))
		return FALSE
	source_turf = pick(valid)
	return TRUE

/// Subtype of battle hallucination for gun based battles, where it sounds like someone is being shot.
/datum/hallucination/battle/gun
	abstract_hallucination_parent = /datum/hallucination/battle/gun
	/// How many shots will we fire at least?
	var/shots_to_fire_lower_range = 3
	/// How many shots maximum.
	var/shots_to_fire_upper_range = 9
	/// Sound of a shot.
	var/fire_sound = 'sound/weapons/gunshots/1stechkin.ogg'
	/// Sound of hitting a person.
	var/hit_person_sound = SFX_BULLET
	/// Sound of hitting a wall.
	var/hit_wall_sound = SFX_RICOCHET
	/// How many hits are needed to "hit" the target.
	var/number_of_hits_to_end = 2
	/// Chance to "kill" a target after accumulating number_of_hits_to_end hits.
	var/chance_to_fall = 80

/datum/hallucination/battle/gun/start()
	. = ..()
	if(!.)
		return
	fire_loop(rand(shots_to_fire_lower_range, shots_to_fire_upper_range))
	return TRUE

/// The main loop for gun based hallucinations.
/datum/hallucination/battle/gun/proc/fire_loop(shots_left = 3, hits = 0)
	if(QDELETED(src) || QDELETED(hallucinator))
		return

	if(shots_left <= 0)
		qdel(src)
		return

	hallucinator.playsound_local(source_turf, fire_sound, 15, TRUE)

	var/next_hit_sound = rand(0.5 SECONDS, 1 SECONDS)
	if(prob(50))
		addtimer(CALLBACK(hallucinator, TYPE_PROC_REF(/mob, playsound_local), source_turf, hit_person_sound, 15, TRUE), next_hit_sound)
		hits++
	else
		addtimer(CALLBACK(hallucinator, TYPE_PROC_REF(/mob, playsound_local), source_turf, hit_wall_sound, 15, TRUE), next_hit_sound)

	if(hits >= number_of_hits_to_end && prob(chance_to_fall))
		addtimer(CALLBACK(hallucinator, TYPE_PROC_REF(/mob, playsound_local), source_turf, SFX_BODYFALL, 15, TRUE), next_hit_sound)
		qdel(src)
		return

	addtimer(CALLBACK(src, PROC_REF(fire_loop), shots_left - 1, hits), rand(CLICK_CD_RANGE, CLICK_CD_RANGE + 6))

/// Gun battle hallucination that sounds like disabler fire.
/datum/hallucination/battle/gun/disabler
	shots_to_fire_lower_range = 5
	shots_to_fire_upper_range = 10
	fire_sound = 'sound/weapons/plasma_cutter.ogg'
	hit_person_sound = 'sound/weapons/sear.ogg'
	hit_wall_sound = 'sound/weapons/sear.ogg'
	number_of_hits_to_end = 3
	chance_to_fall = 70

/// Gun battle hallucination that sounds like laser fire.
/datum/hallucination/battle/gun/laser
	shots_to_fire_lower_range = 5
	shots_to_fire_upper_range = 10
	fire_sound = 'sound/weapons/gunshots/1laser10.ogg'
	hit_person_sound = 'sound/weapons/sear.ogg'
	hit_wall_sound = 'sound/weapons/sear.ogg'
	number_of_hits_to_end = 4
	chance_to_fall = 70

/// Plays a fake cable-cuff sound and deletes the hallucination.
/datum/hallucination/battle/proc/fake_cuff()
	if(QDELETED(src) || QDELETED(hallucinator))
		return

	hallucinator.playsound_local(source_turf, 'sound/weapons/cablecuff.ogg', 15, TRUE)
	qdel(src)

/// A hallucination of someone being hit with a stun prod, followed by cable cuffing.
/datum/hallucination/battle/stun_prod

/datum/hallucination/battle/stun_prod/start()
	. = ..()
	if(!.)
		return

	hallucinator.playsound_local(source_turf, 'sound/weapons/egloves.ogg', 20, TRUE)
	hallucinator.playsound_local(source_turf, get_sfx(SFX_BODYFALL), 20, TRUE)
	addtimer(CALLBACK(src, PROC_REF(fake_cuff)), 2 SECONDS)
	return TRUE

/// A hallucination of someone being stun batonned, and subsequently harmbatonned.
/datum/hallucination/battle/contractor_baton

/datum/hallucination/battle/contractor_baton/start()
	. = ..()
	if(!.)
		return

	hallucinator.playsound_local(source_turf, 'sound/weapons/contractorbatonhit.ogg', 20, TRUE)
	hallucinator.playsound_local(source_turf, get_sfx(SFX_BODYFALL), 20, TRUE)
	addtimer(CALLBACK(src, PROC_REF(fake_cuff)), 2 SECONDS)
	return TRUE

/// A hallucination of someone being stun batonned, and subsequently harmbatonned.
/datum/hallucination/battle/harm_baton

/datum/hallucination/battle/harm_baton/start()
	. = ..()
	if(!.)
		return

	hallucinator.playsound_local(source_turf, 'sound/weapons/egloves.ogg', 20, TRUE)
	hallucinator.playsound_local(source_turf, SFX_SWING_HIT, 25, TRUE)
	hallucinator.playsound_local(source_turf, get_sfx(SFX_BODYFALL), 20, TRUE)
	addtimer(CALLBACK(src, PROC_REF(harmbaton_loop), 0, rand(5, 8)), 2 SECONDS)
	return TRUE

/// The main sound loop for harmbatonning.
/datum/hallucination/battle/harm_baton/proc/harmbaton_loop(hits_done = 0, hits_total = 5)
	if(QDELETED(src) || QDELETED(hallucinator))
		return

	if(hits_done >= hits_total)
		qdel(src)
		return

	hallucinator.playsound_local(source_turf, 'sound/weapons/egloves.ogg', 20, TRUE)
	hallucinator.playsound_local(source_turf, get_sfx(SFX_SWING_HIT), 25, TRUE)
	if(prob(10))
		hallucinator.playsound_local(source_turf, SFX_BONEBREAK, 20, TRUE)


	addtimer(CALLBACK(src, PROC_REF(harmbaton_loop), hits_done + 1, hits_total), rand(CLICK_CD_MELEE, CLICK_CD_MELEE + 4))

/// A hallucination of someone unsheathing an energy sword, going to town, and sheathing it again.
/datum/hallucination/battle/e_sword

/datum/hallucination/battle/e_sword/start()
	. = ..()
	if(!.)
		return

	hallucinator.playsound_local(source_turf, 'sound/weapons/saberon.ogg', 15, TRUE)
	addtimer(CALLBACK(src, PROC_REF(stab_loop), 0, rand(4, 8)), CLICK_CD_MELEE)
	return TRUE

/// The main sound loop of someone being esworded.
/datum/hallucination/battle/e_sword/proc/stab_loop(hits_done = 0, stabs_total = 4)
	if(QDELETED(src) || QDELETED(hallucinator))
		return

	if(hits_done >= stabs_total)
		hallucinator.playsound_local(source_turf, 'sound/weapons/saberoff.ogg', 15, TRUE)
		qdel(src)
		return

	hallucinator.playsound_local(source_turf, 'sound/weapons/blade1.ogg', 25, TRUE)
	if(prob(10))
		hallucinator.playsound_local(source_turf, SFX_BONEBREAK, 20, TRUE)

	if(hits_done == 2)
		hallucinator.playsound_local(source_turf, get_sfx(SFX_BODYFALL), 25, TRUE)

	addtimer(CALLBACK(src, PROC_REF(stab_loop), hits_done + 1, stabs_total), rand(CLICK_CD_MELEE, CLICK_CD_MELEE + 6))

/// A hallucination of a chainsaw revving nearby.
/datum/hallucination/battle/chainsaw

/datum/hallucination/battle/chainsaw/start()
	. = ..()
	if(!.)
		return

	hallucinator.playsound_local(source_turf, 'sound/weapons/chainsaw_start.ogg', 15, TRUE)
	addtimer(CALLBACK(src, PROC_REF(stab_loop), 0, rand(4, 8)), CLICK_CD_MELEE)
	return TRUE

/// The main sound loop of someone being chainsawed.
/datum/hallucination/battle/chainsaw/proc/stab_loop(hits_done = 0, stabs_total = 5)
	if(QDELETED(src) || QDELETED(hallucinator))
		return

	if(hits_done >= stabs_total)
		hallucinator.playsound_local(source_turf, 'sound/weapons/chainsaw_stop.ogg', 15, TRUE)
		qdel(src)
		return

	hallucinator.playsound_local(source_turf, 'sound/weapons/chainsaw.ogg', 25, TRUE)
	if(prob(10))
		hallucinator.playsound_local(source_turf, 'sound/effects/splat.ogg', 20, TRUE)

	if(hits_done == 0)
		hallucinator.playsound_local(source_turf, get_sfx(SFX_BODYFALL), 25, TRUE)

	addtimer(CALLBACK(src, PROC_REF(stab_loop), hits_done + 1, stabs_total), CLICK_CD_MELEE)

/// A hallucination of a syndicate bomb ticking down.
/datum/hallucination/battle/bomb

/datum/hallucination/battle/bomb/start()
	. = ..()
	if(!.)
		return

	addtimer(CALLBACK(src, PROC_REF(fake_tick), rand(3, 11)), 1.5 SECONDS)
	return TRUE

/// The loop of the (fake) bomb ticking down.
/datum/hallucination/battle/bomb/proc/fake_tick(ticks_remaining = 3)
	if(QDELETED(src) || QDELETED(hallucinator))
		return

	if(ticks_remaining <= 0)
		qdel(src)
		return

	hallucinator.playsound_local(source_turf, 'sound/items/timer.ogg', 15, FALSE)

	addtimer(CALLBACK(src, PROC_REF(fake_tick), ticks_remaining - 1), 1.5 SECONDS)

/// A hallucination of a arm blade revving nearby.
/datum/hallucination/battle/arm_blade

/datum/hallucination/battle/arm_blade/start()
	. = ..()
	if(!.)
		return

	hallucinator.playsound_local(source_turf, SFX_BONEBREAK, 15, TRUE)
	addtimer(CALLBACK(src, PROC_REF(stab_loop), 0, rand(4, 8)), CLICK_CD_MELEE)
	return TRUE

/// The main sound loop of someone being mauled by an arm blade.
/datum/hallucination/battle/arm_blade/proc/stab_loop(hits_done = 0, stabs_total = 6)
	if(QDELETED(src) || QDELETED(hallucinator))
		return

	if(hits_done >= stabs_total)
		qdel(src)
		return

	hallucinator.playsound_local(source_turf, 'sound/weapons/armblade.ogg', 25, TRUE)

	if(hits_done == 1)
		hallucinator.playsound_local(source_turf, get_sfx(SFX_BODYFALL), 25, TRUE)

	if(prob(10))
		hallucinator.playsound_local(source_turf, 'sound/effects/splat.ogg', 20, TRUE)
	if(prob(10))
		hallucinator.playsound_local(source_turf, SFX_BONEBREAK, 20, TRUE)

	addtimer(CALLBACK(src, PROC_REF(stab_loop), hits_done + 1), CLICK_CD_MELEE)
