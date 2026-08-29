/datum/keybinding/mob
	category = KB_CATEGORY_MOB
	weight = WEIGHT_MOB

// Hands

/datum/keybinding/mob/activate_inhand
	hotkey_keys = list("Z")
	name = "activate_inhand"
	full_name = "Использовать вещь в руке"
	description = "Uses whatever item you have inhand"
	keybind_signal = COMSIG_KB_MOB_ACTIVATEINHAND_DOWN

/datum/keybinding/mob/activate_inhand/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	user.mob.mode()
	return TRUE

/datum/keybinding/mob/quick_equip
	name = "quick_equip"
	full_name = "Экипировать вещь"
	description = "Quickly puts an item in the best slot available"
	hotkey_keys = list("E")
	keybind_signal = COMSIG_KB_HUMAN_QUICKEQUIP_DOWN

/datum/keybinding/mob/quick_equip/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	user.mob.quick_equip()
	return TRUE

/datum/keybinding/mob/drop_item
	name = "drop_item"
	full_name = "Выложить вещь в руке"
	description = "Drops the item in your active hand to the ground."
	hotkey_keys = list("Q")
	keybind_signal = COMSIG_KB_MOB_DROPITEM_DOWN

/datum/keybinding/mob/drop_item/can_use(client/user)
	return !isrobot(user.mob)   //robots on 'q' have their own proc for drop, in keybindinds/robot.dm

/datum/keybinding/mob/drop_item/down(client/user, turf/target, mousepos_x, mousepos_y)
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

		if(ishuman(user.mob))
			var/mob/living/grabber = user.mob
			var/suppress_target_bodypart = grabber.hand == ACTIVE_HAND_LEFT ? grabber.left_hand_bleed_suppress_lib : grabber.right_hand_bleed_suppress_lib
			if(suppress_target_bodypart)
				if(grabber.hand == ACTIVE_HAND_LEFT)
					grabber.left_hand_bleed_suppress_lib = null
				else
					grabber.right_hand_bleed_suppress_lib = null
				grabber.update_hands_HUD()
				return TRUE

		to_chat(user, span_warning("Вы ничего не держите в руке!"))
	return TRUE

/datum/keybinding/mob/swap_hands
	name = "swap_hands"
	full_name = "Поменять руки"
	hotkey_keys = list("X")
	keybind_signal = COMSIG_KB_MOB_SWAPHANDS_DOWN

/datum/keybinding/mob/swap_hands/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	user.mob.swap_hand()
	return TRUE

/datum/keybinding/mob/select_hand
	abstract_type = /datum/keybinding/mob/select_hand
	var/hand_index = NONE

/datum/keybinding/mob/select_hand/right
	hotkey_keys = list(UNBOUND_KEY)
	name = "select_right_hand"
	full_name = "Swap to Right Hand"
	keybind_signal = COMSIG_KB_MOB_SELECTRIGHTHAND_DOWN
	hand_index = RIGHT_HANDS

/datum/keybinding/mob/select_hand/left
	hotkey_keys = list(UNBOUND_KEY)
	name = "select_left_hand"
	full_name = "Swap to Left Hand"
	keybind_signal = COMSIG_KB_MOB_SELECTLEFTHAND_DOWN
	hand_index = LEFT_HANDS

/datum/keybinding/mob/select_hand/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return

	user.mob.activate_hand(hand_index)

	return TRUE

/datum/keybinding/mob/prev_intent
	name = "prev_intent"
	full_name = "Предыдущий Intent"
	description = "Переключает на предыдущий интент при нажатии"
	hotkey_keys = list("F")
	keybind_signal = COMSIG_KB_MOB_CYCLEINTENTRIGHT_DOWN

/datum/keybinding/mob/prev_intent/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	user.mob.a_intent_change(INTENT_HOTKEY_LEFT)
	return TRUE

/datum/keybinding/mob/next_intent
	name = "next_intent"
	full_name = "Следующий Intent"
	description = "Переключает на следующий интент при нажатии"
	hotkey_keys = list("G", "Insert")
	keybind_signal = COMSIG_KB_MOB_CYCLEINTENTRIGHT_DOWN

/datum/keybinding/mob/next_intent/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	user.mob.a_intent_change(INTENT_HOTKEY_RIGHT)
	return TRUE

/datum/keybinding/mob/hold_move_intent
	name = "toggle_move_intent"
	full_name = "Hold to toggle move intent"
	description = "Held down to cycle to the other move intent, release to cycle back"
	hotkey_keys = list("Alt")
	keybind_signal = COMSIG_KB_LIVING_TOGGLEMOVEINTENT_DOWN

/datum/keybinding/mob/hold_move_intent/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	user.mob.toggle_move_intent()

/datum/keybinding/mob/hold_move_intent/up(client/user)
	. = ..()
	if(.)
		return .
	user.mob.toggle_move_intent()

/datum/keybinding/mob/toggle_move_intent
	name = "toggle_move_intent_alt"
	full_name = "press to cycle move intent"
	description = "Pressing this cycle to the opposite move intent, does not cycle back"
	keybind_signal = COMSIG_KB_LIVING_TOGGLEMOVEINTENTALT_DOWN

/datum/keybinding/mob/toggle_move_intent/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	user.mob.toggle_move_intent()
	return TRUE

// Other
/datum/keybinding/mob/stop_pulling
	name = "stop_pulling"
	full_name = "Перестать тащить"
	hotkey_keys = list("C")
	keybind_signal = COMSIG_KB_MOB_STOPPULLING_DOWN

/datum/keybinding/mob/stop_pulling/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	if(user.mob.pulling)
		user.mob.stop_pulling()
	else
		to_chat(user, span_notice("Вы ничего не тащите."))
	return TRUE

/datum/keybinding/mob/target_cycle
	abstract_type = /datum/keybinding/mob/target_cycle
	var/body_zone

/datum/keybinding/mob/target_cycle/down(client/user, turf/target, mousepos_x, mousepos_y)
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
	name = "target_cycle_head"
	full_name = "Выбрать голову/глаза/рот"
	description = "Последовательно выбирает голову/глаза/рот при нажатии"
	hotkey_keys = list("Numpad8")
	keybind_signal = COMSIG_KB_MOB_TARGETCYCLEHEAD_DOWN
	body_zone = BODY_ZONE_HEAD

/datum/keybinding/mob/target_cycle/chest
	name = "target_cycle_chest"
	full_name = "Выбрать грудь/крылья"
	description = "Последовательно выбирает грудь/крылья при нажатии"
	hotkey_keys = list("Numpad5")
	body_zone = BODY_ZONE_CHEST
	keybind_signal = COMSIG_KB_MOB_TARGETCYCLECHEST_DOWN

/datum/keybinding/mob/target_cycle/r_arm
	name = "target_cycle_r_arm"
	full_name = "Выбрать правую руку/кисть"
	description = "Последовательно выбирает правую руку/кисть при нажатии"
	hotkey_keys = list("Numpad4")
	body_zone = BODY_ZONE_R_ARM
	keybind_signal = COMSIG_KB_MOB_TARGETCYCLERIGHTARM_DOWN

/datum/keybinding/mob/target_cycle/l_arm
	name = "target_cycle_l_arm"
	full_name = "Выбрать левую руку/кисть"
	description = "Последовательно выбирает левую руку/кисть при нажатии"
	hotkey_keys = list("Numpad6")
	body_zone = BODY_ZONE_L_ARM
	keybind_signal = COMSIG_KB_MOB_TARGETCYCLELEFTARM_DOWN

/datum/keybinding/mob/target_cycle/groin
	name = "target_cycle_groin"
	full_name = "Выбрать пах/хвост"
	description = "Последовательно выбирает пах/хвост при нажатии"
	hotkey_keys = list("Numpad2")
	body_zone = BODY_ZONE_PRECISE_GROIN
	keybind_signal = COMSIG_KB_MOB_TARGETCYCLEGROIN_DOWN

/datum/keybinding/mob/target_cycle/r_leg
	name = "target_cycle_r_leg"
	full_name = "Выбрать правую ногу/ступню"
	description = "Последовательно выбирает правую ногу/ступню при нажатии"
	hotkey_keys = list("Numpad1")
	body_zone = BODY_ZONE_R_LEG
	keybind_signal = COMSIG_KB_MOB_TARGETCYCLERIGHTLEG_DOWN

/datum/keybinding/mob/target_cycle/l_leg
	name = "target_cycle_l_leg"
	full_name = "Выбрать левую ногу/ступню"
	description = "Последовательно выбирает левую ногу/ступню при нажатии"
	hotkey_keys = list("Numpad3")
	body_zone = BODY_ZONE_L_LEG
	keybind_signal = COMSIG_KB_MOB_TARGETCYCLELEFTLEG_DOWN

/datum/keybinding/mob/target
	abstract_type = /datum/keybinding/mob/target
	// The body part to target.
	var/body_part

/datum/keybinding/mob/target/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	if(!user.check_has_body_select())
		return FALSE
	var/atom/movable/screen/zone_sel/selector = user.mob.hud_used.zone_select
	selector.set_selected_zone(body_part)

/datum/keybinding/mob/target/head
	name = "target_head"
	full_name = "Выбрать голову"
	description = "Выбирает голову при нажатии"
	body_part = BODY_ZONE_HEAD
	keybind_signal = COMSIG_KB_MOB_TARGETHEAD_DOWN

/datum/keybinding/mob/target/eyes
	name = "target_eyes"
	full_name = "Выбрать глаза"
	description = "Выбирает глаза при нажатии"
	body_part = BODY_ZONE_PRECISE_EYES
	keybind_signal = COMSIG_KB_MOB_TARGETEYES_DOWN

/datum/keybinding/mob/target/mouth
	name = "target_mouth"
	full_name = "Выбрать рот"
	description = "Выбирает рот при нажатии"
	body_part = BODY_ZONE_PRECISE_MOUTH
	keybind_signal = COMSIG_KB_MOB_TARGETMOUTH_DOWN

/datum/keybinding/mob/target/chest
	name = "target_chest"
	full_name = "Выбрать грудь"
	description = "Выбирает грудь при нажатии"
	body_part = BODY_ZONE_CHEST
	keybind_signal = COMSIG_KB_MOB_TARGETBODYCHEST_DOWN

/datum/keybinding/mob/target/wing
	name = "target_wing"
	full_name = "Выбрать крылья"
	description = "Выбирает крылья при нажатии"
	body_part = BODY_ZONE_WING
	keybind_signal = COMSIG_KB_MOB_TARGETBODYCHEST_DOWN

/datum/keybinding/mob/target/r_arm
	name = "target_r_arm"
	full_name = "Выбрать правую руку"
	description = "Выбирает правую руку при нажатии"
	body_part = BODY_ZONE_R_ARM
	keybind_signal = COMSIG_KB_MOB_TARGETRIGHTARM_DOWN

/datum/keybinding/mob/target/r_hand
	name = "target_r_hand"
	full_name = "Выбрать правую кисть"
	description = "Выбирает правую кисть при нажатии"
	body_part = BODY_ZONE_PRECISE_R_HAND
	keybind_signal = COMSIG_KB_MOB_TARGETRIGHTHAND_DOWN

/datum/keybinding/mob/target/l_arm
	name = "target_l_arm"
	full_name = "Выбрать левую руку"
	description = "Выбирает левую руку при нажатии"
	body_part = BODY_ZONE_L_ARM
	keybind_signal = COMSIG_KB_MOB_TARGETLEFTARM_DOWN

/datum/keybinding/mob/target/l_hand
	name = "target_l_hand"
	full_name = "Выбрать левую кисть"
	description = "Выбирает левую кисть при нажатии"
	body_part = BODY_ZONE_PRECISE_L_HAND
	keybind_signal = COMSIG_KB_MOB_TARGETLEFTHAND_DOWN

/datum/keybinding/mob/target/groin
	name = "target_groin"
	full_name = "Выбрать пах"
	description = "Выбирает пах при нажатии"
	body_part = BODY_ZONE_PRECISE_GROIN
	keybind_signal = COMSIG_KB_MOB_TARGETBODYGROIN_DOWN

/datum/keybinding/mob/target/tail
	name = "target_tail"
	full_name = "Выбрать хвост"
	description = "Выбирает хвост при нажатии"
	body_part = BODY_ZONE_TAIL
	keybind_signal = COMSIG_KB_MOB_TARGETBODYGROIN_DOWN

/datum/keybinding/mob/target/r_leg
	name = "target_r_leg"
	full_name = "Выбрать правую ногу"
	description = "Выбирает правую ногу при нажатии"
	body_part = BODY_ZONE_R_LEG
	keybind_signal = COMSIG_KB_MOB_TARGETRIGHTLEG_DOWN

/datum/keybinding/mob/target/r_foot
	name = "target_r_foot"
	full_name = "Выбрать правую ступню"
	description = "Выбирает правую ступню при нажатии"
	body_part = BODY_ZONE_PRECISE_R_FOOT
	keybind_signal = COMSIG_KB_MOB_TARGETRIGHTFOOT_DOWN

/datum/keybinding/mob/target/l_leg
	name = "target_l_leg"
	full_name = "Выбрать левую ногу"
	description = "Выбирает левую ногу при нажатии"
	body_part = BODY_ZONE_L_LEG
	keybind_signal = COMSIG_KB_MOB_TARGETLEFTLEG_DOWN

/datum/keybinding/mob/target/l_foot
	name = "target_l_foot"
	full_name = "Выбрать левую ступню"
	description = "Выбирает левую ступню при нажатии"
	body_part = BODY_ZONE_PRECISE_L_FOOT
	keybind_signal = COMSIG_KB_MOB_TARGETLEFTFOOT_DOWN

/datum/keybinding/mob/prevent_movement
	name = "block_movement"
	full_name = "Остановиться (зажать)"
	description = "Prevents you from moving"
	category = KB_CATEGORY_MOVEMENT
	hotkey_keys = list("Ctrl")
	keybind_signal = COMSIG_KB_MOB_BLOCKMOVEMENT_DOWN

/datum/keybinding/mob/prevent_movement/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	user.movement_locked = TRUE

/datum/keybinding/mob/prevent_movement/up(client/user)
	. = ..()
	if(.)
		return .
	user.movement_locked = FALSE

/datum/keybinding/mob/fast_equip_from_belt
	name = "fast_equip_from_belt"
	full_name = "Достать с пояса"
	description = "Достаёт предмет с пояса при нажатии"
	hotkey_keys = list("CtrlE")
	keybind_signal = COMSIG_KB_MOB_FAST_EQUIP_FROM_BELT_DOWN

/datum/keybinding/mob/fast_equip_from_belt/can_use(client/user)
	return ishuman(user.mob)   //only humans can equip belts

/datum/keybinding/mob/fast_equip_from_belt/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	var/mob/living/carbon/human/human = user.mob
	if(!istype(human))
		return .
	var/obj/item/storage/belt/belt = human.get_item_by_slot(ITEM_SLOT_BELT)
	if(!belt)
		return .
	if(!istype(belt))
		return .
	belt.attack_self(human)

/datum/keybinding/mob/toggle_gun_sight
	name = "toggle_gun_sight"
	full_name = "Использовать прицел"
	description = "Включает/выключает прицел оружия при нажатии"
	hotkey_keys = list("CtrlR")
	keybind_signal = COMSIG_KB_MOB_TOGGLE_GUN_SIGHT_DOWN

/datum/keybinding/mob/toggle_gun_sight/can_use(client/user)
	return ishuman(user.mob) //only humans can use sights

/datum/keybinding/mob/toggle_gun_sight/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	var/mob/living/carbon/human/human = user.mob
	if(!istype(human))
		return .
	var/obj/item/gun/gun = human.get_item_by_slot(ITEM_SLOT_HAND_LEFT)
	if(!gun || !istype(gun))
		gun = human.get_item_by_slot(ITEM_SLOT_HAND_RIGHT)
	if(!gun || !istype(gun))
		return .
	if(!gun.azoom)
		return
	gun.azoom.Trigger()

/datum/keybinding/mob/toggle_laser_sight
	name = "toggle_laser_sight"
	full_name = "Переключить лазерный целеуказатель"
	description = "Включает/выключает лазерный целеуказатель оружия при нажатии"
	hotkey_keys = list("CtrlF")
	keybind_signal = COMSIG_KB_MOB_TOGGLE_LASER_SIGHT_DOWN

/datum/keybinding/mob/toggle_laser_sight/can_use(client/user)
	return ishuman(user.mob) //only humans can use laser sights

/datum/keybinding/mob/toggle_laser_sight/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	var/mob/living/carbon/human/human = user.mob
	if(!istype(human))
		return .
	var/obj/item/gun/gun = human.get_item_by_slot(ITEM_SLOT_HAND_LEFT)
	if(!gun || !istype(gun))
		gun = human.get_item_by_slot(ITEM_SLOT_HAND_RIGHT)
	if(!gun || !istype(gun))
		return .
	SEND_SIGNAL(gun, COMSIG_KEYBINDING_GUN_LASER_SIGHT, human, gun)

/datum/keybinding/mob/toggle_facing_to_mouse
	name = "toggle_facing_to_mouse"
	full_name = "Включить/выключить слежку моба за курсором"
	description = "Переключает режим слежения персонажа за курсором мыши при нажатии"
	hotkey_keys = list("K")
	keybind_signal = COMSIG_KB_MOB_TOGGLE_FACING_TO_MOUSE_DOWN

/datum/keybinding/mob/toggle_facing_to_mouse/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	var/mob/living/mob = user.mob

	if(!istype(mob))
		return .

	if(HAS_TRAIT(mob, TRAIT_FACING_TO_MOUSE))
		mob.RemoveElement(/datum/element/facing_to_mouse)
		mob.balloon_alert(mob, "в направлении движения")
	else
		mob.AddElement(/datum/element/facing_to_mouse)
		mob.balloon_alert(mob, "за курсором мыши")
