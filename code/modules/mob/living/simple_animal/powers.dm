/datum/action/innate/hide
	name = "Спрятаться"
	desc = "Позволяет прятаться под столами и некоторыми объектами."
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	button_icon_state = "mouse_gray_sleep"
	var/layer_to_change_from = MOB_LAYER
	var/layer_to_change_to = TURF_LAYER + 0.2


/datum/action/innate/hide/Grant(mob/user)
	. = ..()
	if(!.)
		return

	if(isanimal(owner))
		var/mob/living/simple_animal/animal = owner
		if(animal.pass_door_while_hidden)
			desc = "[desc] Прячась, вы можете пролезть под незаболтированными шлюзами."


/datum/action/innate/hide/Activate()
	active = TRUE
	update_layer()
	owner.visible_message(span_notice("<b>[owner] быстро прижимается к земле!</b>"), span_notice("Вы теперь прячетесь."))
	var/mob/living/simple_animal/simplemob = owner
	if(isanimal(simplemob))
		simplemob.hidden = TRUE
	if(istype(simplemob) && simplemob.pass_door_while_hidden || isdrone(simplemob))
		simplemob.pass_flags |= PASSDOOR


/datum/action/innate/hide/Deactivate()
	active = FALSE
	update_layer()
	owner.visible_message(span_notice("[owner] осторожно выглядывает..."), span_notice("Вы перестали прятаться."))
	var/mob/living/simple_animal/simplemob = owner
	if(isanimal(simplemob))
		simplemob.hidden = FALSE
	if(istype(simplemob) && simplemob.pass_door_while_hidden || isdrone(simplemob))
		simplemob.pass_flags &= ~PASSDOOR


/datum/action/innate/hide/proc/update_layer()
	owner.layer = active ? layer_to_change_to : layer_to_change_from


/datum/action/innate/hide/drone
	desc = "Позволяет прятаться под столами и некоторыми объектами. В скрытом состоянии можно пролезать под незаболтированными шлюзами."
	button_icon_state = "repairbot"


/datum/action/innate/hide/drone/cogscarab
	layer_to_change_to = LOW_OBJ_LAYER


/datum/action/innate/hide/alien_larva
	desc = "Позволяет прятаться под столами и некоторыми объектами."
	background_icon_state = "bg_alien"
	button_icon_state = "alien_hide"
	layer_to_change_to = ABOVE_NORMAL_TURF_LAYER


/datum/action/innate/drop_jetpack
	name = "Сбросить джетпак"
	desc = "Позволяет избавиться от этой шумной штуки на спине."
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/obj/tank.dmi'
	button_icon_state = "jetpack_mouse"

/datum/action/innate/drop_jetpack/Activate()
	var/mob/living/simple_animal/mouse/mouse = owner
	if(mouse.jetpack)
		INVOKE_ASYNC(mouse, TYPE_PROC_REF(/mob/living/simple_animal/mouse, delayed_jetpack_remove))
