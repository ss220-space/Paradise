#define ZOMBIE_TRIGGER 30

/datum/event/zombie
	var/list/playercount

/datum/event/zombie/start()
	INVOKE_ASYNC(src, PROC_REF(wrappedstart))
	// It is necessary to wrap this to avoid the event triggering repeatedly.

/datum/event/zombie/proc/wrappedstart()
	playercount = num_station_players() //grab playercount when event starts not when game starts
	if(playercount < ZOMBIE_TRIGGER)
		return
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите занять роль Зомби?", ROLE_ZOMBIE, TRUE, 30 SECONDS, role_cleanname = "Зомби", source = /mob/living/simple_animal/hostile/zombie)
	if(!length(candidates))
		return
	var/obj/structure/closet/supplypod/pod = new ()
	for(var/i in 1 to min(length(candidates), 4))
		var/mob/dead/observer/candidate = pick_n_take(candidates)
		var/mob/living/carbon/human/zombie = new(pod)
		zombie.possess_by_player(candidate.key)
		zombie.mind.add_antag_datum(/datum/antagonist/zombie)
	pod.setStyle(/datum/pod_style/syndicate)
	var/turf/target_turf = pick(GLOB.swarmer_spawn)
	new /obj/effect/pod_landingzone(target_turf, pod)
	notify_ghosts(
		title = "Запущена капсула",
		message = "На станцию запущена капсула с зомби.",
		source = pod,
	)

#undef ZOMBIE_TRIGGER
