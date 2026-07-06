#define INJECT_LARVA_COOLDOWN 10 MINUTES
#define IMPREGNATION_PROCESS_TIME 5 SECONDS

/datum/action/cooldown/spell/list_target/impregnate
	name = "Inject Embryo"
	desc = "Impregnate your victim with Alien Embryo."
	spell_requirements = NONE
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "alien_hide"
	background_icon_state = "bg_alien"
	cooldown_time = INJECT_LARVA_COOLDOWN
	target_radius = 1
	var/impregnated = FALSE

/datum/action/cooldown/spell/list_target/impregnate/create_new_handler()
	var/datum/spell_handler/alien/H = new
	return H

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

	if(!do_after(owner, IMPREGNATION_PROCESS_TIME, victim, max_interact_count = 1))
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
	. = ..()

/datum/action/cooldown/spell/list_target/impregnate/after_cast(atom/cast_on)
	if(!impregnated)
		reset_spell_cooldown()
	impregnated = FALSE
	. = ..()


#undef INJECT_LARVA_COOLDOWN
#undef IMPREGNATION_PROCESS_TIME
