/datum/game_mode
	var/list/datum/mind/space_ninjas = list()

/datum/game_mode/space_ninja
	name = "Space Ninja"
	config_tag = "space-ninja"
	required_players = 25
	required_enemies = 1
	recommended_enemies = 1
	var/finished = FALSE
	var/but_wait_theres_more = FALSE
	var/datum/mind/pre_ninja


/datum/game_mode/space_ninja/announce()
	to_chat(world, "<B>>Текущий игровой режим — Космический Ниндзя!</B>")
	to_chat(world, "<B>На станцию проник опасный наёмник из клана Паука. Более известный как Космический Ниндзя. Какие бы он не преследовал цели, станция в опасности!</B>")


/datum/game_mode/space_ninja/can_start()
	if(!..())
		return FALSE
	if(!length(GLOB.ninjastart))
		stack_trace("A starting location for ninja could not be found, please report this bug!")
		return FALSE
	var/list/datum/mind/possible_ninjas = get_players_for_role(ROLE_NINJA)
	if(!length(possible_ninjas))
		return FALSE
	pre_ninja = pick(possible_ninjas)
	return TRUE


/datum/game_mode/space_ninja/pre_setup()
	space_ninjas |= pre_ninja
	pre_ninja.assigned_role = SPECIAL_ROLE_SPACE_NINJA //So they aren't chosen for other jobs.
	pre_ninja.special_role = SPECIAL_ROLE_SPACE_NINJA
	pre_ninja.offstation_role = TRUE //ninja can't be targeted as a victim for some pity traitors
	pre_ninja.set_original_mob(pre_ninja.current)
	pre_ninja?.current.loc = pick(GLOB.ninjastart)
	..()
	return TRUE


/datum/game_mode/space_ninja/post_setup()
	var/datum/antagonist/ninja/ninja_datum = new
	ninja_datum.change_species(pre_ninja.current)
	pre_ninja?.add_antag_datum(ninja_datum)
	..()


// Checks if the game should end due to all Ninjas being dead, or MMI'd/Borged
/datum/game_mode/space_ninja/check_finished()
	var/ninjas_alive = 0

	for(var/datum/mind/ninja in space_ninjas)
		if(!iscarbon(ninja.current))
			continue
		if(ninja.current.stat==DEAD)
			continue
		if(istype(ninja.current, /obj/item/mmi)) // ninja is in an MMI, don't count them as alive
			continue
		ninjas_alive++

	if(ninjas_alive || but_wait_theres_more)
		return ..()
	else
		finished = TRUE
		return TRUE


/datum/game_mode/space_ninja/declare_completion(ragin = FALSE)
	if(finished && !ragin)
		SSticker.mode_result = "ninja loss - ninja killed"
		to_chat(world, span_warning("<FONT size = 3><B> Ниндзя был[(space_ninjas.len>1)?"и":""] убит[(space_ninjas.len>1)?"ы":""] экипажем! Клан Паука ещё не скоро отмоется от этого позора!</B></FONT>"))
	..()
	return TRUE


/datum/game_mode/proc/auto_declare_completion_ninja()
	if(!length(space_ninjas))
		return FALSE

	var/text = "<br><font size=3><b>Космическим[(length(space_ninjas) > 1)?"и":""] Ниндзя был[(length(space_ninjas) > 1)?"и":""]:</b></font>"

	for(var/datum/mind/ninja in space_ninjas)

		text += "<br><b>[ninja.get_display_key()]</b> был <b>[ninja.name]</b> ("
		if(ninja.current)
			if(ninja.current.stat == DEAD)
				text += "Умер"
			else
				text += "Выжил"
			if(ninja.current.real_name != ninja.name)
				text += " как <b>[ninja.current.real_name]</b>"
		else
			text += "Тело уничтожено"
		text += ")"
		text += "<br>"


		var/datum/antagonist/ninja/ninja_datum = ninja.has_antag_datum(/datum/antagonist/ninja)
		if(ninja_datum)
			text += "Выбранные способности: [ninja_datum.purchased_abilities]"

		var/count = 1
		var/ninjawin = TRUE
		for(var/datum/objective/objective in ninja.get_all_objectives())
			if(objective.check_completion())
				text += "<br><B>Цель #[count]</B>: [objective.explanation_text] <font color='green'><B>Успех!</B></font>"
				SSblackbox.record_feedback("nested tally", "ninja_objective", 1, list("[objective.type]", "SUCCESS"))
			else
				text += "<br><B>Цель #[count]</B>: [objective.explanation_text] <font color='red'>Провал.</font>"
				SSblackbox.record_feedback("nested tally", "ninja_objective", 1, list("[objective.type]", "FAIL"))
				ninjawin = FALSE
			count++

		if(ninja.current && ninja.current.stat != DEAD && ninjawin)
			text += "<br><font color='green'><B>Ниндзя успешно выполнил свои задачи!</B></font>"
			SSblackbox.record_feedback("tally", "ninja_success", 1, "SUCCESS")
		else
			text += "<br><font color='red'><B>Ниндзя провалился!</B></font>"
			SSblackbox.record_feedback("tally", "ninja_success", 1, "FAIL")
		text += "<br>"

	to_chat(world, text)
	return TRUE

