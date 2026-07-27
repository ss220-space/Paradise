
/obj/effect/proc_holder/spell/pointed/distortion_field
	name = "Поле Искажения"
	desc = "Растягивает пространство в области 5x5 на выбранной точке. \
			Все, кроме вас и ваших прислужников, двигаются и действуют внутри неё медленнее и периодически застревают. \
			Пролетающие снаряды тоже вязнут. Первое попадание каждой жертвы в поле оставляет Разлом."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "distortion_field"

	sound = 'sound/effects/empulse.ogg'
	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 45 SECONDS

	invocation = "'СК'Ж'Н'!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	cast_range = 6
	active_msg = "Вы выбираете точку, где пространство станет длиннее..."


/obj/effect/proc_holder/spell/pointed/distortion_field/valid_target(atom/cast_on, mob/user)
	return !isnull(get_turf(cast_on))


/obj/effect/proc_holder/spell/pointed/distortion_field/cast(list/targets, mob/user = usr)
	var/mob/living/caster = action?.owner
	var/turf/epicentre = get_turf(targets[1])
	if(!caster || !epicentre)
		return FALSE

	create_distortion_field(epicentre, caster)
	return TRUE
