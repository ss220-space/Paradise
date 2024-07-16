/turf/simulated
	name = "station"
	var/wet = 0
	var/image/wet_overlay = null
	var/mutable_appearance/melting_olay

	var/thermite = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	var/to_be_destroyed = 0 //Used for fire, if a melting temperature was reached, it will be destroyed
	var/max_fire_temperature_sustained = 0 //The max temperature of the fire which it was subjected to

	/// The excited group we're linked to. Used for zone atmos calculations
	var/datum/excited_group/excited_group
	/// Is this turf active?
	var/excited = 0
	/// Was this turf recently activated? Probably not needed anymore
	var/recently_active = 0
	var/archived_cycle = 0
	var/current_cycle = 0
	/// The active hotspot on this turf. The fact this is done through a literal object is painful
	var/obj/effect/hotspot/active_hotspot
	/// The temp we were when we got archived
	var/temperature_archived
	/// Current gas overlay. Can be set to plasma or sleeping_gas
	var/atmos_overlay_type = null
	/// If a fire is ongoing, how much fuel did we burn last tick?
	/// Value is not updated while below PLASMA_MINIMUM_BURN_TEMPERATURE.
	var/fuel_burnt = 0

/turf/simulated/proc/break_tile()
	return

/turf/simulated/proc/burn_tile()
	return

/turf/simulated/water_act(volume, temperature, source)
	. = ..()

	if(volume >= 3)
		MakeSlippery(TURF_WET_WATER, 80 SECONDS)

	quench(1000, 2)

/// Quenches any fire on the turf, and if it does, cools down the turf's air by the given parameters.
/turf/simulated/proc/quench(delta, divisor)
	var/found = FALSE
	for(var/obj/effect/hotspot/hotspot in src)
		qdel(hotspot)
		found = TRUE

	if(!found)
		return

	var/datum/milla_safe/turf_cool/milla = new()
	milla.invoke_async(src, delta, divisor)

/datum/milla_safe/turf_cool

/datum/milla_safe/turf_cool/on_run(turf/T, delta, divisor)
	var/datum/gas_mixture/air = get_turf_air(T)
	air.set_temperature(max(min(air.temperature()-delta * divisor,air.temperature() / divisor), TCMB))
	air.react()

/turf/simulated/proc/MakeSlippery(wet_setting = TURF_WET_WATER, min_wet_time = 0, wet_time_to_add = 0, max_wet_time = MAXIMUM_WET_TIME, permanent = FALSE, should_display_overlay = TRUE)
	AddComponent(/datum/component/wet_floor, wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent, should_display_overlay)

/turf/simulated/proc/MakeDry(wet_setting = TURF_WET_WATER, immediate = FALSE, amount = INFINITY)
	SEND_SIGNAL(src, COMSIG_TURF_MAKE_DRY, wet_setting, immediate, amount)

/turf/simulated/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	var/mob/living/simple_animal/Hulk = arrived
	if(istype(arrived, /mob/living/simple_animal/hulk))
		if(Hulk.body_position != LYING_DOWN)
			playsound(src,'sound/effects/hulk_step.ogg', CHANNEL_BUZZ)
		if(istype(arrived, /mob/living/simple_animal/hulk/clown_hulk))
			if(Hulk.body_position != LYING_DOWN)
				playsound(src, "clownstep", CHANNEL_BUZZ)
	if(istype(arrived, /mob/living/simple_animal/hostile/shitcur_goblin))
		playsound(src, "clownstep", CHANNEL_BUZZ)


/turf/simulated/copyTurf(turf/simulated/copy_to_turf, copy_air = FALSE)
	. = ..()
	ASSERT(istype(copy_to_turf, /turf/simulated))
	var/datum/component/wet_floor/slip = GetComponent(/datum/component/wet_floor)
	if(slip)
		var/datum/component/wet_floor/new_wet_floor_component = copy_to_turf.AddComponent(/datum/component/wet_floor)
		new_wet_floor_component.InheritComponent(slip)

/turf/simulated/ChangeTurf(path, defer_change = FALSE, keep_icon = TRUE, ignore_air = FALSE, copy_existing_baseturf = TRUE)
	. = ..()
	queue_smooth_neighbors(src)

/turf/simulated/AfterChange(ignore_air = FALSE, keep_cabling = FALSE, oldType)
	..()
	RemoveLattice()
	if(!ignore_air)
		assimilate_air()

//////Assimilate Air//////
/turf/simulated/proc/assimilate_air()
	if(blocks_air || !air) // Fuck off
		return
	var/aoxy = 0
	var/anitro = 0
	var/aco = 0
	var/atox = 0
	var/asleep = 0
	var/ab = 0
	var/atemp = TCMB

	var/turf_count = 0

	for(var/turf/T in atmos_adjacent_turfs)
		if(isspaceturf(T))//Counted as no air
			turf_count++//Considered a valid turf for air calcs
			continue
		else if(isfloorturf(T))
			var/turf/simulated/S = T
			if(S.air)//Add the air's contents to the holders
				aoxy += S.air.oxygen
				anitro += S.air.nitrogen
				aco += S.air.carbon_dioxide
				atox += S.air.toxins
				asleep += S.air.sleeping_agent
				ab += S.air.agent_b
				atemp += S.air.temperature
			turf_count++
	air.oxygen = (aoxy / max(turf_count, 1)) //Averages contents of the turfs, ignoring walls and the like
	air.nitrogen = (anitro / max(turf_count, 1))
	air.carbon_dioxide = (aco / max(turf_count, 1))
	air.toxins = (atox / max(turf_count, 1))
	air.sleeping_agent = (asleep / max(turf_count, 1))
	air.agent_b = (ab / max(turf_count, 1))
	air.temperature = (atemp / max(turf_count, 1))
	if(SSair)
		SSair.add_to_active(src)

/turf/simulated/proc/is_shielded()
	return

// for floors and walls to go inside our turf
/turf/simulated/zPassIn(direction)
	if(density)
		return FALSE // wall
	if(direction != DOWN)
		return FALSE
	for(var/obj/on_us in contents)
		if(on_us.obj_flags & BLOCK_Z_IN_DOWN)
			return FALSE
	return TRUE

/turf/simulated/zPassOut(direction)
	if(density)
		return FALSE
	if(direction != UP) // only up. no down from the floor
		return FALSE
	for(var/obj/on_us in contents)
		if(on_us.obj_flags & BLOCK_Z_OUT_UP)
			return FALSE
	return TRUE

/turf/simulated/zAirIn(direction, turf/source)
	return (!blocks_air && (direction == DOWN))

/turf/simulated/zAirOut(direction, turf/source)
	return (!blocks_air && (direction == UP))

/turf/simulated/handle_slip(mob/living/carbon/slipper, weaken_amount, obj/slippable, lube_flags, tilesSlipped)
	if(slipper.movement_type & MOVETYPES_NOT_TOUCHING_GROUND)
		return FALSE
	if(!slipper.has_gravity(src))
		return FALSE

	var/slide_distance = isnull(tilesSlipped) ? 4 : tilesSlipped
	if(lube_flags & SLIDE_ICE)
		// Ice slides only go 1 tile, this is so you will slip across ice until you reach a non-slip tile
		slide_distance = 1
	else if(HAS_TRAIT(slipper, TRAIT_NO_SLIP_SLIDE))
		// Stops sliding
		slide_distance = 0

	var/obj/buckled_obj
	if(slipper.buckled)
		//can't slip while buckled unless it's lube.
		if(!(lube_flags & SLIP_IGNORE_NO_SLIP_WATER))
			return FALSE
		buckled_obj = slipper.buckled
	else
		// can't slip unbuckled mob if they're lying or can't fall.
		if(!(lube_flags & SLIP_WHEN_LYING) && (slipper.body_position == LYING_DOWN || !(slipper.status_flags & CANKNOCKDOWN)))
			return FALSE
		if(slipper.m_intent == MOVE_INTENT_WALK && (lube_flags & NO_SLIP_WHEN_WALKING))
			return FALSE

	if(!(lube_flags & SLIDE_ICE))
		// Ice slides are intended to be combo'd so don't give the feedback
		to_chat(slipper, span_notice("You slipped[slippable ? " on the [slippable.name]" : ""]!"))
		playsound(slipper.loc, 'sound/misc/slip.ogg', 50, TRUE, -3)

	SEND_SIGNAL(slipper, COMSIG_ON_CARBON_SLIP)

	var/old_dir = slipper.dir
	// If this was part of diagonal move slipping will stop it.
	slipper.moving_diagonally = NONE
	if(lube_flags & SLIDE_ICE)
		// They need to be kept upright to maintain the combo effect (So don't weaken)
		slipper.Immobilize(1 SECONDS)
	else
		slipper.stop_pulling()
		slipper.Weaken(weaken_amount)

	if(buckled_obj)
		buckled_obj.unbuckle_mob(slipper)
		// This is added onto the end so they slip "out of their chair" (one tile)
		lube_flags |= SLIDE_ICE
		slide_distance = 1

	if(slide_distance)
		var/turf/target = get_ranged_target_turf(slipper, old_dir, slide_distance)
		if(lube_flags & SLIDE)
			slipper.AddComponent(/datum/component/force_move, target, TRUE)
		else if(lube_flags & SLIDE_ICE)
			// spinning would be bad for ice, fucks up the next dir
			slipper.AddComponent(/datum/component/force_move, target, FALSE)

	return TRUE

