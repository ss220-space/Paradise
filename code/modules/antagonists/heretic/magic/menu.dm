/obj/effect/proc_holder/spell/heretic_menu
	name = "Меню еретика"
	desc = "Открывает меню прокачки."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	school = SCHOOL_UNSET
	clothes_req = FALSE
	base_cooldown = 1 SECONDS


/obj/effect/proc_holder/spell/heretic_menu/cast(list/targets)
	. = ..()
	var/mob/target = targets[1]
	var/datum/antagonist/heretic/heretic_datum = target.mind.has_antag_datum(/datum/antagonist/heretic)
	heretic_datum.ui_interact(target)
