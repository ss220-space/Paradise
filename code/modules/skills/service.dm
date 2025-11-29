// Service skills
/datum/skill/service
	category = "Сервис"

/datum/skill/service/cooking
	id = "service.cooking"
	name = "Готовка"
	desc = "Влияет на готовку."
	duration_mod_signals = list()

/datum/skill/service/butchering
	id = "service.butchering"
	name = "Разделывание туш"
	desc = "Влияет на мастерство разделывания туш."
	duration_mod_signals = list()

/datum/skill/service/drink_mixing
	id = "service.drink_mixing"
	name = "Смешивание напитков"
	desc = "Влияет на смешивание напитков."
	duration_mod_signals = list()
	quality_mod_signals = list()
