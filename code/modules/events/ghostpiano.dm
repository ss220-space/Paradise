/datum/event/ghostpiano
	announceWhen = 10
	endWhen = 11
	var/where

/datum/event/ghostpiano/start()
	var/piano = spawn_piano()
	notify_ghosts("Проклятое фортепиано появилось в [get_area(piano)].\nПомните, что вставка текста в поля UI не по назначению\n(К примеру текст \"А убил Б в техах\") - может каратся.", source = piano, action = NOTIFY_FOLLOW)

/datum/event/ghostpiano/proc/spawn_piano()
	where = get_spawning_turf()
	var/piano = new /obj/structure/ghostpiano(where)
	return piano

/datum/event/ghostpiano/proc/get_spawning_turf()
	var/list/availableareas = list()
	var/list/avaivableturfs = list()
	for(var/area/maintenance/A in world)
		availableareas += A
	var/area/randomarea = pick(availableareas)
	for(var/turf/simulated/floor/F in randomarea)
		if(turf_clear(F))
			avaivableturfs += F
	if(!avaivableturfs)
		get_spawning_turf()
	return pick(avaivableturfs)

/datum/event/ghostpiano/announce()
	var/P = where
	GLOB.event_announcement.Announce("Обнаружена незначительная безвредная паранормальная активность в [get_area(P)]. Рекомендация: пресечь.", "ВНИМАНИЕ: ЗАФИКСИРОВАНА ПАРАНОРМАЛЬНАЯ АКТИВНОСТЬ.")
