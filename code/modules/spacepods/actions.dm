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

/datum/action/innate/pod/pod_panel
	name = "Панель управления"
	button_icon_state = "control_panel"

/datum/action/innate/pod/pod_panel/Activate()
	if(!pod)
		return
	pod.control_panels.ui_interact(usr)


#define POD_MISC_ACTION_PODDOORS "Открыть ближайший шлюз"
#define POD_MISC_ACTION_TOGGLE_LIGHT "Переключить фонари челнока"
#define POD_MISC_ACTION_SEARCH_SEAT "Искать предметы под креслом"

/datum/action/innate/pod/misc
	name = "Дополнительные действия"
	button_icon_state = "mech_misc"

/datum/action/innate/pod/misc/Activate()
	if(!pod)
		return
	var/static/list/choices = list(POD_MISC_ACTION_PODDOORS, POD_MISC_ACTION_TOGGLE_LIGHT, POD_MISC_ACTION_SEARCH_SEAT)
	var/choice = tgui_input_list(owner, "Выберите действие", "Действие в челноке", choices)
	if(choice == null)
		return
	switch(choice)
		if(POD_MISC_ACTION_PODDOORS)
			pod.toggle_doors(owner)
			return
		if(POD_MISC_ACTION_TOGGLE_LIGHT)
			pod.toggle_lights(owner)
			return
		if(POD_MISC_ACTION_SEARCH_SEAT)
			pod.check_seat(owner)
			return

#undef POD_MISC_ACTION_PODDOORS
#undef POD_MISC_ACTION_TOGGLE_LIGHT
#undef POD_MISC_ACTION_SEARCH_SEAT
