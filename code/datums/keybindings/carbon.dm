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
/datum/keybinding/carbon/parry
	name = "Parry"
	keys = list("Space")

/datum/keybinding/carbon/parry/down(client/user)
	. = ..()
	SEND_SIGNAL(user.mob, COMSIG_CARBON_PARRY)
