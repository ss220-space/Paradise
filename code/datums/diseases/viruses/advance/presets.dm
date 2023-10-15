// Cold
/datum/disease/virus/advance/preset/sneezing
	name = "Sneezing"
	symptoms = list(new/datum/symptom/sneeze)

// Flu
/datum/disease/virus/advance/preset/cough
	name = "Cough"
	symptoms = list(new/datum/symptom/cough)

// Voice Changing
/datum/disease/virus/advance/preset/voice_change
	name = "Epiglottis Mutation"
	symptoms = list(new/datum/symptom/voice_change)

// Toxin Filter
/datum/disease/virus/advance/preset/heal
	name = "Liver Enhancer"
	symptoms = list(new/datum/symptom/heal)
	possible_mutations = list(/datum/disease/virus/advance/preset/advanced_regeneration, /datum/disease/virus/advance/preset/sneezing)

// Hullucigen
/datum/disease/virus/advance/preset/hullucigen
	name = "Reality Impairment"
	symptoms = list(new/datum/symptom/hallucigen)
	possible_mutations = list(/datum/disease/virus/brainrot, /datum/disease/virus/advance/preset/sensory_restoration)

// Sensory Restoration
/datum/disease/virus/advance/preset/sensory_restoration
	name = "Reality Enhancer"
	symptoms = list(new/datum/symptom/sensory_restoration)

// Mind Restoration
/datum/disease/virus/advance/preset/mind_restoration
	name = "Reality Purifier"
	symptoms = list(new/datum/symptom/mind_restoration)

// Toxic Filter + Toxic Compensation + Viral Evolutionary Acceleration
/datum/disease/virus/advance/preset/advanced_regeneration
	name = "Advanced Neogenesis"
	symptoms = list(new/datum/symptom/heal, new/datum/symptom/damage_converter, new/datum/symptom/viralevolution)

// Necrotizing Fasciitis + Viral Self-Adaptation + Eternal Youth + Dizziness
/datum/disease/virus/advance/preset/stealth_necrosis
	name = "Necroeyrosis"
	symptoms = list(new/datum/symptom/flesh_eating, new/datum/symptom/viraladaptation, new/datum/symptom/youth, new/datum/symptom/dizzy)
	mutation_reagents = list("mutagen", "histamine")
	possible_mutations = list(/datum/disease/virus/transformation/xeno)

//Facial Hypertrichosis + Voice Change + Itching
/datum/disease/virus/advance/preset/pre_kingstons
	name = "Neverlasting Stranger"
	symptoms = list(new/datum/symptom/beard, new/datum/symptom/voice_change, new/datum/symptom/itching)
	mutation_reagents = list("mutagen", "radium")
	possible_mutations = list(/datum/disease/virus/kingstons)

//Pacifist Syndrome
/datum/disease/virus/advance/preset/love
	name = "Pacifist Syndrome"
	symptoms = list(new/datum/symptom/love)

//Uncontrollable Aggression
/datum/disease/virus/advance/preset/aggression
	name = "Uncontrollable Aggression"
	symptoms = list(new/datum/symptom/aggression)

//Uncontrollable Actions
/datum/disease/virus/advance/preset/obsession
	name = "Uncontrollable Actions"
	symptoms = list(new/datum/symptom/obsession)

//Topographical Cretinism
/datum/disease/virus/advance/preset/confusion
	name = "Topographical Cretinism"
	symptoms = list(new/datum/symptom/confusion)

//Fragile Bones Syndrome
/datum/disease/virus/advance/preset/bones
	name = "Fragile Bones Syndrome"
	symptoms = list(new/datum/symptom/bones)

//Limb Rejection
/datum/disease/virus/advance/preset/limb_throw
	name = "Limb Rejection"
	symptoms = list(new/datum/symptom/limb_throw)

//Uncontrolled Laughter Effect
/datum/disease/virus/advance/preset/laugh
	name = "Uncontrolled Laughter Effect"
	symptoms = list(new/datum/symptom/laugh)

//Groaning Syndrome
/datum/disease/virus/advance/preset/moan
	name = "Groaning Syndrome"
	symptoms = list(new/datum/symptom/moan)

//Toxification syndrome
/datum/disease/virus/advance/preset/infection
	name = "Toxification syndrome"
	symptoms = list(new/datum/symptom/infection)

// Uncontrolled Laughter Effect + Groaning Syndrome + Hullucigen
/datum/disease/virus/advance/preset/pre_loyalty
	name = "Merry sufferer"
	symptoms = list(new/datum/symptom/laugh, new/datum/symptom/moan, new/datum/symptom/hallucigen)
	mutation_reagents = list("love")
	possible_mutations = list(/datum/disease/virus/loyalty)
