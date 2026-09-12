/// Minimum amount of players required to start this event
#define SWARMERS_MINPLAYERS_TRIGGER 30
/// Amount of swarmers spawned
#define SWARMERS_SPAWN_AMOUNT 4

/datum/event/swarmers
	/// Type of swarmers being spawned
	var/spawn_type = /mob/living/simple_animal/hostile/swarmer/basic
	/// The pod sent to the station
	var/pod_type = /obj/structure/closet/supplypod/swarmer
	/// Radius of shields spawned
	var/shields_radius = 2
	/// How long the shields last
	var/shields_duration = 15 SECONDS

/datum/event/swarmers/start()
	// It is necessary to wrap this to avoid the event triggering repeatedly.
	INVOKE_ASYNC(src, PROC_REF(wrapped_start))

/datum/event/swarmers/proc/wrapped_start()
	// Reroll event if not enough players
	var/player_count = num_station_players()
	if(player_count < SWARMERS_MINPLAYERS_TRIGGER)
		log_and_message_admins("Random event attempted to spawn swarmers, but there were only [player_count]/[SWARMERS_MINPLAYERS_TRIGGER] players.")
		var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MODERATE]
		EC.next_event_time = world.time + 1 MINUTES
		return kill()

	var/successSpawn = create_swarmers()
	if(!successSpawn)
		log_and_message_admins("Warning: Could not spawn any mobs for event Swarmers")
		return kill()

/**
 * Gets all candidates for swarmer role, afterwards
 * initializes the pod and puts all swarmers in it.
 */
/datum/event/swarmers/proc/create_swarmers()
	var/mob/living/simple_animal/hostile/swarmer/swarmer_type = spawn_type // for source variable
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите занять роль Свармеров?", ROLE_SWARMER, TRUE, 30 SECONDS, source = swarmer_type)
	if(length(candidates) < SWARMERS_SPAWN_AMOUNT)
		message_admins("Warning: not enough players volunteered to be swarmers. Only [length(candidates)] out of [SWARMERS_SPAWN_AMOUNT]!")
		return FALSE

	var/obj/structure/closet/supplypod/pod = initialize_pod()
	for(var/i in 1 to SWARMERS_SPAWN_AMOUNT)
		var/mob/dead/observer/candidate = pick_n_take(candidates)
		var/mob/living/simple_animal/hostile/swarmer/swarmer = new spawn_type(pod)
		swarmer.possess_by_player(candidate.key)
		swarmer.add_datum_if_not_exist()
		log_game("[swarmer.key] has become [swarmer].")

	return TRUE

/// Creates a pod, registers needed signals and sends it to the station.
/datum/event/swarmers/proc/initialize_pod()
	var/obj/structure/closet/supplypod/pod = new pod_type()
	RegisterSignal(pod, COMSIG_SUPPLYPOD_LANDED, PROC_REF(on_pod_landing))
	RegisterSignal(pod, COMSIG_SUPPLYPOD_OPENED, PROC_REF(on_pod_open))
	RegisterSignal(pod, COMSIG_QDELETING, PROC_REF(on_pod_qdel))

	var/turf/target_turf = pick(GLOB.swarmer_spawn)
	new /obj/effect/pod_landingzone(target_turf, pod)
	notify_ghosts(
		title = "Запущена капсула",
		message = "На станцию запущена капсула Свармеров.",
		source = pod,
	)

	return pod

/// Changes safe to change walls and removes dense objects nearby
/datum/event/swarmers/proc/on_pod_landing(obj/structure/closet/supplypod/pod)
	SIGNAL_HANDLER
	clean_stuff_around(pod)

/// Spawns the core and event swarmers nearby.
/datum/event/swarmers/proc/on_pod_open(obj/structure/closet/supplypod/pod)
	SIGNAL_HANDLER
	var/turf/pod_turf = get_turf(pod)
	new /obj/structure/swarmer/core(pod_turf)
	swarmer_shield_around_turf(pod_turf, shields_radius, shields_duration)

/// Cleans up signals and stuff
/datum/event/swarmers/proc/on_pod_qdel(obj/structure/closet/supplypod/pod)
	SIGNAL_HANDLER
	UnregisterSignal(pod, list(COMSIG_SUPPLYPOD_LANDED, COMSIG_SUPPLYPOD_OPENED, COMSIG_QDELETING))

/// Changes safe to change walls and removes dense objects nearby
/datum/event/swarmers/proc/clean_stuff_around(obj/structure/closet/supplypod/pod)
	var/turf/target_turf = get_turf(pod)
	for(var/turf/simulated/wall/wall_turf in range(shields_radius - 1, target_turf))
		if(check_safe_to_remove(wall_turf))
			wall_turf.ChangeTurf(/turf/simulated/floor/plating)

	for(var/obj/obj in range(shields_radius, target_turf))
		if(obj == pod)
			continue
		if(!obj.density)
			continue
		if(istype(obj, /obj/structure/swarmer))
			continue
		if(check_safe_to_remove(obj))
			qdel(obj)

	for(var/mob/living/living_mob in range(shields_radius, target_turf))
		if(isswarmer(living_mob))
			continue

		living_mob.adjustStaminaLoss(MAX_STAMINA_LOSS, forced = TRUE)
		var/throw_direction = get_dir(living_mob, target_turf)
		var/throw_target = get_edge_target_turf(pod, throw_direction)
		living_mob.throw_at(throw_target, 5, 20)

/// Used to check on landing if there are any space turfs nearby an atom
/datum/event/swarmers/proc/check_safe_to_remove(atom/movable/target)
	var/blocks_air = !target.CanAtmosPass(NORTH) || !target.CanAtmosPass(WEST) || !target.CanAtmosPass(EAST) || !target.CanAtmosPass(SOUTH)
	if(!blocks_air)
		return TRUE

	. = TRUE
	var/turf/target_turf = get_turf(target)
	for(var/turf/turf as anything in target_turf.AdjacentTurfs(cardinal_only = TRUE))
		if(isspaceturf(turf))
			return FALSE

#undef SWARMERS_MINPLAYERS_TRIGGER
#undef SWARMERS_SPAWN_AMOUNT
