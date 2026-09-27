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
	to_chat(world, "<b>>Текущий игровой режим — Космический Ниндзя!</b>")
	to_chat(world, "<b>На станцию проник опасный наёмник из клана Паука. Более известный как Космический Ниндзя. Какие бы он не преследовал цели, станция в опасности!</b>")

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

	for(var/datum/mind/ninja in get_antag_minds(/datum/antagonist/ninja))
		if(!iscarbon(ninja.current))
			continue
		if(ninja.current.stat == DEAD)
			continue
		if(is_mmi(ninja.current)) // ninja is in an MMI, don't count them as alive
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
		var/ninja_count = length(get_antag_minds(/datum/antagonist/ninja))
		to_chat(world, span_warning(span_bold(span_fontsize3(" Ниндзя был[ninja_count > 1 ? "и" : ""] убит[ninja_count > 1 ? "ы" : ""] экипажем! Клан Паука ещё не скоро отмоется от этого позора!"))))
	..()
	return TRUE


