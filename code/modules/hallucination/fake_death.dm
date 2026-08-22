/datum/hallucination/death
	random_hallucination_weight = 1
	hallucination_tier = HALLUCINATION_TIER_UNCOMMON
	var/floor_them = TRUE

/datum/hallucination/death/Destroy()
	if(!QDELETED(hallucinator))
		hallucinator.hal_screwyhud = SCREWYHUD_NONE
		if(floor_them)
			hallucinator.SetSleeping(0)
		else
			hallucinator.SetImmobilized(0)
	return ..()

/datum/hallucination/death/start()
	if(hallucinator.incapacitated())
		return FALSE

	if(floor_them)
		hallucinator.SetSleeping(30 SECONDS)
	else
		hallucinator.SetImmobilized(30 SECONDS)

	hallucinator.hal_screwyhud = SCREWYHUD_DEAD

	to_chat(hallucinator, span_deadsay("<b>[hallucinator.real_name]</b> умер в <b>[get_area_name(hallucinator)]</b>."))

	addtimer(CALLBACK(src, PROC_REF(wake_up)), rand(7 SECONDS, 9 SECONDS))
	return TRUE

/datum/hallucination/death/proc/wake_up()
	if(!QDELETED(hallucinator))
		hallucinator.hal_screwyhud = SCREWYHUD_NONE
		if(floor_them)
			hallucinator.SetSleeping(0)
		else
			hallucinator.SetImmobilized(0)

	if(!QDELETED(src))
		qdel(src)
