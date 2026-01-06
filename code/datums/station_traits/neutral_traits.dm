/datum/station_trait/announcement_intern_ru
	name = "Временная замена анонсов станции"
	weight = 1
	show_in_report = TRUE
	report_message = "Пожалуйста, будьте с ним повежливее, он тут работает первый день..."
	blacklist = list(/datum/station_trait/announcement_medbot, /datum/station_trait/announcement_intern) //datum/station_trait/birthday)

/datum/station_trait/announcement_intern_ru/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/intern_ru

/datum/station_trait/announcement_intern
	name = "Временная замена анонсов станции"
	weight = 1
	show_in_report = TRUE
	report_message = "Мы наняли его из другого сектора, поэтому, вероятно, он не совсем знает наш язык."
	blacklist = list(/datum/station_trait/announcement_medbot, /datum/station_trait/announcement_intern_ru) //datum/station_trait/birthday)

/datum/station_trait/announcement_intern/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/intern

/datum/station_trait/announcement_medbot
	name = "Временная \"система\" оповещений"
	weight = 1
	show_in_report = TRUE
	report_message = "Стандартная система оповещений проходит техническое обслуживание. К счастью, у нас есть отличная замена."
	blacklist = list(/datum/station_trait/announcement_intern, /datum/station_trait/announcement_intern_ru) //datum/station_trait/birthday)

/datum/station_trait/announcement_medbot/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/medbot

/datum/station_trait/bananium_shipment
	name = "Поставка бананиума"
	report_message = "Мы получили партию бананиума для станционного клоуна с запиской, где сказано следующее: \"С любовью, мама.\"."
	show_in_report = TRUE
	cost = STATION_TRAIT_COST_LOW
	weight = 5
	trait_to_give = STATION_TRAIT_BANANIUM_SHIPMENTS

/datum/station_trait/mimanium_shipment
	name = "Поставка транквилита"
	report_message = "..."
	show_in_report = TRUE
	cost = STATION_TRAIT_COST_LOW
	weight = 5
	trait_to_give = STATION_TRAIT_MIMANIUM_SHIPMENTS

/datum/station_trait/unique_ai
	name = "Экспериментальный свод законов ИИ"
	report_message = "В ИИ станции был загружен экспериментальный свод законов. Вам запрещается смена законов за исключением ситуаций, препятствующих работе станции. На кону ваша должность, капитан."
	show_in_report = TRUE
	trait_flags = parent_type::trait_flags | STATION_TRAIT_REQUIRES_AI
	weight = 5
	trait_to_give = STATION_TRAIT_UNIQUE_AI
	force = 1

