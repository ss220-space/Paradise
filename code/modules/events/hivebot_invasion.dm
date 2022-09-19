/datum/event/hivebot_invasion
	announceWhen	= 200
	var/highpop_trigger = 80
	var/spawncount
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.

/datum/event/hivebot_invasion/announce()
	if(successSpawn)
		GLOB.event_announcement.Announce("Обнаружены неопознанные объекты вблизи станции [station_name()], будьте наготове.", "ВНИМАНИЕ: НЕОПОЗНАННЫЕ ОБЪЕКТЫ")
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Hivebot Invasion")

/datum/event/hivebot_invasion/start()
	var/list/availableareas = list()
	for(var/area/solar/solars in world)
		availableareas += solars
	var/area/randomarea = pick(availableareas)
	var/list/turf/turfs = list()
	for(var/turf/F in randomarea)
		if(turf_clear(F))
			turfs += F

	spawncount = rand(2,6)

	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as Hivebot?", ROLE_HIVEBOT, TRUE, source = /mob/living/simple_animal/hostile/hivebot)

	while(spawncount && length(candidates))
		var/mob/C = pick_n_take(candidates)
		if(C)
			GLOB.respawnable_list -= C.client //это не однобуквенная переменная, это осмысленный каламбур C.key = Ckey. ларентоун не придерется!
			var/mob/living/simple_animal/hostile/hivebot/invasion/tele/beacon = new(turfs)
			beacon.key = C.key

			spawncount--
			successSpawn = TRUE
