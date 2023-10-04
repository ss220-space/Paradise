//Visibility Flags
#define VISIBLE 0
#define HIDDEN_HUD 1
#define HIDDEN_SCANNER	2
#define HIDDEN_PANDEMIC	4

//Spread Flags
#define NON_CONTAGIOUS 0	//disease can't spread
#define SPECIAL 1	 		//disease can spread in specially created procs
#define BLOOD 2		 		//disease can spread with infected blood
#define CONTACT 4	 		//disease can spread with any touch
#define AIRBORNE 8	 		//disease spreads through the air

//Severity Defines
#define NONTHREAT	"No threat"
#define MINOR		"Minor"
#define MEDIUM		"Medium"
#define HARMFUL		"Harmful"
#define DANGEROUS 	"Dangerous!"
#define BIOHAZARD	"BIOHAZARD THREAT!"

GLOBAL_LIST_INIT(diseases, subtypesof(/datum/disease))

/datum/disease
	//Flags
	var/visibility_flags = VISIBLE
	var/spread_flags = NON_CONTAGIOUS

	//Fluff
	var/form = "Virus"
	var/name = "No disease"
	var/desc = ""
	var/agent = "some microbes"
	var/spread_text = ""
	var/cure_text = ""

	//Stages
	var/stage = 1
	var/max_stages = 0
	var/stage_prob = 4
	/// The fraction of stages the virus must at least be at to show up on medical HUDs. Rounded up.
	var/discovery_threshold = 0.5
	/// If TRUE, this virus will show up on medical HUDs. Automatically set when it reaches mid-stage.
	var/discovered = FALSE

	//Cure & immunity
	var/curable = TRUE
	var/list/cures = list() //list of cures if the disease has curable = TRUE, these are reagent ids
	var/needs_all_cures = TRUE
	var/cure_chance = 8
	var/can_immunity = TRUE //immunity can be developed from the disease
	var/ignore_immunity = FALSE //Does it skip species VIRUSIMMUNE check? Some things may diseases and not viruses
	var/virus_heal_resistant = FALSE // immunity to Anti-Bodies Metabolism symptom

	//Mutations
	var/mutation_chance = 1
	var/list/mutation_reagents = list("mutagen")
	var/list/possible_mutations

	//Infectivity
	var/infectivity = 65  //affects how often the virus will try to spread
	var/permeability_mod = 1
	var/carrier = FALSE //If our host is only a carrier

	//Other
	var/severity = NONTHREAT
	var/mob/living/affected_mob //Mob that is suffering from this virus
	var/list/viable_mobtypes = list(/mob/living/carbon/human) //Types of infectable mobs
	var/list/required_organs = list()
	var/list/strain_data = list() //dna_spread special bullshit

/datum/disease/Destroy()
	affected_mob = null
	GLOB.active_diseases.Remove(src)
	return ..()

/datum/disease/proc/stage_act()
	var/cure = has_cure()

	if(carrier && !cure)
		return TRUE

	stage = min(stage, max_stages)

	if(!cure)
		if(prob(stage_prob))
			stage = min(stage + 1,max_stages)
			if(!discovered && stage >= CEILING(max_stages * discovery_threshold, 1)) // Once we reach a late enough stage, medical HUDs can pick us up even if we regress
				discovered = TRUE
				affected_mob.med_hud_set_status()
	else
		if(prob(cure_chance))
			stage = max(stage - 1, 1)

	if(curable)
		if(cure && prob(cure_chance))
			cure()
			return FALSE

	if(possible_mutations && prob(mutation_chance))
		mutate()

	return TRUE


/datum/disease/proc/has_cure()
	if(!curable)
		return 0

	. = cures.len
	for(var/C_id in cures)
		if(!affected_mob.reagents.has_reagent(C_id))
			.--
	if(!. || (needs_all_cures && . < cures.len))
		return 0

/datum/disease/proc/spread(force_spread = 0)
	if(!affected_mob)
		return

	if((spread_flags <= BLOOD) && !force_spread)
		return

	if(affected_mob.reagents.has_reagent("spaceacillin") || (affected_mob.satiety > 0 && prob(affected_mob.satiety/10)))
		return

	var/spread_range = 1

	if(force_spread)
		spread_range = force_spread

	if(spread_flags & AIRBORNE)
		spread_range++

	var/turf/T = affected_mob.loc
	if(istype(T))
		for(var/mob/living/carbon/C in oview(spread_range, affected_mob))
			var/turf/V = get_turf(C)
			if(V)
				while(TRUE)
					if(V == T)
						C.ContractDisease(src)
						break
					var/turf/Temp = get_step_towards(V, T)
					if(!V.CanAtmosPass(Temp))
						break
					V = Temp

/datum/disease/proc/Contract(mob/M)
	var/datum/disease/D = new type()
	M.viruses += D
	D.affected_mob = M
	GLOB.active_diseases += D //Add it to the active diseases list, now that it's actually in a mob and being processed.

	//Copy properties over. This is so edited diseases persist.
	var/list/skipped = list("affected_mob","holder","carrier","stage","type","parent_type","vars","transformed")
	for(var/V in D.vars)
		if(V in skipped)
			continue
		if(istype(D.vars[V],/list))
			var/list/L = vars[V]
			D.vars[V] = L.Copy()
		else
			D.vars[V] = vars[V]

	D.affected_mob.med_hud_set_status()
	return

/datum/disease/proc/cure(resistance = TRUE)
	if(affected_mob)
		if(can_immunity)
			if(!(type in affected_mob.resistances))
				affected_mob.resistances += type
		remove_virus()
	qdel(src)

/datum/disease/proc/IsSame(datum/disease/D)
	if(src.type == D.type)
		return 1
	return 0


/datum/disease/proc/Copy()
	var/datum/disease/D = new type()
	D.strain_data = strain_data.Copy()
	return D


/datum/disease/proc/GetDiseaseID()
	return type

//don't use this proc directly. this should only ever be called by cure() //nope
/datum/disease/proc/remove_virus()
	affected_mob.viruses -= src		//remove the datum from the list
	affected_mob.med_hud_set_status()

/datum/disease/proc/mutate()
	var/datum/reagents/reagents = affected_mob.reagents
	if(!reagents.reagent_list.len)
		return
	for(var/R in mutation_reagents)
		if(!reagents.has_reagent(R))
			return

	//Here we have all the necessary reagents in affected_mob
	var/type = pick(possible_mutations)
	if(type)
		remove_virus()
		affected_mob.ForceContractDisease(new type)
		qdel(src)

