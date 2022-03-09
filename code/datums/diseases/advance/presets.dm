// Cold

/datum/disease/advance/cold/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Простуда"
		symptoms = list(new/datum/symptom/sneeze)
	..(process, D, copy)


// Flu

/datum/disease/advance/flu/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Грипп"
		symptoms = list(new/datum/symptom/cough)
	..(process, D, copy)


// Voice Changing

/datum/disease/advance/voice_change/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Мутация надгортанника"
		symptoms = list(new/datum/symptom/voice_change)
	..(process, D, copy)


// Toxin Filter

/datum/disease/advance/heal/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Усилитель печени"
		symptoms = list(new/datum/symptom/heal)
	..(process, D, copy)


// Hullucigen

/datum/disease/advance/hullucigen/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Нарушение восприятия реальности"
		symptoms = list(new/datum/symptom/hallucigen)
	..(process, D, copy)

// Sensory Restoration

/datum/disease/advance/sensory_restoration/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Улучшение восприятия реальности"
		symptoms = list(new/datum/symptom/sensory_restoration)
	..(process, D, copy)
