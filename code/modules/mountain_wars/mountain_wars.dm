// Mountain Wars: ивентовый режим "Морпехи против Повстанцев".
// Вся логика ивента живёт в этом модуле. Обычный раунд не затрагивается:
// карта admin_only, режим с нулевой вероятностью, роли скрыты из префов.

/datum/map/mountain_wars
	name = "Mountain Wars"
	map_path = "_maps/map_files/mountain_wars/prot2.dmm"
	// Два уровня в одном файле, снизу вверх: туннели повстанцев и над ними сектор.
	// Порядок задан картой, менять его тут нельзя — traits[i] прикладывается к z=i.
	// ZTRAIT_UP/DOWN нужны лазам-колодцам (/obj/structure/ladder/mw_shaft): без них
	// GET_TURF_BELOW() возвращает null и связка молча не происходит. Открытого
	// пространства на карте нет, так что падений эти трейты не добавляют.
	traits = list(
		list(MAIN_STATION, STATION_LEVEL = "Туннели", STATION_CONTACT, REACHABLE, ZTRAIT_UP, ZTRAIT_BASETURF = /turf/simulated/mineral),
		list(STATION_LEVEL = "Сектор", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/floor/plating/asteroid),
	)
	// База и воздушный коридор лежат своими файлами: класть их четвёртым и пятым
	// ярусом в общий .dmm незачем, редактору с таким файлом плохо.
	//
	// Базовый турф у обоих — космос. Уровень всегда во всю карту, 255x255, а база
	// занимает угол; заливать полсотни тысяч пустых клеток симулируемым полом значит
	// заставить атмос впустую гонять по ним воздух. Что нарисовано — то и работает,
	// остальное ничего не стоит.
	//
	// ZTRAIT_UP/DOWN им не даём: лазать между базой, воздухом и сектором не нужно, а
	// лишняя вертикальная связка тянет за собой обсчёт соседнего яруса.
	extra_levels = list(
		"_maps/map_files/mountain_wars/marine base.dmm" = list(
			"name" = "База",
			"traits" = list(STATION_LEVEL = "База", STATION_CONTACT, REACHABLE, ZTRAIT_BASETURF = /turf/space),
		),
		// Пустыню рисует лента на экране игрока, звёздная подложка тут только мешала
		// бы — отсюда ZTRAIT_NOPARALLAX.
		"_maps/map_files/mountain_wars/sky.dmm" = list(
			"name" = "Воздушный коридор",
			"traits" = list(STATION_LEVEL = "Воздушный коридор", STATION_CONTACT, REACHABLE, ZTRAIT_NOPARALLAX = TRUE, ZTRAIT_BASETURF = /turf/space),
		),
	)
	// Случайные космические руины ивенту не нужны, а оперативка на 4 ГБ считанная. Но
	// поставить сюда ноль нельзя: проверка в SSmapping идёт на истинность, а ноль в DM
	// ложен, и карта всё равно получит штатные 4-8 уровней. Чинить проверку значит
	// разом включить давно лежащий мёртвым ноль у карты Нова и молча забрать у неё
	// руины — цена не по этому ПР. Пока платим лишними уровнями, режим админский и
	// запускается редко.
	space_ruins_levels = null

	station_name = "Горный сектор"
	english_station_name = "Mountain Sector"
	station_short = "Сектор"
	dock_name = "АКН Трурль"
	company_name = "\"Нанотрейзен\""
	company_short = "НТ"
	starsys_name = "Эпсилон Лукуста"
	admin_only = TRUE
	planetary = TRUE
	linkage = SELFLOOPING
	forced_mode = /datum/game_mode/mountain_wars
	disables = DISABLE_ALL

// Базовые точки спавна фракций — лендмарки с карты. Используются, только если
// у фракции не развёрнуто ни одной живой FOB-рации.
GLOBAL_LIST_INIT(mountain_wars_spawns, list(
	JOB_TITLE_MW_MARINE = list(),
	JOB_TITLE_MW_INSURGENT = list()
))

// Развёрнутые FOB-рации. Пока хоть одна цела — фракция спавнится на них.
GLOBAL_LIST_INIT(mountain_wars_fobs, list(
	JOB_TITLE_MW_MARINE = list(),
	JOB_TITLE_MW_INSURGENT = list()
))

// Роли фракции: отображаемое имя -> тип аутфита.
GLOBAL_LIST_INIT(mountain_wars_roles, list(
	JOB_TITLE_MW_MARINE = list(
		"Командир отряда" = /datum/outfit/job/mountain_wars/marine/leader,
		"Медик" = /datum/outfit/job/mountain_wars/marine/medic,
		"Инженер" = /datum/outfit/job/mountain_wars/marine/engineer,
		"Пулемётчик" = /datum/outfit/job/mountain_wars/marine/mg,
		"Пехотинец" = /datum/outfit/job/mountain_wars/marine,
	),
	JOB_TITLE_MW_INSURGENT = list(
		"Полевой командир" = /datum/outfit/job/mountain_wars/insurgent/leader,
		"Санитар" = /datum/outfit/job/mountain_wars/insurgent/medic,
		"Подрывник" = /datum/outfit/job/mountain_wars/insurgent/engineer,
		"Стрелок" = /datum/outfit/job/mountain_wars/insurgent/marksman,
		"Боевик" = /datum/outfit/job/mountain_wars/insurgent,
	)
))

/// За кого играет моб. Пусто — режим не тот или игрок вне фракций.
/proc/mountain_wars_faction(mob/who)
	var/datum/game_mode/mountain_wars/mode = SSticker.mode
	if(!istype(mode) || !who)
		return null
	return mode.faction_by_ckey[who.ckey]

/// Точка спавна фракции: FOB-рация в приоритете, иначе базовый лендмарк.
/proc/mountain_wars_spawnpoint(faction)
	var/list/fobs = GLOB.mountain_wars_fobs[faction]
	if(LAZYLEN(fobs))
		return pick(fobs)
	var/list/spawns = GLOB.mountain_wars_spawns[faction]
	if(LAZYLEN(spawns))
		return pick(spawns)
	// ponytail: fallback в центр карты, пока на карте нет ни лендмарков, ни раций.
	// Именно второй z: MAIN_STATION — это имя первого уровня, а там туннели.
	// Загрузчик именует остальные как MAIN_STATION + "([i])", см. SSmapping.
	return locate(round(world.maxx / 2), round(world.maxy / 2), level_name_to_num("[MAIN_STATION](2)"))

/obj/effect/landmark/spawner/mw_marine
	name = "mw_marine"
	icon_state = "BLUE"

/obj/effect/landmark/spawner/mw_marine/Initialize(mapload)
	spawner_list = GLOB.mountain_wars_spawns[JOB_TITLE_MW_MARINE]
	// Кнопка "Наблюдать" в лобби ставит госта на /obj/effect/landmark/observer_start —
	// new_player.dm ищет его через locate() по всему миру. На карте такого лендмарка нет,
	// и гост уезжал в nullspace: loc = null, вокруг чернота, а client/Move на пустом loc
	// выходит первой же проверкой, поэтому и шагу не сделать.
	//
	// Ставим лендмарк отсюда, а не на карту руками: точка высадки морпехов на базе одна,
	// место открытое и освещённое. Куда лететь дальше, гост решает сам.
	new /obj/effect/landmark/observer_start(loc)
	return ..()

/obj/effect/landmark/spawner/mw_insurgent
	name = "mw_insurgent"
	icon_state = "RED"

/obj/effect/landmark/spawner/mw_insurgent/Initialize(mapload)
	spawner_list = GLOB.mountain_wars_spawns[JOB_TITLE_MW_INSURGENT]
	return ..()
