// Перестройка. It's like Fleshmend but solely for stamina damage and stuns. Sec meta
/obj/effect/proc_holder/spell/realignment
	name = "Перестройка"
	desc = "Realign yourself, rapidly regenerating stamina and reducing any stuns or knockdowns. \
		You cannot attack while realigning. Can be casted multiple times in short succession, but each cast lengthens the cooldown."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/hud/implants.dmi'
	action_icon_state = "adrenal"
	// sound = 'sound/effects/magic/whistlereset.ogg' I have no idea why this was commented out

	school = SCHOOL_FORBIDDEN
	clothes_req = FALSE
	base_cooldown = 6 SECONDS
	//cooldown_reduction_per_rank = -6 SECONDS // we're not a wizard spell but we use the levelling mechanic
	//spell_max_level = 10 // we can get up to / over a minute duration cd time

	invocation = "R'S'T."
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE


/obj/effect/proc_holder/spell/realignment/valid_target(atom/cast_on)
	return isliving(cast_on)


/obj/effect/proc_holder/spell/realignment/cast(mob/living/cast_on)
	. = ..()
	cast_on.apply_status_effect(/datum/status_effect/realignment)
	to_chat(cast_on, span_notice("We begin to realign ourselves."))


/datum/status_effect/realignment
	id = "realigment"
	status_type = STATUS_EFFECT_REFRESH
	duration = 8 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/realignment
	tick_interval = 0.2 SECONDS
	//show_duration = TRUE
	///Traits to add/remove
	var/list/realignment_traits = list(TRAIT_BATON_RESISTANCE, TRAIT_PACIFISM)


/datum/status_effect/realignment/get_examine_text()
	return span_notice("[genderize_ru(owner.gender, "Его", "Её", "Его", "Их")] глаза слегка мерцают.")


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
	desc = "You're realignment yourself. You cannot attack, but are rapidly regenerating stamina."
	icon_state = "realignment"
