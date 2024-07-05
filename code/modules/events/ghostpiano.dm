/datum/event/ghostpiano
	announceWhen = 10
	endWhen = 11
	var/turf/spawn_turf


/datum/event/ghostpiano/start()
	spawn_turf = get_spawning_turf()
	if(!spawn_turf)
		kill()
		return
	var/obj/structure/pianoclassic/ghostpiano/piano = new(spawn_turf)
	notify_ghosts("Проклятое фортепиано появилось в [get_area(piano)].\nПомните, что вставка текста в поля UI не по назначению\n(К примеру текст \"А убил Б в техах\") - может каратся.", source = piano, action = NOTIFY_FOLLOW)


/datum/event/ghostpiano/proc/get_spawning_turf()
	var/list/availableareas = list()
	for(var/area/maintenance/area in GLOB.all_areas)
		availableareas += area
	if(!length(availableareas))
		return
	var/list/avaivableturfs = list()
	var/area/randomarea = pick(availableareas)
	for(var/turf/simulated/floor/floor in randomarea)
		if(!floor.is_blocked_turf())
			avaivableturfs += floor
	return safepick(avaivableturfs)


/datum/event/ghostpiano/announce()
	GLOB.event_announcement.Announce("Обнаружена незначительная безвредная паранормальная активность в [get_area(spawn_turf)]. Рекомендация: пресечь.", "ВНИМАНИЕ: ЗАФИКСИРОВАНА ПАРАНОРМАЛЬНАЯ АКТИВНОСТЬ.")

