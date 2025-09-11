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
	base_lighting_color = COLOR_WHITE
	base_lighting_alpha = 255
	hide_attacklogs = TRUE
	has_gravity = STANDARD_GRAVITY
	area_flags = NONE


/area/adminconstruction
	name = "Тестовая зона администрации"
	icon_state = "start"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_color = COLOR_WHITE
	base_lighting_alpha = 255
	hide_attacklogs = TRUE
	has_gravity = STANDARD_GRAVITY
	area_flags = NONE

/area/space
	icon_state = "space"
	requires_power = TRUE
	always_unpowered = TRUE
	static_lighting = FALSE
	base_lighting_color = COLOR_WHITE
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
	use_starlight = FALSE
	static_lighting = TRUE
	ambientsounds = list('sound/ambience/ambimine.ogg')
	sound_environment = SOUND_AREA_ASTEROID

/area/space/atmosalert()
	return

/area/space/firealert(obj/source)
	return

/area/space/firereset(obj/source)
	return

//These are shuttle areas, they must contain two areas in a subgroup if you want to move a shuttle from one
//place to another. Look at escape shuttle for example.
//All shuttles show now be under shuttle since we have smooth-wall code.

/area/shuttle
	no_teleportlocs = TRUE
	requires_power = FALSE
	valid_territory = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = TRUE
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
	name = "Шаттл спецсил"
	icon_state = "shuttlered"

/area/shuttle/specops/station
	name = "Шаттл спецсил"
	icon_state = "shuttlered2"

/area/shuttle/syndicate_elite
	name = "Элитный шаттл Синдиката"
	icon_state = "shuttlered"
	nad_allowed = TRUE
	parallax_movedir = SOUTH
	area_flags = NONE

/area/shuttle/syndicate_elite/mothership
	name = "Элитный шаттл Синдиката"
	icon_state = "shuttlered"

/area/shuttle/syndicate_elite/station
	name = "Элитный шаттл Синдиката"
	icon_state = "shuttlered2"

/area/shuttle/syndicate_sit
	name = "Шаттл Диверсионного отряда Синдиката"
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
	name = "Судно Нанотрезйен"
	icon_state = "shuttlered"
	parallax_movedir = WEST
	area_flags = NONE

/area/shuttle/administration/centcom
	name = "Судно Нанотрезйен (Центком)"
	icon_state = "shuttlered"

/area/shuttle/administration/station
	name = "Судно Нанотрезйен"
	icon_state = "shuttlered2"

/area/shuttle/thunderdome
	name = "хонк"
	area_flags = NONE

/area/shuttle/thunderdome/grnshuttle
	name = "Тандердом – ЗЛН шаттл"
	icon_state = "green"

/area/shuttle/thunderdome/grnshuttle/dome
	name = "ЗЛН шаттл"
	icon_state = "shuttlegrn"

/area/shuttle/thunderdome/grnshuttle/station
	name = "ЗЛН станция"
	icon_state = "shuttlegrn2"

/area/shuttle/thunderdome/redshuttle
	name = "Тандердом – КРС шаттл"
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
	icon_state = "shuttle"

/area/shuttle/vox
	name = "Скипджек воксов"
	icon_state = "shuttle"
	area_flags = NONE

/area/shuttle/vox/station
	name = "Скипджек воксов"
	icon_state = "yellow"

/area/shuttle/salvage
	name = "Судно спасателей"
	icon_state = "yellow"
	area_flags = NONE

/area/shuttle/salvage/start
	name = "Посреди Ничего"
	icon_state = "yellow"

/area/shuttle/salvage/arrivals
	name = "Дополнительный док Космической Станции"
	icon_state = "yellow"

/area/shuttle/salvage/derelict
	name = "Заброшенная станция"
	icon_state = "yellow"

/area/shuttle/salvage/djstation
	name = "Русская диджей-станция"
	icon_state = "yellow"

/area/shuttle/salvage/north
	name = "Север станции"
	icon_state = "yellow"

/area/shuttle/salvage/east
	name = "Восток станции"
	icon_state = "yellow"

/area/shuttle/salvage/south
	name = "Юг станции"
	icon_state = "yellow"

/area/shuttle/salvage/commssat
	name = "Коммуникационный спутник"
	icon_state = "yellow"

/area/shuttle/salvage/mining
	name = "Юго-запад шахтёрского астероида"
	icon_state = "yellow"

/area/shuttle/salvage/abandoned_ship
	name = "Заброшенное судно"
	icon_state = "yellow"

/area/shuttle/salvage/clown_asteroid
	name = "Клоунский астероид"
	icon_state = "yellow"

/area/shuttle/salvage/trading_post
	name = "Торговый пункт"
	icon_state = "yellow"

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
	name = "Шаттл отряда \"Атом\" Синдиката"
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
	base_lighting_color = COLOR_WHITE
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
	base_lighting_color = COLOR_WHITE
	base_lighting_alpha = 255
	nad_allowed = TRUE
	has_gravity = STANDARD_GRAVITY
	area_flags = NONE

// New CC
/area/centcom/bridge
	name = "Центком – мостик"
	icon_state = "centcom_bridge"

/area/centcom/court
	name = "Центком – зал суда"
	icon_state = "centcom_court"

/area/centcom/ferry
	name = "Центком – Ferry Shuttle"
	icon_state = "centcom_ferry"

/area/centcom/gamma
	name = "Центком – арсенал \"Гамма\""
	icon_state = "centcom_gamma"

/area/centcom/supply
	name = "Центком – шаттл снабжения"
	icon_state = "centcom_supply"

/area/centcom/jail
	name = "Центком – тюрьма"
	icon_state = "centcom_jail"

/area/centcom/zone3
	name = "Центком – зона 3"
	icon_state = "centcom_zone3"

/area/centcom/zone2
	name = "Центком – зона 2"
	icon_state = "centcom_zone2"

/area/centcom/zone1
	name = "Центком – зона 1"
	icon_state = "centcom_zone1"

/area/centcom/evac
	name = "Центком – эвакуационный шаттл"
	icon_state = "centcom_evac"
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE

/area/centcom/specops
	name = "Центком – крыло Сил специального назначения"
	icon_state = "centcom_specops"

/area/centcom/srtops
	name = "Центком – крыло Отряда специального реагирования"
	icon_state = "centcom_srtops"

/area/centcom/blops
	name = "Центком – крыло Отряда теневых операций"
	icon_state = "centcom_blops"

/area/centcom/shuttle
	name = "Центком – шаттл администрации"

/area/centcom/supplypod/supplypod_temp_holding
	name = "Пункт отправки капсул снабжения"
	icon_state = "supplypod_flight"
	area_flags = UNIQUE_AREA

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
	name = "Центком – ангар №1"
	loading_id = "1"

/area/centcom/supplypod/loading/two
	name = "Центком – ангар №2"
	loading_id = "2"

/area/centcom/supplypod/loading/three
	name = "Центком – ангар №3"
	loading_id = "3"

/area/centcom/supplypod/loading/four
	name = "Центком – ангар №4"
	loading_id = "4"

/area/centcom/supplypod/loading/ert
	name = "Центком – ангар ОБР"
	loading_id = "5"

/**
 * MARK: SYNDICATES
 */

/area/syndicate_mothership
	name = "ПБ Синдиката"
	icon_state = "syndie-ship"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE
	nad_allowed = TRUE
	ambientsounds = HIGHSEC_SOUNDS
	area_flags = NONE

/area/syndicate_mothership/outside
	name = "ПБ Синдиката – внешняя территория"
	static_lighting = FALSE
	base_lighting_color = COLOR_WHITE
	base_lighting_alpha = 255
	icon_state = "syndie-outside"

/area/syndicate_mothership/control
	name = "ПБ Синдиката – комната управления"
	icon_state = "syndie-control"

/area/syndicate_mothership/elite_squad
	name = "ПБ Синдиката – крыло Элитного отряда"
	icon_state = "syndie-elite"

/area/syndicate_mothership/infteam
	name = "ПБ Синдиката – крыло Лазутчиков"
	icon_state = "syndie-infiltrator"

/area/syndicate_mothership/jail
	name = "ПБ Синдиката – тюрьма"
	icon_state = "syndie-jail"

/area/syndicate_mothership/cargo
	name = "ПБ Синдиката – отдел снабжения"
	icon_state = "syndie-cargo"

/**
 * MARK: USSP
 */

/area/ussp_ship
	name = "Судно СССП \"Проект 28У\""
	icon_state = "ussp_ship"
	requires_power = TRUE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE
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
	base_lighting_color = COLOR_WHITE
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
	base_lighting_color = COLOR_WHITE
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
	name = "Астероид – подземелье"
	icon_state = "cave"
	requires_power = FALSE
	outdoors = TRUE
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/area/asteroid/artifactroom
	name = "Астероид – артефакт"
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
	base_lighting_color = COLOR_WHITE
	base_lighting_alpha = 255
	hide_attacklogs = TRUE
	area_flags = NONE


/area/tdome/arena_source
	name = "Тандедом – шаблон арены"
	icon_state = "thunder"

/area/tdome/arena
	name = "Тандедом – арена"
	icon_state = "thunder"

/area/tdome/tdome1
	name = "Тандедом – команда 1"
	icon_state = "green"

/area/tdome/tdome2
	name = "Тандедом – команда 2"
	icon_state = "yellow"

/area/tdome/tdomeadmin
	name = "Тандедом – администрация"
	icon_state = "purple"

/area/tdome/tdomeobserve
	name = "Тандедом – зрители"
	icon_state = "purple"

/area/tdome/newtdome
	name = "Тандедом – новая арена"
	icon_state = "thunder"

/area/tdome/newtdome/CQC
	name = "Тандедом – новая арена (ближний бой)"
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
	base_lighting_color = COLOR_WHITE

/area/ninja
	name = "Клан Паука – родитель для зон"
	icon_state = "ninjabase"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	no_teleportlocs = TRUE
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR
	nad_allowed = TRUE
	area_flags = NONE

/area/ninja/outpost
	name = "Клан Паука – додзё"
	icon_state = "ninja_dojo"

/area/ninja/holding
	name = "Клан Паука – пункт содержания"
	icon_state = "ninja_holding"
	ambientsounds = list('sound/ambience/ambifailure.ogg', 'sound/ambience/ambigen4.ogg', 'sound/ambience/ambimaint2.ogg', 'sound/ambience/ambimystery.ogg', 'sound/ambience/ambitech2.ogg')

/area/ninja/outside
	name = "Клан Паука – внешняя территория"
	icon_state = "ninja_outside"
	static_lighting = FALSE
	base_lighting_color = COLOR_WHITE
	base_lighting_alpha = 255
	sound_environment = SOUND_AREA_ASTEROID

/area/vox_station
	name = "База воксов"
	icon_state = "yellow"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_color = COLOR_WHITE
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
	base_lighting_color = COLOR_WHITE
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
	base_lighting_color = COLOR_WHITE
	area_flags = NONE

/area/ussp_centcom/secretariat
	name = "Секретариат СССП"

/**
 * MARK: Labor camp
 */

/area/mine/laborcamp
	name = "Трудовой лагерь"
	icon_state = "brig"

/area/mine/laborcamp/security
	name = "Трудовой лагерь – пункт охраны"
	icon_state = "security"

/**
 * MARK: STATION13
 */

/area/atmos
	name = "Атмосферный отсек"
	icon_state = "atmos"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/atmos/control
	name = "Атмосферный отсек – комната управления"
	icon_state = "atmos"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/atmos/distribution
	name = "Атмосферный отсек – распределительный контур"
	icon_state = "atmos"

/area/atmos/break_room
	name = "Атмосферный отсек – фойе"
	icon_state = "atmos"

/**
 * MARK: MAINTENANCE
 */

/area/maintenance
	ambientsounds = MAINTENANCE_SOUNDS
	valid_territory = FALSE
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/maintenance/ai
	name = "Технические тоннели – спутник ИИ"
	icon_state = "green"

/area/maintenance/fore //should be refactored
	name = "Технические тоннели – северные"
	icon_state = "fmaint"

/area/maintenance/fore2
	name = "Технические тоннели – северные вторичные"
	icon_state = "fmaint"

/area/maintenance/aft
	name = "Технические тоннели – западные"
	icon_state = "amaint"

/area/maintenance/aft2
	name = "Технические тоннели – западные вторичные"
	icon_state = "amaint"

/area/maintenance/fpmaint
	name = "Технические тоннели – северо-западные"
	icon_state = "fpmaint"

/area/maintenance/fsmaint
	name = "Технические тоннели – дормитории"
	icon_state = "fsmaint"

/area/maintenance/fsmaint2
	name = "Технические тоннели – бар"
	icon_state = "fsmaint"

/area/maintenance/fsmaint3
	name = "Технические тоннели – восток Отдела снабжения"
	icon_state = "fsmaint"

/area/maintenance/fsmaint4
	name = "Технические тоннели – север Отдела снабжения"
	icon_state = "fsmaint"

/area/maintenance/tourist
	name = "Технические тоннели – туристическая зона"
	icon_state = "fsmaint"

/area/maintenance/asmaint
	name = "Технические тоннели – Медицинский отдел"
	icon_state = "asmaint"

/area/maintenance/asmaint2
	name = "Технические тоннели – НИО"
	icon_state = "asmaint"

/area/maintenance/asmaint3
	name = "Технические тоннели – НИО вторичные"
	icon_state = "asmaint"

/area/maintenance/asmaint4
	name = "Технические тоннели – вирусология"
	icon_state = "asmaint"

/area/maintenance/asmaint5
	name = "Технические тоннели – пункт прибытия"
	icon_state = "asmaint"

/area/maintenance/asmaint6
	name = "Технические тоннели – комната отдыха НИО"
	icon_state = "asmaint"

/area/maintenance/apmaint
	name = "Технические тоннели – Отдел снабжения"
	icon_state = "apmaint"

/area/maintenance/apmaint2
	name = "Технические тоннели – юго-западные"
	icon_state = "apmaint"

/area/maintenance/maintcentral
	name = "Технические тоннели – мостик"
	icon_state = "central"

/area/maintenance/maintcentral2
	name = "Технические тоннели – центральные вторичные"
	icon_state = "maintcentral"

/area/maintenance/starboard
	name = "Технические тоннели – восточные"
	icon_state = "smaint"

/area/maintenance/starboard2
	name = "Технические тоннели – восточные вторичные"
	icon_state = "smaint"

/area/maintenance/port
	name = "Технические тоннели – западные"
	icon_state = "pmaint"

/area/maintenance/port2
	name = "Технические тоннели – западные вторичные"
	icon_state = "pmaint"

/area/maintenance/brig
	name = "Технические тоннели – бриг"
	icon_state = "pmaint"

/area/maintenance/perma
	name = "Технические тоннели – пермабриг"
	icon_state = "green"

/area/maintenance/atmospherics
	name = "Технические тоннели – атмосферный отсек"
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
	name = "Опечатанная комната – юго-западная"

/area/maintenance/disposal/south
	name = "Опечатанная комната – южная"

/area/maintenance/disposal/east
	name = "Опечатанная комната – восточная"

/area/maintenance/disposal/northeast
	name = "Опечатанная комната – северо-восточная"

/area/maintenance/disposal/north
	name = "Опечатанная комната – северная"

/area/maintenance/disposal/northwest
	name = "Опечатанная комната – северо-западная"

/area/maintenance/disposal/west
	name = "Опечатанная комната – западная"

/area/maintenance/disposal/westalt
	name = "Опечатанная комната – западная вторичная"

/area/maintenance/disposal/external/southwest
	name = "Внешний мусоропровод – юго-запад"

/area/maintenance/disposal/external/southeast
	name = "Внешний мусоропровод – юго-восток"

/area/maintenance/disposal/external/east
	name = "Внешний мусоропровод – восток"

/area/maintenance/disposal/external/north
	name = "Внешний мусоропровод – север"

/area/maintenance/genetics
	name = "Технические тоннели – генетика"
	icon_state = "asmaint"

/area/maintenance/electrical
	name = "Технические тоннели – отсек электрики"
	icon_state = "elec"

/area/maintenance/engineering
	name = "Технические тоннели – инженерия"
	icon_state = "green"

/area/maintenance/bar
	name = "Технические тоннели – заброшенный бар"
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
	name = "Строительная зона – альтернативная"
	icon_state = "construction"

/area/maintenance/consarea_virology
	name = "Virology Maintenance Construction Area"
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
	icon_state = "quart"

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
	name = "Технические тоннели – Закулисье"
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
	name = "Технические тоннели (цокольный этаж) – Командование"

/area/maintenance/cele/cargo
	name = "Технические тоннели (цокольный этаж) – Отдел снабжения"

/area/maintenance/cele/medbay
	name = "Технические тоннели (цокольный этаж) – Медицинский отдел"

/area/maintenance/cele/servise
	name = "Технические тоннели (цокольный этаж) – Отдел обслуживания"

/area/maintenance/cele/engineering
	name = "Технические тоннели (цокольный этаж) – Инженерный отдел"

/area/maintenance/cele/arrival
	name = "Технические тоннели (цокольный этаж) – пункт прибытия"

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
	name = "Основной проход – командование"
	icon_state = "hallC"

/area/hallway/primary/command/north
/area/hallway/primary/command/south
/area/hallway/primary/command/west
/area/hallway/primary/command/east
/area/hallway/primary/command/nw
/area/hallway/primary/command/ne

/area/hallway/primary/central/second
	name = "Основной центральный проход – второй этаж"
	icon_state = "hallC"

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
	name = "Мост – стыковка-медотсек"

/area/hallway/spacebridge/scidock
	name = "Мост – НИО-стыковка"

/area/hallway/spacebridge/somsec
	name = "Мост – командование-СБ"

/area/hallway/spacebridge/sersec
	name = "Мост – обслуживание-СБ"

/area/hallway/spacebridge/engdock
	name = "Мост – инженерия-стыковка"

/area/hallway/spacebridge/servsci
	name = "Мост – обслуживание-НИО"

/area/hallway/spacebridge/serveng
	name = "Мост – НИО-инженерия"

/area/hallway/spacebridge/engmed
	name = "Мост – инженерия-медотсек"

/area/hallway/spacebridge/medcargo
	name = "Мост – медотсек-снабжение"

/area/hallway/spacebridge/cargocom
	name = "Мост – снабжение-ИИ-командование"

/area/hallway/spacebridge/sercom
	name = "Мост – командование-обслуживание"

/area/hallway/spacebridge/comeng
	name = "Мост – командование-инженерия"

/area/hallway/spacebridge/comcar
	name = "Мост – командование-снабжение"

/area/hallway/secondary/exit
	name = "Проход к эвакуационному шаттлу"
	icon_state = "escape"
	holomap_color = HOLOMAP_AREACOLOR_ESCAPE

/area/hallway/secondary/exit/maint
	name = "Заброшенный проход к эвакуационному шаттлу"
	icon_state = "escape"
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
	name = "Проход к пункту прибытия – восточный"

/area/hallway/secondary/entry/westarrival
	name = "Проход к пункту прибытия – западный"

/area/hallway/secondary/entry/additional
	name = "Проход к пункту прибытия – западный дополнительный"

/area/hallway/secondary/entry/commercial
	name = "Проход к пункту прибытия – западный торговый"

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

/area/crew_quarters
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/crew_quarters/captain
	name = "Офис Капитана"
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/crew_quarters/captain/bedroom
	name = "Спальня Капитана"
	icon_state = "captain"

/area/crew_quarters/recruit
	name = "Офис по подбору персонала"
	icon_state = "head_quarters"

/area/crew_quarters/heads/hop
	name = "Каюта Главы Персонала"
	icon_state = "head_quarters"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/crew_quarters/heads/hor
	name = "Каюта Научного Руководителя"
	icon_state = "head_quarters"
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE

/area/crew_quarters/heads/chief
	name = "Каюта Главного Инженера"
	icon_state = "head_quarters"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/crew_quarters/heads/hos
	name = "Каюта Главы Службы Безопасности"
	icon_state = "head_quarters"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/crew_quarters/heads/cmo
	name = "Каюта Главного Врача"
	icon_state = "head_quarters"
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
	name = "Центком – доки"
	icon_state = "centcom"

/area/bridge/checkpoint
	name = "КПП командования"
	icon_state = "bridge"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/bridge/checkpoint/north
	name = "КПП командования – северный"
	icon_state = "bridge"

/area/bridge/checkpoint/south
	name = "КПП командования – южный"
	icon_state = "bridge"


/**
 * MARK: CREW
 */

/area/crew_quarters
	name = "Дормитории"
	icon_state = "Sleep"
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_DORMS

/area/crew_quarters/serviceyard
	name = "Крыло Отдела обслуживания"
	icon_state = "Sleep"

/area/crew_quarters/cabin1
	name = "Жилая каюта №1"

/area/crew_quarters/cabin2
	name = "Жилая каюта №2"

/area/crew_quarters/cabin3
	name = "Жилая каюта №3"

/area/crew_quarters/cabin4
	name = "Жилая каюта №4"

/area/crew_quarters/toilet
	name = "Уборная – дормитории"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/crew_quarters/toilet2
	name = "Уборная – западная"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/crew_quarters/toilet3
	name = "Уборная – театр"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/crew_quarters/toilet4
	name = "Уборная – пункт прибытия"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_ARRIVALS

/area/crew_quarters/sleep
	name = "Дормитории"
	icon_state = "Sleep"
	valid_territory = FALSE

/area/crew_quarters/sleep/secondary
	name = "Дормитории – вторичные"
	icon_state = "Sleep"

/area/crew_quarters/sleep_male
	name = "Жилая каюта – мужская"
	icon_state = "Sleep"

/area/crew_quarters/sleep_male/toilet_male
	name = "Мужская уборная"
	icon_state = "toilet"

/area/crew_quarters/sleep_female
	name = "Женская уборная"
	icon_state = "Sleep"

/area/crew_quarters/sleep_female/toilet_female
	name = "Женская уборная"
	icon_state = "toilet"

/area/crew_quarters/locker
	name = "Раздевалка"
	icon_state = "locker"

/area/crew_quarters/locker/locker_toilet
	name = "Уборная – раздевалка"
	icon_state = "toilet"

/area/crew_quarters/fitness
	name = "Фитнесс-зал"
	icon_state = "fitness"

/area/crew_quarters/dorms
	name = "Дормитории"
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
	name = "Игровая библиотеки"
	icon_state = "library"

/area/chapel
	icon_state = "chapel"
	ambientsounds = HOLY_SOUNDS
	is_haunted = TRUE
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/chapel/main
	name = "Церковь"

/area/chapel/office
	name = "Церковь – офис Священника"
	icon_state = "chapeloffice"

/area/chapel/morgue
	name = "Церковь – морг"

/area/chapel/massdriver
	name = "Церковь – ускоритель частиц"

/area/escapepodbay
	name = "Проход к эвакуационному шаттлу – ангар для челноков"
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
	name = "Офис клоуна"
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
	base_lighting_color = COLOR_WHITE
	base_lighting_alpha = 255
	holomap_color = HOLOMAP_AREACOLOR_DORMS

/area/holodeck/alphadeck
	name = "Голопалуба альфа"


/area/holodeck/source_plating
	name = "Голопалуба – неактивная"
	icon_state = "Holodeck"

/area/holodeck/source_emptycourt
	name = "Голопалуба – пустая комната"

/area/holodeck/source_boxingcourt
	name = "Голопалуба – бойцовский ринг"

/area/holodeck/source_basketball
	name = "Голопалуба – баскетбольная площадка"

/area/holodeck/source_thunderdomecourt
	name = "Голопалуба – тандердом"

/area/holodeck/source_beach
	name = "Голопалуба – пляж"
	icon_state = "Holodeck"

/area/holodeck/source_burntest
	name = "Голопалуба – тест атмосферного горения"

/area/holodeck/source_wildlife
	name = "Голопалуба – симуляция пожара"

/area/holodeck/source_meetinghall
	name = "Голопалуба – конференц-зал"

/area/holodeck/source_theatre
	name = "Голопалуба – театр"

/area/holodeck/source_picnicarea
	name = "Голопалуба – место для пикника"

/area/holodeck/source_snowfield
	name = "Голопалуба – снежное поле"

/area/holodeck/source_desert
	name = "Голопалуба – пустыня"

/area/holodeck/source_space
	name = "Голопалуба – космос"

/area/holodeck/source_knightarena
	name = "Голопалуба – рыцарская арена"

/**
 * MARK: ENGINEERING
 */

/area/engineering
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/engineering/engine/smes
	name = "Engineering SMES"
	icon_state = "engine_smes"

/area/engineering/engine
	name = "Engineering"
	icon_state = "engine_smes"

/area/engineering/engine/monitor
	name = "Engineering Monitoring Room"
	icon_state = "engine_control"

/area/engineering/break_room
	name = "Engineering Foyer"
	icon_state = "engine"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/engineering/aienter
	name = "AI Sattelit Access Point"
	icon_state = "engine"

/area/engineering/equipmentstorage
	name = "Engineering Equipment Storage"
	icon_state = "storage"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/engineering/hardsuitstorage
	name = "Engineering Hardsuit Storage"
	icon_state = "storage"

/area/engineering/controlroom
	name = "Engineering Control Room"
	icon_state = "engine_control"

/area/engineering/gravitygenerator
	name = "Gravity Generator"
	icon_state = "engine"

/area/engineering/chiefs_office
	name = "Chief Engineer's Офис "
	icon_state = "engine_control"

/area/engineering/mechanic_workshop
	name = "Mechanic Workshop"
	icon_state = "engine"
	holomap_color = HOLOMAP_AREACOLOR_HANGAR

/area/engineering/mechanic_workshop/expedition
	name = "Hangar Expedition"
	icon_state = "engine"

/area/engineering/mechanic_workshop/hangar
	name = "Hangаr Bay"
	icon_state = "engine"

/area/engineering/supermatter
	name = "Supermatter Engine"
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
	base_lighting_color = COLOR_WHITE
	base_lighting_alpha = 255

/area/solar/auxport
	name = "North-West Solar Array"
	icon_state = "panelsA"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/solar/auxstarboard
	name = "North-East Solar Array"
	icon_state = "panelsA"

/area/solar/fore
	name = "North Solar Array"
	icon_state = "yellow"

/area/solar/aft
	name = "South Solar Array"
	icon_state = "aft"

/area/solar/starboardaux
	name = "East Solar Array"
	icon_state = "panelsS"

/area/solar/starboard
	name = "South-East Solar Array"
	icon_state = "panelsS"

/area/solar/west
	name = "West Solar Array"
	icon_state = "panelsS"

/area/solar/port
	name = "South-West Solar Array"
	icon_state = "panelsP"

/area/maintenance/auxsolarport
	name = "North-West Solar Технические тоннели – "
	icon_state = "SolarcontrolA"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/north_solars
	name = "North Solar Технические тоннели – "
	icon_state = "SolarcontrolA"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/starboardaux
	name = "East Solar Технические тоннели – "
	icon_state = "SolarcontrolS"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/starboardsolar
	name = "South-East Solar Технические тоннели – "
	icon_state = "SolarcontrolS"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/portsolar
	name = "South-West Solar Технические тоннели – "
	icon_state = "SolarcontrolP"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/auxsolarstarboard
	name = "North-East Solar Технические тоннели – "
	icon_state = "SolarcontrolA"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/west_solars
	name = "West Solar Технические тоннели – "
	icon_state = "SolarcontrolA"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/assembly
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE

/area/assembly/chargebay
	name = "Mech Bay"
	icon_state = "mechbay"

/area/assembly/showroom
	name = "Robotics Showroom"
	icon_state = "showroom"

/area/assembly/robotics
	name = "Robotics Lab"
	icon_state = "ass_line"

/area/assembly/assembly_line //Derelict Assembly Line
	name = "Assembly Line"
	icon_state = "ass_line"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/**
 * MARK: Teleporter
 */

/area/teleporter
	name = "Teleporter"
	icon_state = "teleporter"
	ambientsounds = ENGINEERING_SOUNDS
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/teleporter/research
	name = "Robotics Teleporter"

/area/teleporter/abandoned
	name = "Заброшенный Teleporter"
	icon_state = "teleporter"
	ambientsounds = ENGINEERING_SOUNDS
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/teleporter/quantum
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/area/teleporter/quantum/security
	name = "Security Quantum Pad"

/area/teleporter/quantum/docking
	name = "Docking Quantum Pad"

/area/teleporter/quantum/science
	name = "Science Quantum Pad"

/area/teleporter/quantum/cargo
	name = "Cargo Quantum Pad"

/area/teleporter/quantum/comand
	name = "Comand Quantum Pad"

/area/teleporter/quantum/service
	name = "Service Quantum Pad"

/area/teleporter/quantum/medbay
	name = "Medical Quantum Pad"

/area/teleporter/quantum/engi
	name = "Engineering Quantum Pad"

/area/gateway
	name = "Gateway"
	icon_state = "teleporter"
	ambientsounds = ENGINEERING_SOUNDS
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/AIsattele
	name = "Unknown Teleporter"
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
	name = "Medbay"
	icon_state = "medbay"

//Medbay is a large area, these additional areas help level out APC load. wtf dude, nobody use THIS MUCH ZONES
/area/medical/medbay2
	name = "Medbay"
	icon_state = "medbay2"

/area/medical/medbay3
	name = "Medbay"
	icon_state = "medbay3"


/area/medical/biostorage
	name = "Medical Storage"
	icon_state = "medbaysecstorage"

/area/medical/reception
	name = "Medbay Reception"
	icon_state = "medbay"

/area/medical/psych
	name = "Psych Room"
	icon_state = "medbaypsych"

/area/medical/medbreak
	name = "Break Room"
	icon_state = "medbaybreak"

/area/medical/medrest
	name = "Med Restroom"
	icon_state = "medbaybreak"

/area/medical/patients_rooms
	name = "Patient's Rooms"
	icon_state = "patients"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/medical/ward
	name = "Medbay Patient Ward"
	icon_state = "patientsward"

/area/medical/patient_a
	name = "Isolation A"
	icon_state = "medbayisoa"

/area/medical/patient_b
	name = "Isolation B"
	icon_state = "medbayisob"

/area/medical/patient_c
	name = "Isolation C"
	icon_state = "medbayisoc"

/area/medical/iso_access
	name = "Isolation Access"
	icon_state = "medbayisoaccess"

/area/medical/cmo
	name = "Chief Medical Officer's Офис "
	icon_state = "CMO"

/area/medical/cmostore
	name = "Medical Secondary Storage"
	icon_state = "medbaysecstorage"

/area/medical/robotics //why
	name = "Robotics"
	icon_state = "research"

/area/medical/research
	name = "Research Division"
	icon_state = "research"
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE

/area/medical/research/nhallway
	name = "RnD North проход"
	icon_state = "research"

/area/medical/research/shallway
	name = "RnD South проход"
	icon_state = "research"

/area/medical/research/restroom
	name = "RnD Restroom"
	icon_state = "research"

/area/medical/virology
	name = "Virology"
	icon_state = "virology"

/area/medical/virology/lab
	name = "Virology Laboratory"
	icon_state = "virology"

/area/medical/morgue
	name = "Morgue"
	icon_state = "morgue"
	ambientsounds = SPOOKY_SOUNDS
	is_haunted = TRUE
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/medical/chemistry
	name = "Chemistry"
	icon_state = "chem"

/area/medical/surgery
	name = "Surgery"
	icon_state = "surgery"

/area/medical/surgery/north
	name = "Surgery 1"
	icon_state = "surgery1"

/area/medical/surgery/south
	name = "Surgery 2"
	icon_state = "surgery2"

/area/medical/surgery/theatre
	name = "Surgery Theatre"
	icon_state = "surgery_theatre"

/area/medical/surgeryobs
	name = "Surgery Observation"
	icon_state = "surgery"

/area/medical/cryo
	name = "Cryogenics"
	icon_state = "cryo"

/area/medical/exam_room
	name = "Exam Room"
	icon_state = "exam_room"

/area/medical/genetics
	name = "Genetics Lab"
	icon_state = "genetics"

/area/medical/cloning
	name = "Cloning Lab"
	icon_state = "cloning"

/area/medical/sleeper
	name = "Medical Treatment Center"
	icon_state = "exam_room"

/area/medical/paramedic
	name = "Paramedic"
	icon_state = "medbay"

/**
 * MARK: Security
 */

/area/security
	ambientsounds = HIGHSEC_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/security/main
	name = "Security Office"
	icon_state = "securityoffice"

/area/security/lobby
	name = "Security Lobby"
	icon_state = "securitylobby"

/area/security/brig
	name = "Brig"
	icon_state = "brig"

/area/security/brig/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = 0
		temp_closet.update_icon()
	for(var/obj/machinery/door_timer/temp_timer in machinery_cache)
		temp_timer.releasetime = 1
	..()

/area/security/permabrig
	name = "Prison Wing"
	icon_state = "sec_prison_perma"
	fast_despawn = TRUE
	can_get_auto_cryod = FALSE

/area/security/prison
	name = "Prison Wing"
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
	name = "Prison Cell Block"
	icon_state = "brig"

/area/security/prison/cell_block/A
	name = "Prison Cell Block A"
	icon_state = "brigcella"

/area/security/prison/cell_block/B
	name = "Prison Cell Block B"
	icon_state = "brigcellb"

/area/security/prison/cell_block/C
	name = "Prison Cell Block C"
	icon_state = "brig"

/area/security/reception
	name = "Brig Reception"
	icon_state = "brig"

/area/security/execution
	name = "Execution"
	icon_state = "execution"
	can_get_auto_cryod = FALSE

/area/security/permahallway
	name = "Permabrig проход"
	icon_state = "sec_prison_perma"

/area/security/processing
	name = "Prisoner Processing"
	icon_state = "prisonerprocessing"
	can_get_auto_cryod = FALSE

/area/security/holding_cell
	name = "Temporary Holding Cell"
	icon_state = "holdingcell"

/area/security/interrogation
	name = "Interrogation"
	icon_state = "interrogation"
	can_get_auto_cryod = FALSE

/area/security/seceqstorage
	name = "Security Equipment Storage"
	icon_state = "securityequipmentstorage"

/area/security/brigstaff
	name = "Brig Staff Room"
	icon_state = "brig"

/area/security/interrogationhallway
	name = "Interrogation проход"
	icon_state = "interrogationhall"

/area/security/courtroomdandp
	name = "Courtroom Defense and Prosecution"
	icon_state = "seccourt"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/security/interrogationobs
	name = "Interrogation Observation"
	icon_state = "security"
	can_get_auto_cryod = FALSE

/area/security/evidence
	name = "Evidence Room"
	icon_state = "evidence"

/area/security/visiting_room
	name = "Visiting Room"
	icon_state = "visiting-room"

/area/security/prisonlockers
	name = "Prisoner Lockers"
	icon_state = "sec_prison_lockers"
	can_get_auto_cryod = FALSE

/area/security/medbay
	name = "Security Medbay"
	icon_state = "security_medbay"

/area/security/prisonershuttle
	name = "Security Prisoner Shuttle"
	icon_state = "security"
	can_get_auto_cryod = FALSE

/area/security/warden
	name = "Warden's Офис "
	icon_state = "Warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/security/armory
	name = "Armory"
	icon_state = "armory"

/area/security/securearmory
	name = "Secure Armory"
	icon_state = "secarmory"

/area/security/securehallway
	name = "Brig Secure проход"
	icon_state = "securehall"

/area/security/hos
	name = "Head of Security's Офис "
	icon_state = "sec_hos"

/area/security/podbay
	name = "Security Podbay"
	icon_state = "securitypodbay"

/area/security/detectives_office
	name = "Detective's Офис "
	icon_state = "detective"
	ambientsounds = list('sound/ambience/ambidet1.ogg', 'sound/ambience/ambidet2.ogg')

/area/security/range
	name = "Firing Range"
	icon_state = "firingrange"

/area/security/nuke_storage
	name = "Vault"
	icon_state = "nuke_storage"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/security/customs
	name = "Customs"
	icon_state = "checkpoint1"

/area/security/customs2
	name = "Customs"
	icon_state = "security"

/area/security/checkpoint
	name = "Security Checkpoint"
	icon_state = "checkpoint1"

/area/security/checkpoint2
	name = "Security Checkpoint"
	icon_state = "checkpoint1"

/area/security/checkpoint/south
	name = "Escape Security Checkpoint"
	icon_state = "security"

/area/security/checkpoint/supply
	name = "Security Post - Cargo Bay"
	icon_state = "checkpoint1"

/area/security/checkpoint/engineering
	name = "Security Post - Engineering"
	icon_state = "checkpoint1"

/area/security/checkpoint/medical
	name = "Security Post - Medbay"
	icon_state = "checkpoint1"

/area/security/checkpoint/science
	name = "Security Post - Science"
	icon_state = "checkpoint1"

/area/quartermaster
	name = "Quartermasters"
	icon_state = "quart"
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_CARGO

/area/quartermaster/sorting
	name = "Delivery Office"
	icon_state = "quartstorage"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/quartermaster/office
	name = "Cargo Office"
	icon_state = "quartoffice"

/area/quartermaster/lobby
	name = "Cargo Lobby"
	icon_state = "quartoffice"

/area/quartermaster/delivery
	name = "Cargo Delivery"
	icon_state = "quartoffice"

/area/quartermaster/storage
	name = "Cargo Bay"
	icon_state = "quartstorage"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/quartermaster/qm
	name = "Quartermaster's Офис "
	icon_state = "quart"

/area/quartermaster/miningdock
	name = "Mining Dock"
	icon_state = "mining"

/area/quartermaster/miningstorage
	name = "Mining Storage"
	icon_state = "green"

/area/quartermaster/mechbay
	name = "Mech Bay"
	icon_state = "yellow"

/area/janitor
	name = "Custodial Closet"
	icon_state = "janitor"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/maintenance/garden
	name = "Old Garden"
	icon_state = "hydro"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/area/maintenance/garden/north
	name = "North Old Garden"
	icon_state = "hydro"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/area/maintenance/kitchen
	name = "Old Restaurant"
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
	name = "Research and Development"
	icon_state = "toxlab"

/area/toxins/hallway
	name = "Research Lab"
	icon_state = "toxlab"

/area/toxins/rdoffice
	name = "Research Director's Офис "
	icon_state = "head_quarters"

/area/toxins/xenobiology
	name = "Xenobiology Lab"
	icon_state = "toxmix"
	xenobiology_compatible = TRUE

/area/toxins/xenobiology/xenoflora_storage
	name = "Xenoflora Storage"
	icon_state = "toxlab"

/area/toxins/xenobiology/xenoflora
	name = "Xenoflora Lab"
	icon_state = "toxlab"

/area/toxins/storage
	name = "Toxins Storage"
	icon_state = "toxstorage"

/area/toxins/test_area
	name = "Toxins Test Area"
	icon_state = "toxtest"
	valid_territory = FALSE

/area/toxins/mixing
	name = "Toxins Mixing Room"
	icon_state = "toxmix"

/area/toxins/launch
	name = "Toxins Launch Room"
	icon_state = "toxlaunch"

/area/toxins/misc_lab
	name = "Research Testing Lab"
	icon_state = "toxmisc"

/area/toxins/test_chamber
	name = "Research Testing Chamber"
	icon_state = "toxtest"

/area/toxins/server
	name = "Server Room"
	icon_state = "server"

/area/toxins/server_coldroom
	name = "Server Coldroom"
	icon_state = "servercold"

/area/toxins/explab
	name = "Experimentation Lab"
	icon_state = "toxmisc"

/area/toxins/sm_test_chamber
	name = "Supermatter Testing Lab"
	icon_state = "toxtest"
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/toxins/explab
	name = "E.X.P.E.R.I-MENTOR Lab"
	icon_state = "toxmisc"

/area/toxins/explab_chamber
	name = "E.X.P.E.R.I-MENTOR Chamber"
	icon_state = "toxmisc"

/**
 * MARK: Storage
 */

/area/storage
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/area/storage/tools
	name = "Auxiliary Tool Storage"
	icon_state = "storage"

/area/storage/primary
	name = "Primary Tool Storage"
	icon_state = "primarystorage"

/area/storage/autolathe
	name = "Autolathe Storage"
	icon_state = "storage"

/area/storage/art
	name = "Art Supply Storage"
	icon_state = "storage"

/area/storage/auxillary
	name = "Auxillary Storage"
	icon_state = "auxstorage"

/area/storage/eva
	name = "EVA Storage"
	icon_state = "eva"
	ambientsounds = HIGHSEC_SOUNDS
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/storage/secure
	name = "Secure Storage"
	icon_state = "storage"
	ambientsounds = HIGHSEC_SOUNDS
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/storage/emergency
	name = "East Emergency Storage"
	icon_state = "emergencystorage"
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/storage/emergency2
	name = "West Emergency Storage"
	icon_state = "emergencystorage"
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/storage/tech
	name = "Technical Storage"
	icon_state = "auxstorage"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/storage/office
	name = "Office Supplies"
	icon_state = "office_supplies"
	holomap_color = HOLOMAP_AREACOLOR_DORMS

/**
 * MARK: DJSTATION
 */

/area/djstation
	name = "Ruskie DJ Station"
	icon_state = "DJ"
	area_flags = UNIQUE_AREA
	has_gravity = STANDARD_GRAVITY

/area/djstation/solars
	name = "Ruskie DJ Station Solars"
	icon_state = "DJ"

/**
 * MARK: DERELICT
 */

/area/derelict
	name = "Derelict Station"
	icon_state = "storage"
	has_gravity = STANDARD_GRAVITY

/area/derelict/hallway/primary
	name = "Derelict Primary проход"
	icon_state = "hallP"

/area/derelict/hallway/secondary
	name = "Derelict Secondary проход"
	icon_state = "hallS"

/area/derelict/arrival
	name = "Derelict Arrival Centre"
	icon_state = "yellow"

/area/derelict/church
	name = "Derelict Church"
	icon_state = "chapel"

/area/derelict/common
	name = "Derelict Common Area"
	icon_state = "crew_quarters"

/area/derelict/asteroidbelt
	name = "Derelict Asteroids"
	icon_state = "mining"
	requires_power = FALSE
	has_gravity = FALSE

/area/derelict/med
	name = "Derelict Medbay"
	icon_state = "medbay"

/area/derelict/garden
	name = "Derelict Hydroponics"
	icon_state = "hydro"

/area/derelict/dining
	name = "Derelict Dining room"
	icon_state = "kitchen"

/area/derelict/dock
	name = "Derelict Docking Area"
	icon_state = "ntrep"

/area/derelict/security
	name = "Derelict Security Area"
	icon_state = "blue"

/area/derelict/rnd
	name = "Derelict Research Area"
	icon_state = "purple"

/area/derelict/engineer_area
	name = "Derelict Engineering Area"
	icon_state = "engine_control"

/area/derelict/storage/equipment
	name = "Derelict Equipment Storage"

/area/derelict/storage/storage_access
	name = "Derelict Storage Access"

/area/derelict/storage/engine_storage
	name = "Derelict Engine Storage"
	icon_state = "green"

/area/derelict/bridge
	name = "Derelict Control Room"
	icon_state = "bridge"

/area/derelict/secret
	name = "Derelict Secret Room"
	icon_state = "library"

/area/derelict/bridge/access
	name = "Derelict Control Room Access"
	icon_state = "auxstorage"

/area/derelict/bridge/ai_upload
	name = "Derelict Computer Core"
	icon_state = "ai"

/area/derelict/solar_control
	name = "Derelict Solar Control"
	icon_state = "engine"

/area/derelict/se_solar
	name = "South East Solars"
	icon_state = "engine"

/area/derelict/crew_quarters
	name = "Derelict Crew Quarters"
	icon_state = "fitness"

/area/derelict/medical
	name = "Derelict Medbay"
	icon_state = "medbay"

/area/derelict/medical/morgue
	name = "Derelict Morgue"
	icon_state = "morgue"
	is_haunted = TRUE

/area/derelict/medical/chapel
	name = "Derelict Chapel"
	icon_state = "chapel"
	is_haunted = TRUE

/area/derelict/teleporter
	name = "Derelict Teleporter"
	icon_state = "teleporter"
	area_flags = UNIQUE_AREA

/area/derelict/annex
	name = "Derelict Annex"
	icon_state = "eva"

/area/shuttle/derelict/ship/start
	name = "Заброшенный Ship"
	icon_state = "yellow"

/area/shuttle/derelict/ship/transit
	name = "Заброшенный Ship"
	icon_state = "yellow"

/area/shuttle/derelict/ship/engipost
	name = "Engineering Outpost"
	icon_state = "yellow"

/area/shuttle/derelict/ship/station
	name = "North of SS13"
	icon_state = "yellow"

/area/solar/derelict_starboard
	name = "Derelict East Solar Array"
	icon_state = "panelsS"

/area/solar/derelict_aft
	name = "Derelict South Solar Array"
	icon_state = "aft"

/area/derelict/singularity_engine
	name = "Derelict Singularity Engine"
	icon_state = "engine"

/area/derelict/gravity_generator
	name = "Derelict Gravity Generator Room"
	icon_state = "red"

/area/derelict/atmospherics
	name = "Derelict Atmospherics"
	icon_state = "red"
/**
 * MARK: Construction
 */
/area/construction
	name = "Construction Area"
	icon_state = "yellow"
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/construction/hallway
	name = "Hallway"
	icon_state = "yellow"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/construction/solars
	name = "Solar Panels"
	icon_state = "yellow"

/**
 * MARK: GAYBAR
 */

/area/secret/gaybar
	name = "Dance Bar"
	icon_state = "dancebar"

/**
 * MARK: AI
 */

/area/turret_protected
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/turret_protected/ai_upload
	name = "AI Upload Chamber"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/turret_protected/ai_upload_foyer
	name = "AI Upload Access"
	icon_state = "ai_foyer"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/turret_protected/ai
	name = "AI Chamber"
	icon_state = "ai_chamber"

/area/turret_protected/aisat
	name = "AI Satellite"
	icon_state = "ai"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/aisat
	name = "AI Satellite проход"
	icon_state = "yellow"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/aisat/aihallway
	name = "AI Satellite Exterior проход"
	icon_state = "yellow"
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/aisat/entrance
	name = "AI Satellite Entrance"
	icon_state = "ai_foyer"

/area/aisat/maintenance
	name = "AI Satellite Service"
	icon_state = "storage"

/area/aisat/atmospherics
	name = "AI Satellite Atmospherics"
	icon_state = "storage"

/area/turret_protected/aisat_interior
	name = "AI Satellite Antechamber"
	icon_state = "ai"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/turret_protected/aisat_interior/secondary
	name = "AI Satellite Secondary Antechamber"

/**
 * MARK: Telecommunications Satellite
 */

/area/tcommsat
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambitech.ogg',\
											'sound/ambience/ambitech2.ogg', 'sound/ambience/ambitech3.ogg', 'sound/ambience/ambimystery.ogg')
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/tcommsat/chamber
	name = "Telecoms Central Compartment"
	icon_state = "tcomms"

// These areas are needed for MetaStation's AI sat
/area/turret_protected/tcomsat
	name = "Telecoms Satellite"
	icon_state = "tcomms"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/turret_protected/tcomfoyer
	name = "Telecoms Foyer"
	icon_state = "tcomms"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/turret_protected/tcomwest
	name = "Telecoms West Wing"
	icon_state = "tcomms"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/turret_protected/tcomeast
	name = "Telecoms East Wing"
	icon_state = "tcomms"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/tcommsat/computer
	name = "Telecoms Control Room"
	icon_state = "tcomms"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/tcommsat/server
	name = "Telecoms Server Room"
	icon_state = "tcomms"

/area/tcommsat/lounge
	name = "Telecoms Lounge"
	icon_state = "tcomms"

/area/tcommsat/powercontrol
	name = "Telecoms Power Control"
	icon_state = "tcomms"

/**
 * MARK: Away missions
 */

/area/awaymission
	name = "Strange Location"
	icon_state = "away"
	report_alerts = FALSE
	has_gravity = STANDARD_GRAVITY
	ambientsounds = AWAY_MISSION_SOUNDS
	sound_environment = SOUND_ENVIRONMENT_ROOM
	area_flags = NONE

/area/awaymission/example
	name = "Strange Station"
	icon_state = "away"

/area/awaymission/desert
	name = "Sudden Drop"
	icon_state = "away"

/area/awaymission/beach
	name = "Beach"
	icon_state = "beach"
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE
	requires_power = FALSE
	ambientsounds = list('sound/ambience/shore.ogg', 'sound/ambience/seag1.ogg', 'sound/ambience/seag2.ogg', 'sound/ambience/seag2.ogg', 'sound/ambience/ambiodd.ogg', 'sound/ambience/ambinice.ogg')

/area/awaymission/undersea
	name = "Undersea"
	icon_state = "undersea"


// area for AWAY "moonoutpost19"
/area/moonoutpost19
	name = "moonoutpost"
	has_gravity = STANDARD_GRAVITY
	report_alerts = FALSE
	area_flags = NONE
	holomap_should_draw = FALSE

/area/moonoutpost19/mo19arrivals
	name = "MO19 Arrivals"
	icon_state = "awaycontent1"

/area/moonoutpost19/mo19research
	name = "MO19 Research"
	icon_state = "awaycontent2"

/area/moonoutpost19/khonsu19
	name = "Khonsu 19"
	icon_state = "awaycontent3"
	always_unpowered = TRUE
	ambientsounds = list('sound/ambience/ambimine.ogg')
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	poweralm = FALSE
	outdoors = TRUE
	area_flags = NONE

/area/moonoutpost19/syndicateoutpost
	name = "Syndicate Outpost"
	icon_state = "awaycontent4"

/area/moonoutpost19/hive
	name = "The Hive"
	icon_state = "awaycontent5"
	always_unpowered = TRUE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	poweralm = FALSE

/area/moonoutpost19/mo19utilityroom
	name = "MO19 Utility Room"
	icon_state = "awaycontent6"

//area for AWAY "aeterna13"
/area/ae13
	icon_state = "ae13"
	always_unpowered = TRUE
	requires_power = TRUE
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
 * MARK: AWAY AREAS/
 */

/area/awaycontent
	name = "space"
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

/**
 * MARK: Centcom
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
	name = "Special event area"
	icon_state = "unknown"
	requires_power = TRUE
	static_lighting = TRUE
	report_alerts = FALSE
	has_gravity = STANDARD_GRAVITY
	area_flags = NONE
	holomap_should_draw = FALSE

/area/special_event/alpha
	name = "Special event area Alpha"
	icon_state = "away1"

/area/special_event/beta
	name = "Special event area Beta"
	icon_state = "away2"

/area/special_event/gamma
	name = "Special event area Gamma"
	icon_state = "away3"

/area/special_event/delta
	name = "Special event area Delta"
	icon_state = "away4"

/area/special_event/epsilon
	name = "Special event area Epsilon"
	icon_state = "away5"

/**
 * MARK: Space area
 */

/area/ruin/space/bubblegum_arena
	name = "Bubblegum Arena"


/area/ruin/USSP_SpaceBanya
	name = "Space_abandoned_banya"
	icon_state = "barstation"

/**
 * MARK: Pirate base
 */

/area/ruin/space/pirate_base
	name = "pirates base "
	icon_state = "unknown"

/area/ruin/space/pirate_base/arrivals
	name = "Unknown Arrivals"
	icon_state = "awaycontent1"

/area/ruin/space/pirate_base/atrium
	name = "Prison Atrium"
	icon_state = "awaycontent2"

/area/ruin/space/pirate_base/kitchen
	name = "Prison Kitchen"
	icon_state = "awaycontent3"

/area/ruin/space/pirate_base/mining
	name = "Prison Mining"
	icon_state = "awaycontent4"

/area/ruin/space/pirate_base/prison_maint
	name = "Prison Технические тоннели – "
	icon_state = "awaycontent5"

/area/ruin/space/pirate_base/entertainment
	name = "Prison Entertainment"
	icon_state = "awaycontent6"

/area/ruin/space/pirate_base/security_atrium
	name = "Security Atrium"
	icon_state = "awaycontent7"

/area/ruin/space/pirate_base/security_maint
	name = "Technical Security zone"
	icon_state = "awaycontent8"

/area/ruin/space/pirate_base/security_medical
	name = "Medical and Storage"
	icon_state = "awaycontent9"

/area/ruin/space/pirate_base/observ
	name = "Observation Point"
	icon_state = "awaycontent10"

/area/ruin/space/pirate_base/lab_sec
	name = "Laboratory Security"
	icon_state = "awaycontent11"

/area/ruin/space/pirate_base/lab_hall
	name = "Laboratory проход"
	icon_state = "awaycontent12"

/area/ruin/space/pirate_base/laboratory
	name = "Laboratory"
	icon_state = "awaycontent13"

/area/ruin/space/pirate_base/lab_medical
	name = "Medical Bay"
	icon_state = "awaycontent14"

/area/ruin/space/pirate_base/lab_maint
	name = "Laboratory Технические тоннели – "
	icon_state = "awaycontent15"

/area/ruin/space/pirate_base/atmos
	name = "Prison Atmos"
	icon_state = "awaycontent16"

/area/ruin/space/pirate_base/xeno_lab
	name = "Xeno Lab"
	icon_state = "awaycontent17"

/area/ruin/space/pirate_base/virus_lab
	name = "Virus TestLab"
	icon_state = "awaycontent18"

/area/ruin/space/pirate_base/virology
	name = "LP7 Virology"
	icon_state = "awaycontent19"

/area/ruin/space/pirate_base/prison_solar
	name = "Prison Solar"
	icon_state = "awaycontent20"

/area/ruin/space/pirate_base/lab_solar
	name = "Labor Solar"
	icon_state = "awaycontent21"

/area/ruin/space/pirate_base/telecomms
	name = "Telecomms"
	icon_state = "awaycontent22"

/area/ruin/space/pirate_base/black_market
	name = "Black Market"
	icon_state = "awaycontent23"

/**
 * MARK: Malta event map
 */

/area/ruin/unpowered/coldcolony_outside
	name = "Surface"
	always_unpowered = TRUE
	ignore_gravgen = TRUE
	outdoors = TRUE

/area/coldcolony
	name = "coldcolony"
	icon_state = "unknown"
	holomap_should_draw = FALSE
	has_gravity = TRUE
	ignore_gravgen = TRUE

/area/coldcolony/ruin
	name = "ruin"
	icon_state = "unknown"

/area/coldcolony/ruin/sm_division
	name = "Заброшенный SM Research Division"
	icon_state = "research"

/area/coldcolony/ruin/sm_maintenance
	name = "Заброшенный SM Технические тоннели – "
	icon_state = "asmaint"

/area/coldcolony/ruin/sm_lab
	name = "Заброшенный SM Laboratory"
	icon_state = "toxlab"

/area/coldcolony/ruin/sm_chamber
	name = "Заброшенный SM Chamber"
	icon_state = "toxtest"

/area/coldcolony/ruin/abandoned_banya
	name = "Заброшенный Banya"
	icon_state = "barstation"

/area/coldcolony/ruin/syndie_outpost
	name = "Syndicate Recruiter Outpost"
	icon_state = "red"

/area/coldcolony/ruin/abandoned_house
	name = "House"
	icon_state = "red"

/area/coldcolony/ruin/abandoned_garage
	name = "Mech Garage"
	icon_state = "mining"

/**
 * MARK: Malta
 */

/area/coldcolony/malta
	name = "malta"
	icon_state = "unknown"
	holomap_should_draw = TRUE
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/coldcolony/malta/outer
	name = "outer"

/area/coldcolony/malta/outer/roadblock
	name = "Roadblock"
	icon_state = "entry"
	holomap_color = HOLOMAP_AREACOLOR_ARRIVALS

/**
 * MARK: Malta cargo
 */

/area/coldcolony/malta/quartermaster
	name = "Quartermasters"
	icon_state = "quart"
	holomap_color = HOLOMAP_AREACOLOR_CARGO

/area/coldcolony/malta/quartermaster/miningbar
	name = "Miner's bar"
	icon_state = "mining_living"

/area/coldcolony/malta/quartermaster/ore_production
	name = "Mining Production"
	icon_state = "mining_production"

/area/coldcolony/malta/quartermaster/miningeva
	name = "Mining EVA"
	icon_state = "mining_eva"

/area/coldcolony/malta/quartermaster/mining_post1
	name = "Mining"
	icon_state = "mining"

/area/coldcolony/malta/quartermaster/sorting
	name = "Delivery Office"
	icon_state = "quartstorage"

/area/coldcolony/malta/quartermaster/storage
	name = "Cargo Bay"
	icon_state = "quartstorage"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/coldcolony/malta/quartermaster/office
	name = "Cargo Office"
	icon_state = "quartoffice"

/area/coldcolony/malta/quartermaster/qm
	name = "Quartermaster's Офис "
	icon_state = "quart"

/**
 * MARK: Malta other
 */

/area/coldcolony/malta/chapel
	icon_state = "chapel"
	ambientsounds = HOLY_SOUNDS
	is_haunted = TRUE
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/coldcolony/malta/chapel/main
	name = "Chapel"

/area/coldcolony/malta/chapel/office
	name = "Церковь – Office"
	icon_state = "chapeloffice"

/area/coldcolony/malta/escape_toilet
	name = "Arrivals Уборная – "
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_ARRIVALS

/area/coldcolony/malta/civilian
	holomap_color = HOLOMAP_AREACOLOR_DORMS

/area/coldcolony/malta/civilian/vacantoffice
	name = "Vacant Office"
	icon_state = "green"

/area/coldcolony/malta/civilian/trading
	name = "Заброшенный Tradiders Room"
	icon_state = "blue"
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/coldcolony/malta/civilian/mrchangs
	name = "Mr Chang's"
	icon_state = "Theatre"
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/**
 * MARK: Malta residental
 */

/area/coldcolony/malta/resid_serv
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/coldcolony/malta/resid_serv/crew_quarters
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
	icon_state = "Sleep"
	holomap_color = HOLOMAP_AREACOLOR_DORMS

/area/coldcolony/malta/resid_serv/crew_quarters/cabin1
	name = "First Жилая каюта №"

/area/coldcolony/malta/resid_serv/crew_quarters/cabin2
	name = "Second Жилая каюта №"

/area/coldcolony/malta/resid_serv/crew_quarters/sleep
	name = "Dormitories"
	valid_territory = FALSE

/area/coldcolony/malta/resid_serv/crew_quarters/fitness
	name = "Fitness Room"
	icon_state = "fitness"

/area/coldcolony/malta/resid_serv/crew_quarters/locker
	name = "Locker Room"
	icon_state = "locker"

/area/coldcolony/malta/resid_serv/crew_quarters/locker_toilet
	name = "Locker Уборная – "
	icon_state = "toilet"

/area/coldcolony/malta/resid_serv/crew_quarters/barber
	name = "Barber Shop"
	icon_state = "barber"

/area/coldcolony/malta/resid_serv/crew_quarters/theatre
	name = "Theatre"
	icon_state = "Theatre"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/coldcolony/malta/resid_serv/clownoffice
	name = "Clown's Офис "
	icon_state = "clown_office"
	sound_environment = SOUND_ENVIRONMENT_PADDED_CELL

/area/coldcolony/malta/resid_serv/mimeoffice
	name = "Mime's Офис "
	icon_state = "mime_office"

/area/coldcolony/malta/resid_serv/bar
	name = "Bar"
	icon_state = "barstation"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/coldcolony/malta/resid_serv/bar/atrium
	name = "Atrium"
	icon_state = "bar"

/area/coldcolony/malta/resid_serv/janitor
	name = "Custodial Closet"
	icon_state = "janitor"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/coldcolony/malta/resid_serv/library
	name = "Library"
	icon_state = "library"
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR

/area/coldcolony/malta/resid_serv/library/game_zone
	name = "Library Games Room"
	icon_state = "library"

/area/coldcolony/malta/resid_serv/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/coldcolony/malta/resid_serv/kitchen
	name = "Kitchen"
	icon_state = "kitchen"

/**
 * MARK: Malta hallways
 */

/area/coldcolony/malta/hallway
	valid_territory = FALSE
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/area/coldcolony/malta/hallway/service
	icon_state = "hallP"

/area/coldcolony/malta/hallway/bridge
	name = "Command Entrance"
	icon_state = "hallC"

/area/coldcolony/malta/hallway/cargo_escape
	icon_state = "hallS"

/area/coldcolony/malta/hallway/service/north
	name = "North Service Entrance"

/area/coldcolony/malta/hallway/service/nw
	name = "Заброшенный Service проход"

/area/coldcolony/malta/hallway/service/central
	name = "Central Service проход"

/area/coldcolony/malta/hallway/service/east
	name = "East Service проход"

/area/coldcolony/malta/hallway/service/south
	name = "South Service Entrance"

/area/coldcolony/malta/hallway/cargo_escape/north
	name = "North Escape проход"

/area/coldcolony/malta/hallway/cargo_escape/exit
	name = "Escape Shuttle проход"
	icon_state = "escape"
	holomap_color = HOLOMAP_AREACOLOR_ESCAPE

/area/coldcolony/malta/hallway/cargo_escape/entrance
	name = "Escape Entrance"

/area/coldcolony/malta/hallway/cargo_escape/port
	icon_state = "entry"

/area/coldcolony/malta/hallway/cargo_escape/port/west
	name = "Port Commercial West проход"

/area/coldcolony/malta/hallway/cargo_escape/port/central
	name = "Port Central проход"

/area/coldcolony/malta/hallway/cargo_escape/port/east
	name = "Port East проход"

/**
 * MARK: Malta maintenance
 */

/area/coldcolony/malta/maintenance
	ambientsounds = MAINTENANCE_SOUNDS
	valid_territory = FALSE
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/coldcolony/malta/maintenance/incinerator
	name = "Incinerator"
	icon_state = "disposal"

/area/coldcolony/malta/maintenance/kitchen
	name = "Old Restaurant"
	icon_state = "kitchen"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/area/coldcolony/malta/maintenance/garden
	name = "Old Garden"
	icon_state = "hydro"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/area/coldcolony/malta/maintenance/servicegen
	name = "Generator Service"
	icon_state = "fmaint"

/area/coldcolony/malta/maintenance/dormitory
	name = "Dormitory Технические тоннели – "
	icon_state = "fmaint"

/area/coldcolony/malta/maintenance/bar
	name = "Bar Технические тоннели – "
	icon_state = "fmaint"

/area/coldcolony/malta/maintenance/casino
	name = "Заброшенный Casino"
	icon_state = "yellow"

/area/coldcolony/malta/maintenance/brig
	name = "Brig Технические тоннели – "
	icon_state = "pmaint"

/area/coldcolony/malta/maintenance/medbay
	name = "Medbay Технические тоннели – "
	icon_state = "asmaint"

/area/coldcolony/malta/maintenance/bridge
	name = "Bridge Технические тоннели – "
	icon_state = "central"

/area/coldcolony/malta/maintenance/cargo
	name = "Cargo Технические тоннели – "
	icon_state = "apmaint"

/area/coldcolony/malta/maintenance/research
	name = "Research Технические тоннели – "
	icon_state = "asmaint"

/area/coldcolony/malta/maintenance/science
	name = "Science Технические тоннели – "
	icon_state = "asmaint"

/area/coldcolony/malta/maintenance/engineering
	name = "Engineering Технические тоннели – "
	icon_state = "green"

/area/coldcolony/malta/maintenance/perma
	name = "Prison Технические тоннели – "
	icon_state = "green"

/**
 * MARK: Malta medical
 */

/area/coldcolony/malta/medical
	ambientsounds = MEDICAL_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION
	min_ambience_cooldown = 90 SECONDS
	max_ambience_cooldown = 180 SECONDS
	holomap_color = HOLOMAP_AREACOLOR_MEDICAL

/area/coldcolony/malta/medical/morgue
	name = "Morgue"
	icon_state = "morgue"
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	poweralm = FALSE

/area/coldcolony/malta/medical/sleeper
	name = "Medical Treatment Center"
	icon_state = "exam_room"

/area/coldcolony/malta/medical/cmo
	name = "Chief Medical Officer's Офис "
	icon_state = "CMO"

/area/coldcolony/malta/medical/cmostore
	name = "Medical Secondary Storage"
	icon_state = "medbaysecstorage"

/area/coldcolony/malta/medical/medbay
	name = "Medbay"
	icon_state = "medbay"

/area/coldcolony/malta/medical/paramedic
	name = "Paramedic"
	icon_state = "medbay"

/area/coldcolony/malta/medical/chemistry
	name = "Chemistry"
	icon_state = "chem"

/area/coldcolony/malta/medical/surgery
	name = "Surgery"
	icon_state = "surgery"

/area/coldcolony/malta/medical/surgery/west
	name = "Surgery 1"
	icon_state = "surgery1"

/area/coldcolony/malta/medical/surgery/east
	name = "Surgery 2"
	icon_state = "surgery2"

/area/coldcolony/malta/medical/biostorage
	name = "Medical Storage"
	icon_state = "medbaysecstorage"

/area/coldcolony/malta/medical/genetics
	name = "Genetics Lab"
	icon_state = "genetics"

/area/coldcolony/malta/medical/virology
	name = "Virology Laboratory"
	icon_state = "virology"

/**
 * MARK: Malta security
 */

/area/coldcolony/malta/security
	ambientsounds = HIGHSEC_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/coldcolony/malta/security/lobby
	name = "Security Lobby"
	icon_state = "securitylobby"

/area/coldcolony/malta/security/magistrateoffice
	name = "Magistrate's Офис "
	icon_state = "magistrate"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/coldcolony/malta/security/reception
	name = "Brig Reception"
	icon_state = "brig"

/area/coldcolony/malta/security/brig
	name = "Brig"
	icon_state = "brig"

/area/coldcolony/malta/security/prison
	name = "Prison Wing"
	icon_state = "sec_prison"
	can_get_auto_cryod = FALSE

/area/coldcolony/malta/security/prison/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = FALSE
		temp_closet.update_icon()
	for(var/obj/machinery/door_timer/temp_timer in machinery_cache)
		temp_timer.releasetime = 1
	..()

/area/coldcolony/malta/security/prison/cell_block/A
	name = "Prison Cell Block A"
	icon_state = "brigcella"

/area/coldcolony/malta/security/customs
	name = "Customs"
	icon_state = "checkpoint1"

/area/coldcolony/malta/security/processing
	name = "Prisoner Processing"
	icon_state = "prisonerprocessing"
	can_get_auto_cryod = FALSE

/area/coldcolony/malta/security/detectives_office
	name = "Detective's Офис "
	icon_state = "detective"
	ambientsounds = list('sound/ambience/ambidet1.ogg', 'sound/ambience/ambidet2.ogg')

/area/coldcolony/malta/security/brigstaff
	name = "Brig Staff Room"
	icon_state = "brig"

/area/coldcolony/malta/security/medbay
	name = "Security Medbay"
	icon_state = "security_medbay"

/area/coldcolony/malta/security/evidence
	name = "Evidence Room"
	icon_state = "evidence"

/area/coldcolony/malta/security/hos
	name = "Head of Security's Офис "
	icon_state = "sec_hos"

/area/coldcolony/malta/security/main
	name = "Security Office"
	icon_state = "securityoffice"

/area/coldcolony/malta/security/securehallway
	name = "Brig Secure проход"
	icon_state = "securehall"

/area/coldcolony/malta/security/warden
	name = "Warden's Офис "
	icon_state = "Warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/coldcolony/malta/security/securearmory
	name = "Secure Armory"
	icon_state = "secarmory"

/area/coldcolony/malta/security/execution
	name = "Execution"
	icon_state = "execution"
	can_get_auto_cryod = FALSE

/area/coldcolony/malta/security/permahallway
	name = "Permabrig проход"
	icon_state = "sec_prison_perma"

/area/coldcolony/malta/security/permabrig
	name = "Prison Wing"
	icon_state = "sec_prison_perma"
	fast_despawn = TRUE
	can_get_auto_cryod = FALSE

/area/coldcolony/malta/security/checkpoint
	name = "Security Checkpoint"
	icon_state = "checkpoint1"

/**
 * MARK: Malta bridge
 */

/area/coldcolony/malta/bridge
	name = "Bridge"
	icon_state = "bridge"
	ambientsounds = list('sound/ambience/signal.ogg')
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/coldcolony/malta/bridge/nuke_storage
	name = "Vault"
	icon_state = "nuke_storage"

/area/coldcolony/malta/bridge/meeting_room
	name = "Heads of Staff Meeting Room"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/coldcolony/malta/bridge/hop
	name = "Head of Personnel's Кабинет"
	icon_state = "head_quarters"

/area/coldcolony/malta/bridge/ntrep
	name = "Nanotrasen Representative's Офис "
	icon_state = "ntrep"

/area/coldcolony/malta/bridge/vip
	name = "VIP Area"
	icon_state = "meeting"

/area/coldcolony/malta/bridge/blueshield
	name = "Blueshield's Офис "
	icon_state = "blueshield"

/area/coldcolony/malta/bridge/captain
	name = "Captain's Офис "
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/coldcolony/malta/bridge/captain/bedroom
	name = "Captain's Bedroom"
	icon_state = "captain"

/area/coldcolony/malta/bridge/tcomm
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambitech3.ogg', 'sound/ambience/ambimystery.ogg')
	name = "Telecoms Central Compartment"
	icon_state = "tcomms"

/area/coldcolony/malta/bridge/checkpoint
	name = "Command Checkpoint"
	icon_state = "bridge"

/**
 * MARK: Malta AI
 */

/area/coldcolony/malta/turret_protected
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/coldcolony/malta/turret_protected/ai_upload
	name = "AI Upload Chamber"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/coldcolony/malta/turret_protected/ai
	name = "AI Chamber"
	icon_state = "ai_chamber"

/area/coldcolony/malta/turret_protected/aisat
	name = "AI проход"
	icon_state = "ai"

/**
 * MARK: Malta research
 */

/area/coldcolony/malta/research
	name = "Research Division"
	icon_state = "research"
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE

/area/coldcolony/malta/research/lab
	name = "Research and Development"
	icon_state = "toxlab"

/area/coldcolony/malta/research/hor
	name = "Research Director's Офис "
	icon_state = "head_quarters"

/area/coldcolony/malta/research/chargebay
	name = "Mech Bay"
	icon_state = "mechbay"

/area/coldcolony/malta/research/hallway
	name = "RnD проход"
	icon_state = "research"

/area/coldcolony/malta/research/robotics
	name = "Robotics Lab"
	icon_state = "ass_line"

/area/coldcolony/malta/research/server
	name = "Server Room"
	icon_state = "server"

/area/coldcolony/malta/research/shallway
	name = "RnD South проход"
	icon_state = "research"

/area/coldcolony/malta/research/explab
	name = "Experimentation Lab"
	icon_state = "toxmisc"

/area/coldcolony/malta/research/test_chamber
	name = "Research Testing Chamber"
	icon_state = "toxtest"

/area/coldcolony/malta/research/storage
	name = "Toxins Storage"
	icon_state = "toxstorage"

/area/coldcolony/malta/research/xenobiology
	name = "Xenobiology Lab"
	icon_state = "toxmix"
	xenobiology_compatible = TRUE

/**
 * MARK: Malta engineering
 */

/area/coldcolony/malta/engineering
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/coldcolony/malta/engineering/break_room
	name = "Engineering Foyer"
	icon_state = "engine"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/coldcolony/malta/engineering/control
	name = "Атмосферный отсек – Control Room"
	icon_state = "atmos"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/coldcolony/malta/engineering/monitor
	name = "Engineering Monitoring Room"
	icon_state = "engine_control"

/area/coldcolony/malta/engineering/engine
	name = "Engineering SMES"
	icon_state = "engine_smes"

/area/coldcolony/malta/engineering/atmos
	name = "Атмосферный отсек –"
	icon_state = "atmos"

/area/coldcolony/malta/engineering/storage
	name = "Secure Storage"
	icon_state = "storage"
	ambientsounds = HIGHSEC_SOUNDS

/area/coldcolony/malta/engineering/chief
	name = "Chief Engineer's Офис "
	icon_state = "head_quarters"

/area/coldcolony/malta/engineering/teg
	name = "Engineering Thermo Generator"
	icon_state = "engine"
