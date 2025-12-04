/obj/item/holotool
	name = "experimental holotool"
	desc = "Экспериментальный прибор, использующий технологии твёрдого света для проецирования голограмм инженерных инструментов. Произведено \"Нанотрейзен\"."
	icon = 'icons/obj/holotool.dmi'
	icon_state = "holotool"
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	usesound = 'sound/items/pshoom.ogg'
	actions_types = list(/datum/action/item_action/change_holotool_color)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	w_class = WEIGHT_CLASS_SMALL
	item_state_color = COLOR_MEDIUM_TURQUOISE
	/// Current active tool mode for the holotool
	var/datum/holotool_mode/current_mode
	/// List of available tool modes for this holotool
	var/list/available_modes
	/// Associative list: mode_id -> mode object
	var/list/modes_by_id
	/// Data for radial menu display of modes
	var/list/radial_modes
	item_state_color = "#48D1CC" // mediumturquoise

/obj/item/holotool/get_ru_names()
	return list(
		NOMINATIVE = "экспериментальный голотул",
		GENITIVE = "экспериментального голотула",
		DATIVE = "экспериментальному голотулу",
		ACCUSATIVE = "экспериментальный голотул",
		INSTRUMENTAL = "экспериментальным голотулом",
		PREPOSITIONAL = "экспериментальном голотуле"
	)

/obj/item/holotool/examine(mob/user)
	. = ..()
	if(current_mode)
		. += span_notice("Текущий режим: <b>[current_mode.name]</b>.")
	else
		. += span_notice("Текущий режим: <b>выключено</b>.")

/obj/item/holotool/ui_action_click(mob/user, datum/action/action)
	var/new_color = tgui_input_color(user, "Выберите цвет:", "Выбор цвета голотула", COLOR_MEDIUM_TURQUOISE)
	if(!new_color || QDELETED(src))
		return
	item_state_color = new_color
	update_state(user)

/obj/item/holotool/proc/switch_tool(mob/user, datum/holotool_mode/mode)
	if(!mode || !istype(mode))
		return

	if(current_mode)
		current_mode.on_unset(src)

	current_mode = mode
	current_mode.on_set(src)
	playsound(loc, 'sound/items/pshoom.ogg', get_clamped_volume(), TRUE, -1)
	balloon_alert(user, "режим — [mode.name]")
	update_state(user)

/obj/item/holotool/proc/update_state(mob/user)
	update_icon()
	update_equipped_item(update_speedmods = FALSE)
	if(!current_mode)
		return

	if(istype(current_mode, /datum/holotool_mode/off))
		set_light(0)
	else
		set_light(3, null, item_state_color)

/obj/item/holotool/update_icon_state()
	if(current_mode)
		item_state = current_mode.icon_id
	else
		item_state = "holotool"
		icon_state = "holotool"

/obj/item/holotool/update_overlays()
	. = ..()
	cut_overlays()
	if(current_mode)
		var/mutable_appearance/holo_item = mutable_appearance(icon, current_mode.icon_id)
		holo_item.color = item_state_color
		. += holo_item

/obj/item/holotool/proc/update_listing()
	LAZYCLEARLIST(available_modes)
	LAZYCLEARLIST(radial_modes)
	LAZYCLEARLIST(modes_by_id)

	for(var/mode_type in subtypesof(/datum/holotool_mode))
		var/datum/holotool_mode/mode = new mode_type

		if(!mode.can_be_used(src))
			qdel(mode)
			continue

		LAZYADD(available_modes, mode)
		LAZYSET(modes_by_id, mode.name, mode)

		var/image/holotool_img = image(icon = icon, icon_state = icon_state)
		var/image/tool_img = image(icon = icon, icon_state = mode.icon_id)
		tool_img.color = item_state_color
		holotool_img.overlays += tool_img
		LAZYSET(radial_modes, mode.name, holotool_img)

/obj/item/holotool/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE

	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE

	return TRUE

/obj/item/holotool/attack_self(mob/user)
	update_listing()
	var/chosen_id = show_radial_menu(user, src, radial_modes, custom_check = CALLBACK(src, PROC_REF(check_menu), user))

	if(!check_menu(user))
		return

	if(!chosen_id)
		return

	var/datum/holotool_mode/selected_mode = LAZYACCESS(modes_by_id, chosen_id)
	if(selected_mode)
		switch_tool(user, selected_mode)

/obj/item/holotool/emag_act(mob/user)
	if(emagged)
		return

	balloon_alert(user, "протоколы безопасности взломаны")
	balloon_alert_to_viewers("искрит и жужжит!", "протоколы безопасности взломаны")
	do_sparks(5, FALSE, src)
	emagged = TRUE
