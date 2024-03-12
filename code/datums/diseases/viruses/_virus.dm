/datum/disease/virus
	form = "Вирус"
	carrier_mobtypes = list(/mob/living/simple_animal/mouse)
	spread_from_dead_prob = 25

	///method of infection of the virus
	var/spread_flags = NON_CONTAGIOUS
	///affects how often the virus will try to spread. The more the better. In range [0-100]
	var/infectivity = 65
	///affects how well the virus will pass through the protection. The more the better. In range (0-2]
	var/permeability_mod = 1

/datum/disease/virus/New()
	..()
	additional_info = spread_text()

/**
 * Main virus process, that executed every tick
 *
 * Returns:
 * * TRUE - if process finished the work properlly
 * * FALSE - if don't need to call a child proc
 */
/datum/disease/virus/stage_act()
	if(!affected_mob)
		return FALSE

	if(can_spread())
		spread()

	. = ..()

	if(!. || carrier)
		return FALSE

	for(var/mobtype in carrier_mobtypes)
		if(istype(affected_mob, mobtype))
			return FALSE

	return TRUE

/datum/disease/virus/try_increase_stage()
	if(prob(affected_mob.reagents?.has_reagent("spaceacillin") ? stage_prob/2 : stage_prob))
		stage = min(stage + 1,max_stages)
		if(!discovered && stage >= CEILING(max_stages * discovery_threshold, 1)) // Once we reach a late enough stage, medical HUDs can pick us up even if we regress
			discovered = TRUE
			affected_mob.med_hud_set_status()


/datum/disease/virus/proc/can_spread()
	if(istype(affected_mob.loc, /obj/structure/closet/body_bag/biohazard))
		return FALSE
	if(prob(infectivity) && (affected_mob.stat != DEAD || prob(spread_from_dead_prob)))
		return TRUE
	return FALSE


/datum/disease/virus/proc/spread(force_spread = 0)
	if(!affected_mob)
		return

	if((spread_flags <= BLOOD) && !force_spread)
		return

	if(affected_mob.reagents?.has_reagent("spaceacillin") || (affected_mob.satiety > 0 && prob(affected_mob.satiety/10)))
		return

	var/spread_range = force_spread ? force_spread : 1

	if(spread_flags & AIRBORNE)
		spread_range++

	var/turf/T = get_turf(affected_mob)
	if(istype(T))
		for(var/mob/living/C in view(spread_range, T))
			var/turf/V = get_turf(C)
			if(V)
				while(TRUE)
					if(V == T)
						var/a_type = (spread_range == 1) ? CONTACT : CONTACT|AIRBORNE
						//if we wear bio suit, for example, we won't be able to contract anyone
						if(affected_mob.CheckVirusProtection(src, a_type))
							return
						Contract(C, act_type = a_type, need_protection_check = TRUE)
						break
					var/turf/Temp = get_step_towards(V, T)
					if(!V.CanAtmosPass(Temp))
						break
					V = Temp

/datum/disease/virus/proc/spread_text()
	var/list/spread = list()
	if(!spread_flags)
		spread += "Не заразный"
	if(spread_flags & BITES)
		spread += "Распространяемый через укусы"
	if(spread_flags & BLOOD)
		spread += "Распространяемый через кровь"
	if(spread_flags & CONTACT)
		spread += "Контактный"
	if(spread_flags & AIRBORNE)
		spread += "Воздушно-капельный"
	return english_list(spread, "Неизвестен", " и ")
