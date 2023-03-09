// В этом списке не должно быть органов которые обычно не достать.
// Всё должно быть более менее достижимо силами генетики, химии, ботаники и медицины
// А так же ничего механического
	/*
	Система подсчёта веса в этом списке.
	Стандартный хуман = 100
	Если орган принадлежит дионе -25
	Если орган принадлежит слайму -40
	Если орган принадлежит младшей расе(мартышки) +10
	Если орган принадлежит любой другой ксенорасе -10
	Если орган хвост -5
	Если орган внутренний - 20
	*/

GLOBAL_LIST_INIT(quest_organs_and_bodyparts, list(
	//Внешние органы
	//Встречаются в квестах чаще внутренних

	//Обычные расы, в основном хуманы
	/obj/item/organ/external/arm = 100,
	/obj/item/organ/external/arm/right = 100,
	/obj/item/organ/external/chest = 100,
	/obj/item/organ/external/foot = 100,
	/obj/item/organ/external/foot/right = 100,
	/obj/item/organ/external/groin = 100,
	/obj/item/organ/external/hand = 100,
	/obj/item/organ/external/hand/right = 100,
	/obj/item/organ/external/head = 100,
	/obj/item/organ/external/leg = 100,
	/obj/item/organ/external/leg/right = 100,
	//Дионы
	/obj/item/organ/external/arm/diona = 75,
	/obj/item/organ/external/arm/right/diona = 75,
	/obj/item/organ/external/chest/diona = 75,
	/obj/item/organ/external/foot/diona = 75,
	/obj/item/organ/external/foot/right/diona = 75,
	/obj/item/organ/external/groin/diona = 75,
	/obj/item/organ/external/hand/diona = 75,
	/obj/item/organ/external/hand/right/diona = 75,
	/obj/item/organ/external/head/diona = 75,
	/obj/item/organ/external/leg/diona = 75,
	/obj/item/organ/external/leg/right/diona = 75,
	//Слаймы
	/obj/item/organ/external/arm/unbreakable = 60,
	/obj/item/organ/external/arm/right/unbreakable = 60,
	/obj/item/organ/external/chest/unbreakable = 60,
	/obj/item/organ/external/foot/unbreakable = 60,
	/obj/item/organ/external/foot/right/unbreakable = 60,
	/obj/item/organ/external/groin/unbreakable = 60,
	/obj/item/organ/external/hand/unbreakable = 60,
	/obj/item/organ/external/hand/right/unbreakable = 60,
	/obj/item/organ/external/head/unbreakable = 60,
	/obj/item/organ/external/leg/unbreakable = 60,
	/obj/item/organ/external/leg/right/unbreakable = 60,
	//Хвосты
	/obj/item/organ/external/tail/monkey = 105,
	/obj/item/organ/external/tail/monkey/tajaran = 95,
	/obj/item/organ/external/tail/monkey/unathi = 95,
	/obj/item/organ/external/tail/monkey/vulpkanin = 95,
	/obj/item/organ/external/tail/tajaran = 85,
	/obj/item/organ/external/tail/unathi = 85,
//	/obj/item/organ/external/tail/vox = 85,
	/obj/item/organ/external/tail/vulpkanin = 85,
	// Внутренние органы
	// Квесты на них должны генериться реже

	// Обычные расы, в основном хуманы
	/obj/item/organ/internal/appendix = 80,
	/obj/item/organ/internal/brain = 80,
	/obj/item/organ/internal/ears = 80,
	/obj/item/organ/internal/eyes = 80,
	/obj/item/organ/internal/heart = 80,
	/obj/item/organ/internal/kidneys = 80,
	/obj/item/organ/internal/liver = 80,
	/obj/item/organ/internal/lungs = 80,
	//Дионы
	/obj/item/organ/internal/appendix/diona = 55,
	/obj/item/organ/internal/brain/diona = 55,
	/obj/item/organ/internal/eyes/diona = 55,
	/obj/item/organ/internal/kidneys/diona = 55,
	/obj/item/organ/internal/liver/diona = 55,
	/obj/item/organ/internal/lungs/diona = 55,
	//Таяры
	/obj/item/organ/internal/brain/tajaran = 70,
	/obj/item/organ/internal/eyes/tajaran = 70,
	/obj/item/organ/internal/heart/tajaran = 70,
	/obj/item/organ/internal/kidneys/tajaran = 70,
	/obj/item/organ/internal/liver/tajaran = 70,
	/obj/item/organ/internal/lungs/tajaran = 70,
	//Фарва
	/obj/item/organ/internal/eyes/tajaran/farwa = 80,
	//Унатхи
	/obj/item/organ/internal/brain/unathi = 70,
	/obj/item/organ/internal/eyes/unathi = 70,
	/obj/item/organ/internal/heart/unathi = 70,
	/obj/item/organ/internal/liver/unathi = 70,
	/obj/item/organ/internal/kidneys/unathi = 70,
	/obj/item/organ/internal/lungs/unathi = 70,
	//Слаймы
	/obj/item/organ/internal/brain/slime = 40,
	/obj/item/organ/internal/heart/slime = 40,
	/obj/item/organ/internal/lungs/slime= 40,
	//Вульпы
	/obj/item/organ/internal/brain/vulpkanin = 70,
	/obj/item/organ/internal/eyes/vulpkanin = 70,
	/obj/item/organ/internal/heart/vulpkanin = 70,
	/obj/item/organ/internal/kidneys/vulpkanin = 70,
	/obj/item/organ/internal/liver/vulpkanin = 70,
	/obj/item/organ/internal/lungs/vulpkanin = 70,
	//Вольпины
	/obj/item/organ/internal/eyes/vulpkanin/wolpin = 80,
	))

////////////////////////////
//Прок генерирующий квест на органы и части тела
////////////////////////////
/datum/cargo_quests_storage/proc/generate_organs_info(var/datum/cargo_quest/quest)
	if(!quest)
		log_debug("Quest generation attempted without a quest datum reference!")
		return
	if(!quest.quest_difficulty)
		quest.generate_difficulty()
	log_debug("Generating quest of type \"Organs and Bodyparts\"")
	var/organs_count = pick(2,3,4,5)
	quest.current_list += GLOB.quest_organs_and_bodyparts

	switch(quest.quest_difficulty)
		if(QUEST_DIFFICULTY_EASY)
			organs_count = pick(2,3)
			for(var/item in quest.current_list)
				if(quest.current_list[item] <= 80)	//Убираем внутренние органы и другие относительно трудные
					quest.current_list -= item
		if(QUEST_DIFFICULTY_NORMAL)
			organs_count = pick(3,4)
			for(var/item in quest.current_list)
				if(quest.current_list[item] <= 70)	//Убираем относительно труднодостижимые органы
					quest.current_list -= item
		if(QUEST_DIFFICULTY_HARD)
			organs_count = pick(4,5)
			for(var/item in quest.current_list)
				if(quest.current_list[item] > 70)	//Оставляем лишь то, что достать трудно
					quest.current_list -= item

	quest.req_item = pickweight(quest.current_list)
	quest.req_quantity = organs_count
	//вписать выбор нужной иконки
	log_debug("Chosen organ/bodypart: [quest.req_item]")
