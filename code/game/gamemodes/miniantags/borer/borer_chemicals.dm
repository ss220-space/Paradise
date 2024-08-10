#define TICKS_TO_MATURE 300
#define TICKS_TO_ADULT 420
#define TICKS_TO_ELDER 600

/datum/borer_datum
	var/mob/living/simple_animal/borer/user // our borer
	var/mob/living/carbon/human/host // our host

/datum/borer_datum/New(mob/living/simple_animal/borer/borer)
	if(!istype(borer))
		qdel(src)
	user = borer
	if(user.host)
		host = user.host
		
	on_apply()
	
/datum/borer_datum/Destroy(force)
	user = null
	host = null
	return ..()
	
/datum/borer_datum/proc/on_apply()
	return

/datum/borer_datum/processing/New(mob/living/simple_animal/borer/borer)
	..()
	START_PROCESSING(SSprocessing, src)
	RegisterSignal(user, COMSIG_MOB_DEATH, PROC_REF(on_mob_death)) // to stop our processing after death
	RegisterSignal(user, COMSIG_LIVING_REVIVE, PROC_REF(on_mob_revive)) // to start our processing after revive

/datum/borer_datum/processing/Destroy(force)
	STOP_PROCESSING(SSprocessing, src)
	UnregisterSignal(user, COMSIG_MOB_DEATH)
	UnregisterSignal(user, COMSIG_LIVING_REVIVE)
	return ..()

/datum/borer_datum/processing/proc/on_mob_death()
	SIGNAL_HANDLER
	STOP_PROCESSING(SSprocessing, src)

/datum/borer_datum/processing/proc/on_mob_revive()
	SIGNAL_HANDLER
	START_PROCESSING(SSprocessing, src)

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

/datum/borer_datum/processing/borer_rank
	var/rankname = "Error"
	var/grow_time = 0 // how many time we need to gain new rank

/datum/borer_datum/processing/borer_rank/young
	rankname = "Young"
	grow_time = TICKS_TO_MATURE 

/datum/borer_datum/processing/borer_rank/mature
	rankname = "Mature"
	grow_time = TICKS_TO_ADULT 

/datum/borer_datum/processing/borer_rank/adult
	rankname = "Adult"
	grow_time = TICKS_TO_ELDER 

/datum/borer_datum/processing/borer_rank/elder
	rankname = "Elder"

/datum/borer_datum/processing/borer_rank/young/on_apply()
	user.update_transform(0.5)

/datum/borer_datum/processing/borer_rank/mature/on_apply()
	user.update_transform(2)
	user.maxHealth += 5

/datum/borer_datum/processing/borer_rank/adult/on_apply()
	user.maxHealth += 5

/datum/borer_datum/processing/borer_rank/elder/on_apply()
	user.maxHealth += 10

/datum/borer_datum/processing/borer_rank/young/process()
	user.adjustHealth(-0.1)

/datum/borer_datum/processing/borer_rank/mature/process()
	user.adjustHealth(-0.15)

/datum/borer_datum/processing/borer_rank/adult/process()
	user.adjustHealth(-0.2)
	if(host?.stat != DEAD && !user.sneaking)
		user.chemicals += 0.2

/datum/borer_datum/processing/borer_rank/elder/process()
	user.adjustHealth(-0.3)
	if(host?.stat != DEAD)
		host.heal_overall_damage(0.4,0.4)
		if(!user.sneaking)
			user.chemicals += 0.3

#undef TICKS_TO_MATURE
#undef TICKS_TO_ADULT
#undef TICKS_TO_ELDER