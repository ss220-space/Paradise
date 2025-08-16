/mob/living/silicon
	var/register_alarms = TRUE
	var/datum/ui_module/atmos_control/atmos_control
	var/datum/ui_module/crew_monitor/crew_monitor
	var/datum/ui_module/law_manager/law_manager
	var/datum/ui_module/power_monitor/digital/power_monitor
	var/obj/item/areaeditor/blueprints/cyborg/blueprints

/mob/living/silicon
	var/list/silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_open_gps,
		/mob/living/silicon/proc/subsystem_law_manager
	)

/mob/living/silicon/decoy
	silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_law_manager
	)

/mob/living/silicon/ai
	silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_open_gps,
		/mob/living/silicon/proc/subsystem_atmos_control,
		/mob/living/silicon/proc/subsystem_crew_monitor,
		/mob/living/silicon/proc/subsystem_law_manager,
		/mob/living/silicon/proc/subsystem_power_monitor
	)

/mob/living/silicon/robot
	var/datum/ui_module/robot_self_diagnosis/self_diagnosis
	silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_open_gps,
		/mob/living/silicon/robot/proc/self_diagnosis,
		/mob/living/silicon/proc/subsystem_law_manager
	)

/mob/living/silicon/robot/drone
	silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_open_gps,
		/mob/living/silicon/robot/proc/self_diagnosis,
		/mob/living/silicon/proc/subsystem_law_manager,
		/mob/living/silicon/proc/subsystem_power_monitor
	)

/mob/living/silicon/robot/cogscarab
	silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_open_gps,
		/mob/living/silicon/robot/proc/self_diagnosis,
		/mob/living/silicon/proc/subsystem_law_manager
	)

/mob/living/silicon/robot/syndicate
	register_alarms = 0

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
/mob/living/silicon/proc/subsystem_atmos_control()
	set category = STATPANEL_SUBSYSTEMS
	set name = "Контроль атмосферы"

	atmos_control.ui_interact(usr)

/********************
*	Crew Monitor	*
********************/
/mob/living/silicon/proc/subsystem_crew_monitor()
	set category = STATPANEL_SUBSYSTEMS
	set name = "Монитор экипажа"
	crew_monitor.ui_interact(usr)

/****************
*	Law Manager	*
****************/
/mob/living/silicon/proc/subsystem_law_manager()
	set name = "Диспетчер законов"
	set category = STATPANEL_SUBSYSTEMS

	law_manager.ui_interact(usr)

/********************
*	Power Monitor	*
********************/
/mob/living/silicon/proc/subsystem_power_monitor()
	set category = STATPANEL_SUBSYSTEMS
	set name = "Монитор мощности"

	power_monitor.ui_interact(usr)

/********************
*	GPS	*
********************/
/mob/living/silicon/proc/subsystem_open_gps()
	set name = "GPS"
	set category = STATPANEL_SUBSYSTEMS

	gps.ui_interact(src)

/********************
*	Blueprints	*
********************/
/mob/living/silicon/proc/subsystem_blueprints()
	set name = "Чертежи станции"
	set category = STATPANEL_SUBSYSTEMS

	blueprints.interact_prints(src)

/mob/living/silicon/robot/proc/self_diagnosis()
	set category = STATPANEL_ROBOTCOMMANDS
	set name = "Самодиагностика"

	if(!is_component_functioning("diagnosis unit"))
		to_chat(src, span_warning("Your self-diagnosis component isn't functioning."))
		return

	self_diagnosis.ui_interact(src)
