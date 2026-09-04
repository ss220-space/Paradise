/proc/build_overmap_shuttle_profiles()
	. = list()
	for(var/path in subtypesof(/datum/overmap_shuttle_profile))
		var/datum/overmap_shuttle_profile/profile = new path
		if(!profile.shuttle_id)
			continue
		.[profile.shuttle_id] = profile

GLOBAL_LIST_INIT(overmap_shuttle_profiles, build_overmap_shuttle_profiles())

/datum/overmap_shuttle_profile
	var/shuttle_id
	var/identity_name
	var/identity_color = COLOR_WHITE
	var/identity_icon = "shuttle_c"
	var/identity_distress = FALSE
	var/identity_broadcasting = TRUE
	var/identity_locked = FALSE
	/// Faction keys. `list(OVERMAP_IFF_SYNDICATE)` TX on; `list(OVERMAP_IFF_SYNDICATE = FALSE)` listen-only. Global TX = identity_broadcasting.
	var/list/identity_iff_ids

/datum/overmap_shuttle_profile/proc/apply_to(obj/overmap/entity/vessel)
	vessel?.apply_overmap_identity(identity_name, identity_color, identity_icon, identity_distress, identity_broadcasting, identity_iff_ids, identity_locked)

/datum/overmap_shuttle_profile/emergency
	shuttle_id = "emergency"
	identity_name = "Эвакуационный шаттл"
	identity_color = COLOR_CENTCOM_BLUE
	identity_iff_ids = list(OVERMAP_IFF_CENTCOM)

/datum/overmap_shuttle_profile/ferry
	shuttle_id = "ferry"
	identity_name = "Паромный шаттл"
	identity_color = COLOR_CENTCOM_BLUE
	identity_iff_ids = list(OVERMAP_IFF_CENTCOM)

/datum/overmap_shuttle_profile/admin
	shuttle_id = "admin"
	identity_name = "Шаттл центрального командования"
	identity_color = COLOR_CENTCOM_BLUE
	identity_iff_ids = list(OVERMAP_IFF_CENTCOM)

/datum/overmap_shuttle_profile/supply
	shuttle_id = "supply"
	identity_color = COLOR_CENTCOM_BLUE
	identity_name = "Шаттл снабжения"
	identity_iff_ids = list(OVERMAP_IFF_CENTCOM)

/datum/overmap_shuttle_profile/mining
	shuttle_id = "mining"
	identity_name = "Шахтёрский транспортный шаттл"

/datum/overmap_shuttle_profile/laborcamp
	shuttle_id = "laborcamp"
	identity_name = "Тюремный транспортный шаттл"

/datum/overmap_shuttle_profile/specops
	shuttle_id = "specops"
	identity_name = "Шаттл для специальных операций"
	identity_color = COLOR_CENTCOM_BLUE
	identity_broadcasting = FALSE
	identity_iff_ids = list(OVERMAP_IFF_CENTCOM)

/datum/overmap_shuttle_profile/gamma
	shuttle_id = "gamma_shuttle"
	identity_name = "Гамма-шаттл"
	identity_color = COLOR_CENTCOM_BLUE
	identity_iff_ids = list(OVERMAP_IFF_CENTCOM)

/datum/overmap_shuttle_profile/pod1
	shuttle_id = "pod1"
	identity_name = "Спасательная капсула 1"
	identity_color = COLOR_CENTCOM_BLUE
	identity_iff_ids = list(OVERMAP_IFF_CENTCOM)

/datum/overmap_shuttle_profile/pod2
	shuttle_id = "pod2"
	identity_name = "Спасательная капсула 2"
	identity_color = COLOR_CENTCOM_BLUE
	identity_iff_ids = list(OVERMAP_IFF_CENTCOM)

/datum/overmap_shuttle_profile/pod3
	shuttle_id = "pod3"
	identity_name = "Спасательная капсула 3"
	identity_color = COLOR_CENTCOM_BLUE
	identity_iff_ids = list(OVERMAP_IFF_CENTCOM)

/datum/overmap_shuttle_profile/pod4
	shuttle_id = "pod4"
	identity_name = "Спасательная капсула 4"
	identity_color = COLOR_CENTCOM_BLUE
	identity_iff_ids = list(OVERMAP_IFF_CENTCOM)

/datum/overmap_shuttle_profile/syndicate
	shuttle_id = "syndicate"
	identity_name = "Штурмовой шаттл спецотряда 'Атом'"
	identity_color = COLOR_RED
	identity_broadcasting = FALSE
	identity_iff_ids = list(OVERMAP_IFF_SYNDICATE)

/datum/overmap_shuttle_profile/sit
	shuttle_id = "sit"
	identity_name = "Шаттл отряда внедрения"
	identity_color = COLOR_RED
	identity_broadcasting = FALSE
	identity_iff_ids = list(OVERMAP_IFF_SYNDICATE)

/datum/overmap_shuttle_profile/sst
	shuttle_id = "sst"
	identity_name = "Штурмовой шаттл"
	identity_color = COLOR_RED
	identity_broadcasting = FALSE
	identity_iff_ids = list(OVERMAP_IFF_SYNDICATE)

/datum/overmap_shuttle_profile/steel_rain
	shuttle_id = "steel_rain"
	identity_name = "Шаттл 'Cтальной дождь'"
	identity_color = COLOR_RED
	identity_broadcasting = FALSE
	identity_iff_ids = list(OVERMAP_IFF_SYNDICATE)

/datum/overmap_shuttle_profile/vox
	shuttle_id = "vox_shuttle"
	identity_name = "Транспортный шаттл 'Скипджек'"
	identity_broadcasting = FALSE
	identity_color = COLOR_ETHIOPIA_GREEN

/datum/overmap_shuttle_profile/ombra
	shuttle_id = "ombra"
	identity_name = "Шаттл 'Омбра'"
	identity_broadcasting = FALSE
	identity_iff_ids = list(OVERMAP_IFF_SYNDICATE = FALSE)
	identity_color = COLOR_JADE

/datum/overmap_shuttle_profile/trade
	shuttle_id = "trade_sol"
	identity_name = "Торговый шаттл"
	identity_color = COLOR_CENTCOM_BLUE
	identity_iff_ids = list(OVERMAP_IFF_CENTCOM)
	identity_color = COLOR_VERY_SOFT_YELLOW

/datum/overmap_shuttle_profile/whiteship
	shuttle_id = "whiteship"
	identity_name = "Белый корабль"

/datum/overmap_shuttle_profile/addition_goal
	shuttle_id = "addition_goal"
	identity_name = "Шаттл дополнительных приказов"
	identity_iff_ids = list(OVERMAP_IFF_CENTCOM)

/datum/overmap_shuttle_profile/shit_rain
	shuttle_id = "shit_rain"
	identity_name = "Шаттл центрального коммандования"
	identity_color = COLOR_CENTCOM_BLUE
	identity_iff_ids = list(OVERMAP_IFF_CENTCOM)

/datum/overmap_shuttle_profile/funeral
	shuttle_id = "funeral"
	identity_name = "Похоронный шаттл"
