	//Список используемых в генерации симптомов для вирусов
	//Цифры для "Веса" симптомов, определялись по их level-у, но инвертировано. Ака 6 = 1, 5 = 2 и т.д.
GLOBAL_LIST_INIT(quest_virus_simptoms, list(
	/datum/symptom/headache = 6,			/datum/symptom/itching = 6,
	/datum/symptom/fever = 5,				/datum/symptom/shivering = 5,
	/datum/symptom/booze = 4,				/datum/symptom/choking = 4,
	/datum/symptom/heal/longevity = 4,		/datum/symptom/heal/metabolism = 4,
	/datum/symptom/viralevolution = 4,		/datum/symptom/viraladaptation = 4,
	/datum/symptom/vomit = 4,				/datum/symptom/weakness = 4,
	/datum/symptom/weight_loss = 4,			/datum/symptom/beard = 3,
	/datum/symptom/confusion = 3,			/datum/symptom/damage_converter = 3,
	/datum/symptom/deafness = 3,			/datum/symptom/dizzy = 3,
	/datum/symptom/sensory_restoration = 3,	/datum/symptom/shedding = 3,
	/datum/symptom/vitiligo = 3,			/datum/symptom/revitiligo = 3,
	/datum/symptom/sneeze = 3,				/datum/symptom/blood = 2,
	/datum/symptom/epinephrine = 2,			/datum/symptom/hallucigen = 2,
	/datum/symptom/painkiller = 2,			/datum/symptom/mind_restoration = 2,
	/datum/symptom/visionloss = 2,			/datum/symptom/youth = 2,
	/datum/symptom/flesh_eating = 1,	//	/datum/symptom/genetic_mutation = 1, //У нас вырублен, но я оставлю это тут на всякий
	/datum/symptom/heal = 1,				/datum/symptom/oxygen = 1,
	/datum/symptom/voice_change = 1,
	))

////////////////////////////
//Прок генерирующий квест на вирус и необходимые симптомы для него
////////////////////////////
/datum/cargo_quests_storage/proc/generate_virus_info(var/datum/cargo_quest/quest)
	if(!quest)
		log_debug("Quest generation attempted without a quest datum reference!")
		return
	if(!quest.quest_difficulty)
		quest.generate_difficulty()
	log_debug("Generating quest of type \"Virus\"")
	quest.req_item = /datum/disease/advance
	quest.current_list += (GLOB.quest_virus_simptoms)
	var/symptom_count
	switch(quest.quest_difficulty)
		if(QUEST_DIFFICULTY_EASY)
			symptom_count = 4
			for(var/item in quest.current_list)
				if(quest.current_list[item] <= 2)	// Удаляем редкие симптомы
					quest.current_list -= item
		if(QUEST_DIFFICULTY_NORMAL)
			symptom_count = 5
			for(var/item in quest.current_list)
				if(quest.current_list[item] == 1)	// Удаляем самые редкие симптомы
					quest.current_list -= item
		if(QUEST_DIFFICULTY_HARD)
			symptom_count = 6
			for(var/item in quest.current_list)
				if(quest.current_list[item] >= 4)	// Удаляем самые частые симптомы
					quest.current_list -= item

	//вписать выбор нужной иконки
	for(var/i in 1 to symptom_count)
		var/current_simptom = pickweight(quest.current_list)
		log_debug("Chosen simptoms: [current_simptom]")
		quest.req_else += (current_simptom)
		quest.current_list -= current_simptom
	log_debug("Generation end")
