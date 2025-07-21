/obj/effect/proc_holder/spell/pointed/void_phase
	name = "Пустотный Сдвиг"
	desc = "Позволяет переместиться в выбранное место, повреждает всех в квадрате 3x3 вокруг \
			выбранного места и вашего текущего местоположения. Минимальная дальность — 3 клетки, \
			максимальная — 9 клеток."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "voidblink"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	clothes_req = FALSE
	base_cooldown = 25 SECONDS

	invocation = "СДВ'Г Р'ЛЬН'СТ."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 9
	/// The minimum range to cast the phase.
	var/min_cast_range = 3
	/// The radius of damage around the void bubble
	var/damage_radius = 1


/obj/effect/proc_holder/spell/pointed/void_phase/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	if(!action.owner || get_dist(get_turf(action.owner), get_turf(cast_on)) >= min_cast_range)
		return

	cast_on.balloon_alert(action.owner, "слишком близко!")
	return . | SPELL_CANCEL_CAST


/obj/effect/proc_holder/spell/pointed/void_phase/cast(atom/cast_on)
	. = ..()
	var/turf/source_turf = get_turf(action.owner)
	var/turf/targeted_turf = get_turf(cast_on)

	cause_aoe(source_turf, /obj/effect/temp_visual/voidin)
	cause_aoe(targeted_turf, /obj/effect/temp_visual/voidout)

	do_teleport(
		action.owner,
		targeted_turf,
		aprecision = 1,
	)


/// Does the AOE effect of the blinka t the passed turf
/obj/effect/proc_holder/spell/pointed/void_phase/proc/cause_aoe(turf/target_turf, effect_type = /obj/effect/temp_visual/voidin)
	new effect_type(target_turf)
	playsound(target_turf, 'sound/effects/magic/voidblink.ogg', 60, FALSE)
	for(var/mob/living/living_mob in range(damage_radius, target_turf))
		if(IS_HERETIC_OR_MONSTER(living_mob) || living_mob == action.owner)
			continue

		if(living_mob.can_block_magic(antimagic_flags))
			continue

		living_mob.apply_damage(40, BRUTE/*, wound_bonus = CANT_WOUND*/)
		living_mob.apply_status_effect(/datum/status_effect/void_chill, 1)


/obj/effect/temp_visual/voidin
	icon = 'icons/effects/96x96.dmi'
	icon_state = "void_blink_in"
	alpha = 150
	duration = 6
	pixel_x = -32
	pixel_y = -32


/obj/effect/temp_visual/voidout
	icon = 'icons/effects/96x96.dmi'
	icon_state = "void_blink_out"
	alpha = 150
	duration = 6
	pixel_x = -32
	pixel_y = -32
