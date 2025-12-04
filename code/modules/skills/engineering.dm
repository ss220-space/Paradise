// Engineering skills
/datum/skill/engineering
	category = "Инженерные"
	category_color = "#f37746"

/datum/skill/engineering/building
	id = "engineering.building"
	name = "Строительство"
	desc = "Влияет на скорость строительства."
	duration_mod_signals = list(COMSIG_GET_BUILDING_SPEED_MOD)

/datum/skill/engineering/construction
	id = "engineering.construction"
	name = "Конструирование"
	desc = "Влияет на скорость конструирования машинерии."
	duration_mod_signals = list(COMSIG_GET_CONSTRUCTING_SPEED_MOD)

/datum/skill/engineering/electrician
	id = "engineering.electrician"
	name = "Электрика"
	desc = "Влияет на работу с электричеством (шанс удара током)."
	duration_mod_signals = list(COMSIG_GET_ELECTRICITY_SPEED_MOD, COMSIG_GET_ELECTRICITY_NEGATIVE_CHANCE_MOD)
	quality_modifiers = list(COMSIG_GET_ELECTRICITY_POSITIVE_CHANCE_MOD)

/datum/skill/engineering/atmos
	id = "engineering.atmos"
	name = "Атмостехника"
	desc = "Влияет на работу с трубами и остальной атмосферной техникой."
	duration_mod_signals = list(COMSIG_GET_ATMOS_SPEED_MOD)

/datum/skill/engineering/lockpick
	id = "engineering.lockpick"
	name = "Взлом"
	desc = "Влияет на взлом шлюзов, ящиков и шкафчиков."
	duration_mod_signals = list(COMSIG_GET_LOCKPICK_SPEED_MOD)
	quality_modifiers = list(COMSIG_GET_LOCKPICK_POSITIVE_CHANCE_MOD)
