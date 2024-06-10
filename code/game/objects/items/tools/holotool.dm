/*
Holotool. All instruments in one object
*/
/datum/action/item_action/change_ht_color
	name = "Change Holotool Color"

/obj/item/holotool
	name = "experimental holotool"
	desc = "A highly experimental holographic tool projector."
	icon = 'icons/obj/holotool.dmi'
	icon_state = "holotool"
	slot_flags = ITEM_SLOT_BELT
	usesound = 'sound/items/pshoom.ogg'
	actions_types = list(/datum/action/item_action/change_ht_color)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	w_class = WEIGHT_CLASS_SMALL

	var/datum/holotool_mode/current_tool
	var/list/available_modes
	var/list/mode_names
	var/list/radial_modes
	item_state_color = "#48D1CC" //mediumturquoise
	var/emagged = FALSE

/obj/item/holotool/examine(mob/user)
	. = ..()
	. += span_notice("It is currently set to [current_tool ? current_tool.name : "'off'"] mode.")

/obj/item/holotool/ui_action_click(mob/user, datum/action/action)
	var/C = input(user, "Select Color", "Select color", "#48D1CC") as null|color
	if(!C || QDELETED(src))
		return
	item_state_color = C
	update_state(user)

/obj/item/holotool/proc/switch_tool(mob/user, datum/holotool_mode/mode)
	if(!mode || !istype(mode))
		return
	if(current_tool)
		current_tool.on_unset(src)
	current_tool = mode
	current_tool.on_set(src)
	playsound(loc, 'sound/items/pshoom.ogg', get_clamped_volume(), 1, -1)
	update_state(user)

/obj/item/holotool/proc/update_state(mob/user)
	update_icon()
	update_equipped_item(update_speedmods = FALSE)
	if(current_tool)
		if(istype(current_tool, /datum/holotool_mode/off))
			set_light(0)
		else
			set_light(3, null, item_state_color)

/obj/item/holotool/update_icon_state()
	if(current_tool)
		item_state = current_tool.name
	else
		item_state = "holotool"
		icon_state = "holotool"

/obj/item/holotool/update_overlays()
	. = ..()
	cut_overlays()
	if(current_tool)
		var/mutable_appearance/holo_item = mutable_appearance(icon, current_tool.name)
		holo_item.color = item_state_color
		. += holo_item

/obj/item/holotool/proc/update_listing()
	LAZYCLEARLIST(available_modes)
	LAZYCLEARLIST(radial_modes)
	LAZYCLEARLIST(mode_names)
	for(var/A in subtypesof(/datum/holotool_mode))
		var/datum/holotool_mode/M = new A
		if(M.can_be_used(src))
			LAZYADD(available_modes, M)
			LAZYSET(mode_names, M.name, M)
			var/image/holotool_img = image(icon = icon, icon_state = icon_state)
			var/image/tool_img = image(icon = icon, icon_state = M.name)
			tool_img.color = item_state_color
			holotool_img.overlays += tool_img
			LAZYSET(radial_modes, M.name, holotool_img)
		else
			qdel(M)

/obj/item/holotool/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/holotool/attack_self(mob/user)
	update_listing()
	var/chosen = show_radial_menu(user, src, radial_modes, custom_check = CALLBACK(src, PROC_REF(check_menu), user))
	if(!check_menu(user))
		return
	if(chosen)
		var/new_tool = LAZYACCESS(mode_names, chosen)
		if(new_tool)
			switch_tool(user, new_tool)

/obj/item/holotool/emag_act(mob/user)
	if(emagged)
		return
	to_chat(user, span_danger("ZZT- ILLEGAL BLUEPRINT UNLOCKED- CONTACT !#$@^%$# NANOTRASEN SUPPORT-@*%$^%!"))
	do_sparks(5, 0, src)
	emagged = TRUE

// holotool modes

/datum/holotool_mode
	var/name = "???"
	var/sound
	var/behavior
	var/speed = 0.5 //upgraded instruments are 0.25 speed

/datum/holotool_mode/proc/can_be_used(var/obj/item/holotool/H)
	return TRUE

/datum/holotool_mode/proc/on_set(var/obj/item/holotool/H)
	H.usesound = sound ? sound :  'sound/items/pshoom.ogg'
	H.toolspeed = speed ? speed : 1
	H.tool_behaviour = behavior ? behavior : null

/datum/holotool_mode/proc/on_unset(var/obj/item/holotool/H)
	H.usesound = initial(H.usesound)
	H.toolspeed = initial(H.toolspeed)
	H.tool_behaviour = initial(H.tool_behaviour)

////////////////////////////////////////////////

/datum/holotool_mode/screwdriver //чек
	name = "holo-screwdriver"
	sound = 'sound/items/pshoom.ogg'
	behavior = TOOL_SCREWDRIVER

/datum/holotool_mode/crowbar //чек
	name = "holo-crowbar"
	sound = 'sound/weapons/sonic_jackhammer.ogg'
	behavior = TOOL_CROWBAR

/datum/holotool_mode/multitool //чек
	name = "holo-multitool"
	sound = 'sound/weapons/tap.ogg'
	behavior = TOOL_MULTITOOL

/datum/holotool_mode/wrench
	name = "holo-wrench"
	sound ='sound/effects/empulse.ogg'
	behavior = TOOL_WRENCH

/datum/holotool_mode/wirecutters //чек
	name = "holo-wirecutters"
	sound = 'sound/items/jaws_cut.ogg'
	behavior = TOOL_WIRECUTTER

/datum/holotool_mode/welder
	name = "holo-welder"
	sound = list('sound/items/welder.ogg', 'sound/items/welder2.ogg')//so it actually gives the expected feedback from welding
	behavior = TOOL_WELDER

/datum/holotool_mode/knife
	name = "holo-knife"
	sound = 'sound/weapons/blade1.ogg'

/datum/holotool_mode/off
	name = "off"
	sound =  'sound/items/jaws_cut.ogg'

/datum/holotool_mode/knife/can_be_used(var/obj/item/holotool/H)
	return H.emagged

/datum/holotool_mode/knife/on_set(var/obj/item/holotool/H)
	..()
	H.sharp = TRUE
	H.force = 17
	H.attack_verb = list("sliced", "torn", "cut")
	H.armour_penetration = 45
	H.embed_chance = 40
	H.embedded_fall_chance = 0
	H.embedded_pain_multiplier = 5
	H.hitsound = 'sound/weapons/blade1.ogg'

/datum/holotool_mode/knife/on_unset(var/obj/item/holotool/H)
	..()
	H.sharp = initial(H.sharp)
	H.force = initial(H.force)
	H.attack_verb = initial(H.attack_verb)
	H.armour_penetration = initial(H.armour_penetration)
	H.embed_chance = initial(H.embed_chance)
	H.embedded_fall_chance = initial(H.embedded_fall_chance)
	H.embedded_pain_multiplier = initial(H.embedded_pain_multiplier)
	H.hitsound = initial(H.hitsound)
