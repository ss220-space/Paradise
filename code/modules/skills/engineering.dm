// Engineering skills
/datum/skill/engineering
	category = "Инженерные"

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
