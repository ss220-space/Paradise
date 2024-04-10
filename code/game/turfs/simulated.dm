#define WATER_WEAKEN_TIME 4 SECONDS //Weaken time for slipping on water
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

/turf/simulated/proc/break_tile()
	return

/turf/simulated/proc/burn_tile()
	return

/turf/simulated/water_act(volume, temperature, source)
	. = ..()

	if(volume >= 3)
		MakeSlippery()

	var/hotspot = (locate(/obj/effect/hotspot) in src)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = remove_air(air.total_moles())
		lowertemp.temperature = max(min(lowertemp.temperature-2000,lowertemp.temperature / 2), 0)
		lowertemp.react()
		assume_air(lowertemp)
		qdel(hotspot)

/*
 * Makes a turf slippery using the given parameters
 * @param wet_setting The type of slipperyness used
 * @param time Time the turf is slippery. If null it will pick a random time between 790 and 820 ticks. If INFINITY then it won't dry up ever
*/
/turf/simulated/proc/MakeSlippery(wet_setting = TURF_WET_WATER, time = null) // 1 = Water, 2 = Lube, 3 = Ice, 4 = Permafrost
	if(wet >= wet_setting)
		return
	wet = wet_setting
	if(wet_setting != TURF_DRY)
		if(wet_overlay)
			cut_overlay(wet_overlay)
			wet_overlay = null
		var/turf/simulated/floor/F = src
		if(istype(F))
			if(wet_setting >= TURF_WET_ICE)
				wet_overlay = image('icons/effects/water.dmi', src, "ice_floor")
			else
				wet_overlay = image('icons/effects/water.dmi', src, "wet_floor_static")
		else
			if(wet_setting >= TURF_WET_ICE)
				wet_overlay = image('icons/effects/water.dmi', src, "ice_floor")
			else
				wet_overlay = image('icons/effects/water.dmi', src, "wet_static")
		wet_overlay.plane = FLOOR_OVERLAY_PLANE
		add_overlay(wet_overlay)
	if(time == INFINITY)
		return
	if(!time)
		time =	rand(790, 820)
	addtimer(CALLBACK(src, PROC_REF(MakeDry), wet_setting), time)

/turf/simulated/MakeDry(wet_setting = TURF_WET_WATER)
	if(wet > wet_setting)
		return
	wet = TURF_DRY
	if(wet_overlay)
		cut_overlay(wet_overlay)

/turf/simulated/Entered(atom/A, atom/OL, ignoreRest = 0)
	..()
	if(!ignoreRest)
		if(ishuman(A))
			var/mob/living/carbon/human/M = A
			if(M.lying_angle)
				return 1

			if(M.movement_type & MOVETYPES_NOT_TOUCHING_GROUND)
				return ..()

			switch(src.wet)
				if(TURF_WET_WATER)
					if(!(M.slip("the wet floor", WATER_WEAKEN_TIME, tilesSlipped = 0, walkSafely = 1)))
						M.inertia_dir = NONE
						return

				if(TURF_WET_LUBE) //lube
					M.slip("the floor", 4 SECONDS, tilesSlipped = 3, walkSafely = 0, slipAny = 1)


				if(TURF_WET_ICE) // Ice
					if(M.slip("the icy floor", 4 SECONDS, tilesSlipped = 0, walkSafely = 0))
						M.inertia_dir = NONE
						if(prob(5))
							var/obj/item/organ/external/affected = M.get_organ(BODY_ZONE_HEAD)
							if(affected)
								M.apply_damage(5, BRUTE, BODY_ZONE_HEAD)
								M.visible_message(span_warning("<b>[M]</b> hits their head on the ice!"))
								playsound(src, 'sound/weapons/genhit1.ogg', 50, 1)

				if(TURF_WET_PERMAFROST) // Permafrost
					M.slip("the frosted floor", 10 SECONDS, tilesSlipped = 1, walkSafely = 0, slipAny = 1)
	var/mob/living/simple_animal/Hulk = A
	if(istype(A, /mob/living/simple_animal/hulk))
		if(!Hulk.lying_angle)
			playsound(src,'sound/effects/hulk_step.ogg', CHANNEL_BUZZ)
	if (istype(A, /mob/living/simple_animal/hulk/clown_hulk))
		if(!Hulk.lying_angle)
			playsound(src, "clownstep", CHANNEL_BUZZ)
	if(istype(A, /mob/living/simple_animal/hostile/shitcur_goblin))
		playsound(src, "clownstep", CHANNEL_BUZZ)

/turf/simulated/ChangeTurf(path, defer_change = FALSE, keep_icon = TRUE, ignore_air = FALSE, copy_existing_baseturf = TRUE)
    . = ..()
    queue_smooth_neighbors(src)

/turf/simulated/AfterChange(ignore_air = FALSE, keep_cabling = FALSE, oldType)
    ..()
    RemoveLattice()

//////Assimilate Air//////
/turf/simulated/proc/assimilate_air(datum/gas_mixture/old_air)
    if(blocks_air || !air) // We are wall
        return
    if(old_air) // We are floor and prev(old) turf was also floor
        air.copy_from(old_air) // We just transfer the old air to our new air and call it a day
        if(SSair)
            SSair.add_to_active(src)
        return
	// We become floor from wall or space turf.
    var/aoxy = 0
    var/anitro = 0
    var/aco = 0
    var/atox = 0
    var/asleep = 0
    var/ab = 0
    var/atemp = 0

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

#undef WATER_WEAKEN_TIME
