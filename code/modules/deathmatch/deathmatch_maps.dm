/datum/lazy_template/deathmatch
	map_dir = "_maps/minigames/deathmatch"
	/// Map UI Name
	var/name
	/// Map Description
	var/desc = ""
	/// Minimum players for this map
	var/min_players = 2
	/// Maximum players for this map
	var/max_players = 2 // TODO: make this automatic.
	/// The map will end in this time
	var/automatic_gameend_time = 8 MINUTES
	/// List of allowed loadouts for this map
	var/list/allowed_loadouts = list(/datum/outfit/deathmatch_loadout/naked)
	/// whether we are currently being loaded by a lobby
	var/template_in_use = FALSE

/datum/lazy_template/deathmatch/ragecage
	name = "Клетка"
	desc = "Классическая клетка для устраивания мордобоя."
	max_players = 4
	automatic_gameend_time = 4 MINUTES // its a 10x10 cage what are you guys doing in there
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/assistant,
	)
	map_name = "ragecage"
	key = LAZY_TEMPLATE_KEY_DEATHMATCH_RAGECAGE

/datum/lazy_template/deathmatch/osha_violator
	name = "Нарушение ТБ"
	desc = "Мечта для любого инженера — понатыканные куда попало рефлекторы, едва рабочий СМ и куча бесполезного мусора."
	max_players = 10
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/assistant/weaponless,
	)
	map_name = "OSHA_violator"
	key = LAZY_TEMPLATE_KEY_DEATHMATCH_OSHA_VIOLATOR

/datum/lazy_template/deathmatch/arena_station
	name = "Космическая Станция"
	desc = "Всё необходимое для убийства, оказывается, можно было уместить на небольшой станции."
	max_players = 10
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/securing_sec,
		/datum/outfit/deathmatch_loadout/tider,
	)
	map_name = "arena_station"
	key = LAZY_TEMPLATE_KEY_DEATHMATCH_ARENA_STATION

/datum/lazy_template/deathmatch/backalley
	name = "Переулок"
	desc = "Ты и дня не продержишься на улице, пацан."
	max_players = 8
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/assistant,
		/datum/outfit/deathmatch_loadout/naked,
	)
	map_name = "backalley"
	key = LAZY_TEMPLATE_KEY_DEATHMATCH_BACKALLEY

/datum/lazy_template/deathmatch/final_destination
	name = "Арена"
	desc = "Четыре команды, окруженные рвами. Победит сильнейший!"
	max_players = 8
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/nukie,
		/datum/outfit/deathmatch_loadout/captain,
		/datum/outfit/deathmatch_loadout/head_of_security,
		/datum/outfit/deathmatch_loadout/operative/ranged,
	)
	map_name = "final_destination"
	key = LAZY_TEMPLATE_KEY_DEATHMATCH_FINAL_DESTINATION

/datum/lazy_template/deathmatch/instagib
	name = "Корабль Абдукторов"
	desc = "Отличная арена для стрельбы из гиб-пушек"
	max_players = 8
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/assistant/instagib,
		/datum/outfit/deathmatch_loadout/assistant/pulse,
		/datum/outfit/deathmatch_loadout/assistant/annihilator,
	)

	map_name = "instagib"
	key = LAZY_TEMPLATE_KEY_DEATHMATCH_INSTAGIB

/datum/lazy_template/deathmatch/lattice_battle
	name = "Битва над разломом"
	desc = "Надоело сражаться с помощью кулаков? Попробуйте столкнуть соперника в бездонную пропасть!"
	max_players = 9
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/assistant,
	)
	map_name = "lattice_battle"
	key = LAZY_TEMPLATE_KEY_DEATHMATCH_LATTICE_BATTLE

// TODO:
// 13 more maps, at least
