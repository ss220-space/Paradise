/area
	var/fire = null
	var/area_emergency_mode = FALSE // When true, fire alarms cannot unset emergency lighting. Not to be confused with emergency_mode var on light objects.
	var/atmosalm = ATMOS_ALARM_NONE
	var/poweralm = TRUE
	var/report_alerts = TRUE // Should atmos alerts notify the AI/computers
	level = null
	name = "Space"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = AREA_LAYER
	plane = AREA_PLANE //Keeping this on the default plane, GAME_PLANE, will make area overlays fail to render on FLOOR_PLANE.
	luminosity = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_LIGHTING

	/// List of all turfs currently inside this area. Acts as a filtered bersion of area.contents
	/// For faster lookup (area.contents is actually a filtered loop over world)
	/// Semi fragile, but it prevents stupid so I think it's worth it
	var/list/turf/contained_turfs = list()
	/// Contained turfs is a MASSIVE list, so rather then adding/removing from it each time we have a problem turf
	/// We should instead store a list of turfs to REMOVE from it, then hook into a getter for it
	/// There is a risk of this and contained_turfs leaking, so a subsystem will run it down to 0 incrementally if it gets too large
	var/list/turf/turfs_to_uncontain = list()

	var/valid_territory = TRUE //used for cult summoning areas on station zlevel
	var/map_name // Set in New(); preserves the name set by the map maker, even if renamed by the Blueprints.
	var/lightswitch = TRUE

	var/debug = FALSE
	var/requires_power = TRUE
	var/always_unpowered = FALSE	//this gets overriden to 1 for space in area/New()

	var/power_equip = TRUE
	var/power_light = TRUE
	var/power_environ = TRUE
	var/used_equip = 0
	var/used_light = 0
	var/used_environ = 0
	var/static_equip = 0
	var/static_light = 0
	var/static_environ = 0

	/// Whether this area has a gravity by default.
	var/has_gravity = FALSE
	/// If `TRUE` this area will skip gravity generator's effect in its Z-level.
	var/ignore_gravgen = FALSE

	var/list/apc = list()
	var/no_air = null

	var/air_doors_activated = FALSE

	var/tele_proof = FALSE
	var/no_teleportlocs = FALSE

	var/outdoors = FALSE //For space, the asteroid, lavaland, etc. Used with blueprints to determine if we are adding a new area (vs editing a station room)
	var/xenobiology_compatible = FALSE //Can the Xenobio management console transverse this area by default?
	var/nad_allowed = FALSE //is the station NAD allowed on this area?

	var/global/global_uid = 0
	var/uid

	var/list/ambientsounds = GENERIC_SOUNDS

	var/list/firedoors
	var/list/cameras
	var/list/firealarms

	///Used for performance in light manipulation operations
	var/list/lights_cache

	///Used for perfomance in machinery manipulation operations
	var/list/machinery_cache

	var/firedoors_last_closed_on = 0

	var/fast_despawn = FALSE
	var/can_get_auto_cryod = TRUE
	var/hide_attacklogs = FALSE // For areas such as thunderdome, lavaland syndiebase, etc which generate a lot of spammy attacklogs. Reduces log priority.

	var/parallax_movedir = 0
	var/moving = FALSE
	/// "Haunted" areas such as the morgue and chapel are easier to boo. Because flavor.
	var/is_haunted = FALSE
	///Used to decide what kind of reverb the area makes sound have
	var/sound_environment = SOUND_ENVIRONMENT_NONE

	///Used to decide what the minimum time between ambience is
	var/min_ambience_cooldown = 30 SECONDS
	///Used to decide what the maximum time between ambience is
	var/max_ambience_cooldown = 90 SECONDS

	///This datum, if set, allows terrain generation behavior to be ran on Initialize() // This is unfinished, used in Lavaland
	var/datum/map_generator/cave_generator/map_generator

	var/area_flags = NONE

/area/New(loc, ...)
	// This interacts with the map loader, so it needs to be set immediately
	// rather than waiting for atoms to initialize.
	if (area_flags & UNIQUE_AREA)
		GLOB.areas_by_type[type] = src
	GLOB.areas += src
	..()

/area/Initialize(mapload)
	icon_state = ""
	layer = AREA_LAYER
	uid = ++global_uid

	map_name = name // Save the initial (the name set in the map) name of the area.

	if(use_starlight && CONFIG_GET(flag/starlight))
		// Areas lit by starlight are not supposed to be fullbright 4head
		base_lighting_alpha = 0
		base_lighting_color = null
		static_lighting = TRUE


	if(requires_power)
		luminosity = 0
	else
		power_light = TRUE
		power_equip = TRUE
		power_environ = TRUE

		if(static_lighting)
			luminosity = 0

	. = ..()

	if(!static_lighting)
		blend_mode = BLEND_MULTIPLY

	reg_in_areas_in_z()

	update_base_lighting()

	return INITIALIZE_HINT_LATELOAD

/area/LateInitialize()
	. = ..()
	power_change()		// all machines set to current power level, also updates lighting icon

/**
 * Register this area as belonging to a z level
 *
 * Ensures the item is added to the SSmapping.areas_in_z list for this z
 */
/area/proc/reg_in_areas_in_z()
	if(!has_contained_turfs())
		return
	var/list/areas_in_z = SSmapping.areas_in_z
	if(!z)
		WARNING("No z found for [src]")
		return
	if(!areas_in_z["[z]"])
		areas_in_z["[z]"] = list()
	areas_in_z["[z]"] += src

/area/proc/get_cameras()
	var/list/cameras = list()
	for(var/obj/machinery/camera/C in machinery_cache)
		cameras += C
	return cameras

/// Generate turfs, including cool cave wall gen
/area/proc/RunTerrainGeneration()
	if(map_generator)
		map_generator = new map_generator()
		var/list/turfs = list()
		for(var/turf/T in contents)
			turfs += T
		map_generator.generate_terrain(turfs, src)

/// Populate the previously generated terrain with mobs and objects
/area/proc/RunTerrainPopulation()
	if(map_generator)
		var/list/turfs = list()
		for(var/turf/T in contents)
			turfs += T
		map_generator.populate_terrain(turfs, src)

/area/proc/test_gen()
	if(map_generator)
		var/list/turfs = list()
		for(var/turf/T in contents)
			turfs += T
		map_generator.generate_terrain(turfs, src)

/area/proc/air_doors_close()
	if(air_doors_activated)
		return
	air_doors_activated = TRUE
	for(var/obj/machinery/door/firedoor/firedoor as anything in firedoors)
		if(!firedoor.is_operational())
			continue
		firedoor.activate_alarm()
		if(firedoor.welded)
			continue
		if(firedoor.operating && firedoor.operating != DOOR_CLOSING)
			firedoor.nextstate = FD_CLOSED
		else if(!firedoor.density)
			INVOKE_ASYNC(firedoor, TYPE_PROC_REF(/obj/machinery/door/firedoor, close))


/area/proc/air_doors_open()
	if(!air_doors_activated)
		return
	air_doors_activated = FALSE
	for(var/obj/machinery/door/firedoor/firedoor as anything in firedoors)
		if(!firedoor.is_operational())
			continue
		firedoor.deactivate_alarm()
		if(firedoor.welded)
			continue
		if(firedoor.operating && firedoor.operating != DOOR_OPENING)
			firedoor.nextstate = FD_OPEN
		else if(firedoor.density)
			INVOKE_ASYNC(firedoor, TYPE_PROC_REF(/obj/machinery/door/firedoor, open))

/area/proc/get_contained_turfs()
	if(length(turfs_to_uncontain))
		cannonize_contained_turfs()
	return contained_turfs

/// Ensures that the contained_turfs list properly represents the turfs actually inside us
/area/proc/cannonize_contained_turfs()
	// This is massively suboptimal for LARGE removal lists
	// Try and keep the mass removal as low as you can. We'll do this by ensuring
	// We only actually add to contained turfs after large changes (Also the management subsystem)
	// Do your damndest to keep turfs out of /area/space as a stepping stone
	// That sucker gets HUGE and will make this take actual tens of seconds if you stuff turfs_to_uncontain
	contained_turfs -= turfs_to_uncontain
	turfs_to_uncontain = list()

/// Returns TRUE if we have contained turfs, FALSE otherwise
/area/proc/has_contained_turfs()
	return length(contained_turfs) - length(turfs_to_uncontain) > 0

/area/Destroy()
	if(GLOB.areas_by_type[type] == src)
		GLOB.areas_by_type[type] = null
	GLOB.areas -= src
	STOP_PROCESSING(SSobj, src)
	return ..()

/**
  * Generate a power alert for this area
  *
  * Sends to all ai players, alert consoles, drones and alarm monitor programs in the world
  */
/area/proc/poweralert(state, obj/source)
	if(state != poweralm)
		poweralm = state
		if(istype(source))	//Only report power alarms on the z-level where the source is located.
			for(var/thing in cameras)
				var/obj/machinery/camera/C = locateUID(thing)
				if(!QDELETED(C) && is_station_level(C.z))
					if(state)
						C.network -= "Power Alarms"
					else
						C.network |= "Power Alarms"

			if(state)
				SSalarm.cancelAlarm("Power", src, source)
			else
				SSalarm.triggerAlarm("Power", src, cameras, source)

/**
  * Generate an atmospheric alert for this area
  *
  * Sends to all ai players, alert consoles, drones and alarm monitor programs in the world
  */
/area/proc/atmosalert(danger_level, obj/source)
	if(danger_level != atmosalm)
		if(danger_level == ATMOS_ALARM_DANGER)

			for(var/thing in cameras)
				var/obj/machinery/camera/C = locateUID(thing)
				if(!QDELETED(C) && is_station_level(C.z))
					C.network |= "Atmosphere Alarms"


			SSalarm.triggerAlarm("Atmosphere", src, cameras, source)

		else if(atmosalm == ATMOS_ALARM_DANGER)
			for(var/thing in cameras)
				var/obj/machinery/camera/C = locateUID(thing)
				if(!QDELETED(C) && is_station_level(C.z))
					C.network -= "Atmosphere Alarms"

			SSalarm.cancelAlarm("Atmosphere", src, source)

		atmosalm = danger_level
		return TRUE
	return FALSE

/**
  * Try to close all the firedoors in the area
  */
/area/proc/ModifyFiredoors(opening)
	if(!firedoors)
		return
	firedoors_last_closed_on = world.time
	for(var/obj/machinery/door/firedoor/firedoor as anything in firedoors)
		if(!firedoor.is_operational())
			continue
		var/valid = TRUE
		if(opening)	//don't open if adjacent area is on fire
			for(var/area/check as anything in firedoor.affecting_areas)
				if(check.fire)
					valid = FALSE
					break
		if(!valid)
			continue

		// At this point, the area is safe and the door is technically functional.

		INVOKE_ASYNC(firedoor, (opening ? TYPE_PROC_REF(/obj/machinery/door/firedoor, deactivate_alarm) : TYPE_PROC_REF(/obj/machinery/door/firedoor, activate_alarm)))
		if(firedoor.welded)
			continue // Alarm is toggled, but door stuck
		if(firedoor.operating)
			if((firedoor.operating == DOOR_OPENING && opening) || (firedoor.operating == DOOR_CLOSING && !opening))
				continue
			else
				firedoor.nextstate = opening ? FD_OPEN : FD_CLOSED
		else if(firedoor.density == opening)
			INVOKE_ASYNC(firedoor, (opening ? TYPE_PROC_REF(/obj/machinery/door/firedoor, open) : TYPE_PROC_REF(/obj/machinery/door/firedoor, close)))

/**
  * Generate a firealarm alert for this area
  *
  * Sends to all ai players, alert consoles, drones and alarm monitor programs in the world
  *
  * Also starts the area processing on SSobj
  */
/area/proc/firealert(obj/source)
	if(always_unpowered) //no fire alarms in space/asteroid
		return

	if(!fire)
		set_fire_alarm_effect()
		ModifyFiredoors(FALSE)

	for(var/thing in cameras)
		var/obj/machinery/camera/C = locateUID(thing)
		if(!QDELETED(C) && is_station_level(C.z))
			C.network |= "Fire Alarms"

	SSalarm.triggerAlarm("Fire", src, cameras, source)

	START_PROCESSING(SSobj, src)

/**
  * Reset the firealarm alert for this area
  *
  * resets the alert sent to all ai players, alert consoles, drones and alarm monitor programs
  * in the world
  *
  * Also cycles the icons of all firealarms and deregisters the area from processing on SSOBJ
  */
/area/proc/firereset(obj/source)
	if(fire)
		unset_fire_alarm_effects()
		ModifyFiredoors(TRUE)

	for(var/thing in cameras)
		var/obj/machinery/camera/C = locateUID(thing)
		if(!QDELETED(C) && is_station_level(C.z))
			C.network -= "Fire Alarms"

	SSalarm.cancelAlarm("Fire", src, source)

	STOP_PROCESSING(SSobj, src)

/**
  * If 100 ticks has elapsed, toggle all the firedoors closed again
  */
/area/process()
	if(firedoors_last_closed_on + 100 < world.time)	//every 10 seconds
		ModifyFiredoors(FALSE)

/**
  * Close and lock a door passed into this proc
  *
  * Does this need to exist on area? probably not
  */
/area/proc/close_and_lock_door(obj/machinery/door/DOOR)
	set waitfor = FALSE
	DOOR.close()
	if(DOOR.density)
		DOOR.lock()

/**
  * Raise a burglar alert for this area
  *
  * Close and locks all doors in the area and alerts silicon mobs of a break in
  *
  * Alarm auto resets after 600 ticks
  */
/area/proc/burglaralert(obj/trigger)
	if(always_unpowered) //no burglar alarms in space/asteroid
		return

	//Trigger alarm effect
	set_fire_alarm_effect()
	//Lockdown airlocks
	for(var/obj/machinery/door/DOOR in machinery_cache)
		close_and_lock_door(DOOR)

	if(SSalarm.triggerAlarm("Burglar", src, cameras, trigger))
		//Cancel silicon alert after 1 minute
		addtimer(CALLBACK(SSalarm, TYPE_PROC_REF(/datum/controller/subsystem/alarm, cancelAlarm), "Burglar", src, trigger), 600)

/**
  * Trigger the fire alarm visual affects in an area
  *
  * Updates the fire light on fire alarms in the area and sets all lights to emergency mode
  */
/area/proc/set_fire_alarm_effect()
	fire = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	for(var/obj/machinery/firealarm/alarm as anything in firealarms)
		alarm.update_fire_light()
		alarm.update_icon()
	if(area_emergency_mode) //Fires are not legally allowed if the power is off
		return
	for(var/obj/machinery/light/light as anything in lights_cache)
		light.fire_mode = TRUE
		light.update()

///unset the fire alarm visual affects in an area
/area/proc/unset_fire_alarm_effects()
	fire = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	for(var/obj/machinery/firealarm/alarm as anything in firealarms)
		alarm.update_fire_light()
		alarm.update_icon()
	if(area_emergency_mode) //The lights stay red until the crisis is resolved
		return
	for(var/obj/machinery/light/light as anything in lights_cache)
		light.fire_mode = FALSE
		light.update()


/area/update_icon_state()
	var/weather_icon = FALSE
	for(var/datum/weather/weather as anything in SSweather.processing)
		if(weather.stage != END_STAGE && (src in weather.impacted_areas))
			weather.update_areas()
			weather_icon = TRUE
	if(!weather_icon)
		icon_state = null


/area/space/update_icon_state()
	icon_state = null


/*
#define EQUIP 1
#define LIGHT 2
#define ENVIRON 3
*/

/area/proc/powered(chan)		// return true if the area has power to given channel
	if(!requires_power)
		return TRUE
	if(always_unpowered)
		return FALSE
	switch(chan)
		if(EQUIP)
			return power_equip
		if(LIGHT)
			return power_light
		if(ENVIRON)
			return power_environ
	return FALSE

/area/space/powered(chan) //Nope.avi
	return FALSE

/**
  * Called when the area power status changes
  *
  * Updates the area icon, calls power change on all machines in the area, and sends the `COMSIG_AREA_POWER_CHANGE` signal.
  */
/area/proc/power_change()
	for(var/obj/machinery/machine as anything in machinery_cache)	// for each machine in the area
		machine.power_change()										// reverify power status (to update icons etc.)
	update_icon(UPDATE_ICON_STATE)
	SEND_SIGNAL(src, COMSIG_AREA_POWER_CHANGE)


/area/proc/usage(chan)
	var/used = 0
	switch(chan)
		if(LIGHT)
			used += used_light
		if(EQUIP)
			used += used_equip
		if(ENVIRON)
			used += used_environ
		if(TOTAL)
			used += used_light + used_equip + used_environ
		if(CHANNEL_STATIC_EQUIP)
			used += static_equip
		if(CHANNEL_STATIC_LIGHT)
			used += static_light
		if(CHANNEL_STATIC_ENVIRON)
			used += static_environ
	return used

/area/proc/addStaticPower(value, powerchannel)
	switch(powerchannel)
		if(CHANNEL_STATIC_EQUIP)
			static_equip += value
		if(CHANNEL_STATIC_LIGHT)
			static_light += value
		if(CHANNEL_STATIC_ENVIRON)
			static_environ += value

/area/proc/clear_usage()

	used_equip = 0
	used_light = 0
	used_environ = 0

/area/proc/use_power(amount, chan)
	switch(chan)
		if(EQUIP)
			used_equip += amount
		if(LIGHT)
			used_light += amount
		if(ENVIRON)
			used_environ += amount

/area/proc/use_battery_power(amount, chan)
	switch(chan)
		if(EQUIP)
			used_equip += amount
		if(LIGHT)
			used_light += amount
		if(ENVIRON)
			used_environ += amount


/area/Entered(atom/movable/arrived, area/old_area)

	SEND_SIGNAL(src, COMSIG_AREA_ENTERED, arrived, old_area)
	SEND_SIGNAL(arrived, COMSIG_ATOM_ENTERED_AREA, src, old_area)

	if(ismob(arrived))
		var/mob/arrived_mob = arrived
		if(!arrived_mob.lastarea || old_area != src)
			arrived_mob.lastarea = src

/area/Exited(atom/movable/departed, area/new_area)
	SEND_SIGNAL(src, COMSIG_AREA_EXITED, departed, new_area)
	SEND_SIGNAL(departed, COMSIG_ATOM_EXITED_AREA, src, new_area)

/area/proc/gravitychange()
	for(var/mob/living/carbon/human/user in src)
		var/prev_gravity = user.gravity_state
		user.refresh_gravity()
		if(!prev_gravity && user.gravity_state)
			user.thunk()

/area/proc/prison_break()
	for(var/obj/machinery/power/apc/temp_apc in machinery_cache)
		INVOKE_ASYNC(temp_apc, TYPE_PROC_REF(/obj/machinery/power/apc, overload_lighting), 70)
	for(var/obj/machinery/door/airlock/temp_airlock in machinery_cache)
		INVOKE_ASYNC(temp_airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, prison_open))
	for(var/obj/machinery/door/window/temp_windoor in machinery_cache)
		INVOKE_ASYNC(temp_windoor, TYPE_PROC_REF(/obj/machinery/door, open))


/area/AllowDrop()
	CRASH("Bad op: area/AllowDrop() called")


/area/drop_location()
	CRASH("Bad op: area/drop_location() called")

