/obj/effect/proc_holder/spell/heretic_menu
	name = "Меню Еретика"
	desc = "Открывает меню прокачки."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions.dmi'
	action_icon_state = "spell_default"
	school = SCHOOL_UNSET
	clothes_req = FALSE
	base_cooldown = 1 SECONDS
	invocation_type = INVOCATION_NONE


/obj/effect/proc_holder/spell/heretic_menu/cast(list/targets)
	. = ..()
	var/mob/target = targets[1]
	var/datum/antagonist/heretic/heretic_datum = target.mind.has_antag_datum(/datum/antagonist/heretic)
	heretic_datum.ui_interact(target)
