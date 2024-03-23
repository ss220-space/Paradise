/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/
/obj/screen
	name = ""
	icon = 'icons/mob/screen_gen.dmi'
	layer = HUD_LAYER
	plane = HUD_PLANE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.
	var/datum/hud/hud = null
	appearance_flags = NO_CLIENT_COLOR

/obj/screen/take_damage()
	return

/obj/screen/Destroy()
	master = null
	hud = null
	return ..()

/obj/screen/proc/component_click(obj/screen/component_button/component, params)
	return

/obj/screen/text
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480


/obj/screen/close
	name = "close"
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE

/obj/screen/close/Click()
	if(master)
		if(istype(master, /obj/item/storage))
			var/obj/item/storage/S = master
			S.close(usr)
	return TRUE


/obj/screen/drop
	name = "accurate drop"
	icon_state = "act_drop"

/obj/screen/drop/Click()
	if(usr.stat == CONSCIOUS)
		usr.drop_item_ground(usr.get_active_hand(), ignore_pixel_shift = TRUE)


/obj/screen/grab
	name = "grab"

/obj/screen/grab/Click()
	var/obj/item/grab/G = master
	G.s_click(src)
	return TRUE

/obj/screen/grab/attack_hand()
	return

/obj/screen/grab/attackby()
	return

/obj/screen/act_intent
	name = "intent"
	icon_state = "help"
	screen_loc = ui_acti

/obj/screen/act_intent/Click(location, control, params)
	if(ishuman(usr))
		var/_x = text2num(params2list(params)["icon-x"])
		var/_y = text2num(params2list(params)["icon-y"])
		if(_x<=16 && _y<=16)
			usr.a_intent_change(INTENT_HARM)
		else if(_x<=16 && _y>=17)
			usr.a_intent_change(INTENT_HELP)
		else if(_x>=17 && _y<=16)
			usr.a_intent_change(INTENT_GRAB)
		else if(_x>=17 && _y>=17)
			usr.a_intent_change(INTENT_DISARM)
	else
		usr.a_intent_change("right")

/obj/screen/act_intent/alien
	icon = 'icons/mob/screen_alien.dmi'
	screen_loc = ui_acti

/obj/screen/act_intent/robot
	icon = 'icons/mob/screen_robot.dmi'
	screen_loc = ui_borg_intents

/obj/screen/act_intent/robot/AI
	screen_loc = "SOUTH+1:6,EAST-1:32"

/obj/screen/mov_intent
	name = "run/walk toggle"
	icon_state = "running"

/obj/screen/act_intent/simple_animal
	icon = 'icons/mob/screen_simplemob.dmi'
	screen_loc = ui_acti

/obj/screen/act_intent/guardian
	icon = 'icons/mob/guardian.dmi'
	screen_loc = ui_acti

/obj/screen/mov_intent/Click()
	usr.toggle_move_intent()

/obj/screen/pull
	name = "stop pulling"
	icon_state = "pull"

/obj/screen/pull/Click()
	usr.stop_pulling()

/obj/screen/pull/update_icon_state()
	if(hud?.mymob?.pulling)
		icon_state = "pull"
	else
		icon_state = "pull0"

/obj/screen/resist
	name = "resist"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_resist"

/obj/screen/resist/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.resist()


/obj/screen/throw_catch
	name = "throw/catch"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_throw_off"

/obj/screen/throw_catch/Click()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.toggle_throw_mode()


/obj/screen/storage
	name = "storage"

/obj/screen/storage/Click(location, control, params)
	if(world.time <= usr.next_move)
		return TRUE

	if(usr.incapacitated(ignore_restraints = TRUE, ignore_lying = TRUE))
		return TRUE

	if(ismecha(usr.loc)) // stops inventory actions in a mech
		return TRUE

	if(is_ventcrawling(usr)) // stops inventory actions in vents
		return TRUE

	if(master)
		var/obj/item/I = usr.get_active_hand()
		if(I)
			master.attackby(I, usr, params)
	return TRUE


/obj/screen/storage/proc/is_item_accessible(obj/item/I, mob/user)
	if(!user || !I)
		return FALSE

	var/storage_depth = I.storage_depth(user)
	if((I in user.loc) || (storage_depth != -1))
		return TRUE

	if(!isturf(user.loc))
		return FALSE

	var/storage_depth_turf = I.storage_depth_turf()
	if(isturf(I.loc) || (storage_depth_turf != -1))
		if(I.Adjacent(user))
			return TRUE
	return FALSE


/obj/screen/storage/MouseDrop_T(obj/item/I, mob/user, params)
	if(!user || !istype(I) || user.incapacitated(ignore_restraints = TRUE, ignore_lying = TRUE) || ismecha(user.loc) || !master)
		return FALSE

	if(is_ventcrawling(user))
		return FALSE

	var/obj/item/storage/S = master
	if(!S)
		return FALSE

	if(!is_item_accessible(I, user))
		add_game_logs("tried to abuse storage remote drag&drop with '[I]' at [atom_loc_line(I)] into '[S]' at [atom_loc_line(S)]", user)
		return FALSE

	if(I in S.contents) // If the item is already in the storage, move them to the end of the list
		if(S.contents[S.contents.len] == I) // No point moving them at the end if they're already there!
			return FALSE

		var/list/new_contents = S.contents.Copy()
		if(S.display_contents_with_number)
			// Basically move all occurences of I to the end of the list.
			var/list/obj/item/to_append = list()
			for(var/obj/item/stored_item in S.contents)
				if(S.can_items_stack(stored_item, I))
					new_contents -= stored_item
					to_append += stored_item

			new_contents.Add(to_append)
		else
			new_contents -= I
			new_contents += I // oof
		S.contents = new_contents

		if(user.s_active == S)
			S.orient2hud(user)
			S.show_to(user)
	else // If it's not in the storage, try putting it inside
		I.pickup(user) //Do not actually put in hands, but rather make some funny effects out of it
		S.attackby(I, user)
	return TRUE


/obj/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/overlay_file = 'icons/mob/zone_sel.dmi'
	var/selecting = BODY_ZONE_CHEST
	var/list/hover_overlays_cache
	var/list/selecting_overlays_cache
	var/hovering


/obj/screen/zone_sel/Initialize(mapload, hud, icon, alpha, color)
	. = ..()
	src.hud = hud	// Don't forget to always put here the created HUD '/datum/hud/'.
	hover_overlays_cache = list()
	selecting_overlays_cache = list()
	if(icon)
		src.icon = icon
	if(alpha)
		src.alpha = alpha
	if(color)
		src.color = color
	src.hud.mymob.zone_selected = selecting
	update_icon(UPDATE_OVERLAYS)


/obj/screen/zone_sel/Destroy()
	QDEL_LIST_ASSOC_VAL(hover_overlays_cache)
	QDEL_LIST_ASSOC_VAL(selecting_overlays_cache)
	return ..()


/obj/screen/zone_sel/Click(location, control, params)
	if(isobserver(usr))
		return FALSE

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/choice = get_zone_at(icon_x, icon_y)
	if(!choice)
		return TRUE

	if(PL["alt"])
		AltClick(usr, choice)
		return

	return set_selected_zone(choice)

/obj/screen/zone_sel/AltClick(mob/user, choice)

	if(user.next_click > world.time || user.next_move > world.time)
		return FALSE
	user.changeNext_click(1)

	var/obj/item/holding_item = user.get_active_hand()
	var/old_selecting = selecting
	if(!istype(holding_item))
		return FALSE
	if(!set_selected_zone(choice, FALSE))
		return FALSE
	holding_item.melee_attack_chain(user, user)
	set_selected_zone(old_selecting, FALSE)


/obj/screen/zone_sel/MouseEntered(location, control, params)
	MouseMove(location, control, params)


/obj/screen/zone_sel/MouseMove(location, control, params)
	if(isobserver(usr))
		return

	var/list/PL = params2list(params)
	var/choice = get_zone_at(text2num(PL["icon-x"]), text2num(PL["icon-y"]))

	if(!choice)
		cut_overlay(hover_overlays_cache[hovering])
		hovering = null
		return

	if(choice == hovering)
		return

	cut_overlay(hover_overlays_cache[hovering])
	hovering = choice

	var/mutable_appearance/hovering_olay = hover_overlays_cache[hovering]
	if(!hovering_olay)
		hovering_olay = mutable_appearance(overlay_file, "[hovering]", alpha = 128, appearance_flags = RESET_COLOR)
		hover_overlays_cache[hovering] = hovering_olay

	add_overlay(hovering_olay)


/obj/screen/zone_sel/MouseExited(location, control, params)
	if(!isobserver(usr) && hovering)
		cut_overlay(hover_overlays_cache[hovering])
		hovering = null


/obj/screen/zone_sel/proc/get_zone_at(icon_x, icon_y)
	switch(icon_y)
		if(1 to 3) //Feet
			switch(icon_x)
				if(10 to 15)
					return BODY_ZONE_PRECISE_R_FOOT
				if(17 to 22)
					return BODY_ZONE_PRECISE_L_FOOT
		if(4 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					return BODY_ZONE_R_LEG
				if(17 to 22)
					return BODY_ZONE_L_LEG
				if(23 to 29)
					return BODY_ZONE_TAIL
		if(10 to 13) //Hands,groin and wings
			switch(icon_x)
				if(8 to 11)
					return BODY_ZONE_PRECISE_R_HAND
				if(12 to 20)
					return BODY_ZONE_PRECISE_GROIN
				if(21 to 24)
					return BODY_ZONE_PRECISE_L_HAND
				if(3 to 7)
					return BODY_ZONE_WING
				if(25 to 28)
					return BODY_ZONE_WING
		if(14 to 22) //Chest and arms to shoulders and wings
			switch(icon_x)
				if(3 to 7)
					return BODY_ZONE_WING
				if(8 to 11)
					return BODY_ZONE_R_ARM
				if(12 to 20)
					return BODY_ZONE_CHEST
				if(21 to 24)
					return BODY_ZONE_L_ARM
				if(25 to 28)
					return BODY_ZONE_WING
		if(23 to 30)
			switch(icon_x)
				if(4 to 10)
					return BODY_ZONE_WING
				if(12 to 20)	//Head, but we need to check for eye or mouth
					switch(icon_y)
						if(23 to 24)
							if(icon_x in 15 to 17)
								return BODY_ZONE_PRECISE_MOUTH
						if(26) //Eyeline, eyes are on 15 and 17
							if(icon_x in 14 to 18)
								return BODY_ZONE_PRECISE_EYES
						if(25 to 27)
							if(icon_x in 15 to 17)
								return BODY_ZONE_PRECISE_EYES
					return BODY_ZONE_HEAD
				if(22 to 28)
					return BODY_ZONE_WING


/obj/screen/zone_sel/proc/set_selected_zone(choice, update_overlay = TRUE)
	if(!hud || !hud.mymob)
		return FALSE

	if(isobserver(hud.mymob))
		return FALSE

	if(choice != selecting)
		selecting = choice
		hud.mymob.zone_selected = choice
		if(update_overlay)
			update_icon(UPDATE_OVERLAYS)
	return TRUE


/obj/screen/zone_sel/update_overlays()
	. = ..()
	var/mutable_appearance/selecting_olay = selecting_overlays_cache[selecting]
	if(!selecting_olay)
		selecting_olay = mutable_appearance(overlay_file, "[selecting]", appearance_flags = RESET_COLOR)
		selecting_overlays_cache[selecting] = selecting_olay
	. += selecting_olay


/obj/screen/zone_sel/alien
	icon = 'icons/mob/screen_alien.dmi'
	overlay_file = 'icons/mob/screen_alien.dmi'


/obj/screen/zone_sel/robot
	icon = 'icons/mob/screen_robot.dmi'


/obj/screen/craft
	name = "crafting menu"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "craft"
	screen_loc = ui_crafting

/obj/screen/craft/Click()
	var/mob/living/M = usr
	M.OpenCraftingMenu()

/obj/screen/language_menu
	name = "language menu"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "talk_wheel"
	screen_loc = ui_language_menu

/obj/screen/language_menu/Click()
	var/mob/M = usr
	if(!istype(M))
		return
	M.check_languages()

/obj/screen/inventory
	var/slot_id	//The indentifier for the slot. It has nothing to do with ID cards.
	var/image/object_overlay

/obj/screen/inventory/MouseEntered()
	..()
	add_overlays()

/obj/screen/inventory/MouseExited()
	..()
	cut_overlay(object_overlay)
	QDEL_NULL(object_overlay)

/obj/screen/inventory/proc/add_overlays()
	var/mob/user = hud?.mymob

	if(!user || !slot_id || slot_id == slot_l_hand || slot_id == slot_r_hand)
		return

	var/obj/item/holding = user.get_active_hand()

	if(!holding || user.get_item_by_slot(slot_id))
		return

	var/image/item_overlay = image(holding)
	item_overlay.alpha = 92

	if(!holding.mob_can_equip(user, slot_id, disable_warning = TRUE, bypass_equip_delay_self = TRUE, bypass_obscured = FALSE))
		item_overlay.color = "#ff0000"
	else
		item_overlay.color = "#00ff00"

	cut_overlay(object_overlay)
	QDEL_NULL(object_overlay)
	object_overlay = item_overlay
	add_overlay(object_overlay)


/obj/screen/inventory/Click(location, control, params)
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return TRUE

	if(usr.incapacitated())
		return TRUE

	if(ismecha(usr.loc)) // stops inventory actions in a mech
		return TRUE

	if(is_ventcrawling(usr)) // stops inventory actions in vents
		return TRUE

	if(hud?.mymob && slot_id)
		var/obj/item/inv_item = hud.mymob.get_item_by_slot(slot_id)
		if(inv_item)
			return inv_item.Click(location, control, params)

	if(usr.attack_ui(slot_id, params))
		usr.update_inv_hands()

	return TRUE


/obj/screen/inventory/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	cut_overlay(object_overlay)
	QDEL_NULL(object_overlay)
	if(could_be_click_lag())
		Click(src_location, src_control, params)
		drag_start = 0
		return
	return ..()


/obj/screen/inventory/MouseDrop_T(obj/item/I, mob/user, params)

	if(!user || !istype(I) || user.incapacitated() || ismecha(user.loc) || is_ventcrawling(user))
		return FALSE

	if(isalien(user) && !I.allowed_for_alien())	// We need to do this here
		return FALSE

	if(!in_range(get_turf(I), get_turf(user)))
		return FALSE

	if(!hud?.mymob || !slot_id)
		return FALSE

	if(hud.mymob != user)
		return FALSE

	if(slot_id != slot_l_hand && slot_id != slot_r_hand)
		return FALSE

	if(I.is_equipped() && !user.is_general_slot(user.get_slot_by_item(I)))

		if(I.equip_delay_self && !user.is_general_slot(user.get_slot_by_item(I)))
			user.visible_message(span_notice("[user] начинает снимать [I.name]..."), \
								span_notice("Вы начинаете снимать [I.name]..."))
			if(!do_after_once(user, I.equip_delay_self, target = user, attempt_cancel_message = "Снятие [I.name] было прервано!"))
				return FALSE

			if((slot_id == slot_l_hand && user.l_hand) || (slot_id == slot_r_hand && user.r_hand))
				return FALSE

		if(!user.drop_item_ground(I))
			return FALSE

	else if(user.is_general_slot(user.get_slot_by_item(I)) && !user.drop_item_ground(I))
		return FALSE

	if((slot_id == slot_l_hand && !user.put_in_l_hand(I, ignore_anim = FALSE)) || \
		(slot_id == slot_r_hand && !user.put_in_r_hand(I, ignore_anim = FALSE)))
		return FALSE

	I.pickup(user)


/obj/screen/inventory/hand
	var/image/active_overlay
	var/image/handcuff_overlay
	var/static/mutable_appearance/blocked_overlay = mutable_appearance('icons/mob/screen_gen.dmi', "blocked")


/obj/screen/inventory/hand/update_overlays()
	. = ..()

	if(!hud || !hud.mymob)
		return

	if(!active_overlay)
		active_overlay = image("icon" = icon, "icon_state" = "hand_active")

	if(!handcuff_overlay)
		var/state = (slot_id == slot_l_hand) ? "gabrielle" : "markus"
		handcuff_overlay = image("icon" = 'icons/mob/screen_gen.dmi', "icon_state" = state)

	if(iscarbon(hud.mymob))
		var/mob/living/carbon/user = hud.mymob
		if(user.handcuffed)
			. += handcuff_overlay

		var/obj/item/organ/external/limb = user.get_organ((slot_id == slot_l_hand) ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
		if(!isalien(user) && (!limb || !limb.is_usable()))
			. += blocked_overlay

	if(slot_id == slot_l_hand && hud.mymob.hand)
		. += active_overlay

	else if(slot_id == slot_r_hand && !hud.mymob.hand)
		. += active_overlay


/obj/screen/inventory/hand/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	var/mob/user = hud?.mymob
	if(usr != user)
		return TRUE

	if(world.time <= user.next_move)
		return TRUE

	if(user.incapacitated())
		return TRUE

	if(ismecha(user.loc)) // stops inventory actions in a mech
		return TRUE

	if(is_ventcrawling(user)) // stops inventory actions in vents
		return TRUE

	if(ismob(user))
		var/mob/M = user
		switch(name)
			if("right hand", "r_hand")
				M.activate_hand("r")
			if("left hand", "l_hand")
				M.activate_hand("l")
	return TRUE


/obj/screen/swap_hand
	name = "swap hand"

/obj/screen/swap_hand/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return TRUE

	if(usr.incapacitated())
		return TRUE

	if(ismob(usr))
		var/mob/user = usr
		user.swap_hand()
	return TRUE


/obj/screen/healths
	name = "health"
	icon_state = "health0"
	screen_loc = ui_health

/obj/screen/stamina_bar
	name = "stamina"
	icon_state = "stamina0"
	screen_loc = ui_stamina

/obj/screen/healths/alien
	icon = 'icons/mob/screen_alien.dmi'
	screen_loc = ui_alien_health

/obj/screen/healths/bot
	icon = 'icons/mob/screen_bot.dmi'
	screen_loc = ui_borg_health

/obj/screen/healths/robot
	icon = 'icons/mob/screen_robot.dmi'
	screen_loc = ui_borg_health

/obj/screen/healths/corgi
	icon = 'icons/mob/screen_corgi.dmi'

/obj/screen/healths/slime
	icon = 'icons/mob/screen_slime.dmi'
	icon_state = "slime_health0"
	screen_loc = ui_slime_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/healths/guardian
	name = "summoner health"
	icon = 'icons/mob/guardian.dmi'
	icon_state = "base"
	screen_loc = ui_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/healthdoll
	name = "health doll"
	icon_state = "healthdoll_DEAD"
	screen_loc = ui_healthdoll
	var/list/cached_healthdoll_overlays = list() // List of icon states (strings) for overlays

/obj/screen/healthdoll/Click()
	if(ishuman(usr) && !usr.is_dead())
		var/mob/living/carbon/H = usr
		H.check_self_for_injuries()

/obj/screen/healthdoll/living
	var/filtered = FALSE //so we don't repeatedly create the mask of the mob every update

/obj/screen/component_button
	var/obj/screen/parent

/obj/screen/component_button/Initialize(mapload, obj/screen/new_parent)
	. = ..()
	parent = new_parent

/obj/screen/component_button/Click(params)
	if(parent)
		parent.component_click(src, params)
