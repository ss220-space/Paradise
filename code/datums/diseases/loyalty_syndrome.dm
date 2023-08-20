/datum/disease/loyalty
	name = "Loyalty Syndrome"
	max_stages = 5
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	//TODO cure
	cure_text = "Ethanol"
	cures = list("ethanol")
	agent = "Halomonas minomae"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = ""
	severity = MEDIUM
	var/is_master = FALSE
	var/mob/living/carbon/human/master

/datum/disease/loyalty/New(var/mob/living/carbon/human/new_master)
	if(new_master)
		master = new_master
	else
		is_master = TRUE

/datum/disease/loyalty/spread()
	if(!affected_mob)
		return

	if(affected_mob.reagents.has_reagent("spaceacillin") || (affected_mob.satiety > 0 && prob(affected_mob.satiety/10)))
		return

	var/turf/T = affected_mob.loc
	if(istype(T))
		for(var/mob/living/carbon/C in oview(1, affected_mob))
			var/turf/V = get_turf(C)
			if(V)
				while(TRUE)
					if(V == T)
						var/mob/living/carbon/human/new_master = is_master ? affected_mob : master
						var/datum/disease/loyalty/copy = new(new_master)
						C.ContractDisease(copy, create_copy = FALSE)
						break
					var/turf/Temp = get_step_towards(V, T)
					if(!V.CanAtmosPass(Temp))
						break
					V = Temp

/datum/disease/loyalty/stage_act()
	if(affected_mob)
		if(is_master)
			affected_mob.say("Слава мне!")
		else
			affected_mob.say("Славься [master]!")
	return
