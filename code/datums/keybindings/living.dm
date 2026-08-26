/datum/keybinding/living
	category = KB_CATEGORY_LIVING

/datum/keybinding/living/can_use(client/user)
	return isliving(user.mob)

/datum/keybinding/living/intent
	/// The intent to switch to.
	var/intent

/datum/keybinding/living/intent/down(client/user)
	. = ..()
	if(.)
		return

	var/mob/living/mob = user.mob
	mob.a_intent_change(intent)
	return TRUE

/datum/keybinding/living/intent/help
	name = "Help Intent (нажать)"
	intent = INTENT_HELP
	keys = list("1")

/datum/keybinding/living/intent/disarm
	name = "Disarm Intent (нажать)"
	intent = INTENT_DISARM
	keys = list("2")

/datum/keybinding/living/intent/grab
	name = "Grab Intent (нажать)"
	intent = INTENT_GRAB
	keys = list("3")

/datum/keybinding/living/intent/harm
	name = "Harm Intent (нажать)"
	intent = INTENT_HARM
	keys = list("4")


/datum/keybinding/living/intent_hold
	/// The intent to switch to.
	var/intent
	/// The previous intent before holding.
	var/prev_intent

/datum/keybinding/living/intent_hold/down(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/mob = user.mob
	prev_intent = mob.a_intent
	mob.a_intent_change(intent)

/datum/keybinding/living/intent_hold/up(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/mob = user.mob
	mob.a_intent_change(prev_intent)
	prev_intent = null

/datum/keybinding/living/intent_hold/help
	name = "Help Intent (зажать)"
	intent = INTENT_HELP

/datum/keybinding/living/intent_hold/disarm
	name = "Disarm Intent (зажать)"
	intent = INTENT_DISARM

/datum/keybinding/living/intent_hold/grab
	name = "Grab Intent (зажать)"
	intent = INTENT_GRAB

/datum/keybinding/living/intent_hold/harm
	name = "Harm Intent (зажать)"
	intent = INTENT_HARM


/datum/keybinding/living/rest
	name = "Лечь/встать"
	keys = list("ShiftB")

/datum/keybinding/living/rest/down(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/living_mob = user.mob
	living_mob.toggle_resting()
	return TRUE

/datum/keybinding/living/resist
	name = "Сопротивляться"
	keys = list("B")

/datum/keybinding/living/resist/down(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/living_mob = user.mob
	living_mob.resist()
	return TRUE

/datum/keybinding/living/look_up
	name = "Взглянуть вверх"
	keys = list("Northwest") // Home

/datum/keybinding/living/look_up/down(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/living_mob = user.mob
	living_mob.look_up()
	return TRUE

/datum/keybinding/living/look_up/up(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/living_mob = user.mob
	living_mob.end_look_up()
	return TRUE

/datum/keybinding/living/look_down
	name = "Взглянуть вниз"
	keys = list("Southwest") // End

/datum/keybinding/living/look_down/down(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/living_mob = user.mob
	living_mob.look_down()
	return TRUE

/datum/keybinding/living/look_down/up(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/living_mob = user.mob
	living_mob.end_look_down()
	return TRUE

