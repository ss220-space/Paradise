#define MORPH_AMBUSH_PERFECTION_TIME 10 SECONDS

/datum/action/cooldown/spell/morph_ambush
	name = "Подготовить засаду"
	desc = "Первый удар нанесёт значительно больше урона и ослабит цель. Работает только в изменённой форме. Если цель попытается взаимодействовать с вами руками, вы нанесёте ещё больше урона. \
			Если вы простоите на месте ещё 10 секунд, ваша маскировка станет идеальной."
	button_icon_state = "morph_ambush"
	background_icon_state = "bg_morph"
	cooldown_time = 8 SECONDS
	spell_requirements = NONE

/datum/action/cooldown/spell/morph_ambush/create_new_handler()
	var/datum/spell_handler/morph/handler = new
	return handler

/datum/action/cooldown/spell/morph_ambush/can_cast_spell(feedback)
	. = ..()
	if(!.)
		return FALSE
	if(!ismorph(owner))
		return FALSE
	var/mob/living/simple_animal/hostile/morph/morph = owner
	if(!morph.morphed)
		if(feedback)
			morph.balloon_alert(morph, "нужна маскировка!")
		return FALSE
	if(morph.ambush_prepared)
		if(feedback)
			morph.balloon_alert(morph, "вы уже подготовлены!")
		return FALSE
	return TRUE

/datum/action/cooldown/spell/morph_ambush/cast(atom/cast_on)
	. = ..()
	var/mob/living/simple_animal/hostile/morph/user = cast_on
	to_chat(user, span_sinister("Вы начинаете готовить засаду..."))
	if(!do_after(user, 6 SECONDS, user, ALL, extra_checks = CALLBACK(src, PROC_REF(prepare_check), user)))
		if(!user.morphed)
			to_chat(user, span_warning("Вам нужно оставаться в изменённой форме, чтобы подготовить засаду!"))
			return
		to_chat(user, span_warning("Вам нужно стоять на месте, чтобы подготовить засаду!"))
		return
	user.prepare_ambush()

/datum/action/cooldown/spell/morph_ambush/proc/prepare_check(mob/living/simple_animal/hostile/morph/user)
	return user.morphed

/datum/status_effect/morph_ambush
	id = "morph_ambush"
	tick_interval = MORPH_AMBUSH_PERFECTION_TIME
	alert_type = /atom/movable/screen/alert/status_effect/morph_ambush

/datum/status_effect/morph_ambush/tick(seconds_between_ticks)
	STOP_PROCESSING(SSfastprocess, src)
	var/mob/living/simple_animal/hostile/morph/M = owner
	M.perfect_ambush()
	linked_alert.name = "Идеальная засада!"
	linked_alert.desc = "Вы подготовили засаду! Ваша маскировка безупречна!"

/atom/movable/screen/alert/status_effect/morph_ambush
	name = "Засада!"
	desc = "Вы подготовили засаду!"
	icon_state = "morph_ambush"

#undef MORPH_AMBUSH_PERFECTION_TIME

