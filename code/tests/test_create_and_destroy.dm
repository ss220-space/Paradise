/// Creates one of every movable and turf type on a test floor and deletes it right away.
/// Fails for every type that ignores a forced qdel, returns no qdel hint, breaks the Initialize() rules,
/// changes the baseturf of the test floor or causes a runtime on the way.
/// Types that fail to garbage collect are reported by [/datum/unit_test/gc_failures], which runs after this test.
/datum/unit_test/room_test/create_and_destroy
	// Leaves the test room in an unknown state, so it has to run after (almost) every other test.
	priority = TEST_CREATE_AND_DESTROY

/// TRUE while [/datum/unit_test/room_test/create_and_destroy] creates and destroys its types.
GLOBAL_VAR_INIT(running_create_and_destroy, FALSE)

/datum/unit_test/room_test/create_and_destroy/Run()
	// Everything is spawned here.
	var/turf/spawn_at = run_loc_floor_bottom_left
	TEST_ASSERT_NOTNULL(spawn_at, "There is no test floor to spawn on.")

	var/list/cached_contents = spawn_at.contents.Copy()
	var/original_turf_type = spawn_at.type
	var/original_baseturf = spawn_at.baseturf
	var/list/bad_initialize_calls_before = SSatoms.BadInitializeCalls.Copy()
	var/list/runtimes_by_type = list()

	// No areas.
	var/list/type_paths_to_check = (valid_typesof(/atom/movable) + valid_typesof(/turf)) - uncreatables
	log_world("Create and destroy: checking [length(type_paths_to_check)] types.")
	var/real_start_time = REALTIMEOFDAY

	GLOB.running_create_and_destroy = TRUE
	for(var/type_path in type_paths_to_check)
		var/runtimes_before = GLOB.total_runtimes
		if(ispath(type_path, /turf))
			spawn_at.ChangeTurf(type_path)
			// Changed back so that the next type starts from the same floor.
			spawn_at.ChangeTurf(original_turf_type)
			if(spawn_at.baseturf != original_baseturf)
				TEST_FAIL("[type_path] changed the baseturf of the test floor from [original_baseturf] to [spawn_at.baseturf].")
				spawn_at.baseturf = original_baseturf
		else
			var/atom/creation = new type_path(spawn_at)
			if(!QDELETED(creation))
				qdel(creation, force = TRUE)
			// Without this the variable keeps a reference to the last thing created.
			creation = null

		// Many types spawn other things when created or leave things behind when deleted.
		// They are removed so that the next type starts from a clean floor.
		var/list/leftovers = spawn_at.contents - cached_contents
		for(var/atom/leftover in leftovers)
			qdel(leftover, force = TRUE)
			leftover = null
		leftovers = null

		var/new_runtimes = GLOB.total_runtimes - runtimes_before
		if(new_runtimes)
			runtimes_by_type[type_path] = new_runtimes
	GLOB.running_create_and_destroy = FALSE

	log_world("Create and destroy: [length(type_paths_to_check)] types took [DisplayTimeText(REALTIMEOFDAY - real_start_time)].")
	cached_contents.Cut()

	for(var/type_path in runtimes_by_type)
		TEST_FAIL("[type_path] caused [runtimes_by_type[type_path]] runtimes while it was created and destroyed.")

	for(var/path in SSgarbage.items)
		var/datum/qdel_item/item = SSgarbage.items[path]
		if(item.no_respect_force)
			TEST_FAIL("[item.name] failed to respect force deletion [item.no_respect_force] times out of a total del count of [item.qdels].")
		if(item.no_hint)
			TEST_FAIL("[item.name] failed to return a qdel hint [item.no_hint] times out of a total del count of [item.qdels].")

	for(var/path in SSatoms.BadInitializeCalls)
		// Only what this test added: the rest is reported by the init_sanity test.
		var/new_fails = SSatoms.BadInitializeCalls[path] & ~bad_initialize_calls_before[path]
		if(new_fails & BAD_INIT_NO_HINT)
			TEST_FAIL("[path] didn't return an Initialize() hint.")
		if(new_fails & BAD_INIT_QDEL_BEFORE)
			TEST_FAIL("[path] was qdeleted before Initialize() could be called.")
		if(new_fails & BAD_INIT_DIDNT_INIT)
			TEST_FAIL("[path] didn't set the INITIALIZED flag in Initialize().")
		if(new_fails & BAD_INIT_SLEPT)
			TEST_FAIL("[path] slept during Initialize().")
