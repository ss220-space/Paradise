/turf/simulated
	name = "station"
	flags = NO_SCREENTIPS
	rad_insulation = RAD_MEDIUM_INSULATION
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	abstract_type = /turf/simulated

	var/wet = 0
	var/image/wet_overlay = null
	var/mutable_appearance/melting_olay
	var/thermite = 0
	var/to_be_destroyed = 0 //Used for fire, if a melting temperature was reached, it will be destroyed
	var/max_fire_temperature_sustained = 0 //The max temperature of the fire which it was subjected to

	// LINDA
	var/datum/excited_group/excited_group
	var/excited = 0
	var/recently_active = 0
	var/archived_cycle = 0
	var/current_cycle = 0
	var/icy = 0
	var/icyoverlay
	/// The active hotspot on this turf. The fact this is done through a literal object is painful
	var/obj/effect/hotspot/active_hotspot

	/// The temp we were when we got archived
	var/temperature_archived

	/// Current gas overlays.
	var/list/atmos_overlay_types = null
	/// If a fire is ongoing, how much fuel did we burn last tick?
	/// Value is not updated while below PLASMA_MINIMUM_BURN_TEMPERATURE.
	var/fuel_burnt = 0
	/// When do we last remember having wind?
	var/wind_tick = null
	/// Wind's X component
	var/wind_x = null
	/// Wind's Y component
	var/wind_y = null
	/// Wind effect
	var/obj/effect/wind/wind_effect = null

/turf/simulated/Initialize(mapload)
	. = ..()
	add_debris_element()
	if(!is_station_level(z))
		return
	GLOB.station_turfs += src

/turf/simulated/Destroy(force)
	if(is_station_level(z))
		GLOB.station_turfs -= src
	return ..()

/turf/simulated/add_debris_element()
	AddElement(/datum/element/debris, null, -40, 8, 0.7)

/turf/simulated/proc/break_tile()
	return

/turf/simulated/proc/burn_tile()
	return

/turf/simulated/water_act(volume, temperature, source)
	. = ..()

	if(volume >= 3)
		MakeSlippery(TURF_WET_WATER, 80 SECONDS)

	quench(1000, 2, min_temperature =  temperature)

/// Quenches any fire on the turf, and if it does, cools down the turf's air by the given parameters.
/turf/simulated/proc/quench(delta, divisor, min_temperature = TCMB)
	var/found = FALSE
	for(var/obj/effect/hotspot/hotspot in src)
		qdel(hotspot)
		found = TRUE

	if(!found)
		return

	var/datum/milla_safe/turf_cool/milla = new()
	milla.invoke_async(src, delta, divisor, min_temperature)

/datum/milla_safe/turf_cool

/datum/milla_safe/turf_cool/on_run(turf/location, delta, divisor, min_temperature = TCMB)
	var/datum/gas_mixture/air = get_turf_air(location)
	air.set_temperature(max(min(air.temperature() - delta * divisor, air.temperature() / divisor), min_temperature))
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
				playsound(src, SFX_CLOWN_STEP, CHANNEL_BUZZ)
	if(istype(arrived, /mob/living/simple_animal/hostile/shitcur_goblin))
		playsound(src, SFX_CLOWN_STEP, CHANNEL_BUZZ)

/turf/simulated/copyTurf(turf/simulated/copy_to_turf, copy_air = FALSE)
	. = ..()
	ASSERT(issimulatedturf(copy_to_turf))
	var/datum/component/wet_floor/slip = GetComponent(/datum/component/wet_floor)
	if(slip)
		var/datum/component/wet_floor/new_wet_floor_component = copy_to_turf.AddComponent(/datum/component/wet_floor)
		new_wet_floor_component.InheritComponent(slip)

/turf/simulated/ChangeTurf(path, defer_change = FALSE, keep_icon = TRUE, after_flags = NONE, copy_existing_baseturf = TRUE)
	. = ..()
	QUEUE_SMOOTH_NEIGHBORS(src)

/turf/simulated/AfterChange(flags, oldType)
	..()
	RemoveLattice()
	if(!(flags & CHANGETURF_IGNORE_AIR))
		var/datum/milla_safe/turf_assimilate_air/milla = new()
		milla.invoke_async(src)

/datum/milla_safe/turf_assimilate_air

/datum/milla_safe/turf_assimilate_air/on_run(turf/self)
	if(self.blocks_air || isnull(self))
		return

	var/datum/gas_mixture/merged = new()
	var/turf_count = 0

	for(var/turf/T in self.GetAtmosAdjacentTurfs())
		if(isspaceturf(T))
			turf_count += 1
			continue

		if(T.blocks_air)
			continue

		merged.merge(get_turf_air(T))
		turf_count++

	if(turf_count > 0)
		// Average the contents of the turfs.
		merged.set_oxygen(merged.oxygen() / turf_count)
		merged.set_nitrogen(merged.nitrogen() / turf_count)
		merged.set_carbon_dioxide(merged.carbon_dioxide() / turf_count)
		merged.set_toxins(merged.toxins() / turf_count)
		merged.set_sleeping_agent(merged.sleeping_agent() / turf_count)
		merged.set_agent_b(merged.agent_b() / turf_count)
		merged.set_hydrogen(merged.hydrogen() / turf_count)
		merged.set_water_vapor(merged.water_vapor() / turf_count)
		merged.set_hypernoblium(merged.hypernoblium() / turf_count)
		merged.set_nitrium(merged.nitrium() / turf_count)
		merged.set_tritium(merged.tritium() / turf_count)
		merged.set_bz(merged.bz() / turf_count)
		merged.set_pluoxium(merged.pluoxium() / turf_count)
		merged.set_miasma(merged.miasma() / turf_count)
		merged.set_freon(merged.freon() / turf_count)
		merged.set_healium(merged.healium() / turf_count)
		merged.set_proto_nitrate(merged.proto_nitrate() / turf_count)
		merged.set_zauker(merged.zauker() / turf_count)
		merged.set_halon(merged.halon() / turf_count)
		merged.set_helium(merged.helium() / turf_count)
		merged.set_antinoblium(merged.antinoblium() / turf_count)
	get_turf_air(self).copy_from(merged)

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
	if(slipper.no_gravity(src))
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
		to_chat(slipper, span_notice("Вы поскользнул[GEND_SYA_AS_OS_IS(slipper)][slippable ? " на [slippable.declent_ru(PREPOSITIONAL)]" : ""]!"))
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
		slipper.stop_hand_bleedsuppress()
		slipper.Knockdown(weaken_amount)

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

