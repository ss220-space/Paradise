// This is to replace the previous datum/disease/alien_embryo for slightly improved handling and maintainability
// It functions almost identically (see code/datums/diseases/alien_embryo.dm)

/obj/item/organ/internal/body_egg/alien_embryo
	name = "alien embryo"
	icon = 'icons/mob/alien.dmi'
	icon_state = "larva0_dead"
	var/stage = 0
	var/polling = FALSE
	var/mob/candidate = null
	COOLDOWN_DECLARE(xeno_embryo)

/obj/item/organ/internal/body_egg/alien_embryo/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	COOLDOWN_START(src, xeno_embryo, XENO_EMBRYO_TIME)

/obj/item/organ/internal/body_egg/alien_embryo/on_find(mob/living/finder)
	..()
	if(stage < 4)
		to_chat(finder, "Оно маленькое и слабое, едва размером с плод.")
	else
		to_chat(finder, "Оно выросло довольно большим и слегка извивается, когда вы смотрите на него.")
		if(prob(10))
			AttemptGrow(FALSE)

/obj/item/organ/internal/body_egg/alien_embryo/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("sacid", 10)
	return S

/obj/item/organ/internal/body_egg/alien_embryo/on_life()
	switch(stage)
		if(2, 3)
			if(prob(2))
				owner.emote("sneeze")
			if(prob(2))
				owner.emote("cough")
			if(prob(2))
				to_chat(owner, span_danger("Ваше горло болит."))
			if(prob(2))
				to_chat(owner, span_danger("Слизь стекает по задней стенке вашего горла."))
		if(4)
			if(prob(2))
				owner.emote("sneeze")
			if(prob(2))
				owner.emote("cough")
			if(prob(4))
				to_chat(owner, span_danger("Ваши мышцы ноют."))
				owner.take_organ_damage(1)
			if(prob(4))
				to_chat(owner, span_danger("Ваш живот болит."))
				owner.adjustToxLoss(1)
		if(5)
			to_chat(owner, span_danger("Вы чувствуете, как что-то прорывается из вашего живота..."))
			owner.adjustToxLoss(10)

/obj/item/organ/internal/body_egg/alien_embryo/egg_process()
	if(stage < 5 && COOLDOWN_FINISHED(src, xeno_embryo))
		COOLDOWN_START(src, xeno_embryo, XENO_EMBRYO_TIME)
		stage++
		spawn(0)
			RefreshInfectionImage()

	if(stage >= 5 && COOLDOWN_FINISHED(src, xeno_embryo))
		for(var/datum/surgery/surgery in owner.surgeries)
			if(surgery.location == BODY_ZONE_CHEST && surgery.organ_to_manipulate.open >= ORGAN_ORGANIC_OPEN)
				AttemptGrow(FALSE)
				return
		AttemptGrow()

/obj/item/organ/internal/body_egg/alien_embryo/proc/AttemptGrow(gib_on_success = TRUE)
	if(!owner || polling)
		return

	polling = TRUE
	INVOKE_ASYNC(src, PROC_REF(handle_async), gib_on_success)

/obj/item/organ/internal/body_egg/alien_embryo/proc/handle_async(gib_on_success)
	if(QDELETED(src))
		return

	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыгрять за Чужого?", ROLE_ALIEN, FALSE, poll_time = 5 SECONDS, source = /mob/living/carbon/alien/larva)

	if(QDELETED(src))
		return
	// To stop clientless larva, we will check that our host has a client
	// if we find no ghosts to become the alien. If the host has a client
	// he will become the alien but if he doesn't then we will set the stage
	// to 4, so we don't do a process heavy check everytime.

	if(length(candidates))
		candidate = pick(candidates)
	else if(owner.client)
		candidate = owner.client
	else
		stage = 4 // Let's try again later.
		polling = FALSE
		return

	addtimer(CALLBACK(src, PROC_REF(spawn_larva), gib_on_success), 1 SECONDS)

/obj/item/organ/internal/body_egg/alien_embryo/proc/spawn_larva(gib_on_success)
	if(QDELETED(src) || QDELETED(owner))
		return

	var/stand_check = owner.body_position == STANDING_UP
	var/overlay = mutable_appearance('icons/mob/alien.dmi', icon_state = stand_check? "burst_stand" : "burst_lie")
	owner.add_overlay(overlay)

	var/mob/living/carbon/alien/larva/new_xeno = new(owner.drop_location())
	new_xeno.possess_by_player(candidate.key)
	new_xeno.mind.name = new_xeno.name
	new_xeno.update_datum()
	SEND_SOUND(new_xeno, sound('sound/voice/hiss5.ogg'))//To get the player's attention
	log_game("[new_xeno.key] has become Alien Larva from [owner](ckey: [owner.key ? owner.key : "None"]) body.")

	if(gib_on_success)
		owner.gib()
	else
		owner.adjustBruteLoss(40)
		owner.cut_overlay(overlay)
		stand_check = owner.body_position == STANDING_UP
		overlay = mutable_appearance('icons/mob/alien.dmi', icon_state = stand_check? "bursted_stand" : "bursted_lie")
		owner.add_overlay(overlay)
	qdel(src)

/*----------------------------------------
Proc: AddInfectionImages(C)
Des: Adds the infection image to all aliens for this embryo
----------------------------------------*/
/obj/item/organ/internal/body_egg/alien_embryo/AddInfectionImages()
	for(var/mob/living/carbon/alien/alien as anything in GLOB.aliens_list)
		if(alien.client)
			var/I = image('icons/mob/alien.dmi', loc = owner, icon_state = "infected[stage]")
			alien.client.images += I

/*----------------------------------------
Proc: RemoveInfectionImage(C)
Des: Removes all images from the mob infected by this embryo
----------------------------------------*/
/obj/item/organ/internal/body_egg/alien_embryo/RemoveInfectionImages()
	for(var/mob/living/carbon/alien/alien as anything in GLOB.aliens_list)
		if(alien.client)
			for(var/image/I in alien.client.images)
				if(dd_hasprefix_case(I.icon_state, "infected") && I.loc == owner)
					qdel(I)

#undef XENO_EMBRYO_TIME
