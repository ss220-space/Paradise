/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME (you can make as many subdivisions as you want)
	name = "NICE NAME" (not required but makes things really nice)
	icon = "ICON FILENAME" (defaults to areas.dmi)
	icon_state = "NAME OF ICON" (defaults to "unknown" (blank))
	requires_power = FALSE (defaults to TRUE)
	music = "music/music.ogg" (defaults to "music/music.ogg")
	sound_environment = SOUND_ENVIRONMENT_NONE (defaults to SOUND_AREA_STANDARD_STATION. Look _DEFINES/sound.dm)

NOTE: there are two lists of areas in the end of this file: centcom and station itself. Please maintain these lists valid. --rastaf0

Numbers in the order will be used to indicate the direction of the sector
This applies to all STANDARD station areas
1 West-North	2 North		3 East-North
4 West			5 Central	6 East
7 West-South	9 South		10 East-South
*/

/*-----------------------------------------------------------------------------*/


/area/admin
	name = "Админ-комната"
	icon_state = "start"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255
	hide_attacklogs = TRUE
	has_gravity = STANDARD_GRAVITY
	area_flags = NONE


/area/adminconstruction
	name = "Тестовая зона администрации"
	icon_state = "start"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255
	hide_attacklogs = TRUE
	has_gravity = STANDARD_GRAVITY
	area_flags = NONE

/area/space
	icon_state = "space"
	always_unpowered = TRUE
	static_lighting = FALSE
	base_lighting_alpha = 255
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE
	valid_territory = FALSE
	outdoors = TRUE
	ambientsounds = SPACE_SOUNDS
	sound_environment = SOUND_AREA_SPACE
	area_flags = UNIQUE_AREA

/area/space/nearstation
	icon_state = "space_near"
	use_starlight = TRUE

/area/space/planetary
	icon_state = "space_planet"
	static_lighting = TRUE
	ambientsounds = list('sound/ambience/ambimine.ogg')
	sound_environment = SOUND_AREA_ASTEROID

/area/space/atmosalert()
	return

/area/space/firealert(obj/source)
	return

/area/space/firereset(obj/source)
	return

/area/game_test
	name = "Game Test Area"
	icon_state = "test_room"
	requires_power = FALSE

//These are shuttle areas, they must contain two areas in a subgroup if you want to move a shuttle from one
//place to another. Look at escape shuttle for example.
//All shuttles show now be under shuttle since we have smooth-wall code.

/area/shuttle
	no_teleportlocs = TRUE
	requires_power = FALSE
	valid_territory = FALSE
	has_gravity = STANDARD_GRAVITY
	sound_environment = SOUND_ENVIRONMENT_ROOM
	holomap_should_draw = FALSE

/area/shuttle/arrival
	name = "Шаттл прибытия"
	holomap_should_draw = TRUE
	holomap_color = HOLOMAP_AREACOLOR_ARRIVALS

/area/shuttle/arrival/station
	icon_state = "shuttle"

/area/shuttle/auxillary_base
	icon_state = "shuttle"
	area_flags = NONE

/area/shuttle/escape
	name = "Эвакуационный шаттл"
	icon_state = "shuttle2"
	nad_allowed = TRUE

/area/shuttle/pod_1
	name = "Эвакуационная капсула 1"
	icon_state = "shuttle"
	nad_allowed = TRUE

/area/shuttle/pod_2
	name = "Эвакуационная капсула 2"
	icon_state = "shuttle"
	nad_allowed = TRUE

/area/shuttle/pod_3
	name = "Эвакуационная капсула 3"
	icon_state = "shuttle"
	nad_allowed = TRUE

/area/shuttle/pod_4
	name = "Эвакуационная капсула 4"
	icon_state = "shuttle"
	nad_allowed = TRUE

/area/shuttle/escape_pod1
	name = "Эвакуационная капсула 1"
	nad_allowed = TRUE

/area/shuttle/escape_pod1/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod1/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod1/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod2
	name = "Эвакуационная капсула 2"
	nad_allowed = TRUE

/area/shuttle/escape_pod2/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod2/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod2/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod3
	name = "Эвакуационная капсула 3"
	nad_allowed = TRUE

/area/shuttle/escape_pod3/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod3/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod3/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod5 //Pod 4 was lost to meteors
	name = "Escape Pod Five"
	nad_allowed = TRUE

/area/shuttle/escape_pod5/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod5/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod5/transit
	icon_state = "shuttle"

/area/shuttle/mining
	name = "Шахтёрский шаттл"
	icon_state = "shuttle"

/area/shuttle/transport
	icon_state = "shuttle"

/area/shuttle/transport1
	name = "Транспортный шаттл"
	icon_state = "shuttle"

/area/shuttle/alien/base
	name = "Инопланетный шаттл-база"
	icon_state = "shuttle"
	requires_power = 1
	area_flags = NONE

/area/shuttle/alien/mine
	name = "Инопланетный шахтёрский шаттл"
	icon_state = "shuttle"
	requires_power = 1
	area_flags = NONE

/area/shuttle/gamma
	name = "Гамма-арсенал"
	icon_state = "shuttle"

/area/shuttle/prison/
	name = "Тюремный шаттл"

/area/shuttle/prison/station
	icon_state = "shuttle"

/area/shuttle/prison/prison
	icon_state = "shuttle2"

/area/shuttle/siberia
	name = "Шаттл трудового лагеря"
	icon_state = "shuttle"

/area/shuttle/specops
	name = "Шаттл спецсил"
	icon_state = "shuttlered"
	parallax_movedir = EAST
	area_flags = NONE

/area/shuttle/specops/centcom

/area/shuttle/specops/station
	icon_state = "shuttlered2"

/area/shuttle/syndicate_elite
	name = "Элитный шаттл \"Синдиката\""
	icon_state = "shuttlered"
	nad_allowed = TRUE
	parallax_movedir = SOUTH
	area_flags = NONE

/area/shuttle/syndicate_elite/mothership

/area/shuttle/syndicate_elite/station
	icon_state = "shuttlered2"

/area/shuttle/syndicate_sit
	name = "Шаттл Диверсионного отряда \"Синдиката\""
	icon_state = "shuttlered"
	nad_allowed = TRUE
	parallax_movedir = SOUTH
	area_flags = NONE

/area/shuttle/assault_pod
	name = "Штурмовой под \"Стальной дождь\""
	icon_state = "shuttle"

/area/shuttle/nt_droppod
	name = "Штурмовой под \"Говнодождь\""
	icon_state = "shuttle"

/area/shuttle/administration
	name = "Судно \"Нанотрейзен\""
	icon_state = "shuttlered"
	parallax_movedir = WEST
	area_flags = NONE

/area/shuttle/administration/centcom
	name = "Судно \"Нанотрейзен\" (Центком)"

/area/shuttle/administration/station
	icon_state = "shuttlered2"

/area/shuttle/thunderdome
	name = "хонк"
	area_flags = NONE

/area/shuttle/thunderdome/grnshuttle
	name = "Тандердом — ЗЛН шаттл"
	icon_state = "green"

/area/shuttle/thunderdome/grnshuttle/dome
	name = "ЗЛН шаттл"
	icon_state = "shuttlegrn"

/area/shuttle/thunderdome/grnshuttle/station
	name = "ЗЛН станция"
	icon_state = "shuttlegrn2"

/area/shuttle/thunderdome/redshuttle
	name = "Тандердом — КРС шаттл"
	icon_state = "red"

/area/shuttle/thunderdome/redshuttle/dome
	name = "КРС шаттл"
	icon_state = "shuttlered"

/area/shuttle/thunderdome/redshuttle/station
	name = "КРС станция"
	icon_state = "shuttlered2"

/area/shuttle/research
	name = "Исследовательский шаттл"
	icon_state = "shuttle"

/area/shuttle/research/station
	icon_state = "shuttle2"

/area/shuttle/research/outpost

/area/shuttle/vox
	name = "Скипджек воксов"
	icon_state = "shuttle"
	area_flags = NONE

/area/shuttle/vox/station
	icon_state = "yellow"

/area/shuttle/salvage
	name = "Судно спасателей"
	icon_state = "yellow"
	area_flags = NONE

/area/shuttle/salvage/start
	name = "Посреди Ничего"

/area/shuttle/salvage/arrivals
	name = "Дополнительный док Космической Станции"

/area/shuttle/salvage/derelict
	name = "Заброшенная станция"

/area/shuttle/salvage/djstation
	name = "Русская диджей-станция"

/area/shuttle/salvage/north
	name = "Север станции"

/area/shuttle/salvage/east
	name = "Восток станции"

/area/shuttle/salvage/south
	name = "Юг станции"

/area/shuttle/salvage/commssat
	name = "Коммуникационный спутник"

/area/shuttle/salvage/mining
	name = "Юго-запад шахтёрского астероида"

/area/shuttle/salvage/abandoned_ship
	name = "Заброшенное судно"

/area/shuttle/salvage/clown_asteroid
	name = "Клоунский астероид"

/area/shuttle/salvage/trading_post
	name = "Торговый пункт"

/area/shuttle/salvage/transit
	name = "гиперпространство"
	icon_state = "shuttle"

/area/shuttle/supply
	name = "Шаттл снабжения"
	icon_state = "shuttle3"
	area_flags = NONE

/area/shuttle/ussp
	name = "Шаттл СССП"
	icon_state = "shuttle3"
	area_flags = NONE

/area/shuttle/spacebar
	name = "Шаттл космического бара"
	icon_state = "shuttle3"
	area_flags = NONE

/area/shuttle/abandoned
	name = "Заброшенное судно"
	icon_state = "shuttle"
	area_flags = NONE

/area/shuttle/syndicate
	name = "Шаттл отряда \"Атом\" \"Синдиката\""
	icon_state = "shuttle"
	nad_allowed = TRUE
	area_flags = NONE

/area/shuttle/trade
	name = "Торговый шаттл"
	icon_state = "shuttle"
	area_flags = NONE

/area/shuttle/trade/sol
	name = "Торговый шаттл ТСФ"

/area/shuttle/freegolem
	name = "Судно свободных големов"
	icon_state = "purple"
	xenobiology_compatible = TRUE

/area/shuttle/pirate_corvette
	name = "Пиратский корвет"
	requires_power = TRUE
	icon_state = "shuttle"
	area_flags = NONE

/area/shuttle/transit
	name = "Гиперпространство"
	static_lighting = FALSE
	base_lighting_alpha = 255


/area/airtunnel1/ // referenced in airtunnel.dm:759

/area/dummy/ // Referenced in engine.dm:261

/area/start // will be unused once kurper gets his login interface patch done
	name = "start area"
	icon_state = "start"
	requires_power = FALSE
	static_lighting = FALSE
	has_gravity = STANDARD_GRAVITY
	ambientsounds = null

// === end remove

/**
 * MARK: CENTCOM
 */

/area/centcom
	name = "Центральное командование"
	icon_state = "centcom"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255
	nad_allowed = TRUE
	has_gravity = STANDARD_GRAVITY
	area_flags = NONE

// New CC
/area/centcom/bridge
	name = "Центком — мостик"
	icon_state = "centcom_bridge"

/area/centcom/court
	name = "Центком — зал суда"
	icon_state = "centcom_court"

/area/centcom/ferry
	name = "Центком — Ferry Shuttle"
	icon_state = "centcom_ferry"

/area/centcom/gamma
	name = "Центком — арсенал \"Гамма\""
	icon_state = "centcom_gamma"

/area/centcom/supply
	name = "Центком — шаттл снабжения"
	icon_state = "centcom_supply"

/area/centcom/jail
	name = "Центком — тюрьма"
	icon_state = "centcom_jail"

/area/centcom/zone3
	name = "Центком — зона 3"
	icon_state = "centcom_zone3"

/area/centcom/zone2
	name = "Центком — зона 2"
	icon_state = "centcom_zone2"

/area/centcom/zone1
	name = "Центком — зона 1"
	icon_state = "centcom_zone1"

/area/centcom/evac
	name = "Центком — эвакуационный шаттл"
	icon_state = "centcom_evac"

/area/centcom/specops
	name = "Центком — крыло Сил специального назначения"
	icon_state = "centcom_specops"

/area/centcom/srtops
	name = "Центком — крыло Отряда специального реагирования"
	icon_state = "centcom_srtops"

/area/centcom/blops
	name = "Центком — крыло Отряда теневых операций"
	icon_state = "centcom_blops"

/area/centcom/shuttle
	name = "Центком — шаттл администрации"

/area/centcom/supplypod/supplypod_temp_holding
	name = "Пункт отправки капсул снабжения"
	icon_state = "supplypod_flight"
	area_flags = UNIQUE_AREA

/area/centcom/supplypod
	name = "Отсек капсул снабжения"
	icon_state = "supplypod"

/area/centcom/supplypod/pod_storage
	name = "Хранилище капсул снабжения"
	icon_state = "supplypod_holding"

/area/centcom/supplypod/loading
	name = "Отсек загрузки капсул снабжения"
	icon_state = "supplypod_loading"
	var/loading_id = ""

/area/centcom/supplypod/loading/Initialize(mapload)
	. = ..()
	if(!loading_id)
		CRASH("[type] created without a loading_id")
	if(GLOB.supplypod_loading_bays[loading_id])
		CRASH("Duplicate loading bay area: [type] ([loading_id])")
	GLOB.supplypod_loading_bays[loading_id] = src

/area/centcom/supplypod/loading/one
	name = "Центком — ангар №1"
	loading_id = "1"

/area/centcom/supplypod/loading/two
	name = "Центком — ангар №2"
	loading_id = "2"

/area/centcom/supplypod/loading/three
	name = "Центком — ангар №3"
	loading_id = "3"

/area/centcom/supplypod/loading/four
	name = "Центком — ангар №4"
	loading_id = "4"

/area/centcom/supplypod/loading/ert
	name = "Центком — ангар ОБР"
	loading_id = "5"

/**
 * MARK: SYNDICATES
 */

/area/syndicate_mothership
	name = "ПБ \"Синдиката\""
	icon_state = "syndie-ship"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_alpha = 255
	nad_allowed = TRUE
	ambientsounds = HIGHSEC_SOUNDS
	area_flags = NONE

/area/syndicate_mothership/outside
	name = "ПБ \"Синдиката\" — внешняя территория"
	icon_state = "syndie-outside"

/area/syndicate_mothership/control
	name = "ПБ \"Синдиката\" — комната управления"
	icon_state = "syndie-control"

/area/syndicate_mothership/elite_squad
	name = "ПБ \"Синдиката\" — крыло Элитного отряда"
	icon_state = "syndie-elite"

/area/syndicate_mothership/infteam
	name = "ПБ \"Синдиката\" — крыло Лазутчиков"
	icon_state = "syndie-infiltrator"

/area/syndicate_mothership/jail
	name = "ПБ \"Синдиката\" — тюрьма"
	icon_state = "syndie-jail"

/area/syndicate_mothership/cargo
	name = "ПБ \"Синдиката\" — отдел снабжения"
	icon_state = "syndie-cargo"

/**
 * MARK: USSP
 */

/area/ussp_ship
	name = "Судно СССП \"Проект 28У\""
	icon_state = "ussp_ship"
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_alpha = 255
	ambientsounds = HIGHSEC_SOUNDS
	area_flags = NONE

/**
 * MARK: Chrono
 */

/area/chrono_ship
	name = "Судно Хронолегиона"
	icon_state = "chrono_ship"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_alpha = 255
	nad_allowed = TRUE
	area_flags = NONE

/**
 * MARK: EXTRA
 */

/area/event_zone
	name = "Ивент-зона"
	icon_state = "event_zone"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_alpha = 255
	nad_allowed = TRUE
	area_flags = NONE

/area/asteroid
	name = "Asteroid"
	icon_state = "asteroid"
	requires_power = FALSE
	valid_territory = FALSE
	ambientsounds = MINING_SOUNDS

/area/asteroid/cave
	name = "Астероид — подземелье"
	icon_state = "cave"
	outdoors = TRUE
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/area/asteroid/artifactroom
	name = "Астероид — артефакт"
	icon_state = "cave"

/**
 * MARK: THUNDERDOME
 */

/area/tdome
	name = "Тандердом"
	icon_state = "thunder"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_alpha = 255
	hide_attacklogs = TRUE
	area_flags = NONE


/area/tdome/arena_source
	name = "Тандедом — шаблон арены"

/area/tdome/arena
	name = "Тандедом — арена"

/area/tdome/tdome1
	name = "Тандедом — команда 1"
	icon_state = "green"

/area/tdome/tdome2
	name = "Тандедом — команда 2"
	icon_state = "yellow"

/area/tdome/tdomeadmin
	name = "Тандедом — администрация"
	icon_state = "purple"

/area/tdome/tdomeobserve
	name = "Тандедом — зрители"
	icon_state = "purple"

/area/tdome/newtdome
	name = "Тандедом — новая арена"

/area/tdome/newtdome/CQC
	name = "Тандедом — новая арена (ближний бой)"
	icon_state = "thunderCQC"

/area/exploration/methlab
	name = "Заброшенная нарколаборатория"
	icon_state = "green"
	area_flags = UNIQUE_AREA
	has_gravity = STANDARD_GRAVITY
	area_flags = NONE

/**
 * MARK: Abductors
 */

/area/abductor_ship
	name = "Судно абдукторов"
	icon_state = "yellow"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	area_flags = NONE

/area/wizard_station
	name = "Логова мага"
	icon_state = "yellow"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/ninja
	name = "Клан Паука — родитель для зон"
	icon_state = "ninjabase"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	no_teleportlocs = TRUE
	static_lighting = FALSE
	base_lighting_alpha = 255
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR
	nad_allowed = TRUE
	area_flags = NONE

/area/ninja/outpost
	name = "Клан Паука — додзё"
	icon_state = "ninja_dojo"

/area/ninja/holding
	name = "Клан Паука — пункт содержания"
	icon_state = "ninja_holding"
	ambientsounds = list('sound/ambience/ambifailure.ogg', 'sound/ambience/ambigen4.ogg', 'sound/ambience/ambimaint2.ogg', 'sound/ambience/ambimystery.ogg', 'sound/ambience/ambitech2.ogg')

/area/ninja/outside
	name = "Клан Паука — внешняя территория"
	icon_state = "ninja_outside"
	sound_environment = SOUND_AREA_ASTEROID

/area/vox_station
	name = "База воксов"
	icon_state = "yellow"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_alpha = 255
	no_teleportlocs = TRUE
	area_flags = NONE

/area/trader_station
	name = "База торговцев"
	icon_state = "yellow"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_alpha = 255
	area_flags = NONE

/area/trader_station/sol
	name = "Станция \"Юпитер 6\""

/area/ussp_centcom
	name = "Центральный комитет СССП"
	icon_state = "red"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_alpha = 255
	area_flags = NONE

/area/ussp_centcom/secretariat
	name = "Секретариат СССП"

/**
 * MARK: Labor camp
 */

/area/mine/laborcamp
	name = "Трудовой лагерь"
	icon_state = "brig"

/**
 * MARK: STATION13
 */

/area/atmos
	name = "Атмосферный отсек"
	icon_state = "atmos"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/atmos/control
	name = "Атмосферный отсек — комната управления"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/atmos/distribution
	name = "Атмосферный отсек — распределительный контур"

/area/atmos/break_room
	name = "Атмосферный отсек — фойе"

/**
 * MARK: MAINTENANCE
 */

/area/maintenance
	ambientsounds = MAINTENANCE_SOUNDS
	valid_territory = FALSE
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/maintenance/ai
	name = "Технические тоннели — спутник ИИ"
	icon_state = "green"

/area/maintenance/fore //should be refactored
	name = "Технические тоннели — северные"
	icon_state = "fmaint"

/area/maintenance/fore2
	name = "Технические тоннели — северные вторичные"
	icon_state = "fmaint"

/area/maintenance/aft
	name = "Технические тоннели — западные"
	icon_state = "amaint"

/area/maintenance/aft2
	name = "Технические тоннели — западные вторичные"
	icon_state = "amaint"

/area/maintenance/fpmaint
	name = "Технические тоннели — северо-западные"
	icon_state = "fpmaint"

/area/maintenance/fsmaint
	name = "Технические тоннели — дормитории"
	icon_state = "fsmaint"

/area/maintenance/fsmaint2
	name = "Технические тоннели — бар"
	icon_state = "fsmaint"

/area/maintenance/fsmaint3
	name = "Технические тоннели — восток Отдела снабжения"
	icon_state = "fsmaint"

/area/maintenance/fsmaint4
	name = "Технические тоннели — север Отдела снабжения"
	icon_state = "fsmaint"

/area/maintenance/tourist
	name = "Технические тоннели — туристическая зона"
	icon_state = "fsmaint"

/area/maintenance/asmaint
	name = "Технические тоннели — Медицинский отдел"
	icon_state = "asmaint"

/area/maintenance/asmaint2
	name = "Технические тоннели — НИО"
	icon_state = "asmaint"

/area/maintenance/asmaint3
	name = "Технические тоннели — НИО вторичные"
	icon_state = "asmaint"

/area/maintenance/asmaint4
	name = "Технические тоннели — вирусология"
	icon_state = "asmaint"

/area/maintenance/asmaint5
	name = "Технические тоннели — пункт прибытия"
	icon_state = "asmaint"

/area/maintenance/asmaint6
	name = "Технические тоннели — комната отдыха НИО"
	icon_state = "asmaint"

/area/maintenance/apmaint
	name = "Технические тоннели — Отдел снабжения"
	icon_state = "apmaint"

/area/maintenance/apmaint2
	name = "Технические тоннели — юго-западные"
	icon_state = "apmaint"

/area/maintenance/maintcentral
	name = "Технические тоннели — мостик"
	icon_state = "central"

/area/maintenance/maintcentral2
	name = "Технические тоннели — центральные вторичные"
	icon_state = "maintcentral"

/area/maintenance/starboard
	name = "Технические тоннели — восточные"
	icon_state = "smaint"

/area/maintenance/starboard2
	name = "Технические тоннели — восточные вторичные"
	icon_state = "smaint"

/area/maintenance/port
	name = "Технические тоннели — западные"
	icon_state = "pmaint"

/area/maintenance/port2
	name = "Технические тоннели — западные вторичные"
	icon_state = "pmaint"

/area/maintenance/brig
	name = "Технические тоннели — бриг"
	icon_state = "pmaint"

/area/maintenance/perma
	name = "Технические тоннели — пермабриг"
	icon_state = "green"

/area/maintenance/atmospherics
	name = "Технические тоннели — атмосферный отсек"
	icon_state = "green"

/area/maintenance/incinerator
	name = "Мусоросжигатель"
	icon_state = "disposal"

/area/maintenance/turbine
	name = "Газовая турбина"
	icon_state = "disposal"

/area/maintenance/disposal
	name = "Отсек утилизации отходов"
	icon_state = "disposal"

/area/maintenance/disposal/southwest
	name = "Опечатанная комната — юго-западная"

/area/maintenance/disposal/south
	name = "Опечатанная комната — южная"

/area/maintenance/disposal/east
	name = "Опечатанная комната — восточная"

/area/maintenance/disposal/northeast
	name = "Опечатанная комната — северо-восточная"

/area/maintenance/disposal/north
	name = "Опечатанная комната — северная"

/area/maintenance/disposal/northwest
	name = "Опечатанная комната — северо-западная"

/area/maintenance/disposal/west
	name = "Опечатанная комната — западная"

/area/maintenance/disposal/westalt
	name = "Опечатанная комната — западная вторичная"

/area/maintenance/disposal/external/southwest
	name = "Внешний мусоропровод — юго-запад"

/area/maintenance/disposal/external/southeast
	name = "Внешний мусоропровод — юго-восток"

/area/maintenance/disposal/external/east
	name = "Внешний мусоропровод — восток"

/area/maintenance/disposal/external/north
	name = "Внешний мусоропровод — север"

/area/maintenance/genetics
	name = "Технические тоннели — генетика"
	icon_state = "asmaint"

/area/maintenance/electrical
	name = "Технические тоннели — отсек электрики"
	icon_state = "elec"

/area/maintenance/engineering
	name = "Технические тоннели — инженерия"
	icon_state = "green"

/area/maintenance/bar
	name = "Технические тоннели — заброшенный бар"
	icon_state = "oldbar"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/area/maintenance/electrical_shop
	name = "Логово электрика"
	icon_state = "elec"

/area/maintenance/gambling_den
	name = "Заброшенный бойцовский клуб"
	icon_state = "yellow"

/area/maintenance/gambling_den2
	name = "Игорный дом"
	icon_state = "yellow"

/area/maintenance/casino
	name = "Заброшенное казино"
	icon_state = "yellow"

/area/maintenance/consarea
	name = "Строительная зона — альтернативная"
	icon_state = "construction"

/area/maintenance/consarea_virology
	name = "Строительная зона — тех. тонелли вирусологии"
	icon_state = "yellow"

/area/maintenance/detectives_office
	name = "Заброшенный офис детектива"
	icon_state = "detective"
	ambientsounds = list('sound/ambience/ambidet1.ogg', 'sound/ambience/ambidet2.ogg')

/area/maintenance/engrooms
	name = "Заброшенная инженерная"
	icon_state = "yellow"

/area/maintenance/library
	name = "Заброшенная библиотека"
	icon_state = "library"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/maintenance/quarters
	name = "Заброшенные дормитории"
	icon_state = "Sleep"

/area/maintenance/secpost
	name = "Заброшенный пост охраны"
	icon_state = "security"

/area/maintenance/banya
	name = "Заброшенная баня"
	icon_state = "yellow"

/area/maintenance/medroom
	name = "Заброшенное крыло неотложной медпомощи"
	icon_state = "medbay3"

/area/maintenance/chapel
	name = "Заброшенная церковь"
	icon_state = "chapel"
	ambientsounds = list('sound/ambience/ambimo2.ogg', 'sound/ambience/spooky/moan1.ogg', 'sound/ambience/spooky/muffled_cry1.ogg', 'sound/ambience/spooky/scared_breathing1.ogg', 'sound/ambience/spooky/scared_breathing2.ogg', 'sound/ambience/spooky/scared_sob1.ogg', 'sound/ambience/spooky/scared_sob2.ogg')
	is_haunted = TRUE

/area/maintenance/livingcomplex
	name = "Вестибюль заброшенного жилого комплекса"
	icon_state = "quart"

/area/maintenance/livingcomplex/hall
	name = "Зал заброшенного жилого комплекса"

/area/maintenance/cafeteria
	name = "Заброшенный кафетерий"
	icon_state = "cafeteria"

/area/maintenance/xenozoo
	name = "Заброшенный ксено-зоопарк"
	icon_state = "yellow"

/area/maintenance/club
	name = "Заброшенный покерный клуб"
	icon_state = "yellow"

/area/maintenance/backstage
	name = "Технические тоннели — Закулисье"
	icon_state = "yellow"

/area/maintenance/trading
	name = "Заброшенная торговая зона"
	icon_state = "yellow"

/area/maintenance/server
	name = "Заброшенная серверная"
	icon_state = "yellow"

/area/maintenance/abandonedwarehouse
	name = "Заброшенный склад"
	icon_state = "yellow"

/area/maintenance/abandonedoffices
	name = "Заброшенный офис"
	icon_state = "yellow"

/area/maintenance/abandonedclub
	name = "Заброшенный клуб"
	icon_state = "yellow"

/area/maintenance/abandonedhangar
	name = "Заброшенный ангар"
	icon_state = "yellow"

/area/maintenance/cele //for SDMM group of zones
	icon_state = "green"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/maintenance/cele/command
	name = "Технические тоннели (цокольный этаж) — Командование"

/area/maintenance/cele/cargo
	name = "Технические тоннели (цокольный этаж) — Отдел снабжения"

/area/maintenance/cele/medbay
	name = "Технические тоннели (цокольный этаж) — Медицинский отдел"

/area/maintenance/cele/servise
	name = "Технические тоннели (цокольный этаж) — Отдел обслуживания"

/area/maintenance/cele/engineering
	name = "Технические тоннели (цокольный этаж) — Инженерный отдел"

/area/maintenance/cele/arrival
	name = "Технические тоннели (цокольный этаж) — пункт прибытия"

/**
 * MARK: HALLWAY
 */


/area/hallway
	valid_territory = FALSE //too many areas with similar/same names, also not very interesting summon spots
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/area/hallway/primary/fore
	name = "Основной северный проход"
	icon_state = "hallF"

/area/hallway/primary/fore/west
	name = "Северо-западный проход"

/area/hallway/primary/fore/east
	name = "Северо-восточный проход"

/area/hallway/primary/fore/north
	name = "Дальний северный проход"

/area/hallway/primary/fore/south
	name = "Север-юг проход"

/area/hallway/primary/starboard
	name = "Восточнй основной проход"
	icon_state = "hallS"

/area/hallway/primary/starboard/west
	name = "Восток-запад проход"

/area/hallway/primary/starboard/east
	name = "Дальний восточный проход"

/area/hallway/primary/starboard/north
	name = "Северо-восточный проход"

/area/hallway/primary/starboard/south
	name = "Юго-восточный проход"

/area/hallway/primary/aft
	name = "Основной южный проход"
	icon_state = "hallA"

/area/hallway/primary/aft/west
	name = "Юго-западный проход"

/area/hallway/primary/aft/east
	name = "Юго-восточный проход"

/area/hallway/primary/aft/north
	name = "Юг-север проход"

/area/hallway/primary/aft/south
	name = "Дальний южный проход"

/area/hallway/primary/port
	name = "Основной западный проход"
	icon_state = "hallP"

/area/hallway/primary/port/west
	name = "Дальний западный проход"

/area/hallway/primary/port/east
	name = "Запад-восток проход"

/area/hallway/primary/port/north
	name = "Северо-западный проход"

/area/hallway/primary/port/south
	name = "Юго-западный проход"

/area/hallway/primary/central //pay attention to THIS SHIT
	name = "Основной центральный проход"
	icon_state = "hallC"

/area/hallway/primary/central/north
/area/hallway/primary/central/south
/area/hallway/primary/central/west
/area/hallway/primary/central/east
/area/hallway/primary/central/nw
/area/hallway/primary/central/ne
/area/hallway/primary/central/sw
/area/hallway/primary/central/se

/area/hallway/primary/command
	name = "Основной проход — командование"
	icon_state = "hallC"

/area/hallway/primary/command/north
/area/hallway/primary/command/south
/area/hallway/primary/command/west
/area/hallway/primary/command/east
/area/hallway/primary/command/nw
/area/hallway/primary/command/ne

/area/hallway/primary/central/second
	name = "Основной центральный проход — второй этаж"

/area/hallway/primary/central/second/north
/area/hallway/primary/central/second/south
/area/hallway/primary/central/second/west
/area/hallway/primary/central/second/east
/area/hallway/primary/central/second/nw
/area/hallway/primary/central/second/ne
/area/hallway/primary/central/second/sw
/area/hallway/primary/central/second/se

/area/hallway/spacebridge
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	icon_state = "hall_space"

/area/hallway/spacebridge/dockmed
	name = "Мост — стыковка-медотсек"

/area/hallway/spacebridge/scidock
	name = "Мост — НИО-стыковка"

/area/hallway/spacebridge/somsec
	name = "Мост — командование-СБ"

/area/hallway/spacebridge/sersec
	name = "Мост — обслуживание-СБ"

/area/hallway/spacebridge/engdock
	name = "Мост — инженерия-стыковка"

/area/hallway/spacebridge/servsci
	name = "Мост — обслуживание-НИО"

/area/hallway/spacebridge/serveng
	name = "Мост — НИО-инженерия"

/area/hallway/spacebridge/engmed
	name = "Мост — инженерия-медотсек"

/area/hallway/spacebridge/medcargo
	name = "Мост — медотсек-снабжение"

/area/hallway/spacebridge/cargocom
	name = "Мост — снабжение-ИИ-командование"

/area/hallway/spacebridge/sercom
	name = "Мост — командование-обслуживание"

/area/hallway/spacebridge/comeng
	name = "Мост — командование-инженерия"

/area/hallway/spacebridge/comcar
	name = "Мост — командование-снабжение"

/area/hallway/secondary/exit
	name = "Проход к эвакуационному шаттлу"
	icon_state = "escape"
	holomap_color = HOLOMAP_AREACOLOR_ESCAPE

/area/hallway/secondary/exit/maint
	name = "Заброшенный проход к эвакуационному шаттлу"
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/hallway/secondary/construction
	name = "Строительная площадка"
	icon_state = "construction"

/area/hallway/secondary/garden
	name = "Сад"
	icon_state = "hydro"

/area/hallway/secondary/entry
	name = "Проход к пункту прибытия"
	icon_state = "entry"
	holomap_color = HOLOMAP_AREACOLOR_ARRIVALS


/area/hallway/secondary/entry/eastarrival
	name = "Проход к пункту прибытия — восточный"

/area/hallway/secondary/entry/westarrival
	name = "Проход к пункту прибытия — западный"

/area/hallway/secondary/entry/additional
	name = "Проход к пункту прибытия — западный дополнительный"

/area/hallway/secondary/entry/commercial
	name = "Проход к пункту прибытия — западный торговый"

/area/hallway/secondary/entry/north

/area/hallway/secondary/entry/south

/area/hallway/secondary/entry/lounge
	name = "Зал прибытия"
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/**
 * MARK: Command
 */

/area/bridge
	name = "Мостик"
	icon_state = "bridge"
	ambientsounds = list('sound/ambience/signal.ogg')
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/bridge/meeting_room
	name = "Зал совещаний Командования"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/bridge/vip
	name = "ВИП-зона"
	icon_state = "meeting"
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/area/crew_quarters/captain
	name = "Офис Капитана"
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/crew_quarters/captain/bedroom
	name = "Спальня Капитана"

/area/crew_quarters/recruit
	name = "Офис по подбору персонала"
	icon_state = "head_quarters"

/area/crew_quarters/heads/hop
	name = "Каюта Главы Персонала"

/area/crew_quarters/heads/hor
	name = "Каюта Научного Руководителя"
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE

/area/crew_quarters/heads/chief
	name = "Каюта Главного Инженера"

/area/crew_quarters/heads/hos
	name = "Каюта Главы Службы Безопасности"

/area/crew_quarters/heads/cmo
	name = "Каюта Главного Врача"
	holomap_color = HOLOMAP_AREACOLOR_MEDICAL

/area/crew_quarters/courtroom
	name = "Зал суда"
	icon_state = "courtroom"
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/crew_quarters/heads
	name = "Офис Главы Персонала"
	icon_state = "head_quarters"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/crew_quarters/hor
	name = "Офис Научного Руководителя"
	icon_state = "head_quarters"
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE

/area/crew_quarters/hos
	name = "Офис Главы Службы Безопасности"
	icon_state = "head_quarters"
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/crew_quarters/chief
	name = "Офис Главного Инженера"
	icon_state = "head_quarters"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/mint
	name = "Мята"
	icon_state = "green"

/area/comms
	name = "Реле коммуникаций"
	icon_state = "tcomms"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/server
	name = "Сервер обмена сообщениями"
	icon_state = "server"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/ntrep
	name = "Офис Представителя Нанотрейзен"
	icon_state = "ntrep"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/blueshield
	name = "Офис Офицера \"Синий щит\""
	icon_state = "blueshield"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/centcomdocks
	name = "Центком — доки"
	icon_state = "centcom"

/area/bridge/checkpoint
	name = "КПП командования"

/area/bridge/checkpoint/north
	name = "КПП командования — северный"

/area/bridge/checkpoint/south
	name = "КПП командования — южный"


/**
 * MARK: CREW
 */

/area/crew_quarters
	name = "Дормитории"
	icon_state = "Sleep"
	holomap_color = HOLOMAP_AREACOLOR_DORMS
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/crew_quarters/serviceyard
	name = "Крыло Отдела обслуживания"

/area/crew_quarters/cabin1
	name = "Жилая каюта №1"

/area/crew_quarters/cabin2
	name = "Жилая каюта №2"

/area/crew_quarters/cabin3
	name = "Жилая каюта №3"

/area/crew_quarters/cabin4
	name = "Жилая каюта №4"

/area/crew_quarters/toilet
	name = "Уборная — дормитории"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/crew_quarters/toilet2
	name = "Уборная — западная"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/crew_quarters/toilet3
	name = "Уборная — театр"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/crew_quarters/toilet4
	name = "Уборная — пункт прибытия"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_ARRIVALS

/area/crew_quarters/sleep
	valid_territory = FALSE

/area/crew_quarters/sleep/secondary
	name = "Дормитории — вторичные"

/area/crew_quarters/sleep_male
	name = "Жилая каюта — мужская"

/area/crew_quarters/sleep_male/toilet_male
	name = "Мужская уборная"
	icon_state = "toilet"

/area/crew_quarters/sleep_female
	name = "Жилая каюта — женская"

/area/crew_quarters/sleep_female/toilet_female
	name = "Женская уборная"
	icon_state = "toilet"

/area/crew_quarters/locker
	name = "Раздевалка"
	icon_state = "locker"

/area/crew_quarters/locker/locker_toilet
	name = "Уборная — раздевалка"
	icon_state = "toilet"

/area/crew_quarters/fitness
	name = "Фитнесс-зал"
	icon_state = "fitness"

/area/crew_quarters/dorms
	icon_state = "dorms"

/area/crew_quarters/trading
	name = "Заброшенный торговый пункт"
	icon_state = "blue"
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/crew_quarters/arcade
	name = "Игровой зал"
	icon_state = "arcade"

/area/crew_quarters/cafeteria
	name = "Кафетерий"
	icon_state = "cafeteria"
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/crew_quarters/kitchen
	name = "Кухня"
	icon_state = "kitchen"
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/crew_quarters/bar
	name = "Бар"
	icon_state = "barstation"
	sound_environment = SOUND_AREA_WOODFLOOR
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/crew_quarters/bar/atrium
	name = "Атриум"
	icon_state = "bar"

/area/crew_quarters/theatre
	name = "Театр"
	icon_state = "Theatre"
	sound_environment = SOUND_AREA_WOODFLOOR
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/crew_quarters/mrchangs
	name = "Кафетерий \"У Мистера Чанга\""
	icon_state = "Theatre"
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/area/library
	name = "Библиотека"
	icon_state = "library"
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/library/game_zone
	name = "Библиотека — игровая"

/area/chapel
	icon_state = "chapel"
	ambientsounds = HOLY_SOUNDS
	is_haunted = TRUE
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/chapel/main
	name = "Церковь"

/area/chapel/office
	name = "Церковь — офис Священника"
	icon_state = "chapeloffice"

/area/chapel/morgue
	name = "Церковь — морг"

/area/chapel/massdriver
	name = "Церковь — ускоритель частиц"

/area/escapepodbay
	name = "Проход к эвакуационному шаттлу — ангар для челноков"
	icon_state = "escape"
	holomap_color = HOLOMAP_AREACOLOR_HANGAR

/area/lawoffice
	name = "Юридический офис"
	icon_state = "law"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/magistrateoffice
	name = "Офис Магистрата"
	icon_state = "magistrate"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/clownoffice
	name = "Офис Клоуна"
	icon_state = "clown_office"
	sound_environment = SOUND_ENVIRONMENT_PADDED_CELL
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/clownoffice/secret
	name = "Сверхсекретная клоунская штаб-квартира"
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/mimeoffice
	name = "Офис Мима"
	icon_state = "mime_office"
	holomap_color = HOLOMAP_AREACOLOR_SERVICE


/**
 * MARK: CIVILIAN
 */

/area/civilian
	holomap_color = HOLOMAP_AREACOLOR_DORMS

/area/civilian/vacantoffice
	name = "Свободный офис"
	icon_state = "green"

/area/civilian/barber
	name = "Парикмахерская"
	icon_state = "barber"

/area/civilian/clothing
	name = "Магазин одежды"
	icon_state = "Theatre"

/area/civilian/pet_store
	name = "Зоомагазин"
	icon_state = "pet_store"

/area/civilian/vacantoffice2
	name = "Свободный офис"
	icon_state = "security"

/area/holodeck
	name = "Голопалуба"
	icon_state = "Holodeck"
	static_lighting = FALSE
	base_lighting_alpha = 255
	holomap_color = HOLOMAP_AREACOLOR_DORMS

/area/holodeck/alphadeck
	name = "Голопалуба альфа"


/area/holodeck/source_plating
	name = "Голопалуба — неактивная"

/area/holodeck/source_emptycourt
	name = "Голопалуба — пустая комната"

/area/holodeck/source_boxingcourt
	name = "Голопалуба — бойцовский ринг"

/area/holodeck/source_basketball
	name = "Голопалуба — баскетбольная площадка"

/area/holodeck/source_thunderdomecourt
	name = "Голопалуба — тандердом"

/area/holodeck/source_beach
	name = "Голопалуба — пляж"

/area/holodeck/source_burntest
	name = "Голопалуба — отсек атмосферного тестирования"

/area/holodeck/source_wildlife
	name = "Голопалуба — симуляция пожара"

/area/holodeck/source_meetinghall
	name = "Голопалуба — конференц-зал"

/area/holodeck/source_theatre
	name = "Голопалуба — театр"

/area/holodeck/source_picnicarea
	name = "Голопалуба — место для пикника"

/area/holodeck/source_snowfield
	name = "Голопалуба — снежное поле"

/area/holodeck/source_desert
	name = "Голопалуба — пустыня"

/area/holodeck/source_space
	name = "Голопалуба — космос"

/area/holodeck/source_knightarena
	name = "Голопалуба — рыцарская арена"

/**
 * MARK: ENGINEERING
 */

/area/engineering
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/engineering/engine/smes
	name = "Инженерный отдел — СКАН'ы"

/area/engineering/engine
	name = "Инженерный отдел — двигательный отсек"
	icon_state = "engine_smes"

/area/engineering/engine/monitor
	name = "Инженерный отдел — комната слежения за двигателем"
	icon_state = "engine_control"

/area/engineering/break_room
	name = "Инженерный отдел — фойе"
	icon_state = "engine"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/engineering/aienter
	name = "Инженерный отдел — проход на спутник ИИ"
	icon_state = "engine"

/area/engineering/equipmentstorage
	name = "Инженерный отдел — склад снаряжения"
	icon_state = "storage"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/engineering/hardsuitstorage
	name = "Инженерный отдел — склад ИКС"
	icon_state = "storage"

/area/engineering/controlroom
	name = "Инженерный отдел — комната слежения"
	icon_state = "engine_control"

/area/engineering/gravitygenerator
	name = "Инженерный отдел — генератор гравитации"
	icon_state = "engine"

/area/engineering/chiefs_office
	name = "Офис Главного Инженера"
	icon_state = "engine_control"

/area/engineering/mechanic_workshop
	name = "Мастерская Механика"
	icon_state = "engine"
	holomap_color = HOLOMAP_AREACOLOR_HANGAR

/area/engineering/mechanic_workshop/expedition
	name = "Склад снаряжения для Исследователей"

/area/engineering/mechanic_workshop/hangar
	name = "Ангар для челноков"

/area/engineering/supermatter
	name = "Отсек Суперматерии"
	icon_state = "engine"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/**
 * MARK: Solars
 */

/area/solar //i hate this macaroni areas
	requires_power = FALSE
	valid_territory = FALSE
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_SPACE
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/solar/auxport
	name = "Солнечная батарея — северо-запад"
	icon_state = "panelsA"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/solar/auxstarboard
	name = "Солнечная батарея — северо-восток"
	icon_state = "panelsA"

/area/solar/fore
	name = "Солнечная батарея — север"
	icon_state = "yellow"

/area/solar/aft
	name = "Солнечная батарея — юг"
	icon_state = "aft"

/area/solar/starboardaux
	name = "Солнечная батарея — восток"
	icon_state = "panelsS"

/area/solar/starboard
	name = "Солнечная батарея — юго-восток"
	icon_state = "panelsS"

/area/solar/west
	name = "Солнечная батарея — запад"
	icon_state = "panelsS"

/area/solar/port
	name = "Солнечная батарея — юго-запад"
	icon_state = "panelsP"

/area/maintenance/auxsolarport
	name = "Технические тоннели у солнечной батареи — северо-запад"
	icon_state = "SolarcontrolA"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/north_solars
	name = "Технические тоннели у солнечной батареи — север"
	icon_state = "SolarcontrolA"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/starboardaux
	name = "Технические тоннели у солнечной батареи — восток"
	icon_state = "SolarcontrolS"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/starboardsolar
	name = "Технические тоннели у солнечной батареи — юго-восток"
	icon_state = "SolarcontrolS"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/portsolar
	name = "Технические тоннели у солнечной батареи — юго-запад"
	icon_state = "SolarcontrolP"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/auxsolarstarboard
	name = "Технические тоннели у солнечной батареи — северо-восток"
	icon_state = "SolarcontrolA"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/west_solars
	name = "Технические тоннели у солнечной батареи — запад"
	icon_state = "SolarcontrolA"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/assembly
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE

/area/assembly/chargebay
	name = "Ангар для экзоскелетов"
	icon_state = "mechbay"

/area/assembly/showroom
	name = "Робототехника — демонстрационный зал"
	icon_state = "showroom"

/area/assembly/robotics
	name = "Отсек робототехники"
	icon_state = "ass_line"

/area/assembly/assembly_line //Derelict Assembly Line
	name = "Сборочный конвейер"
	icon_state = "ass_line"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/**
 * MARK: Teleporter
 */

/area/teleporter
	name = "Телепортерная"
	icon_state = "teleporter"
	ambientsounds = ENGINEERING_SOUNDS
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/teleporter/research
	name = "Робототехника — телепортерная"

/area/teleporter/abandoned
	name = "Заброшенная телепортерная"
	ambientsounds = ENGINEERING_SOUNDS
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/teleporter/quantum
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/area/teleporter/quantum/security
	name = "Телепортерная — Служба безопасности"

/area/teleporter/quantum/docking
	name = "Телепортерная — стыковочный пункт"

/area/teleporter/quantum/science
	name = "Телепортерная — НИО"

/area/teleporter/quantum/cargo
	name = "Телепортерная — Отдел снабжения"

/area/teleporter/quantum/comand
	name = "Телепортерная — Командование"

/area/teleporter/quantum/service
	name = "Телепортерная — Отдел обслуживания"

/area/teleporter/quantum/medbay
	name = "Телепортерная — Медицинский отдел"

/area/teleporter/quantum/engi
	name = "Телепортерная — инженерия"

/area/gateway
	name = "Врата"
	icon_state = "teleporter"
	ambientsounds = ENGINEERING_SOUNDS
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/AIsattele
	name = "Телепортер — спутник ИИ"
	icon_state = "teleporter"
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/signal.ogg')
	area_flags = UNIQUE_AREA
	holomap_color = HOLOMAP_AREACOLOR_COMMAND
/**
 * MARK: MedBay
 */
/area/medical
	ambientsounds = MEDICAL_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION
	min_ambience_cooldown = 90 SECONDS
	max_ambience_cooldown = 180 SECONDS
	holomap_color = HOLOMAP_AREACOLOR_MEDICAL

/area/medical/medbay
	name = "Медицинский отдел"
	icon_state = "medbay"

//Medbay is a large area, these additional areas help level out APC load. wtf dude, nobody use THIS MUCH ZONES
/area/medical/medbay2
	name = "Медицинский отдел"
	icon_state = "medbay2"

/area/medical/medbay3
	name = "Медицинский отдел"
	icon_state = "medbay3"


/area/medical/biostorage
	name = "Медицинский отдел — склад снаряжения"
	icon_state = "medbaysecstorage"

/area/medical/reception
	name = "Медицинский отдел — приёмная"
	icon_state = "medbay"

/area/medical/psych
	name = "Медицинский отдел — кабинет Психиатра"
	icon_state = "medbaypsych"

/area/medical/medbreak
	name = "Медицинский отдел — комната отдыха"
	icon_state = "medbaybreak"

/area/medical/medrest
	name = "Медицинский отдел — комната отдыха"
	icon_state = "medbaybreak"

/area/medical/patients_rooms
	name = "Медицинский отдел — палаты пациентов"
	icon_state = "patients"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/medical/ward
	name = "Медицинский отдел — крыло пациентов"
	icon_state = "patientsward"

/area/medical/patient_a
	name = "Медицинский отдел — изолятор №1"
	icon_state = "medbayisoa"

/area/medical/patient_b
	name = "Медицинский отдел — изолятор №2"
	icon_state = "medbayisob"

/area/medical/patient_c
	name = "Медицинский отдел — изолятор №3"
	icon_state = "medbayisoc"

/area/medical/iso_access
	name = "Isolation Access"
	icon_state = "medbayisoaccess"

/area/medical/cmo
	name = "Офис Главного Врача"
	icon_state = "CMO"

/area/medical/cmostore
	name = "Медицинский отдел — вторичный склад снаряжения"
	icon_state = "medbaysecstorage"

/area/medical/robotics //why
	name = "Робототехника"
	icon_state = "research"

/area/medical/research
	name = "Научно-исследовательский отдел"
	icon_state = "research"
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE

/area/medical/research/nhallway
	name = "НИО — северный коридор"

/area/medical/research/shallway
	name = "НИО — южный коридор"

/area/medical/research/restroom
	name = "НИО — комната отдыха"

/area/medical/virology
	name = "Медицинский отдел — вирусология"
	icon_state = "virology"

/area/medical/virology/lab
	name = "Медицинский отдел — лаборатория вирусологии"

/area/medical/morgue
	name = "Медицинский отдел — морг"
	icon_state = "morgue"
	ambientsounds = SPOOKY_SOUNDS
	is_haunted = TRUE
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/medical/chemistry
	name = "Медицинский отдел — химическая лаборатория"
	icon_state = "chem"

/area/medical/surgery
	name = "Медицинский отдел — операционная"
	icon_state = "surgery"

/area/medical/surgery/north
	name = "Медицинский отдел — операционная №1"
	icon_state = "surgery1"

/area/medical/surgery/south
	name = "Медицинский отдел — операционная №2"
	icon_state = "surgery2"

/area/medical/surgery/theatre
	name = "Медицинский отдел — операционный театр"
	icon_state = "surgery_theatre"

/area/medical/surgeryobs
	name = "Медицинский отдел — пункт наблюдения за операционными"
	icon_state = "surgery"

/area/medical/cryo
	name = "Медицинский отдел — отсек криогеники"
	icon_state = "cryo"

/area/medical/exam_room
	name = "Медицинский отдел — смотровой кабинет"
	icon_state = "exam_room"

/area/medical/genetics
	name = "Медицинский отдел — лаборатория генетики"
	icon_state = "genetics"

/area/medical/cloning
	name = "Медицинский отдел — отсек клонирования"
	icon_state = "cloning"

/area/medical/sleeper
	name = "Медицинский отдел — центр медицинской помощи"
	icon_state = "exam_room"

/area/medical/paramedic
	name = "Медицинский отдел — кабинет Парамедика"
	icon_state = "medbay"

/**
 * MARK: Security
 */

/area/security
	ambientsounds = HIGHSEC_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/security/main
	name = "Служба безопасности — главный офис"
	icon_state = "securityoffice"

/area/security/lobby
	name = "Служба безопасности — вестибюль"
	icon_state = "securitylobby"

/area/security/brig
	name = "Служба безопасности — бриг"
	icon_state = "brig"

/area/security/brig/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = 0
		temp_closet.update_icon()
	for(var/obj/machinery/door_timer/temp_timer in machinery_cache)
		temp_timer.releasetime = 1
	..()

/area/security/permabrig
	name = "Служба безопасности — пермабриг"
	icon_state = "sec_prison_perma"
	fast_despawn = TRUE
	can_get_auto_cryod = FALSE

/area/security/prison
	name = "Служба безопасности — пермабриг"
	icon_state = "sec_prison"
	can_get_auto_cryod = FALSE

/area/security/prison/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = 0
		temp_closet.update_icon()
	for(var/obj/machinery/door_timer/temp_timer in machinery_cache)
		temp_timer.releasetime = 1
	..()

/area/security/prison/cell_block
	name = "Служба безопасности — камера заключения"
	icon_state = "brig"

/area/security/prison/cell_block/A
	name = "Служба безопасности — камера заключения №1"
	icon_state = "brigcella"

/area/security/prison/cell_block/B
	name = "Служба безопасности — камера заключения №2"
	icon_state = "brigcellb"

/area/security/prison/cell_block/C
	name = "Служба безопасности — камера заключения №3"

/area/security/reception
	name = "Служба безопасности — приёмная"
	icon_state = "brig"

/area/security/execution
	name = "Служба безопасности — комната казни"
	icon_state = "execution"
	can_get_auto_cryod = FALSE

/area/security/permahallway
	name = "Служба безопасности — проход к пермабрига"
	icon_state = "sec_prison_perma"

/area/security/processing
	name = "Служба безопасности — обработка заключённых"
	icon_state = "prisonerprocessing"
	can_get_auto_cryod = FALSE

/area/security/holding_cell
	name = "Служба безопасности — пункт временного удержания"
	icon_state = "holdingcell"

/area/security/interrogation
	name = "Служба безопасности — допросная"
	icon_state = "interrogation"
	can_get_auto_cryod = FALSE

/area/security/seceqstorage
	name = "Служба безопасности — склад снаряжения"
	icon_state = "securityequipmentstorage"

/area/security/brigstaff
	name = "Служба безопасности — комната отдыха"
	icon_state = "brig"

/area/security/interrogationhallway
	name = "Служба безопасности — проход к допросной"
	icon_state = "interrogationhall"

/area/security/courtroomdandp
	name = "Зал суда — защита и обвинение"
	icon_state = "seccourt"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/security/interrogationobs
	name = "Служба безопасности — наблюдение за допросной"
	icon_state = "security"
	can_get_auto_cryod = FALSE

/area/security/evidence
	name = "Служба безопасности — комната хранения улик"
	icon_state = "evidence"

/area/security/visiting_room
	name = "Служба безопасности — комната для свиданий"
	icon_state = "visiting-room"

/area/security/prisonlockers
	name = "PСлужба безопасности — шкафчики заключённых"
	icon_state = "sec_prison_lockers"
	can_get_auto_cryod = FALSE

/area/security/medbay
	name = "Служба безопасности — лазарет"
	icon_state = "security_medbay"

/area/security/prisonershuttle
	name = "Служба безопасности — шаттл трудового лагеря"
	icon_state = "security"
	can_get_auto_cryod = FALSE

/area/security/warden
	name = "Офис Смотрителя"
	icon_state = "Warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/security/armory
	name = "Служба безопасности — арсенал"
	icon_state = "armory"

/area/security/securearmory
	name = "Служба безопасности — защищённый арсенал"
	icon_state = "secarmory"

/area/security/securehallway
	name = "Служба безопасности — защищённый проход"
	icon_state = "securehall"

/area/security/hos
	name = "Офис Главы службы безопасности"
	icon_state = "sec_hos"

/area/security/podbay
	name = "Служба безопасности — ангар для челнока"
	icon_state = "securitypodbay"

/area/security/detectives_office
	name = "Офис Детектива"
	icon_state = "detective"
	ambientsounds = list('sound/ambience/ambidet1.ogg', 'sound/ambience/ambidet2.ogg')

/area/security/range
	name = "Служба безопасности — стрельбище"
	icon_state = "firingrange"

/area/security/nuke_storage
	name = "Защищённое хранилище"
	icon_state = "nuke_storage"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/security/customs
	name = "КПП"
	icon_state = "checkpoint1"

/area/security/customs2
	name = "КПП"
	icon_state = "security"

/area/security/checkpoint
	name = "Служба безопасности — КПП"
	icon_state = "checkpoint1"

/area/security/checkpoint2
	name = "Служба безопасности — КПП"
	icon_state = "checkpoint1"

/area/security/checkpoint/south
	name = "Служба безопасности — КПП пункта отбытия"
	icon_state = "security"

/area/security/checkpoint/supply
	name = "Служба безопасности — охранный пост Отдела снабжения"

/area/security/checkpoint/engineering
	name = "Служба безопасности — охранный пост Инженерного отдела"

/area/security/checkpoint/medical
	name = "Служба безопасности — охранный пост Медицинского отдела"

/area/security/checkpoint/science
	name = "Служба безопасности — охранный пост НИО"

/area/quartermaster
	name = "Отдел снабжения"
	icon_state = "quart"
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_CARGO

/area/quartermaster/sorting
	name = "Отдел снабжения — распределительный центр"
	icon_state = "quartstorage"

/area/quartermaster/office
	name = "Отдел снабжения — офис"
	icon_state = "quartoffice"

/area/quartermaster/lobby
	name = "Отдел снабжения — вестибюль"
	icon_state = "quartoffice"

/area/quartermaster/delivery
	name = "Отдел снабжения — пункт отправки"
	icon_state = "quartoffice"

/area/quartermaster/storage
	name = "Отдел снабжения — грузовой ангар"
	icon_state = "quartstorage"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/quartermaster/qm
	name = "Офис Квартирмейстера"

/area/quartermaster/miningdock
	name = "Отдел снабжения — шахтёрский пункт"
	icon_state = "mining"

/area/quartermaster/miningstorage
	name = "Отдел снабжения — шахтёрский склад"
	icon_state = "green"

/area/quartermaster/mechbay
	name = "Отдел снабжения — ангар для экзоскелетов"
	icon_state = "yellow"

/area/janitor
	name = "Каморка Уборщика"
	icon_state = "janitor"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/hydroponics
	name = "Гидропоника"
	icon_state = "hydro"
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/maintenance/garden
	name = "Старый сад"
	icon_state = "hydro"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/area/maintenance/garden/north
	name = "Старый сад — северный"

/area/maintenance/kitchen
	name = "Старый ресторан"
	icon_state = "kitchen"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/**
 * MARK: Toxins
 */

/area/toxins
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE

/area/toxins/lab
	name = "Научно-исследовательский отдел"
	icon_state = "toxlab"

/area/toxins/hallway
	name = "НИО — лаборатория"
	icon_state = "toxlab"

/area/toxins/rdoffice
	name = "Офис Научного Руководителя"
	icon_state = "head_quarters"

/area/toxins/xenobiology
	name = "НИО — лаборатория ксенобиологии"
	icon_state = "toxmix"
	xenobiology_compatible = TRUE

/area/toxins/xenobiology/xenoflora_storage
	name = "НИО — хранилище ксенофлоры"
	icon_state = "toxlab"

/area/toxins/xenobiology/xenoflora
	name = "НИО — хранилище ксенофлоры"
	icon_state = "toxlab"

/area/toxins/storage
	name = "НИО — хранилище токсинов"
	icon_state = "toxstorage"

/area/toxins/test_area
	name = "НИО — отсек тестирования токсинов"
	icon_state = "toxtest"
	valid_territory = FALSE

/area/toxins/mixing
	name = "НИО — смеситель токсинов"
	icon_state = "toxmix"

/area/toxins/launch
	name = "НИО — комната отправки токсинных бомб"
	icon_state = "toxlaunch"

/area/toxins/misc_lab
	name = "НИО — пункт тестирования токсинов"
	icon_state = "toxmisc"

/area/toxins/test_chamber
	name = "НИО — камера исследования токсинов"
	icon_state = "toxtest"

/area/toxins/server
	name = "НИО — серверная"
	icon_state = "server"

/area/toxins/server_coldroom
	name = "НИО — отсек охлаждения серверной"
	icon_state = "servercold"

/area/toxins/sm_test_chamber
	name = "НИО — лаборатория исследования Суперматерии"
	icon_state = "toxtest"
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/toxins/explab
	name = "НИО — лаборатория \"Э.К.С.П.Е.Р.И-МЕНТОР\"'а"
	icon_state = "toxmisc"

/area/toxins/explab_chamber
	name = "НИО — камера \"Э.К.С.П.Е.Р.И-МЕНТОР\"'а"
	icon_state = "toxmisc"

/**
 * MARK: Storage
 */

/area/storage
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/area/storage/tools
	name = "Дополнительное хранилище инструментов"
	icon_state = "storage"

/area/storage/primary
	name = "Хранилище инструментов"
	icon_state = "primarystorage"

/area/storage/autolathe
	name = "Склад автолата"
	icon_state = "storage"

/area/storage/art
	name = "Артистическое хранилище"
	icon_state = "storage"

/area/storage/auxillary
	name = "Дополнительный склад"
	icon_state = "auxstorage"

/area/storage/eva
	name = "Склад снаряжения для ВКД"
	icon_state = "eva"
	ambientsounds = HIGHSEC_SOUNDS
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/storage/secure
	name = "Защищённое хранилище"
	icon_state = "storage"
	ambientsounds = HIGHSEC_SOUNDS
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/storage/emergency
	name = "Аварийное хранилище — восточное"
	icon_state = "emergencystorage"
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/storage/emergency2
	name = "Аварийное хранилище — западное"
	icon_state = "emergencystorage"
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/storage/tech
	name = "Техническое хранилище"
	icon_state = "auxstorage"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/storage/office
	name = "Склад офисного оборудования"
	icon_state = "office_supplies"
	holomap_color = HOLOMAP_AREACOLOR_DORMS

/**
 * MARK: DJSTATION
 */

/area/djstation
	name = "Диджей-станция СССП"
	icon_state = "DJ"
	area_flags = UNIQUE_AREA
	has_gravity = STANDARD_GRAVITY

/area/djstation/solars
	name = "Диджей-станция СССП — солнечная батарея"

/**
 * MARK: DERELICT
 */

/area/derelict
	name = "Заброшенная станция"
	icon_state = "storage"
	has_gravity = STANDARD_GRAVITY

/area/derelict/hallway/primary
	name = "Заброшенная станция — основной коридор"
	icon_state = "hallP"

/area/derelict/hallway/secondary
	name = "Заброшенная станция — дополнительный коридор"
	icon_state = "hallS"

/area/derelict/arrival
	name = "Заброшенная станция — пункт прибытия"
	icon_state = "yellow"

/area/derelict/church
	name = "Заброшенная станция — церковь"
	icon_state = "chapel"

/area/derelict/common
	name = "Заброшенная станция — стандартная зона"
	icon_state = "crew_quarters"

/area/derelict/asteroidbelt
	name = "Заброшенная станция — астероиды"
	icon_state = "mining"
	requires_power = FALSE
	has_gravity = FALSE

/area/derelict/med
	name = "Заброшенная станция — медотсек"
	icon_state = "medbay"

/area/derelict/garden
	name = "Заброшенная станция — гидропоника"
	icon_state = "hydro"

/area/derelict/dining
	name = "Заброшенная станция — обеденная комната"
	icon_state = "kitchen"

/area/derelict/dock
	name = "Заброшенная станция — пункт стыковки"
	icon_state = "ntrep"

/area/derelict/security
	name = "Заброшенная станция — служба безопасности"
	icon_state = "blue"

/area/derelict/rnd
	name = "Заброшенная станция — НИО"
	icon_state = "purple"

/area/derelict/engineer_area
	name = "Заброшенная станция — инженерия"
	icon_state = "engine_control"

/area/derelict/storage/equipment
	name = "Заброшенная станция — склад снаряжения"

/area/derelict/storage/storage_access
	name = "Заброшенная станция — пункт доступа к складу"

/area/derelict/storage/engine_storage
	name = "Заброшенная станция — хранилище для двигателя"
	icon_state = "green"

/area/derelict/bridge
	name = "Заброшенная станция — комната управления"
	icon_state = "bridge"

/area/derelict/secret
	name = "Заброшенная станция — секретная комната"
	icon_state = "library"

/area/derelict/bridge/access
	name = "Заброшенная станция — пункт доступа к комнате управления"
	icon_state = "auxstorage"

/area/derelict/bridge/ai_upload
	name = "Заброшенная станция — ядро ИИ"
	icon_state = "ai"

/area/derelict/solar_control
	name = "Заброшенная станция — пункт управления солнечной батареей"
	icon_state = "engine"

/area/derelict/se_solar
	name = "Заброшенная станция — юго-восточная солнечная батарея"
	icon_state = "engine"

/area/derelict/crew_quarters
	name = "Заброшенная станция — жилой модуль"
	icon_state = "fitness"

/area/derelict/medical
	name = "Заброшенная станция — медотсек"
	icon_state = "medbay"

/area/derelict/medical/morgue
	name = "Заброшенная станция — морг"
	icon_state = "morgue"
	is_haunted = TRUE

/area/derelict/medical/chapel
	name = "Заброшенная станция — церковь"
	icon_state = "chapel"
	is_haunted = TRUE

/area/derelict/teleporter
	name = "Заброшенная станция — телепортационная"
	icon_state = "teleporter"
	area_flags = UNIQUE_AREA

/area/derelict/annex
	name = "Заброшенная станция — пристройка"
	icon_state = "eva"

/area/shuttle/derelict/ship/start
	name = "Заброшенное судно"
	icon_state = "yellow"

/area/shuttle/derelict/ship/transit
	name = "Заброшенное судно"
	icon_state = "yellow"

/area/shuttle/derelict/ship/engipost
	name = "Инженерный аванпост"
	icon_state = "yellow"

/area/shuttle/derelict/ship/station
	name = "Север Космической Станции №13"
	icon_state = "yellow"

/area/solar/derelict_starboard
	name = "Заброшенная станция — восточная солнечная батарея"
	icon_state = "panelsS"

/area/solar/derelict_aft
	name = "Заброшенная станция — южная солнечная батарея"
	icon_state = "aft"

/area/derelict/singularity_engine
	name = "Заброшенная станция — сингулярный двигатель"
	icon_state = "engine"

/area/derelict/gravity_generator
	name = "Заброшенная станция — отсек генератора гравитации"
	icon_state = "red"

/area/derelict/atmospherics
	name = "Заброшенная станция — атмосферный отсек"
	icon_state = "red"
/**
 * MARK: Construction
 */
/area/construction
	name = "Строительная площадка"
	icon_state = "yellow"
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/construction/hallway
	name = "Проход к строительной площадке"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/construction/solars
	name = "Строительная площадка — солнечная батарея"

/**
 * MARK: GAYBAR
 */

/area/secret/gaybar
	name = "Танцевальный бар"
	icon_state = "dancebar"

/**
 * MARK: AI
 */

/area/turret_protected
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/turret_protected/ai_upload
	name = "Отсек конфигурации ИИ"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/turret_protected/ai_upload_foyer
	name = "Пункт доступа к отсеку конфигурации ИИ"
	icon_state = "ai_foyer"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/turret_protected/ai
	name = "Ядро ИИ"
	icon_state = "ai_chamber"

/area/turret_protected/aisat
	name = "AI Satellite"
	icon_state = "ai"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/aisat
	name = "Проход к спутнику ИИ"
	icon_state = "yellow"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/aisat/aihallway
	name = "Внешний проход к спутнику ИИ"
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/aisat/entrance
	name = "Спутник ИИ — вход"
	icon_state = "ai_foyer"

/area/aisat/maintenance
	name = "Спутник ИИ — пункт технического обслуживания"
	icon_state = "storage"

/area/aisat/atmospherics
	name = "Спутник ИИ — атмосферный отсек"
	icon_state = "storage"

/area/turret_protected/aisat_interior
	name = "Спутник ИИ — вестибюль"
	icon_state = "ai"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/turret_protected/aisat_interior/secondary
	name = "Спутник ИИ — вторичный вестибюль"

/**
 * MARK: Telecommunications Satellite
 */

/area/tcommsat
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambitech.ogg',\
											'sound/ambience/ambitech2.ogg', 'sound/ambience/ambitech3.ogg', 'sound/ambience/ambimystery.ogg')
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/tcommsat/chamber
	name = "Телекоммуникационный спутник — основной отсек"
	icon_state = "tcomms"

// These areas are needed for MetaStation's AI sat
/area/turret_protected/tcomsat
	name = "Телекоммуникационный спутник"
	icon_state = "tcomms"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/turret_protected/tcomfoyer
	name = "Телекоммуникационный спутник — фойе"
	icon_state = "tcomms"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/turret_protected/tcomwest
	name = "Телекоммуникационный спутник — западное крыло"
	icon_state = "tcomms"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/turret_protected/tcomeast
	name = "Телекоммуникационный спутник — восточное крыло"
	icon_state = "tcomms"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/tcommsat/computer
	name = "Телекоммуникационный спутник — комната управления"
	icon_state = "tcomms"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/tcommsat/server
	name = "Телекоммуникационный спутник — серверная"
	icon_state = "tcomms"

/area/tcommsat/lounge
	name = "Телекоммуникационный спутник — зона отдыха"
	icon_state = "tcomms"

/area/tcommsat/powercontrol
	name = "Телекоммуникационный спутник — пункт энергоуправления"
	icon_state = "tcomms"

/**
 * MARK: Away missions
 */

/area/awaymission
	name = "Загадочное место"
	icon_state = "away"
	report_alerts = FALSE
	has_gravity = STANDARD_GRAVITY
	ambientsounds = AWAY_MISSION_SOUNDS
	sound_environment = SOUND_ENVIRONMENT_ROOM
	area_flags = NONE

/area/awaymission/example
	name = "Загадочная станция"

/area/awaymission/desert
	name = "Вынужденная посадка"

/area/awaymission/beach
	name = "Пляж"
	icon_state = "beach"
	static_lighting = FALSE
	base_lighting_alpha = 255
	requires_power = FALSE
	ambientsounds = list('sound/ambience/shore.ogg', 'sound/ambience/seag1.ogg', 'sound/ambience/seag2.ogg', 'sound/ambience/seag2.ogg', 'sound/ambience/ambiodd.ogg', 'sound/ambience/ambinice.ogg')

/area/awaymission/undersea
	name = "Под водой"
	icon_state = "undersea"


// area for AWAY "moonoutpost19"
/area/moonoutpost19
	name = "Лунный аванпост №19"
	has_gravity = STANDARD_GRAVITY
	report_alerts = FALSE
	area_flags = NONE
	holomap_should_draw = FALSE

/area/moonoutpost19/mo19arrivals
	name = "Лунный аванпост №19 — пункт прибытия"
	icon_state = "awaycontent1"

/area/moonoutpost19/mo19research
	name = "Лунный аванпост №19 — НИО"
	icon_state = "awaycontent2"

/area/moonoutpost19/khonsu19
	name = "Хонсу 19"
	icon_state = "awaycontent3"
	always_unpowered = TRUE
	ambientsounds = list('sound/ambience/ambimine.ogg')
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	poweralm = FALSE
	outdoors = TRUE

/area/moonoutpost19/syndicateoutpost
	name = "Лунный аванпост \"Синдиката\""
	icon_state = "awaycontent4"

/area/moonoutpost19/hive
	name = "Лунный аванпост №19 — улей"
	icon_state = "awaycontent5"
	always_unpowered = TRUE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	poweralm = FALSE

/area/moonoutpost19/mo19utilityroom
	name = "Лунный аванпост №19 — подсобное помещение"
	icon_state = "awaycontent6"

//area for AWAY "aeterna13"
/area/ae13
	icon_state = "ae13"
	always_unpowered = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	outdoors = TRUE
	has_gravity = STANDARD_GRAVITY
	holomap_should_draw = FALSE

/area/ae13/medbay
	name = "medbay"
	icon_state = "ae13_ship1"

/area/ae13/energy
	name = "energy"
	icon_state = "ae13_ship2"

/area/ae13/hall
	name = "hall"
	icon_state = "ae13_ship3"

/area/ae13/miner
	name = "miner"
	icon_state = "ae13_ship4"

/area/ae13/epicenter
	name = "epicenter"
	icon_state = "ae13_ship5"

/area/ae13/command
	name = "command"
	icon_state = "ae13_ship6"

/area/ae13/asteroid
	name = "asteroid"
	icon_state = "ae13_asteroid"

/**
 * MARK: AWAY AREAS
 */

/area/awaycontent
	report_alerts = FALSE
	has_gravity = STANDARD_GRAVITY
	area_flags = NONE
	holomap_should_draw = FALSE

/area/awaycontent/a1
	icon_state = "awaycontent1"

/area/awaycontent/a2
	icon_state = "awaycontent2"

/area/awaycontent/a3
	icon_state = "awaycontent3"

/area/awaycontent/a4
	icon_state = "awaycontent4"

/area/awaycontent/a5
	icon_state = "awaycontent5"

/area/awaycontent/a6
	icon_state = "awaycontent6"

/area/awaycontent/a7
	icon_state = "awaycontent7"

/area/awaycontent/a8
	icon_state = "awaycontent8"

/area/awaycontent/a9
	icon_state = "awaycontent9"

/area/awaycontent/a10
	icon_state = "awaycontent10"

/area/awaycontent/a11
	icon_state = "awaycontent11"

/area/awaycontent/a12
	icon_state = "awaycontent12"

/area/awaycontent/a13
	icon_state = "awaycontent13"

/area/awaycontent/a14
	icon_state = "awaycontent14"

/area/awaycontent/a15
	icon_state = "awaycontent15"

/area/awaycontent/a16
	icon_state = "awaycontent16"

/area/awaycontent/a17
	icon_state = "awaycontent17"

/area/awaycontent/a18
	icon_state = "awaycontent18"

/area/awaycontent/a19
	icon_state = "awaycontent19"

/area/awaycontent/a20
	icon_state = "awaycontent20"

/area/awaycontent/a21
	icon_state = "awaycontent21"

/area/awaycontent/a22
	icon_state = "awaycontent22"

/area/awaycontent/a23
	icon_state = "awaycontent23"

/area/awaycontent/a24
	icon_state = "awaycontent24"

/area/awaycontent/a25
	icon_state = "awaycontent25"

/area/awaycontent/a26
	icon_state = "awaycontent26"

/area/awaycontent/a27
	icon_state = "awaycontent27"

/area/awaycontent/a28
	icon_state = "awaycontent28"

/area/awaycontent/a29
	icon_state = "awaycontent29"

/area/awaycontent/a30
	icon_state = "awaycontent30"

/////////////////////////////////////////////////////////////////////
/*
	Lists of areas to be used with is_type_in_list.
	Used in gamemodes code at the moment. --rastaf0
*/
GLOBAL_LIST_INIT(centcom_areas, list(
	/area/centcom,
	/area/shuttle/escape_pod1/centcom,
	/area/shuttle/escape_pod2/centcom,
	/area/shuttle/escape_pod3/centcom,
	/area/shuttle/escape_pod5/centcom,
	/area/shuttle/transport1,
	/area/shuttle/administration/centcom,
	/area/shuttle/specops/centcom,
))


/**
 * MARK: Special event areas
 */

/area/special_event
	name = "Специальная ивент-зона"
	report_alerts = FALSE
	has_gravity = STANDARD_GRAVITY
	area_flags = NONE
	holomap_should_draw = FALSE

/area/special_event/alpha
	name = "Специальная ивент-зона — Альфа"
	icon_state = "away1"

/area/special_event/beta
	name = "Специальная ивент-зона — Бета"
	icon_state = "away2"

/area/special_event/gamma
	name = "Специальная ивент-зона — Гамма"
	icon_state = "away3"

/area/special_event/delta
	name = "Специальная ивент-зона — Дельта"
	icon_state = "away4"

/area/special_event/epsilon
	name = "Специальная ивент-зона — Эпсилон"
	icon_state = "away5"

/**
 * MARK: Space area
 */

/area/ruin/space/bubblegum_arena
	name = "Арена Бубльгума"


/area/ruin/USSP_SpaceBanya
	name = "Заброшенная космическая баня"
	icon_state = "barstation"

/**
 * MARK: Pirate base
 */

/area/ruin/space/pirate_base
	name = "Пиратская база"
	icon_state = "unknown"

/area/ruin/space/pirate_base/arrivals
	name = "Пиратская база — пункт прибытия"
	icon_state = "awaycontent1"

/area/ruin/space/pirate_base/atrium
	name = "Пиратская база — тюремный атриум"
	icon_state = "awaycontent2"

/area/ruin/space/pirate_base/kitchen
	name = "Пиратская база — тюремная кухня"
	icon_state = "awaycontent3"

/area/ruin/space/pirate_base/mining
	name = "Пиратская база — тюремный шахтёрский пункт"
	icon_state = "awaycontent4"

/area/ruin/space/pirate_base/prison_maint
	name = "Пиратская база — технические тоннели тюрьмы"
	icon_state = "awaycontent5"

/area/ruin/space/pirate_base/entertainment
	name = "Пиратская база — тюремный развлекательный центр"
	icon_state = "awaycontent6"

/area/ruin/space/pirate_base/security_atrium
	name = "Пиратская база — атриум СБ"
	icon_state = "awaycontent7"

/area/ruin/space/pirate_base/security_maint
	name = "Пиратская база — технические тоннели СБ"
	icon_state = "awaycontent8"

/area/ruin/space/pirate_base/security_medical
	name = "Пиратская база — лазарет СБ"
	icon_state = "awaycontent9"

/area/ruin/space/pirate_base/observ
	name = "Пиратская база — наблюдательный пункт"
	icon_state = "awaycontent10"

/area/ruin/space/pirate_base/lab_sec
	name = "Пиратская база — СБ лаборатории"
	icon_state = "awaycontent11"

/area/ruin/space/pirate_base/lab_hall
	name = "Пиратская база — проход к лаборатории"
	icon_state = "awaycontent12"

/area/ruin/space/pirate_base/laboratory
	name = "Пиратская база — лаборатория"
	icon_state = "awaycontent13"

/area/ruin/space/pirate_base/lab_medical
	name = "Пиратская база — медпункт лаборатории"
	icon_state = "awaycontent14"

/area/ruin/space/pirate_base/lab_maint
	name = "Пиратская база — технические тоннели лаборатории"
	icon_state = "awaycontent15"

/area/ruin/space/pirate_base/atmos
	name = "Пиратская база — атмосферный отсек тюрьмы"
	icon_state = "awaycontent16"

/area/ruin/space/pirate_base/xeno_lab
	name = "Пиратская база — лаборатория ксенобиологии"
	icon_state = "awaycontent17"

/area/ruin/space/pirate_base/virus_lab
	name = "Пиратская база — лаборатория вирусологии"
	icon_state = "awaycontent18"

/area/ruin/space/pirate_base/virology
	name = "Пиратская база — \"Отсек вирусологии ЛП7\""
	icon_state = "awaycontent19"

/area/ruin/space/pirate_base/prison_solar
	name = "Пиратская база — солчечная батарея тюрьмы"
	icon_state = "awaycontent20"

/area/ruin/space/pirate_base/lab_solar
	name = "Пиратская база — солнечная батарея лаборатории"
	icon_state = "awaycontent21"

/area/ruin/space/pirate_base/telecomms
	name = "Пиратская база — пункт телекоммуникации"
	icon_state = "awaycontent22"

/area/ruin/space/pirate_base/black_market
	name = "Пиратская база — чёрный рынок"
	icon_state = "awaycontent23"

