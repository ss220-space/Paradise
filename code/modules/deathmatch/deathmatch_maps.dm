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
		/datum/outfit/deathmatch_loadout/unfunny,
		/datum/outfit/deathmatch_loadout/unfunny/pulse,
		/datum/outfit/deathmatch_loadout/unfunny/annihilator,
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

/datum/lazy_template/deathmatch/maint_mania
	name = "Технические туннели"
	desc = "Плохо освещённые технические туннели, неизвестные таблетки, кровавые следы и самодельное оружие. Мечта ассистента."
	max_players = 8
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/assistant,
	)
	map_name = "maint_mania"
	key = LAZY_TEMPLATE_KEY_DEATHMATCH_MAINT_MANIA

/datum/lazy_template/deathmatch/meat_tower
	name = "Кухня"
	desc = "Должен остаться только один шеф-повар."
	max_players = 8
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/chef,
	)
	map_name = "meat_tower"
	key = LAZY_TEMPLATE_KEY_DEATHMATCH_MEAT_TOWER

/datum/lazy_template/deathmatch/mech_madness
	name = "Битва Мехов"
	desc = "Нравятся мехи? Нет? Ну а сражаться всё равно придётся."
	max_players = 4
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/operative,
	)
	map_name = "mech_madness"
	key = LAZY_TEMPLATE_KEY_DEATHMATCH_MECH_MADNESS

/datum/lazy_template/deathmatch/meta_brig
	name = "Бриг Метастанции"
	desc = "Этой карты у нас как бы нет, но арена для битвы неплохая."
	max_players = 8
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/assistant,
	)
	map_name = "meta_brig"
	key = LAZY_TEMPLATE_KEY_DEATHMATCH_META_BRIG

/datum/lazy_template/deathmatch/ragin_mages
	name = "Корабль ФКВ"
	desc = "Волшебный корабль, на котором произойдет не такая уж и волшебная резня."
	max_players = 8
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/wizard,
		/datum/outfit/deathmatch_loadout/wizard/pyro,
		/datum/outfit/deathmatch_loadout/wizard/electro,
		/datum/outfit/deathmatch_loadout/wizard/lizard,
		/datum/outfit/deathmatch_loadout/wizard/singulo,
		/datum/outfit/deathmatch_loadout/wizard/battlemage,
		/datum/outfit/deathmatch_loadout/wizard/gunmancer,
		/datum/outfit/deathmatch_loadout/wizard/chaos,
		/datum/outfit/deathmatch_loadout/wizard/spellblade,

	)
	map_name = "ragin_mages"
	key = LAZY_TEMPLATE_KEY_DEATHMATCH_RAGIN_MAGES

/datum/lazy_template/deathmatch/delta_bridge
	name = "Мостик Кербероса"
	desc = "Копия привычного всем мостика Дельты. Потренируйтесь в убийстве капитана."
	max_players = 8
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/nukie,
		/datum/outfit/deathmatch_loadout/captain,
		/datum/outfit/deathmatch_loadout/head_of_security,
		/datum/outfit/deathmatch_loadout/ert,
		/datum/outfit/deathmatch_loadout/tider,
	)
	map_name = "delta_bridge"
	key = LAZY_TEMPLATE_KEY_DEATHMATCH_DELTA_BRIDGE

/datum/lazy_template/deathmatch/delta_brig
	name = "Бриг Кербероса"
	desc = "Копия привычного всем брига Дельты. Потренируйтесь в штурме и мирном убийстве всего СБ."
	max_players = 16
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/nukie,
		/datum/outfit/deathmatch_loadout/captain,
		/datum/outfit/deathmatch_loadout/head_of_security,
		/datum/outfit/deathmatch_loadout/ert,
		/datum/outfit/deathmatch_loadout/tider,
	)
	map_name = "delta_brig"
	key = LAZY_TEMPLATE_KEY_DEATHMATCH_DELTA_BRIG

/datum/lazy_template/deathmatch/ragnarok
	name = "Рагнарёк"
	desc = "Культисты (которых еще нет) и еретики (которых еще нет) собрались выяснять, кто из них сильнее."
	max_players = 9
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/head_of_security,
		/datum/outfit/deathmatch_loadout/securing_sec,
		/datum/outfit/deathmatch_loadout/assistant,
		/datum/outfit/deathmatch_loadout/tider,
	)
	map_name = "ragnarok"
	key = LAZY_TEMPLATE_KEY_DEATHMATCH_RAGNAROK

/datum/lazy_template/deathmatch/secu_ring
	name = "Офицерский ринг"
	desc = "Небольшая арена для вашей любимой тактики — бесконечного обновления стана с помощью дизейблеров и батонов."
	max_players = 4
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/securing_sec,
	)
	map_name = "secu_ring"
	key = LAZY_TEMPLATE_KEY_DEATHMATCH_SECU_RING

/datum/lazy_template/deathmatch/shooting_range
	name = "Перестрелка"
	desc = "Простая комната с укрытиями для кровавой перестрелки."
	max_players = 6
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/operative/ranged,
	)
	map_name = "shooting_range"
	key = LAZY_TEMPLATE_KEY_DEATHMATCH_SHOOTING_RANGE

/datum/lazy_template/deathmatch/sniper_elite
	name = "Снайперская дуэль"
	desc = "Звуки сломанных костей и оторванных конечностей это то, ради чего я живу."
	max_players = 8
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/operative/sniper,
		/datum/outfit/deathmatch_loadout/nukie/sniper,
	)
	map_name = "sniper_elite"
	key = LAZY_TEMPLATE_KEY_DEATHMATCH_SNIPER_ELITE

// TODO:
// 2-4 more maps, at least
