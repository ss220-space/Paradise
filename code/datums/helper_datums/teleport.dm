#define TELEPORT_BLOCKER_CONTENT_SEARCH_DEPTH 3
#define BLUESPACE_INTERFERENCE_SHUNT_ATTEMPTS 15

/**
 * Standard teleport wrapper, routed through the science instant teleport (`/datum/teleport/instant/science`).
 *
 * Use this for the vast majority of teleports. Unlike [do_direct_teleport], it runs the science
 * precision logic, so bags/sacks of holding in the teleatom's contents randomise the landing turf.
 *
 * Interference arguments, shared with the procs below:
 * * always_precise - skip the BoH/SoH precision randomisation AND ignore stationary BSIG fields,
 *   landing exactly on the requested turf. Does not bypass [TRAIT_NO_TELEPORT] blockers.
 * * blocked_when_interfered - if inside a BSIG field, fully block the teleport instead of shunting
 *   it to the field edge. Has no effect together with `always_precise` (which ignores fields).
 * * ignore_blocking_traits - skip the [TRAIT_NO_TELEPORT] blocker check entirely.
 *
 * Returns TRUE on a successful teleport, FALSE otherwise.
 */
/proc/do_teleport(ateleatom, adestination, aprecision = 0, afteleport = 1, aeffectin = null, aeffectout = null, asoundin = null, asoundout = null, bypass_area_flag = FALSE, always_precise = FALSE, blocked_when_interfered = FALSE, ignore_blocking_traits = FALSE)
	var/datum/teleport/instant/science/D = new
	if(D.start(arglist(args)))
		return TRUE
	return FALSE

/**
 * Direct teleport variant that takes explicit, typed arguments and skips the science precision logic.
 *
 * Behaves like [do_teleport] regarding the interference arguments, but never applies the
 * bag/sack of holding precision randomisation, so it always aims for `destination` (+/- `precision`).
 * Defaults `force_teleport` to TRUE. Prefer this when you need a predictable, exact teleport.
 *
 * Returns TRUE on a successful teleport, FALSE otherwise.
 */
/proc/do_direct_teleport(atom/movable/teleatom, atom/destination, precision = 0, force_teleport = TRUE, datum/effect_system/effectin = null, datum/effect_system/effectout = null, soundin = null, soundout = null, bypass_area_flag = FALSE, always_precise = FALSE, blocked_when_interfered = FALSE, ignore_blocking_traits = FALSE)
	if(!teleatom || !destination)
		return FALSE

	var/datum/teleport/instant/direct_teleport = new
	return direct_teleport.start(
		teleatom,
		destination,
		precision,
		force_teleport,
		effectin,
		effectout,
		soundin,
		soundout,
		bypass_area_flag,
		always_precise,
		blocked_when_interfered,
		ignore_blocking_traits
	)

/**
 * Magical teleport: use this for spells, runes and other supernatural displacement.
 *
 * Differs from [do_teleport] in two ways:
 * * It is gated by the ITB collar — [itb_blocks_teleport] is checked first, and a worn, active ITB
 *   aborts the teleport (notifying `notified_user` with `block_message`).
 * * Magic ignores mundane bluespace interference: it always teleports precisely and bypasses
 *   [TRAIT_NO_TELEPORT] blockers (only the ITB stops it).
 *
 * Returns TRUE on a successful teleport, FALSE otherwise.
 */
/proc/do_magic_teleport(atom/movable/teleatom, atom/destination, precision = 0, force_teleport = TRUE, datum/effect_system/effectin = null, datum/effect_system/effectout = null, soundin = null, soundout = null, bypass_area_flag = FALSE, mob/notified_user = null, block_message = null)
	if(itb_blocks_teleport(teleatom, notified_user, block_message))
		return FALSE
	return do_teleport(
		teleatom,
		destination,
		precision,
		force_teleport,
		effectin,
		effectout,
		soundin,
		soundout,
		bypass_area_flag,
		always_precise = TRUE,
		ignore_blocking_traits = TRUE
	)

/// As [do_magic_teleport], but routed through [do_direct_teleport] (explicit args, no science
/// precision logic) and defaulting `bypass_area_flag` to TRUE. Still gated by the ITB collar.
/proc/do_magic_direct_teleport(atom/movable/teleatom, atom/destination, precision = 0, force_teleport = TRUE, datum/effect_system/effectin = null, datum/effect_system/effectout = null, soundin = null, soundout = null, bypass_area_flag = TRUE, mob/notified_user = null, block_message = null)
	if(itb_blocks_teleport(teleatom, notified_user, block_message))
		return FALSE
	return do_direct_teleport(
		teleatom,
		destination,
		precision,
		force_teleport,
		effectin,
		effectout,
		soundin,
		soundout,
		bypass_area_flag,
		always_precise = TRUE,
		ignore_blocking_traits = TRUE
	)

/// Returns the mob carrying `blocking_trait` for a single living atom: either `living_teleatom`
/// itself or one of the mobs buckled to it. Returns null if none is found.
/proc/get_living_teleport_blocker(mob/living/living_teleatom, blocking_trait = TRAIT_NO_TELEPORT)
	if(!living_teleatom)
		return null
	if(HAS_TRAIT(living_teleatom, blocking_trait))
		return living_teleatom
	if(living_teleatom.has_buckled_mobs())
		var/list/buckled = living_teleatom.buckled_mobs
		for(var/mob/living/buckled_living as anything in buckled)
			if(HAS_TRAIT(buckled_living, blocking_trait))
				return buckled_living
	return null

/// Recursively searches `container`'s contents (up to [TELEPORT_BLOCKER_CONTENT_SEARCH_DEPTH] deep)
/// for a living mob carrying `blocking_trait`, e.g. someone stuffed in a locker or bag. Returns it or null.
/proc/get_contained_teleport_blocker(atom/movable/container, blocking_trait = TRAIT_NO_TELEPORT, depth = 0)
	if(!container || depth >= TELEPORT_BLOCKER_CONTENT_SEARCH_DEPTH)
		return null

	var/list/contents = container.contents
	for(var/atom/movable/contained_atom as anything in contents)
		if(QDELETED(contained_atom))
			continue
		if(isliving(contained_atom))
			var/mob/living/contained_living = contained_atom
			var/mob/living/contained_blocker = get_living_teleport_blocker(contained_living, blocking_trait)
			if(contained_blocker)
				return contained_blocker
		var/list/contained_contents = contained_atom.contents
		if(length(contained_contents))
			var/mob/living/found_blocker = get_contained_teleport_blocker(contained_atom, blocking_trait, depth + 1)
			if(found_blocker)
				return found_blocker
	return null

/// Top-level blocker lookup for an arbitrary teleatom. Checks the atom itself, mobs buckled to it,
/// a mecha occupant, and finally its nested contents, returning the first mob with `blocking_trait`.
/proc/get_teleport_blocking_living(atom/movable/teleatom, blocking_trait = TRAIT_NO_TELEPORT)
	if(!teleatom)
		return null
	if(isliving(teleatom))
		var/mob/living/living_teleatom = teleatom
		var/mob/living/living_blocker = get_living_teleport_blocker(living_teleatom, blocking_trait)
		if(living_blocker)
			return living_blocker
	if(teleatom.has_buckled_mobs())
		var/list/buckled = teleatom.buckled_mobs
		for(var/mob/living/buckled_living as anything in buckled)
			var/mob/living/buckled_blocker = get_living_teleport_blocker(buckled_living, blocking_trait)
			if(buckled_blocker)
				return buckled_blocker
	if(ismecha(teleatom))
		var/obj/mecha/mecha = teleatom
		if(isliving(mecha.occupant))
			var/mob/living/mecha_occupant = mecha.occupant
			var/mob/living/mecha_blocker = get_living_teleport_blocker(mecha_occupant, blocking_trait)
			if(mecha_blocker)
				return mecha_blocker
	return get_contained_teleport_blocker(teleatom, blocking_trait)

/// Returns TRUE if `teleatom` cannot be teleported from where it currently stands: either it (or a
/// mob it carries) has a teleport-blocking trait (ITB collar, BSIG-P), or it is inside an active
/// stationary BSIG field. Use this for "step-through" movers (e.g. the gateway) that don't run a
/// full [do_teleport] but should still respect bluespace interference.
/proc/is_teleport_blocked(atom/movable/teleatom)
	if(!teleatom)
		return FALSE
	if(get_teleport_blocking_living(teleatom))
		return TRUE
	var/turf/origin = get_turf(teleatom)
	if(!origin)
		return FALSE
	return SEND_SIGNAL(teleatom, COMSIG_MOVABLE_TELEPORTING, origin, origin, null) & COMPONENT_BLOCK_TELEPORT

/proc/notify_bluespace_interference(atom/movable/notified_atom, atom/movable/teleatom)
	if(!isliving(notified_atom))
		return
	var/mob/living/notified_living = notified_atom
	to_chat(notified_living, span_warning("Блюспейс-помехи предотвращают телепортацию!"))
	if(notified_atom == teleatom || !isliving(teleatom))
		return
	var/mob/living/living_teleatom = teleatom
	to_chat(living_teleatom, span_warning("Блюспейс-помехи предотвращают телепортацию!"))

/proc/notify_bluespace_interference_shunt(atom/movable/teleatom)
	if(!isliving(teleatom))
		return
	var/mob/living/living_teleatom = teleatom
	to_chat(living_teleatom, span_warning("Блюспейс-помехи искажают телепортацию!"))

/**
 * Resolves the turf a teleport should actually land on after interference is accounted for.
 *
 * First respects [TRAIT_NO_TELEPORT] blockers (unless `ignore_blocking_traits`), then sends the
 * teleport through the BSIG field handlers via signals. A field may block the teleport (returns null),
 * shunt it to its edge (returns a different turf), or leave it untouched. With `always_precise` the
 * fields are ignored and the original `destination` is returned. Set `notify` to message the mob on
 * a block/shunt. Returns the final destination turf, or null if the teleport should be cancelled.
 */
/proc/get_teleport_intercepted_destination(atom/movable/teleatom, turf/origin, turf/destination, always_precise = FALSE, blocked_when_interfered = FALSE, notify = TRUE, ignore_blocking_traits = FALSE)
	if(!teleatom || !origin || !destination)
		return null

	if(!ignore_blocking_traits)
		var/mob/living/teleport_blocker = get_teleport_blocking_living(teleatom)
		if(teleport_blocker)
			if(notify)
				notify_bluespace_interference(teleport_blocker, teleatom)
			return null

	var/list/teleport_data = list(
		TELEPORT_INTERCEPT_TELEATOM = teleatom,
		TELEPORT_INTERCEPT_DESTINATION = destination,
		TELEPORT_INTERCEPT_IGNORE_BLUESPACE = always_precise,
		TELEPORT_INTERCEPT_BLOCK_BLUESPACE = blocked_when_interfered,
		TELEPORT_INTERCEPT_BLUESPACE_SHUNTED = FALSE,
	)

	if(SEND_SIGNAL(teleatom, COMSIG_MOVABLE_TELEPORTING, origin, destination, teleport_data) & COMPONENT_BLOCK_TELEPORT)
		if(notify && teleport_data[TELEPORT_INTERCEPT_BLUESPACE_BLOCKED])
			notify_bluespace_interference(teleatom, teleatom)
		return null

	var/turf/current_destination = destination
	if(always_precise)
		teleport_data[TELEPORT_INTERCEPT_DESTINATION] = current_destination
		if(SEND_SIGNAL(current_destination, COMSIG_ATOM_INTERCEPT_TELEPORTING, origin, teleport_data) & COMPONENT_BLOCK_TELEPORT)
			return null
		return teleport_data[TELEPORT_INTERCEPT_DESTINATION]

	var/shunt_attempts = BLUESPACE_INTERFERENCE_SHUNT_ATTEMPTS
	while(shunt_attempts > 0)
		shunt_attempts--
		teleport_data[TELEPORT_INTERCEPT_DESTINATION] = current_destination
		if(SEND_SIGNAL(current_destination, COMSIG_ATOM_INTERCEPT_TELEPORTING, origin, teleport_data) & COMPONENT_BLOCK_TELEPORT)
			if(notify && teleport_data[TELEPORT_INTERCEPT_BLUESPACE_BLOCKED])
				notify_bluespace_interference(teleatom, teleatom)
			return null

		var/turf/new_destination = teleport_data[TELEPORT_INTERCEPT_DESTINATION]
		if(!new_destination)
			return null
		if(new_destination == current_destination)
			if(notify && teleport_data[TELEPORT_INTERCEPT_BLUESPACE_SHUNTED])
				notify_bluespace_interference_shunt(teleatom)
			return current_destination
		current_destination = new_destination

	return null

/datum/teleport
	var/atom/movable/teleatom //atom to teleport
	var/atom/destination //destination to teleport to
	var/precision = 0 //teleport precision
	var/datum/effect_system/effectin //effect to show right before teleportation
	var/datum/effect_system/effectout //effect to show right after teleportation
	var/soundin //soundfile to play before teleportation
	var/soundout //soundfile to play after teleportation
	var/force_teleport = 1 //if false, teleport will use Move() proc (dense objects will prevent teleportation)
	var/ignore_area_flag = FALSE
	/// Skip BoH/SoH precision randomisation and ignore stationary BSIG fields (see [/proc/do_teleport]).
	var/always_precise = FALSE
	/// Fully block the teleport inside a BSIG field instead of shunting it to the field edge.
	var/blocked_when_interfered = FALSE
	/// Skip the [TRAIT_NO_TELEPORT] blocker check entirely.
	var/ignore_blocking_traits = FALSE

/datum/teleport/proc/start(ateleatom, adestination, aprecision = 0, afteleport = 1, aeffectin = null, aeffectout = null, asoundin = null, asoundout = null, bypass_area_flag = FALSE, always_precise = FALSE, blocked_when_interfered = FALSE, ignore_blocking_traits = FALSE)
	if(!initTeleport(arglist(args)))
		return FALSE
	return TRUE

/datum/teleport/proc/initTeleport(ateleatom, adestination, aprecision, afteleport, aeffectin, aeffectout, asoundin, asoundout, bypass_area_flag = FALSE, always_precise = FALSE, blocked_when_interfered = FALSE, ignore_blocking_traits = FALSE)
	if(!setTeleatom(ateleatom))
		return FALSE
	if(!setDestination(adestination))
		return FALSE
	if(!setPrecision(aprecision, always_precise))
		return FALSE
	setEffects(aeffectin, aeffectout)
	setForceTeleport(afteleport)
	setSounds(asoundin, asoundout)
	ignore_area_flag = bypass_area_flag
	src.always_precise = always_precise
	src.blocked_when_interfered = blocked_when_interfered
	src.ignore_blocking_traits = ignore_blocking_traits
	return TRUE

//must succeed
/datum/teleport/proc/setPrecision(aprecision, always_precise)
	if(isnum(aprecision))
		precision = aprecision
		return TRUE
	return FALSE

//must succeed
/datum/teleport/proc/setDestination(atom/adestination)
	if(istype(adestination))
		destination = adestination
		return TRUE
	return FALSE

//must succeed in most cases
/datum/teleport/proc/setTeleatom(atom/movable/ateleatom)
	if(iseffect(ateleatom) && !istype(ateleatom, /obj/effect/dummy/chameleon) && !isanomaly(ateleatom))
		qdel(ateleatom)
		return FALSE
	if(istype(ateleatom))
		teleatom = ateleatom
		return TRUE
	return FALSE

//custom effects must be properly set up first for instant-type teleports
//optional
/datum/teleport/proc/setEffects(datum/effect_system/aeffectin = null, datum/effect_system/aeffectout = null)
	effectin = istype(aeffectin) ? aeffectin : null
	effectout = istype(aeffectout) ? aeffectout : null
	return TRUE

//optional
/datum/teleport/proc/setForceTeleport(afteleport)
	force_teleport = afteleport
	return TRUE

//optional
/datum/teleport/proc/setSounds(asoundin = null, asoundout = null)
	soundin = isfile(asoundin) ? asoundin : null
	soundout = isfile(asoundout) ? asoundout : null
	return TRUE

//placeholder
/datum/teleport/proc/teleportChecks()
	return TRUE

/datum/teleport/proc/playSpecials(atom/location, datum/effect_system/effect, sound)
	if(location)
		if(effect)
			spawn(-1)
				src = null
				effect.attach(location)
				effect.start()
		if(sound)
			spawn(-1)
				src = null
				playsound(location, sound, 60, TRUE)
	return

//do the monkey dance
/datum/teleport/proc/doTeleport()

	var/atom/movable/tele_atom = teleatom
	var/turf/destturf
	var/turf/curturf = get_turf(tele_atom)
	var/area/curarea = get_area(curturf)

	if(precision)
		var/list/posturfs = list()
		var/center = get_turf(destination)
		if(!center)
			center = destination
		for(var/turf/T in range(precision, center))
			posturfs.Add(T)
		destturf = safepick(posturfs)
	else
		destturf = get_turf(destination)

	if(!destturf || !curturf)
		return FALSE

	destturf = get_teleport_intercepted_destination(tele_atom, curturf, destturf, always_precise, blocked_when_interfered, ignore_blocking_traits = ignore_blocking_traits)
	if(!destturf)
		return FALSE

	if(!is_teleport_allowed(destturf.z) && !ignore_area_flag)
		return FALSE
	// Only check the destination zlevel for is_teleport_allowed. Checking origin as well breaks ERT teleporters.

	var/area/destarea = get_area(destturf)

	if(!ignore_area_flag)
		if(curarea.tele_proof)
			return FALSE
		if(destarea.tele_proof)
			return FALSE

	playSpecials(curturf, effectin, soundin)
	var/success = tele_atom.forceMove(destturf)
	if(success)
		playSpecials(destturf, effectout, soundout)

	if(isliving(tele_atom))
		var/mob/living/living_teleatom = tele_atom
		if(living_teleatom.buckled)
			living_teleatom.buckled.unbuckle_mob(living_teleatom, force = TRUE)
		if(living_teleatom.has_buckled_mobs())
			living_teleatom.unbuckle_all_mobs(force = TRUE)

	tele_atom.on_teleported()

	return TRUE

/datum/teleport/proc/teleport()
	if(teleportChecks())
		return doTeleport()
	return FALSE

/datum/teleport/instant/start(ateleatom, adestination, aprecision = 0, afteleport = 1, aeffectin = null, aeffectout = null, asoundin = null, asoundout = null, bypass_area_flag = FALSE, always_precise = FALSE, blocked_when_interfered = FALSE, ignore_blocking_traits = FALSE)
	if(..())
		if(teleport())
			return TRUE
	return FALSE

/datum/teleport/instant/science

/datum/teleport/instant/science/setEffects(datum/effect_system/aeffectin, datum/effect_system/aeffectout)
	if(aeffectin == null || aeffectout == null)
		var/datum/effect_system/spark_spread/aeffect = new
		aeffect.set_up(5, 1, teleatom)
		effectin = effectin || aeffect
		effectout = effectout || aeffect
		return TRUE
	else
		return ..()

/datum/teleport/instant/science/setPrecision(aprecision, always_precise)
	..()
	if(!is_admin_level(destination.z))
		if(always_precise)
			return TRUE

		if(istype(teleatom, /obj/item/storage/backpack/holding))
			precision = rand(1, 100)

		var/list/bagholding = teleatom.search_contents_for(/obj/item/storage/backpack/holding)
		if(length(bagholding))
			precision = max(rand(1, 100) * length(bagholding), 100)
			if(isliving(teleatom))
				var/mob/living/MM = teleatom
				to_chat(MM, span_warning("The bluespace interface on your bag of holding interferes with the teleport!"))

		var/list/beltholding = teleatom.search_contents_for(/obj/item/storage/belt/bluespace)
		if(length(beltholding))
			precision = max(rand(1, 100) * length(beltholding), 100)
			if(isliving(teleatom))
				var/mob/living/MM = teleatom
				to_chat(MM, span_warning("The bluespace interface on your belt of holding interferes with the teleport!"))

		var/list/trashbagholding = teleatom.search_contents_for(/obj/item/storage/bag/trash/bluespace)
		if(length(trashbagholding))
			precision = max(rand(1, 100) * length(trashbagholding), 100)
			if(isliving(teleatom))
				var/mob/living/MM = teleatom
				to_chat(MM, span_warning("The bluespace interface on your trashbag of holding interferes with the teleport!"))

		var/list/miningsatholding = teleatom.search_contents_for(/obj/item/storage/bag/ore/holding)
		if(length(miningsatholding))
			precision = max(rand(1, 100) * length(miningsatholding), 100)
			if(isliving(teleatom))
				var/mob/living/MM = teleatom
				to_chat(MM, span_warning("The bluespace interface on your mining satchel of holding interferes with the teleport!"))
	return TRUE

#undef BLUESPACE_INTERFERENCE_SHUNT_ATTEMPTS

// Random safe location finder
/proc/find_safe_turf(zlevel, list/zlevels)
	if(!zlevels)
		if(zlevel)
			zlevels = list(zlevel)
		else
			zlevels = levels_by_trait(STATION_LEVEL)
	var/cycles = 1000
	for(var/cycle in 1 to cycles)
		// DRUNK DIALLING WOOOOOOOOO
		var/x = rand(1, world.maxx)
		var/y = rand(1, world.maxy)
		var/z = pick(zlevels)
		var/turf/random_location = locate(x, y, z)

		if(random_location.is_safe())
			return random_location

/**
 * Checks to see if a given turf is a "safe" location. Being safe requires the following to be true:
 * * Must be a [floor][/turf/simulated/floor]
 * * Must have air, and that air must have [breathable bounds][/proc/check_gases] for humans
 * * Must have goldilocks temperature
 * * Must have safe pressure
 *
 * Optionally:
 * * extended_safety_checks: Will make additional checks for turfs that technically pass all previous requirements but still may not be safe
 * * dense_atoms: Must be unobstructed (no blocking objects such as machines, structures or mobs)
 * * no_teleport: Must not have [NOTELEPORT][/area/var/area_flag]
 *
 * Returns TRUE if all conditions pass, FALSE otherwise.
 */
/proc/is_safe_turf(turf/random_location, extended_safety_checks = FALSE, dense_atoms = FALSE, no_teleport = FALSE)
	//SHOULD_BE_PURE(TRUE)

	. = FALSE
	if(!isfloorturf(random_location))
		return
	var/turf/simulated/floor/floor_turf = random_location
	//var/area/destination_area = floor_turf.loc

	if(no_teleport /*&& (destination_area.area_flags & NOTELEPORT)*/)
		return

	var/datum/gas_mixture/floor_gas_mixture = floor_turf.return_analyzable_air()
	if(!floor_gas_mixture)
		return

	var/static/list/gases_to_check = list(
		TLV_O2 = list(/obj/item/organ/internal/lungs::safe_oxygen_min, 100),
		TLV_N2,
		TLV_CO2 = list(0, /obj/item/organ/internal/lungs::safe_co2_max)
	)

	if(!check_gases(floor_gas_mixture.get_interesting(), gases_to_check))
		return FALSE

	// Aim for goldilocks temperatures and pressure
	if((floor_gas_mixture.temperature() <= BODYTEMP_COLD_DAMAGE_LIMIT) || (floor_gas_mixture.temperature() >= BODYTEMP_HEAT_DAMAGE_LIMIT))
		return
	var/pressure = floor_gas_mixture.return_pressure()
	if((pressure <= HAZARD_LOW_PRESSURE) || (pressure >= HAZARD_HIGH_PRESSURE))
		return

	if(extended_safety_checks)
		if(islava(floor_turf)) //chasms aren't /floor, and so are pre-filtered
			var/turf/simulated/floor/lava/lava_turf = floor_turf // Cyberboss: okay, this makes no sense and I don't understand the above comment, but I'm too lazy to check history to see what it's supposed to do right now
			if(!lava_turf.is_safe())
				return

	// Check that we're not warping onto a table or window
	if(!dense_atoms)
		var/density_found = FALSE
		for(var/atom/movable/found_movable in floor_turf)
			if(found_movable.density)
				density_found = TRUE
				break
		if(density_found)
			return

	// DING! You have passed the gauntlet, and are "probably" safe.
	return TRUE

#undef TELEPORT_BLOCKER_CONTENT_SEARCH_DEPTH
