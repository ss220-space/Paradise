
/atom/proc/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return null

/turf/proc/hotspot_expose(exposed_temperature, exposed_volume, soh = 0)
	return


/turf/simulated/hotspot_expose(exposed_temperature, exposed_volume, soh)
	//If the air doesn't exist we just return false
	var/list/air_gases = air?.gases
	if(!air_gases)
		return

	. = air_gases[/datum/gas/oxygen]
	var/oxy = . ? .[MOLES] : 0
	if (oxy < 0.5)
		return
	. = air_gases[/datum/gas/plasma]
	var/plas = . ? .[MOLES] : 0
	if(active_hotspot)
		if(soh && plas > 0.5)
			if(active_hotspot.temperature < exposed_temperature)
				active_hotspot.temperature = exposed_temperature
			if(active_hotspot.volume < exposed_volume)
				active_hotspot.volume = exposed_volume
		return

	if((exposed_temperature > PLASMA_MINIMUM_BURN_TEMPERATURE) && (plas > 0.5))

		active_hotspot = new /obj/effect/hotspot(src, exposed_volume*25, exposed_temperature)

		active_hotspot.just_spawned = (current_cycle < SSair.times_fired)
			//remove just_spawned protection if no longer processing this cell
		SSair.add_to_active(src)


/**
 * Hotspot objects interfaces with the temperature of turf gasmixtures while also providing visual effects.
 * One important thing to note about hotspots are that they can roughly be divided into two categories based on the bypassing variable.
 */
/obj/effect/hotspot
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = ABOVE_GAME_PLANE
	light_system = MOVABLE_LIGHT
	light_range = LIGHT_RANGE_FIRE
	light_power = 1
	light_color = LIGHT_COLOR_FIRE

	/**
	 * Volume is the representation of how big and healthy a fire is.
	 * Hotspot volume will be divided by turf volume to get the ratio for temperature setting on non bypassing mode.
	 * Also some visual stuffs for fainter fires.
	 */
	var/volume = 125
	/// Temperature handles the initial ignition and the colouring.
	var/temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	/// Whether the hotspot is new or not. Used for bypass logic.
	var/just_spawned = TRUE
	/// Whether the hotspot becomes passive and follows the gasmix temp instead of changing it.
	var/bypassing = FALSE
	/// Determines if hotspot is fake or not
	var/fake = FALSE

/obj/effect/hotspot/Initialize(mapload, starting_volume, starting_temperature)
	. = ..()
	SSair.hotspots += src
	if(!isnull(starting_volume))
		volume = starting_volume
	if(!isnull(starting_temperature))
		temperature = starting_temperature
	perform_exposure()
	setDir(pick(GLOB.cardinals))
	air_update_turf(FALSE, FALSE)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/**
 * Perform interactions between the hotspot and the gasmixture.
 *
 * For the first tick, hotspots will take a sample of the air in the turf,
 * set the temperature equal to a certain amount, and then reacts it.
 * In some implementations the ratio comes out to around 1, so all of the air in the turf.
 *
 * Afterwards if the reaction is big enough it mostly just tags along the fire,
 * copying the temperature and handling the colouring.
 * If the reaction is too small it will perform like the first tick.
 *
 * Also calls fire_act() which handles burning.
 */
/obj/effect/hotspot/proc/perform_exposure()
	var/turf/simulated/location = loc
	if(!istype(location) || !(location.air))
		return FALSE

	location.active_hotspot = src

	bypassing = !just_spawned && (volume > CELL_VOLUME*0.95)

	//Passive mode
	if(bypassing)
		volume = location.air.reaction_results["fire"]*FIRE_GROWTH_RATE
		temperature = location.air.temperature
	//Active mode
	else
		var/datum/gas_mixture/affected = location.air.remove_ratio(volume/location.air.volume)
		if(affected) //in case volume is 0
			affected.temperature = temperature
			affected.react(src)
			temperature = affected.temperature
			volume = affected.reaction_results["fire"]*FIRE_GROWTH_RATE
			location.assume_air(affected)

	// Handles the burning of atoms.
	for(var/A in location)
		var/atom/AT = A
		if(!QDELETED(AT) && AT != src)
			AT.fire_act(temperature, volume)
	return

#define INSUFFICIENT(path) (!location.air.gases[path] || location.air.gases[path][MOLES] < 0.5)

/**
 * Regular process proc for hotspots governed by the controller.
 * Handles the calling of perform_exposure() which handles the bulk of temperature processing.
 * Burning or fire_act() are also called by perform_exposure().
 * Also handles the dying and qdeletion of the hotspot and hotspot creations on adjacent cardinal turfs.
 * And some visual stuffs too! Colors and fainter icons for specific conditions.
 */
/obj/effect/hotspot/process()
	if(just_spawned)
		just_spawned = 0
		return 0

	var/turf/simulated/location = loc
	if(!istype(location))
		qdel(src)
		return

	if(location.excited_group)
		location.excited_group.reset_cooldowns()

	if((temperature < FIRE_MINIMUM_TEMPERATURE_TO_EXIST) || (volume <= 1))
		qdel(src)
		return

	//Not enough / nothing to burn
	if(!location.air || (INSUFFICIENT(/datum/gas/plasma) || INSUFFICIENT(/datum/gas/oxygen))
		qdel(src)
		return

	perform_exposure()

	if(location.wet) //what
		location.wet = TURF_DRY

	if(bypassing)
		icon_state = "3"
		location.burn_tile()

		//Possible spread due to radiated heat
		if(location.air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_SPREAD)
			var/radiated_temperature = location.air.temperature*FIRE_SPREAD_RADIOSITY_SCALE
			for(var/t in location.atmos_adjacent_turfs)
				var/turf/simulated/T = t
				if(!T.active_hotspot)
					T.hotspot_expose(radiated_temperature, CELL_VOLUME/4)

	else
		if(volume > CELL_VOLUME*0.4)
			icon_state = "2"
		else
			icon_state = "1"

	return TRUE

// Garbage collect itself by nulling reference to it

/obj/effect/hotspot/Destroy()
	SSair.hotspots -= src
	var/turf/simulated/T = loc
	if(istype(T) && T.active_hotspot == src)
		T.active_hotspot = null
	if(!fake)
		DestroyTurf()
	return ..()

/obj/effect/hotspot/proc/DestroyTurf()

	if(istype(loc, /turf/simulated))
		var/turf/simulated/T = loc
		if(T.to_be_destroyed && !T.changing_turf)
			var/chance_of_deletion
			if(T.heat_capacity) //beware of division by zero
				chance_of_deletion = T.max_fire_temperature_sustained / T.heat_capacity * 8 //there is no problem with prob(23456), min() was redundant --rastaf0
			else
				chance_of_deletion = 100
			if(prob(chance_of_deletion))
				T.ChangeTurf(T.baseturf)
			else
				T.to_be_destroyed = 0
				T.max_fire_temperature_sustained = 0

/obj/effect/hotspot/Crossed(mob/living/L, oldloc)
	..()
	if(isliving(L))
		L.fire_act()

/obj/effect/hotspot/singularity_pull()
	return

/obj/effect/hotspot/fake // Largely for the fireflash procs below
	fake = TRUE
	var/burn_time = 30

/obj/effect/hotspot/fake/New()
	..()
	if(burn_time)
		QDEL_IN(src, burn_time)

/proc/fireflash(atom/center, radius, temp)
	if(!temp)
		temp = rand(2800, 3200)
	for(var/turf/T in view(radius, get_turf(center)))
		if(isspaceturf(T))
			continue
		if(locate(/obj/effect/hotspot) in T)
			continue
		if(!can_line(get_turf(center), T, radius + 1))
			continue

		var/obj/effect/hotspot/fake/H = new(T)
		H.temperature = temp
		H.volume = 400
		H.color = heat2color(H.temperature)
		H.set_light(l_color = H.color)

		T.hotspot_expose(H.temperature, H.volume)
		for(var/atom/A in T)
			if(isliving(A))
				continue
			if(A != H)
				A.fire_act(null, H.temperature, H.volume)

		if(isfloorturf(T))
			var/turf/simulated/floor/F = T
			F.burn_tile()

		for(var/mob/living/L in T)
			L.adjust_fire_stacks(3)
			L.IgniteMob()
			L.bodytemperature = max(temp / 3, L.bodytemperature)

/proc/fireflash_s(atom/center, radius, temp, falloff)
	if(temp < T0C + 60)
		return list()
	var/list/open = list()
	var/list/affected = list()
	var/list/closed = list()
	var/turf/Ce = get_turf(center)
	var/max_dist = radius
	if(falloff)
		max_dist = min((temp - (T0C + 60)) / falloff, radius)
	open[Ce] = 0
	while(open.len)
		var/turf/T = open[1]
		var/dist = open[T]
		open -= T
		closed[T] = TRUE

		if(isspaceturf(T))
			continue
		if(dist > max_dist)
			continue
		if(!ff_cansee(Ce, T))
			continue

		var/obj/effect/hotspot/existing_hotspot = locate(/obj/effect/hotspot) in T
		var/prev_temp = 0
		var/need_expose = 0
		var/expose_temp = 0
		if(!existing_hotspot)
			var/obj/effect/hotspot/fake/H = new(T)
			need_expose = TRUE
			H.temperature = temp - dist * falloff
			expose_temp = H.temperature
			H.volume = 400
			H.color = heat2color(H.temperature)
			H.set_light(l_color = H.color)
			existing_hotspot = H

		else if(existing_hotspot.temperature < temp - dist * falloff)
			expose_temp = (temp - dist * falloff) - existing_hotspot.temperature
			prev_temp = existing_hotspot.temperature
			if(expose_temp > prev_temp * 3)
				need_expose = TRUE
			existing_hotspot.temperature = temp - dist * falloff
			existing_hotspot.color = heat2color(existing_hotspot.temperature)
			existing_hotspot.set_light(l_color = existing_hotspot.color)

		affected[T] = existing_hotspot.temperature
		if(need_expose && expose_temp)
			T.hotspot_expose(expose_temp, existing_hotspot.volume)
			for(var/atom/A in T)
				if(isliving(A))
					continue
				if(A != existing_hotspot)
					A.fire_act(null, expose_temp, existing_hotspot.volume)
		if(isfloorturf(T))
			var/turf/simulated/floor/F = T
			F.burn_tile()
		for(var/mob/living/L in T)
			L.adjust_fire_stacks(3)
			L.IgniteMob()
			L.bodytemperature = (2 * L.bodytemperature + temp) / 3

		if(T.density)
			continue

		if(dist == max_dist)
			continue

		for(var/dir in GLOB.cardinal)
			var/turf/link = get_step(T, dir)
			if (!link)
				continue
			// Check if it wasn't already visited and if you can get to that turf
			if(!closed[link] && T.CanAtmosPass(link))
				var/dx = link.x - Ce.x
				var/dy = link.y - Ce.y
				var/target_dist = max((dist + 1 + sqrt(dx * dx + dy * dy)) / 2, dist)
				if(link in open)
					if(open[link] > target_dist)
						open[link] = target_dist
				else
					open[link] = target_dist

	return affected

/proc/fireflash_sm(atom/center, radius, temp, falloff, capped = TRUE, bypass_rng = FALSE)
	var/list/affected = fireflash_s(center, radius, temp, falloff)
	for(var/turf/simulated/T in affected)
		var/mytemp = affected[T]
		var/melt = 1643.15 // default steel melting point
		var/divisor = melt
		if(mytemp >= melt * 2)
			var/chance = mytemp / divisor
			if(capped)
				chance = min(chance, 30)
			if(prob(chance) || bypass_rng)
				T.visible_message("<span class='warning'>[T] melts!</span>")
				T.burn_down()
	return affected

#undef INSUFFICIENT
