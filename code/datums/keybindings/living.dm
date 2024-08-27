/datum/keybinding/living
	category = KB_CATEGORY_LIVING


/datum/keybinding/living/can_use(client/user)
	return isliving(user.mob)


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

