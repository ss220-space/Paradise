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
	/// List of allowed loadouts for this map, otherwise defaults to all loadouts
	var/list/allowed_loadouts = list()
	/// whether we are currently being loaded by a lobby
	var/template_in_use = FALSE

/datum/lazy_template/deathmatch/ragecage
	name = "Клетка"
	desc = "Классическая клетка для устраивания мордобоя."
	max_players = 4
	automatic_gameend_time = 4 MINUTES // its a 10x10 cage what are you guys doing in there
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/assistant)
	map_name = "ragecage"
	key = LAZY_TEMPLATE_KEY_DEATHMATCH_RAGECAGE

/datum/lazy_template/deathmatch/osha_violator
	name = "Нарушение ТБ"
	desc = "Мечта для любого инженера — понатыканные куда попало рефлекторы, едва рабочий СМ и куча бесполезного мусора."
	max_players = 10
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/assistant)
	map_name = "OSHA_violator"
	key = LAZY_TEMPLATE_KEY_DEATHMATCH_OSHA_VIOLATOR

/datum/lazy_template/deathmatch/arena_station
	name = "Космическая Станция"
	desc = "Всё необходимое для убийства, оказывается, можно было уместить на небольшой станции."
	max_players = 10
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
	key = "LAZY_TEMPLATE_KEY_DEATHMATCH_BACKALLEY"

// TODO:
// 16 more maps, at least
