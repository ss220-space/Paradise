/*
Система квестов или "Контрактов" для карго на тайпане.
Работает следующим образом. У карго есть хранилище квестов,
в нём есть три слота под квесты. Квесты могут быть:
	* ограничены временем
	* скрыты пока ты не выберешь сам квест(За выбор скрытого квеста идёт доп награда при выполнении)
	* уникальны (Пресеты заданые в коде)
В начале производится генерация квестов с выбором рандомного типа квеста для каждого из слотов.
Потом на основе выбранного типа, создаётся сам квест. После этого игроки должны выбрать активный квест.
Пока есть активный квест, другие квесты недоступны. Невыполнение квеста вовремя или отказ от квеста
приведёт к пенальти (снятие денег) зависящего от сложности квеста и замене активного квеста.
За выполнение квеста в награду даются кредиты и возможно другие безделушки.

Возможно в будущем её можно будет адаптировать и для обычной станции.
*/

//GLOBAL_LIST_INIT(premade_syndie_quests, list(/datum/cargo_quest/grenade/death_kiss,,,,,,,,,))

//У сложностей такие значения потому, что она будет учитываться при подсчёте награды за квест
#define QUEST_DIFFICULTY_EASY 	5000
#define QUEST_DIFFICULTY_NORMAL 10000
#define QUEST_DIFFICULTY_HARD 	15000

//Типы квестов
#define QUEST_TYPE_VIRUS "virus"
#define QUEST_TYPE_MECHA "mecha"
#define QUEST_TYPE_GRENADE "grenade"
#define QUEST_TYPE_PLANTS "plants"
#define QUEST_TYPE_ORGANS "organs_and_bodyparts"
#define QUEST_TYPE_GENES "genes"
#define QUEST_TYPE_WEAPONS "weapons_and_implants"
#define QUEST_TYPE_BOTS "bots"
#define QUEST_TYPE_MINERALS "minerals"
#define QUEST_TYPE_TECH "tech"

/datum/cargo_quests_storage
	//Активный квест выбранный в консоли
	var/datum/cargo_quest/current_quest
	//Сгенерированные квесты. Одновременно может существовать только 3 Квеста
	var/datum/cargo_quest/quest_one
	var/datum/cargo_quest/quest_two
	var/datum/cargo_quest/quest_three
	//Возможные виды квестов для генерации
	var/list/possible_quest_types = list(
		QUEST_TYPE_VIRUS,
		QUEST_TYPE_MECHA,
		QUEST_TYPE_GRENADE,
		QUEST_TYPE_PLANTS,
		QUEST_TYPE_ORGANS,
/*		TODO:
		QUEST_TYPE_GENES,
		QUEST_TYPE_WEAPONS,
		QUEST_TYPE_BOTS,
		QUEST_TYPE_MINERALS,
		QUEST_TYPE_TECH,
*/
	)

/datum/cargo_quests_storage/proc/QuestStorageInitialize() //TODO:Вызывать сразу после создания хранилища квестов
	for(var/i in 1 to 3)
		generate_quest()

////////////////////////////
//Основной прок генерирующий 1 квест с посланным в него типом.
////////////////////////////
/datum/cargo_quests_storage/proc/generate_quest(var/quest_type = null)
	if(!quest_type)
		quest_type = pick(possible_quest_types)

	var/datum/cargo_quest/quest
	if(!quest_one)
		quest_one = new /datum/cargo_quest
		quest = quest_one
	else if(!quest_two)
		quest_two = new /datum/cargo_quest
		quest = quest_two
	else if(!quest_three)
		quest_three = new /datum/cargo_quest
		quest = quest_three
	else
		return

	quest.generate_difficulty()
	switch(quest_type)
		if(QUEST_TYPE_VIRUS)
			quest.quest_type = QUEST_TYPE_VIRUS
			generate_virus_info(quest)
		if(QUEST_TYPE_MECHA)
			quest.quest_type = QUEST_TYPE_MECHA
			generate_mecha_info(quest)
		if(QUEST_TYPE_GRENADE)
			quest.quest_type = QUEST_TYPE_GRENADE
			generate_grenade_info(quest)
		if(QUEST_TYPE_PLANTS)
			quest.quest_type = QUEST_TYPE_PLANTS
			generate_plants_info(quest)
		if(QUEST_TYPE_ORGANS)
			quest.quest_type = QUEST_TYPE_ORGANS
			generate_organs_info(quest)
		if(QUEST_TYPE_GENES)
			quest.quest_type = QUEST_TYPE_GENES
			generate_genes_info(quest)

//TODO:
/datum/cargo_quests_storage/proc/populate_quest_window()

//TODO:
/datum/cargo_quests_storage/proc/check_quest_completion()

/datum/cargo_quest
	var/active = FALSE 								// Выбран ли квест игроками или нет?
	var/quest_type = QUEST_TYPE_MECHA				// Тип Квеста. Список типов есть выше.
	var/quest_name = ""								// Название квеста
	var/quest_desc = ""								// Описание квеста
	var/quest_icon = null							// Иконка для этого квеста которая будет показана в интерфейсе
	var/quest_difficulty = QUEST_DIFFICULTY_EASY	// EASY, NORMAL, HARD.
	var/quest_reward = 0 							// Кредиты выдаваемые в награду за квест
	var/stealth = FALSE								// Скрыто ли содержимое нашего квеста до его активации?
	var/list/quest_reward_else = list() 			// Лист предметов выдающихся в дополнение, за выполнение квеста.
	var/quest_time_minutes = -1						// Время в МИНУТАХ за которое надо успеть сделать квест или автопровал. Если время < 0, значит ограничения по времени нет.
	var/list/current_list = list()					// Лист для дебага. TODO: Удалить когда квест система официально будет закончена и заменить все места где он применяется временными листами
	var/req_item = null								// Тип предмета который нам надо произвести
	var/list/req_else = list()						// Дополнительные штуки которые будут проверяться в зависимости от типа квеста
	var/req_quantity = 0							// Требуемое количество предметов

// Генерирует сложность квеста.
/datum/cargo_quest/proc/generate_difficulty()
	if(prob(50))
		quest_difficulty = QUEST_DIFFICULTY_EASY
		log_debug("Quest difficulty: Easy")
	else if(prob(50))
		quest_difficulty = QUEST_DIFFICULTY_NORMAL
		log_debug("Quest difficulty: Normal")
	else
		quest_difficulty = QUEST_DIFFICULTY_HARD
		log_debug("Quest difficulty: Hard")

//TODO:
/datum/cargo_quest/proc/generate_reward()


///////////////////////////////
// Уникальные заранее созданные квесты. Со своим описанием, требованиями и т.д.
///////////////////////////////

/datum/cargo_quest/grenade
	quest_type = QUEST_TYPE_GRENADE
	req_item = /obj/item/grenade/chem_grenade

/datum/cargo_quest/grenade/death_kiss
	quest_name = "Поцелуй смерти"
	quest_desc = "Порой на поле боя нужны радикальные меры... Клиент запросил пару смертельно опасных, дымовых гранат с инитропидрилом."
	quest_icon = null
	quest_difficulty = QUEST_DIFFICULTY_NORMAL
	quest_time_minutes = 10
	req_else = list("smoke_powder" = 30, "initropidril" = 50)
	req_quantity = 3
	quest_reward = 50000
	quest_reward_else = list(/obj/item/stack/sheet/mineral/diamond = 10)
