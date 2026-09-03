/datum/action/cooldown/spell/evolve
	name = "Evolve"
	desc = "Evolve into reporting this issue."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "larva2"
	button_icon = 'icons/mob/alien.dmi'
	background_icon_state = "bg_alien"
	spell_requirements = NONE
	var/evolution_path = /mob/living/carbon/alien/larva

/datum/action/cooldown/spell/evolve/create_new_handler()
	var/datum/spell_handler/alien/handler = new(src)
	return handler

/datum/action/cooldown/spell/evolve/larva
	desc = "Evolve into a fully grown Alien."
	button_icon_state = "alienh_running"

/datum/action/cooldown/spell/evolve/praetorian
	desc = "Become a Praetorian, Royal Guard to the Queen."
	button_icon_state = "aliens_running"
	evolution_path = /mob/living/carbon/alien/humanoid/praetorian

/datum/action/cooldown/spell/evolve/queen
	desc = "Evolve into an Alien Queen."
	button_icon_state = "alienq_running"
	evolution_path = /mob/living/carbon/alien/humanoid/queen/large

/datum/action/cooldown/spell/evolve/can_cast_spell(feedback)
	if(!..())
		return FALSE
	if(!isalien(owner))
		return FALSE
	var/mob/living/carbon/alien/humanoid/xeno = owner
	if(!xeno.can_evolve)
		if(feedback)
			to_chat(xeno, span_warning("We have nowhere to evolve further!"))
		return FALSE

	if(xeno.evolution_points < xeno.max_evolution_points)
		if(feedback)
			to_chat(xeno, span_warning("We are not ready to evolve yet!"))
		return FALSE

	if(xeno.has_brain_worms())
		if(feedback)
			to_chat(xeno, span_warning("We cannot perform this ability at the present time!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/evolve/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/alien/user = cast_on

	to_chat(user, span_noticealien("You begin to evolve!"))
	user.visible_message(span_alertalien("[user] begins to twist and contort!"))

	var/mob/living/carbon/alien/new_xeno = new evolution_path(get_turf(user))
	user.mind.transfer_to(new_xeno)
	SEND_SIGNAL(new_xeno.mind, COMSIG_ALIEN_EVOLVE, user.type, evolution_path)
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
				playsound(turf, 'sound/effects/clang.ogg', 50, TRUE)
				turf.break_tile_to_plating()
				pipe?.deconstruct()
		else
			new_xeno.move_into_vent(pipe, message = FALSE)

	playsound_xenobuild(user.loc)
	SSblackbox.record_feedback("tally", "alien_growth", 1, "[new_xeno]")
	qdel(user)

/datum/action/cooldown/spell/evolve/larva/cast(atom/cast_on)
	to_chat(cast_on, span_boldnotice("You are growing into a beautiful alien! It is time to choose a caste."))
	to_chat(cast_on, span_notice("There are three to choose from:"))
	to_chat(cast_on, span_notice("<b>Hunters</b> are strong and agile, able to hunt away from the hive and rapidly move through ventilation shafts. Hunters generate plasma slowly and have low reserves."))
	to_chat(cast_on, span_notice("<b>Sentinels</b> are tasked with protecting the hive and are deadly up close and at a range. They are not as physically imposing nor fast as the hunters."))
	to_chat(cast_on, span_notice("<b>Drones</b> are the working class, offering the largest plasma storage and generation. They are the only caste which may evolve again, turning into the dreaded alien queen."))
	var/static/list/to_evolve = list("Hunter" = image(icon = 'icons/mob/alien.dmi', icon_state = "alienh_running"),
								"Sentinel" = image(icon = 'icons/mob/alien.dmi', icon_state = "aliens_running"),
								"Drone" = image(icon = 'icons/mob/alien.dmi', icon_state = "aliend_running"))
	var/choosen_type = show_radial_menu(cast_on, cast_on, to_evolve, src, radius = 40)
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

/datum/action/cooldown/spell/evolve/praetorian/cast(atom/cast_on)
	var/mob/living/carbon/alien/spell_owner = cast_on
	if(!istype(spell_owner))
		return

	var/living_players_count = 0
	for(var/mob/living/player in GLOB.player_list)
		if(player.client && player.stat != DEAD)
			living_players_count++

	if(spell_owner.praetorian_count < (living_players_count / XENO_PLAYERS_FOR_PRAETORIAN))
		..()
	else
		to_chat(spell_owner, span_warning("We have too many praetorians."))

/datum/action/cooldown/spell/evolve/queen/can_cast_spell(feedback)
	if(!..())
		return FALSE
	var/mob/living/carbon/alien/humanoid/xeno = owner
	if(xeno.queen_count >= xeno.queen_maximum)
		if(feedback)
			to_chat(xeno, span_warning("We already have a queen."))
		return FALSE
	var/datum/team/xenomorph/team = locate(/datum/team/xenomorph) in GLOB.antagonist_teams
	if(team?.current_queen?.current && team.current_queen.current.stat != DEAD)
		if(feedback)
			to_chat(xeno, span_warning("Королева всё ещё жива."))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/evolve/queen/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/alien/user = cast_on
	if(!user)
		return
	user.queen_count++

#undef XENO_PLAYERS_FOR_PRAETORIAN
