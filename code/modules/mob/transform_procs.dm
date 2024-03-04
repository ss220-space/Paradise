/mob/living/carbon/human/proc/monkeyize()
	if (!dna.GetSEState(GLOB.monkeyblock)) // Monkey block NOT present.
		dna.SetSEState(GLOB.monkeyblock,1)
		genemutcheck(src,GLOB.monkeyblock,null,MUTCHK_FORCED)

/mob/living/carbon/human/proc/is_monkeyized()
	return dna.GetSEState(GLOB.monkeyblock)

/mob/living/carbon/human/proc/humanize()
	if (dna.GetSEState(GLOB.monkeyblock)) // Monkey block present.
		dna.SetSEState(GLOB.monkeyblock,0)
		genemutcheck(src,GLOB.monkeyblock,null,MUTCHK_FORCED)

/mob/living/carbon/human/proc/is_humanized()
	return !dna.GetSEState(GLOB.monkeyblock)

/mob/new_player/AIize()
	spawning = 1
	return ..()

/mob/living/carbon/AIize()
	if(notransform)
		return
	for(var/obj/item/W in src)
		drop_item_ground(W)
	notransform = 1
	canmove = FALSE
	icon = null
	invisibility = INVISIBILITY_ABSTRACT
	return ..()

/mob/proc/AIize()
	if(client)
		stop_sound_channel(CHANNEL_LOBBYMUSIC)

	var/mob/living/silicon/ai/O = new (loc,,,1)//No MMI but safety is in effect.
	O.invisibility = 0
	O.aiRestorePowerRoutine = 0

	if(mind)
		mind.transfer_to(O)
		O.mind.set_original_mob(O)
	else
		O.key = key

	O.on_mob_init()

	O.add_ai_verbs()

	O.rename_self("AI",1)

	O.tts_seed = tts_seed

	INVOKE_ASYNC(GLOBAL_PROC, /proc/qdel, src) // To prevent the proc from returning null.
	return O



/**
	For transforming humans into robots (cyborgs).

	Arguments:
	* cell_type: A type path of the cell the new borg should receive.
	* connect_to_default_AI: TRUE if you want /robot/New() to handle connecting the borg to the AI with the least borgs.
	* AI: A reference to the AI we want to connect to.
*/
/mob/living/carbon/human/proc/Robotize(cell_type = null, connect_to_default_AI = TRUE, mob/living/silicon/ai/AI = null)
	if(notransform)
		return
	for(var/obj/item/W in src)
		drop_item_ground(W)

	notransform = 1
	canmove = FALSE
	icon = null
	invisibility = INVISIBILITY_ABSTRACT

	// Creating a new borg here will connect them to a default AI and notify that AI, if `connect_to_default_AI` is TRUE.
	var/mob/living/silicon/robot/O = new /mob/living/silicon/robot(loc, connect_to_AI = connect_to_default_AI)

	// If `AI` is passed in, we want to connect to that AI specifically.
	if(AI)
		O.lawupdate = TRUE
		O.connect_to_ai(AI)

	if(!cell_type)
		O.cell = new /obj/item/stock_parts/cell/high(O)
	else
		O.cell = new cell_type(O)

	O.gender = gender
	O.invisibility = 0

	if(mind)		//TODO
		mind.transfer_to(O)
		if(O.mind.assigned_role == "Cyborg")
			O.mind.set_original_mob(O)
		else if(mind && mind.special_role)
			O.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")
	else
		O.key = key

	O.forceMove(loc)
	O.job = "Cyborg"

	if(O.mind && O.mind.assigned_role == "Cyborg")
		if(O.mind.role_alt_title == "Robot")
			O.mmi = new /obj/item/mmi/robotic_brain(O)
			if(O.mmi.brainmob)
				O.mmi.brainmob.name = O.name
		else
			O.mmi = new /obj/item/mmi(O)
		O.mmi.transfer_identity(src) //Does not transfer key/client.

	O.update_pipe_vision()

	O.Namepick()

	O.tts_seed = tts_seed

	INVOKE_ASYNC(GLOBAL_PROC, /proc/qdel, src) // To prevent the proc from returning null.
	return O

/mob/living/carbon/human/proc/corgize()
	if(notransform)
		return
	for(var/obj/item/W in src)
		drop_item_ground(W)
	regenerate_icons()
	notransform = 1
	canmove = FALSE
	icon = null
	invisibility = INVISIBILITY_ABSTRACT
	for(var/t in bodyparts)	//this really should not be necessary
		qdel(t)

	var/mob/living/simple_animal/pet/dog/corgi/new_corgi = new /mob/living/simple_animal/pet/dog/corgi (loc)
	new_corgi.key = key

	to_chat(new_corgi, "<B>You are now a Corgi. Yap Yap!</B>")
	new_corgi.update_pipe_vision()
	qdel(src)

/mob/living/carbon/human/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(notransform)
		return
	for(var/obj/item/W in src)
		drop_item_ground(W)

	regenerate_icons()
	notransform = 1
	canmove = FALSE
	icon = null
	invisibility = INVISIBILITY_ABSTRACT

	for(var/t in bodyparts)
		qdel(t)

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = INTENT_HARM


	to_chat(new_mob, "You suddenly feel more... animalistic.")
	new_mob.update_pipe_vision()
	qdel(src)

/mob/proc/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = INTENT_HARM
	to_chat(new_mob, "You feel more... animalistic")
	new_mob.update_pipe_vision()

	qdel(src)

/mob/living/carbon/human/proc/paize(name, bespai)
	if(notransform)
		return
	for(var/obj/item/W in src)
		drop_item_ground(W)
	regenerate_icons()
	notransform = TRUE
	canmove = FALSE
	icon = null
	invisibility = INVISIBILITY_ABSTRACT
	var/obj/item/paicard/card

	if(bespai)
		card = new /obj/item/paicard/syndicate(loc)

	else
		card = new /obj/item/paicard(loc)

	var/mob/living/silicon/pai/pai = new(card)
	pai.key = key
	card.setPersonality(pai)
	pai.name = name
	pai.real_name = name
	card.name = name

	to_chat(pai, "<B>You have become a pAI! Your name is [pai.name].</B>")
	pai.update_pipe_vision()
	INVOKE_ASYNC(GLOBAL_PROC, /proc/qdel, src)

/mob/proc/gorillize(gorilla_type = "Normal", message = TRUE)
	if(notransform)
		return

	if(stat == DEAD)
		return

	for(var/obj/item/check in get_all_slots())
		drop_item_ground(check, force = TRUE)

	notransform = TRUE
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
		new_gorilla.key = key

	qdel(src)


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

	if(istype(passed_mob, /mob/living/simple_animal/borer) && !jobban_isbanned(src, ROLE_BORER) && !jobban_isbanned(src, ROLE_SYNDICATE))
		return TRUE

	if(isnymph(passed_mob) && !jobban_isbanned(src, ROLE_NYMPH))
		return TRUE

	// Whitelist typecache. Alphabetical order please!
	var/static/list/safe_respawn_typecache_whitelist = typecacheof(list(
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
		/mob/living/simple_animal/mouse/hamster,
		/mob/living/simple_animal/mouse/rat,
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
