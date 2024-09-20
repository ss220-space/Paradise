//HONKsquad

#define HONKSQUAD_POSSIBLE 6 //if more Commandos are needed in the future
GLOBAL_VAR_INIT(sent_honksquad, 0)
GLOBAL_VAR_INIT(sent_clownsequritysquad, 0)

/client/proc/honksquad()
	if(!SSticker)
		to_chat(src, "<font color='red'>Игра еще не началась!</font>")
		return
	if(world.time < 6000)
		to_chat(src, "<font color='red'>Осталось [(6000-world.time)/10] секунд до того, как это может быть вызвано.</font>")
		return
	if(tgui_alert(src, "Вы хотите отправить ХОНКсквад? После согласия это необратимо.", "Подтверждение", list("Да","Нет")) != "Да")
		return
	var/is_security_clowns = FALSE
	if(tgui_alert(src, "Какую группу вы хотите послать?","Тип отряда", list("ХОНК-сквад", "ХОНК-смотрители")) == "ХОНК-смотрители")
		is_security_clowns = TRUE
		GLOB.sent_clownsequritysquad += 1
	else
		GLOB.sent_honksquad += 1

	if(GLOB.sent_honksquad > 1 && !is_security_clowns || GLOB.sent_clownsequritysquad > 1 && is_security_clowns)
		to_chat(src, "<font color='red'>Планета Клоунов уже отправила ХОНКсквад.</font>")
		return
	tgui_alert(src, "Этот 'режим' будет продолжаться до тех пор, пока не будут восстановлены надлежащий уровень ХОНКа. Также, при необходимости, можно вызвать эвакуационный шаттл через админские кнопки.")

	var/input = null
	while(!input)
		input = tgui_input_text(src, "Пожалуйста, уточните, какую миссию будет выполнять ХОНКсквад.", "Укажите миссию", "", max_length=MAX_MESSAGE_LEN)
		if(!input)
			if(tgui_alert(src, "Ошибка, миссия не задана. Вы хотите приостановить процесс?", "Подтверждение", list("Да","Нет")) == "Да")
				return


	var/honksquad_number = HONKSQUAD_POSSIBLE //for selecting a leader
	var/honk_leader_selected = 0 //when the leader is chosen. The last person spawned.


//Generates a list of HONKsquad from active ghosts. Then the user picks which characters to respawn as the commandos.
	var/list/candidates = pick_candidates_all_types(src, HONKSQUAD_POSSIBLE, "Присоединиться к ХОНКскваду?", , 21, 30 SECONDS, FALSE, 60, TRUE, FALSE,, "ХОНКсквад", input)

//Spawns HONKsquad and equips them.
	for(var/obj/effect/landmark/L in GLOB.landmarks_list)
		if(honksquad_number<=0)	break
		if(L.name == "HONKsquad")
			honk_leader_selected = (honksquad_number == HONKSQUAD_POSSIBLE ? 1 : 0)

			var/mob/living/carbon/human/new_honksquad = is_security_clowns ? create_honksquad_security(L, honk_leader_selected) : create_honksquad(L, honk_leader_selected)

			if(candidates.len)
				var/mob/mob = pick(candidates)
				new_honksquad.key = mob.key
				candidates -= new_honksquad.key
				new_honksquad.internal = new_honksquad.s_store
				new_honksquad.update_action_buttons_icon()

			//So they don't forget their code or mission.
			new_honksquad.mind.store_memory("<B>Миссия:</B> <span class='warning'>[input].</span>")

			to_chat(new_honksquad, span_notice("Вы [!honk_leader_selected ? "член" : "<B>ЛИДЕР</B>"] ХОНКсквада в подчинении Планеты Клоунов. Вас вызывают в случае крайне низкого уровня ХОНКа на объекте. Вы НЕ имеете права убивать.\nВаша текущая миссия: <span class='danger'>[input]</span>"))

			honksquad_number--


	log_and_message_admins("used Spawn HONKsquad.")
	return 1

/client/proc/create_honksquad(obj/spawn_location, honk_leader_selected = 0)
	var/mob/living/carbon/human/new_honksquad = new(spawn_location.loc)
	var/honksquad_leader_rank = pick("Лейтенант", "Капитан", "Майор")
	var/honksquad_rank = pick("Младший Сержант", "Сержант", "Старший Сержант", "Старшина", "Прапорщик", "Старший Прапорщик")
	var/honksquad_name = pick(GLOB.clown_names)

	var/datum/preferences/A = new()//Randomize appearance for the commando.
	if(honk_leader_selected)
		A.age = rand(35,45)
		A.real_name = "[honksquad_leader_rank] [honksquad_name]"
	else
		A.real_name = "[honksquad_rank] [honksquad_name]"
	var/rankName = honk_leader_selected ? honksquad_leader_rank : honksquad_rank
	A.copy_to(new_honksquad)

	new_honksquad.dna.ready_dna(new_honksquad)//Creates DNA.

	//Creates mind stuff.
	new_honksquad.mind_initialize()
	new_honksquad.mind.assigned_role = SPECIAL_ROLE_HONKSQUAD
	new_honksquad.mind.special_role = SPECIAL_ROLE_HONKSQUAD
	new_honksquad.mind.offstation_role = TRUE
	new_honksquad.add_language(LANGUAGE_CLOWN)
	new_honksquad.change_voice()
	SSticker.mode.traitors |= new_honksquad.mind//Adds them to current traitor list. Which is really the extra antagonist list.
	new_honksquad.equip_honksquad(honk_leader_selected, rankName)
	return new_honksquad

/mob/living/carbon/human/proc/equip_honksquad(honk_leader_selected = 0, var/rankName)

	var/obj/item/radio/R = new /obj/item/radio/headset(src)
	R.set_frequency(1442)
	equip_to_slot_or_del(R, ITEM_SLOT_EAR_LEFT)
	equip_to_slot_or_del(new /obj/item/storage/backpack/clown(src), ITEM_SLOT_BACK)
	equip_to_slot_or_del(new /obj/item/storage/box/survival(src), ITEM_SLOT_BACKPACK)
	if(src.gender == FEMALE)
		equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat/sexy(src), ITEM_SLOT_MASK)
		equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown/sexy(src), ITEM_SLOT_CLOTH_INNER)
	else
		equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(src), ITEM_SLOT_CLOTH_INNER)
		equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(src), ITEM_SLOT_MASK)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(src), ITEM_SLOT_FEET)
	equip_to_slot_or_del(new /obj/item/pda/clown(src), ITEM_SLOT_PDA)
	equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(src), ITEM_SLOT_MASK)
	equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/grown/banana(src), ITEM_SLOT_BACKPACK)
	equip_to_slot_or_del(new /obj/item/bikehorn(src), ITEM_SLOT_BACKPACK)
	equip_to_slot_or_del(new /obj/item/clown_recorder(src), ITEM_SLOT_BACKPACK)
	equip_to_slot_or_del(new /obj/item/stamp/clown(src), ITEM_SLOT_BACKPACK)
	equip_to_slot_or_del(new /obj/item/toy/crayon/rainbow(src), ITEM_SLOT_BACKPACK)
	equip_to_slot_or_del(new /obj/item/reagent_containers/spray/waterflower(src), ITEM_SLOT_BACKPACK)
	equip_to_slot_or_del(new /obj/item/reagent_containers/food/pill/patch/jestosterone(src), ITEM_SLOT_POCKET_RIGHT)
	if(prob(50))
		equip_to_slot_or_del(new /obj/item/gun/energy/clown(src), ITEM_SLOT_BACKPACK)
	else
		equip_to_slot_or_del(new /obj/item/gun/throw/piecannon(src), ITEM_SLOT_BACKPACK)
	force_gene_block(GLOB.clumsyblock, TRUE, TRUE)
	grant_mimicking()
	var/obj/item/implant/sad_trombone/S = new/obj/item/implant/sad_trombone(src)
	S.implant(src)

	var/obj/item/card/id/I = new(src)
	apply_to_card(I, src, list(ACCESS_CLOWN), "HONKsquad", "clownsquad")
	I.assignment = "[rankName] ХОНК-отряда"
	equip_to_slot_or_del(I, ITEM_SLOT_ID)

	return TRUE

/client/proc/create_honksquad_security(obj/spawn_location, honk_leader_selected = 0)
	var/mob/living/carbon/human/new_honksquad = new(spawn_location.loc)

	new_honksquad.dna.ready_dna(new_honksquad)//Creates DNA.

	//Creates mind stuff.
	new_honksquad.mind_initialize()
	new_honksquad.mind.assigned_role = SPECIAL_ROLE_HONKSQUAD
	new_honksquad.mind.special_role = SPECIAL_ROLE_HONKSQUAD
	new_honksquad.mind.offstation_role = TRUE
	SSticker.mode.traitors |= new_honksquad.mind//Adds them to current traitor list. Which is really the extra antagonist list.

	//экипируем уже готовы пресетом
	if(honk_leader_selected)
		new_honksquad.equipOutfit(/datum/outfit/admin/clown_security/warden)
	else
		if(prob(25))
			new_honksquad.equipOutfit(/datum/outfit/admin/clown_security/physician)
		else
			new_honksquad.equipOutfit(/datum/outfit/admin/clown_security)

	return new_honksquad
