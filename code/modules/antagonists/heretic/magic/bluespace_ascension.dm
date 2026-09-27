
/datum/action/cooldown/spell/aoe/bluespace_stasis
	name = "Стазис"
	desc = "Вырывает всех не-еретиков и все снаряды в радиусе шести плиток из течения времени на четыре секунды. \
			Застывшие неуязвимы и не могут действовать, но вы свободно перемещаетесь между ними. \
			Навредить застывшему нельзя — зато \"Пространственная Рокировка\" работает как обычно, \
			а \"Расплетение Формы\" снимает стазис с цели и развязывает нить."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "bluespace_stasis"

	sound = 'sound/magic/voidblink.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 45 SECONDS

	invocation = "СТ'З'С!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	aoe_radius = 6
	var/stasis_duration = 4 SECONDS


/datum/action/cooldown/spell/aoe/bluespace_stasis/get_things_to_cast_on(atom/center, radius_override)
	var/list/stuff = list()
	for(var/mob/living/frozen in range(radius_override || aoe_radius, center))
		if(frozen == owner || IS_HERETIC_OR_MONSTER(frozen))
			continue

		stuff += frozen

	return stuff


/datum/action/cooldown/spell/aoe/bluespace_stasis/cast(atom/cast_on)
	. = ..()
	var/mob/living/caster = owner
	if(!caster)
		return FALSE

	for(var/mob/living/frozen as anything in get_things_to_cast_on(get_turf(caster)))
		frozen.apply_status_effect(/datum/status_effect/bluespace_stasis)

	for(var/obj/projectile/stalled in range(aoe_radius, caster))
		stalled.paused = TRUE
		addtimer(VARSET_CALLBACK(stalled, paused, FALSE), stasis_duration)

	new /obj/effect/temp_visual/bluespace_collapse(get_turf(caster))
	return TRUE


/datum/action/cooldown/spell/spatial_rewind
	name = "Откат Пространства"
	desc = "Запоминает положение существ и незакреплённых предметов в радиусе семи плиток. \
			Через пять секунд область откатывается: все не-еретики возвращаются на прежние места, \
			получают тридцать урона по выносливости и два Разлома. \
			Здоровье, раны, реагенты и содержимое карманов не откатываются."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "spatial_rewind"

	sound = 'sound/magic/timeparadox2.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 60 SECONDS

	invocation = "'ТК'Т!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	var/rewind_range = 7
	var/rewind_delay = 5 SECONDS


/datum/action/cooldown/spell/spatial_rewind/cast(atom/cast_on)
	. = ..()
	var/mob/living/caster = owner
	if(!caster)
		return FALSE

	var/list/snapshot = list()
	for(var/atom/movable/recorded in range(rewind_range, caster))
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
		new /obj/effect/temp_visual/bluespace_marker/selection(snapshot[recorded])

	caster.visible_message(span_danger("Пространство вокруг [caster.declent_ru(GENITIVE)] начинает помнить себя прежним!"))
	addtimer(CALLBACK(src, PROC_REF(roll_back), caster, snapshot), rewind_delay)
	return TRUE


/datum/action/cooldown/spell/spatial_rewind/proc/roll_back(mob/living/caster, list/snapshot)
	for(var/atom/movable/restored as anything in snapshot)
		if(QDELETED(restored))
			continue
		var/turf/remembered = snapshot[restored]
		if(!remembered || remembered.density)
			continue

		restored.forceMove(remembered)
		new /obj/effect/temp_visual/bluespace_collapse(remembered)

		if(!isliving(restored))
			continue
		var/mob/living/living_restored = restored
		living_restored.adjustStaminaLoss(30)
		give_spatial_instability(living_restored, caster)
		give_spatial_instability(living_restored, caster)
		to_chat(living_restored, span_userdanger("Пространство откатывается назад, и вы вместе с ним!"))

	playsound(get_turf(caster), pick(GLOB.bluespace_collapse_sounds), 70, TRUE)


/datum/action/cooldown/spell/pointed/bluespace_banish
	name = "Изгнание в Блюспейс"
	desc = "Втягивает в разлом существо без сознания, которое только что пережило схлопывание. \
			Через три секунды оно перестаёт существовать. Изгнание прерывается, если цель придёт в себя, \
			уйдёт из поля зрения или если вы потеряете возможность поддерживать заклинание."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "bluespace_banish"

	sound = 'sound/magic/disintegrate.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 90 SECONDS

	invocation = "'ЗГН'Н'!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	active_msg = "Вы выбираете существо, которому больше нет места в этом мире..."
	var/banish_time = 3 SECONDS
	var/banish_range = 7


/datum/action/cooldown/spell/pointed/bluespace_banish/is_valid_target(atom/cast_on)
	if(!isliving(cast_on) || cast_on == owner)
		return FALSE
	var/mob/living/living_target = cast_on
	if(IS_HERETIC_OR_MONSTER(living_target) || living_target.mob_size > MOB_SIZE_HUMAN)
		return FALSE
	return is_collapsed(living_target)


/datum/action/cooldown/spell/pointed/bluespace_banish/proc/is_collapsed(mob/living/target)
	return target.stat != CONSCIOUS && target.has_status_effect(/datum/status_effect/collapse_immunity)


/datum/action/cooldown/spell/pointed/bluespace_banish/cast(mob/living/cast_on)
	. = ..()
	var/mob/living/caster = owner
	if(!caster || !isliving(cast_on))
		return FALSE

	cast_on.visible_message(span_userdanger("Вокруг [cast_on.declent_ru(GENITIVE)] раскрывается разлом!"))
	new /obj/effect/temp_visual/bluespace_banish(get_turf(cast_on))
	cast_on.add_atom_colour(COLOR_CYAN, TEMPORARY_COLOUR_PRIORITY)
	playsound(cast_on, 'sound/magic/disintegrate.ogg', 60, TRUE)
	to_chat(caster, span_hierophant("Изнанка принимает вашу подачу."))
	addtimer(CALLBACK(src, PROC_REF(finish_banishment), caster, cast_on), banish_time)
	return TRUE


/datum/action/cooldown/spell/pointed/bluespace_banish/proc/finish_banishment(mob/living/caster, mob/living/cast_on)
	if(QDELETED(cast_on))
		return

	cast_on.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_CYAN)
	if(QDELETED(caster) || caster.incapacitated() || !caster.can_see(cast_on, banish_range) || !is_collapsed(cast_on))
		cast_on.balloon_alert_to_viewers("разлом затягивается")
		to_chat(caster, span_warning("Мир держит цель слишком крепко — изнанка её не приняла."))
		return

	cast_on.visible_message(span_userdanger("[DECLENT_RU_CAP(cast_on, NOMINATIVE)] распадается на осколки света и исчезает!"))
	cast_on.dust()
