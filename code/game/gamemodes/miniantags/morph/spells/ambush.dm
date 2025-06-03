#define MORPH_AMBUSH_PERFECTION_TIME 10 SECONDS


/obj/effect/proc_holder/spell/morph_spell/ambush
	name = "Подготовить засаду"
	desc = "Первый удар нанесёт значительно больше урона и ослабит цель. Работает только в изменённой форме. Если цель попытается взаимодействовать с вами руками, вы нанесёте ещё больше урона. \
			Если вы простоите на месте ещё 10 секунд, ваша маскировка станет идеальной."
	action_icon_state = "morph_ambush"
	base_cooldown = 8 SECONDS


/obj/effect/proc_holder/spell/morph_spell/ambush/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/morph_spell/ambush/can_cast(mob/living/simple_animal/hostile/morph/user, charge_check, show_message)
	. = ..()
	if(!.)
		return
	if(!user.morphed)
		if(show_message)
			balloon_alert(user, "нужна маскировка!")
		return FALSE
	if(user.ambush_prepared)
		if(show_message)
			balloon_alert(user, "вы уже подготовлены!")
		return FALSE


/obj/effect/proc_holder/spell/morph_spell/ambush/cast(list/targets, mob/living/simple_animal/hostile/morph/user)
	to_chat(user, span_sinister("Вы начинаете готовить засаду..."))
	if(!do_after(user, 6 SECONDS, user, ALL, extra_checks = CALLBACK(src, PROC_REF(prepare_check), user)))
		if(!user.morphed)
			to_chat(user, span_warning("Вам нужно оставаться в изменённой форме, чтобы подготовить засаду!"))
			return
		to_chat(user, span_warning("Вам нужно стоять на месте, чтобы подготовить засаду!"))
		return
	user.prepare_ambush()


/obj/effect/proc_holder/spell/morph_spell/ambush/proc/prepare_check(mob/living/simple_animal/hostile/morph/user)
	return user.morphed


/datum/status_effect/morph_ambush
	id = "morph_ambush"
	duration = -1
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

