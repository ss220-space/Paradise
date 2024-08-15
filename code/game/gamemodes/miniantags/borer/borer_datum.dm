#define REPRODUCTIONS_TO_MATURE 3
#define REPRODUCTIONS_TO_ADULT 6
#define REPRODUCTIONS_TO_ELDER 10
#define HEAD_FOCUS_COST 9
#define TORSO_FOCUS_COST 15
#define HANDS_FOCUS_COST 5
#define LEGS_FOCUS_COST 10
#define SCALING_MAX_CHEM 355
#define SCALING_CHEM_GAIN 15
#define FLAG_PROCESS (1<<0) // processing datum
#define FLAG_HOST_REQUIRED (1<<1) // essential if we handle host, especially in processing.
#define FLAG_HAS_MOVABLE_EFFECT (1<<2) // Movable, nonstatic effects.
/// processing flags
#define SHOULD_PROCESS_AFTER_DEATH (1<<0) // Doesn't register signals, process even borer is dead.

/datum/borer_datum
	var/mob/living/simple_animal/borer/user // our borer
	var/mob/living/carbon/human/host // our host
	var/mob/living/carbon/human/previous_host // previous host, used to del transferable effects from previous host.
	var/flags = NONE
	var/processing_flags = NONE
	var/tick_interval = 1 SECONDS

/datum/borer_datum/New(mob/living/simple_animal/borer/borer)
	if(!borer)
		qdel(src)
	Grant(borer)

/datum/borer_datum/proc/Grant(mob/living/simple_animal/borer/borer)
	user = borer
	host = borer.host
	if(QDELETED(user))
		qdel(src)
		return FALSE
	on_apply()
	if((flags & FLAG_HOST_REQUIRED) || (flags & FLAG_HAS_MOVABLE_EFFECT)) // important to change host value.
		RegisterSignal(user, COMSIG_BORER_ENTERED_HOST, PROC_REF(entered_host))
		RegisterSignal(user, COMSIG_BORER_LEFT_HOST, PROC_REF(left_host)) 
	if((flags & FLAG_HAS_MOVABLE_EFFECT) && (host)) 
		previous_host = host
		pre_grant_movable_effect()
	if(flags & FLAG_PROCESS)
		if(tick_interval != -1)
			tick_interval = world.time + tick_interval
		if(!(tick_interval > world.time))
			return FALSE
		if(!(processing_flags & SHOULD_PROCESS_AFTER_DEATH))
			RegisterSignal(user, COMSIG_MOB_DEATH, PROC_REF(on_mob_death)) 
			RegisterSignal(user, COMSIG_LIVING_REVIVE, PROC_REF(on_mob_revive))
			if(user.stat != DEAD)
				START_PROCESSING(SSprocessing, src)
			return TRUE
		START_PROCESSING(SSprocessing, src)
	return TRUE

/datum/borer_datum/proc/entered_host()
	SIGNAL_HANDLER
	host = user.host
	if((flags & FLAG_HAS_MOVABLE_EFFECT) && (pre_grant_movable_effect()))
		previous_host = host
			
/datum/borer_datum/proc/left_host()
	SIGNAL_HANDLER
	host = null
	if((flags & FLAG_HAS_MOVABLE_EFFECT) && (pre_remove_movable_effect()))
		previous_host = host

/datum/borer_datum/proc/pre_grant_movable_effect()
	if(QDELETED(user) || QDELETED(host))
		return

	if(grant_movable_effect())
		return

/datum/borer_datum/proc/pre_remove_movable_effect()
	if(QDELETED(user) || QDELETED(previous_host))
		return

	if(remove_movable_effect())
		return

/datum/borer_datum/proc/grant_movable_effect()
	return TRUE

/datum/borer_datum/proc/remove_movable_effect()
	return TRUE

/datum/borer_datum/proc/tick(seconds_between_ticks)
	return

/datum/borer_datum/proc/host_tick(seconds_between_ticks)
	return

/datum/borer_datum/Destroy(force)
	if((flags & FLAG_HOST_REQUIRED) || (flags & FLAG_HAS_MOVABLE_EFFECT))
		UnregisterSignal(user, COMSIG_BORER_ENTERED_HOST)
		UnregisterSignal(user, COMSIG_BORER_LEFT_HOST)
	if((flags & FLAG_HAS_MOVABLE_EFFECT) && (previous_host))
		pre_remove_movable_effect()
	if(flags & FLAG_PROCESS)
		if(!(processing_flags & SHOULD_PROCESS_AFTER_DEATH))
			UnregisterSignal(user, COMSIG_MOB_DEATH)
			UnregisterSignal(user, COMSIG_LIVING_REVIVE)
		STOP_PROCESSING(SSprocessing, src)
	user = null
	host = null
	previous_host = null
	return ..()
	
/datum/borer_datum/proc/on_apply() // Apply something to BORER or untransferable effect to host.
	return TRUE

/datum/borer_datum/proc/on_mob_death()
	SIGNAL_HANDLER
	STOP_PROCESSING(SSprocessing, src)

/datum/borer_datum/proc/on_mob_revive()
	SIGNAL_HANDLER
	if(tick_interval > world.time)
		START_PROCESSING(SSprocessing, src)

/datum/borer_datum/process(seconds_per_tick)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(QDELETED(user))
		qdel(src)
		return
	if(tick_interval != -1 && tick_interval <= world.time)
		var/tick_length = initial(tick_interval)
		tick(tick_length / (1 SECONDS))
		if((flags &  FLAG_HOST_REQUIRED) && (!QDELETED(host)))
			host_tick(tick_length / (1 SECONDS))
		tick_interval = world.time + tick_length
		if(QDELING(src))
			return

/datum/borer_datum/miscellaneous // category for small datums.

/datum/borer_datum/miscellaneous/change_host_and_scale
	var/list/used_UIDs = list()
	flags = FLAG_HAS_MOVABLE_EFFECT

/datum/borer_datum/miscellaneous/change_host_and_scale/New()
	return

/datum/borer_datum/miscellaneous/change_host_and_scale/grant_movable_effect()
	if(user.max_chems >= SCALING_MAX_CHEM)
		qdel(src)
		return

	if(host.ckey && !LAZYIN(host?.UID(), used_UIDs))
		user.max_chems += SCALING_CHEM_GAIN
		used_UIDs += host.UID()

	return TRUE

/datum/borer_datum/miscellaneous/change_host_and_scale/remove_movable_effect()
	return TRUE

/datum/borer_datum/miscellaneous/change_host_and_scale/Destroy(force)
	LAZYNULL(used_UIDs)
	return ..()

/datum/borer_datum/borer_rank
	var/rankname = "Error"
	var/required_reproductions = null // how many reproductions we need to gain new rank
	flags = FLAG_PROCESS
	
/datum/borer_datum/borer_rank/young
	rankname = "Young"
	required_reproductions = REPRODUCTIONS_TO_MATURE 

/datum/borer_datum/borer_rank/mature
	rankname = "Mature"
	required_reproductions = REPRODUCTIONS_TO_ADULT 

/datum/borer_datum/borer_rank/adult
	rankname = "Adult"
	required_reproductions = REPRODUCTIONS_TO_ELDER
	flags = FLAG_PROCESS|FLAG_HOST_REQUIRED

/datum/borer_datum/borer_rank/elder
	rankname = "Elder"
	flags = FLAG_PROCESS|FLAG_HOST_REQUIRED

/datum/borer_datum/borer_rank/young/on_apply()
	user.update_transform(0.5)
	return TRUE

/datum/borer_datum/borer_rank/mature/on_apply()
	user.update_transform(2)
	user.maxHealth += 5
	return TRUE

/datum/borer_datum/borer_rank/adult/on_apply()
	user.maxHealth += 5
	return TRUE

/datum/borer_datum/borer_rank/elder/on_apply()
	user.maxHealth += 10
	return TRUE

/datum/borer_datum/borer_rank/young/tick(seconds_between_ticks)
	user.adjustHealth(-0.1)

/datum/borer_datum/borer_rank/mature/tick(seconds_between_ticks)
	user.adjustHealth(-0.15)

/datum/borer_datum/borer_rank/adult/tick(seconds_between_ticks)
	user.adjustHealth(-0.2)

/datum/borer_datum/borer_rank/adult/host_tick(seconds_between_ticks)
	if(host.stat != DEAD && !user.sneaking)
		user.chemicals += 0.2

/datum/borer_datum/borer_rank/elder/tick(seconds_between_ticks)
	user.adjustHealth(-0.3)

/datum/borer_datum/borer_rank/elder/host_tick(seconds_between_ticks)
	if(host.stat != DEAD)
		host.heal_overall_damage(0.4, 0.4)
		user.chemicals += 0.3

/datum/borer_datum/focus
	var/bodypartname = "Focus"
	var/cost = 0
	flags = FLAG_HAS_MOVABLE_EFFECT
	
/datum/borer_datum/focus/head
	bodypartname = "Head focus"
	cost = HEAD_FOCUS_COST
	flags = FLAG_HAS_MOVABLE_EFFECT|FLAG_PROCESS|FLAG_HOST_REQUIRED
	
/datum/borer_datum/focus/torso
	bodypartname = "Body focus"
	cost = TORSO_FOCUS_COST
	flags = FLAG_HAS_MOVABLE_EFFECT|FLAG_PROCESS|FLAG_HOST_REQUIRED
	var/obj/item/organ/internal/heart/linked_organ
	
/datum/borer_datum/focus/hands
	bodypartname = "Hands focus"
	cost = HANDS_FOCUS_COST
	
/datum/borer_datum/focus/legs
	bodypartname = "Legs focus"
	cost = LEGS_FOCUS_COST
	
/datum/borer_datum/focus/head/grant_movable_effect()
	host.physiology.brain_mod *= 0.7
	host.physiology.hunger_mod *= 0.3
	host.stam_regen_start_modifier *= 0.75
	return TRUE

/datum/borer_datum/focus/head/remove_movable_effect()
	previous_host.physiology.brain_mod /= 0.7
	previous_host.physiology.hunger_mod /= 0.3
	previous_host.stam_regen_start_modifier /= 0.75
	return TRUE

/datum/borer_datum/focus/head/host_tick(seconds_between_ticks)
	if(!user.controlling && host.stat != DEAD)
		host.adjustBrainLoss(-1)
			
/datum/borer_datum/focus/torso/grant_movable_effect()
	host.physiology.brute_mod *= 0.8
	return TRUE

/datum/borer_datum/focus/torso/remove_movable_effect()
	previous_host.physiology.brute_mod /= 0.8
	return TRUE

/datum/borer_datum/focus/torso/host_tick(seconds_between_ticks)
	if(host.stat != DEAD)
		linked_organ = host.get_int_organ(/obj/item/organ/internal/heart)
		if(linked_organ)
			host.set_heartattack(FALSE)

/datum/borer_datum/focus/torso/Destroy(force)
	linked_organ = null
	return ..()
		
/datum/borer_datum/focus/hands/grant_movable_effect()
	host.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/species_tool_mod, multiplicative_slowdown = -0.5)
	host.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/species_surgery_mod, multiplicative_slowdown = -0.5)
	host.physiology.punch_damage_low += 7
	host.physiology.punch_damage_high += 5
	host.next_move_modifier *= 0.75
	return TRUE

/datum/borer_datum/focus/hands/remove_movable_effect()
	previous_host.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/species_tool_mod, multiplicative_slowdown = 0.5)
	previous_host.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/species_surgery_mod, multiplicative_slowdown = 0.5)
	previous_host.physiology.punch_damage_low -= 7
	previous_host.physiology.punch_damage_high -= 5	
	previous_host.next_move_modifier /= 0.75
	return TRUE
	
/datum/borer_datum/focus/legs/grant_movable_effect()
	host.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/species_speedmod, multiplicative_slowdown = -0.25)
	return TRUE

/datum/borer_datum/focus/legs/remove_movable_effect()
	previous_host.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/species_speedmod, multiplicative_slowdown = 0.25)
	return TRUE

/datum/borer_chem
	var/chemname
	var/chemdesc = "This is a chemical"
	var/chemuse = 30
	var/quantity = 10

/datum/borer_chem/capulettium_plus
	chemname = "capulettium_plus"
	chemdesc = "Silences and masks pulse."

/datum/borer_chem/charcoal
	chemname = "charcoal"
	chemdesc = "Slowly heals toxin damage, also slowly removes other chemicals."

/datum/borer_chem/epinephrine
	chemname = "epinephrine"
	chemdesc = "Stabilizes critical condition and slowly heals suffocation damage."

/datum/borer_chem/fliptonium
	chemname = "fliptonium"
	chemdesc = "Causes uncontrollable flipping."
	chemuse = 50

/datum/borer_chem/hydrocodone
	chemname = "hydrocodone"
	chemdesc = "An extremely strong painkiller."

/datum/borer_chem/mannitol
	chemname = "mannitol"
	chemdesc = "Heals brain damage."

/datum/borer_chem/methamphetamine
	chemname = "methamphetamine"
	chemdesc = "Reduces stun times and increases stamina. Deals small amounts of brain damage."
	chemuse = 50

/datum/borer_chem/mitocholide
	chemname = "mitocholide"
	chemdesc = "Heals internal organ damage."

/datum/borer_chem/salbutamol
	chemname = "salbutamol"
	chemdesc = "Heals suffocation damage."

/datum/borer_chem/salglu_solution
	chemname = "salglu_solution"
	chemdesc = "Slowly heals brute and burn damage, also slowly restores blood."

/datum/borer_chem/spaceacillin
	chemname = "spaceacillin"
	chemdesc = "Slows progression of diseases and fights infections."

#undef REPRODUCTIONS_TO_MATURE
#undef REPRODUCTIONS_TO_ADULT
#undef REPRODUCTIONS_TO_ELDER
#undef HEAD_FOCUS_COST
#undef TORSO_FOCUS_COST
#undef HANDS_FOCUS_COST
#undef LEGS_FOCUS_COST
#undef SCALING_MAX_CHEM
#undef SCALING_CHEM_GAIN
#undef FLAG_PROCESS
#undef FLAG_HOST_REQUIRED 
#undef FLAG_HAS_MOVABLE_EFFECT 
#undef SHOULD_PROCESS_AFTER_DEATH
