#define LIVING_PLAYERS_COUNT_FOR_1_PRAETORIAN 25

/obj/effect/proc_holder/spell/alien_spell/evolve
	name = "Evolve"
	desc = "Evolve into reporting this issue."
	action_icon_state = "larva2"
	action_icon = 'icons/mob/alien.dmi'
	var/evolution_path = /mob/living/carbon/alien/larva


/obj/effect/proc_holder/spell/alien_spell/evolve/larva
	desc = "Evolve into a fully grown Alien."
	action_icon_state = "alienh_running"


/obj/effect/proc_holder/spell/alien_spell/evolve/praetorian
	desc = "Become a Praetorian, Royal Guard to the Queen."
	action_icon_state = "aliens_running"
	evolution_path = /mob/living/carbon/alien/humanoid/praetorian


/obj/effect/proc_holder/spell/alien_spell/evolve/queen
	desc = "Evolve into an Alien Queen."
	action_icon_state = "alienq_running"
	evolution_path = /mob/living/carbon/alien/humanoid/queen/large


/obj/effect/proc_holder/spell/alien_spell/evolve/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/alien_spell/evolve/can_cast(mob/living/carbon/alien/user, charge_check, show_message)
	if(!..())
		return FALSE

	if(!user.can_evolve)
		if(show_message)
			to_chat(user, span_warning("We have nowhere to evolve further!"))
		return FALSE

	if(user.evolution_points < user.max_evolution_points)
		if(show_message)
			to_chat(user, span_warning("We are not ready to evolve yet!"))
		return FALSE

	if(user.has_brain_worms())
		if(show_message)
			to_chat(user, span_warning("We cannot perform this ability at the present time!"))
		return FALSE

	return TRUE


/obj/effect/proc_holder/spell/alien_spell/evolve/cast(list/targets, mob/living/carbon/alien/user)
	to_chat(user, span_noticealien("You begin to evolve!"))
	user.visible_message(span_alertalien("[user] begins to twist and contort!"))

	var/mob/living/carbon/alien/new_xeno = new evolution_path(get_turf(user))
	user.mind.transfer_to(new_xeno)
	new_xeno.mind.name = new_xeno.name

	if(HAS_TRAIT(user, TRAIT_MOVE_VENTCRAWLING))
		var/obj/machinery/atmospherics/pipe = user.loc
		if(!new_xeno.ventcrawler_trait)
			new_xeno.stop_ventcrawling(message = FALSE)
			new_xeno.visible_message(
				span_notice("[new_xeno.name] с грохотом вываливается из вентиляции!"),
				span_notice("Вы с грохотом вываливаетесь из вентиляции."),
			)

			var/turf/simulated/floor/turf = get_turf(new_xeno)
			if(istype(turf))
				playsound(turf, "sound/effects/clang.ogg", 50, TRUE)
				turf.break_tile_to_plating()
				pipe?.deconstruct()
		else
			new_xeno.move_into_vent(pipe, message = FALSE)


	playsound_xenobuild(user.loc)
	SSblackbox.record_feedback("tally", "alien_growth", 1, "[new_xeno]")
	qdel(user)


/obj/effect/proc_holder/spell/alien_spell/evolve/larva/cast(list/targets, mob/living/carbon/alien/larva/user)
	to_chat(user, span_boldnotice("You are growing into a beautiful alien! It is time to choose a caste."))
	to_chat(user, span_notice("There are three to choose from:"))
	to_chat(user, span_notice("<B>Hunters</B> are strong and agile, able to hunt away from the hive and rapidly move through ventilation shafts. Hunters generate plasma slowly and have low reserves."))
	to_chat(user, span_notice("<B>Sentinels</B> are tasked with protecting the hive and are deadly up close and at a range. They are not as physically imposing nor fast as the hunters."))
	to_chat(user, span_notice("<B>Drones</B> are the working class, offering the largest plasma storage and generation. They are the only caste which may evolve again, turning into the dreaded alien queen."))
	var/static/list/to_evolve = list("Hunter" = image(icon = 'icons/mob/alien.dmi', icon_state = "alienh_running"),
								"Sentinel" = image(icon = 'icons/mob/alien.dmi', icon_state = "aliens_running"),
								"Drone" = image(icon = 'icons/mob/alien.dmi', icon_state = "aliend_running"))
	var/choosen_type = show_radial_menu(user, user, to_evolve, src, radius = 40)
	if(!choosen_type)
		return
	switch(choosen_type)
		if("Hunter")
			evolution_path = /mob/living/carbon/alien/humanoid/hunter
		if("Sentinel")
			evolution_path = /mob/living/carbon/alien/humanoid/sentinel
		if("Drone")
			evolution_path = /mob/living/carbon/alien/humanoid/drone
	..()


/obj/effect/proc_holder/spell/alien_spell/evolve/praetorian/cast(list/targets, mob/living/carbon/user)
	var/mob/living/carbon/alien/spell_owner = user
	if(!istype(spell_owner))
		return

	var/living_players_count = 0
	for(var/mob/living/player in GLOB.player_list)
		if(player.client && player.stat != DEAD)
			living_players_count++

	if(spell_owner.praetorian_count < (living_players_count/LIVING_PLAYERS_COUNT_FOR_1_PRAETORIAN))
		..()
	else
		to_chat(user, span_warning("We have too many praetorians."))


/obj/effect/proc_holder/spell/alien_spell/evolve/queen/can_cast(mob/living/carbon/alien/user, charge_check, show_message)
	if(!..())
		return FALSE

	if(user.queen_count >= user.queen_maximum)
		if(show_message)
			to_chat(user, span_warning("We already have a queen."))
		return FALSE

	return TRUE

/obj/effect/proc_holder/spell/alien_spell/evolve/queen/cast(list/targets, mob/living/carbon/alien/user)
	..()
	user.queen_count++


#undef LIVING_PLAYERS_COUNT_FOR_1_PRAETORIAN
