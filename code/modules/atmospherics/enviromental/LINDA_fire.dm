
/atom/proc/temperature_expose(exposed_temperature, exposed_volume)
	if(!isnull(reagents))
		reagents.temperature_reagents(exposed_temperature)

/turf/simulated/temperature_expose(exposed_temperature, exposed_volume)
	if(reagents)
		reagents.temperature_reagents(exposed_temperature, 10, 300)

/turf/proc/hotspot_expose(exposed_temperature, exposed_volume)
	return

/turf/simulated/hotspot_expose(exposed_temperature, exposed_volume)
	var/datum/milla_safe/make_hotspot/milla = new()
	milla.invoke_async(src, exposed_temperature, exposed_volume)

/datum/milla_safe/make_hotspot

/datum/milla_safe/make_hotspot/on_run(turf/simulated/tile, exposed_temperature, exposed_volume)
	create_hotspot(tile, exposed_temperature, exposed_volume)

//This is the icon for fire on turfs.
/obj/effect/hotspot
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/goonstation/effects/fire.dmi'
	icon_state = "1"
	layer = MASSIVE_OBJ_LAYER
	alpha = 250
	blend_mode = BLEND_ADD
	light_range = 2

	var/volume = 125
	var/temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	/// The last tick this hotspot should be alive for.
	var/death_timer = 0
	/// How much fuel did we burn this tick?
	var/fuel_burnt = 0
	/// Which tick did we last load data at?
	var/data_tick = 0
	/// Which update tick are we on?
	var/update_tick = 0
	/// How often do we update?
	var/update_interval = 1

	var/static/mutable_appearance/sparkle_overlay_static
	var/static/mutable_appearance/lightning_overlay_static
	var/static/mutable_appearance/fusion_overlay_static
	var/static/mutable_appearance/rainbow_overlay_static

	var/last_temperature = 0
	var/last_fuel_burnt = 0

/obj/effect/hotspot/Initialize(mapload)
	. = ..()
	dir = pick(GLOB.cardinal)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	if(sparkle_overlay_static)
		return
	sparkle_overlay_static = mutable_appearance('icons/effects/effects.dmi', "shieldsparkles")
	sparkle_overlay_static.blend_mode = BLEND_ADD
	lightning_overlay_static = mutable_appearance(icon, "overcharged")
	lightning_overlay_static.blend_mode = BLEND_ADD
	fusion_overlay_static = mutable_appearance('icons/effects/tile_effects.dmi', "fusion_gas")
	fusion_overlay_static.blend_mode = BLEND_ADD
	rainbow_overlay_static = mutable_appearance('icons/mob/screen_gen.dmi', "druggy")
	rainbow_overlay_static.blend_mode = BLEND_ADD
	rainbow_overlay_static.appearance_flags = RESET_COLOR


/obj/effect/hotspot/proc/gauss_lerp(x, x1, x2)
	var/d = (x - (x1 + x2) * 0.5) / ((x2 - x1) / 3)
	return NUM_E ** -(d * d)

/obj/effect/hotspot/proc/update_visuals(fuel_burnt)
	if(last_temperature == temperature && last_fuel_burnt == fuel_burnt)
		return
	var/cached_temperature = temperature
	last_temperature = temperature
	last_fuel_burnt = fuel_burnt

	cut_overlays()

	var/heat_r = heat2color_r(cached_temperature)
	var/heat_g = heat2color_g(cached_temperature)
	var/heat_b = heat2color_b(cached_temperature)
	var/heat_a = 255
	var/greyscale_fire = 1 //This determines how greyscaled the fire is.

	if(cached_temperature < FREON_MAXIMUM_BURN_TEMPERATURE)
		heat_r = 0
		heat_g = LERP(255, cached_temperature, 1.2)
		heat_b = LERP(255, cached_temperature, 0.9)
		heat_a = 100

	else if(cached_temperature < 5000) //This is where fire is very orange, we turn it into the normal fire texture here.
		var/normal_amt = gauss_lerp(cached_temperature, 1000, 3000)
		heat_r = LERP(heat_r, 255, normal_amt)
		heat_g = LERP(heat_g, 255, normal_amt)
		heat_b = LERP(heat_b, 255, normal_amt)
		heat_a -= gauss_lerp(cached_temperature, -5000, 5000) * 128
		greyscale_fire -= normal_amt

	if(cached_temperature > 40000) //Past this temperature the fire will gradually turn a bright purple
		var/purple_amt = cached_temperature < LERP(40000, 200000, 0.5) ? gauss_lerp(cached_temperature, 40000, 200000) : 1
		heat_r = LERP(heat_r, 255, purple_amt)

	if(cached_temperature > 200000 && cached_temperature < 500000) //Somewhere at this temperature nitryl happens.
		var/sparkle_amt = gauss_lerp(cached_temperature, 200000, 500000)
		sparkle_overlay_static.alpha = sparkle_amt * 255
		add_overlay(sparkle_overlay_static)

	if(cached_temperature > 400000 && cached_temperature < 1500000) //Lightning because very anime.
		add_overlay(lightning_overlay_static)

	if(cached_temperature > 4500000) //This is where noblium happens. Some fusion-y effects.
		var/fusion_amt = cached_temperature < LERP(4500000, 12000000, 0.5) ? gauss_lerp(cached_temperature, 4500000, 12000000) : 1
		fusion_overlay_static.alpha = fusion_amt * 255
		rainbow_overlay_static.alpha = fusion_amt * 255
		heat_r = LERP(heat_r, 150, fusion_amt)
		heat_g = LERP(heat_g, 150, fusion_amt)
		heat_b = LERP(heat_b, 150, fusion_amt)
		add_overlay(fusion_overlay_static)
		add_overlay(rainbow_overlay_static)

	var/r = LERP(250, heat_r, greyscale_fire)
	var/g = LERP(160, heat_g, greyscale_fire)
	var/b = LERP(25, heat_b, greyscale_fire)

	var/new_light_color = rgb(r, g, b)

	if(isnull(light_color))
		light_color = new_light_color
		set_light_color(new_light_color)
	else
		var/list/light_rgb = rgb2num(light_color)
		var/r_delta = abs(r - light_rgb[1])
		var/g_delta = abs(g - light_rgb[2])
		var/b_delta = abs(b - light_rgb[3])

		if(r_delta > 10 || g_delta > 10 || b_delta > 10)
			set_light_color(new_light_color)
			light_color = new_light_color

	heat_r /= 255
	heat_g /= 255
	heat_b /= 255

	var/greyscale_fire_reversed = 1 - greyscale_fire

	color = list(
		LERP(0.3, 1, greyscale_fire_reversed) * heat_r,
		0.3 * heat_g * greyscale_fire,
		0.3 * heat_b * greyscale_fire,
		0.59 * heat_r * greyscale_fire,
		LERP(0.59, 1, greyscale_fire_reversed) * heat_g,
		0.59 * heat_b * greyscale_fire,
		0.11 * heat_r * greyscale_fire,
		0.11 * heat_g * greyscale_fire,
		LERP(0.11, 1, greyscale_fire_reversed) * heat_b,
		0, 0, 0
	)
	if(fuel_burnt > 1)
		icon_state = "3"
	else if(fuel_burnt > 0.1)
		icon_state = "2"
	else
		icon_state = "1"


/obj/effect/hotspot/proc/perform_exposure()
	if(temperature < FREON_MAXIMUM_BURN_TEMPERATURE)
		return
	for(var/atom/item in loc.contents)
		if(!QDELETED(item) && item != src && !(item.resistance_flags & (INDESTRUCTIBLE|FIRE_PROOF))) // It's possible that the item is deleted in temperature_expose
			item.fire_act(temperature, volume)

// Garbage collect itself by nulling reference to it

/obj/effect/hotspot/Destroy()
	set_light_on(FALSE)
	var/turf/simulated/T = loc
	if(istype(T) && T.active_hotspot == src)
		T.active_hotspot = null
	return ..()

/obj/effect/hotspot/proc/recolor()
	color = heat2color(temperature)
	set_light(l_color = color)

/obj/effect/hotspot/proc/on_atom_entered(datum/source, mob/living/entered)
	SIGNAL_HANDLER // COMSIG_ATOM_ENTERED

	if(temperature < FREON_MAXIMUM_BURN_TEMPERATURE)
		return

	if(istype(entered))
		entered.fire_act()

/obj/effect/hotspot/singularity_pull()
	return

/// Largely for the fireflash procs below
/obj/effect/hotspot/fake
	var/burn_time = 3 SECONDS

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
		H.recolor()

		T.hotspot_expose(H.temperature, H.volume)
		for(var/atom/A in T)
			if(isliving(A))
				continue
			if(A != H)
				A.fire_act(H.temperature, H.volume)

		if(isfloorturf(T))
			var/turf/simulated/floor/F = T
			F.burn_tile()

		for(var/mob/living/L in T)
			L.adjust_fire_stacks(3)
			L.IgniteMob()
			if(ishuman(L))
				var/mob/living/carbon/human/M = L
				var/heatBlockPercent = 1 - M.get_heat_protection(temp)
				M.bodytemperature += (temp - M.bodytemperature) * heatBlockPercent / 3
			else
				L.bodytemperature = (2 * L.bodytemperature + temp) / 3

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
	while(length(open))
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
			H.recolor()
			existing_hotspot = H

		else if(existing_hotspot.temperature < temp - dist * falloff)
			expose_temp = (temp - dist * falloff) - existing_hotspot.temperature
			prev_temp = existing_hotspot.temperature
			if(expose_temp > prev_temp * 3)
				need_expose = TRUE
			existing_hotspot.temperature = temp - dist * falloff
			existing_hotspot.recolor()

		affected[T] = existing_hotspot.temperature
		if(need_expose && expose_temp)
			T.hotspot_expose(expose_temp, existing_hotspot.volume)
			for(var/atom/A in T)
				if(isliving(A))
					continue
				if(A != existing_hotspot)
					A.fire_act(expose_temp, existing_hotspot.volume)
		if(isfloorturf(T))
			var/turf/simulated/floor/F = T
			F.burn_tile()
		for(var/mob/living/L in T)
			L.adjust_fire_stacks(3)
			L.IgniteMob()
			if(ishuman(L))
				var/mob/living/carbon/human/M = L
				var/heatBlockPercent = 1 - M.get_heat_protection(temp)
				M.bodytemperature += (temp - M.bodytemperature) * heatBlockPercent / 3
			else
				L.bodytemperature = (2 * L.bodytemperature + temp) / 3

		if(T.density)
			continue

		if(dist == max_dist)
			continue

		for(var/direction in GLOB.cardinal)
			var/turf/link = get_step(T, direction)
			if(!link)
				continue
			// Check if it wasn't already visited and if you can get to that turf
			if(!closed[link] && T.CanAtmosPass(direction) && link.CanAtmosPass(turn(direction, 180)))
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
				T.visible_message(span_warning("[T] melts!"))
				T.burn_down()
	return affected
