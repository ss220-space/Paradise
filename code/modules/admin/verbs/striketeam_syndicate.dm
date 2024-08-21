//STRIKE TEAMS

#define SYNDICATE_COMMANDOS_POSSIBLE 6 //if more Commandos are needed in the future
GLOBAL_VAR_INIT(sent_syndicate_strike_team, 0)
/client/proc/syndicate_strike_team()
	set category = "Event"
	set name = "Заспавнить Ударный Отряд Синдиката"
	set desc = "Спавнит Ударный Отряд Синдиката в месте их дислокации на СЦК."
	if(!src.holder)
		to_chat(src, "Только администраторы могут использовать эту команду.")
		return
	if(!SSticker)
		tgui_alert(src, "Игра еще не началась!")
		return
	if(GLOB.sent_syndicate_strike_team == 1)
		tgui_alert(src, "Синдикат уже отправил отряд, Мистер Тупой.")
		return
	if(tgui_alert(src, "Вы действительно хотите отправить Ударный Отряд Синдиката? После согласия это необратимо.", "Подтверждение", list("Да","Нет")) != "Да")
		return
	tgui_alert(src, "Этот 'режим' будет продолжаться до тех пор, пока все не погибнут или станция не будет разрушена. Также, при необходимости, можно вызвать эвакуационный шаттл через админские кнопки. У появившихся агентов синдиката есть внутренние камеры, которые можно просматривать через монитор на мостике корабля синдиката. Руководить командой рекомендуется оттуда. Первый выбранный/появившийся будет лидером команды.")

	message_admins(span_notice("[key_name_admin(usr)] has started to spawn a Syndicate Strike Team."))

	var/input = null
	while(!input)
		input = tgui_input_text(src, "Пожалуйста, уточните, какую миссию будет выполнять ударный отряд синдиката.", "Укажите миссию", "", max_length=MAX_MESSAGE_LEN)
		if(!input)
			if(tgui_alert(src, "Ошибка, миссия не задана. Вы хотите приостановить процесс? ", "Подтверждение", list("Да","Нет")) == "Да")
				return

	if(GLOB.sent_syndicate_strike_team)
		to_chat(src, "Кажется кто-то стукнет вас за это.")
		return

	var/syndicate_commando_number = SYNDICATE_COMMANDOS_POSSIBLE //for selecting a leader
	var/is_leader = TRUE // set to FALSE after leader is spawned

	// Find the nuclear auth code
	var/nuke_code
	var/temp_code
	for(var/obj/machinery/nuclearbomb/N in GLOB.machines)
		temp_code = text2num(N.r_code)
		if(temp_code)//if it's actually a number. It won't convert any non-numericals.
			nuke_code = N.r_code
			break

	// Find ghosts willing to be SST
	var/image/I = new('icons/obj/cardboard_cutout.dmi', "cutout_commando")
	var/list/commando_ghosts = pick_candidates_all_types(src, SYNDICATE_COMMANDOS_POSSIBLE, "Присоединиться к Ударному Отряду Синдиката?", , 21, 60 SECONDS, TRUE, GLOB.role_playtime_requirements[ROLE_DEATHSQUAD], TRUE, FALSE, I, "Ударный Отряд Синдиката", input)
	if(!commando_ghosts.len)
		to_chat(src, span_userdanger("Никто не присоединился к SST."))
		return

	GLOB.sent_syndicate_strike_team = 1

	//Spawns commandos and equips them.
	for(var/obj/effect/landmark/L in GLOB.landmarks_list)
		if(syndicate_commando_number <= 0)
			break

		if(L.name == "Syndicate-Commando")

			if(!commando_ghosts.len)
				break

			var/mob/ghost_mob = pick(commando_ghosts)
			commando_ghosts -= ghost_mob

			if(!ghost_mob || !ghost_mob.key || !ghost_mob.client)
				continue

			var/mob/living/carbon/human/new_syndicate_commando = create_syndicate_death_commando(L, is_leader)

			if(!new_syndicate_commando)
				continue

			new_syndicate_commando.key = ghost_mob.key
			new_syndicate_commando.internal = new_syndicate_commando.s_store
			new_syndicate_commando.update_action_buttons_icon()

			//So they don't forget their code or mission.
			if(nuke_code)
				new_syndicate_commando.mind.store_memory("<B>Коды от боеголовки:</B> <span class='warning'>[nuke_code]</span>.")
			new_syndicate_commando.mind.store_memory("<B>Миссия:</B> <span class='warning'>[input]</span>.")

			to_chat(new_syndicate_commando, span_notice("Вы [is_leader ? "<B>Лидер</B>" : "боец"] Элитного Отряда в подчинении Синдиката. \nВаша миссия: <span class='userdanger'>[input]</span>"))
			new_syndicate_commando.faction += "syndicate"
			var/datum/atom_hud/antag/opshud = GLOB.huds[ANTAG_HUD_OPS]
			opshud.join_hud(new_syndicate_commando.mind.current)
			set_antag_hud(new_syndicate_commando.mind.current, "hudoperative")
			new_syndicate_commando.regenerate_icons()
			is_leader = FALSE
			syndicate_commando_number--

	message_admins(span_notice("[key_name_admin(usr)] has spawned a Syndicate strike squad."))
	log_admin("[key_name(usr)] used Spawn Syndicate Squad.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Send SST") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/create_syndicate_death_commando(obj/spawn_location, is_leader = FALSE)
	var/mob/living/carbon/human/new_syndicate_commando = new(spawn_location.loc)
	var/syndicate_commando_leader_rank = pick("Лейтенант", "Капитан", "Майор")
	var/syndicate_commando_rank = pick("Младший Сержант", "Сержант", "Старший Сержант", "Старшина", "Прапорщик", "Старший Прапорщик")
	var/syndicate_commando_name = pick(GLOB.last_names)

	var/datum/preferences/A = new()//Randomize appearance for the commando.
	if(is_leader)
		A.age = rand(35,45)
		A.real_name = "[syndicate_commando_leader_rank] [A.gender==FEMALE ? pick(GLOB.last_names_female) : syndicate_commando_name]"
	else
		A.real_name = "[syndicate_commando_rank] [A.gender==FEMALE ? pick(GLOB.last_names_female) : syndicate_commando_name]"
	A.copy_to(new_syndicate_commando)

	new_syndicate_commando.dna.ready_dna(new_syndicate_commando)//Creates DNA.

	//Creates mind stuff.
	new_syndicate_commando.mind_initialize()
	new_syndicate_commando.mind.assigned_role = SPECIAL_ROLE_SYNDICATE_DEATHSQUAD
	new_syndicate_commando.mind.special_role = SPECIAL_ROLE_SYNDICATE_DEATHSQUAD
	new_syndicate_commando.mind.offstation_role = TRUE
	new_syndicate_commando.change_voice()
	SSticker.mode.traitors |= new_syndicate_commando.mind	//Adds them to current traitor list. Which is really the extra antagonist list.
	if(is_leader)
		new_syndicate_commando.equipOutfit(/datum/outfit/admin/syndicate_strike_team/officer)
	else
		new_syndicate_commando.equipOutfit(/datum/outfit/admin/syndicate_strike_team)
	qdel(spawn_location)
	return new_syndicate_commando
