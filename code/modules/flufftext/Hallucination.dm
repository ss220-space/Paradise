/**
 * Spawns an hallucination for the mob.
 *
 * Arguments:
 * * hal_type - The name of the hallucination. "xeno", etc.
 * * specific - used to specify a particular hallucination
 */
/mob/living/proc/hallucinate_living(hal_type, specific)
	investigate_log("was afflicted with a hallucination of type [hal_type] by [last_hallucinator_log ? last_hallucinator_log : "Unknown source"].", INVESTIGATE_HALLUCINATIONS)
	switch(hal_type)
		if("message")
			cause_hallucination(/datum/hallucination/message, "hallucinate_living wrapper")
			return
		if("sounds")
			cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/fake_sound/normal), "hallucinate_living wrapper")
			return
		if("screwy_hud")
			cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/screwy_hud), "hallucinate_living wrapper")
			return
		if("fake_alert")
			cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/fake_alert), "hallucinate_living wrapper")
			return
		if("death")
			cause_hallucination(/datum/hallucination/death, "hallucinate_living wrapper")
			return
		if("delusion")
			cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/delusion/preset), "hallucinate_living wrapper")
			return
		if("chat")
			cause_hallucination(/datum/hallucination/chat, "hallucinate_living wrapper")
			return
		if("battle")
			cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/battle), "hallucinate_living wrapper")
			return
		if("your_mother")
			cause_hallucination(/datum/hallucination/your_mother, "hallucinate_living wrapper")
			return
		if("station_message")
			cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/station_message), "hallucinate_living wrapper")
			return
		if("stray_bullet")
			cause_hallucination(/datum/hallucination/stray_bullet, "hallucinate_living wrapper")
			return
		if("body")
			cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/body), "hallucinate_living wrapper")
			return
		if("ice")
			cause_hallucination(/datum/hallucination/ice, "hallucinate_living wrapper")
			return
		if("fire")
			cause_hallucination(/datum/hallucination/fire, "hallucinate_living wrapper")
			return
		if("shock")
			cause_hallucination(/datum/hallucination/shock, "hallucinate_living wrapper")
			return
		if("hazard")
			cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/hazard), "hallucinate_living wrapper")
			return
		if("telepathy")
			cause_hallucination(/datum/hallucination/telepathy, "hallucinate_living wrapper")
			return
		if("fake_item")
			cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/fake_item), "hallucinate_living wrapper")
			return
		if("items_other")
			cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/nearby_fake_item), "hallucinate_living wrapper")
			return
		if("xeno")
			cause_hallucination(/datum/hallucination/xeno_attack, "hallucinate_living wrapper")
			return
		if("flood")
			cause_hallucination(/datum/hallucination/fake_flood, "hallucinate_living wrapper")
			return
		if("bolts")
			cause_hallucination(/datum/hallucination/bolted_airlocks, "hallucinate_living wrapper")
			return
		if("koolaid")
			cause_hallucination(/datum/hallucination/oh_yeah, "hallucinate_living wrapper")
			return
		if("borer")
			cause_hallucination(/datum/hallucination/borer, "hallucinate_living wrapper")
			return
		if("singulo") // Нужно доработать
			cause_hallucination(/datum/hallucination/singularity_scare, "hallucinate_living wrapper")
			return
