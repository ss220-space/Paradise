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
		if("message") // Работает
			cause_hallucination(/datum/hallucination/message, "hallucinate_living wrapper")
			return
		if("sounds") // Работает
			cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/fake_sound/normal), "hallucinate_living wrapper")
			return
		if("screwy_hud") // Работает
			cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/screwy_hud), "hallucinate_living wrapper")
			return
		if("fake_alert") // Работает
			cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/fake_alert), "hallucinate_living wrapper")
			return
		if("death") // Работает
			cause_hallucination(/datum/hallucination/death, "hallucinate_living wrapper")
			return
		if("delusion") // Работает
			cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/delusion/preset), "hallucinate_living wrapper")
			return
		if("chat") // Работает
			cause_hallucination(/datum/hallucination/chat, "hallucinate_living wrapper")
			return
		if("battle") // Работает
			cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/battle), "hallucinate_living wrapper")
			return
		if("your_mother") // Работает
			cause_hallucination(/datum/hallucination/your_mother, "hallucinate_living wrapper")
			return
		if("station_message") // Работает
			cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/station_message), "hallucinate_living wrapper")
			return
		if("stray_bullet") // Работает
			cause_hallucination(/datum/hallucination/stray_bullet, "hallucinate_living wrapper")
			return
		if("body") // Работает
			cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/body), "hallucinate_living wrapper")
			return
		if("ice") // Работает
			cause_hallucination(/datum/hallucination/ice, "hallucinate_living wrapper")
			return
		if("fire") // Работает
			cause_hallucination(/datum/hallucination/fire, "hallucinate_living wrapper")
			return
		if("shock") // Работает
			cause_hallucination(/datum/hallucination/shock, "hallucinate_living wrapper")
			return
		if("hazard") // Работает
			cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/hazard), "hallucinate_living wrapper")
			return
		if("telepathy") // Работает
			cause_hallucination(/datum/hallucination/telepathy, "hallucinate_living wrapper")
			return
		if("fake_item") // Работает
			cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/fake_item), "hallucinate_living wrapper")
			return
		if("items_other") // Работает
			cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/nearby_fake_item), "hallucinate_living wrapper")
			return
		if("xeno") // Работает
			cause_hallucination(/datum/hallucination/xeno_attack, "hallucinate_living wrapper")
			return
		if("flood") // Работает
			cause_hallucination(/datum/hallucination/fake_flood, "hallucinate_living wrapper")
			return
		if("bolts") // Работает
			cause_hallucination(/datum/hallucination/bolted_airlocks, "hallucinate_living wrapper")
			return
		if("koolaid") // Работает
			cause_hallucination(/datum/hallucination/oh_yeah, "hallucinate_living wrapper")
			return
		if("borer") // Нужно доработать
			cause_hallucination(/datum/hallucination/borer, "hallucinate_living wrapper")
			return
		if("singulo") // Нужно доработать
			cause_hallucination(/datum/hallucination/singularity_scare, "hallucinate_living wrapper")
			return
