// Админские кнопки режима.
//
// Раздача ролей на старте и поздний заход спрашивают игрока, а здесь решает админ:
// поставить опоздавшего в нужное отделение, разжаловать командира, перекинуть
// перекошенную по числу бойцов сторону. Вся работа уходит в mode.assign_player() —
// ту же дверь, через которую заходят и остальные.

/// Кого можно ставить в строй прямо сейчас: живое тело или игрок в лобби.
/// Наблюдателю тела взять неоткуда — его сперва возвращают в раунд штатным респавном.
/proc/mw_can_assign(mob/target)
	return isliving(target) || isnewplayer(target)

ADMIN_VERB_AND_CONTEXT_MENU(mw_assign, R_EVENT, "MW: Фракция и роль", "Ставит игрока во фракцию Mountain Wars и выдаёт роль.", ADMIN_CATEGORY_EVENTS, mob/target in GLOB.mob_list)
	var/datum/game_mode/mountain_wars/mode = SSticker?.mode
	if(!istype(mode))
		to_chat(user, span_warning("Раунд не Mountain Wars."))
		return
	if(!target?.mind)
		to_chat(user, span_warning("У [target] нет разума — ставить в строй некого."))
		return
	if(!mw_can_assign(target))
		to_chat(user, span_warning("[target] сейчас без тела. Верните в раунд, потом назначайте."))
		return

	var/list/factions = list()
	for(var/faction in mode.teams)
		var/datum/team/mountain_wars/team = mode.teams[faction]
		factions["[team.name] — бойцов: [LAZYLEN(team.members)]"] = faction
	var/faction_choice = tgui_input_list(user, "Фракция", "Mountain Wars", factions)
	if(!faction_choice)
		return
	var/faction = factions[faction_choice]

	var/list/roles = GLOB.mountain_wars_roles[faction]
	var/role_choice = tgui_input_list(user, "Роль", "Mountain Wars", roles)
	if(!role_choice)
		return

	// Пока админ выбирал, игрок мог уйти, умереть или уже влезть в бой сам.
	if(QDELETED(target) || !target.mind || !mw_can_assign(target))
		to_chat(user, span_warning("[target] больше не годится в строй."))
		return

	// Из лобби выходят так же, как через кнопку «Присоединиться»: экран прячем, тело
	// создаст сама выдача роли, а лобби-моб после этого лишний.
	var/from_lobby = isnewplayer(target)
	if(from_lobby && target.client)
		SStitle.hide_title_screen_from(target.client)
	if(!mode.assign_player(target.mind, faction, roles[role_choice]))
		to_chat(user, span_warning("Не вышло поставить [target] в строй."))
		return
	if(from_lobby && !QDELETED(target))
		qdel(target)

	BLACKBOX_LOG_ADMIN_VERB("MW Assign Role")
	log_and_message_admins("поставил [key_name_log(target)] в [faction] на роль «[role_choice]».")

// Объявить победу руками. Штатное условие — исчерпанные билеты и ни одного живого
// морпеха — сходится не всегда: последний морпех может засесть в углу карты, а ивент
// пора сворачивать. Заодно это единственный способ проверить сам ролик, не доигрывая
// раунд до конца.
ADMIN_VERB(mw_declare_victory, R_EVENT, "MW: Объявить победу", "Играет ролик победы выбранной фракции и раскрывает итоги боя.", ADMIN_CATEGORY_EVENTS)
	var/datum/game_mode/mountain_wars/mode = SSticker?.mode
	if(!istype(mode))
		to_chat(user, span_warning("Раунд не Mountain Wars."))
		return

	var/list/factions = list()
	for(var/faction in mode.teams)
		var/datum/team/mountain_wars/team = mode.teams[faction]
		factions[team.name] = faction
	var/faction_choice = tgui_input_list(user, "Чья победа", "Mountain Wars", factions)
	if(!faction_choice)
		return

	// Победа объявляется один раз за раунд, и защита стоит в самом declare_victory.
	// Предупреждаем здесь, иначе кнопка молча не сработает.
	if(mode.winner)
		to_chat(user, span_warning("Победа уже объявлена — ролик второй раз не пойдёт."))
		return

	mode.declare_victory(factions[faction_choice])
	BLACKBOX_LOG_ADMIN_VERB("MW Declare Victory")
	log_and_message_admins("объявил победу фракции «[faction_choice]» в Mountain Wars.")

// Собрать весь раунд в одну кучу: брифинг, разбор полётов, финальная бойня. Точка —
// клетка под самим админом, отдельного выбора координат не заводим: долететь туда
// призраком и нажать кнопку короче, чем набирать три числа.
ADMIN_VERB(mw_gather_all, R_EVENT, "MW: Собрать всех сюда", "Телепортирует всех игроков на клетку под вами.", ADMIN_CATEGORY_EVENTS)
	var/datum/game_mode/mountain_wars/mode = SSticker?.mode
	if(!istype(mode))
		to_chat(user, span_warning("Раунд не Mountain Wars."))
		return
	var/turf/point = get_turf(user.mob)
	if(!point)
		to_chat(user, span_warning("Вы сами вне мира — телепортировать некуда."))
		return

	// Сидящих в лобби не трогаем: тела у них нет, двигать нечего.
	var/list/mob/crowd = list()
	for(var/mob/player as anything in GLOB.player_list)
		if(QDELETED(player) || player == user.mob || isnewplayer(player))
			continue
		crowd += player
	if(!length(crowd))
		to_chat(user, span_warning("Некого собирать."))
		return
	if(tgui_alert(user, "Стянуть [length(crowd)] игроков на [COORD(point)]?", "Mountain Wars", list("Да", "Нет")) != "Да")
		return

	var/moved = 0
	for(var/mob/player as anything in crowd)
		if(QDELETED(player))
			continue
		// Пристёгнутого forceMove утащит вместе с привязкой, и он останется сидеть
		// на стуле, оставшемся за полкарты отсюда.
		if(isliving(player))
			var/mob/living/body = player
			body.buckled?.unbuckle_mob(body, force = TRUE)
		player.forceMove(point)
		moved++

	BLACKBOX_LOG_ADMIN_VERB("MW Gather All")
	log_and_message_admins("стянул всех игроков ([moved]) на [AREACOORD(point)].")
