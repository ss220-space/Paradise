	//Химикаты - Медицинские
GLOBAL_LIST_INIT(quest_medical_chems, list(
	//Простые
	"charcoal" = 95,			"cryoxadone" = 80,			"mannitol" = 90,
	"salbutamol" = 95,			"salglu_solution" = 95,		"silver_sulfadiazine" = 90,
	"styptic_powder" = 90,		"synthflesh" = 80,
	//Продвинутые
	"atropine" = 75,			"calomel" = 75,				"mutadone" = 75,
	"omnizine" = 60,			"pen_acid" = 70,			"perfluorodecalin" = 85,
	"sal_acid" = 80,
	//Уникальные
	"sterilizine" = 80,			"antihol" = 75,				"degreaser" = 60,
	"diphenhydramine" = 60,		"ephedrine" = 70,			"epinephrine" = 80,
	"ether" = 80,				"haloperidol" = 70,			"hydrocodone" = 70,
	"insulin" = 50,				"liquid_solder" = 85,		"mitocholide" = 60,
	"morphine" = 60,			"earthsblood" = 60,			"nanocalcium" = 40,
	"oculine" = 70,				"potass_iodide" = 90,		"rezadone" = 60,
	"spaceacillin" = 85,		"stimulants" = 50,			"strange_reagent" = 40,
	"teporone" = 70,			"lavaland_extract" = 40,
	))
	//Химикаты - Наркотики
GLOBAL_LIST_INIT(quest_drug_chems, list(
	"aranesp" = 80,				"bath_salts" = 60,			"crank" = 60,
	"jenkem" = 90,				"krokodil" = 50,			"lsd" = 70,
	"methamphetamine" = 80,		"nicotine" = 70,			"space_drugs" = 90,
	"surge" = 90,				"ultralube" = 70,			"thc" = 50,			//Tetrahydrocannabinol
	))
	//Химикаты - Пиротехнические
GLOBAL_LIST_INIT(quest_pyrotech_chems, list(
	"blackpowder" = 50,			"cryostylane" = 90,			"clf3" = 70,		//Chlorine Trifluoride
	"firefighting_foam" = 90,	"flash_powder" = 90,		"liquid_dark_matter" = 90,
	"napalm" = 80,				"phlogiston" = 70,			"pyrosium" = 90,
	"sonic_powder" = 90,		"sorium" = 90,			//	"stabilizing_agent" = 90,
	"teslium" = 50,
	))
	//Химикаты - Яды/Токсины
GLOBAL_LIST_INIT(quest_toxin_chems, list(
	"????" = 90,				"amanitin" = 70,			"atrazine" = 90,
	"capulettium" = 80,			"capulettium_plus" = 60,	"carpotoxin" = 60,
	"jestosterone" = 50,		"coniine" = 50,				"sarin" = 60,
	"cyanide" = 70,				"formaldehyde" = 90,		"glyphosate" = 70,
	"heparin" = 50,				"histamine" = 40,			"initropidril" = 1,
	"itching_powder" = 70,		"ketamine" = 60,			"lipolicide" = 50,
	"neurotoxin" = 80,			"pancuronium" = 80,			"pestkiller" = 90,
	"sulfonal" = 70,			"rotatium" = 10,		//	"curare" = 90,
//	"sodium_thiopental" = 90	"polonium" = 90,			"venom" = 90,		//Не достать без аплинка...
	))
	//Химикаты - Разные
GLOBAL_LIST_INIT(quest_misc_chems, list(
	"colorful_reagent" = 70,	"fliptonium" = 40,			"drying_agent" = 90,//Chlorine Trifluoride
	"hairgrownium" = 60,		"holywater" = 80,			"facid" = 70,		//FluoroSulfuric Acid
	"jestosterone" = 60,		"lye" = 90,					"hair_dye" = 30,
	"sodiumchloride" = 80,		"cleaner" = 80,				"lube" = 90,
	"super_hairgrownium" = 40,	"synthanol" = 80,			"mutagen" = 90,		//Unstable mutagen
	"stable_mutagen" = 70,		"thermite" = 70,
	))

////////////////////////////
//Прок генерирующий квест на гранаты и необходимые в гранатах химикаты
////////////////////////////
/datum/cargo_quests_storage/proc/generate_grenade_info(var/datum/cargo_quest/quest)
	if(!quest)
		log_debug("Quest generation attempted without a quest datum reference!")
		return
	if(!quest.quest_difficulty)
		quest.generate_difficulty()

	var/grenade_type = pick("explosive", "smoke", "foam")
	var/chem_type = pick("drugs","medical","toxin","misc")

	switch(quest.quest_difficulty)
		if(QUEST_DIFFICULTY_EASY)
			grenade_type = pick("explosive", "smoke")
			chem_type = pick("drugs","medical","toxin")
		if(QUEST_DIFFICULTY_NORMAL)
			chem_type = pick("drugs","medical","toxin")
		if(QUEST_DIFFICULTY_HARD)
			grenade_type = pick("smoke", "foam")

	quest.req_item = /obj/item/grenade/chem_grenade
	log_debug("Generating quest of type \"Grenade\"")
	switch(grenade_type)
		if("explosive")
			log_debug("Chosen grenade type: Explosive")
			quest.req_item = /obj/item/grenade/chem_grenade/pyro
			//вписать выбор нужной иконки
			quest.current_list += (GLOB.quest_pyrotech_chems)
		if("smoke")
			log_debug("Chosen grenade type: Smoke")
			if(chem_type == "drugs")
				quest.current_list += (GLOB.quest_drug_chems)
				//вписать выбор нужной иконки
			else if(chem_type == "medical")
				quest.current_list += (GLOB.quest_medical_chems)
				//вписать выбор нужной иконки
			else if(chem_type == "toxin")
				quest.current_list += (GLOB.quest_toxin_chems)
				//вписать выбор нужной иконки
			else if(chem_type == "misc")
				quest.current_list += (GLOB.quest_misc_chems)
				//вписать выбор нужной иконки
			quest.req_else = list("smoke_powder" = 30)
		if("foam")
			log_debug("Chosen grenade type: Foam")
			if(chem_type == "drugs")
				quest.current_list += (GLOB.quest_drug_chems)
				//вписать выбор нужной иконки
			else if(chem_type == "medical")
				quest.current_list += (GLOB.quest_medical_chems)
				//вписать выбор нужной иконки
			else if(chem_type == "toxin")
				quest.current_list += (GLOB.quest_toxin_chems)
				//вписать выбор нужной иконки
			else if(chem_type == "misc")
				quest.current_list += (GLOB.quest_misc_chems)
				//вписать выбор нужной иконки
			quest.req_else = list("fluorosurfactant" = 30)

	var/max_chems // от 3 до 10 химикатов
	switch(quest.quest_difficulty)
		if(QUEST_DIFFICULTY_EASY)
			for(var/item in quest.current_list)
				if(quest.current_list[item] < 50)	// Удаляем редкие химикаты ("<" здесь и должно быть)
					quest.current_list -= item
			max_chems = pick(3, 4, 5, 6)
		if(QUEST_DIFFICULTY_NORMAL)
			for(var/item in quest.current_list)
				if(quest.current_list[item] <= 30)	// Удаляем самые редкие химикаты
					quest.current_list -= item
			max_chems = pick(5, 6, 7, 8)
		if(QUEST_DIFFICULTY_HARD)
			for(var/item in quest.current_list)
				if(quest.current_list[item] >= 70)	// Удаляем частые химикаты
					quest.current_list -= item
			max_chems = pick(7, 8, 9, 10)

	for(var/i in 1 to max_chems)
		var/current_chem = pickweight(quest.current_list)
		var/current_value = (pick(10, 20, 30, 40, 50))
		quest.req_else += list(trim(current_chem) = current_value) 	// trim() тут скорее для обхода логики листа по которой, вместо того текста,
		quest.current_list -= current_chem							// что хранит current_chem он просто писал "current_chem" Если знаете вариант лучше, сообщите. Спасибо.
	log_debug("Generation end")
