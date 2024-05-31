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

/datum/keybinding/living/whisper
	name = "Шептать"
	keys = list("ShiftT")
/datum/keybinding/living/whisper/down(client/C)
	var/mob/M = C.mob
	M.set_typing_indicator(TRUE)
	M.hud_typing = 1
	var/message = typing_input(M, "", "Whisper (text)")
	M.hud_typing = 0
	M.set_typing_indicator(FALSE)
	if(message)
		M.whisper(message)

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
