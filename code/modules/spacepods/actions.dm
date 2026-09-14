/datum/action/innate/pod
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	button_icon = 'icons/mob/actions/actions_mecha.dmi'
	var/obj/spacepod/pod

/datum/action/innate/pod/Grant(mob/living/target, obj/spacepod/spacepod)
	if(spacepod)
		pod = spacepod
	. = ..()

/datum/action/innate/pod/Destroy()
	pod = null
	return ..()

/datum/action/innate/pod/pod_eject
	name = "Выйти из челнока"
	button_icon_state = "mech_eject"

/datum/action/innate/pod/pod_eject/Activate()
	pod.exit_pod(owner)

/datum/action/innate/pod/pod_toggle_lights
	name = "Переключить прожектор"
	desc = "Переключает мощный осветительный модуль."
	button_icon_state = "mech_lights_off"

/datum/action/innate/pod/pod_toggle_lights/Activate()
	if(!owner || !pod || pod.pilot != owner)
		return
	// pod.toggleLights(owner)
	button_icon_state = "mech_lights_[pod.lights ? "on" : "off"]"
	UpdateButtonIcon()

/datum/action/innate/pod/pod_fire
	name = "Стрелять"
	button_icon_state = "mech_zoom_off"

/datum/action/innate/pod/pod_fire/Activate()
	if(!owner || !pod || pod.pilot != owner)
		return
	// pod.fireWeapon(owner)

/datum/action/innate/pod/pod_panel
	name = "Панель управления"
	button_icon_state = "mech_misc"

/datum/action/innate/pod/pod_panel/Activate()
	if(!owner || !pod || pod.pilot != owner)
		return
	pod.control_panels.ui_interact(owner)

	// var/misc_system = tgui_input_list(owner, "Выберите систему", "Управление челноком", POD_MISC_SYSTEMS)
	// if(!misc_system)
	// 	return
	// if(!owner || !pod || pod.pilot != owner) //we check twice because of input
	// 	return
	// switch(misc_system)
	// 	if(POD_MISC_LOCK_DOOR)
	// 		pod.lock_pod(owner)
	// 	if(POD_MISC_POD_DOORS)
	// 		pod.toggleDoors(owner)
	// 	if(POD_MISC_UNLOAD_CARGO)
	// 		pod.unload(owner)
	// 	if(POD_MISC_CHECK_SEAT)
	// 		pod.checkSeat(owner)
	// 	if(POD_MISC_LOCATOR_SKAN)
	// 		pod.startScan(owner)
