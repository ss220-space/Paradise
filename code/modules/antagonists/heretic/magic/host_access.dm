
/obj/effect/proc_holder/spell/aoe/host_pause
	name = "Pause()"
	desc = "Останавливает всех не-еретиков и все снаряды в радиусе шести плиток на четыре секунды. \
			Остановленные неуязвимы и не могут действовать, но вы свободно перемещаетесь между ними. \
			Навредить замершему нельзя — зато \"Подмена Ссылок\" и \"Просмотр Переменных\" работают как обычно."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "host_pause"

	sound = 'sound/machines/terminal_alert.ogg'
	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 45 SECONDS

	invocation = "P'AUSE()"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	aoe_range = 6
	var/pause_duration = 4 SECONDS


/obj/effect/proc_holder/spell/aoe/host_pause/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/aoe/host_pause/get_things_to_cast_on(atom/center, radius_override)
	var/list/stuff = list()
	for(var/mob/living/frozen in range(radius_override || aoe_range, center))
		if(frozen == action.owner || IS_HERETIC_OR_MONSTER(frozen))
			continue

		stuff += frozen

	return stuff


/obj/effect/proc_holder/spell/aoe/host_pause/cast(list/targets, mob/user = usr)
	var/mob/living/caster = action?.owner
	if(!caster)
		return FALSE

	for(var/mob/living/frozen as anything in get_things_to_cast_on(get_turf(caster)))
		frozen.apply_status_effect(/datum/status_effect/beyond_paused)

	for(var/obj/projectile/stalled in range(aoe_range, caster))
		stalled.paused = TRUE
		addtimer(VARSET_CALLBACK(stalled, paused, FALSE), pause_duration)

	new /obj/effect/temp_visual/beyond_crash(get_turf(caster))
	return TRUE


/obj/effect/proc_holder/spell/reboot_area
	name = "Reboot Area()"
	desc = "Запоминает положение существ и незакреплённых предметов в радиусе семи плиток. \
			Через пять секунд область перезагружается: все не-еретики возвращаются на прежние места, \
			получают тридцать урона по выносливости и два Runtime Error. \
			Здоровье, раны, реагенты и содержимое карманов не откатываются."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "reboot_area"

	sound = 'sound/magic/heretic/beyond/beyond_error.ogg'
	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 60 SECONDS

	invocation = "R'EBOOT()"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	var/reboot_range = 7
	var/reboot_delay = 5 SECONDS


/obj/effect/proc_holder/spell/reboot_area/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/reboot_area/cast(list/targets, mob/user = usr)
	var/mob/living/caster = action?.owner
	if(!caster)
		return FALSE

	var/list/snapshot = list()
	for(var/atom/movable/recorded in range(reboot_range, caster))
		if(recorded == caster || recorded.anchored || !isturf(recorded.loc))
			continue
		if(!isliving(recorded) && !isitem(recorded))
			continue
		if(isliving(recorded))
			var/mob/living/living_recorded = recorded
			if(IS_HERETIC_OR_MONSTER(living_recorded))
				continue
		snapshot[recorded] = get_turf(recorded)

	if(!length(snapshot))
		return FALSE

	for(var/atom/movable/recorded as anything in snapshot)
		new /obj/effect/temp_visual/beyond_select/selection(snapshot[recorded])

	caster.visible_message(span_danger("Воздух вокруг [caster.declent_ru(GENITIVE)] начинает повторять последний кадр!"))
	addtimer(CALLBACK(src, PROC_REF(roll_back), caster, snapshot), reboot_delay)
	return TRUE


/obj/effect/proc_holder/spell/reboot_area/proc/roll_back(mob/living/caster, list/snapshot)
	for(var/atom/movable/restored as anything in snapshot)
		if(QDELETED(restored))
			continue
		var/turf/remembered = snapshot[restored]
		if(!remembered || remembered.density)
			continue

		restored.forceMove(remembered)
		new /obj/effect/temp_visual/beyond_crash(remembered)

		if(!isliving(restored))
			continue
		var/mob/living/living_restored = restored
		living_restored.adjustStaminaLoss(30)
		give_runtime_error(living_restored, caster)
		give_runtime_error(living_restored, caster)
		to_chat(living_restored, span_userdanger("Область перезагружается, и вы вместе с ней!"))

	playsound(get_turf(caster), pick(GLOB.beyond_glitch_sounds), 70, TRUE)


/obj/effect/proc_holder/spell/pointed/host_qdel
	name = "qdel()"
	desc = "Помечает на удаление существо, которое едва держится на ногах и недавно пережило краш. \
			Через три секунды оно перестаёт существовать. Удаление прерывается, если цель исцелится, \
			уйдёт из поля зрения или если вы потеряете возможность поддерживать заклинание."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "host_qdel"

	sound = 'sound/magic/disintegrate.ogg'
	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 90 SECONDS

	invocation = "Q'DEL()"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	active_msg = "Вы выбираете существо, которое больше не должно существовать..."
	var/deletion_time = 3 SECONDS


/obj/effect/proc_holder/spell/pointed/host_qdel/valid_target(atom/cast_on, mob/user)
	if(!isliving(cast_on) || cast_on == user)
		return FALSE
	var/mob/living/living_target = cast_on
	if(IS_HERETIC_OR_MONSTER(living_target) || living_target.mob_size > MOB_SIZE_HUMAN)
		return FALSE
	return TRUE


/obj/effect/proc_holder/spell/pointed/host_qdel/cast(list/targets, mob/user = usr)
	var/mob/living/caster = action?.owner
	var/mob/living/cast_on = targets[1]
	if(!caster || !isliving(cast_on))
		return FALSE

	cast_on.visible_message(span_userdanger("[DECLENT_RU_CAP(cast_on, NOMINATIVE)] покрывается отсутствующей текстурой!"))
	new /obj/effect/temp_visual/beyond_qdel(get_turf(cast_on))
	cast_on.add_atom_colour(COLOR_MAGENTA, TEMPORARY_COLOUR_PRIORITY)
	playsound(cast_on, 'sound/magic/disintegrate.ogg', 60, TRUE)
	to_chat(caster, span_hierophant("qdel(): force deleting corrupted mob."))
	addtimer(CALLBACK(src, PROC_REF(finish_deletion), cast_on), deletion_time)
	return TRUE


/obj/effect/proc_holder/spell/pointed/host_qdel/proc/finish_deletion(mob/living/cast_on)
	if(QDELETED(cast_on))
		return
	cast_on.visible_message(span_userdanger("[DECLENT_RU_CAP(cast_on, NOMINATIVE)] распадается на пиксели и исчезает!"))
	cast_on.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_MAGENTA)
	cast_on.dust()
