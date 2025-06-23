/proc/flame_radius(radius = 1, turf/epicenter, flame_level = 20, burn_level = 30, flameshape = FLAMESHAPE_DEFAULT, target, fire_type = FIRE_VARIANT_DEFAULT, reagent_type = null)
	//This proc is used to generate automatically-colored fires from manually adjusted item variables.
	//It parses them as parameters and sets color automatically based on Intensity, then sends an edited reagent to the standard flame code.
	//By default, this generates a napalm fire with a radius of 1, flame_level of 20 per UT (prev 14 as greenfire), burn_level of 30 per UT (prev 15 as greenfire), in a diamond shape.
	if(!istype(epicenter))
		return

	var/datum/reagent/reagent

	if(reagent_type)
		reagent = new reagent_type()

	else if(burn_level >= BURN_LEVEL_TIER_7)
		reagent = new /datum/reagent/napalm/blue()

	else if(burn_level <= BURN_LEVEL_TIER_2)
		reagent  = new /datum/reagent/napalm/green()

	else
		reagent = new /datum/reagent/napalm/ut()

	reagent.durationfire = flame_level
	reagent.intensityfire = burn_level
	reagent.rangefire = radius

	new /obj/flamer_fire(epicenter, reagent, reagent.rangefire, null, flameshape, target, , , fire_type)

/obj/flamer_fire
	name = "fire"
	desc = "Ouch!"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/fire.dmi'
	icon_state = "dynamic_2"
	layer = ABOVE_OBJ_LAYER

	light_system = STATIC_LIGHT
	light_on = TRUE
	light_range = 3
	light_power = 3
	light_color = "#f88818"

	var/firelevel = 12 //Tracks how much "fire" there is. Basically the timer of how long the fire burns
	var/burnlevel = 10 //Tracks how HOT the fire is. This is basically the heat level of the fire and determines the temperature.

	/// After the fire is created, for 0.5 seconds this variable will be TRUE.
	var/initial_burst = TRUE

	var/flame_icon = "dynamic"
	var/flameshape = FLAMESHAPE_DEFAULT // diagonal square shape
	var/turf/target_clicked

	var/datum/reagent/tied_reagent
	var/datum/reagents/tied_reagents
	var/datum/callback/to_call

	var/fire_variant = FIRE_VARIANT_DEFAULT


/obj/flamer_fire/ComponentInitialize()
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/flamer_fire/Initialize(mapload, datum/reagent/reagent, fire_spread_amount = 0, datum/reagents/obj_reagents = null, new_flameshape = FLAMESHAPE_DEFAULT, atom/target = null, datum/callback/callback, fuel_pressure = 1, fire_type = FIRE_VARIANT_DEFAULT)
	. = ..()
	if(!reagent)
		reagent = new /datum/reagent/napalm/ut()

	if(!tied_reagents)
		create_reagents(100) // So that the expanding flames are all linked together by 1 tied_reagents object
		tied_reagents = reagents
		tied_reagents.locked = TRUE

	flameshape = new_flameshape

	fire_variant = fire_type

	//non-dynamic flame is already colored
	if(reagent.burn_sprite == "dynamic")
		color = reagent.burncolor
	else
		flame_icon = reagent.burn_sprite

	set_light(l_color = reagent.burncolor)

	tied_reagent = new reagent.type() // Can't get deleted this way

	if(obj_reagents)
		tied_reagents = obj_reagents

	target_clicked = target

	icon_state = "[flame_icon]_2"

	//Fire duration increases with fuel usage
	firelevel = reagent.durationfire + fuel_pressure * reagent.durationmod
	burnlevel = reagent.intensityfire


	update_flame()

	addtimer(CALLBACK(src, PROC_REF(un_burst_flame)), 0.5 SECONDS)
	START_PROCESSING(SSobj, src)

	to_call = callback

	var/burn_dam = burnlevel * FIRE_DAMAGE_PER_LEVEL

	if(tied_reagents && !tied_reagents.locked)
		var/removed = tied_reagents.remove_reagent(tied_reagent.id, FLAME_REAGENT_USE_AMOUNT * fuel_pressure)
		if(removed)
			qdel(src)
			return

	if(fire_spread_amount > 0)
		var/datum/flameshape/flameshape = GLOB.flameshapes[src.flameshape]
		if(!flameshape)
			CRASH("Invalid flameshape passed to /obj/flamer_fire. (Expected /datum/flameshape, got [flameshape] (id: [flameshape]))")

		INVOKE_ASYNC(flameshape, TYPE_PROC_REF(/datum/flameshape, handle_fire_spread), src, fire_spread_amount, burn_dam, fuel_pressure)
	//Apply fire effects onto everyone in the fire

	for(var/mob/living/ignited_morb in loc) //Deal bonus damage if someone's caught directly in initial stream
		if(ignited_morb.stat == DEAD)
			continue

		var/fire_intensity_resistance = ignited_morb.run_armor_check(attack_flag = FIRE)
		var/firedamage = max(burn_dam - fire_intensity_resistance, 0)
		if(!firedamage)
			continue
		ignited_morb.adjust_fire_stacks(tied_reagent.durationfire)
		ignited_morb.IgniteMob()

		ignited_morb.apply_damage(firedamage, BURN)
		animation_flash_color(ignited_morb, tied_reagent.burncolor) //pain hit flicker


	var/turf/current_turf = get_turf(src)

	if(!isopenspaceturf(current_turf))
		return

	var/turf/simulated/openspace/current_open_turf = current_turf
	current_open_turf.check_fall()

/obj/flamer_fire/Destroy()
	STOP_PROCESSING(SSobj, src)
	to_call = null
	tied_reagent = null
	tied_reagents = null
	. = ..()

/obj/flamer_fire/extinguish()
	firelevel /= 2

/obj/flamer_fire/blob_act(obj/structure/blob/B)
	firelevel /= 2

/obj/flamer_fire/proc/on_entered(datum/source, atom/movable/entered)
	if(!isliving(entered))
		return

	entered.handle_flamer_fire_crossed(src)


/obj/flamer_fire/proc/set_on_fire(mob/living/mob)
	if(!istype(mob))
		return

	var/burn_damage = floor(burnlevel * 0.5)
	switch(fire_variant)
		if(FIRE_VARIANT_TYPE_B) //Armor Shredding Greenfire, 2x tile damage (Equiavlent to UT)
			burn_damage = burnlevel
	var/fire_intensity_resistance = mob.run_armor_check(attack_flag = FIRE)

	if(!tied_reagent.fire_penetrating)
		burn_damage = max(burn_damage * (100 - fire_intensity_resistance) / 100, 0)


	mob.adjust_fire_stacks(tied_reagent.durationfire)
	mob.IgniteMob()


	mob.apply_damage(burn_damage, BURN) //This makes fire stronk.

	to_chat(mob, span_danger("You are burned!"))
	mob.updatehealth()

/obj/flamer_fire/proc/update_flame()
	if(burnlevel < 15 && flame_icon != "dynamic")
		color = "#c1c1c1" //make it darker to make show its weaker.
	var/flame_level = 1
	switch(firelevel)
		if(1 to 9)
			flame_level = 1
		if(10 to 25)
			flame_level = 2
		if(25 to INFINITY) //Change the icons and luminosity based on the fire's intensity
			flame_level = 3

	if(initial_burst)
		flame_level++ //the initial flame burst is 1 level higher for a small time

	icon_state = "[flame_icon]_[flame_level]"
	set_light(flame_level * 2)

/obj/flamer_fire/proc/un_burst_flame()
	initial_burst = FALSE
	update_flame()

/obj/flamer_fire/process(delta_time)
	var/turf/process_turf = loc
	firelevel = max(0, firelevel)
	if(!istype(process_turf)) //Is it a valid turf? Has to be on a floor
		qdel(src)
		return PROCESS_KILL
	var/damage = burnlevel * delta_time
	process_turf.flamer_fire_act(damage)

	if(!firelevel)
		qdel(src)
		return

	update_flame()

	for(var/atom/thing in loc)
		thing.handle_flamer_fire(src, damage, delta_time)

	//This has been made a simple loop, for the most part flamer_fire_act() just does return, but for specific items it'll cause other effects.

	firelevel -= 2

	return

/proc/fire_spread_recur(turf/target, remaining_distance, direction, fire_lvl, burn_lvl, f_color, burn_sprite = "dynamic")
	var/direction_angle = dir2angle(direction)
	var/obj/flamer_fire/foundflame = locate() in target
	if(!foundflame)
		var/datum/reagent/fire_reag = new()
		fire_reag.intensityfire = burn_lvl
		fire_reag.durationfire = fire_lvl
		fire_reag.burn_sprite = burn_sprite
		fire_reag.burncolor = f_color
		new/obj/flamer_fire(target, fire_reag)

	if(target.density)
		return

	for(var/spread_direction in GLOB.alldirs)

		var/spread_power = remaining_distance

		var/spread_direction_angle = dir2angle(spread_direction)

		var/angle = 180 - abs( abs( direction_angle - spread_direction_angle ) - 180 ) // the angle difference between the spread direction and initial direction

		switch(angle) //this reduces power when the explosion is going around corners
			if (45)
				spread_power *= 0.75
			if (90 to 180) //turns out angles greater than 90 degrees almost never happen. This bit also prevents trying to spread backwards
				continue

		switch(spread_direction)
			if(NORTH,SOUTH,EAST,WEST)
				spread_power--
			else
				spread_power -= 1.414 //diagonal spreading

		if (spread_power < 1)
			continue

		var/turf/picked_turf = get_step(target, spread_direction)

		if(!picked_turf || picked_turf.density) //prevents trying to spread into "null" (edge of the map?)
			continue
		var/has_pass = TRUE
		for(var/atom/atom as anything in picked_turf)
			if(!atom.density)
				continue
			has_pass = FALSE
			break

		if(!has_pass)
			return

		ASYNC
			fire_spread_recur(picked_turf, spread_power, spread_direction, fire_lvl, burn_lvl, f_color, burn_sprite)

/proc/fire_spread(turf/target, range, fire_lvl, burn_lvl, f_color, burn_sprite = "dynamic")
	var/datum/reagent/fire_reag = new()
	fire_reag.intensityfire = burn_lvl
	fire_reag.durationfire = fire_lvl
	fire_reag.burn_sprite = burn_sprite
	fire_reag.burncolor = f_color

	new/obj/flamer_fire(target, fire_reag)
	for(var/direction in GLOB.alldirs)
		var/spread_power = range
		switch(direction)
			if(NORTH,SOUTH,EAST,WEST)
				spread_power--
			else
				spread_power -= 1.414 //diagonal spreading
		var/turf/picked_turf = get_step(target, direction)
		if(!picked_turf || picked_turf.density) //prevents trying to spread into "null" (edge of the map?)
			continue
		var/has_pass = TRUE
		for(var/atom/atom as anything in picked_turf)
			if(!atom.density)
				continue
			has_pass = FALSE
			break

		if(!has_pass)
			return
		fire_spread_recur(picked_turf, spread_power, direction, fire_lvl, burn_lvl, f_color, burn_sprite)


//Flashes a color, then goes back to regular.
/proc/animation_flash_color(atom/animation_atom, flash_color = COLOR_RED, speed = 3) //Flashes red on default.
	var/oldcolor = animation_atom.color
	animate(animation_atom, color = flash_color, time = speed, flags = ANIMATION_PARALLEL)
	animate(color = oldcolor, time = speed)
