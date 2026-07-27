/obj/effect/proc_holder/spell/realignment
	name = "Перестройка"
	desc = "Перестроив свой организм, вы быстро восстановите выносливость и уменьшите время \
			оглушения или ошеломления. Вы не можете атаковать, пока заклинание активно. \
			Можно применять несколько раз подряд, но каждое применение \
			увеличивает время перезарядки."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/hud/implants.dmi'
	action_icon_state = "adrenal"

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 6 SECONDS
	invocation = "П'Р'СТР'ЙК"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	/// Current ramp level (0 = base cooldown). Climbs with each cast, decays over time.
	var/realign_level = 0
	/// How many times the cooldown can ramp up.
	var/realign_max_level = 10
	/// How much each ramp level adds to the cooldown.
	var/realign_cooldown_step = 6 SECONDS


/obj/effect/proc_holder/spell/realignment/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/realignment/valid_target(atom/cast_on)
	return isliving(cast_on)


/obj/effect/proc_holder/spell/realignment/cast(list/targets, mob/user = usr)
	var/mob/living/cast_on = targets[1]
	. = ..()
	cast_on.apply_status_effect(/datum/status_effect/realignment)
	to_chat(cast_on, span_notice("Вы начали перестраивать свой организм."))


/obj/effect/proc_holder/spell/realignment/after_cast(list/targets, mob/user)
	. = ..()
	if(!level_realignment())
		return
	var/reduction_timer = max(cooldown_handler.recharge_duration * realign_max_level * 0.5, 1.5 MINUTES)
	addtimer(CALLBACK(src, PROC_REF(delevel_realignment)), reduction_timer)


/// Ramps the cooldown up a level. Returns TRUE if it actually changed (i.e. not already capped).
/obj/effect/proc_holder/spell/realignment/proc/level_realignment()
	if(realign_level >= realign_max_level)
		return FALSE
	realign_level++
	cooldown_handler.recharge_duration = min(base_cooldown + realign_cooldown_step * realign_level, base_cooldown * realign_max_level)
	return TRUE


/// Walks the cooldown back down a level. Scheduled on a delay after each cast.
/obj/effect/proc_holder/spell/realignment/proc/delevel_realignment()
	if(realign_level <= 0)
		return
	realign_level--
	cooldown_handler.recharge_duration = max(base_cooldown + realign_cooldown_step * realign_level, base_cooldown)


/datum/status_effect/realignment
	id = "realigment"
	status_type = STATUS_EFFECT_REFRESH
	duration = 8 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/realignment
	tick_interval = 0.2 SECONDS
	show_duration = TRUE
	///Traits to add/remove
	var/list/realignment_traits = list(TRAIT_BATON_RESISTANCE, TRAIT_PACIFISM)


/datum/status_effect/realignment/get_examine_text()
	return span_notice("[GEND_HIS_HER_CAP(owner)] глаза слегка мерцают.")


/datum/status_effect/realignment/on_apply()
	owner.add_traits(realignment_traits, TRAIT_STATUS_EFFECT(id))
	owner.add_filter(id, 2, list("type" = "outline", "color" = "#d6e3e7", "size" = 2))
	var/filter = owner.get_filter(id)
	animate(filter, alpha = 127, time = 1 SECONDS, loop = -1)
	animate(alpha = 63, time = 2 SECONDS)
	return TRUE


/datum/status_effect/realignment/on_remove()
	owner.remove_traits(realignment_traits, TRAIT_STATUS_EFFECT(id))
	owner.remove_filter(id)


/datum/status_effect/realignment/tick(seconds_between_ticks)
	owner.adjustStaminaLoss(-10)
	owner.AdjustAllImmobility(-1 SECONDS)


/atom/movable/screen/alert/status_effect/realignment
	name = "Перестройка"
	desc = "Вы перестроили свой организм. Вы не можете атаковать, но быстро восстанавливаете выносливость."
	icon_state = "realignment"
