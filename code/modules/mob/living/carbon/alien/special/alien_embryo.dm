// This is to replace the previous datum/disease/alien_embryo for slightly improved handling and maintainability
// It functions almost identically (see code/datums/diseases/alien_embryo.dm)

/obj/item/organ/internal/body_egg/alien_embryo
	name = "alien embryo"
	icon = 'icons/mob/alien.dmi'
	icon_state = "larva0_dead"
	var/stage = 0
	var/polling = 0

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
	if(stage < 5 && prob(4))
		stage++
		spawn(0)
			RefreshInfectionImage()

	if(stage == 5 && prob(50))
		for(var/datum/surgery/S in owner.surgeries)
			if(S.location == BODY_ZONE_CHEST && S.organ_to_manipulate.open >= ORGAN_ORGANIC_OPEN)
				AttemptGrow(FALSE)
				return
		AttemptGrow()



/obj/item/organ/internal/body_egg/alien_embryo/proc/AttemptGrow(gib_on_success = TRUE)
	if(!owner || polling)
		return
	polling = 1
	spawn()
		var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыгрять за Чужого?", ROLE_ALIEN, FALSE, source = /mob/living/carbon/alien/larva)
		var/mob/C = null

		// To stop clientless larva, we will check that our host has a client
		// if we find no ghosts to become the alien. If the host has a client
		// he will become the alien but if he doesn't then we will set the stage
		// to 2, so we don't do a process heavy check everytime.

		if(candidates.len)
			C = pick(candidates)
		else if(owner.client)
			C = owner.client
		else
			stage = 2 // Let's try again later.
			polling = 0
			return
		var/stand_check = owner.body_position == STANDING_UP
		var/overlay = mutable_appearance('icons/mob/alien.dmi', icon_state = stand_check? "burst_stand" : "burst_lie")
		owner.add_overlay(overlay)

		spawn(6)
			var/mob/living/carbon/alien/larva/new_xeno = new(owner.drop_location())
			new_xeno.key = C.key
			new_xeno.mind.name = new_xeno.name
			new_xeno.update_datum()
			new_xeno << sound('sound/voice/hiss5.ogg',0,0,0,100)//To get the player's attention
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
