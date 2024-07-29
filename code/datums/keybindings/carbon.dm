/datum/keybinding/carbon
	category = KB_CATEGORY_CARBON


/datum/keybinding/carbon/can_use(client/user)
	return iscarbon(user.mob)


/datum/keybinding/carbon/throw_mode
	name = "Режим броска (переключить)"
	keys = list("R")


/datum/keybinding/carbon/throw_mode/down(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/carbon/carbon_mob = user.mob
	carbon_mob.toggle_throw_mode()
	return TRUE


/datum/keybinding/carbon/throw_mode_hold
	name = "Режим броска (Зажать)"


/datum/keybinding/carbon/throw_mode_hold/down(client/user)
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
	name = "Передать вещь (переключить)"
	keys = list("V")


/datum/keybinding/carbon/give_item/down(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/carbon/carbon_mob = user.mob
	carbon_mob.toggle_give()
	return TRUE


/datum/keybinding/carbon/intent
	/// The intent to switch to.
	var/intent


/datum/keybinding/carbon/intent/down(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/carbon/carbon_mob = user.mob
	carbon_mob.a_intent_change(intent)
	return TRUE


/datum/keybinding/carbon/intent/help
	name = "Help Intent (нажать)"
	intent = INTENT_HELP
	keys = list("1")


/datum/keybinding/carbon/intent/disarm
	name = "Disarm Intent (нажать)"
	intent = INTENT_DISARM
	keys = list("2")


/datum/keybinding/carbon/intent/grab
	name = "Grab Intent (нажать)"
	intent = INTENT_GRAB
	keys = list("3")


/datum/keybinding/carbon/intent/harm
	name = "Harm Intent (нажать)"
	intent = INTENT_HARM
	keys = list("4")


/datum/keybinding/carbon/intent_hold
	/// The intent to switch to.
	var/intent
	/// The previous intent before holding.
	var/prev_intent


/datum/keybinding/carbon/intent_hold/down(client/user)
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

