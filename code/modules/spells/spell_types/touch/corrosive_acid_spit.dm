/datum/action/cooldown/spell/touch/corrosive_acid_spit
	name = "Corrosive acid"
	desc = "Spit acid on someone in range, this acid melts through nearly anything and heavily damages anyone lacking proper safety equipment."
	hand_path = /obj/item/melee/touch_attack/alien/corrosive_acid
	button_icon_state = "alien_acid"
	background_icon_state = "bg_alien"
	check_flags = AB_CHECK_CONSCIOUS
	invocation_type = INVOCATION_NONE
	invocation = ""
	spell_requirements = NONE
	draw_message = span_noticealien_alt("You vomit acid in your hand and prepare to use it.")
	drop_message = span_noticealien_alt("You decide not to use acid for now...")
	cooldown_time = 1
	var/plasma_cost = 200
	var/acid_power = 400

/datum/action/cooldown/spell/touch/corrosive_acid_spit/create_new_handler()
	var/datum/spell_handler/alien/handler = new(src)
	return handler

/datum/action/cooldown/spell/touch/corrosive_acid_spit/is_valid_target(atom/cast_on)
	if(isalien(cast_on))
		return FALSE
	return TRUE

/// Remove second can_cast_spell so we wont check plasma cost again
/datum/action/cooldown/spell/touch/corrosive_acid_spit/can_hit_with_hand(atom/victim, mob/living/caster)
	if(!can_cast_on_self && victim == caster)
		return FALSE
	if(!is_valid_target(victim))
		return FALSE
	if(!(caster.mobility_flags & MOBILITY_USE))
		caster.balloon_alert(caster, "can't reach out!")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/touch/corrosive_acid_spit/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	var/mob/living/carbon/alien/alien_caster = caster

	if(!victim.acid_act(acid_power, 100))
		to_chat(alien_caster, span_noticealien("You cannot dissolve this object."))
		return FALSE
	playsound(victim, 'sound/items/welder.ogg', 150, TRUE)
	caster.visible_message(span_alertalien("[alien_caster] vomits globs of vile stuff all over [victim]. It begins to sizzle and melt under the bubbling mess of acid!"))
	add_attack_logs(alien_caster, victim, "Applied corrosive acid") // Want this logged
	alien_caster.adjust_alien_plasma(-plasma_cost)
	return TRUE

/datum/action/cooldown/spell/touch/corrosive_acid_spit/sentinel
	plasma_cost = 150

/datum/action/cooldown/spell/touch/corrosive_acid_spit/praetorian
	plasma_cost = 100

/datum/action/cooldown/spell/touch/corrosive_acid_spit/queen
	plasma_cost = 50
	acid_power = 1000

/obj/item/melee/touch_attack/alien/corrosive_acid
	name = "Corrosive acid"
	desc = "A fistfull of death."
	icon_state = "alien_acid"
