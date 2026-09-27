/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash
	name = "Врата Пепла"
	desc = "Заклинание, позволяющее в течении очень маленького промежутка времени проходить сквозь стены."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "ash_shift"
	sound = null

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	invocation = "ВР'Т П'ПЛ"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	exit_jaunt_sound = null
	jaunt_duration = 2 SECONDS
	jaunt_in_time = 1.3 SECONDS
	jaunt_type = /obj/effect/dummy/phased_mob/spell_jaunt/red
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/ash_shift
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/ash_shift/out


/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/long
	name = "Прогулка по Углям"
	desc = "Заклинание, позволяющее в течении небольшого промежутка времени беспрепятственно проходить сквозь стены."
	jaunt_duration = 5 SECONDS


/obj/effect/temp_visual/dir_setting/ash_shift
	name = "ash_shift"
	icon = 'icons/mob/mob.dmi'
	icon_state = "ash_shift2"
	duration = 1.3 SECONDS


/obj/effect/temp_visual/dir_setting/ash_shift/out
	icon_state = "ash_shift"


