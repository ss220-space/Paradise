/// Minimum amount of players required to start this event
#define SWARMERS_MINPLAYERS_TRIGGER 30
/// Amount of swarmers spawned
#define SWARMERS_SPAWN_AMOUNT 4

/datum/event/swarmers
	/// Type of swarmers being spawned
	var/spawn_type = /mob/living/simple_animal/hostile/swarmer/basic
	/// The pod sent to the station
	var/obj/structure/closet/supplypod/swarmer/pod = null
	/// Candidates for swarmers, saved for pod handling
	var/list/candidates
	/// Radius of shields spawned
	var/shields_radius = 2
	/// How long the shields last for
	var/shields_duration = 1 MINUTES

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
 * sends a pod, which will spawn swarmers and the core on landing.
 */
/datum/event/swarmers/proc/create_swarmers()
	var/mob/living/simple_animal/hostile/swarmer/swarmer_type = spawn_type // for source variable
	candidates = SSghost_spawns.poll_candidates("Вы хотите занять роль Свармеров?", ROLE_SWARMER, TRUE, 5 SECONDS, source = swarmer_type)
	if(length(candidates) < SWARMERS_SPAWN_AMOUNT)
		message_admins("Warning: not enough players volunteered to be swarmers. Only [length(candidates)] out of [SWARMERS_SPAWN_AMOUNT]!")
		return FALSE

	initialize_pod()
	return TRUE

/// Creates a pod, registers needed signals and sends it to the station.
/datum/event/swarmers/proc/initialize_pod()
	pod = new
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

/// Changes safe to change walls and removes dense objects nearby
/datum/event/swarmers/proc/on_pod_landing()
	SIGNAL_HANDLER
	var/turf/pod_turf = get_turf(pod)
	clean_stuff_around(pod_turf)

/// Spawns the core and event swarmers nearby.
/datum/event/swarmers/proc/on_pod_open()
	SIGNAL_HANDLER
	var/turf/pod_turf = get_turf(pod)
	new /obj/structure/swarmer/core(pod_turf)

	for(var/i in 1 to SWARMERS_SPAWN_AMOUNT)
		var/turf/swarmer_turf = get_step(pod_turf, pick(GLOB.alldirs))
		var/mob/dead/observer/candidate = pick_n_take(candidates)
		var/mob/living/simple_animal/hostile/swarmer/swarmer = new spawn_type(swarmer_turf)
		swarmer.possess_by_player(candidate.key)
		swarmer.add_datum_if_not_exist()
		log_game("[swarmer.key] has become [swarmer].")

	candidates = null
	create_safety_shield(pod_turf)

/// Cleans up signals and stuff
/datum/event/swarmers/proc/on_pod_qdel()
	SIGNAL_HANDLER
	UnregisterSignal(pod, list(COMSIG_SUPPLYPOD_LANDED, COMSIG_SUPPLYPOD_OPENED, COMSIG_QDELETING))
	pod = null

/// Creates a safety shield around the landing spot, through which only swarmers may pass
/datum/event/swarmers/proc/create_safety_shield(turf/target_turf)
	var/list/shield_turfs = RANGE_EDGE_TURFS(shields_radius, target_turf)
	var/list/corner_turfs = list(shield_turfs[1], shield_turfs[1 + 2 * shields_radius], shield_turfs[2 + 2 * shields_radius], shield_turfs[2 + 4 * shields_radius])
	var/list/non_corner_turfs = shield_turfs - corner_turfs

	// Amount of shields per side without corners
	var/shields_per_side = length(non_corner_turfs) / 4
	// Helper associative list, tells in which order turfs are
	// Reference: Order of turfs from RANGE_EDGE_TURFS
	var/alist/quotient_to_edge_dir = alist(0 = EAST, 1 = WEST, 2 = NORTH, 3 = SOUTH)
	for(var/i in 1 to length(non_corner_turfs))
		var/turf/field_turf = non_corner_turfs[i]
		var/dir = quotient_to_edge_dir[floor((i - 1) / shields_per_side)]
		new /obj/structure/swarmer_core_field(field_turf, shields_duration, dir)

	// And now the corner turfs, also an assoc list for easier reading
	// RANGE_EDGE_TURFS returns north and south edges first (with corners), left to right, thus these values
	var/alist/index_to_corner_dir = alist(1 = NORTHEAST, 2 = SOUTHEAST, 3 = NORTHWEST, 4 = SOUTHWEST)
	for(var/i in 1 to length(corner_turfs))
		var/turf/field_turf = corner_turfs[i]
		var/dir = index_to_corner_dir[i]
		new /obj/structure/swarmer_core_field(field_turf, shields_duration, dir)

/// Changes safe to change walls and removes dense objects nearby
/datum/event/swarmers/proc/clean_stuff_around(turf/target_turf)
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
