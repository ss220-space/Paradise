/datum/cargo_quests_storage
	//Активный квест выбранный в консоли
	var/datum/cargo_quest/current_quest
	//Возможные виды квестов для генерации
	var/list/quest_types = list(
		"virus",
		"mecha",
		"grenade",
		"plants",
		"weapons_and_implants",
		"genes",
		"bots",
		"minerals",
		"tech",
		"organs_and_bodyparts",
	)
	//Список используемых в генерации симптомов для вирусов
	//Цифры для "Веса" симптомов, определялись по их level-у, но инвертировано. Ака 6 = 1, 5 = 2 и т.д.
	var/list/virus_simptoms = list(
	/datum/symptom/headache = 6,
	/datum/symptom/itching = 6,
	/datum/symptom/fever = 5,
	/datum/symptom/shivering = 5,
	/datum/symptom/booze = 4,
	/datum/symptom/choking = 4,
	/datum/symptom/heal/longevity = 4,
	/datum/symptom/heal/metabolism = 4,
	/datum/symptom/viralevolution = 4,
	/datum/symptom/viraladaptation = 4,
	/datum/symptom/vomit = 4,
	/datum/symptom/weakness = 4,
	/datum/symptom/weight_loss = 4,
	/datum/symptom/beard = 3,
	/datum/symptom/confusion = 3,
	/datum/symptom/damage_converter = 3,
	/datum/symptom/deafness = 3,
	/datum/symptom/dizzy = 3,
	/datum/symptom/sensory_restoration = 3,
	/datum/symptom/shedding = 3,
	/datum/symptom/vitiligo = 3,
	/datum/symptom/revitiligo = 3,
	/datum/symptom/sneeze = 3,
	/datum/symptom/blood = 2,
	/datum/symptom/epinephrine = 2,
	/datum/symptom/hallucigen = 2,
	/datum/symptom/painkiller = 2,
	/datum/symptom/mind_restoration = 2,
	/datum/symptom/visionloss = 2,
	/datum/symptom/youth = 2,
	/datum/symptom/flesh_eating = 1,
//	/datum/symptom/genetic_mutation = 1, //У нас вырублен, но я оставлю это тут на всякий
	/datum/symptom/heal = 1,
	/datum/symptom/oxygen = 1,
	/datum/symptom/voice_change = 1,
	)
	/*
	var/list/clear_chems = list(
	/datum/reagent/nitrogen = 10,
	/datum/reagent/water = 10,
	/datum/reagent/aluminum = 10,
	/datum/reagent/bromine = 10,
	/datum/reagent/iron = 10,
	/datum/reagent/hydrogen = 10,
	/datum/reagent/iodine = 10,
	/datum/reagent/potassium = 10,
	/datum/reagent/oxygen = 10,
	/datum/reagent/silicon = 10,
	/datum/reagent/lithium = 10,
	/datum/reagent/copper = 10,
	/datum/reagent/sodium = 10,
	/datum/reagent/plasma = 10,
	/datum/reagent/radium = 10,
	/datum/reagent/mercury = 10,
	/datum/reagent/consumable/sugar = 10,
	/datum/reagent/sulfur = 10,
	/datum/reagent/silver = 10,
	/datum/reagent/toxin = 10,
	/datum/reagent/carbon = 10,
	/datum/reagent/uranium = 10,
	/datum/reagent/phosphorus = 10,
	/datum/reagent/fluorine = 10,
	/datum/reagent/chlorine = 10,
	/datum/reagent/ethanol = 10,
	)
	*/
	/*
	var/list/simple_chems = list(
	/datum/reagent/acetone = 10,
	/datum/reagent/ammonia = 10,
	/datum/reagent/ash = 10,
	/datum/reagent/carpet = 10,
	/datum/reagent/diethylamine = 10,
	/datum/reagent/oil = 10,
	/datum/reagent/phenol = 10,
	/datum/reagent/saltpetre = 10,
	/datum/reagent/acid = 10,				//Sulphuric acid
	/datum/reagent/fuel = 10,				//Welding fuel
	)
	*/
	//Химикаты - Медицинские
	var/list/medical_chems = list(
	//Простые
	/datum/reagent/medicine/charcoal = 10,
	/datum/reagent/medicine/cryoxadone = 10,
	/datum/reagent/medicine/mannitol = 10,
	/datum/reagent/medicine/salbutamol = 10,
	/datum/reagent/medicine/salglu_solution = 10,
	/datum/reagent/medicine/silver_sulfadiazine = 10,
	/datum/reagent/medicine/styptic_powder = 10,
	/datum/reagent/medicine/synthflesh = 10,
	//Продвинутые
	/datum/reagent/medicine/atropine = 10,
	/datum/reagent/medicine/calomel = 10,
	/datum/reagent/medicine/mutadone = 10,
	/datum/reagent/medicine/omnizine = 10,
	/datum/reagent/medicine/pen_acid = 10,
	/datum/reagent/medicine/perfluorodecalin = 10,
	/datum/reagent/medicine/sal_acid = 10,
	//Уникальные
	/datum/reagent/medicine/sterilizine = 10,
	/datum/reagent/medicine/antihol = 10,
	/datum/reagent/medicine/degreaser = 10,
	/datum/reagent/medicine/diphenhydramine = 10,
	/datum/reagent/medicine/ephedrine = 10,
	/datum/reagent/medicine/epinephrine = 10,
	/datum/reagent/medicine/ether = 10,
	/datum/reagent/medicine/haloperidol = 10,
	/datum/reagent/medicine/hydrocodone = 10,
	/datum/reagent/medicine/insulin = 10,
	/datum/reagent/medicine/liquid_solder = 10,
	/datum/reagent/medicine/mitocholide = 10,
	/datum/reagent/medicine/morphine = 10,
	/datum/reagent/medicine/earthsblood = 10,
	/datum/reagent/medicine/nanocalcium = 10,
	/datum/reagent/medicine/oculine = 10,
	/datum/reagent/medicine/potass_iodide = 10,
	/datum/reagent/medicine/rezadone = 10,
	/datum/reagent/medicine/spaceacillin = 10,
	/datum/reagent/medicine/stimulants = 10,
	/datum/reagent/medicine/strange_reagent = 10,
	/datum/reagent/medicine/teporone = 10,
	/datum/reagent/medicine/lavaland_extract = 10,
	)
	//Химикаты - Наркотики
	var/list/drug_chems = list(
	/datum/reagent/aranesp = 10,
	/datum/reagent/bath_salts = 10,
	/datum/reagent/crank = 10,
	/datum/reagent/jenkem = 10,
	/datum/reagent/krokodil = 10,
	/datum/reagent/lsd = 10,
	/datum/reagent/methamphetamine = 10,
	/datum/reagent/nicotine = 10,
	/datum/reagent/space_drugs = 10,
	/datum/reagent/surge = 10,
	/datum/reagent/thc = 10,				//Tetrahydrocannabinol
	/datum/reagent/lube/ultra = 10,
	)
	//Химикаты - Пиротехнические
	var/list/pyrotech_chems = list(
	/datum/reagent/blackpowder = 10,
	/datum/reagent/clf3 = 10,				//Chlorine Trifluoride
	/datum/reagent/cryostylane = 10,
	/datum/reagent/firefighting_foam = 10,
	/datum/reagent/flash_powder = 10,
	/datum/reagent/liquid_dark_matter = 10,
	/datum/reagent/napalm = 10,
	/datum/reagent/phlogiston = 10,
	/datum/reagent/pyrosium = 10,
	/datum/reagent/sonic_powder = 10,
	/datum/reagent/sorium = 10,
	/datum/reagent/stabilizing_agent = 10,
	/datum/reagent/teslium = 10,
	)
	//Химикаты - Яды/Токсины
	var/list/toxin_chems = list(
	/datum/reagent/questionmark = 10,
	/datum/reagent/amanitin = 10,
	/datum/reagent/glyphosate/atrazine = 10,
	/datum/reagent/capulettium = 10,
	/datum/reagent/capulettium_plus = 10,
	/datum/reagent/carpotoxin = 10,
	/datum/reagent/jestosterone = 10,
	/datum/reagent/coniine = 10,
//	/datum/reagent/curare = 10,						//Не достать без аплинка...
	/datum/reagent/cyanide = 10,
	/datum/reagent/formaldehyde = 10,
	/datum/reagent/glyphosate = 10,
	/datum/reagent/heparin = 10,
	/datum/reagent/histamine = 10,
	/datum/reagent/initropidril = 10,
	/datum/reagent/itching_powder = 10,
	/datum/reagent/ketamine = 10,
	/datum/reagent/lipolicide = 10,
	/datum/reagent/consumable/ethanol/neurotoxin = 10,
	/datum/reagent/pancuronium = 10,
	/datum/reagent/pestkiller = 10,
//	/datum/reagent/polonium = 10,					//Не достать без аплинка...
	/datum/reagent/rotatium = 10,
	/datum/reagent/sarin = 10,
//	/datum/reagent/sodium_thiopental = 10,			//Не достать без аплинка...
	/datum/reagent/sulfonal = 10,
//	/datum/reagent/venom = 10,						//Не достать без аплинка...
	)
	//Химикаты - Разные
	var/list/misc_chems = list(
	/datum/reagent/colorful_reagent = 10,
	/datum/reagent/drying_agent = 10,				//Chlorine Trifluoride
	/datum/reagent/fliptonium = 10,
	/datum/reagent/acid/facid = 10,						//FluoroSulfuric Acid
	/datum/reagent/hairgrownium = 10,
	/datum/reagent/holywater = 10,
	/datum/reagent/jestosterone = 10,
	/datum/reagent/lye = 10,
	/datum/reagent/hair_dye = 10,
	/datum/reagent/consumable/sodiumchloride = 10,
	/datum/reagent/space_cleaner = 10,
	/datum/reagent/lube = 10,
	/datum/reagent/super_hairgrownium = 10,
	/datum/reagent/consumable/ethanol/synthanol = 10,
	/datum/reagent/thermite = 10,
	/datum/reagent/mutagen = 10,					//Unstable mutagen
	/datum/reagent/stable_mutagen = 10,
	)

	var/list/plants_chems = list(
	/obj/item/bodybag = 10,
	)
	var/list/weapons_and_implants = list(
	/obj/item/bodybag = 10,
	)
	//Список мехов для генерации
	var/list/mechs = list(
	/obj/mecha/combat/durand/rover = 5,
	/obj/mecha/combat/gygax/dark = 5,
	/obj/mecha/medical/odysseus = 10,
	/obj/mecha/working/ripley = 10,
	/obj/mecha/working/ripley/firefighter = 15,
	/obj/mecha/combat/durand = 20,
	/obj/mecha/combat/gygax = 20,
	/obj/mecha/working/clarke = 20,
	/obj/mecha/combat/honker = 10,
	/obj/mecha/combat/reticence = 10,
	/obj/mecha/makeshift = 50,
	)
	//Эквип подходящий каждому меху за парой исключений
	var/list/mechs_equipment_all = list(
	/obj/item/mecha_parts/mecha_equipment/drill = 10,					//Все кроме одиссея и локермеха
	/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill = 10,		//Все кроме одиссея и локермеха
	/obj/item/mecha_parts/mecha_equipment/mining_scanner = 10,			//Все
	/obj/item/mecha_parts/mecha_equipment/teleporter = 10,				//Все
	/obj/item/mecha_parts/mecha_equipment/wormhole_generator = 10,		//Все
	/obj/item/mecha_parts/mecha_equipment/gravcatapult = 10,			//Все
	/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster = 10,	//Все
	/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster = 10,	//Все
	/obj/item/mecha_parts/mecha_equipment/repair_droid = 10,			//Все
	/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay = 10,		//Все
	/obj/item/mecha_parts/mecha_equipment/generator = 10,				//Все
	/obj/item/mecha_parts/mecha_equipment/generator/nuclear = 10,		//Все
	/obj/item/mecha_parts/mecha_equipment/rcd = 10,						//Все
	)
	//Эквип подходящий только Хонк Меху
	var/list/mechs_equipment_honk = list(
	/obj/item/mecha_parts/mecha_equipment/weapon/honker = 20,									//Только Хонк
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar = 20,		//Только Хонк
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar = 20,	//Только Хонк
	)
	//Эквип подходящий только Молчуну
	var/list/mechs_equipment_reticence = list(
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/silenced = 20,				//Только Молчун
	/obj/item/mecha_parts/mecha_equipment/mimercd = 10,											//Только Молчун
	)
	//Эквип подходящий только кларку, рипли и огнеборец
	var/list/mechs_equipment_working = list(
	/obj/item/mecha_parts/mecha_equipment/cable_layer = 10,										//Кларк, рипли, огнеборец
	/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp = 10,									//Кларк, рипли, огнеборец
	/obj/item/mecha_parts/mecha_equipment/extinguisher = 10,									//Кларк, рипли, огнеборец
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma = 20,							//Кларк, рипли, огнеборец
	)
	//Эквип подходящий только одиссею с одним исключением
	var/list/mechs_equipment_medical = list(
	/obj/item/mecha_parts/mecha_equipment/medical/sleeper = 10,									//Только одиссей
	/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun = 10,								//Только одиссей
	/obj/item/mecha_parts/mecha_equipment/medical/rescue_jaw = 10,								//Только одиссей и огнеборец
	)
	//Эквип подходящий только боевым мехам Хонку, Молчуну и емагнутому рипли/огнеборцу
	var/list/mechs_equipment_weapons = list(
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser = 20,								//Нельзя Локермеху, Кларку, рипли, огнеборцу, одиссею
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/disabler = 20,					//Нельзя Локермеху, Кларку, рипли, огнеборцу, одиссею
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy = 20,						//Нельзя Локермеху, Кларку, рипли, огнеборцу, одиссею
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion = 20,								//Нельзя Локермеху, Кларку, рипли, огнеборцу, одиссею
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/tesla = 20,								//Нельзя Локермеху, Кларку, рипли, огнеборцу, одиссею
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/immolator = 20,							//Нельзя Локермеху, Кларку, рипли, огнеборцу, одиссею
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser = 20,								//Нельзя Локермеху, Кларку, рипли, огнеборцу, одиссею
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine = 20,						//Нельзя Локермеху, Кларку, рипли, огнеборцу, одиссею
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot = 20,					//Нельзя Локермеху, Кларку, рипли, огнеборцу, одиссею
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg = 20,							//Нельзя Локермеху, Кларку, рипли, огнеборцу, одиссею
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack = 20,					//Нельзя Локермеху, Кларку, рипли, огнеборцу, одиссею
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang = 20,			//Нельзя Локермеху, Кларку, рипли, огнеборцу, одиссею
	)
	var/list/rare_misc_from_nt = list(
	/obj/item/bodybag = 10,
	)
	var/list/genes = list(
	/obj/item/bodybag = 10,
	)
	var/list/bot_types = list(
	/obj/item/bodybag = 10,
	)
	var/list/minerals = list(
	/obj/item/bodybag = 10,
	)
	var/list/organs_and_bodyparts = list(
	/obj/item/bodybag = 10,
	)
	//Сгенерированные квесты. Одновременно может существовать только 3 Квеста
	var/datum/cargo_quest/quest_one
	var/datum/cargo_quest/quest_two
	var/datum/cargo_quest/quest_three

////////////////////////////
//Основной прок генерирующий 1 квест с посланным в него типом.
////////////////////////////
/datum/cargo_quests_storage/proc/generate_quest(var/quest_type = "mecha")
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

	////////////////////////////
	//Прописать тут генерацию типа квеста при отсутствии аргумента quest_type
	////////////////////////////

	switch(quest_type)
		if("virus")
			quest.quest_type = "virus"
			quest.req_item = /datum/disease/advance
			generate_virus_info(quest)
		if("mecha")
			quest.quest_type = "mecha"
			generate_mecha_info(quest)
		if("grenade")
			quest.quest_type = "grenade"
			generate_grenade_info(quest)

////////////////////////////
//Прок генерирующий квест на вирус и необходимые симптомы для него
////////////////////////////
/datum/cargo_quests_storage/proc/generate_virus_info(var/datum/cargo_quest/quest)
	var/symptom_count = pick(4,5,6)
	quest.current_list += (virus_simptoms)
	for(var/i in 1 to symptom_count)
		var/current_simptom = pickweight(quest.current_list)
		quest.req_else += (current_simptom)
		quest.current_list -= current_simptom

////////////////////////////
//Прок генерирующий квест на Меха и необходимый эквип для него
////////////////////////////
/datum/cargo_quests_storage/proc/generate_mecha_info(var/datum/cargo_quest/quest)
	quest.req_item = pickweight(mechs)
	var/req_mech = quest.req_item
	var/list/mech_equipment_all_cut = list()
	mech_equipment_all_cut.Add(mechs_equipment_all)
	mech_equipment_all_cut.Cut(1,3)
	var/max_equip
	log_debug("begin")
	if(req_mech == /obj/mecha/combat/honker)
		quest.current_list += (mechs_equipment_all)
		quest.current_list += (mechs_equipment_honk)
		quest.current_list += (mechs_equipment_weapons)
		max_equip = 3
		log_debug("honker")
	else if(req_mech == /obj/mecha/combat/reticence)
		quest.current_list += (mechs_equipment_all)
		quest.current_list += (mechs_equipment_reticence)
		quest.current_list += (mechs_equipment_weapons)
		max_equip = 3
		log_debug("reticence")
	else if(req_mech == /obj/mecha/working/ripley || req_mech == /obj/mecha/working/ripley/firefighter)
		quest.current_list += (mechs_equipment_all)
		quest.current_list += (mechs_equipment_working)
		quest.current_list += (mechs_equipment_weapons)
		max_equip = 6
		log_debug("ripley or firefighter")
	else if(req_mech == /obj/mecha/working/clarke)
		quest.current_list += (mechs_equipment_all)
		quest.current_list += (mechs_equipment_working)
		max_equip = 4
		log_debug("clarke")
	else if(req_mech == /obj/mecha/medical/odysseus)
		quest.current_list += (mechs_equipment_medical)
		max_equip = 3
		log_debug("medical")
	else if(req_mech == /obj/mecha/makeshift)
		quest.current_list += (mech_equipment_all_cut)
		max_equip = 2
		log_debug("makeshift")
	else
		quest.current_list += (mechs_equipment_all)
		quest.current_list += (mechs_equipment_weapons)
		max_equip = 3
		log_debug("else")
	for(var/i in 1 to max_equip)
		var/current_equipment = pickweight(quest.current_list)
		quest.req_else += (current_equipment)
		quest.current_list -= (current_equipment)
		log_debug("end")

////////////////////////////
//Прок генерирующий квест на гранаты и необходимые в гранатах химикаты
////////////////////////////
/datum/cargo_quests_storage/proc/generate_grenade_info(var/datum/cargo_quest/quest)
	var/grenade_type = pick("explosive", "smoke", "foam", "unique")
	quest.req_item = /obj/item/grenade/chem_grenade
	switch(grenade_type)
		if("explosive")
			quest.req_item = /obj/item/grenade/chem_grenade/pyro
			quest.current_list += (pyrotech_chems)
		if("smoke")
			quest.current_list += (drug_chems)
			quest.current_list += (medical_chems)
			quest.current_list += (toxin_chems)
			quest.current_list += (misc_chems)
			quest.req_else = list(/datum/reagent/smoke_powder, 30)
		if("foam")
			quest.current_list += (drug_chems)
			quest.current_list += (medical_chems)
			quest.current_list += (toxin_chems)
			quest.current_list += (misc_chems)
			quest.req_else = list(/datum/reagent/fluorosurfactant,  30)
		if("unique")
			//Написать пару пресетов и тут вписать код который будет копировать с пресетов ебучие данные.
			quest.current_list += (misc_chems)	//placeholder. Удалить после создания логики с коммента выше.


	var/max_chems = pick(6, 7, 8, 9, 10)
	for(var/i in 1 to max_chems)
		var/current_chem = pickweight(quest.current_list)
		var/current_value = (pick(10, 20, 30, 40, 50))
		quest.req_else += list(current_chem, current_value)
		quest.current_list -= current_chem

/datum/cargo_quests_storage/proc/populate_quest_window()

/datum/cargo_quests_storage/proc/check_quest_completion()

/datum/cargo_quest
	var/quest_type = "mecha"
	var/quest_desc = ""
	var/list/current_list = list()
	var/req_item = null
	var/list/req_else = list()
	var/quest_icon = null


