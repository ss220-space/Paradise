// TODO refactor when spell code is component based instead of OO based
/obj/effect/proc_holder/spell/morph_spell/pass_airlock
	name = "Пройти через шлюз"
	desc = "Изменяйте свою форму, чтобы пройти через незаблокированный шлюз. Это занимает некоторое время и может быть использовано только в вашей истинной форме."
	action_background_icon_state = "bg_morph"
	action_icon_state = "morph_airlock"
	base_cooldown = 10 SECONDS
	selection_activated_message = span_sinister("ЛКМ на шлюз, чтобы попытаться пройти через него.")
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/morph_spell/pass_airlock/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.range = 1
	T.allowed_type = /obj/machinery/door/airlock
	T.click_radius = -1
	return T


/obj/effect/proc_holder/spell/morph_spell/pass_airlock/can_cast(mob/living/simple_animal/hostile/morph/user, charge_check, show_message)
	. = ..()
	if(!.)
		return

	if(user.morphed)
		if(show_message)
			to_chat(user, span_warning("Вы можете проходить через шлюзы только в своей истинной форме!"))
			user.balloon_alert(user, "нужна истинная форма!")
		return FALSE


/obj/effect/proc_holder/spell/morph_spell/pass_airlock/cast(list/targets, mob/living/simple_animal/hostile/morph/user)
	var/obj/machinery/door/airlock/airlock = targets[1]
	if(airlock.locked)
		user.balloon_alert(user, "шлюз заблокирован!")
		revert_cast(user)
		return
	user.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] начинает протискиваться в шлюз [airlock.declent_ru(GENITIVE)]!"))
	user.balloon_alert(user, "попытка приоткрыть шлюз...")
	if(!do_after(user, 6 SECONDS, user, timed_action_flags = DEFAULT_DOAFTER_IGNORE|DA_IGNORE_INCAPACITATED|DA_IGNORE_HELD_ITEM|DA_IGNORE_EMPTY_GRIPPER, extra_checks = CALLBACK(src, PROC_REF(pass_check), user, airlock)))
		if(user.morphed)
			user.balloon_alert(user, "нужна исходная форма!")
		else if(airlock.locked)
			user.balloon_alert(user, "шлюз заблокирован!")
		else
			user.balloon_alert(user, "не двигайтесь!")
		revert_cast(user)
		return

	user.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] ненадолго приоткрывает шлюз [airlock.declent_ru(GENITIVE)] и проходит через него!"))
	user.forceMove(airlock.loc) // Move into the turf of the airlock


/obj/effect/proc_holder/spell/morph_spell/pass_airlock/proc/pass_check(mob/living/simple_animal/hostile/morph/user, obj/machinery/door/airlock/airlock)
	return !user.morphed && !airlock.locked
