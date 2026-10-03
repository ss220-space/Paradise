/datum/keybinding/living
	category = KB_CATEGORY_LIVING
	weight = WEIGHT_MOB

/datum/keybinding/living/can_use(client/user)
	return isliving(user.mob)

/datum/keybinding/living/rest
	name = "rest"
	full_name = "Лечь/встать"
	description = "Lay down, or get up."
	hotkey_keys = list("ShiftB")
	keybind_signal = COMSIG_KB_LIVING_REST_DOWN


/datum/keybinding/living/rest/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	var/mob/living/living_mob = user.mob
	living_mob.toggle_resting()
	return TRUE

/datum/keybinding/living/rest/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	var/mob/living/living_mob = user.mob
	living_mob.toggle_resting()
	return TRUE

/datum/keybinding/living/resist
	name = "resist"
	full_name = "Сопротивляться"
	description = "Break free of your current state. Handcuffed? on fire? Resist!"
	hotkey_keys = list("B")
	keybind_signal = COMSIG_KB_LIVING_RESIST_DOWN

/datum/keybinding/living/resist/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	var/mob/living/living_mob = user.mob
	living_mob.resist()
	return TRUE

/datum/keybinding/living/look_up
	name = "look up"
	full_name = "Взглянуть вверх"
	description = "Look up at the next z-level.  Only works if directly below open space."
	hotkey_keys = list("Northwest") // Home
	keybind_signal = COMSIG_KB_LIVING_LOOKUP_DOWN

/datum/keybinding/living/look_up/down(client/user, turf/target, mousepos_x, mousepos_y)
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
	name = "look down"
	full_name = "Взглянуть вниз"
	description = "Look down at the previous z-level.  Only works if directly above open space."
	hotkey_keys = list("Southwest") // End
	keybind_signal = COMSIG_KB_LIVING_LOOKDOWN_DOWN

/datum/keybinding/living/look_down/down(client/user, turf/target, mousepos_x, mousepos_y)
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

