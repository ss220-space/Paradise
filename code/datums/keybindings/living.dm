/datum/keybinding/living
	category = KB_CATEGORY_LIVING

/datum/keybinding/living/can_use(client/C, mob/M)
	return isliving(M) && ..()

/datum/keybinding/living/rest
	name = "Лечь/встать"
	keys = list("ShiftB")

/datum/keybinding/living/rest/down(client/C)
	. = ..()
	var/mob/living/M = C.mob
	M.toggle_resting()

/datum/keybinding/living/resist
	name = "Сопротивляться"
	keys = list("B")

/datum/keybinding/living/resist/down(client/C)
	. = ..()
	var/mob/living/M = C.mob
	M.resist()

/datum/keybinding/living/look_up
	name = "Взглянуть вверх"
	keys = list("Northwest") // Home

/datum/keybinding/living/look_up/down(client/user)
	. = ..()
	var/mob/living/L = user.mob
	L.look_up()

/datum/keybinding/living/look_up/up(client/user)
	. = ..()
	var/mob/living/L = user.mob
	L.end_look_up()

/datum/keybinding/living/look_down
	name = "Взглянуть вниз"
	keys = list("Southwest") // End

/datum/keybinding/living/look_down/down(client/user)
	. = ..()
	var/mob/living/L = user.mob
	L.look_down()

/datum/keybinding/living/look_down/up(client/user)
	. = ..()
	var/mob/living/L = user.mob
	L.end_look_down()
