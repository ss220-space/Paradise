/datum/action/cooldown/spell/evolve
	name = "Эволюционировать"
	desc = "Эволюционируйте, чтобы сообщить об этой проблеме."
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
	desc = "Эволюционируйте во взрослого Ксеноморфа."
	button_icon_state = "alienh_running"

/datum/action/cooldown/spell/evolve/praetorian
	desc = "Станьте преторианцем — стражем Королевы."
	button_icon_state = "aliens_running"
	evolution_path = /mob/living/carbon/alien/humanoid/praetorian

/datum/action/cooldown/spell/evolve/queen
	desc = "Эволюционируйте в Королеву Ксеноморфов."
	button_icon_state = "alienq_running"
	evolution_path = /mob/living/carbon/alien/humanoid/queen

/datum/action/cooldown/spell/evolve/resin_drone
	desc = "Станьте смоляным рабочим — улучшенной кастой рабочих, способной возводить толстые смоляные стены."
	button_icon_state = "drone_run"
	evolution_path = /mob/living/carbon/alien/humanoid/drone/resin_drone

/datum/action/cooldown/spell/evolve/drone
	desc = "Эволюционируйте в касту рабочих."
	button_icon_state = "drone_run"

/datum/action/cooldown/spell/evolve/drone/cast(atom/cast_on)
	var/mob/living/carbon/alien/xeno = cast_on
	if(!xeno)
		return
	to_chat(cast_on, span_boldnotice("Вы эволюционируете в продвинутую касту рабочих! Пришло время выбрать свой путь."))
	to_chat(cast_on, span_notice("Есть два пути на выбор:"))
	to_chat(cast_on, span_notice("<b>Королева</b> — матриарх улья, способная откладывать яйца и производить новых ксеносов."))
	to_chat(cast_on, span_notice("<b>Смоляной дрон</b> — улучшенный строитель, способный возводить толстые смоляные стены."))
	var/static/list/to_evolve = list("Queen" = image(icon = 'icons/mob/xeno/radial_xenos.dmi', icon_state = "queen"),
		"Resin Drone" = image(icon = 'icons/mob/xeno/radial_xenos.dmi', icon_state = "drone"))
	var/choosen_type = show_radial_menu(cast_on, cast_on, to_evolve, src, radius = 40)
	if(!choosen_type)
		return
	var/datum/team/xenomorph/team = locate(/datum/team/xenomorph) in GLOB.antagonist_teams
	switch(choosen_type)
		if("Queen")
			if(xeno.queen_count >= xeno.queen_maximum)
				to_chat(cast_on, span_warning("У нас уже есть королева."))
				return
			if(team?.current_queen?.current && team.current_queen.current.stat != DEAD)
				to_chat(cast_on, span_warning("Королева всё ещё жива."))
				return
			evolution_path = /mob/living/carbon/alien/humanoid/queen
			xeno.queen_count++
		if("Resin Drone")
			evolution_path = /mob/living/carbon/alien/humanoid/drone/resin_drone
	..()

/datum/action/cooldown/spell/evolve/can_cast_spell(feedback)
	if(!..())
		return FALSE
	if(!isalien(owner))
		return FALSE
	var/mob/living/carbon/alien/humanoid/xeno = owner
	if(!xeno.can_evolve)
		if(feedback)
			to_chat(xeno, span_warning("Нам больше некуда эволюционировать!"))
		return FALSE

	if(xeno.evolution_points < xeno.max_evolution_points)
		if(feedback)
			to_chat(xeno, span_warning("Мы ещё не готовы эволюционировать!"))
		return FALSE

	if(xeno.has_brain_worms())
		if(feedback)
			to_chat(xeno, span_warning("Мы не можем применить эту способность в данный момент!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/evolve/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/alien/user = cast_on

	to_chat(user, span_noticealien("Вы начинаете эволюционировать!"))
	user.visible_message(span_alertalien("[user] начинает извиваться и корчиться!"))

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
	to_chat(cast_on, span_boldnotice("Вы превращаетесь в прекрасного чужого! Пришло время выбрать касту."))
	to_chat(cast_on, span_notice("Есть три на выбор:"))
	to_chat(cast_on, span_notice("<b>Охотники</b> сильны и ловки, способны охотиться вдали от улья и быстро перемещаться по вентиляционным шахтам. Охотники медленно вырабатывают плазму и имеют небольшой запас."))
	to_chat(cast_on, span_notice("<b>Стражи</b> отвечают за защиту улья и смертоносны как вблизи, так и на расстоянии. Они не так быстры, как охотники."))
	to_chat(cast_on, span_notice("<b>Дроны</b> — рабочий класс, обладающий наибольшим запасом и выработкой плазмы. Это единственная каста, которая может эволюционировать снова, превратившись в грозную королеву чужих."))
	var/static/list/to_evolve = list("Hunter" = image(icon = 'icons/mob/xeno/radial_xenos.dmi', icon_state = "hunter"),
								"Sentinel" = image(icon = 'icons/mob/xeno/radial_xenos.dmi', icon_state = "sentinel"),
								"Drone" = image(icon = 'icons/mob/xeno/radial_xenos.dmi', icon_state = "drone"))
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
		to_chat(spell_owner, span_warning("У нас слишком много преторианцев."))

/datum/action/cooldown/spell/evolve/queen/can_cast_spell(feedback)
	if(!..())
		return FALSE
	var/mob/living/carbon/alien/humanoid/xeno = owner
	if(xeno.queen_count >= xeno.queen_maximum)
		if(feedback)
			to_chat(xeno, span_warning("У нас уже есть королева."))
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
