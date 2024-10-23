GLOBAL_DATUM_INIT(space_manager, /datum/zlev_manager, new())

/datum/zlev_manager
	// A list of z-levels
	var/list/z_list = list()
	var/list/levels_by_name = list()
	var/list/heaps = list()

	// Levels that need their transitions rebuilt
	var/list/unbuilt_space_transitions = list()

	var/datum/spacewalk_grid/linkage_map
	var/initialized = 0

// Populate our space level list
// and prepare space transitions
/datum/zlev_manager/proc/initialize()
	var/num_official_z_levels = GLOB.map_transition_config.len
	var/k = 1

	// First take care of "Official" z levels, without visiting levels outside of the list
	for(var/list/features in GLOB.map_transition_config)
		if(k > world.maxz)
			CRASH("More map attributes pre-defined than existent z levels - [num_official_z_levels]")
		var/name = features["name"]
		var/linking = features["linkage"]
		var/list/traits = features["traits"]
		traits = traits.Copy() // Clone the list so it can't be changed on accident

		var/datum/space_level/S = new /datum/space_level(k, name, transition_type = linking, traits = traits)
		z_list["[k]"] = S
		levels_by_name[name] = S
		SSmapping.manage_z_level(S)
		k++

	// Then, we take care of unmanaged z levels
	// They get the default linkage of SELFLOOPING
	for(var/i = k, i <= world.maxz, i++)
		z_list["[i]"] = new /datum/space_level(i)
	initialized = 1


/datum/zlev_manager/proc/get_zlev(z)
	if(!("[z]" in z_list))
		log_runtime(EXCEPTION("Unmanaged z level: '[z]'"))
	else
		return z_list["[z]"]

/datum/zlev_manager/proc/get_zlev_by_name(A)
	if(!(A in levels_by_name))
		log_runtime(EXCEPTION("Non-existent z level: '[A]'"))
	return levels_by_name[A]

/*
* "Dirt" management
* "Dirt" is used to keep track of whether a z level should automatically have
* stuff on it initialize or not - If you're loading a map, place
* a freeze on the z levels it touches so as to prevent atmos from exploding,
* among other things
*/


// Returns whether the given z level has a freeze on initialization
/datum/zlev_manager/proc/is_zlevel_dirty(z)
	var/datum/space_level/our_z = get_zlev(z)
	return (our_z.dirt_count > 0)


// Increases the dirt count on a z level
/datum/zlev_manager/proc/add_dirt(z)
	var/datum/space_level/our_z = get_zlev(z)
	if(our_z.dirt_count == 0)
		log_debug("Placing an init freeze on z-level '[our_z.zpos]'!")
	our_z.dirt_count++


// Decreases the dirt count on a z level
/datum/zlev_manager/proc/remove_dirt(z)
	var/datum/space_level/our_z = get_zlev(z)
	our_z.dirt_count--
	if(our_z.dirt_count == 0)
		our_z.resume_init()
	if(our_z.dirt_count < 0)
		log_debug("WARNING: Imbalanced dirt removal")
		our_z.dirt_count = 0

/datum/zlev_manager/proc/postpone_init(z, thing)
	var/datum/space_level/our_z = get_zlev(z)
	our_z.init_list.Add(thing)


/**
*
*	SPACE ALLOCATION
*
*/


// For when you need the z-level to be at a certain point
/datum/zlev_manager/proc/increase_max_zlevel_to(new_maxz)
	if(world.maxz>=new_maxz)
		return
	while(world.maxz<new_maxz)
		add_new_zlevel("Anonymous Z level [world.maxz]")

/*
 * * add_new_zlevel - Increments max z-level of world by one more z-level.
 * Then applies name, linkage and traits to it.
 * For convenience's sake returns the z-level added.
 *
 * This is a default way to create new z-level on your desire.
 *
 * * name - a name of new z-level. It should be unique. If you'll make multiple with same name, at least add "# [i]" in the end ("Ruin #1", "Ruin #2"...)
 * * linkage - a state of how /turf/space on the edge of the z-level will interact with movable atoms. SELFLOOPING, CROSSLINKED will teleport, while UNAFFECTED won't do anything.
 * * traits - traits/flags/attributes for z-level. All setting are in '_maps/_MAP_DEFINES.dm'
 */
/datum/zlev_manager/proc/add_new_zlevel(name, linkage = SELFLOOPING, traits = list(BLOCK_TELEPORT))
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NEW_Z, args)
	if(name in levels_by_name)
		throw EXCEPTION("Name already in use: [name]")
	world.incrementMaxZ()
	var/our_z = world.maxz
	var/datum/space_level/S = new /datum/space_level(our_z, name, transition_type = linkage, traits = traits)
	levels_by_name[name] = S
	z_list["[our_z]"] = S
	SSmapping.manage_z_level(S)
	return our_z
