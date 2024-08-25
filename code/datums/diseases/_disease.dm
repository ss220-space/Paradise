
GLOBAL_LIST_INIT(diseases, subtypesof(/datum/disease))

/datum/disease
	//Fluff
	var/form = "Болезнь"
	var/name = "Unknown"
	var/desc = ""
	var/agent = "some microbes"
	var/cure_text = null
	var/additional_info = "Болезнь"

	//Stages

	/// Current stage of disease
	var/stage = 1
	/// Count of stages of disease
	var/max_stages = 5
	/// Probability of moving to the next stage for a tick
	var/stage_prob = 4

	//Visibility
	var/visibility_flags = VISIBLE
	/// If NONTHREAT, not marked on HUD
	var/severity = NONTHREAT

	/// The fraction of stages the disease must at least be at to show up on medical HUDs. Rounded up.
	var/discovery_threshold = 0.5
	/// If TRUE, this disease will show up on medical HUDs. Automatically set when it reaches mid-stage.
	var/discovered = FALSE

	//Cure & immunity

	/// Сan the disease be cured
	var/curable = TRUE
	/// List of cures if the disease has curable = TRUE, these are reagent ids
	var/list/cures = list()
	/// If FASLSE, you need one of any cure from the cures list. Otherwise, you need all the cures from the cure list
	var/needs_all_cures = TRUE
	/// Probability of cure for a tick
	var/cure_prob = 8
	/// Immunity can be developed from the disease
	var/can_immunity = TRUE
	/// Does it skip TRAIT_VIRUSIMMUNE
	var/ignore_immunity = FALSE
	/// Immunity to Anti-Bodies Metabolism symptom
	var/virus_heal_resistant = FALSE
	/// Message when cured
	var/cured_message = "You feel better."

	//Mutations

	/// Probability of mutation if the necessary reagents are in the body
	var/mutation_chance = 1
	/// Necessary reagents
	var/list/mutation_reagents = list("mutagen")
	/// List of diseases in which it can mutate
	var/list/possible_mutations

	//Other

	/// Mob that is suffering from this disease
	var/mob/living/affected_mob
	/// Types of infectable mobs
	var/list/infectable_mobtypes = list(/mob/living/carbon/human)
	/// Required organs
	var/list/required_organs = list()
	/// If TRUE, disease can progress in dead mobs
	var/can_progress_in_dead = FALSE
	/// If TRUE, disease can contract dead mobs
	var/can_contract_dead = FALSE
	/// Disease can contract others, if carrier is dead with this chance. Set to 0, if can't. Must be in [0, 100].
	var/spread_from_dead_prob = 0
	/// If TRUE, host not affected by virus, but can spread it (mostly for viruses)
	var/carrier = FALSE
	/// Infectable mob types, that can only be carriers
	var/list/carrier_mobtypes = list()


/datum/disease/New()
	if(!cure_text)
		var/reagents = list()
		for(var/id in cures)
			var/datum/reagent/R = GLOB.chemical_reagents_list[id]
			if(istype(R))
				reagents += R.name
		cure_text = english_list(reagents, "Неизлечимо", needs_all_cures ? " & " : " or ")

/datum/disease/Destroy()
	affected_mob = null
	GLOB.active_diseases.Remove(src)
	return ..()


/**
 * Main disease process, that executed every tick
 *
 * Returns:
 * * TRUE - if process finished the work properlly
 * * FALSE - if disease was deleted
 */
/datum/disease/proc/stage_act()
	if(!affected_mob)
		return FALSE

	if(affected_mob?.stat == DEAD && !can_progress_in_dead)
		return FALSE

	var/cure = has_cure()
	stage = min(stage, max_stages)

	if(cure)
		try_reduce_stage()
	else
		try_increase_stage()

	if(curable && cure && prob(cure_prob))
		cure()
		return FALSE

	if(possible_mutations && prob(mutation_chance))
		if(mutate())
			return FALSE
	return TRUE


/datum/disease/proc/try_increase_stage()
	if(prob(stage_prob))
		stage = min(stage + 1, max_stages)
		// Once we reach a late enough stage, medical HUDs can pick us up even if we regress
		if(!discovered && stage >= CEILING(max_stages * discovery_threshold, 1))
			discovered = TRUE
			affected_mob.med_hud_set_status()

/datum/disease/proc/try_reduce_stage()
	if(prob(cure_prob))
		stage = max(stage - 1, 1)

/**
 * Returns the number of reagents from the cures list that are in the body
 */
/datum/disease/proc/has_cure()
	. = cures.len
	for(var/C_id in cures)
		if(!affected_mob.reagents?.has_reagent(C_id))
			.--
	if(. <= 0 || (needs_all_cures && . < cures.len))
		return 0


/datum/disease/proc/cure(id = type, need_immunity = TRUE)
	if(affected_mob)
		if(can_immunity && need_immunity)
			LAZYOR(affected_mob.resistances, id)
		LAZYREMOVE(affected_mob.diseases, src)
		affected_mob.med_hud_set_status()
		if(cured_message)
			to_chat(affected_mob, span_notice(cured_message))
	qdel(src)


/**
 * Basic checks of the possibility of infecting a mob
 */
/datum/disease/proc/CanContract(mob/living/M, act_type, need_protection_check, zone)
	. = FALSE
	if(!M.CanContractDisease(src))
		return FALSE

	if(M.stat == DEAD && !can_contract_dead)
		return FALSE

	if(LAZYIN(M.resistances, GetDiseaseID()))
		return FALSE

	if(M.HasDisease(src))
		return FALSE

	for(var/mobtype in infectable_mobtypes + carrier_mobtypes)
		if(istype(M, mobtype))
			. = TRUE

	if(. && need_protection_check && M.CheckVirusProtection(src, act_type, zone))
		. = FALSE

	return

/**
 * Attempt to infect a mob
 * Arguments:
 * * act_type - type of contract. Can be BITES, CONTACT, AIRBORNE or combination of them, for example CONTACT|AIRBORNE
 * * is_carrier - make this mob a carrier of the virus
 * * need_protection_check - check mob's clothing, internals, special masks etc
 * * zone - zone of contact ("l_leg", "head", etc or /obj/item/organ/external)
 * Returns:
 * * /datum/disease/D - a new instance of the virus that contract the mob
 * * FALSE - otherwise
 */
/datum/disease/proc/Contract(mob/living/M, act_type, is_carrier = FALSE, need_protection_check = FALSE, zone)
	if(!CanContract(M, act_type, need_protection_check, zone))
		return FALSE

	var/datum/disease/D = Copy()
	LAZYADD(M.diseases, D)
	D.affected_mob = M
	GLOB.active_diseases += D
	D.carrier = is_carrier
	D.affected_mob.med_hud_set_status()
	return D


/datum/disease/proc/IsSame(datum/disease/D)
	if(src.type == D.type)
		return TRUE
	return FALSE


/datum/disease/proc/Copy()
	var/datum/disease/D = new type()
	return D


/datum/disease/proc/GetDiseaseID()
	return type

/**
 * Transform a disease into another, if the requirements are met
 *
 * Returns:
 * * TRUE - if mutation was succesful
 * * FALSE - otherwise
 */
/datum/disease/proc/mutate()
	var/datum/reagents/reagents = affected_mob.reagents
	if(!reagents || !length(reagents.reagent_list))
		return FALSE
	for(var/R in mutation_reagents)
		if(!reagents.has_reagent(R))
			return FALSE

	//Here we have all the necessary reagents in affected_mob
	var/type = pick(possible_mutations)
	if(type)
		LAZYREMOVE(affected_mob.diseases, src)
		affected_mob.med_hud_set_status()
		var/datum/disease/new_disease = new type
		new_disease.Contract(affected_mob)
		qdel(src)
		return TRUE

