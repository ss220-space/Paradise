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
