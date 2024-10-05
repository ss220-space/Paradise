/datum/borer_focus
	var/bodypartname = "Focus"
	var/cost = 0
	var/datum/antagonist/borer/parent
	var/movable_granted = FALSE
	var/is_catathonic = FALSE // Ckey isn't a constant value. So, check only on this.

/datum/borer_focus/New(mob/living/simple_animal/borer/borer)
	parent = borer.antag_datum

/datum/borer_focus/proc/tick(seconds_between_ticks)
	return

/datum/borer_focus/proc/grant_movable_effect()
	return

/datum/borer_focus/proc/remove_movable_effect()
	return

/datum/borer_focus/Destroy(force)
	parent = null
	return ..()

/datum/borer_focus/head
	bodypartname = "Head focus"
	cost = HEAD_FOCUS_COST
	
/datum/borer_focus/torso
	bodypartname = "Body focus"
	cost = TORSO_FOCUS_COST
	var/obj/item/organ/internal/heart/linked_organ
	
/datum/borer_focus/hands
	bodypartname = "Hands focus"
	cost = HANDS_FOCUS_COST
	
/datum/borer_focus/legs
	bodypartname = "Legs focus"
	cost = LEGS_FOCUS_COST
	
/datum/borer_focus/head/grant_movable_effect()
	if(!is_catathonic)
		parent.host.physiology.brain_mod *= 0.85
		parent.host.physiology.hunger_mod *= 0.75
		parent.host.stam_regen_start_modifier *= 0.875
		return TRUE

	parent.host.physiology.brain_mod *= 0.7
	parent.host.physiology.hunger_mod *= 0.5
	parent.host.stam_regen_start_modifier *= 0.75
	return TRUE

/datum/borer_focus/head/remove_movable_effect()
	if(!is_catathonic)
		parent.host.physiology.brain_mod /= 0.85
		parent.host.physiology.hunger_mod /= 0.75
		parent.host.stam_regen_start_modifier /= 0.875
		return TRUE

	parent.previous_host.physiology.brain_mod /= 0.7
	parent.previous_host.physiology.hunger_mod /= 0.3
	parent.previous_host.stam_regen_start_modifier /= 0.75
	return TRUE

/datum/borer_focus/head/tick(seconds_between_ticks)
	if(!parent.user.controlling && parent.host?.stat != DEAD)
		parent.host?.adjustBrainLoss(-1)
			
/datum/borer_focus/torso/grant_movable_effect()
	if(!is_catathonic)
		parent.host.physiology.brute_mod *= 0.9
		return TRUE

	parent.host.physiology.brute_mod *= 0.8
	return TRUE

/datum/borer_focus/torso/remove_movable_effect()
	if(!is_catathonic)
		parent.host.physiology.brute_mod /= 0.9
		return TRUE

	parent.previous_host.physiology.brute_mod /= 0.8
	return TRUE

/datum/borer_focus/torso/tick(seconds_between_ticks)
	if(parent.host?.stat == DEAD)
		return

	linked_organ = parent.host?.get_int_organ(/obj/item/organ/internal/heart)
	if(!linked_organ)
		return

	parent.host?.set_heartattack(FALSE)

/datum/borer_focus/torso/Destroy(force)
	linked_organ = null
	return ..()
		
/datum/borer_focus/hands/grant_movable_effect()
	parent.host.add_actionspeed_modifier(/datum/actionspeed_modifier/borer_arm_focus)
	parent.host.physiology.punch_damage_low += 7
	parent.host.physiology.punch_damage_high += 5
	parent.host.next_move_modifier *= 0.75
	return TRUE

/datum/borer_focus/hands/remove_movable_effect()
	parent.previous_host.remove_actionspeed_modifier(/datum/actionspeed_modifier/borer_arm_focus)
	parent.previous_host.physiology.punch_damage_low -= 7
	parent.previous_host.physiology.punch_damage_high -= 5	
	parent.previous_host.next_move_modifier /= 0.75
	return TRUE
	
/datum/borer_focus/legs/grant_movable_effect()
	if(!is_catathonic)
		parent.host.add_movespeed_modifier(/datum/movespeed_modifier/borer_leg_focus/lesser)
		return TRUE

	parent.host.add_movespeed_modifier(/datum/movespeed_modifier/borer_leg_focus)
	return TRUE

/datum/borer_focus/legs/remove_movable_effect()
	if(!is_catathonic)
		parent.previous_host.remove_movespeed_modifier(/datum/movespeed_modifier/borer_leg_focus/lesser)
		return TRUE

	parent.previous_host.remove_movespeed_modifier(/datum/movespeed_modifier/borer_leg_focus)
	return TRUE
