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

#define RANGEFINDER_MODE_RANGE "измерение расстояния"
#define RANGEFINDER_MODE_TARGET "целеуказание"

/obj/item/binoculars/range
	name = "rangefinder"
	gender = NEUTER
	actions_types = list(/datum/action/item_action/toggle_rangefinder_mode)
	var/cooldown_duration = 20 SECONDS
	var/obj/effect/overlay/temp/coord
	var/coord_type = /obj/effect/overlay/temp/laser_coordinate
	COOLDOWN_DECLARE(laser_cooldown)
	var/last_x = 0
	var/last_y = 0
	var/last_z = 0
	var/calculate_delay = 10 SECONDS
	var/mode = RANGEFINDER_MODE_RANGE
	var/connected = FALSE

/obj/item/binoculars/range/get_ru_names()
	return alist(
		NOMINATIVE = "бинокль-дальномер",
		GENITIVE = "бинокля-дальномера",
		DATIVE = "биноклю-дальномеру",
		ACCUSATIVE = "бинокль-дальномер",
		INSTRUMENTAL = "биноклем-дальномером",
		PREPOSITIONAL = "бинокле-дальномере",
	)

/obj/item/binoculars/range/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(istype(interacting_with, /atom/movable/screen/fullscreen/cursor_catcher/scope))
		var/atom/movable/screen/fullscreen/cursor_catcher/scope/scope = interacting_with
		calculate_target(scope.given_turf, user)
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/item/binoculars/range/proc/select_mode(mob/user)
	switch(mode)
		if(RANGEFINDER_MODE_RANGE)
			mode = RANGEFINDER_MODE_TARGET
			coord_type = /obj/effect/overlay/temp/laser_target
		if(RANGEFINDER_MODE_TARGET)
			mode = RANGEFINDER_MODE_RANGE
			coord_type = /obj/effect/overlay/temp/laser_coordinate
	balloon_alert(user, mode)

/obj/item/binoculars/range/proc/calculate_target(turf/location, mob/user)
	set waitfor = FALSE
	if(!COOLDOWN_FINISHED(src, laser_cooldown))
		balloon_alert(user, "на перезарядке")
		return
	var/check_dir = get_dir(user, location)
	for(var/turf/position in get_line(user, location))
		if(position.directional_opacity & check_dir)
			balloon_alert(user, "есть препятствие")
			return
	coord = new coord_type(location)
	COOLDOWN_START(src, laser_cooldown, cooldown_duration)
	if(!do_after(user, calculate_delay, location))
		return
	last_x = location.x
	last_y = location.y
	last_z = location.z
	switch(mode)
		if(RANGEFINDER_MODE_RANGE)
			ui_interact(user)
		if(RANGEFINDER_MODE_TARGET)
			on_target_selected(location, user)
	QDEL_NULL(coord)

/obj/item/binoculars/range/proc/on_target_selected(turf/location, mob/user)
	balloon_alert(user, "цель захвачена")
	SEND_SIGNAL(src, COMSIG_RANGEFINDER_TARGET_LOCKED, location, user)

/obj/item/binoculars/range/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Binoculars", "[capitalize(name)]")
		ui.open()

/obj/item/binoculars/range/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/binoculars/range/ui_data(mob/user)
	var/list/data = list()

	data["xcoord"] = last_x
	data["ycoord"] = last_y
	data["zcoord"] = last_z

	return data

/datum/action/item_action/toggle_rangefinder_mode
	name = "Переключить режим"

/datum/action/item_action/toggle_rangefinder_mode/call_effect_proc()
	var/obj/item/binoculars/range/item_target = target
	item_target.select_mode(owner)

#undef RANGEFINDER_MODE_RANGE
#undef RANGEFINDER_MODE_TARGET
