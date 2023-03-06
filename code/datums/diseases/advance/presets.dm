// Cold

/datum/disease/advance/cold/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Cold"
		symptoms = list(new/datum/symptom/sneeze)
	..(process, D, copy)


// Flu

/datum/disease/advance/flu/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Flu"
		symptoms = list(new/datum/symptom/cough)
	..(process, D, copy)


// Voice Changing

/datum/disease/advance/voice_change/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Epiglottis Mutation"
		symptoms = list(new/datum/symptom/voice_change)
	..(process, D, copy)


// Toxin Filter

/datum/disease/advance/heal
	mutable = TRUE
	possible_mutations = list(/datum/disease/advance/advanced_regeneration, /datum/disease/advance/cold)

/datum/disease/advance/heal/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Liver Enhancer"
		symptoms = list(new/datum/symptom/heal)
	..(process, D, copy)


// Hullucigen
/datum/disease/advance/hullucigen
	mutable = TRUE
	possible_mutations = list(/datum/disease/brainrot, /datum/disease/advance/sensory_restoration)

/datum/disease/advance/hullucigen/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Reality Impairment"
		symptoms = list(new/datum/symptom/hallucigen)
	..(process, D, copy)

// Sensory Restoration

/datum/disease/advance/sensory_restoration/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Reality Enhancer"
		symptoms = list(new/datum/symptom/sensory_restoration)
	..(process, D, copy)

// Mind Restoration

/datum/disease/advance/mind_restoration/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Reality Purifier"
		symptoms = list(new/datum/symptom/mind_restoration)
	..(process, D, copy)

// Toxic Filter + Toxic Compensation + Viral Evolutionary Acceleration

/datum/disease/advance/advanced_regeneration/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Advanced Neogenesis"
		symptoms = list(new/datum/symptom/heal, new/datum/symptom/damage_converter, new/datum/symptom/viralevolution)
	..(process, D, copy)

// Necrotizing Fasciitis + Viral Self-Adaptation + Eternal Youth + Dizziness

/datum/disease/advance/stealth_necrosis
	mutable = TRUE
	mutation_reagents = list("mutagen", "histamine")
	possible_mutations = list(/datum/disease/transformation/xeno)

/datum/disease/advance/stealth_necrosis/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Necroeyrosis"
		symptoms = list(new/datum/symptom/flesh_eating, new/datum/symptom/viraladaptation, new/datum/symptom/youth, new/datum/symptom/dizzy)
	..(process, D, copy)

//Facial Hypertrichosis + Voice Change + Itching

/datum/disease/advance/pre_kingstons
	mutable = TRUE
	mutation_reagents = list("mutagen", "radium")
	possible_mutations = list(/datum/disease/kingstons)

/datum/disease/advance/pre_kingstons/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Neverlasting Stranger"
		symptoms = list(new/datum/symptom/beard, new/datum/symptom/voice_change, new/datum/symptom/itching)
	..(process, D, copy)
