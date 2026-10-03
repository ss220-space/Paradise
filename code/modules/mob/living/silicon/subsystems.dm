/mob/living/silicon/proc/init_subsystems()
	atmos_control	= new(src)
	crew_monitor	= new(src)
	law_manager		= new(src)
	power_monitor	= new(src)
	gps				= new(src)
	blueprints		= new(src)

/mob/living/silicon/decoy/init_subsystems()
	law_manager = new(src)
	return

/mob/living/silicon/robot/init_subsystems()
	. = ..()
	self_diagnosis  = new(src)

/********************
*	Atmos Control	*
********************/
GAME_VERB_PROC(/mob/living/silicon, subsystem_atmos_control, "Контроль атмосферы", VERB_CATEGORY_SUBSYSTEMS)

	atmos_control.ui_interact(usr)

/********************
*	Crew Monitor	*
********************/
GAME_VERB_PROC(/mob/living/silicon, subsystem_crew_monitor, "Монитор экипажа", VERB_CATEGORY_SUBSYSTEMS)
	crew_monitor.ui_interact(usr)

/****************
*	Law Manager	*
****************/
GAME_VERB_PROC(/mob/living/silicon, subsystem_law_manager, "Диспетчер законов", VERB_CATEGORY_SUBSYSTEMS)

	law_manager.ui_interact(usr)

/********************
*	Power Monitor	*
********************/
GAME_VERB_PROC(/mob/living/silicon, subsystem_power_monitor, "Монитор мощности", VERB_CATEGORY_SUBSYSTEMS)

	power_monitor.ui_interact(usr)

/********************
*	GPS	*
********************/
GAME_VERB_PROC(/mob/living/silicon, subsystem_open_gps, "GPS", VERB_CATEGORY_SUBSYSTEMS)

	gps.ui_interact(src)

/********************
*	Blueprints	*
********************/
GAME_VERB_PROC(/mob/living/silicon, subsystem_blueprints, "Чертежи станции", VERB_CATEGORY_SUBSYSTEMS)

	blueprints.interact_prints(src)

GAME_VERB_PROC(/mob/living/silicon/robot, self_diagnosis, "Самодиагностика", VERB_CATEGORY_ROBOTCOMMANDS)

	if(!is_component_functioning("diagnosis unit"))
		to_chat(src, span_warning("Your self-diagnosis component isn't functioning."))
		return

	self_diagnosis.ui_interact(src)
