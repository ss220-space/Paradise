/obj/effect/proc_holder/spell/heretic_menu
	name = "Меню Еретика"
	desc = "Открывает меню прокачки."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	school = SCHOOL_UNSET
	clothes_req = FALSE
	base_cooldown = 1 SECONDS


/obj/effect/proc_holder/spell/heretic_menu/cast(list/targets, mob/user = usr)
	. = ..()
	var/datum/antagonist/heretic/heretic_datum = user?.mind?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return
	heretic_datum.ui_interact(user)
