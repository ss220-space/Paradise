// TODO refactor when spell code is component based instead of OO based
/datum/action/cooldown/spell/pointed/pass_airlock
	name = "Пройти через шлюз"
	desc = "Изменяйте свою форму, чтобы пройти через незаблокированный шлюз. Это занимает некоторое время и может быть использовано только в вашей истинной форме."
	button_icon_state = "morph_airlock"
	background_icon_state = "bg_morph"
	background_icon_state_active = "bg_morph"
	active_msg = span_sinister_alt("ЛКМ на шлюз, чтобы попытаться пройти через него.")
	spell_requirements = NONE
	cast_range = 1

/datum/action/cooldown/spell/pointed/pass_airlock/create_new_handler()
	var/datum/spell_handler/morph/handler = new
	return handler

/datum/action/cooldown/spell/pointed/pass_airlock/can_cast_spell(feedback)
	. = ..()
	if(!.)
		return FALSE
	if(!ismorph(owner))
		return FALSE
	var/mob/living/simple_animal/hostile/morph/user = owner
	if(user.morphed)
		if(feedback)
			to_chat(user, span_warning("Вы можете проходить через шлюзы только в своей истинной форме!"))
			user.balloon_alert(user, "нужна истинная форма!")
		return FALSE

/datum/action/cooldown/spell/pointed/pass_airlock/is_valid_target(atom/cast_on)
	return is_airlock(cast_on)

/datum/action/cooldown/spell/pointed/pass_airlock/cast(atom/cast_on)
	. = ..()
	var/obj/machinery/door/airlock/airlock = cast_on
	if(airlock.locked)
		owner.balloon_alert(owner, "шлюз заблокирован!")
		reset_spell_cooldown()
		return
	var/mob/living/simple_animal/hostile/morph/user = owner
	user.visible_message(span_warning("[DECLENT_RU_CAP(user, NOMINATIVE)] начинает протискиваться в шлюз [airlock.declent_ru(GENITIVE)]!"))
	user.balloon_alert(user, "попытка приоткрыть шлюз...")
	if(!do_after(user, 6 SECONDS, user, timed_action_flags = DEFAULT_DOAFTER_IGNORE|DA_IGNORE_INCAPACITATED|DA_IGNORE_HELD_ITEM|DA_IGNORE_EMPTY_GRIPPER, extra_checks = CALLBACK(src, PROC_REF(pass_check), user, airlock)))
		if(user.morphed)
			user.balloon_alert(user, "нужна исходная форма!")
		else if(airlock.locked)
			user.balloon_alert(user, "шлюз заблокирован!")
		else
			user.balloon_alert(user, "не двигайтесь!")
		reset_spell_cooldown()
		return

	user.visible_message(span_warning("[DECLENT_RU_CAP(user, NOMINATIVE)] ненадолго приоткрывает шлюз [airlock.declent_ru(GENITIVE)] и проходит через него!"))
	user.forceMove(airlock.loc) // Move into the turf of the airlock

/datum/action/cooldown/spell/pointed/pass_airlock/proc/pass_check(mob/living/simple_animal/hostile/morph/user, obj/machinery/door/airlock/airlock)
	return !user.morphed && !airlock.locked
