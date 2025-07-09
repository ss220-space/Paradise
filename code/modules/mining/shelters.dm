/datum/map_template/shelter
	var/shelter_id
	var/description
	var/blacklisted_turfs
	var/whitelisted_turfs
	var/banned_areas

/datum/map_template/shelter/New()
	. = ..()
	blacklisted_turfs = typecacheof(list(/turf/simulated/wall, /turf/simulated/mineral, /turf/simulated/wall/shuttle, /turf/simulated/wall/indestructible))
	whitelisted_turfs = list()
	banned_areas = typecacheof(list(/area/shuttle, /area/lavaland/surface/outdoors/necropolis))

/datum/map_template/shelter/proc/check_deploy(turf/deploy_location)
	var/affected = get_affected_turfs(deploy_location, centered=TRUE)
	for(var/turf/T in affected)
		var/area/A = get_area(T)
		if(is_type_in_typecache(A, banned_areas))
			return SHELTER_DEPLOY_BAD_AREA

		var/banned = is_type_in_typecache(T, blacklisted_turfs)
		var/permitted = is_type_in_typecache(T, whitelisted_turfs)
		if(banned && !permitted)
			return SHELTER_DEPLOY_BAD_TURFS

		for(var/obj/O in T)
			if(O.density && O.anchored)
				return SHELTER_DEPLOY_ANCHORED_OBJECTS
	return SHELTER_DEPLOY_ALLOWED

/datum/map_template/shelter/alpha
	name = "Убежище Альфа"
	shelter_id = "shelter_alpha"
	description = "Уютное автономное герметичное убежище со встроенной навигацией, развлечениями, медицинским оборудованием и спальной зоной! Закажите сейчас – и получите МАЛЕНЬКИЙ ВЕНТИЛЯТОР абсолютно бесплатно!"
	mappath = "_maps/map_files/templates/shelter_1.dmm"

/datum/map_template/shelter/alpha/New()
	. = ..()
	whitelisted_turfs = typecacheof(/turf/simulated/mineral)

/datum/map_template/shelter/beta
	name = "Убежище Бета"
	shelter_id = "shelter_beta"
	description = "Невероятно роскошное убежище со всеми удобствами: ковровые покрытия, горячая и холодная вода, изысканный трехразовый рацион, кухонное оборудование и элитный компаньон, чтобы вам не было одиноко во время пепельной бури."
	mappath = "_maps/map_files/templates/shelter_2.dmm"

/datum/map_template/shelter/beta/New()
	. = ..()
	whitelisted_turfs = typecacheof(/turf/simulated/mineral)

/datum/map_template/shelter/charlie
	name = "Убежище Чарли"
	shelter_id = "shelter_charlie"
	description = "Элитное убежище класса люкс с полноценным баром, двумя торговыми автоматами, столиками и санузлом с раковиной. Это не аварийная капсула, поэтому не рассчитывайте, что она спасет вас в случае смертельного ранения."
	mappath = "_maps/map_files/templates/shelter_3.dmm"

/datum/map_template/shelter/charlie/New()
	. = ..()
	whitelisted_turfs = typecacheof(/turf/simulated/mineral)
