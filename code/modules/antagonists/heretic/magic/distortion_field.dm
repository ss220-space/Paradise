
/datum/action/cooldown/spell/pointed/distortion_field
	name = "Поле Искажения"
	desc = "Растягивает пространство в области 5x5 на выбранной точке. \
			Все, кроме вас и ваших прислужников, двигаются и действуют внутри неё медленнее и периодически застревают. \
			Пролетающие снаряды тоже вязнут. Первое попадание каждой жертвы в поле оставляет Разлом."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "distortion_field"

	sound = 'sound/effects/empulse.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 45 SECONDS

	invocation = "'СК'Ж'Н'!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	cast_range = 6
	active_msg = "Вы выбираете точку, где пространство станет длиннее..."


/datum/action/cooldown/spell/pointed/distortion_field/is_valid_target(atom/cast_on)
	return !isnull(get_turf(cast_on))


/datum/action/cooldown/spell/pointed/distortion_field/cast(atom/cast_on)
	. = ..()
	var/mob/living/caster = owner
	var/turf/epicentre = get_turf(cast_on)
	if(!caster || !epicentre)
		return FALSE

	create_distortion_field(epicentre, caster)
	return TRUE
