/// A pair of binoculars. Wield them in both hands to look far away towards your cursor.
/obj/item/binoculars
	name = "binoculars"
	desc = "Используется для наблюдения за объектами на дальних расстояниях."
	gender = MALE
	icon_state = "binoculars"
	item_state = "binoculars"
	slot_flags = ITEM_SLOT_NECK
	w_class = WEIGHT_CLASS_SMALL
	force = 8

/obj/item/binoculars/get_ru_names()
	return alist(
		NOMINATIVE = "бинокль",
		GENITIVE = "бинокля",
		DATIVE = "биноклю",
		ACCUSATIVE = "бинокль",
		INSTRUMENTAL = "биноклем",
		PREPOSITIONAL = "бинокле",
	)

/obj/item/binoculars/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/two_handed, \
		force_wielded = 12, \
		force_unwielded = 8, \
		wield_callback = CALLBACK(src, PROC_REF(on_wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)) \
	)
	AddComponent(/datum/component/scope, range_modifier = 2.5, zoom_method = ZOOM_METHOD_WIELD, severity = SEVERITY_ITEM)

/obj/item/binoculars/Destroy()
	if(ismob(loc))
		var/mob/user = loc
		user.remove_movespeed_modifier(/datum/movespeed_modifier/binocs_wielded)
	return ..()

/obj/item/binoculars/proc/on_wield(obj/item/source, mob/user)
	if(!ismob(user))
		return
	user.visible_message(
		span_notice("[user] подносит [declent_ru(ACCUSATIVE)] к глазам."),
		span_notice("Вы подносите [declent_ru(ACCUSATIVE)] к глазам."),
	)
	update_icon(UPDATE_ICON_STATE)
	user.update_held_items()
	user.add_movespeed_modifier(/datum/movespeed_modifier/binocs_wielded)

/obj/item/binoculars/proc/on_unwield(obj/item/source, mob/user)
	if(!ismob(user))
		return
	user.visible_message(
		span_notice("[user] опускает [declent_ru(ACCUSATIVE)]."),
		span_notice("Вы опускаете [declent_ru(ACCUSATIVE)]."),
	)
	update_icon(UPDATE_ICON_STATE)
	user.update_held_items()
	user.remove_movespeed_modifier(/datum/movespeed_modifier/binocs_wielded)

/obj/item/binoculars/update_icon_state()
	. = ..()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		item_state = "binoculars_wielded"
		return
	item_state = "binoculars"
