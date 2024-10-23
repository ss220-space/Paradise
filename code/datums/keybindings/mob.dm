/datum/keybinding/mob
	category = KB_CATEGORY_MOB


// Hands
/datum/keybinding/mob/use_held_object
	name = "Использовать вещь в руке"
	keys = list("Z")


/datum/keybinding/mob/use_held_object/down(client/user)
	. = ..()
	if(.)
		return .
	user.mob.mode()
	return TRUE


/datum/keybinding/mob/equip_held_object
	name = "Экипировать вещь"
	keys = list("E")


/datum/keybinding/mob/equip_held_object/down(client/user)
	. = ..()
	if(.)
		return .
	user.mob.quick_equip()
	return TRUE


/datum/keybinding/mob/drop_held_object
	name = "Выложить вещь в руке"
	keys = list("Q")


/datum/keybinding/mob/drop_held_object/can_use(client/user)
	return !isrobot(user.mob)   //robots on 'q' have their own proc for drop, in keybindinds/robot.dm


/datum/keybinding/mob/drop_held_object/down(client/user)
	. = ..()
	if(.)
		return .
	var/obj/item/active_item = user.mob.get_active_hand()
	if(!active_item && user.mob.special_hands_drop_action())
		SEND_SIGNAL(user.mob, COMSIG_MOB_KEY_DROP_ITEM_DOWN)
		return TRUE

	if(active_item)
		if(SEND_SIGNAL(user.mob, COMSIG_MOB_KEY_DROP_ITEM_DOWN) & COMPONENT_CANCEL_DROP)
			return TRUE
		active_item.run_drop_held_item(user.mob)
	else
		if(user.mob.pulling && isliving(user.mob))
			var/mob/living/grabber = user.mob
			if(!isnull(grabber.pull_hand) && grabber.pull_hand != PULL_WITHOUT_HANDS)
				if(user.mob.next_move <= world.time && grabber.hand == grabber.pull_hand)
					grabber.stop_pulling()
				return TRUE
		to_chat(user, span_warning("Вы ничего не держите в руке!"))
	return TRUE


/datum/keybinding/mob/swap_hands
	name = "Поменять руки"
	keys = list("X")


/datum/keybinding/mob/swap_hands/down(client/user)
	. = ..()
	if(.)
		return .
	user.mob.swap_hand()
	return TRUE


// Intents
/datum/keybinding/mob/prev_intent
	name = "Предыдущий Intent"
	keys = list("F")


/datum/keybinding/mob/prev_intent/down(client/user)
	. = ..()
	if(.)
		return .
	user.mob.a_intent_change(INTENT_HOTKEY_LEFT)
	return TRUE


/datum/keybinding/mob/next_intent
	name = "Следующий Intent"
	keys = list("G", "Insert")


/datum/keybinding/mob/next_intent/down(client/user)
	. = ..()
	if(.)
		return .
	user.mob.a_intent_change(INTENT_HOTKEY_RIGHT)
	return TRUE


/datum/keybinding/mob/walk_hold
	name = "Идти (Зажать)"
	keys = list("Alt")


/datum/keybinding/mob/walk_hold/down(client/user)
	. = ..()
	if(.)
		return .
	user.mob.toggle_move_intent()


/datum/keybinding/mob/walk_hold/up(client/user)
	. = ..()
	if(.)
		return .
	user.mob.toggle_move_intent()


/datum/keybinding/mob/walk_toggle
	name = "Идти (Переключить)"


/datum/keybinding/mob/walk_toggle/down(client/user)
	. = ..()
	if(.)
		return .
	user.mob.toggle_move_intent()
	return TRUE


// Other
/datum/keybinding/mob/stop_pulling
	name = "Перестать тащить"
	keys = list("C")


/datum/keybinding/mob/stop_pulling/down(client/user)
	. = ..()
	if(.)
		return .
	if(user.mob.pulling)
		user.mob.stop_pulling()
	else
		to_chat(user, span_notice("Вы ничего не тащите."))
	return TRUE


/datum/keybinding/mob/face_dir
	/// The direction to face towards.
	var/dir


/datum/keybinding/mob/face_dir/down(client/user)
	. = ..()
	if(.)
		return .
	user.mob.keybind_face_direction(dir)
	return TRUE


/datum/keybinding/mob/face_dir/north
	name = "Смотреть наверх"
	keys = list("CtrlW", "CtrlNorth")
	dir = NORTH


/datum/keybinding/mob/face_dir/south
	name = "Смотреть вниз"
	keys = list("CtrlS", "CtrlSouth")
	dir = SOUTH


/datum/keybinding/mob/face_dir/east
	name = "Смотреть вправо"
	keys = list("CtrlD", "CtrlEast")
	dir = EAST


/datum/keybinding/mob/face_dir/west
	name = "Смотреть влево"
	keys = list("CtrlA", "CtrlWest")
	dir = WEST


/datum/keybinding/mob/target_cycle
	var/body_zone


/datum/keybinding/mob/target_cycle/down(client/user)
	. = ..()
	if(.)
		return .
	switch(body_zone)
		if(BODY_ZONE_HEAD)
			user.body_toggle_head()
		if(BODY_ZONE_CHEST)
			user.body_chest()
		if(BODY_ZONE_L_ARM)
			user.body_l_arm()
		if(BODY_ZONE_R_ARM)
			user.body_r_arm()
		if(BODY_ZONE_PRECISE_GROIN)
			user.body_groin()
		if(BODY_ZONE_L_LEG)
			user.body_l_leg()
		if(BODY_ZONE_R_LEG)
			user.body_r_leg()
		else
			stack_trace("Target keybind pressed but not implemented! '[body_zone]'")
			return FALSE


/datum/keybinding/mob/target_cycle/head
	name = "Выбрать голову/глаза/рот"
	keys = list("Numpad8")
	body_zone = BODY_ZONE_HEAD


/datum/keybinding/mob/target_cycle/chest
	name = "Выбрать грудь/крылья"
	keys = list("Numpad5")
	body_zone = BODY_ZONE_CHEST


/datum/keybinding/mob/target_cycle/r_arm
	name = "Выбрать правую руку/кисть"
	keys = list("Numpad4")
	body_zone = BODY_ZONE_R_ARM


/datum/keybinding/mob/target_cycle/l_arm
	name = "Выбрать левую руку/кисть"
	keys = list("Numpad6")
	body_zone = BODY_ZONE_L_ARM


/datum/keybinding/mob/target_cycle/groin
	name = "Выбрать пах/хвост"
	keys = list("Numpad2")
	body_zone = BODY_ZONE_PRECISE_GROIN


/datum/keybinding/mob/target_cycle/r_leg
	name = "Выбрать правую ногу/ступню"
	keys = list("Numpad1")
	body_zone = BODY_ZONE_R_LEG


/datum/keybinding/mob/target_cycle/l_leg
	name = "Выбрать левую ногу/ступню"
	keys = list("Numpad3")
	body_zone = BODY_ZONE_L_LEG


/datum/keybinding/mob/target
	// The body part to target.
	var/body_part


/datum/keybinding/mob/target/down(client/user)
	. = ..()
	if(.)
		return .
	if(!user.check_has_body_select())
		return FALSE
	var/atom/movable/screen/zone_sel/selector = user.mob.hud_used.zone_select
	selector.set_selected_zone(body_part)


/datum/keybinding/mob/target/head
	name = "Выбрать голову"
	body_part = BODY_ZONE_HEAD


/datum/keybinding/mob/target/eyes
	name = "Выбрать глаза"
	body_part = BODY_ZONE_PRECISE_EYES


/datum/keybinding/mob/target/mouth
	name = "Выбрать рот"
	body_part = BODY_ZONE_PRECISE_MOUTH


/datum/keybinding/mob/target/chest
	name = "Выбрать грудь"
	body_part = BODY_ZONE_CHEST


/datum/keybinding/mob/target/wing
	name = "Выбрать крылья"
	body_part = BODY_ZONE_WING


/datum/keybinding/mob/target/r_arm
	name = "Выбрать правую руку"
	body_part = BODY_ZONE_R_ARM


/datum/keybinding/mob/target/r_hand
	name = "Выбрать правую кисть"
	body_part = BODY_ZONE_PRECISE_R_HAND


/datum/keybinding/mob/target/l_arm
	name = "Выбрать левую руку"
	body_part = BODY_ZONE_L_ARM


/datum/keybinding/mob/target/l_hand
	name = "Выбрать левую кисть"
	body_part = BODY_ZONE_PRECISE_L_HAND


/datum/keybinding/mob/target/groin
	name = "Выбрать пах"
	body_part = BODY_ZONE_PRECISE_GROIN


/datum/keybinding/mob/target/tail
	name = "Выбрать хвост"
	body_part = BODY_ZONE_TAIL


/datum/keybinding/mob/target/r_leg
	name = "Выбрать правую ногу"
	body_part = BODY_ZONE_R_LEG


/datum/keybinding/mob/target/r_foot
	name = "Выбрать правую ступню"
	body_part = BODY_ZONE_PRECISE_R_FOOT


/datum/keybinding/mob/target/l_leg
	name = "Выбрать левую ногу"
	body_part = BODY_ZONE_L_LEG


/datum/keybinding/mob/target/l_foot
	name = "Выбрать левую ступню"
	body_part = BODY_ZONE_PRECISE_L_FOOT


/datum/keybinding/mob/trigger_action_button // Don't add a name to this, shouldn't show up in the prefs menu
	var/datum/action/linked_action
	var/binded_to // these are expected to actually get deleted at some point, to prevent hard deletes we need to know where to remove them from the clients list


/datum/keybinding/mob/trigger_action_button/down(client/user)
	. = ..()
	if(.)
		return .
	if(user.mob.next_click > world.time)
		return FALSE
	linked_action.Trigger()
	linked_action.UpdateButtonIcon()
	return TRUE


/datum/keybinding/mob/move_up
	name = "Подняться"
	keys = list("Northeast") // Page Up


/datum/keybinding/mob/move_down
	name = "Спуститься"
	keys = list("Southeast") // Page Down


/datum/keybinding/mob/move_up/down(client/user)
	. = ..()
	if(.)
		return .
	user.mob.move_up()


/datum/keybinding/mob/move_down/down(client/user)
	. = ..()
	if(.)
		return .
	user.mob.move_down()

