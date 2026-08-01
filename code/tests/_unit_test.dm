GLOBAL_LIST_EMPTY(unit_test_chats)
GLOBAL_LIST_EMPTY(unit_test_tguis)

/// For advanced cases, fail unconditionally but don't return (so a test can return multiple results)
#define TEST_FAIL(reason) (Fail(reason || "No reason", __FILE__, __LINE__))

/// Asserts that a condition is true
/// If the condition is not true, fails the test
#define TEST_ASSERT(assertion, reason) if(!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }

#define TEST_ASSERT_NOT(assertion, reason) if(assertion) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }

/// Asserts that a parameter is not null
#define TEST_ASSERT_NOTNULL(a, reason) if(isnull(a)) { return Fail("Expected non-null value: [reason || "No reason"]", __FILE__, __LINE__) }

/// Asserts that a parameter is null
#define TEST_ASSERT_NULL(a, reason) if(!isnull(a)) { return Fail("Expected null value but received [a]: [reason || "No reason"]", __FILE__, __LINE__) }

#define TEST_ASSERT_LAST_CHATLOG(puppet, text) if(!puppet.last_chatlog_has_text(text)) { return Fail("Expected `[text]` in last chatlog but got `[puppet.get_last_chatlog()]`", __FILE__, __LINE__) }

#define TEST_ASSERT_ANY_CHATLOG(puppet, text) if(!puppet.any_chatlog_has_text(text))  { return Fail("Expected `[text]` in any chatlog but got [jointext(puppet.get_chatlogs(), "\n")]", __FILE__, __LINE__) }

#define TEST_ASSERT_NOT_CHATLOG(puppet, text) if(puppet.any_chatlog_has_text(text))  { return Fail("Didn't expect `[text]` in any chatlog but got [jointext(puppet.get_chatlogs(), "\n")]", __FILE__, __LINE__) }

#define TEST_ASSERT_SUBSTRING(haystack, needle) if(!findtextEx(haystack, needle))  { return Fail("`[needle]` not found in string `[haystack]`", __FILE__, __LINE__) }

/// Asserts that the two parameters passed are equal, fails otherwise
/// Optionally allows an additional message in the case of a failure
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if(lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while(FALSE)

/// Asserts that the two parameters passed are not equal, fails otherwise
/// Optionally allows an additional message in the case of a failure
#define TEST_ASSERT_NOTEQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if(lhs == rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to not be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while(FALSE)

#define TEST_PRE 0
#define TEST_DEFAULT 1
/// After most test steps, used for tests that run long so shorter issues can be noticed faster
#define TEST_LONGER 10
/// This must be the one of last tests to run due to the inherent nature of the test iterating every single tangible atom in the game and qdeleting all of them (while taking long sleeps to make sure the garbage collector fires properly) taking a large amount of time.
#define TEST_CREATE_AND_DESTROY 9001
/**
 * For tests that rely on create and destroy having iterated through every (tangible) atom so they don't have to do something similar.
 * Keep in mind tho that create and destroy will absolutely break the test platform, anything that relies on its shape cannot come after it.
 */
#define TEST_AFTER_CREATE_AND_DESTROY INFINITY

/**
 * Usage:
 *
 * - Override /Run() to run your test code
 * - Call TEST_FAIL() to fail the test (You should specify a reason)
 * - You may use /New() and /Destroy() for setup/teardown respectively
 * - You can use the bottom_left and top_right to get turfs for testing
 */
/datum/unit_test
	/// Do not instantiate if type matches this
	abstract_type = /datum/unit_test

	//Bit of metadata for the future maybe
	var/list/procs_tested

	///The priority of the test, the larger it is the later it fires
	var/priority = TEST_DEFAULT

	// failure tracking
	var/succeeded = TRUE
	var/list/allocated
	var/list/fail_reasons

	/// List of atoms that we don't want to ever initialize in an agnostic context, like for Create and Destroy. Stored on the base datum for usability in other relevant tests that need this data.
	var/static/list/uncreatables = null

/proc/cmp_unit_test_priority(datum/unit_test/a, datum/unit_test/b)
	return initial(a.priority) - initial(b.priority)

/datum/unit_test/New()
	if(isnull(uncreatables))
		uncreatables = build_list_of_uncreatables()

/datum/unit_test/Destroy()
	QDEL_LIST(allocated)
	// clear the whole test area, not just the bounds of the landmarks
	for(var/turf/turf in get_area_turfs(/area/misc/testroom))
		for(var/atom/movable/target in turf)
			qdel(target)

	return ..()

/datum/unit_test/proc/Run()
	TEST_FAIL("Run() called parent or not implemented")

/datum/unit_test/proc/Fail(reason = "No reason", file = "OUTDATED_TEST", line = 1)
	succeeded = FALSE

	if(!istext(reason))
		reason = "FORMATTED: [reason != null ? reason : "NULL"]"

	LAZYADD(fail_reasons, list(list(reason, file, line)))

/datum/unit_test/proc/get_available_turfs()
	return get_area_turfs(findEventArea())

/// Allocates an instance of the provided type, and places it somewhere in an available loc
/// Instances allocated through this proc will be destroyed when the test is over
/datum/unit_test/proc/allocate(type, ...)
	if(priority > TEST_CREATE_AND_DESTROY) //I'm not using TEST_ASSERT here since these are just numbers that tell nothing useful about the problem.
		TEST_FAIL("allocate() was called for a unit test after 'create_and_destroy' has finished. The unit test room is no longer a reliable testing ground for atoms.")
		return null //you deserve runtime errors for it
	var/list/arguments = args.Copy(2)

	arguments = update_atom_args(type, arguments)

	var/instance
	// Byond will throw an index out of bounds if arguments is empty in that arglist call. Sigh
	if(length(arguments))
		instance = new type(arglist(arguments))
	else
		instance = new type()
	LAZYADD(allocated, instance)
	return instance

/datum/unit_test/proc/update_atom_args(type, list/arguments)
	if(ispath(type, /atom))
		if(!length(arguments))
			return list(pick(get_available_turfs()))
		else if(arguments[1] == null)
			arguments[1] = pick(get_available_turfs())
	return arguments

/datum/unit_test/room_test
	var/list/available_turfs
	var/testing_area_name = "test_generic.dmm"
	var/obj/effect/landmark/bottom_left
	var/obj/effect/landmark/top_right
	/// The bottom left floor turf of the testing zone
	var/turf/run_loc_floor_bottom_left
	/// The top right floor turf of the testing zone
	var/turf/run_loc_floor_top_right

/datum/unit_test/room_test/New()
	. = ..()
	if(!length(available_turfs))
		load_testing_area()
		available_turfs = get_test_turfs()

/datum/unit_test/room_test/Destroy()
	. = ..()
	// Gotta destroy these landmarks so the next test
	// doesn't end up seeing them if it tries to load a new map
	qdel(bottom_left)
	qdel(top_right)

/datum/unit_test/room_test/update_atom_args(type, list/arguments)
	if(ispath(type, /atom))
		if(!length(arguments))
			return list(run_loc_floor_bottom_left)
		else if(arguments[1] == null)
			arguments[1] = run_loc_floor_bottom_left
	return arguments

/datum/unit_test/room_test/get_available_turfs()
	return available_turfs

/datum/unit_test/room_test/proc/load_testing_area()
	var/list/testing_levels = levels_by_trait(UNIT_TEST_LEVEL)
	if(!length(testing_levels))
		TEST_FAIL("Could not find appropriate z-level for spawning test areas")
	var/testing_z_level = pick(testing_levels)
	var/datum/map_template/generic_test_area = GLOB.map_templates[testing_area_name]
	if(!generic_test_area.load(locate(TRANSITIONEDGE + 1, TRANSITIONEDGE + 1, testing_z_level)))
		TEST_FAIL("Could not place generic testing area on z-level [testing_z_level]")

/datum/unit_test/room_test/proc/get_test_turfs()
	var/list/result = list()
	for(var/obj/effect/landmark in GLOB.landmarks_list)
		if(istype(landmark, /obj/effect/landmark/unit_test/bottom_left_corner))
			bottom_left = landmark
			run_loc_floor_bottom_left = get_turf(landmark)
		else if(istype(landmark, /obj/effect/landmark/unit_test/top_right_corner))
			top_right = landmark
			run_loc_floor_top_right = get_turf(landmark)

	if(!(bottom_left && top_right))
		TEST_FAIL("could not find test area landmarks")

	for(var/turf/turf in block(bottom_left.loc, top_right.loc))
		result |= turf

	if(!length(result))
		TEST_FAIL("could not find any test turfs")

	return result

/// Builds (and returns) a list of atoms that we shouldn't initialize in generic testing, like Create and Destroy.
/// It is appreciated to add the reason why the atom shouldn't be initialized if you add it to this list.
/datum/unit_test/proc/build_list_of_uncreatables()
	RETURN_TYPE(/list)
	// The following are just generic, singular types
	var/list/returnable_list = list(
		//Yet more templates
	//	/obj/machinery/restaurant_portal,
		//Template type
	//	/obj/structure/holosign/robot_seat,
		//Singleton
		/mob/dview,
		//Template type
	//	/obj/item/bodypart,
		//This is meant to fail extremely loud every single time it occurs in any environment in any context, and it falsely alarms when this unit test iterates it. Let's not spawn it in.
		/obj/merge_conflict_marker,
		//Not meant to spawn without the machine wand
	//	/obj/effect/bug_moving,
		//Single use case holder atom requiring a user
	//	/atom/movable/looking_holder,
		//Should not exist outside of holders
	//	/obj/effect/decal/cleanable/blood/trail,
		//Should not exist outside of ethereals
	//	/obj/item/stock_parts/power_store/cell/ethereal,
		// Abstract type, controlled by turfs
		// Literally errors on creation/deletion
		/atom/movable/lighting_object,
	)

	// Everything that follows is a typesof() check.
	returnable_list += typesof(/obj/machinery/doomsday_device) //This should be obvious
//	returnable_list += typesof(/obj/machinery/launchpad/briefcase) //briefcase launchpads erroring
	//Say it with me now, type template
	returnable_list += typesof(/obj/effect/mapping_helpers)
	//This turf existing is an error in and of itself
//	returnable_list += typesof(/turf/baseturf_skipover)
	returnable_list += typesof(/turf/baseturf_bottom)
	//This demands a borg, so we'll let if off easy
	returnable_list += typesof(/obj/item/pda/silicon)
	//This one demands a computer, ditto
//	returnable_list += typesof(/obj/item/modular_computer/processor)
	//Very finiky, blacklisting to make things easier
//	returnable_list += typesof(/obj/item/poster/wanted)
	//Needs clients / mobs to observe it to exist. Also includes hallucinations.
	returnable_list += typesof(/obj/effect/client_image_holder)
	//Same to above. Needs a client / mob / hallucination to observe it to exist.
//	returnable_list += typesof(/obj/projectile/hallucination)
//	returnable_list += typesof(/obj/item/hallucinated)
	//We don't have a pod
	returnable_list += typesof(/obj/effect/pod_landingzone_effect)
	returnable_list += typesof(/obj/effect/pod_landingzone)
	//We have a baseturf limit of 10, adding more than 10 baseturf helpers will kill CI, so here's a future edge case to fix.
	returnable_list += typesof(/obj/effect/baseturf_helper)
	//No tauma to pass in
//	returnable_list += typesof(/mob/eye/imaginary_friend)
	//No heart to give
//	returnable_list += typesof(/obj/structure/ethereal_crystal)
	//No linked console
//	returnable_list += typesof(/mob/eye/camera/remote/base_construction)
	//See above
//	returnable_list += typesof(/mob/eye/camera/remote/shuttle_docker)
	//Hangs a ref post invoke async, which we don't support. Could put a qdeleted check but it feels hacky
//	returnable_list += typesof(/obj/effect/anomaly/grav/high)
	//See above
	returnable_list += typesof(/obj/effect/timestop)
	//Sparks can ignite a number of things, causing a fire to burn the floor away. Only you can prevent CI fires
	returnable_list += typesof(/obj/effect/particle_effect/sparks)
	//See above - These are one of those things.
//	returnable_list += typesof(/obj/effect/decal/cleanable/fuel_pool)
	//Invoke async in init, skippppp
//	returnable_list += typesof(/mob/living/silicon/robot/model)
	//This lad also sleeps
//	returnable_list += typesof(/obj/item/hilbertshotel)
	//this boi spawns turf changing stuff, and it stacks and causes pain. Let's just not
	returnable_list += typesof(/obj/effect/sliding_puzzle)
	//these can explode and cause the turf to be destroyed at unexpected moments
	returnable_list += typesof(/obj/effect/mine)
	returnable_list += typesof(/obj/effect/spawner/random_spawners/syndicate/trap/mine)
//	returnable_list += typesof(/obj/item/minespawner)
	//Stacks baseturfs, can't be tested here
	returnable_list += typesof(/obj/effect/temp_visual/lava_warning)
	//Stacks baseturfs, can't be tested here
//	returnable_list += typesof(/obj/effect/landmark/ctf)
	//Our system doesn't support it without warning spam from unregister calls on things that never registered
	returnable_list += typesof(/obj/docking_port)
	//Asks for a shuttle that may not exist, let's leave it alone
//	returnable_list += typesof(/obj/item/pinpointer/shuttle)
	//This spawns beams as a part of init, which can sleep past an async proc. This hangs a ref, and fucks us. It's only a problem here because the beam sleeps with CHECK_TICK
//	returnable_list += typesof(/obj/structure/alien/resin/flower_bud)
	//Needs a linked mecha
//	returnable_list += typesof(/obj/effect/skyfall_landingzone)
	//Expects a mob to holderize, we have nothing to give
	returnable_list += typesof(/obj/item/holder)
	//Needs cards passed into the initilazation args
//	returnable_list += typesof(/obj/item/toy/cards/cardhand)
	//Needs a holodeck area linked to it which is not guarenteed to exist and technically is supposed to have a 1:1 relationship with computer anyway.
	returnable_list += typesof(/obj/machinery/computer/HolodeckControl)
	//runtimes if not paired with a landmark
//	returnable_list += typesof(/obj/structure/transport/linear)
	// Runtimes if the associated machinery does not exist, but not the base type
	returnable_list += subtypesof(/obj/machinery/embedded_controller/radio/airlock/airlock_controller)
	// Can't spawn openspace above nothing, it'll get pissy at me
	returnable_list += typesof(/turf/space/openspace)
	returnable_list += typesof(/turf/simulated/openspace)
//	returnable_list += typesof(/obj/item/robot_model) // These should never be spawned outside of a robot.
	//A lot of these depend on a hud datum to function and should not be created in a vacuum
	returnable_list += typesof(/atom/movable/screen)

	//1984 edition (along with some alterations of the paths above)
	//Requires blood color and already checks for it in every place it spawned
	returnable_list += typesof(/obj/effect/temp_visual/dir_setting/bloodsplatter)
	// Can't exist without player
	returnable_list += typesof(/obj/effect/hallucination)
	// Can't exist without a water tank
	returnable_list += typesof(/obj/item/reagent_containers/spray/mister)
	// See above
	returnable_list += typesof(/obj/item/extinguisher/mini/nozzle)
	// Can't exist without a suit
	returnable_list += typesof(/obj/item/clothing/head/hooded)
	// Instantiated only once per spell type and then cached in a static list for this type to reuse, are not meant to be deleted
	returnable_list += typesof(/datum/spell_handler)
	return returnable_list
