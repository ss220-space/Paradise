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

/datum/keybinding/carbon/intent
	abstract_type = /datum/keybinding/carbon/intent
	/// The intent to switch to.
	var/intent

/datum/keybinding/carbon/intent/New()
	keybind_signal = COMSIG_KB_CARBON_INTENT(intent)
	name = "intent_switch_[intent]"
	var/intent_cap = capitalize(intent)
	full_name = "[intent_cap] Intent (нажать)"
	description = "Переключает интент на [intent_cap]."
	..()

/datum/keybinding/carbon/intent/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	var/mob/living/carbon/carbon_mob = user.mob
	carbon_mob.a_intent_change(intent)

	return TRUE

/datum/keybinding/carbon/intent/help
	name = "Help Intent (нажать)"
	intent = INTENT_HELP
	hotkey_keys = list("1")

/datum/keybinding/carbon/intent/disarm
	name = "Disarm Intent (нажать)"
	intent = INTENT_DISARM
	hotkey_keys = list("2")

/datum/keybinding/carbon/intent/grab
	name = "Grab Intent (нажать)"
	intent = INTENT_GRAB
	hotkey_keys = list("3")

/datum/keybinding/carbon/intent/harm
	name = "Harm Intent (нажать)"
	intent = INTENT_HARM
	hotkey_keys = list("4")

/datum/keybinding/carbon/intent_hold
	abstract_type = /datum/keybinding/carbon/intent_hold
	/// The intent to switch to.
	var/intent
	/// The previous intent before holding.
	var/prev_intent

/datum/keybinding/carbon/intent_hold/New()
	keybind_signal = COMSIG_KB_CARBON_INTENT(intent)
	name = "intent_hold_[intent]"
	var/intent_cap = capitalize(intent)
	full_name = "[intent_cap] Intent (зажать)"
	description = "Удерживает интент [intent_cap]."
	..()

/datum/keybinding/carbon/intent_hold/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	var/mob/living/carbon/carbon_mob = user.mob
	prev_intent = carbon_mob.a_intent
	carbon_mob.a_intent_change(intent)

/datum/keybinding/carbon/intent_hold/up(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/carbon/carbon_mob = user.mob
	carbon_mob.a_intent_change(prev_intent)
	prev_intent = null

/datum/keybinding/carbon/intent_hold/help
	name = "Help Intent (зажать)"
	intent = INTENT_HELP

/datum/keybinding/carbon/intent_hold/disarm
	name = "Disarm Intent (зажать)"
	intent = INTENT_DISARM

/datum/keybinding/carbon/intent_hold/grab
	name = "Grab Intent (зажать)"
	intent = INTENT_GRAB

/datum/keybinding/carbon/intent_hold/harm
	name = "Harm Intent (зажать)"
	intent = INTENT_HARM

/datum/keybinding/carbon/parry
	name = "parry"
	full_name = "Парирование"
	description = "Активирует парирование предметом в руках, если предмет способен на это."
	hotkey_keys = list("Space")
	keybind_signal = COMSIG_KB_CARBON_PARRY
