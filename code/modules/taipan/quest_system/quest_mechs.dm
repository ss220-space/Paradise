	//Список мехов для генерации
GLOBAL_LIST_INIT(quest_mechs, list(
	/obj/mecha/makeshift = 50,			/obj/mecha/combat/durand = 20,
	/obj/mecha/combat/gygax = 20,		/obj/mecha/working/ripley/firefighter = 15,
	/obj/mecha/working/clarke = 15,		/obj/mecha/medical/odysseus = 10,
	/obj/mecha/working/ripley = 10,		/obj/mecha/combat/honker = 10,
	/obj/mecha/combat/reticence = 10,	/obj/mecha/combat/durand/rover = 5,
	/obj/mecha/combat/gygax/dark = 5,
	))
	//Эквип подходящий каждому меху за парой исключений
	//Эта пара исключений должна оставаться вверху списка для правильной работы кода
GLOBAL_LIST_INIT(quest_mechs_equipment_all, list(
	/obj/item/mecha_parts/mecha_equipment/drill = 100,					/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill = 91,		//Эти два подходят всем кроме одиссея и локермеха
	/obj/item/mecha_parts/mecha_equipment/mining_scanner = 100,			/obj/item/mecha_parts/mecha_equipment/generator = 100,
	/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster = 91,	/obj/item/mecha_parts/mecha_equipment/wormhole_generator = 89,
	/obj/item/mecha_parts/mecha_equipment/gravcatapult = 89,			/obj/item/mecha_parts/mecha_equipment/repair_droid = 89,
	/obj/item/mecha_parts/mecha_equipment/generator/nuclear = 88,		/obj/item/mecha_parts/mecha_equipment/teleporter = 87,
	/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster = 87,	/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay = 87,
	/obj/item/mecha_parts/mecha_equipment/rcd = 79,
	))
	//Эквип подходящий только Хонк Меху
GLOBAL_LIST_INIT(quest_mechs_equipment_honk, list(
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar = 100,
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar = 100,
	/obj/item/mecha_parts/mecha_equipment/weapon/honker = 95,
	))
	//Эквип подходящий только Молчуну
GLOBAL_LIST_INIT(quest_mechs_equipment_reticence, list(
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/silenced = 100,
	/obj/item/mecha_parts/mecha_equipment/mimercd = 100,
	))
	//Эквип подходящий только кларку, рипли и огнеборцу
GLOBAL_LIST_INIT(quest_mechs_equipment_working, list(
	/obj/item/mecha_parts/mecha_equipment/cable_layer = 100,		/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp = 100,
	/obj/item/mecha_parts/mecha_equipment/extinguisher = 100,		/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma = 87,
	))
	//Эквип подходящий только одиссею с одним исключением
GLOBAL_LIST_INIT(quest_mechs_equipment_medical, list(
	/obj/item/mecha_parts/mecha_equipment/medical/sleeper = 92,		/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun = 75,
	/obj/item/mecha_parts/mecha_equipment/medical/rescue_jaw = 74,	//Только одиссей и огнеборец
	))
	//Эквип подходящий только боевым мехам, Хонку, Молчуну и емагнутому рипли/огнеборцу
	//Нельзя Локермеху, Кларку, рипли, огнеборцу, одиссею
GLOBAL_LIST_INIT(quest_mechs_equipment_weapons, list(
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/disabler = 97,			/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser = 97,
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot = 96,			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg = 96,
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang = 92,	/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser = 91,
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine = 91,				/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy = 88,
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion = 84,						/obj/item/mecha_parts/mecha_equipment/weapon/energy/tesla = 84,
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/immolator = 84,					/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack = 84,
	))

////////////////////////////
//Прок генерирующий квест на Меха и необходимый эквип для него
////////////////////////////
/datum/cargo_quests_storage/proc/generate_mecha_info(var/datum/cargo_quest/quest)
	if(!quest)
		log_debug("Quest generation attempted without a quest datum reference!")
		return
	if(!quest.quest_difficulty)
		quest.generate_difficulty()
	var/list/mecha_list = list(GLOB.quest_mechs)
	switch(quest.quest_difficulty)
		if(QUEST_DIFFICULTY_EASY)
			for(var/item in mecha_list)
				if(mecha_list[item] <= 15)	// Удаляем редких мехов
					mecha_list -= item
		if(QUEST_DIFFICULTY_NORMAL)
			for(var/item in mecha_list)
				if(mecha_list[item] <= 5)	// Удаляем самых редких мехов
					mecha_list -= item
		if(QUEST_DIFFICULTY_HARD)
			for(var/item in mecha_list)
				if(mecha_list[item] > 15)	// Удаляем самых частых мехов
					mecha_list -= item

	quest.req_item = pickweight(GLOB.quest_mechs)
	var/req_mech = quest.req_item
	var/list/mech_equipment_all_cut = list()
	mech_equipment_all_cut.Add(GLOB.quest_mechs_equipment_all)
	mech_equipment_all_cut.Cut(1,3)
	var/max_equip
	//вписать выбор нужной иконки
	log_debug("Generating quest of type \"Mecha\"")
	if(req_mech == /obj/mecha/combat/honker)
		quest.current_list += (GLOB.quest_mechs_equipment_all)
		quest.current_list += (GLOB.quest_mechs_equipment_honk)
		if(quest.quest_difficulty == QUEST_DIFFICULTY_HARD)
			quest.current_list += (GLOB.quest_mechs_equipment_weapons)
		max_equip = 3
		log_debug("Chosen mech: Honker")
	else if(req_mech == /obj/mecha/combat/reticence)
		quest.current_list += (GLOB.quest_mechs_equipment_all)
		quest.current_list += (GLOB.quest_mechs_equipment_reticence)
		if(quest.quest_difficulty == QUEST_DIFFICULTY_HARD)
			quest.current_list += (GLOB.quest_mechs_equipment_weapons)
		max_equip = 3
		log_debug("Chosen mech: Reticence")
	else if(req_mech == /obj/mecha/working/ripley || req_mech == /obj/mecha/working/ripley/firefighter)
		quest.current_list += (GLOB.quest_mechs_equipment_all)
		quest.current_list += (GLOB.quest_mechs_equipment_working)
		if(quest.quest_difficulty == QUEST_DIFFICULTY_HARD)
			quest.current_list += (GLOB.quest_mechs_equipment_weapons)
		max_equip = 6
		log_debug("Chosen mech: Ripley or Firefighter")
	else if(req_mech == /obj/mecha/working/clarke)
		quest.current_list += (GLOB.quest_mechs_equipment_all)
		quest.current_list += (GLOB.quest_mechs_equipment_working)
		max_equip = 4
		log_debug("Chosen mech: Clarke")
	else if(req_mech == /obj/mecha/medical/odysseus)
		quest.current_list += (GLOB.quest_mechs_equipment_medical)
		max_equip = 3
		log_debug("Chosen mech: Medical")
	else if(req_mech == /obj/mecha/makeshift)
		quest.current_list += (mech_equipment_all_cut)
		max_equip = 2
		log_debug("Chosen mech: Makeshift")
	else
		quest.current_list += (GLOB.quest_mechs_equipment_all)
		quest.current_list += (GLOB.quest_mechs_equipment_weapons)
		max_equip = 3
		log_debug("Chosen mech: Battle Mech")
	for(var/i in 1 to max_equip)
		var/current_equipment = pickweight(quest.current_list)
		quest.req_else += (current_equipment)
		quest.current_list -= (current_equipment)
	log_debug("Generation end")
