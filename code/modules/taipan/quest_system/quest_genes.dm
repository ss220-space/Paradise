// В этом списке находятся все используемые игрой гены
// Имена генов должны совпадать с используемыми в setupgame.dm для списка GLOB.assigned_blocks
// Ибо через этот глобальный лист и будет вестись проверка на то совпал ли ген в шприце с запрошенным
	/*
	Система подсчёта веса в этом списке.
	Мартышка/хуман = 100
	Нейтральная мутация = 90
	Обычные болячки = 80
	Особо раздражающие болячки = 70
	Если мутация полезная = 60
	Полезная мутация которая не активируется с шансом(XRAY и т.д.) = 40

	Затем в ход идёт дизбаланс гена.
	Негативный прибавляется к весу,
	позитивный наоборот отнимается.
	Если "+" или "-" нет, значит дизбаланса у гена нет
	*/
GLOBAL_LIST_INIT(quest_genes, list(
	// Standard muts
	"BLINDNESS" = 70+15,	"COLOURBLIND" = 80+10,
	"DEAF" = 70+15,			"HULK" = 40-15,
	"TELE" = 40-15,			"FIRE" = 60-10,
	"XRAY" = 40-15,			"CLUMSY" = 70+5,
//	"FAKE" = 100, //ПОЧЕМУ Я ПОСТОЯННО НАХОЖУ РУДИМЕНТЫ ПОКА ПОПОЛНЯЮ ЭТИ ЛИСТЫ?! ЧТО ЭТО ЗА ГЕЕЕЕН!!!!!!!
	"COUGH" = 80+5,			"GLASSES" = 80+10,
	"EPILEPSY" = 70+10,		"TWITCH" = 70+10,
	"NERVOUS" = 80,			"WINGDINGS" = 80+5,
	// Bay muts
	"BREATHLESS" = 40-10,	"REMOTEVIEW" = 90-5,
	"REGENERATE" = 60-5,	"INCREASERUN" = 60-5,
	"REMOTETALK" = 60-5,	"MORPH" = 60-5,
	"COLD" = 60-10,			"HALLUCINATION" = 80+10,
	"NOPRINTS" = 60-5,		"SHOCKIMMUNITY" = 60-10,
	"SMALLSIZE" = 60-5,
	// Goon muts
	// Disabilities
	"LISP" = 80,			"MUTE" = 70+10,
	"RAD" = 70+15,			"FAT" = 90+5,
	"SWEDE" = 80,			"SCRAMBLE" = 70+5,
	"STRONG" = 90,			"HORNS" = 90,
	"COMIC" = 90,
	// Powers
	"SOBER" = 90,			"PSYRESIST" = 60,
	"SHADOW" = 40-10,		"CHAMELEON" = 40-10,
	"CRYO" = 60-10,			"EAT" = 90-5,
	"JUMP" = 60-5,			"IMMOLATE" = 90,
	"EMPATH" = 90-5,		"POLYMORPH" = 60-10,
	// /vg/ Blocks
	// Disabilities
	"LOUD" = 80,			"DIZZY" = 70+5,
	// Paradise220 Disabilities
	"AULD_IMPERIAL" = 80,
	// Monkeyblock on/off
	// TODO: Когда буду делать проверки для уже выполнения самих квестов - не забыть о логике проверки монки/хуман гена отдельно
	// GLOB.monkeyblock = DNA_SE_LENGTH - Эта строчка шпаргалка для меня. Потом удалю.
	"MONKEY" = 100,			"HUMAN" = 100,
	))

////////////////////////////
//Прок генерирующий квест на шприцы с генами
//TODO: Возможно в будущем сюда можно добавить так же различных мартышек/хуманов с нужными генами, как альтернативу лишь шприцам.
////////////////////////////
/datum/cargo_quests_storage/proc/generate_genes_info(var/datum/cargo_quest/quest)
	if(!quest)
		log_debug("Quest generation attempted without a quest datum reference!")
		return
	if(!quest.quest_difficulty)
		quest.generate_difficulty()
	log_debug("Generating quest of type \"Genes\"")
	var/syringes_count = pick(1,2,3,4,5)
	quest.current_list += GLOB.quest_genes

	switch(quest.quest_difficulty)
		if(QUEST_DIFFICULTY_EASY)
			syringes_count = pick(2,3)
			for(var/item in quest.current_list)
				if(quest.current_list[item] < 60)	//Убираем большую часть сложно получаемых генов
					quest.current_list -= item
		if(QUEST_DIFFICULTY_NORMAL)
			syringes_count = pick(3,4)
			for(var/item in quest.current_list)
				if(quest.current_list[item] >= 60)	//Убираем простые гены
					quest.current_list -= item
		if(QUEST_DIFFICULTY_HARD)
			syringes_count = pick(4,5)
			for(var/item in quest.current_list)
				if(quest.current_list[item] > 40)	//Оставляем лишь то, что достать трудно
					quest.current_list -= item

	quest.req_item = /obj/item/dnainjector
	quest.req_else = pickweight(quest.current_list)
	quest.req_quantity = syringes_count
	//вписать выбор нужной иконки
	log_debug("Chosen gene: [quest.req_else]")
