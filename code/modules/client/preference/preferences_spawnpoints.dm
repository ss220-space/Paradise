GLOBAL_LIST_EMPTY(spawntypes)

/proc/populate_spawn_points()
	// GLOB.spawntypes = list() | This is already done, is it not
	for(var/type in subtypesof(/datum/spawnpoint))
		var/datum/spawnpoint/S = new type()
		GLOB.spawntypes[S.display_name] = S

/datum/spawnpoint
	var/msg          //Message to display on the arrivals computer.
	var/list/turfs   //List of turfs to spawn on.
	var/display_name //Name used in preference setup.
	var/list/restrict_job = null
	var/list/disallow_job = null

/datum/spawnpoint/proc/check_job_spawning(job)
	if(restrict_job && !(job in restrict_job))
		return 0

	if(disallow_job && (job in disallow_job))
		return 0

	return 1

/datum/spawnpoint/arrivals
	display_name = "Arrivals Shuttle"
	msg = "прибыл на станцию"

/datum/spawnpoint/arrivals/New()
	..()
	turfs = GLOB.latejoin

/datum/spawnpoint/gateway
	display_name = "Gateway"
	msg = "завершил переход с гейта"

/datum/spawnpoint/gateway/New()
	..()
	turfs = GLOB.latejoin_gateway

/datum/spawnpoint/cryo
	display_name = "Cryogenic Storage"
	msg = "завершил криогенное восстановление"
	disallow_job = list("Cyborg")

/datum/spawnpoint/cryo/New()
	..()
	turfs = GLOB.latejoin_cryo

/datum/spawnpoint/cyborg
	display_name = "Cyborg Storage"
	msg = "был активирован из хранилища"
	restrict_job = list("Cyborg")

/datum/spawnpoint/cyborg/New()
	..()
	turfs = GLOB.latejoin_cyborg
