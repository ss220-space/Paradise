//STRIKE TEAMS

#define COMMANDOS_POSSIBLE 6 //if more Commandos are needed in the future
GLOBAL_VAR_INIT(sent_strike_team, FALSE)

/client/proc/strike_team()
	if(!SSticker)
		to_chat(src, span_userdanger("Игра еще не началась!"))
		return
	if(GLOB.sent_strike_team)
		to_chat(src, span_userdanger("Центральное Командование уже отправило один отряд."))
		if(tgui_alert(src, "Вы хотите послать еще один?","Подтверждение", list("Да","Нет")) != "Да")
			return
	else if(tgui_alert(src, "Вы хотите отправить отряд смерти Центрального Коммандования? После согласия это необратимо.", "Подтверждение", list("Да","Нет")) != "Да")
		return
	tgui_alert(src, "Этот «режим» будет продолжаться до тех пор, пока все не умрут или станция не будет уничтожена. Также, при необходимости, можно вызвать эвакуационный шаттл через админские кнопки. Появившиеся коммандос имеют внутренние камеры, которые можно просматривать через монитор внутри Офиса Спецопераций. Руководить командой рекомендуется оттуда. Первый выбранный/появившийся будет лидером команды.")

	message_admins(span_notice("[key_name_admin(usr)] has started to spawn a CentComm DeathSquad."))

	var/input = null
	while(!input)
		input = tgui_input_text(src, "Пожалуйста, уточните, какую миссию будет выполнять Отряд Смерти.", "Укажите миссию", "", max_length=MAX_MESSAGE_LEN)
		if(!input)
			if(tgui_alert(src, "Ошибка, миссия не задана. Вы хотите приостановить процесс? ", "Подтверждение", list("Да","Нет")) == "Да")
				return

	// Find the nuclear auth code
	var/nuke_code
	var/temp_code
	for(var/obj/machinery/nuclearbomb/N in GLOB.machines)
		temp_code = text2num(N.r_code)
		if(temp_code)//if it's actually a number. It won't convert any non-numericals.
			nuke_code = N.r_code
			break

	// Find ghosts willing to be DS
	var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_deathsquad")
	var/list/commando_ghosts = pick_candidates_all_types(src, COMMANDOS_POSSIBLE, "Присоединиться к Отряду Смерти?", , 21, 60 SECONDS, TRUE, GLOB.role_playtime_requirements[ROLE_DEATHSQUAD], TRUE, FALSE, source, "Отряд Смерти", input)
	if(!commando_ghosts.len)
		to_chat(src, span_userdanger("Никто не вызвался присоединиться к Отряду Смерти."))
		return

	GLOB.sent_strike_team = TRUE

	// Spawns commandos and equips them.
	var/commando_number = COMMANDOS_POSSIBLE //for selecting a leader
	var/is_leader = TRUE // set to FALSE after leader is spawned

	for(var/obj/effect/landmark/L in GLOB.landmarks_list)
		if(commando_number <= 0)
			break

		if(L.name == "Commando")

			if(!commando_ghosts.len)
				break

			var/use_ds_borg = FALSE
			var/mob/ghost_mob = pick(commando_ghosts)
			commando_ghosts -= ghost_mob
			if(!ghost_mob || !ghost_mob.key || !ghost_mob.client)
				continue

			if(!is_leader)
				var/new_dstype = tgui_alert(ghost_mob.client, "Выберете тип члена Отряда Смерти.", "Создание персонажа.",list("Органик", "Борг"))
				if(new_dstype == "Борг")
					use_ds_borg = TRUE

			if(!ghost_mob || !ghost_mob.key || !ghost_mob.client) // Have to re-check this due to the above alert() call
				continue

			if(use_ds_borg)
				var/mob/living/silicon/robot/deathsquad/R = new()
				R.forceMove(get_turf(L))
				var/rnum = rand(1,1000)
				var/borgname = "Epsilon [rnum]"
				R.name = borgname
				R.custom_name = borgname
				R.real_name = R.name
				R.mind = new
				R.mind.current = R
				R.mind.set_original_mob(R)
				R.mind.assigned_role = SPECIAL_ROLE_DEATHSQUAD
				R.mind.special_role = SPECIAL_ROLE_DEATHSQUAD
				R.mind.offstation_role = TRUE
				if(!(R.mind in SSticker.minds))
					SSticker.minds += R.mind
				SSticker.mode.traitors += R.mind
				R.key = ghost_mob.key
				if(nuke_code)
					R.mind.store_memory("<B>Коды от боеголовки:</B> <span class='warning'>[nuke_code].</span>")
				R.mind.store_memory("<B>Миссия:</B> <span class='warning'>[input].</span>")
				to_chat(R, span_userdanger("Вы борг отдела Специальных Операций, подчиняющийся Центральному Командованию. \nВаша миссия: <span class='danger'>[input]</span>"))
			else
				var/mob/living/carbon/human/new_commando = create_death_commando(L, is_leader)
				new_commando.mind.key = ghost_mob.key
				new_commando.key = ghost_mob.key
				new_commando.internal = new_commando.s_store
				new_commando.update_action_buttons_icon()
				new_commando.change_voice()
				if(nuke_code)
					new_commando.mind.store_memory("<B>Коды от боеголовки:</B> <span class='warning'>[nuke_code].</span>")
				new_commando.mind.store_memory("<B>Миссия:</B> <span class='warning'>[input].</span>")
				to_chat(new_commando, span_userdanger("Вы [is_leader ? "<B>КОМАНДИР</B>" : "боец"] отряда Специальных Операций, подчиняющийся Центральному Командованию. \nВаша миссия: <span class='danger'>[input]</span>"))

			is_leader = FALSE
			commando_number--

	//Spawns the rest of the commando gear.
	for(var/obj/effect/landmark/L in GLOB.landmarks_list)

		if(L.name == "Commando_Manual")
			//new /obj/item/gun/energy/pulse_rifle(L.loc)
			var/obj/item/paper/pamphletdeathsquad/P = new(L.loc)
			P.info = "<p><b>Доброе утро, солдат!</b>. \
			Это компактное руководство познакомит тебя со стандартной процедурой операции. \
			Есть три основных правила, которым нужно следовать:<br>\
			#1 Работай в команде.<br>\
			#2 Достигай своей цели любой ценой.<br>\
			#3 Не оставляй свидетелей.<br>\
			Ты полностью экипирован и подготовлен к миссии — перед отправкой на шаттле Специальных операций\
			севернее, убедись, что все бойцы готовы.\
			Фактическая цель миссии будет передана тебе Центральным Командованием через гарнитуру.<br>\
			Если это будет сочтено уместным, Центральное Командование также позволит членам твоей команды экипироваться штурмовыми мехами для миссии. \
			Ты найдешь оружейную с ними на западе от твоей позиции.  \
			Когда будешь готов к отправке, используй консоль специального оперативного шаттла и переключи двери корпуса через другую консоль.</p>\
			<p>В случае, если команда не выполнит поставленную задачу вовремя или не найдет другого способа её выполнить, ниже приведены инструкции по эксплуатации ядерного устройства Nanotrasen. \
			Твой <b>КОМАНДИР</b> обеспечен диском аутентификации и пинпоинтером для этой цели. \
			Ты легко узнаешь его по рангу: Лейтенант, Капитан или Майор \
			Сама ядерная боеголовка будет находиться где-то в пункте назначения.</p>\
			<p>Здравствуйте и спасибо, что выбрали Nanotrasen для получения информации о ядерных устройствах. \
			Сегодняшний экспресс-курс будет посвящен эксплуатации ядерного устройства термоядерного класса производства Nanotrasen.<br>\
			Прежде всего, <b>НЕ ТРОГАЙ НИЧЕГО, ПОКА БОМБА НЕ УСТАНОВЛЕНА.</b> \
			Нажатие любой кнопки на сложенной бомбе заставит её развернуться и закрепиться на месте. \
			Если это произойдет, для разблокировки необходимо будет полностью авторизоваться, что в данный момент может быть невозможно.<br>\
			Чтобы сделать устройство функциональным:<br>\
			#1 Помести бомбу в обозначенную зону детонации<br> \
			#2 Разверни и закрепи бомбу (ударь её рукой).<br>\
			#3 Вставь диск аутентификации в слот.<br>\
			#4 Введи цифровой код ([nuke_code]) на клавиатуре.<br>\
			Примечание: Если сделаешь ошибку, нажми R для сброса устройства.<br>\
			#5 Нажми кнопку E, чтобы авторизоваться в устройстве<br>Вы успешно активировали боеголовку. \
			Чтобы деактивировать кнопки в любое время, например, когда ты уже подготовил бомбу к детонации, удали диск аутентификации ИЛИ нажми R на клавиатуре. \
			Теперь бомба МОЖЕТ БЫТЬ взорвана только с помощью таймера. Ручная детонация невозможна.<br>Примечание: Отключи <b>ПРЕДОХРАНИТЕЛЬ</b>.<br>\
			Используй - - и + + для установки времени детонации от 5 секунд до 10 минут. Затем нажми кнопку таймера для запуска обратного отсчета. \
			Теперь удали диск аутентификации, чтобы кнопки деактивировались.<br>Примечание: <b>БОМБА ВСЕ ЕЩЕ УСТАНОВЛЕНА И ВЗОРВЕТСЯ</b><br>\
			Теперь, прежде чем удалить диск, если нужно переместить бомбу, можешь: открепить её, переместить и снова закрепить.</p><p>\
			Код ядерной аутентификации: <b>[nuke_code ? nuke_code : "Не предоставлен"]</b></p>\
			<p><b>Удачи, солдат!</b></p>"
			P.name = "Руководство по Специальным Операциям"
			P.stamp(/obj/item/stamp/centcom)

	for(var/obj/effect/landmark/L in GLOB.landmarks_list)
		if(L.name == "Commando-Bomb")
			new /obj/effect/spawner/newbomb/timer/syndicate(L.loc)
			qdel(L)

	message_admins(span_notice("[key_name_admin(usr)] has spawned a CentComm DeathSquad."))
	log_admin("[key_name(usr)] used Spawn Death Squad.")
	return 1

/client/proc/create_death_commando(obj/spawn_location, is_leader = FALSE)
	var/mob/living/carbon/human/new_commando = new(spawn_location.loc)
	var/commando_leader_rank = pick("Лейтенант", "Капитан", "Майор")
	var/commando_rank = pick("Младший Сержант", "Сержант", "Старший Сержант", "Старшина", "Прапорщик", "Старший Прапорщик")
	var/commando_name = pick(GLOB.last_names)

	var/datum/preferences/A = new()//Randomize appearance for the commando.
	if(is_leader)
		A.age = rand(35,45)
		A.real_name = "[commando_leader_rank] [A.gender==FEMALE ? pick(GLOB.last_names_female) : commando_name]"
	else
		A.real_name = "[commando_rank] [A.gender==FEMALE ? pick(GLOB.last_names_female) : commando_name]"
	A.copy_to(new_commando)


	new_commando.dna.ready_dna(new_commando)//Creates DNA.

	//Creates mind stuff.
	new_commando.mind_initialize()
	new_commando.mind.assigned_role = SPECIAL_ROLE_DEATHSQUAD
	new_commando.mind.special_role = SPECIAL_ROLE_DEATHSQUAD
	SSticker.mode.traitors |= new_commando.mind//Adds them to current traitor list. Which is really the extra antagonist list.
	if(is_leader)
		new_commando.equipOutfit(/datum/outfit/admin/death_commando/officer)
	else
		new_commando.equipOutfit(/datum/outfit/admin/death_commando)
	return new_commando
