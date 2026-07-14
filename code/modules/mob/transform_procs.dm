/mob/living/carbon/human/proc/monkeyize()
	if(!is_monkeyized())
		force_gene_block(GLOB.monkeyblock, TRUE)

/mob/living/carbon/human/proc/is_monkeyized()
	return dna.GetSEState(GLOB.monkeyblock)

/mob/living/carbon/human/proc/humanize()
	if(is_monkeyized())
		force_gene_block(GLOB.monkeyblock, FALSE)

/mob/living/carbon/human/proc/is_humanized()
	return !dna.GetSEState(GLOB.monkeyblock)

/mob/new_player/AIize()
	spawning = 1
	return ..()

/mob/living/carbon/AIize()
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return
	for(var/obj/item/check as anything in get_equipped_items(INCLUDE_POCKETS | INCLUDE_HELD))
		drop_item_ground(check, force = TRUE)
	ADD_TRAIT(src, TRAIT_NO_TRANSFORM, PERMANENT_TRANSFORMATION_TRAIT)
	icon = null
	invisibility = INVISIBILITY_ABSTRACT
	return ..()

/mob/proc/AIize()
	if(client)
		// stop_sound_channel(CHANNEL_LOBBYMUSIC)
		client?.tgui_panel?.stop_music()

	var/mob/living/silicon/ai/ai = new (loc,,,1)//No MMI but safety is in effect.
	ai.invisibility = 0
	ai.aiRestorePowerRoutine = POWER_RESTORATION_OFF

	if(mind)
		mind.transfer_to(ai)
		ai.mind.set_original_mob(ai)
	else
		ai.possess_by_player(key)

	ai.on_mob_init()

	ai.add_ai_verbs()

	ai.rename_self(JOB_TITLE_AI,1)

	ai.tts_seed = tts_seed

	INVOKE_ASYNC(GLOBAL_PROC, /proc/qdel, src) // To prevent the proc from returning null.
	return ai

/**
	For transforming humans into robots (cyborgs).

	Arguments:
	* cell_type: A type path of the cell the new borg should receive.
	* connect_to_default_AI: TRUE if you want /robot/New() to handle connecting the borg to the AI with the least borgs.
	* AI: A reference to the AI we want to connect to.
*/
/mob/living/carbon/human/proc/Robotize(cell_type = null, connect_to_default_AI = TRUE, mob/living/silicon/ai/AI = null)
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return
	for(var/obj/item/check as anything in get_equipped_items(INCLUDE_POCKETS | INCLUDE_HELD))
		drop_item_ground(check, force = TRUE)

	ADD_TRAIT(src, TRAIT_NO_TRANSFORM, PERMANENT_TRANSFORMATION_TRAIT)
	icon = null
	invisibility = INVISIBILITY_ABSTRACT

	// Creating a new borg here will connect them to a default AI and notify that AI, if `connect_to_default_AI` is TRUE.
	var/mob/living/silicon/robot/robot = new /mob/living/silicon/robot(loc, FALSE, FALSE, FALSE, connect_to_default_AI)

	// If `AI` is passed in, we want to connect to that AI specifically.
	if(AI)
		robot.lawupdate = TRUE
		robot.connect_to_ai(AI)

	if(!cell_type)
		robot.cell = new /obj/item/stock_parts/cell/high(robot)
	else
		robot.cell = new cell_type(robot)

	robot.gender = gender
	robot.invisibility = 0

	if(mind)		//TODO
		mind.transfer_to(robot)
		if(robot.mind.assigned_role == JOB_TITLE_CYBORG)
			robot.mind.set_original_mob(robot)
		else if(mind?.special_role)
			robot.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")
	else
		robot.possess_by_player(key)

	robot.forceMove(loc)
	robot.job = JOB_TITLE_CYBORG

	if(robot.mind && robot.mind.assigned_role == JOB_TITLE_CYBORG)
		var/obj/item/mmi/new_mmi
		switch(robot.mind.role_alt_title)
			if(JOB_TITLE_CYBORG)
				new_mmi = new /obj/item/mmi/robotic_brain(robot)
				if(new_mmi.brainmob)
					new_mmi.brainmob.name = robot.name
			if(ALT_JOB_TITLE_RU_CYBORG)
				new_mmi = new /obj/item/mmi(robot)
			else
				// This should never happen, but oh well
				new_mmi = new /obj/item/mmi(robot)
		new_mmi.transfer_identity(src) //Does not transfer key/client.
		// Replace the MMI.
		QDEL_NULL(robot.mmi)
		robot.mmi = new_mmi

	robot.Namepick()

	robot.tts_seed = tts_seed

	INVOKE_ASYNC(GLOBAL_PROC, /proc/qdel, src) // To prevent the proc from returning null.
	return robot

/mob/living/carbon/human/proc/corgize()
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return
	for(var/obj/item/check as anything in get_equipped_items(INCLUDE_POCKETS | INCLUDE_HELD))
		drop_item_ground(check, force = TRUE)
	ADD_TRAIT(src, TRAIT_NO_TRANSFORM, PERMANENT_TRANSFORMATION_TRAIT)
	icon = null
	invisibility = INVISIBILITY_ABSTRACT
	for(var/t in bodyparts)	//this really should not be necessary
		qdel(t)

	var/mob/living/simple_animal/pet/dog/corgi/new_corgi = new /mob/living/simple_animal/pet/dog/corgi (loc)
	new_corgi.possess_by_player(key)

	to_chat(new_corgi, "<b>You are now a Corgi. Yap Yap!</b>")
	qdel(src)

/mob/living/carbon/human/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = tgui_input_list(usr, "Which type of mob should [src] turn into?", "Choose a type", mobtypes)

	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return
	for(var/obj/item/check as anything in get_equipped_items(INCLUDE_POCKETS | INCLUDE_HELD))
		drop_item_ground(check, force = TRUE)

	ADD_TRAIT(src, TRAIT_NO_TRANSFORM, PERMANENT_TRANSFORMATION_TRAIT)
	icon = null
	invisibility = INVISIBILITY_ABSTRACT

	for(var/t in bodyparts)
		qdel(t)

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.possess_by_player(key)
	new_mob.a_intent = INTENT_HARM

	to_chat(new_mob, "You suddenly feel more... animalistic.")
	qdel(src)

/mob/proc/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = tgui_input_list(usr, "Which type of mob should [src] turn into?", "Choose a type", mobtypes)

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.possess_by_player(key)
	new_mob.a_intent = INTENT_HARM
	to_chat(new_mob, "You feel more... animalistic")

	qdel(src)

/mob/living/carbon/human/proc/paize(name, bespai)
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return
	for(var/obj/item/check as anything in get_equipped_items(INCLUDE_POCKETS | INCLUDE_HELD))
		drop_item_ground(check, force = TRUE)
	ADD_TRAIT(src, TRAIT_NO_TRANSFORM, PERMANENT_TRANSFORMATION_TRAIT)
	icon = null
	invisibility = INVISIBILITY_ABSTRACT
	var/obj/item/paicard/card

	if(bespai)
		card = new /obj/item/paicard/syndicate(loc)

	else
		card = new /obj/item/paicard(loc)

	var/mob/living/silicon/pai/pai = new(card)
	pai.possess_by_player(key)
	card.setPersonality(pai)
	pai.name = name
	pai.real_name = name
	card.name = name

	to_chat(pai, "<b>You have become a pAI! Your name is [pai.name].</b>")
	INVOKE_ASYNC(GLOBAL_PROC, /proc/qdel, src)

/mob/proc/gorillize(gorilla_type = "Normal", message = TRUE)
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return

	if(stat == DEAD)
		return

	for(var/obj/item/check as anything in get_equipped_items(INCLUDE_POCKETS | INCLUDE_HELD))
		drop_item_ground(check, force = TRUE)

	ADD_TRAIT(src, TRAIT_NO_TRANSFORM, PERMANENT_TRANSFORMATION_TRAIT)
	icon = null
	invisibility = INVISIBILITY_MAXIMUM

	if(message)
		visible_message(
			span_warning("[src] transforms into a gorilla!"),
			span_warning("You transform into a gorilla! Ooga ooga!"),
			span_italics("You hear a loud roar!"),
		)

	switch(gorilla_type)
		if("Normal")
			gorilla_type = /mob/living/simple_animal/hostile/gorilla
		if("Enraged")
			gorilla_type = /mob/living/simple_animal/hostile/gorilla/rampaging
		if("Cargorilla")
			gorilla_type = /mob/living/simple_animal/hostile/gorilla/cargo_domestic
		else
			return

	var/mob/living/simple_animal/hostile/gorilla/new_gorilla = new gorilla_type(get_turf(src))
	playsound(new_gorilla, 'sound/creatures/gorilla.ogg', 50)

	if(mind)
		mind.transfer_to(new_gorilla)
	else
		new_gorilla.possess_by_player(key)

	qdel(src)

//oh no, cringe
/mob/proc/get_npc_respawn_message()
	return "Ты [name]."

/mob/proc/safe_respawn(mob/living/passed_mob, check_station_level = TRUE)
	. = FALSE

	var/static/list/safe_respawn_typecache_nuclear = typecacheof(list(
		/mob/living/simple_animal/pet/cat/Syndi,
		/mob/living/simple_animal/pet/dog/fox/Syndifox,
	))
	if(is_type_in_typecache(passed_mob, safe_respawn_typecache_nuclear))
		return GAMEMODE_IS_NUCLEAR

	if(check_station_level && !is_admin(src) && !is_station_level(passed_mob.z))
		return FALSE

	if(isborer(passed_mob) && !jobban_isbanned(src, ROLE_BORER) && !jobban_isbanned(src, ROLE_SYNDICATE))
		return TRUE

	if(isnymph(passed_mob) && !jobban_isbanned(src, ROLE_NYMPH))
		return TRUE

	var/static/list/safe_respawn_typecache_whitelist = typecacheof(list(
		/mob/living/carbon/human/lesser/monkey/punpun,
		/mob/living/simple_animal/butterfly,
		/mob/living/simple_animal/chick,
		/mob/living/simple_animal/chicken,
		/mob/living/simple_animal/cock,
		/mob/living/simple_animal/cow,
		/mob/living/simple_animal/crab,
		/mob/living/simple_animal/frog,
		/mob/living/simple_animal/goose,
		/mob/living/simple_animal/hostile/gorilla/cargo_domestic,
		/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge,
		/mob/living/simple_animal/mouse/rat,
		/mob/living/simple_animal/mouse/wooly,
		/mob/living/simple_animal/parrot,
		/mob/living/simple_animal/pet/cat,
		/mob/living/simple_animal/pet/dog/corgi,
		/mob/living/simple_animal/pet/dog/fox,
		/mob/living/simple_animal/pet/dog/pug,
		/mob/living/simple_animal/pet/dog/security,
		/mob/living/simple_animal/pet/penguin,
		/mob/living/simple_animal/pet/sloth,
		/mob/living/simple_animal/pet/slugcat,
		/mob/living/simple_animal/pig,
		/mob/living/simple_animal/possum,
		/mob/living/simple_animal/turkey,
	))

	// Blacklist typecache.
	var/static/list/safe_respawn_typecache_blacklist = typecacheof(list(
		/mob/living/simple_animal/pet/dog/fox/alisa,
	))

	if(is_type_in_typecache(passed_mob, safe_respawn_typecache_whitelist) && !is_type_in_typecache(passed_mob, safe_respawn_typecache_blacklist))
		return TRUE
