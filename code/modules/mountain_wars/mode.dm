// Минуты до появления кнопки респавна у трупа. Повстанцы уходят в бой сразу после неё,
// морпехи дополнительно ждут окно волны.
#define RESPAWN_MW_DELAY 3
#define MW_MARINE_TICKETS 100
#define MW_WAVE_INTERVAL (6 MINUTES)
#define MW_WAVE_WINDOW (1 MINUTES)
// Раздача ролей на старте: отряд из 8 — командир, медик, инженер, пулемётчик и
// четверо рядовых. Спецроли идут первыми в GLOB.mountain_wars_roles, рядовой —
// последним, поэтому раздача считается по порядковому номеру в отряде.
#define MW_SQUAD_SIZE 8
#define MW_SQUAD_SPECIALISTS 4
// Сколько игрок думает над ролью на старте, прежде чем получить её по разнарядке.
#define MW_ROLE_PICK_TIME (20 SECONDS)
// Сколько у морпехов есть на отход после подрыва завода.
#define MW_EVAC_TIME (5 MINUTES)
// За сколько до конца напоминаем.
#define MW_EVAC_WARNING (1 MINUTES)

/datum/game_mode/mountain_wars
	name = "mountain_wars"
	config_tag = "mountain_wars"
	required_players = 2
	var/list/players
	var/list/teams = list()
	/// Билеты морпехов: каждая смерть морпеха снимает один.
	var/marine_tickets = MW_MARINE_TICKETS
	/// Открыто ли окно волны подкреплений морпехов.
	var/wave_open = FALSE
	/// world.time следующей волны, для ETA в чате.
	var/next_wave_time = 0
	/// ckey -> фракция. Нужно для подсчёта и как значение по умолчанию при респавне.
	var/list/faction_by_ckey = list()
	/// "фракция|роль" -> сколько уже разобрано. Считаем только спецроли.
	var/list/role_taken = list()
	/// Кто победил. Пусто — бой ещё идёт.
	var/winner
	/// Когда истекает время на отход. Ноль — завод цел.
	var/evac_deadline = 0

/datum/game_mode/mountain_wars/pre_setup()
	var/list/temp_players = list()
	for(var/mob/new_player/player in GLOB.player_list)
		if(!player.client || !player.ready || !player.has_valid_preferences())
			continue
		temp_players |= player.mind

	shuffle(temp_players)
	// Чередуем фракции: чётные — морпехи, нечётные — повстанцы.
	var/list/faction_list = list(JOB_TITLE_MW_MARINE, JOB_TITLE_MW_INSURGENT)
	var/index = 0
	for(var/datum/mind/mind as anything in temp_players)
		var/faction = faction_list[(index++ % 2) + 1]
		mind.assigned_role = faction
		mind.special_role = faction
	players = temp_players
	return TRUE

/datum/game_mode/mountain_wars/post_setup()
	for(var/datum/team/mountain_wars/team as anything in list(/datum/team/mountain_wars/marine, /datum/team/mountain_wars/insurgent))
		teams[initial(team.team_role)] = new team

	var/list/faction_size = list()
	for(var/datum/mind/mind as anything in players)
		faction_size[mind.special_role] += 1

	// Счётчик на фракцию, чтобы раздать по одной спецроли на отряд.
	var/list/faction_index = list()
	for(var/datum/mind/mind as anything in players)
		var/faction = mind.special_role
		var/index = faction_index[faction] || 0
		faction_index[faction] = index + 1
		if(mind.current?.ckey)
			faction_by_ckey[mind.current.ckey] = faction
		// Опрос роли асинхронный: синхронный повесил бы старт раунда на всех,
		// пока каждый выбирает.
		INVOKE_ASYNC(src, PROC_REF(join_roundstart), mind, faction, index, role_limit(faction_size[faction]))

	GLOB.mw_scoreboard = new
	start_respawn_hud()
	SSevents.can_fire = FALSE
	GLOB.off_mob_spawns = TRUE
	GLOB.respawn_delay = RESPAWN_MW_DELAY
	next_wave_time = world.time + MW_WAVE_INTERVAL
	addtimer(CALLBACK(src, PROC_REF(open_wave)), MW_WAVE_INTERVAL)
	return ..()

/// Роль по порядковому номеру бойца в отряде: первые места — спецроли, дальше рядовые.
/datum/game_mode/mountain_wars/proc/roundstart_outfit(faction, index)
	var/list/roles = GLOB.mountain_wars_roles[faction]
	var/slot = index % MW_SQUAD_SIZE
	if(slot < MW_SQUAD_SPECIALISTS)
		return roles[roles[slot + 1]]
	return roles[roles[length(roles)]]

/// Сколько мест под каждую спецроль во фракции — по одному на отряд, как в разнарядке.
/datum/game_mode/mountain_wars/proc/role_limit(faction_size)
	return max(1, CEILING(faction_size / MW_SQUAD_SIZE, 1))

/// Спрашивает роль и заводит бойца в бой. Не ответил — идёт по разнарядке.
/datum/game_mode/mountain_wars/proc/join_roundstart(datum/mind/mind, faction, index, limit)
	var/datum/team/mountain_wars/team = teams[faction]
	team.add_member(mind, TRUE, pick_roundstart_role(mind, faction, index, limit))

/datum/game_mode/mountain_wars/proc/pick_roundstart_role(datum/mind/mind, faction, index, limit)
	var/list/roles = GLOB.mountain_wars_roles[faction]
	// Рядовой стоит в списке последним и мест не считает — в него берут всех.
	var/rank_and_file = roles[length(roles)]
	var/list/options = list()
	for(var/role in roles)
		if(role == rank_and_file)
			options[role] = role
			continue
		var/left = limit - role_taken["[faction]|[role]"]
		if(left > 0)
			options["[role] — мест: [left]"] = role

	var/choice = tgui_input_list(mind.current, "Кем идёте в бой?", "Mountain Wars", options, timeout = MW_ROLE_PICK_TIME)
	var/role = options[choice]
	// Пока игрок думал, место могли занять — считаем ещё раз, уже по факту.
	if(!role || (role != rank_and_file && role_taken["[faction]|[role]"] >= limit))
		return roundstart_outfit(faction, index)
	role_taken["[faction]|[role]"] += 1
	return roles[role]

/**
 * Ставит бойца во фракцию и роль. Одна дверь для всех входов: старт раунда, поздний
 * заход и админская кнопка.
 *
 * Переназначение считает нормой: боец мог уже воевать за другую сторону или в другой
 * роли. Со старой стороны его выписываем, иначе он останется в её списке членов —
 * а по нему считаются и живые бойцы, и конец раунда.
 */
/datum/game_mode/mountain_wars/proc/assign_player(datum/mind/mind, faction, outfit_type)
	var/datum/team/mountain_wars/team = teams[faction]
	if(!istype(team) || !mind)
		return FALSE
	for(var/other in teams)
		if(other == faction)
			continue
		var/datum/team/mountain_wars/previous = teams[other]
		previous.dismiss_member(mind)
	if(mind.current?.ckey)
		faction_by_ckey[mind.current.ckey] = faction
	if(mind in team.members)
		team.deploy_member(mind, outfit_type)
	else
		team.add_member(mind, TRUE, outfit_type)
	return TRUE

/datum/game_mode/mountain_wars/proc/open_wave()
	if(marine_tickets <= 0)
		return
	wave_open = TRUE
	message_faction(JOB_TITLE_MW_MARINE, span_boldwarning("Волна подкреплений прибыла! Окно высадки открыто на [MW_WAVE_WINDOW / 600] мин. Билетов осталось: [marine_tickets]."))
	addtimer(CALLBACK(src, PROC_REF(close_wave)), MW_WAVE_WINDOW)

/datum/game_mode/mountain_wars/proc/close_wave()
	wave_open = FALSE
	next_wave_time = world.time + MW_WAVE_INTERVAL
	addtimer(CALLBACK(src, PROC_REF(open_wave)), MW_WAVE_INTERVAL)

/// Сообщение всем живым и мёртвым членам фракции.
/datum/game_mode/mountain_wars/proc/message_faction(faction, message)
	for(var/mob/mob as anything in GLOB.player_list)
		if(faction_by_ckey[mob.ckey] == faction)
			to_chat(mob, message)

/// Снять билеты подкреплений. Боец стоит одного, техника — своих, см. vehicles.dm.
/datum/game_mode/mountain_wars/proc/lose_tickets(amount = 1)
	if(marine_tickets <= 0)
		return
	marine_tickets -= amount
	if(marine_tickets <= 0)
		message_faction(JOB_TITLE_MW_MARINE, span_boldwarning("Билеты подкреплений исчерпаны! Подкреплений больше не будет."))
	else if(marine_tickets <= 10)
		message_faction(JOB_TITLE_MW_MARINE, span_boldwarning("Осталось билетов подкреплений: [marine_tickets]!"))

/// Смерть морпеха снимает билет. Зовётся из тим-датума по сигналу смерти.
/datum/game_mode/mountain_wars/proc/on_marine_death()
	lose_tickets(1)

/// Сколько бойцов у фракции сейчас в строю. Мёртвые не в счёт: ждущий волну морпех на
/// поле не стоит, а перекос считается по тем, кто реально воюет.
/datum/game_mode/mountain_wars/proc/faction_strength(faction)
	var/datum/team/mountain_wars/team = teams[faction]
	return istype(team) ? team.alife_members_count() : 0

/// Куда пускают прямо сейчас. Во фракцию, которая уже крупнее соседней, вход закрыт:
/// иначе поздние заходы сливаются в ту сторону, где веселее, и бой кончается.
/// При равенстве открыты обе.
/datum/game_mode/mountain_wars/proc/faction_open(faction)
	var/mine = faction_strength(faction)
	for(var/other in teams)
		if(other == faction)
			continue
		if(mine > faction_strength(other))
			return FALSE
	return TRUE

/datum/game_mode/mountain_wars/late_join(mob/new_player/player)
	var/list/faction_options = list()
	for(var/faction in teams)
		var/datum/team/mountain_wars/team = teams[faction]
		var/label = "[team.name] — бойцов: [faction_strength(faction)]"
		if(faction == JOB_TITLE_MW_MARINE)
			label += ", билетов: [max(marine_tickets, 0)]"
		// Закрытую сторону показываем, а не прячем: игрок должен видеть, что она есть
		// и почему туда нельзя.
		if(!faction_open(faction))
			label += " (закрыто: перевес)"
		faction_options[label] = faction

	var/faction_choice = tgui_input_list(player, "Выберите фракцию", "Mountain Wars", faction_options)
	if(!faction_choice)
		return TRUE
	var/faction = faction_options[faction_choice]

	// Пока игрок выбирал, счёт мог сойтись или разойтись — считаем по факту.
	if(!faction_open(faction))
		to_chat(player, span_warning("В этой фракции сейчас больше бойцов — вход закрыт. Возьмите противоположную сторону или подождите."))
		return TRUE

	if(faction == JOB_TITLE_MW_MARINE)
		if(marine_tickets <= 0)
			to_chat(player, span_boldwarning("Билеты морпехов исчерпаны — подкреплений больше не будет."))
			return TRUE
		if(!wave_open)
			to_chat(player, span_warning("Высадка только волнами. Следующая волна через [max(round((next_wave_time - world.time) / 600), 0)] мин. Нажмите \"Присоединиться\" ещё раз, когда она откроется."))
			return TRUE

	var/list/roles = GLOB.mountain_wars_roles[faction]
	var/role_choice = tgui_input_list(player, "Выберите роль", "Mountain Wars", roles)
	if(!role_choice)
		return TRUE

	if(QDELETED(player) || !player.client)
		return TRUE

	// Выбор роли — ещё одно окно и ещё одна пауза. За неё в бой могли зайти другие.
	if(!faction_open(faction))
		to_chat(player, span_warning("Пока вы выбирали роль, эта фракция ушла в перевес. Попробуйте ещё раз."))
		return TRUE

	SStitle.hide_title_screen_from(player.client)
	assign_player(player.mind, faction, roles[role_choice])
	qdel(player)
	return TRUE

// MARK: Подрыв завода и отход
// Завод — цель всей операции. Пока он цел, морпехам некуда торопиться; как только его
// не стало, сектор обречён, и дальше считаются только минуты до отхода.
//
// Дошли морпехи до бортов или нет, значения не имеет: задачу они выполнили в тот
// момент, когда установка перестала существовать. Отход — это финальная сцена, а не
// ещё одна проверка.

/// Завод взорван. Зовётся самой установкой, см. structures.dm.
/datum/game_mode/mountain_wars/proc/plant_destroyed()
	if(evac_deadline)
		return
	evac_deadline = world.time + MW_EVAC_TIME

	// Сирена всем: текст в чате в бою читают не сразу, а вой слышно мгновенно.
	SEND_SOUND(world, sound('sound/effects/purge_siren.ogg', volume = 70))
	to_chat(world, span_boldwarning("<br>ВНИМАНИЕ. Химический завод в горном секторе уничтожен."))
	to_chat(world, span_boldwarning("Реактор пошёл вразнос, хранилище прекурсоров вскрыто. Сектор непригоден для нахождения и будет накрыт."))
	to_chat(world, span_boldwarning("Всем силам Корпуса — отход к вертолётам. Расчётное время до накрытия: [MW_EVAC_TIME / 600] мин.<br>"))

	// Задача меняется и в титрах: тот, кто прилетит следующим бортом, увидит уже её.
	var/datum/team/mountain_wars/marines = teams[JOB_TITLE_MW_MARINE]
	if(istype(marines))
		marines.briefing_task = "отойти к вертолётам"
	for(var/datum/mind/mate as anything in marines?.members)
		var/mob/living/body = mate.current
		if(QDELETED(body) || body.stat == DEAD)
			continue
		mw_briefing(body, "отойти к вертолётам")

	addtimer(CALLBACK(src, PROC_REF(evac_warning)), MW_EVAC_TIME - MW_EVAC_WARNING)
	addtimer(CALLBACK(src, PROC_REF(evac_over)), MW_EVAC_TIME)

/datum/game_mode/mountain_wars/proc/evac_warning()
	to_chat(world, span_userdanger("До накрытия сектора — [MW_EVAC_WARNING / 600] мин."))

/datum/game_mode/mountain_wars/proc/evac_over()
	// Победа засчитывается за уничтоженный завод, а не за успешный отход. Кто не
	// добежал — просто не вернулся домой, на исход это не влияет.
	declare_victory(JOB_TITLE_MW_MARINE)

/**
 * Объявляет победу фракции: сообщение всему серверу и ролик.
 *
 * Раунд при этом продолжается. Победа здесь — сюжетная точка, а не выключатель:
 * ивент идёт, пока админ не свернёт его сам. Поэтому и объявляем ровно один раз —
 * второй ролик поверх первого никому не нужен.
 */
/datum/game_mode/mountain_wars/proc/declare_victory(faction)
	if(winner)
		return
	winner = faction
	var/datum/team/mountain_wars/team = teams[faction]
	to_chat(world, span_userdanger("<br>Бой за горный сектор окончен. Победа фракции «[team?.name || faction]».<br>"))
	play_cinematic(faction == JOB_TITLE_MW_MARINE ? /datum/cinematic/mw_victory/marine : /datum/cinematic/mw_victory/insurgent, world)

// Ролик здесь не играем: он уже отработал в момент победы, а сюда мы попадаем позже и
// по другому поводу — когда раунд сворачивает админ.
/datum/game_mode/mountain_wars/declare_completion()
	return ..()

// Победа раунд не заканчивает — см. declare_victory. Проверку держим здесь только
// потому, что тикер и так зовёт check_finished каждый тик: свой цикл ради этого заводить
// незачем. Возвращаем то же, что и родитель, то есть в норме «нет».
/datum/game_mode/mountain_wars/check_finished()
	if(!winner && marine_tickets <= 0)
		var/datum/team/marines = teams[JOB_TITLE_MW_MARINE]
		// Билеты вышли, живых морпехов нет — сектор остался за повстанцами.
		if(!marines.alife_members_count())
			declare_victory(JOB_TITLE_MW_INSURGENT)
	return ..()

#undef RESPAWN_MW_DELAY
#undef MW_MARINE_TICKETS
#undef MW_WAVE_INTERVAL
#undef MW_WAVE_WINDOW
#undef MW_SQUAD_SIZE
#undef MW_SQUAD_SPECIALISTS
#undef MW_ROLE_PICK_TIME
#undef MW_EVAC_TIME
#undef MW_EVAC_WARNING
