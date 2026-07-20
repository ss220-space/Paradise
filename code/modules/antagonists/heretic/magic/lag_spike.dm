
/obj/effect/proc_holder/spell/pointed/lag_spike
	name = "Скачок Задержки"
	desc = "Разворачивает область задержки 5x5 на выбранной точке. \
			Все, кроме вас и ваших прислужников, двигаются и действуют внутри неё медленнее и периодически застывают. \
			Пролетающие снаряды тоже вязнут. Первое попадание каждой жертвы в поле оставляет Runtime Error."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "lag_spike"

	sound = 'sound/magic/heretic/beyond/beyond_glitch.ogg'
	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 45 SECONDS

	invocation = "З'Д'РЖК'!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	cast_range = 6
	active_msg = "Вы выбираете точку, где мир перестанет успевать..."


/obj/effect/proc_holder/spell/pointed/lag_spike/valid_target(atom/cast_on, mob/user)
	return !isnull(get_turf(cast_on))


/obj/effect/proc_holder/spell/pointed/lag_spike/cast(list/targets, mob/user = usr)
	var/mob/living/caster = action?.owner
	var/turf/epicentre = get_turf(targets[1])
	if(!caster || !epicentre)
		return FALSE

	create_lag_field(epicentre, caster)
	return TRUE
