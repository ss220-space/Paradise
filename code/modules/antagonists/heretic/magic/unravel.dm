
#define UNRAVEL_OBLIVION_CHOICE "Беспамятство"

/obj/effect/proc_holder/spell/pointed/unravel
	name = "Расплетение Формы"
	desc = "Показывает нити, которыми выбранное существо привязано к миру, и позволяет временно развязать одну из них. \
			Одновременно на цели может держаться только одно расплетение, и каждое проверяется магической защитой."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "unravel"

	sound = 'sound/magic/ethereal_enter.ogg'
	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 55 SECONDS
	should_recharge_after_cast = FALSE

	invocation = "Р'СПЛ'Т' Ф'РМ'!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	active_msg = "Вы выбираете существо, чьи нити хотите увидеть..."
	var/static/list/unravel_threads = list(
		"Пространственный Якорь" = /datum/status_effect/unravelled/anchor,
		"Расфазировка" = /datum/status_effect/unravelled/phase,
		"Преломление" = /datum/status_effect/unravelled/refract,
	)
	var/static/list/thread_icons = list(
		"Пространственный Якорь" = "unravel_anchor",
		"Расфазировка" = "unravel_phase",
		"Преломление" = "unravel_refract",
		UNRAVEL_OBLIVION_CHOICE = "unravel_oblivion",
	)


/obj/effect/proc_holder/spell/pointed/unravel/valid_target(atom/cast_on, mob/user)
	if(!isliving(cast_on) || cast_on == user)
		return FALSE
	var/mob/living/living_target = cast_on
	return !IS_HERETIC_OR_MONSTER(living_target)


/obj/effect/proc_holder/spell/pointed/unravel/cast(list/targets, mob/user = usr)
	var/mob/living/caster = action?.owner
	var/mob/living/cast_on = targets[1]
	if(!caster || !isliving(cast_on))
		return FALSE

	if(cast_on.can_block_magic(MAGIC_RESISTANCE))
		to_chat(caster, span_warning("Нити [cast_on.declent_ru(GENITIVE)] закрыты от вас!"))
		return FALSE

	if(cast_on.has_status_effect(/datum/status_effect/unravelled))
		to_chat(caster, span_warning("Одна нить [cast_on.declent_ru(GENITIVE)] уже развязана."))
		return FALSE

	var/picked = pick_thread(caster, cast_on)
	if(!picked)
		return FALSE

	if(QDELETED(cast_on) || get_dist(caster, cast_on) > cast_range)
		to_chat(caster, span_warning("Цель ускользнула из области видимости."))
		return FALSE

	cast_on.remove_status_effect(/datum/status_effect/bluespace_stasis)

	if(picked == UNRAVEL_OBLIVION_CHOICE)
		return knock_out(caster, cast_on)

	cast_on.apply_status_effect(unravel_threads[picked], caster)
	return TRUE


/obj/effect/proc_holder/spell/pointed/unravel/proc/knock_out(mob/living/caster, mob/living/cast_on)
	cast_on.SetSleeping(2 SECONDS)
	if(!cast_on.IsSleeping())
		to_chat(caster, span_warning("Эта нить [cast_on.declent_ru(GENITIVE)] не поддаётся."))
		return FALSE

	cast_on.remove_status_effect(/datum/status_effect/spatial_instability)
	cast_on.apply_status_effect(/datum/status_effect/collapse_immunity)
	cast_on.balloon_alert_to_viewers("проваливается в беспамятство")
	playsound(cast_on, pick(GLOB.bluespace_collapse_sounds), 50, TRUE)
	return TRUE


/obj/effect/proc_holder/spell/pointed/unravel/after_cast(list/targets, mob/user)
	. = ..()
	cooldown_handler.start_recharge()


/obj/effect/proc_holder/spell/pointed/unravel/proc/pick_thread(mob/living/caster, mob/living/cast_on)
	var/list/choices = list()
	for(var/label in unravel_threads)
		choices[label] = image('icons/mob/actions/actions_ecult.dmi', thread_icons[label])

	var/datum/status_effect/spatial_instability/rifts = cast_on.has_status_effect(/datum/status_effect/spatial_instability)
	if(rifts?.rifts >= BLUESPACE_MAX_INSTABILITY - 1)
		choices[UNRAVEL_OBLIVION_CHOICE] = image('icons/mob/actions/actions_ecult.dmi', thread_icons[UNRAVEL_OBLIVION_CHOICE])

	return show_radial_menu(
		caster,
		cast_on,
		choices,
		radius = 38,
		custom_check = CALLBACK(src, PROC_REF(check_menu), caster),
		autopick_single_option = FALSE,
		tooltips = TRUE,
	)


/obj/effect/proc_holder/spell/pointed/unravel/proc/check_menu(mob/living/caster)
	if(QDELETED(caster))
		return FALSE
	return !caster.incapacitated()

#undef UNRAVEL_OBLIVION_CHOICE
