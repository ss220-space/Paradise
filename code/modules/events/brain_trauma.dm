/datum/event/brain_trauma/start()
	for(var/mob/living/carbon/human/victim in shuffle(GLOB.alive_mob_list))
		if(!victim.client || victim.stat == DEAD)
			continue
		if(is_monkeybasic(victim))
			continue
		if(!victim.get_int_organ(/obj/item/organ/internal/brain))
			continue
		var/turf/victim_turf = get_turf(victim)
		if(!is_station_level(victim_turf?.z))
			continue
		traumatize(victim)
		notify_ghosts(
			"[victim] получил[GEND_A_O_I(victim)] спонтанную травму мозга.",
			source = victim,
			action = NOTIFY_FOLLOW,
			title = EVENT_BRAIN_TRAUMA,
		)
		break

/datum/event/brain_trauma/proc/traumatize(mob/living/carbon/human/victim)
	var/resilience = pick(
		50;TRAUMA_RESILIENCE_BASIC,
		30;TRAUMA_RESILIENCE_SURGERY,
		15;TRAUMA_RESILIENCE_LOBOTOMY,
		5;TRAUMA_RESILIENCE_MAGIC,
	)
	var/trauma_type = pick(
		60;BRAIN_TRAUMA_MILD,
		30;BRAIN_TRAUMA_SEVERE,
		10;BRAIN_TRAUMA_SPECIAL,
	)
	victim.gain_trauma_type(trauma_type, resilience)
