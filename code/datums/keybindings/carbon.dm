/datum/keybinding/carbon
	abstract_type = /datum/keybinding/carbon
	category = KB_CATEGORY_CARBON
	weight = WEIGHT_MOB

/datum/keybinding/carbon/can_use(client/user)
	return iscarbon(user.mob)

/datum/keybinding/carbon/throw_mode
	name = "toggle_throw_mode"
	full_name = "Режим броска (переключить)"
	description = "Toggle throwing the current item or not."
	hotkey_keys = list("R")
	keybind_signal = COMSIG_KB_LIVING_TOGGLETHROWMODE_DOWN

/datum/keybinding/carbon/throw_mode/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	var/mob/living/carbon/carbon_mob = user.mob
	carbon_mob.toggle_throw_mode()
	return TRUE

/datum/keybinding/carbon/throw_mode_hold
	name = "hold_throw_mode"
	full_name = "Режим броска (Зажать)"
	description = "Hold this to turn on throw mode, and release it to turn off throw mode"
	keybind_signal = COMSIG_KB_LIVING_HOLDTHROWMODE_DOWN

/datum/keybinding/carbon/throw_mode_hold/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	var/mob/living/carbon/carbon_mob = user.mob
	carbon_mob.toggle_throw_mode()

/datum/keybinding/carbon/throw_mode_hold/up(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/carbon/carbon_mob = user.mob
	carbon_mob.throw_mode_off()

/datum/keybinding/carbon/give_item
	name = "Give_Item"
	full_name = "Передать вещь (переключить)"
	description = "Give the item you're currently holding"
	hotkey_keys = list("V")
	keybind_signal = COMSIG_KB_LIVING_GIVEITEM_DOWN

/datum/keybinding/carbon/give_item/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	var/mob/living/carbon/carbon_mob = user.mob
	carbon_mob.toggle_give()
	return TRUE

/datum/keybinding/carbon/parry
	name = "parry"
	full_name = "Парирование"
	description = "Активирует парирование предметом в руках, если предмет способен на это."
	hotkey_keys = list("Space")
	keybind_signal = COMSIG_KB_CARBON_PARRY
