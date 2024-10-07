/* Code for the Wild West map by Brotemis
 * Contains:
 *		Wish Granter
 *		Meat Grinder
 */

//Wild West Areas

/area/awaymission/wwmines
	name = "\improper Wild West Mines"
	icon_state = "away1"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE

/area/awaymission/wwgov
	name = "\improper Wild West Mansion"
	icon_state = "away2"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE

/area/awaymission/wwrefine
	name = "\improper Wild West Refinery"
	icon_state = "away3"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE

/area/awaymission/wwvault
	name = "\improper Wild West Vault"
	icon_state = "away3"

/area/awaymission/wwvaultdoors
	name = "\improper Wild West Vault Doors"  // this is to keep the vault area being entirely lit because of requires_power
	icon_state = "away2"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE

/*
 * Wish Granter
 */
/obj/machinery/wish_granter_dark
	name = "Wish Granter"
	desc = "You're not so sure about this, anymore..."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"

	anchored = TRUE
	density = TRUE
	use_power = NO_POWER_USE

	var/chargesa = 1
	var/insistinga = 0

/obj/machinery/wish_granter_dark/attack_hand(var/mob/living/carbon/human/user as mob)
	usr.set_machine(src)

	if(chargesa <= 0)
		to_chat(user, "The Wish Granter lies silent.")
		return

	else if(!ishuman(user))
		to_chat(user, "You feel a dark stirring inside of the Wish Granter, something you want nothing of. Your instincts are better than any man's.")
		return

	else if(is_special_character(user))
		to_chat(user, "Even to a heart as dark as yours, you know nothing good will come of this.  Something instinctual makes you pull away.")

	else if(!insistinga)
		to_chat(user, "Your first touch makes the Wish Granter stir, listening to you.  Are you really sure you want to do this?")
		insistinga++

	else
		chargesa--
		insistinga = 0
		var/wish = input("You want...","Wish") as null|anything in list("Power","Wealth","Immortality","Peace")
		switch(wish)
			if("Power")
				to_chat(user, "<B>Your wish is granted, but at a terrible cost...</B>")
				to_chat(user, "The Wish Granter punishes you for your selfishness, claiming your soul and warping your body to match the darkness in your heart.")
				ADD_TRAIT(user, TRAIT_LASEREYES, WISHGRANTER_TRAIT)
				ADD_TRAIT(user, TRAIT_RESIST_COLD, WISHGRANTER_TRAIT)
				ADD_TRAIT(user, TRAIT_XRAY, WISHGRANTER_TRAIT)
				user.update_sight()
				if(ishuman(user))
					var/mob/living/carbon/human/human = user
					if(!isshadowperson(human))
						to_chat(user, "<span class='warning'>Your flesh rapidly mutates!</span>")
						to_chat(user, "<b>You are now a Shadow Person, a mutant race of darkness-dwelling humanoids.</b>")
						to_chat(user, "<span class='warning'>Your body reacts violently to light.</span> <span class='notice'>However, it naturally heals in darkness.</span>")
						to_chat(user, "Aside from your new traits, you are mentally unchanged and retain your prior obligations.")
						human.set_species(/datum/species/shadow)
				user.regenerate_icons()
			if("Wealth")
				to_chat(user, "<B>Your wish is granted, but at a terrible cost...</B>")
				to_chat(user, "The Wish Granter punishes you for your selfishness, claiming your soul and warping your body to match the darkness in your heart.")
				new /obj/structure/closet/syndicate/resources/everything(loc)
				if(ishuman(user))
					var/mob/living/carbon/human/human = user
					if(!isshadowperson(human))
						to_chat(user, "<span class='warning'>Your flesh rapidly mutates!</span>")
						to_chat(user, "<b>You are now a Shadow Person, a mutant race of darkness-dwelling humanoids.</b>")
						to_chat(user, "<span class='warning'>Your body reacts violently to light.</span> <span class='notice'>However, it naturally heals in darkness.</span>")
						to_chat(user, "Aside from your new traits, you are mentally unchanged and retain your prior obligations.")
						human.set_species(/datum/species/shadow)
				user.regenerate_icons()
			if("Immortality")
				to_chat(user, "<B>Your wish is granted, but at a terrible cost...</B>")
				to_chat(user, "The Wish Granter punishes you for your selfishness, claiming your soul and warping your body to match the darkness in your heart.")
				add_verb(user, /mob/living/carbon/proc/immortality)
				if(ishuman(user))
					var/mob/living/carbon/human/human = user
					if(!isshadowperson(human))
						to_chat(user, "<span class='warning'>Your flesh rapidly mutates!</span>")
						to_chat(user, "<b>You are now a Shadow Person, a mutant race of darkness-dwelling humanoids.</b>")
						to_chat(user, "<span class='warning'>Your body reacts violently to light.</span> <span class='notice'>However, it naturally heals in darkness.</span>")
						to_chat(user, "Aside from your new traits, you are mentally unchanged and retain your prior obligations.")
						human.set_species(/datum/species/shadow)
				user.regenerate_icons()
			if("Peace")
				to_chat(user, "<B>Whatever alien sentience that the Wish Granter possesses is satisfied with your wish. There is a distant wailing as the last of the Faithless begin to die, then silence.</B>")
				to_chat(user, "You feel as if you just narrowly avoided a terrible fate...")
				for(var/mob/living/simple_animal/hostile/faithless/F in GLOB.mob_living_list)
					F.death()


///////////////Meatgrinder//////////////


/obj/effect/meatgrinder
	name = "Meat Grinder"
	desc = "What is that thing?"
	density = TRUE
	anchored = TRUE
	layer = 3
	icon = 'icons/mob/blob.dmi'
	icon_state = "blobpod"
	var/triggered = FALSE


/obj/effect/meatgrinder/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/effect/meatgrinder/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(collide), arrived)


/obj/effect/meatgrinder/Bumped(atom/movable/moving_atom)
	. = ..()
	collide(moving_atom)


/obj/effect/meatgrinder/proc/collide(atom/movable/moving_atom)
	if(triggered || !ishuman(moving_atom))
		return
	visible_message(span_warning("[moving_atom] triggered the [bicon(src)] [src]!"))
	triggered = TRUE
	do_sparks(3, 1, src)
	explosion(src, 1, 0, 0, 0)
	qdel(src)


/////For the Wishgranter///////////

/mob/living/carbon/proc/immortality()
	set category = "Immortality"
	set name = "Resurrection"

	var/mob/living/carbon/C = usr
	if(C.stat != DEAD)
		to_chat(C, "<span class='notice'>You're not dead yet!</span>")
		return
	if(revival_in_progress)
		to_chat(C, "<span class='notice'>You're already rising from the dead!</span>")
		return //no spam callbacks
	C.revival_in_progress = TRUE
	to_chat(C, "<span class='notice'>Death is not your end!</span>")
	addtimer(CALLBACK(C, PROC_REF(resurrect), C), rand(80 SECONDS, 120 SECONDS))

/mob/living/carbon/proc/resurrect(var/mob/living/carbon/user)
	user.revive()
	user.revival_in_progress = FALSE
	to_chat(user, "<span class='notice'>You have regenerated.</span>")
	user.visible_message("<span class='warning'>[user] appears to wake from the dead, having healed all wounds.</span>")
	return 1


/obj/item/wildwest_communicator
	name = "Syndicate Comms Device"
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-red"
	item_state = "walkietalkie"
	desc = "Use to communicate with the syndicate base commander."
	var/used = FALSE


/obj/item/wildwest_communicator/attack_self(mob/living/user)

	if(!is_away_level(user.z))
		to_chat(user, span_warning("The communicator emits a faint beep. Perhaps it is out of range?"))
		return

	if(used)
		to_chat(user, span_warning("The communicator buzzes, and then dies. Apparently nobody is responding."))
		return

	to_chat(user, span_warning("The communicator buzzes, and you hear a voice on the line, almost lost in the static. 'Hello? Who is this?'."))

	var/const/option_explorer = "(TRUTH) \"Explorers.\""
	var/const/option_bluff = "(BLUFF) \"Weapons delivery.\""
	var/const/option_threat = "(THREAT) \"NT, here to kick your ass!\""
	var/const/option_syndicate = "(SYNDI) \"Agent reporting in...\""
	var/list/response_choices = list(option_explorer, option_bluff, option_threat)

	if(user.mind?.has_antag_datum(/datum/antagonist/traitor))
		response_choices |= option_syndicate

	var/selected_choice = tgui_input_list(user, "How do you respond on the comms device?", "Response to Syndicate", response_choices)

	if(!selected_choice || used)
		return

	switch(selected_choice)
		if(option_explorer)
			to_chat(user, span_warning("The communicator buzzes, and you hear the voice again: 'Hah! You sure picked the wrong asteroid to explore. Get em, boys!'"))
		if(option_bluff)
			to_chat(user, span_warning("The communicator buzzes, and you hear the voice again: 'Really? I think not. Get them!'"))
		if(option_threat)
			to_chat(user, span_warning("The communicator buzzes, and you hear the voice again: 'Oh really now?' You hear a clicking sound. 'Team, get back here. We have trouble.' Then the line goes dead."))
			for(var/obj/effect/landmark/L in GLOB.landmarks_list)
				if(L.name == "wildwest_syndipod")
					var/obj/spacepod/syndi/P = new /obj/spacepod/syndi(get_turf(L))
					P.name = "Syndi Recon Pod"
				if(L.name == "wildwest_syndibackup")
					var/mob/living/simple_animal/hostile/syndicate/ranged/space/R = new /mob/living/simple_animal/hostile/syndicate/ranged/space(get_turf(L))
					R.name = "Syndi Recon Team"
		if(option_syndicate)
			to_chat(user, span_warning("The communicator buzzes, and you hear the voice again: 'Well, I'll be damned. An agent out here? You must be off-mission! Leave my troops alone, and they will do the same for you. Our Commander will handle you himself.'"))
			stand_down()
	used = TRUE


/obj/item/wildwest_communicator/proc/stand_down()
	for(var/mob/living/simple_animal/hostile/syndicate/ranged/wildwest/W in GLOB.alive_mob_list)
		W.on_alert = FALSE


/mob/living/simple_animal/hostile/syndicate/ranged/wildwest
	var/on_alert = TRUE

/mob/living/simple_animal/hostile/syndicate/ranged/wildwest/ListTargets()
	if(on_alert)
		return ..()
	return list()

/mob/living/simple_animal/hostile/syndicate/ranged/wildwest/death(gibbed)
	// putting this up here so we don't say anything after deathgasp
	if(can_die() && !on_alert)
		say("How could you betray the Syndicate?")
		for(var/mob/living/simple_animal/hostile/syndicate/ranged/wildwest/W in GLOB.alive_mob_list)
			W.on_alert = TRUE
	return ..(gibbed)
