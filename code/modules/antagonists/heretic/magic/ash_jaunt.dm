/obj/effect/proc_holder/spell/ethereal_jaunt/ash
	name = "Врата Пепла"
	desc = "A short range spell that allows you to pass unimpeded through walls."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "ash_shift"
	sound = null

	school = SCHOOL_FORBIDDEN
	clothes_req = FALSE
	base_cooldown = 15 SECONDS

	invocation = "ASH'N P'SSG'"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	sound_out = null
	jaunt_duration = 1.1 SECONDS
	jaunt_in_time = 1.3 SECONDS
	jaunt_type_path = /obj/effect/dummy/spell_jaunt/red
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/ash_shift/out


/obj/effect/proc_holder/spell/ethereal_jaunt/ash/long
	name = "Ashen Walk"
	desc = "A long range spell that allows you pass unimpeded through multiple walls."
	jaunt_duration = 5 SECONDS


/obj/effect/temp_visual/dir_setting/ash_shift
	name = "ash_shift"
	icon = 'icons/mob/mob.dmi'
	icon_state = "ash_shift2"
	duration = 1.3 SECONDS


/obj/effect/temp_visual/dir_setting/ash_shift/out
	icon_state = "ash_shift"


/// Red coloured variant
/obj/effect/dummy/spell_jaunt/red
	icon = 'icons/obj/weapons/projectiles.dmi'
	icon_state = "red_1"
