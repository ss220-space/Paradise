/**
 * Malta event map
 */

/area/ruin/unpowered/coldcolony_outside
	name = "Внешняя территория"
	always_unpowered = TRUE
	ignore_gravgen = TRUE
	outdoors = TRUE

/area/coldcolony
	holomap_should_draw = FALSE
	has_gravity = TRUE
	ignore_gravgen = TRUE

/area/coldcolony/ruin
	name = "Руины"

/area/coldcolony/ruin/sm_division
	name = "Заброшенное исследовательское отделение Суперматерии"
	icon_state = "research"

/area/coldcolony/ruin/sm_maintenance
	name = "Заброшенная служба техобслуживания Суперматерии"
	icon_state = "asmaint"

/area/coldcolony/ruin/sm_lab
	name = "Заброшенная лаборатория Суперматерии"
	icon_state = "toxlab"

/area/coldcolony/ruin/sm_chamber
	name = "Заброшенная испытательная камера Суперматерии"
	icon_state = "toxtest"

/area/coldcolony/ruin/abandoned_banya
	name = "Заброшенная баня"
	icon_state = "barstation"

/area/coldcolony/ruin/syndie_outpost
	name = "Аванпост вербовщика Синдиката"
	icon_state = "red"

/area/coldcolony/ruin/abandoned_house
	name = "Дом"
	icon_state = "red"

/area/coldcolony/ruin/abandoned_garage
	name = "Механический гараж"
	icon_state = "mining"

//Malta
/area/coldcolony/malta
	name = "Мальта"
	holomap_should_draw = TRUE
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/coldcolony/malta/outer
	name = "Внешняя зона"

/area/coldcolony/malta/outer/roadblock
	name = "Блокпост"
	icon_state = "entry"
	holomap_color = HOLOMAP_AREACOLOR_ARRIVALS

//Malta Cargo
/area/coldcolony/malta/quartermaster
	name = "Складское управление"
	icon_state = "quart"
	holomap_color = HOLOMAP_AREACOLOR_CARGO

/area/coldcolony/malta/quartermaster/miningbar
	name = "Бар шахтёров"
	icon_state = "mining_living"

/area/coldcolony/malta/quartermaster/ore_production
	name = "Производство руды"
	icon_state = "mining_production"

/area/coldcolony/malta/quartermaster/miningeva
	name = "Шахтёрская ВАК"
	icon_state = "mining_eva"

/area/coldcolony/malta/quartermaster/mining_post1
	name = "Горные работы"
	icon_state = "mining"

/area/coldcolony/malta/quartermaster/sorting
	name = "Отдел доставки"
	icon_state = "quartstorage"

/area/coldcolony/malta/quartermaster/storage
	name = "Грузовой отсек"
	icon_state = "quartstorage"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/coldcolony/malta/quartermaster/office
	name = "Канцелярия грузового отдела"
	icon_state = "quartoffice"

/area/coldcolony/malta/quartermaster/qm
	name = "Кабинет квартирмейстера"

//Malta Other
/area/coldcolony/malta/chapel
	icon_state = "chapel"
	ambientsounds = HOLY_SOUNDS
	is_haunted = TRUE
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/coldcolony/malta/chapel/main
	name = "Часовня"

/area/coldcolony/malta/chapel/office
	name = "Канцелярия часовни"
	icon_state = "chapeloffice"

/area/coldcolony/malta/escape_toilet
	name = "Туалеты у прибытия"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_ARRIVALS

/area/coldcolony/malta/civilian
	holomap_color = HOLOMAP_AREACOLOR_DORMS

/area/coldcolony/malta/civilian/vacantoffice
	name = "Свободный офис"
	icon_state = "green"

/area/coldcolony/malta/civilian/trading
	name = "Заброшенная комната торговцев"
	icon_state = "blue"
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/coldcolony/malta/civilian/mrchangs
	name = "Mr Chang's"
	icon_state = "Theatre"
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

//Malta Residental
/area/coldcolony/malta/resid_serv
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/coldcolony/malta/resid_serv/crew_quarters
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
	icon_state = "Sleep"
	holomap_color = HOLOMAP_AREACOLOR_DORMS

/area/coldcolony/malta/resid_serv/crew_quarters/cabin1
	name = "Первая кабина"

/area/coldcolony/malta/resid_serv/crew_quarters/cabin2
	name = "Вторая кабина"

/area/coldcolony/malta/resid_serv/crew_quarters/sleep
	name = "Общежития"
	valid_territory = FALSE

/area/coldcolony/malta/resid_serv/crew_quarters/fitness
	name = "Тренажёрный зал"
	icon_state = "fitness"

/area/coldcolony/malta/resid_serv/crew_quarters/locker
	name = "Раздевалка"
	icon_state = "locker"

/area/coldcolony/malta/resid_serv/crew_quarters/locker_toilet
	name = "Туалеты раздевалки"
	icon_state = "toilet"

/area/coldcolony/malta/resid_serv/crew_quarters/barber
	name = "Парикмахерская"
	icon_state = "barber"

/area/coldcolony/malta/resid_serv/crew_quarters/theatre
	name = "Театр"
	icon_state = "Theatre"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/coldcolony/malta/resid_serv/clownoffice
	name = "Кабинет клоуна"
	icon_state = "clown_office"
	sound_environment = SOUND_ENVIRONMENT_PADDED_CELL

/area/coldcolony/malta/resid_serv/mimeoffice
	name = "Кабинет мима"
	icon_state = "mime_office"

/area/coldcolony/malta/resid_serv/bar
	name = "Бар"
	icon_state = "barstation"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/coldcolony/malta/resid_serv/bar/atrium
	name = "Атриум"
	icon_state = "bar"

/area/coldcolony/malta/resid_serv/janitor
	name = "Кладовая уборщика"
	icon_state = "janitor"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/coldcolony/malta/resid_serv/library
	name = "Библиотека"
	icon_state = "library"
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR

/area/coldcolony/malta/resid_serv/library/game_zone
	name = "Игровая комната библиотеки"

/area/coldcolony/malta/resid_serv/hydroponics
	name = "Гидропоника"
	icon_state = "hydro"

/area/coldcolony/malta/resid_serv/kitchen
	name = "Кухня"
	icon_state = "kitchen"

//Malta Hallways
/area/coldcolony/malta/hallway
	valid_territory = FALSE
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/area/coldcolony/malta/hallway/service
	icon_state = "hallP"

/area/coldcolony/malta/hallway/bridge
	name = "Вход в командный мостик"
	icon_state = "hallC"

/area/coldcolony/malta/hallway/cargo_escape
	icon_state = "hallS"

/area/coldcolony/malta/hallway/service/north
	name = "Северный служебный вход"

/area/coldcolony/malta/hallway/service/nw
	name = "Заброшенный служебный коридор"

/area/coldcolony/malta/hallway/service/central
	name = "Центральный служебный коридор"

/area/coldcolony/malta/hallway/service/east
	name = "Восточный служебный коридор"

/area/coldcolony/malta/hallway/service/south
	name = "Южный служебный вход"

/area/coldcolony/malta/hallway/cargo_escape/north
	name = "Северный эвакуационный коридор"

/area/coldcolony/malta/hallway/cargo_escape/exit
	name = "Коридор к эвакуационному челноку"
	icon_state = "escape"
	holomap_color = HOLOMAP_AREACOLOR_ESCAPE

/area/coldcolony/malta/hallway/cargo_escape/entrance
	name = "Вход в эвакуационную зону"

/area/coldcolony/malta/hallway/cargo_escape/port
	icon_state = "entry"

/area/coldcolony/malta/hallway/cargo_escape/port/west
	name = "Западный коммерческий коридор порта"

/area/coldcolony/malta/hallway/cargo_escape/port/central
	name = "Центральный коридор порта"

/area/coldcolony/malta/hallway/cargo_escape/port/east
	name = "Восточный коридор порта"

//Malta Maintenance
/area/coldcolony/malta/maintenance
	ambientsounds = MAINTENANCE_SOUNDS
	valid_territory = FALSE
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/coldcolony/malta/maintenance/incinerator
	name = "Инсинератор"
	icon_state = "disposal"

/area/coldcolony/malta/maintenance/kitchen
	name = "Старый ресторан"
	icon_state = "kitchen"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/area/coldcolony/malta/maintenance/garden
	name = "Старый сад"
	icon_state = "hydro"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/area/coldcolony/malta/maintenance/servicegen
	name = "Обслуживание генератора"
	icon_state = "fmaint"

/area/coldcolony/malta/maintenance/dormitory
	name = "Обслуживание общежитий"
	icon_state = "fmaint"

/area/coldcolony/malta/maintenance/bar
	name = "Обслуживание бара"
	icon_state = "fmaint"

/area/coldcolony/malta/maintenance/casino
	name = "Заброшенное казино"
	icon_state = "yellow"

/area/coldcolony/malta/maintenance/brig
	name = "Обслуживание карцера"
	icon_state = "pmaint"

/area/coldcolony/malta/maintenance/medbay
	name = "Обслуживание медотсека"
	icon_state = "asmaint"

/area/coldcolony/malta/maintenance/bridge
	name = "Обслуживание мостика"
	icon_state = "central"

/area/coldcolony/malta/maintenance/cargo
	name = "Обслуживание грузового отсека"
	icon_state = "apmaint"

/area/coldcolony/malta/maintenance/research
	name = "Обслуживание исследовательского отдела"
	icon_state = "asmaint"

/area/coldcolony/malta/maintenance/science
	name = "Обслуживание научного отдела"
	icon_state = "asmaint"

/area/coldcolony/malta/maintenance/engineering
	name = "Обслуживание инженерного отдела"
	icon_state = "green"

/area/coldcolony/malta/maintenance/perma
	name = "Обслуживание тюрьмы"
	icon_state = "green"

//Malta Medical
/area/coldcolony/malta/medical
	ambientsounds = MEDICAL_SOUNDS
	min_ambience_cooldown = 90 SECONDS
	max_ambience_cooldown = 180 SECONDS
	holomap_color = HOLOMAP_AREACOLOR_MEDICAL

/area/coldcolony/malta/medical/morgue
	name = "Морг"
	icon_state = "morgue"
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	poweralm = FALSE

/area/coldcolony/malta/medical/sleeper
	name = "Медицинский центр лечения"
	icon_state = "exam_room"

/area/coldcolony/malta/medical/cmo
	name = "Кабинет главного врача"
	icon_state = "CMO"

/area/coldcolony/malta/medical/cmostore
	name = "Дополнительное медицинское хранилище"
	icon_state = "medbaysecstorage"

/area/coldcolony/malta/medical/medbay
	name = "Медотсек"
	icon_state = "medbay"

/area/coldcolony/malta/medical/paramedic
	name = "Парамедики"
	icon_state = "medbay"

/area/coldcolony/malta/medical/chemistry
	name = "Химия"
	icon_state = "chem"

/area/coldcolony/malta/medical/surgery
	name = "Операционная"
	icon_state = "surgery"

/area/coldcolony/malta/medical/surgery/west
	name = "Операционная 1"
	icon_state = "surgery1"

/area/coldcolony/malta/medical/surgery/east
	name = "Операционная 2"
	icon_state = "surgery2"

/area/coldcolony/malta/medical/biostorage
	name = "Медицинское хранилище"
	icon_state = "medbaysecstorage"

/area/coldcolony/malta/medical/genetics
	name = "Лаборатория генетики"
	icon_state = "genetics"

/area/coldcolony/malta/medical/virology
	name = "Лаборатория вирусологии"
	icon_state = "virology"

//Malta Security
/area/coldcolony/malta/security
	ambientsounds = HIGHSEC_SOUNDS
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/coldcolony/malta/security/lobby
	name = "Лобби охраны"
	icon_state = "securitylobby"

/area/coldcolony/malta/security/magistrateoffice
	name = "Кабинет магистрата"
	icon_state = "magistrate"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/coldcolony/malta/security/reception
	name = "Приёмная карцера"
	icon_state = "brig"

/area/coldcolony/malta/security/brig
	name = "Карцер"
	icon_state = "brig"

/area/coldcolony/malta/security/prison
	name = "Тюремный блок"
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
	name = "Тюремный блок A"
	icon_state = "brigcella"

/area/coldcolony/malta/security/customs
	name = "Таможня"
	icon_state = "checkpoint1"

/area/coldcolony/malta/security/processing
	name = "Обработка заключённых"
	icon_state = "prisonerprocessing"
	can_get_auto_cryod = FALSE

/area/coldcolony/malta/security/detectives_office
	name = "Кабинет детектива"
	icon_state = "detective"
	ambientsounds = list('sound/ambience/ambidet1.ogg', 'sound/ambience/ambidet2.ogg')

/area/coldcolony/malta/security/brigstaff
	name = "Комната персонала карцера"
	icon_state = "brig"

/area/coldcolony/malta/security/medbay
	name = "Медотсек охраны"
	icon_state = "security_medbay"

/area/coldcolony/malta/security/evidence
	name = "Комната улик"
	icon_state = "evidence"

/area/coldcolony/malta/security/hos
	name = "Кабинет начальника охраны"
	icon_state = "sec_hos"

/area/coldcolony/malta/security/main
	name = "Офис охраны"
	icon_state = "securityoffice"

/area/coldcolony/malta/security/securehallway
	name = "Охраняемый коридор карцера"
	icon_state = "securehall"

/area/coldcolony/malta/security/warden
	name = "Кабинет начальника тюрьмы"
	icon_state = "Warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/coldcolony/malta/security/securearmory
	name = "Охраняемый арсенал"
	icon_state = "secarmory"

/area/coldcolony/malta/security/execution
	name = "Место казни"
	icon_state = "execution"
	can_get_auto_cryod = FALSE

/area/coldcolony/malta/security/permahallway
	name = "Коридор постоянной тюрьмы"
	icon_state = "sec_prison_perma"

/area/coldcolony/malta/security/permabrig
	name = "Тюремный блок"
	icon_state = "sec_prison_perma"
	fast_despawn = TRUE
	can_get_auto_cryod = FALSE

/area/coldcolony/malta/security/checkpoint
	name = "Контрольно-пропускной пункт охраны"
	icon_state = "checkpoint1"

//Malta Bridge
/area/coldcolony/malta/bridge
	name = "Командный мостик"
	icon_state = "bridge"
	ambientsounds = list('sound/ambience/signal.ogg')
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/coldcolony/malta/bridge/nuke_storage
	name = "Хранилище"
	icon_state = "nuke_storage"

/area/coldcolony/malta/bridge/meeting_room
	name = "Зал заседаний руководства"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/coldcolony/malta/bridge/hop
	name = "Квартира начальника персонала"
	icon_state = "head_quarters"

/area/coldcolony/malta/bridge/ntrep
	name = "Кабинет представителя Нанотрасен"
	icon_state = "ntrep"

/area/coldcolony/malta/bridge/vip
	name = "VIP-зона"
	icon_state = "meeting"

/area/coldcolony/malta/bridge/blueshield
	name = "Кабинет Blueshield"
	icon_state = "blueshield"

/area/coldcolony/malta/bridge/captain
	name = "Кабинет капитана"
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/coldcolony/malta/bridge/captain/bedroom
	name = "Спальня капитана"

/area/coldcolony/malta/bridge/tcomm
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambitech3.ogg', 'sound/ambience/ambimystery.ogg')
	name = "Центральный отсек связи"
	icon_state = "tcomms"

/area/coldcolony/malta/bridge/checkpoint
	name = "Командный контрольно-пропускной пункт"

//Malta AI
/area/coldcolony/malta/turret_protected
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/coldcolony/malta/turret_protected/ai_upload
	name = "Камера загрузки ИИ"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/coldcolony/malta/turret_protected/ai
	name = "Камера ИИ"
	icon_state = "ai_chamber"

/area/coldcolony/malta/turret_protected/aisat
	name = "Коридор ИИ"
	icon_state = "ai"

//Malta Research
/area/coldcolony/malta/research
	name = "Исследовательское отделение"
	icon_state = "research"
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE

/area/coldcolony/malta/research/lab
	name = "Научно-исследовательские разработки"
	icon_state = "toxlab"

/area/coldcolony/malta/research/hor
	name = "Кабинет директора исследований"
	icon_state = "head_quarters"

/area/coldcolony/malta/research/chargebay
	name = "Механоотсек"
	icon_state = "mechbay"

/area/coldcolony/malta/research/hallway
	name = "Коридор НИОКР"

/area/coldcolony/malta/research/robotics
	name = "Лаборатория робототехники"
	icon_state = "ass_line"

/area/coldcolony/malta/research/server
	name = "Серверная"
	icon_state = "server"

/area/coldcolony/malta/research/shallway
	name = "Южный коридор НИОКР"

/area/coldcolony/malta/research/explab
	name = "Лаборатория экспериментов"
	icon_state = "toxmisc"

/area/coldcolony/malta/research/test_chamber
	name = "Испытательная камера исследований"
	icon_state = "toxtest"

/area/coldcolony/malta/research/storage
	name = "Хранилище токсинов"
	icon_state = "toxstorage"

/area/coldcolony/malta/research/xenobiology
	name = "Лаборатория ксенобиологии"
	icon_state = "toxmix"
	xenobiology_compatible = TRUE

//Malta Engineering
/area/coldcolony/malta/engineering
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/coldcolony/malta/engineering/break_room
	name = "Фойе инженерного отдела"
	icon_state = "engine"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/coldcolony/malta/engineering/control
	name = "Комната управления атмосферой"
	icon_state = "atmos"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/coldcolony/malta/engineering/monitor
	name = "Комната мониторинга инженерных систем"
	icon_state = "engine_control"

/area/coldcolony/malta/engineering/engine
	name = "SMES инженерного отдела"
	icon_state = "engine_smes"

/area/coldcolony/malta/engineering/atmos
	name = "Атмосферика"
	icon_state = "atmos"

/area/coldcolony/malta/engineering/storage
	name = "Охраняемое хранилище"
	icon_state = "storage"
	ambientsounds = HIGHSEC_SOUNDS

/area/coldcolony/malta/engineering/chief
	name = "Кабинет главного инженера"
	icon_state = "head_quarters"

/area/coldcolony/malta/engineering/teg
	name = "Термогенератор инженерного отдела"
	icon_state = "engine"
