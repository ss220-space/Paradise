// Cold
/datum/disease/advance/preset/cold/New(var/update_archive = TRUE)
	name = "Cold"
	symptoms = list(new/datum/symptom/sneeze)
	if(update_archive)
		Refresh()

// Flu
/datum/disease/advance/preset/flu/New(var/update_archive = TRUE)
	name = "Flu"
	symptoms = list(new/datum/symptom/cough)
	if(update_archive)
		Refresh()

// Voice Changing
/datum/disease/advance/preset/voice_change/New(var/update_archive = TRUE)
	name = "Epiglottis Mutation"
	symptoms = list(new/datum/symptom/voice_change)
	if(update_archive)
		Refresh()

// Toxin Filter
/datum/disease/advance/preset/heal/New(var/update_archive = TRUE)
	name = "Liver Enhancer"
	symptoms = list(new/datum/symptom/heal)
	mutable = TRUE
	possible_mutations = list(/datum/disease/advance/preset/advanced_regeneration, /datum/disease/advance/preset/cold/)
	if(update_archive)
		Refresh(update_mutations = FALSE)

// Hullucigen
/datum/disease/advance/preset/hullucigen/New(var/update_archive = TRUE)
	name = "Reality Impairment"
	symptoms = list(new/datum/symptom/hallucigen)
	mutable = TRUE
	possible_mutations = list(/datum/disease/brainrot, /datum/disease/advance/preset/sensory_restoration)
	if(update_archive)
		Refresh(update_mutations = FALSE)

// Sensory Restoration
/datum/disease/advance/preset/sensory_restoration/New(var/update_archive = TRUE)
	name = "Reality Enhancer"
	symptoms = list(new/datum/symptom/sensory_restoration)
	if(update_archive)
		Refresh()

// Mind Restoration
/datum/disease/advance/preset/mind_restoration/New(var/update_archive = TRUE)
	name = "Reality Purifier"
	symptoms = list(new/datum/symptom/mind_restoration)
	if(update_archive)
		Refresh()

// Toxic Filter + Toxic Compensation + Viral Evolutionary Acceleration
/datum/disease/advance/preset/advanced_regeneration/New(var/update_archive = TRUE)
	name = "Advanced Neogenesis"
	symptoms = list(new/datum/symptom/heal, new/datum/symptom/damage_converter, new/datum/symptom/viralevolution)
	if(update_archive)
		Refresh()

// Necrotizing Fasciitis + Viral Self-Adaptation + Eternal Youth + Dizziness
/datum/disease/advance/preset/stealth_necrosis/New(var/update_archive = TRUE)
	name = "Necroeyrosis"
	symptoms = list(new/datum/symptom/flesh_eating, new/datum/symptom/viraladaptation, new/datum/symptom/youth, new/datum/symptom/dizzy)
	mutable = TRUE
	mutation_reagents = list("mutagen", "histamine")
	possible_mutations = list(/datum/disease/transformation/xeno)
	if(update_archive)
		Refresh(update_mutations = FALSE)

//Facial Hypertrichosis + Voice Change + Itching
/datum/disease/advance/preset/pre_kingstons/New(var/update_archive = TRUE)
	name = "Neverlasting Stranger"
	symptoms = list(new/datum/symptom/beard, new/datum/symptom/voice_change, new/datum/symptom/itching)
	mutable = TRUE
	mutation_reagents = list("mutagen", "radium")
	possible_mutations = list(/datum/disease/kingstons)
	if(update_archive)
		Refresh(update_mutations = FALSE)
