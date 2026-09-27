/datum/action/cooldown/spell/heretic_menu
	name = "Меню Еретика"
	desc = "Открывает меню прокачки."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	spell_requirements = NONE
	cooldown_time = 1 SECONDS


/datum/action/cooldown/spell/heretic_menu/cast(atom/cast_on)
	. = ..()
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(owner)
	if(!heretic_datum)
		return
	heretic_datum.ui_interact(owner)
