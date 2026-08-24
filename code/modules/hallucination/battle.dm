/// Battle hallucination — makes it sound like there is a shootout or battle going on nearby.
/datum/hallucination/battle
	abstract_hallucination_parent = /datum/hallucination/battle
	random_hallucination_weight = 3
	hallucination_tier = HALLUCINATION_TIER_COMMON

/datum/hallucination/battle/start()
	if(HAS_TRAIT(hallucinator, TRAIT_DEAF))
		return FALSE
	return TRUE

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
	fire_loop(random_far_turf(), rand(shots_to_fire_lower_range, shots_to_fire_upper_range))

/datum/hallucination/battle/gun/proc/fire_loop(turf/source, shots_left = 3, hits = 0)
	if(QDELETED(src) || QDELETED(hallucinator) || !source)
		return

	hallucinator.playsound_local(source, fire_sound, 25, TRUE)

	var/next_hit_sound = rand(0.5 SECONDS, 1 SECONDS)
	if(prob(50))
		addtimer(CALLBACK(hallucinator, TYPE_PROC_REF(/mob, playsound_local), source, hit_person_sound, 25, TRUE), next_hit_sound)
		hits++
	else
		addtimer(CALLBACK(hallucinator, TYPE_PROC_REF(/mob, playsound_local), source, hit_wall_sound, 25, TRUE), next_hit_sound)

	if(hits >= number_of_hits_to_end && prob(chance_to_fall))
		addtimer(CALLBACK(hallucinator, TYPE_PROC_REF(/mob, playsound_local), source, SFX_BODYFALL, 25, TRUE), next_hit_sound)
		qdel(src)
	else if(shots_left >= 0)
		shots_left--
		addtimer(CALLBACK(src, PROC_REF(fire_loop), source, shots_left, hits), rand(CLICK_CD_RANGE, CLICK_CD_RANGE + 6))
	else
		qdel(src)

/datum/hallucination/battle/gun/disabler
	shots_to_fire_lower_range = 5
	shots_to_fire_upper_range = 10
	fire_sound = 'sound/weapons/plasma_cutter.ogg'
	hit_person_sound = 'sound/weapons/sear.ogg'
	hit_wall_sound = 'sound/weapons/sear.ogg'
	number_of_hits_to_end = 3
	chance_to_fall = 70

/datum/hallucination/battle/gun/laser
	shots_to_fire_lower_range = 5
	shots_to_fire_upper_range = 10
	fire_sound = 'sound/weapons/gunshots/1laser10.ogg'
	hit_person_sound = 'sound/weapons/sear.ogg'
	hit_wall_sound = 'sound/weapons/sear.ogg'
	number_of_hits_to_end = 4
	chance_to_fall = 70

/datum/hallucination/battle/proc/fake_cuff(turf/source)
	if(QDELETED(src) || QDELETED(hallucinator) || !source)
		return
	hallucinator.playsound_local(source, 'sound/weapons/cablecuff.ogg', 15, TRUE)
	qdel(src)

/datum/hallucination/battle/stun_prod

/datum/hallucination/battle/stun_prod/start()
	. = ..()
	if(!.)
		return
	var/turf/source = random_far_turf()
	hallucinator.playsound_local(source, 'sound/weapons/egloves.ogg', 25, TRUE)
	hallucinator.playsound_local(source, get_sfx(SFX_BODYFALL), 25, TRUE)
	addtimer(CALLBACK(src, PROC_REF(fake_cuff), source), 2 SECONDS)

/datum/hallucination/battle/contractor_baton

/datum/hallucination/battle/contractor_baton/start()
	. = ..()
	if(!.)
		return
	var/turf/source = random_far_turf()
	hallucinator.playsound_local(source, 'sound/weapons/contractorbatonhit.ogg', 25, TRUE)
	hallucinator.playsound_local(source, get_sfx(SFX_BODYFALL), 25, TRUE)
	addtimer(CALLBACK(src, PROC_REF(fake_cuff), source), 2 SECONDS)

/datum/hallucination/battle/harm_baton

/datum/hallucination/battle/harm_baton/start()
	. = ..()
	if(!.)
		return
	var/turf/source = random_far_turf()
	hallucinator.playsound_local(source, 'sound/weapons/egloves.ogg', 25, TRUE)
	hallucinator.playsound_local(source, SFX_SWING_HIT, 25, TRUE)
	hallucinator.playsound_local(source, get_sfx(SFX_BODYFALL), 25, TRUE)
	addtimer(CALLBACK(src, PROC_REF(harmbaton_loop), source, rand(5, 12)), 2 SECONDS)

/datum/hallucination/battle/harm_baton/proc/harmbaton_loop(turf/source, hits_remaining = 5)
	if(QDELETED(src) || QDELETED(hallucinator) || !source)
		return
	hallucinator.playsound_local(source, get_sfx(SFX_SWING_HIT), 30, TRUE)
	hits_remaining--
	if(hits_remaining <= 0)
		qdel(src)
	else
		addtimer(CALLBACK(src, PROC_REF(harmbaton_loop), source, hits_remaining), rand(CLICK_CD_MELEE, CLICK_CD_MELEE + 4))

/datum/hallucination/battle/e_sword

/datum/hallucination/battle/e_sword/start()
	. = ..()
	if(!.)
		return
	var/turf/source = random_far_turf()
	hallucinator.playsound_local(source, 'sound/weapons/saberon.ogg', 15, TRUE)
	addtimer(CALLBACK(src, PROC_REF(stab_loop), source, rand(4, 8)), CLICK_CD_MELEE)

/datum/hallucination/battle/e_sword/proc/stab_loop(turf/source, stabs_remaining = 4)
	if(QDELETED(src) || QDELETED(hallucinator) || !source)
		return
	if(stabs_remaining >= 1)
		hallucinator.playsound_local(source, 'sound/weapons/blade1.ogg', 25, TRUE)
	else
		hallucinator.playsound_local(source, 'sound/weapons/saberoff.ogg', 15, TRUE)
		qdel(src)
		return
	if(stabs_remaining == 4)
		hallucinator.playsound_local(source, get_sfx(SFX_BODYFALL), 25, TRUE)
	addtimer(CALLBACK(src, PROC_REF(stab_loop), source, stabs_remaining - 1), rand(CLICK_CD_MELEE, CLICK_CD_MELEE + 6))

/datum/hallucination/battle/chainsaw

/datum/hallucination/battle/chainsaw/start()
	. = ..()
	if(!.)
		return
	var/turf/source = random_far_turf()
	hallucinator.playsound_local(source, 'sound/weapons/chainsaw_start.ogg', 15, TRUE)
	addtimer(CALLBACK(src, PROC_REF(stab_loop), source, rand(4, 8)), CLICK_CD_MELEE)

/datum/hallucination/battle/chainsaw/proc/stab_loop(turf/source, stabs_remaining = 4)
	if(QDELETED(src) || QDELETED(hallucinator) || !source)
		return
	if(stabs_remaining >= 1)
		hallucinator.playsound_local(source, 'sound/weapons/chainsaw.ogg', 25, TRUE)
	else
		hallucinator.playsound_local(source, 'sound/weapons/chainsaw_stop.ogg', 15, TRUE)
		qdel(src)
		return
	if(stabs_remaining == 4)
		hallucinator.playsound_local(source, get_sfx(SFX_BODYFALL), 25, TRUE)
	addtimer(CALLBACK(src, PROC_REF(stab_loop), source, stabs_remaining - 1), rand(CLICK_CD_MELEE, CLICK_CD_MELEE + 6))

/datum/hallucination/battle/bomb

/datum/hallucination/battle/bomb/start()
	. = ..()
	if(!.)
		return
	addtimer(CALLBACK(src, PROC_REF(fake_tick), random_far_turf(), rand(3, 11)), 1.5 SECONDS)

/datum/hallucination/battle/bomb/proc/fake_tick(turf/source, ticks_remaining = 3)
	if(QDELETED(src) || QDELETED(hallucinator) || !source)
		return
	hallucinator.playsound_local(source, 'sound/items/timer.ogg', 15, FALSE)
	ticks_remaining--
	if(ticks_remaining <= 0)
		qdel(src)
	else
		addtimer(CALLBACK(src, PROC_REF(fake_tick), source, ticks_remaining), 1.5 SECONDS)
