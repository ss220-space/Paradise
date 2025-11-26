/**********************Mine areas**************************/

/area/mine
	icon_state = "mining"
	has_gravity = STANDARD_GRAVITY
	sound_environment = SOUND_AREA_STANDARD_STATION
	area_flags = NONE

/area/mine/explored
	name = "Шахта"
	icon_state = "explored"
	always_unpowered = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	outdoors = TRUE
	ambientsounds = MINING_SOUNDS
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/area/mine/dangerous/explored/golem
	name = "Малый астероид"

/area/mine/unexplored
	name = "Шахта"
	icon_state = "unexplored"
	always_unpowered = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	outdoors = TRUE
	ambientsounds = MINING_SOUNDS
	sound_environment = SOUND_AREA_ASTEROID
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS
	holomap_should_draw = FALSE

/area/mine/unexplored/cere
	ignore_gravgen = TRUE

/area/mine/unexplored/cere/ai
	name = "Астероид ИИ"

/area/mine/unexplored/cere/cargo
	name = "Грузовой астероид"

/area/mine/unexplored/cere/civilian
	name = "Гражданский астероид"

/area/mine/unexplored/cere/command
	name = "Командный астероид"

/area/mine/unexplored/cere/docking
	name = "Стыковочный астероид"

/area/mine/unexplored/cere/engineering
	name = "Инженерный астероид"

/area/mine/unexplored/cere/medical
	name = "Медицинский астероид"

/area/mine/unexplored/cere/research
	name = "Исследовательский астероид"

/area/mine/unexplored/cere/orbiting
	name = "Астероиды у станции"

/area/mine/lobby
	name = "Шахтёрский аванпост"

/area/mine/storage
	name = "Склад шахтёрского аванпоста"

/area/mine/production
	name = "Производственный сектор шахтёрского аванпоста"
	icon_state = "mining_production"

/area/mine/abandoned
	name = "Заброшенный шахтёрский аванпост"

/area/mine/living_quarters
	name = "Жилой сектор шахтёрского аванпоста"
	icon_state = "mining_living"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/mine/eva
	name = "Отсек ВКД шахтёрского аванпоста"
	icon_state = "mining_eva"

/area/mine/maintenance
	name = "Пункт связи шахтёрского аванпоста"
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED

/area/mine/cafeteria
	name = "Столовая шахтёрского аванпоста"

/area/mine/hydroponics
	name = "Гидропоника шахтёрского аванпоста"

/area/mine/sleeper
	name = "Аварийные капсулы шахтёрского аванпоста"

/area/mine/north_outpost
	name = "Северное крыло шахтёрского аванпоста"

/area/mine/west_outpost
	name = "Западное крыло шахтёрского аванпоста"

/area/mine/laborcamp/security
	name = "Охрана трудового лагеря"
	icon_state = "security"
	ambientsounds = HIGHSEC_SOUNDS

/area/mine/podbay
	name = "Ангар шахтёрских капсул"

/**********************Lavaland Areas**************************/

/area/lavaland
	icon_state = "mining"
	has_gravity = STANDARD_GRAVITY
	sound_environment = SOUND_AREA_LAVALAND
	area_flags = FLORA_ALLOWED

/area/lavaland/surface
	name = "Лазис"
	icon_state = "explored"
	always_unpowered = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	ambientsounds = MINING_SOUNDS
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS
	area_flags = NONE
	holomap_should_draw = FALSE

/area/lavaland/underground
	name = "Пещеры Лазиса"
	icon_state = "unexplored"
	always_unpowered = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	ambientsounds = MINING_SOUNDS
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/area/lavaland/surface/outdoors
	name = "Пустоши Лазиса"
	outdoors = TRUE
	area_flags = FLORA_ALLOWED | BLOBS_ALLOWED

/area/lavaland/surface/outdoors/unexplored // ruins spawn here
	icon_state = "unexplored"

/area/lavaland/surface/outdoors/unexplored/danger //megafauna will also spawn here
	icon_state = "cave"
	area_flags = CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED | MEGAFAUNA_SPAWN_ALLOWED
	map_generator = /datum/map_generator/cave_generator/lavaland

/area/lavaland/surface/outdoors/explored
	name = "Трудовой лагерь Лазиса"
	area_flags = NONE

/area/lavaland/surface/outdoors/necropolis
	name = "Некрополис"
	icon_state = "unexplored"
	tele_proof = TRUE
	area_flags = NONE
