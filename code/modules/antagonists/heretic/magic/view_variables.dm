
#define VV_UNCONSCIOUS_CHOICE "stat = UNCONSCIOUS"

/obj/effect/proc_holder/spell/pointed/view_variables
	name = "Просмотр Переменных"
	desc = "Открывает список свойств выбранного существа и позволяет временно переписать одно из них. \
			Одновременно на цели может действовать только одна правка, и каждая проверяется магической защитой."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "view_variables"

	sound = 'sound/machines/terminal_button01.ogg'
	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 55 SECONDS
	should_recharge_after_cast = FALSE

	invocation = "П'К'Ж'М'Н' СВ'ЙСТВ'!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	active_msg = "Вы выбираете существо, чьи свойства хотите прочесть..."
	var/static/list/editable_variables = list(
		"anchored = TRUE" = /datum/status_effect/beyond_variable/anchored,
		"density = FALSE" = /datum/status_effect/beyond_variable/density,
		"alpha = 0" = /datum/status_effect/beyond_variable/alpha,
	)
	var/static/list/variable_icons = list(
		"anchored = TRUE" = "vv_anchored",
		"density = FALSE" = "vv_density",
		"alpha = 0" = "vv_alpha",
		VV_UNCONSCIOUS_CHOICE = "vv_unconscious",
	)


/obj/effect/proc_holder/spell/pointed/view_variables/valid_target(atom/cast_on, mob/user)
	if(!isliving(cast_on) || cast_on == user)
		return FALSE
	var/mob/living/living_target = cast_on
	return !IS_HERETIC_OR_MONSTER(living_target)


/obj/effect/proc_holder/spell/pointed/view_variables/cast(list/targets, mob/user = usr)
	var/mob/living/caster = action?.owner
	var/mob/living/cast_on = targets[1]
	if(!caster || !isliving(cast_on))
		return FALSE

	if(cast_on.can_block_magic(MAGIC_RESISTANCE))
		to_chat(caster, span_warning("Свойства [cast_on.declent_ru(GENITIVE)] закрыты для чтения!"))
		return FALSE

	if(cast_on.has_status_effect(/datum/status_effect/beyond_variable))
		to_chat(caster, span_warning("Одно свойство [cast_on.declent_ru(GENITIVE)] уже переписано."))
		return FALSE

	var/picked = pick_variable(caster, cast_on)
	if(!picked)
		return FALSE

	if(QDELETED(cast_on) || get_dist(caster, cast_on) > cast_range)
		to_chat(caster, span_warning("Цель ускользнула из области видимости."))
		return FALSE

	if(picked == VV_UNCONSCIOUS_CHOICE)
		knock_out(caster, cast_on)
		return TRUE

	cast_on.apply_status_effect(editable_variables[picked], caster)
	return TRUE


/obj/effect/proc_holder/spell/pointed/view_variables/proc/knock_out(mob/living/caster, mob/living/cast_on)
	cast_on.remove_status_effect(/datum/status_effect/runtime_error)
	cast_on.apply_status_effect(/datum/status_effect/crash_immunity)
	cast_on.SetSleeping(2 SECONDS)
	cast_on.balloon_alert_to_viewers("stat = UNCONSCIOUS")
	playsound(cast_on, pick(GLOB.beyond_glitch_sounds), 50, TRUE)


/obj/effect/proc_holder/spell/pointed/view_variables/after_cast(list/targets, mob/user)
	. = ..()
	cooldown_handler.start_recharge()


/obj/effect/proc_holder/spell/pointed/view_variables/proc/pick_variable(mob/living/caster, mob/living/cast_on)
	var/list/choices = list()
	for(var/label in editable_variables)
		choices[label] = image('icons/mob/actions/actions_ecult.dmi', variable_icons[label])

	var/datum/status_effect/runtime_error/errors = cast_on.has_status_effect(/datum/status_effect/runtime_error)
	if(errors?.errors >= BEYOND_MAX_RUNTIME_ERRORS - 1)
		choices[VV_UNCONSCIOUS_CHOICE] = image('icons/mob/actions/actions_ecult.dmi', variable_icons[VV_UNCONSCIOUS_CHOICE])

	return show_radial_menu(
		caster,
		cast_on,
		choices,
		radius = 38,
		custom_check = CALLBACK(src, PROC_REF(check_menu), caster),
		autopick_single_option = FALSE,
		tooltips = TRUE,
	)


/obj/effect/proc_holder/spell/pointed/view_variables/proc/check_menu(mob/living/caster)
	if(QDELETED(caster))
		return FALSE
	return !caster.incapacitated()

#undef VV_UNCONSCIOUS_CHOICE
