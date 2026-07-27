
/obj/effect/proc_holder/spell/pointed/spatial_swap
	name = "Пространственная Рокировка"
	desc = "Позволяет выбрать два объекта или существа и поменять их местами. \
			Обе цели должны быть на виду, не дальше девяти плиток от вас и не дальше девяти плиток друг от друга. \
			Каждая перемещённая жертва получает Разлом."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "spatial_swap"

	sound = 'sound/magic/blink.ogg'
	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 25 SECONDS
	should_recharge_after_cast = FALSE

	invocation = "Р'К'Р'ВК'!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 9
	active_msg = "Вы выделяете первый объект для рокировки..."
	var/datum/weakref/first_target_ref
	var/datum/weakref/caster_ref
	var/selection_timer
	var/image/selection_outline
	var/max_swap_distance = 9


/obj/effect/proc_holder/spell/pointed/spatial_swap/Destroy()
	clear_selection()
	return ..()


/obj/effect/proc_holder/spell/pointed/spatial_swap/should_remove_click_intercept(mob/user)
	return FALSE


/obj/effect/proc_holder/spell/pointed/spatial_swap/valid_target(atom/cast_on, mob/user)
	if(cast_on == first_target_ref?.resolve())
		return FALSE
	if(isliving(cast_on))
		var/mob/living/living_target = cast_on
		return living_target.mob_size <= MOB_SIZE_HUMAN
	if(!ismovable(cast_on) || isturf(cast_on))
		return FALSE
	var/atom/movable/movable_target = cast_on
	if(movable_target.anchored || !isturf(movable_target.loc))
		return FALSE
	return TRUE


/obj/effect/proc_holder/spell/pointed/spatial_swap/cast(list/targets, mob/user = usr)
	var/mob/living/caster = action?.owner
	var/atom/movable/picked = targets[1]
	if(!caster || !ismovable(picked))
		return FALSE

	var/atom/movable/first_target = first_target_ref?.resolve()
	if(!first_target)
		select_first(caster, picked)
		return TRUE

	. = perform_swap(caster, first_target, picked)
	remove_ranged_ability(caster)


/obj/effect/proc_holder/spell/pointed/spatial_swap/after_cast(list/targets, mob/user)
	. = ..()
	if(first_target_ref)
		return
	cooldown_handler.start_recharge()


/obj/effect/proc_holder/spell/pointed/spatial_swap/proc/select_first(mob/living/caster, atom/movable/picked)
	first_target_ref = WEAKREF(picked)
	caster_ref = WEAKREF(caster)
	selection_outline = image('icons/effects/eldritch.dmi', picked, "bluespace_mark", ABOVE_LIGHTING_PLANE)
	selection_outline.appearance_flags |= RESET_ALPHA
	SET_PLANE_EXPLICIT(selection_outline, ABOVE_LIGHTING_PLANE, picked)
	caster.client?.images |= selection_outline
	picked.balloon_alert(caster, "выделено")
	to_chat(caster, span_hierophant("Точка, в которой находится [picked.declent_ru(NOMINATIVE)], у вас в руках. Выберите вторую цель."))
	selection_timer = addtimer(CALLBACK(src, PROC_REF(selection_expired), caster), 5 SECONDS, TIMER_STOPPABLE)


/obj/effect/proc_holder/spell/pointed/spatial_swap/proc/selection_expired(mob/living/caster)
	clear_selection()
	to_chat(caster, span_warning("Выделение сброшено."))
	remove_ranged_ability(caster)
	cooldown_handler.start_recharge()


/obj/effect/proc_holder/spell/pointed/spatial_swap/proc/clear_selection()
	var/mob/living/caster = caster_ref?.resolve()
	caster?.client?.images -= selection_outline
	selection_outline = null
	first_target_ref = null
	caster_ref = null
	if(!selection_timer)
		return
	deltimer(selection_timer)
	selection_timer = null


/obj/effect/proc_holder/spell/pointed/spatial_swap/proc/perform_swap(mob/living/caster, atom/movable/first_target, atom/movable/second_target)
	clear_selection()

	var/turf/first_turf = get_turf(first_target)
	var/turf/second_turf = get_turf(second_target)

	if(!first_turf || !second_turf || first_turf.z != second_turf.z)
		to_chat(caster, span_warning("Цели находятся в разных пространствах."))
		return FALSE

	if(get_dist(first_turf, second_turf) > max_swap_distance)
		to_chat(caster, span_warning("Цели слишком далеко друг от друга."))
		return FALSE

	if(first_turf.density || second_turf.density)
		to_chat(caster, span_warning("Одна из точек назначения непригодна."))
		return FALSE

	for(var/atom/movable/swapped as anything in list(first_target, second_target))
		if(!isliving(swapped))
			continue
		var/mob/living/living_swapped = swapped
		if(living_swapped == caster || !living_swapped.can_block_magic(MAGIC_RESISTANCE))
			continue
		to_chat(caster, span_warning("[DECLENT_RU_CAP(living_swapped, NOMINATIVE)] сопротивляется рокировке!"))
		return FALSE

	new /obj/effect/temp_visual/bluespace_marker(first_turf)
	new /obj/effect/temp_visual/bluespace_marker(second_turf)

	first_target.forceMove(second_turf)
	second_target.forceMove(first_turf)

	for(var/atom/movable/swapped as anything in list(first_target, second_target))
		if(!isliving(swapped) || swapped == caster)
			continue
		give_spatial_instability(swapped, caster)

	playsound(first_turf, 'sound/magic/swap.ogg', 50, TRUE)
	playsound(second_turf, 'sound/magic/swap.ogg', 50, TRUE)

	for(var/obj/effect/bluespace_double/spent in list(first_target, second_target))
		qdel(spent)

	return TRUE
