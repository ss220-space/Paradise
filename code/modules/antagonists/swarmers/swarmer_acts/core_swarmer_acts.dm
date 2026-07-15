// === All swarmer acts, that are directly related to swarmer related mechanics ===

/obj/structure/swarmer/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	switch(user.a_intent)
		if(INTENT_HELP)
			swarmer_help_act(user)
		if(INTENT_DISARM)
			swarmer_disarm_act(user)
		if(INTENT_GRAB)
			swarmer_grab_act(user)
		if(INTENT_HARM)
			swarmer_harm_act(user)

	return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_OVERRIDE

/obj/machinery/porta_turret/swarmer/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	switch(user.a_intent)
		if(INTENT_HELP)
			swarmer_help_act(user)
		if(INTENT_DISARM)
			swarmer_disarm_act(user)
		if(INTENT_GRAB)
			swarmer_grab_act(user)
		if(INTENT_HARM)
			swarmer_harm_act(user)

	return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_OVERRIDE


// MARK: Organic processer related stuff

/obj/item/reagent_containers/food/snacks/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	user.send_organic_processer_signal(src, SWARMER_SEND_ORGANIC_DELAY)
	return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_OVERRIDE

/obj/item/grown/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	user.send_organic_processer_signal(src, SWARMER_SEND_ORGANIC_DELAY)
	return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_OVERRIDE

/obj/item/seeds/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	user.send_organic_processer_signal(src, SWARMER_SEND_ORGANIC_DELAY)
	return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_OVERRIDE

/obj/machinery/hydroponics/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	if(!myseed) // If there is no plant, then there is nothing to process
		return SWARMER_ACT_POSSIBLE | SWARMER_ACT_POSSIBLE_ACTION_DISMANTLE

	user.balloon_alert(user, "отправка растения...")
	if(!do_after(user, SWARMER_SEND_ORGANIC_DELAY, src, max_interact_count = 1))
		balloon_alert(user, "сбито!")
		return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_OVERRIDE

	// Clean the hydroponic lot, nusanya TODO: make a proc for this
	age = 0
	plant_health = 0
	if(harvest)
		harvest = FALSE //To make sure they can't just put in another seed and insta-harvest it
	qdel(myseed)
	myseed = null
	plant_hud_set_health()
	plant_hud_set_status()
	update_state()

	user.send_organic_processer_signal() // Arguments being null is intentional, we aren't sending anything and not delaying
	return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_OVERRIDE

/obj/item/reagent_containers/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	if(!reagents?.total_volume) // Checks if there is any reagent in the container
		return SWARMER_ACT_POSSIBLE | SWARMER_ACT_POSSIBLE_ACTION_CONSUME
	user.send_organic_processer_signal(src, SWARMER_SEND_ORGANIC_DELAY)
	return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_OVERRIDE
