// Cold

/datum/disease/advance/preset/cold/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Cold"
		symptoms = list(new/datum/symptom/sneeze)
	..(process, D, copy)


// Flu

/datum/disease/advance/preset/flu/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Flu"
		symptoms = list(new/datum/symptom/cough)
	..(process, D, copy)


// Voice Changing

/datum/disease/advance/preset/voice_change/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Epiglottis Mutation"
		symptoms = list(new/datum/symptom/voice_change)
	..(process, D, copy)


// Toxin Filter

/datum/disease/advance/preset/heal/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Liver Enhancer"
		mutable = TRUE
		possible_mutations = list(/datum/disease/advance/preset/advanced_regeneration, /datum/disease/advance/preset/cold/)
		symptoms = list(new/datum/symptom/heal)
	..(process, D, copy)


// Hullucigen

/datum/disease/advance/preset/hullucigen/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Reality Impairment"
		mutable = TRUE
		possible_mutations = list(/datum/disease/brainrot, /datum/disease/advance/preset/sensory_restoration)
		symptoms = list(new/datum/symptom/hallucigen)
	..(process, D, copy)


// Sensory Restoration

/datum/disease/advance/preset/sensory_restoration/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Reality Enhancer"
		symptoms = list(new/datum/symptom/sensory_restoration)
	..(process, D, copy)


// Mind Restoration

/datum/disease/advance/preset/mind_restoration/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Reality Purifier"
		symptoms = list(new/datum/symptom/mind_restoration)
	..(process, D, copy)


// Toxic Filter + Toxic Compensation + Viral Evolutionary Acceleration

/datum/disease/advance/preset/advanced_regeneration/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Advanced Neogenesis"
		symptoms = list(new/datum/symptom/heal, new/datum/symptom/damage_converter, new/datum/symptom/viralevolution)
	..(process, D, copy)


// Necrotizing Fasciitis + Viral Self-Adaptation + Eternal Youth + Dizziness

/datum/disease/advance/preset/stealth_necrosis/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Necroeyrosis"
		mutable = TRUE
		mutation_reagents = list("mutagen", "histamine")
		possible_mutations = list(/datum/disease/transformation/xeno)
		symptoms = list(new/datum/symptom/flesh_eating, new/datum/symptom/viraladaptation, new/datum/symptom/youth, new/datum/symptom/dizzy)
	..(process, D, copy)


//Facial Hypertrichosis + Voice Change + Itching

/datum/disease/advance/preset/pre_kingstons/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Neverlasting Stranger"
		mutable = TRUE
		mutation_reagents = list("mutagen", "radium")
		possible_mutations = list(/datum/disease/kingstons)
		symptoms = list(new/datum/symptom/beard, new/datum/symptom/voice_change, new/datum/symptom/itching)
	..(process, D, copy)
