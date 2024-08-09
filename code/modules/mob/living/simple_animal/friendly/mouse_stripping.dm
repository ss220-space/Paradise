GLOBAL_LIST_INIT(strippable_mouse_items, create_strippable_list(list(
	/datum/strippable_item/mouse_jet,
	/datum/strippable_item/pet_collar
)))

/datum/strippable_item/mouse_jet
	key = STRIPPABLE_ITEM_BACK

/datum/strippable_item/mouse_jet/get_item(atom/source)
	var/mob/living/simple_animal/mouse/mouse_source = source
	return istype(mouse_source) ? mouse_source.jetpack : null

/datum/strippable_item/mouse_jet/try_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!istype(equipping, /obj/item/mouse_jetpack))
		to_chat(user, span_warning("You can't figure out how to do something with \the [equipping] and [src]."))
		return FALSE

	return TRUE

/datum/strippable_item/mouse_jet/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/obj/item/mouse_jetpack/jet = equipping
	if(!istype(jet))
		return

	var/mob/living/simple_animal/mouse/mouse_source = source
	if(!istype(mouse_source))
		return

	mouse_source.place_on_back(equipping, user)

/datum/strippable_item/mouse_jet/finish_unequip(atom/source, mob/user)
	var/mob/living/simple_animal/mouse/mouse_source = source
	if(!istype(mouse_source))
		return

	mouse_source.remove_from_back(user)
