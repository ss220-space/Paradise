/obj/effect/proc_holder/spell/ethereal_jaunt/ash
	name = "Врата пепла"
	desc = "Заклинание позволяющее в течении очень маленького промежутка времени проходить сквозь стены."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "ash_shift"
	sound = null

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 15 SECONDS

	invocation = "ВР'Т П'ПЛ"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	sound_out = null
	jaunt_duration = 2 SECONDS
	jaunt_in_time = 0.2 SECONDS
	// The ash_shift reform animation runs for 1.3s (see /obj/effect/temp_visual/dir_setting/ash_shift below).
	// Hold the reveal until it finishes so the heretic forms fully out of the ash before the model appears,
	// instead of popping in 0.2s into the animation. Matches TG (jaunt_in_time == ash_shift duration).
	jaunt_in_reveal_time = 1.3 SECONDS
	jaunt_type_path = /obj/effect/dummy/spell_jaunt/red
	// No steam puff: the vampire base spawns a light-blue steam cloud at both ends via jaunt_water_effect.
	// TG's ash passage has no such effect — only the crumble-to-ash visual. Disable it so the heretic just
	// turns to ash and reforms, with no out-of-place blue cloud.
	jaunt_water_effect = FALSE
	// Both ends play an ash effect, matching TG: crumble to ash on the way out, reform from ash on the way
	// in. selfharm only set jaunt_out_type, so the reappear fell back to the base wizard sparkle.
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/ash_shift
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/ash_shift/out


/obj/effect/proc_holder/spell/ethereal_jaunt/ash/cast(list/targets, mob/user = usr)
	// Empowered (Scorched Mantle + fire stacks): a longer jaunt that also frees you of stuns, stamina
	// crit and restraints — matching TG's empowered Ashen Passage.
	if(is_ash_empowered(user))
		jaunt_duration = initial(jaunt_duration) + 1 SECONDS
		if(iscarbon(user))
			var/mob/living/carbon/carbon_user = user
			carbon_user.SetStunned(0)
			carbon_user.SetKnockdown(0)
			carbon_user.SetImmobilized(0)
			carbon_user.SetParalysis(0)
			carbon_user.setStaminaLoss(0)
			carbon_user.uncuff()
	else
		jaunt_duration = initial(jaunt_duration)
	return ..()


/obj/effect/proc_holder/spell/ethereal_jaunt/ash/long
	name = "Прогулка по углям"
	desc = "Заклинание, позволяющее в течении небольшого промежутка времени беспрепятственно проходить сквозь стены."
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
	phased_mob_icon_state = "red_1"
