// Service skills
/datum/skill/service
	category = "Сервис"
	category_color = "#6ca729"

/datum/skill/service/drink_mixing
	id = "service.drink_mixing"
	name = "Смешивание напитков"
	desc = "Влияет на смешивание напитков."
	duration_mod_signals = list()
	quality_mod_signals = list()

/datum/skill/service/botany
	id = "service.botany"
	name = "Ботаника"
	desc = "Влияет на работу с растениями."
	duration_mod_signals = list()
	quality_mod_signals = list()

/datum/skill/service/cleaning
	id = "service.cleaning"
	name = "Уборка"
	desc = "Влияет на мытье полов и уборку."
	duration_mod_signals = list(COMSIG_GET_CLEANING_SPEED_MOD)
	quality_mod_signals = list(COMSIG_GET_CLEANING_DISTANCE_MOD)
