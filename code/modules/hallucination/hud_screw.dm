/datum/hallucination/screwy_hud
	abstract_hallucination_parent = /datum/hallucination/screwy_hud
	random_hallucination_weight = 4
	hallucination_tier = HALLUCINATION_TIER_COMMON

	var/screwy_hud_type = SCREWYHUD_NONE

/datum/hallucination/screwy_hud/start()
	hallucinator.hal_screwyhud = screwy_hud_type
	QDEL_IN(src, rand(10 SECONDS, 25 SECONDS))
	return TRUE

/datum/hallucination/screwy_hud/Destroy()
	if(!QDELETED(hallucinator))
		hallucinator.hal_screwyhud = SCREWYHUD_NONE
	return ..()

/datum/hallucination/screwy_hud/crit
	screwy_hud_type = SCREWYHUD_CRIT

/datum/hallucination/screwy_hud/dead
	screwy_hud_type = SCREWYHUD_DEAD

/datum/hallucination/screwy_hud/healthy
	screwy_hud_type = SCREWYHUD_HEALTHY
