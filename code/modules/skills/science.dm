// Science skills (R&D)
/datum/skill/research
	category = "Научные"
	category_color = "#c68cfa"

/datum/skill/research/research
	id = "research.research"
	name = "Исследования"
	desc = "Влияет на шансы разбора для получения техов."

/datum/skill/research/protolathe
	id = "research.protolathe"
	name = "Обращение с протолатом"
	desc = "Влияет на скорость и шанс успеха при работе с протолатом."
	duration_mod_signals = list(COMSIG_GET_PROTOLATHE_DURATION_MOD)

/datum/skill/research/mech_construct
	id = "research.mech_construct"
	name = "Конструирование мехов"
	desc = "Влияет на скорость постройки мехов и печати их запчастей."
	duration_mod_signals = list(COMSIG_GET_MECH_CONSTRUCT_DURATION_MOD, COMSIG_GET_PROTOLATHE_RESOURCE_MOD)

/datum/skill/research/anomaly
	id = "research.anomaly"
	name = "Обращение с аномалиями"
	desc = "Влияет на шансы при работе с аномалиями."

/datum/skill/research/xenobiology
	id = "research.xenobiology"
	name = "Ксенобиология"
	desc = "Влияет на шанс двойного лута с ядра слаймов."
