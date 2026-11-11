/datum/overmap_ai_profile
	var/long_scan = FALSE
	var/name
	var/acceleration = 1.5
	var/distance = 65
	var/fire_range = 350
	var/width = 9
	var/height = 13
	var/gun_type = /obj/machinery/ship_gun/ak820
	var/gun_count = 2

/datum/overmap_ai_profile/light
	name = "Лёгкий"
	acceleration = 2
	distance = 30
	fire_range = 220
	width = 7
	height = 9
	gun_type = /obj/machinery/ship_gun/fang
	gun_count = 1

/datum/overmap_ai_profile/medium
	name = "Средний"
	gun_type = /obj/machinery/ship_gun/fang

/datum/overmap_ai_profile/heavy
	name = "Тяжёлый"
	acceleration = 0.8
	distance = 180
	fire_range = 550
	width = 13
	height = 17
	gun_type = /obj/machinery/ship_gun/charon

/datum/overmap_ai_profile/support
	name = "Поддержка"
	acceleration = 0.6
	distance = 300
	fire_range = 750
	width = 11
	height = 15
	gun_type = /obj/machinery/ship_gun/prometheus
	gun_count = 1

/datum/overmap_ai_profile/support/flagship
	name = "Флагман"
	long_scan = TRUE
	width = 15
	height = 19
	gun_count = 2
