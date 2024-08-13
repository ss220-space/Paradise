#define REPRODUCTIONS_TO_MATURE 3
#define REPRODUCTIONS_TO_ADULT 6
#define REPRODUCTIONS_TO_ELDER 10
#define FLAG_PROCESS (1<<0) // processing datum
#define FLAG_HOST_REQUIRED (1<<1) // essential if we handle host
#define FLAG_HAS_HOST_EFFECT (1<<2) // if we applying something to host and want to transfer these effects between hosts.
/// processing flags
#define SHOULD_PROCESS_AFTER_DEATH (1<<0) // Doesn't register signals, process even borer is dead.

/datum/borer_datum
	var/mob/living/simple_animal/borer/user // our borer
	var/mob/living/carbon/human/host // our host
	var/mob/living/carbon/human/previous_host // previous host, used to del transferable effects from previous host.
	var/flags = NONE
	var/processing_flags = NONE

/datum/borer_datum/New(mob/living/simple_animal/borer/borer)
	if(!borer)
		qdel(src)
	Grant(borer)

/datum/borer_datum/proc/Grant(mob/living/simple_animal/borer/borer)
	user = borer
	host = borer.host
	if(QDELETED(user) || !on_apply())
		qdel(src)
		return FALSE
	if((flags & FLAG_HOST_REQUIRED) || (flags & FLAG_HAS_HOST_EFFECT)) // important to change host value.
		RegisterSignal(user, COMSIG_BORER_ENTERED_HOST, PROC_REF(check_host))
		RegisterSignal(user, COMSIG_BORER_LEFT_HOST, PROC_REF(check_host)) 
	if((flags & FLAG_HAS_HOST_EFFECT) && (host)) 
		previous_host = borer.host
		host_handle_buff()
	if(flags & FLAG_PROCESS)
		if(!(processing_flags & SHOULD_PROCESS_AFTER_DEATH))
			RegisterSignal(user, COMSIG_MOB_DEATH, PROC_REF(on_mob_death)) 
			RegisterSignal(user, COMSIG_LIVING_REVIVE, PROC_REF(on_mob_revive))
			if(user.stat != DEAD)
				START_PROCESSING(SSprocessing, src)
			return TRUE
		START_PROCESSING(SSprocessing, src)
	return TRUE

/datum/borer_datum/proc/check_host()
	SIGNAL_HANDLER
	host = user.host
	if(flags & FLAG_HAS_HOST_EFFECT)
		var/update_previous_host = FALSE
		switch(host) 
			if(TRUE)
				if(host_handle_buff()) // use host.
					update_previous_host = TRUE
			if(FALSE)
				if(host_handle_buff(FALSE)) // use previous_host to delete buff from previous host.
					update_previous_host = TRUE
		if(update_previous_host)
			previous_host = host

/datum/borer_datum/proc/host_handle_buff(grant = TRUE) // if we want transferable effects between hosts.
	return TRUE

/datum/borer_datum/Destroy(force)
	if((flags & FLAG_HOST_REQUIRED) || (flags & FLAG_HAS_HOST_EFFECT))
		UnregisterSignal(user, COMSIG_BORER_ENTERED_HOST)
		UnregisterSignal(user, COMSIG_BORER_LEFT_HOST)
	if((flags & FLAG_HAS_HOST_EFFECT) && (previous_host))
		host_handle_buff(FALSE)
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
	START_PROCESSING(SSprocessing, src)

/datum/borer_datum/miscellaneous // category for small datums.

/datum/borer_datum/miscellaneous/change_host_and_scale
	var/list/used_ckeys = list()
	flags = FLAG_HAS_HOST_EFFECT

/datum/borer_datum/miscellaneous/change_host_and_scale/New(mob/living/simple_animal/borer/borer)
	if(!borer)
		qdel(src)

/datum/borer_datum/miscellaneous/change_host_and_scale/host_handle_buff(grant = TRUE)
	if(grant && host?.ckey && !locate(host?.ckey) in used_ckeys)
		user.max_chems += 10
		used_ckeys += host.ckey

	return TRUE

/datum/borer_datum/miscellaneous/change_host_and_scale/Destroy(force)
	LAZYNULL(used_ckeys)
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

/datum/borer_datum/borer_rank/young/process()
	user.adjustHealth(-0.1)

/datum/borer_datum/borer_rank/mature/process()
	user.adjustHealth(-0.15)

/datum/borer_datum/borer_rank/adult/process()
	user.adjustHealth(-0.2)
	if(host?.stat != DEAD && !user.sneaking)
		user.chemicals += 0.2

/datum/borer_datum/borer_rank/elder/process()
	user.adjustHealth(-0.3)
	if(host?.stat != DEAD)
		host?.heal_overall_damage(0.4, 0.4)
		user.chemicals += 0.3

/datum/borer_datum/focus
	var/bodypartname = "Focus"
	var/cost = 250
	flags = FLAG_HAS_HOST_EFFECT
	
/datum/borer_datum/focus/head
	bodypartname = "Head focus"
	flags = FLAG_HAS_HOST_EFFECT|FLAG_PROCESS
	
/datum/borer_datum/focus/torso
	bodypartname = "Body focus"
	flags = FLAG_HAS_HOST_EFFECT|FLAG_PROCESS
	
/datum/borer_datum/focus/hands
	bodypartname = "Hands focus"
	
/datum/borer_datum/focus/legs
	bodypartname = "Legs focus"
	
/datum/borer_datum/focus/head/host_handle_buff(grant = TRUE)
	switch(grant)
		if(TRUE)
			host?.physiology.brain_mod *= 0.7
			host?.physiology.hunger_mod *= 0.3
		if(FALSE)
			previous_host?.physiology.brain_mod /= 0.7
			previous_host?.physiology.hunger_mod /= 0.3
	return TRUE
			
/datum/borer_datum/focus/head/process()
	if(!user.controlling && host?.stat != DEAD)
		host?.adjustBrainLoss(-1)
			
/datum/borer_datum/focus/torso/host_handle_buff(grant = TRUE)
	switch(grant)
		if(TRUE)
			host?.physiology.brute_mod *= 0.8
		if(FALSE)
			previous_host?.physiology.brute_mod /= 0.8
	return TRUE

/datum/borer_datum/focus/torso/process()
	if(host?.stat != DEAD)
		var/obj/item/organ/internal/heart/heart = host?.get_int_organ(/obj/item/organ/internal/heart)
		if(heart)
			host?.set_heartattack(FALSE)
		
/datum/borer_datum/focus/hands/host_handle_buff(grant = TRUE)
	switch(grant)
		if(TRUE)
			host?.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/species_tool_mod, multiplicative_slowdown = host.dna.species.toolspeedmod * 0.5)
			host?.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/species_surgery_mod, multiplicative_slowdown = host.dna.species.surgeryspeedmod * 0.5)
			host?.physiology.punch_damage_low += 7
			host?.physiology.punch_damage_high += 5
		if(FALSE)
			previous_host?.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/species_tool_mod, multiplicative_slowdown = previous_host.dna.species.toolspeedmod * 0.5)
			previous_host?.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/species_surgery_mod, multiplicative_slowdown = previous_host.dna.species.surgeryspeedmod * 0.5)
			previous_host?.physiology.punch_damage_low -= 7
			previous_host?.physiology.punch_damage_high -= 5
	return TRUE
	
/datum/borer_datum/focus/legs/host_handle_buff(grant = TRUE)
	switch(grant)
		if(TRUE)
			host?.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/species_speedmod, multiplicative_slowdown = host.dna.species.speed_mod - 0.5)
		if(FALSE)
			previous_host?.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/species_speedmod, multiplicative_slowdown = previous_host.dna.species.speed_mod + 0.5)
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
#undef FLAG_PROCESS
#undef FLAG_HOST_REQUIRED 
#undef FLAG_HAS_HOST_EFFECT 
#undef SHOULD_PROCESS_AFTER_DEATH
