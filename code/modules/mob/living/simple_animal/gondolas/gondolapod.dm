/mob/living/simple_animal/pet/gondola/gondolapod
	name = "gondola"
	real_name = "gondola"
	desc = "Бесшумный ходок. Кажется, это сотрудник агентства доставки."
	icon = 'icons/obj/supplypods.dmi'
	icon_state = "gondola"
	icon_living = "gondola"
	SET_BASE_PIXEL(-16, -5) //2x2 sprite
	layer = TABLE_LAYER //so that deliveries dont appear underneath it

	///Boolean on whether the pod is currently open, and should appear such.
	var/opened = FALSE
	///The supply pod attached to the gondola, that actually holds the contents of our delivery.
	var/obj/structure/closet/supplypod/centcompod/linked_pod
	
	///Static list of actions the gondola is given on creation, and taken away when it successfully delivers.
	var/static/list/gondola_delivering_actions = list(
		/datum/action/innate/deliver_gondola_package,
		/datum/action/innate/check_gondola_contents,
	)

/mob/living/simple_animal/pet/gondola/gondolapod/Initialize(mapload, pod)
	linked_pod = pod || new(src)
	name = linked_pod.name
	desc = linked_pod.desc
	if(!linked_pod.stay_after_drop || !linked_pod.opened)
		grant_actions_by_list(gondola_delivering_actions)
	return ..()

/mob/living/simple_animal/pet/gondola/gondolapod/death(gibbed)
	QDEL_NULL(linked_pod) //Will cause the open() proc for the linked supplypod to be called with the "broken" parameter set to true, meaning that it will dump its contents on death
	return ..()

/mob/living/simple_animal/pet/gondola/gondolapod/create_gondola()
	return

/mob/living/simple_animal/pet/gondola/gondolapod/update_overlays()
	. = ..()
	if(opened)
		. += "[icon_state]_open"

/mob/living/simple_animal/pet/gondola/gondolapod/examine(mob/user)
	. = ..()
	if (contents.len)
		. += span_notice("Похоже, посылка еще не доставлена.")
	else
		. += span_notice("Судя по всему, доставку уже осуществили.")

/mob/living/simple_animal/pet/gondola/gondolapod/setOpened()
	opened = TRUE
	layer = initial(layer)
	update_appearance()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/, setClosed)), 5 SECONDS)

/mob/living/simple_animal/pet/gondola/gondolapod/setClosed()
	opened = FALSE
	layer = OBJ_LAYER
	update_appearance()

///Opens the gondola pod and delivers its package, one-time use as it removes all delivery-related actions.
/datum/action/innate/deliver_gondola_package
	name = "Доставить"
	desc = "Откройте хранилище и освободите все содержимое, хранящееся внутри."
	button_icon_state = "arrow"

/datum/action/innate/deliver_gondola_package/Trigger(left_click)
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/pet/gondola/gondolapod/gondola_owner = owner
	gondola_owner.linked_pod.open_pod(gondola_owner, forced = TRUE)
	for(var/datum/action/actions as anything in gondola_owner.actions)
		if(actions.type in gondola_owner.gondola_delivering_actions)
			actions.Remove(gondola_owner)
	return TRUE

///Checks the contents of the gondola and lets them know what they're holding.
/datum/action/innate/check_gondola_contents
	name = "Проверить содержимое"
	desc = "Посмотрите, сколько предметов вы сейчас держите в капсуле."
	button_icon_state = "storage"

/datum/action/innate/check_gondola_contents/Trigger(left_click)
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/pet/gondola/gondolapod/gondola_owner = owner
	var/total = gondola_owner.contents.len
	if (total)
		to_chat(gondola_owner, span_notice("You detect [total] object\s within your incredibly vast belly."))
	else
		to_chat(gondola_owner, span_notice("A closer look inside yourself reveals... nothing."))
	return TRUE
