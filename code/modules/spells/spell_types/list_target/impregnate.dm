/datum/action/cooldown/spell/list_target/impregnate
	name = "Inject Embryo"
	desc = "Impregnate your victim with Alien Embryo."
	spell_requirements = NONE
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "alien_hide"
	background_icon_state = "bg_alien"
	cooldown_time = XENO_VECTOR_INJECT_COOLDOWN
	target_radius = 1
	var/impregnated = FALSE

/datum/action/cooldown/spell/list_target/impregnate/create_new_handler()
	var/datum/spell_handler/alien/handler = new(src)
	return handler

/datum/action/cooldown/spell/list_target/impregnate/get_list_targets(atom/center, target_radius)
	var/list/targets = list()
	for(var/mob/living/carbon/human/target in range(target_radius, center))
		if(owner.pulling != target)
			continue
		if(owner.grab_state < GRAB_AGGRESSIVE)
			to_chat(owner, span_warning("Схватите цель крепче!"))
			continue
		targets += target
	return targets

/datum/action/cooldown/spell/list_target/impregnate/proc/can_impregnate(mob/living/carbon/human/victim)
	if(victim.is_mouth_covered())
		to_chat(owner, span_warning("Victim's mouth is obstructed!"))
		return FALSE
	if(!victim.check_has_mouth())
		to_chat(owner, span_warning("It appears victim doesn't have mouth..."))
		return FALSE
	if(victim.is_dead())
		to_chat(owner, span_warning("Victim is dead!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/list_target/impregnate/proc/impregnate(mob/living/carbon/human/victim)
	if(!victim)
		to_chat(owner, span_warning("No victims found"))
		return

	if(!do_after(owner, 5 SECONDS, victim, max_interact_count = 1))
		to_chat(owner, span_danger("Victim managed to escape!"))
		return

	if(!victim.get_int_organ(/obj/item/organ/internal/body_egg/alien_embryo))
		new /obj/item/organ/internal/body_egg/alien_embryo(victim)
		to_chat(owner, span_notice("You have impregnated your victim."))
		to_chat(victim, span_danger("You feel something is wrong..."))
		impregnated = TRUE
		return

/datum/action/cooldown/spell/list_target/impregnate/cast(atom/cast_on)
	if(!can_impregnate(cast_on))
		return
	impregnate(cast_on)
	return ..()

/datum/action/cooldown/spell/list_target/impregnate/after_cast(atom/cast_on)
	if(!impregnated)
		reset_spell_cooldown()
	impregnated = FALSE
	return ..()

#undef XENO_VECTOR_INJECT_COOLDOWN
