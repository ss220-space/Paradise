#define SMOKE_TICK_TO_SECONDS *15

/**
 * A fluid which spreads through the air affecting every mob it engulfs.
 */
/obj/effect/particle_effect/fluid/smoke
	name = "smoke"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke"
	pixel_x = -32
	pixel_y = -32
	opacity = TRUE
	plane = ABOVE_GAME_PLANE
	layer = FLY_LAYER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	animate_movement = FALSE
	/// How long the smoke sticks around before it dissipates.
	var/lifetime = 5 SMOKE_TICK_TO_SECONDS
	/// Makes the smoke react to changes on/of its turf.
	var/static/loc_connections = list(
		COMSIG_TURF_CALCULATED_ADJACENT_ATMOS = PROC_REF(react_to_atmos_adjacency_changes)
	)

/obj/effect/particle_effect/fluid/smoke/Initialize(mapload, datum/fluid_group/group, ...)
	. = ..()
	create_reagents(1000)
	setDir(pick(GLOB.cardinal))
	AddElement(/datum/element/connect_loc, loc_connections)
	SSsmoke.start_processing(src)

/obj/effect/particle_effect/fluid/smoke/Destroy()
	SSsmoke.stop_processing(src)
	if(spread_bucket)
		SSsmoke.cancel_spread(src)
	return ..()


/**
 * Makes the smoke fade out and then deletes it.
 */
/obj/effect/particle_effect/fluid/smoke/proc/kill_smoke()
	SSsmoke.stop_processing(src)
	if(spread_bucket)
		SSsmoke.cancel_spread(src)
	INVOKE_ASYNC(src, PROC_REF(fade_out))
	QDEL_IN(src, 1 SECONDS)

/**
 * Animates the smoke gradually fading out of visibility.
 * Also makes the smoke turf transparent as it passes 160 alpha.
 *
 * Arguments:
 * - frames = 0.8 [SECONDS]: The amount of time the smoke should fade out over.
 */
/obj/effect/particle_effect/fluid/smoke/proc/fade_out(frames = 0.8 SECONDS)
	if(alpha == 0) //Handle already transparent case
		if(opacity)
			set_opacity(FALSE)
		return

	if(frames == 0)
		set_opacity(FALSE)
		alpha = 0
		return

	var/time_to_transparency = round(((alpha - 160) / alpha) * frames)
	if(time_to_transparency >= 1)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, set_opacity), FALSE), time_to_transparency)
	else
		set_opacity(FALSE)
	animate(src, time = frames, alpha = 0)


/obj/effect/particle_effect/fluid/smoke/spread(seconds_per_tick = 0.1 SECONDS)
	if(!group || group.total_size > group.target_size)
		return
	var/turf/t_loc = get_turf(src)
	if(!t_loc)
		return

	for(var/turf/spread_turf in t_loc.GetAtmosAdjacentTurfs())
		if(group.total_size > group.target_size)
			break
		if(locate(type) in spread_turf)
			continue // Don't spread smoke where there's already smoke!
		for(var/mob/living/smoker in spread_turf)
			smoke_mob(smoker, seconds_per_tick)

		var/obj/effect/particle_effect/fluid/smoke/spread_smoke = new type(spread_turf, group, src)
		reagents.copy_to(spread_smoke, reagents.total_volume)
		spread_smoke.add_atom_colour(color, FIXED_COLOUR_PRIORITY)
		spread_smoke.lifetime = lifetime

		// the smoke spreads rapidly, but not instantly
		SSfoam.queue_spread(spread_smoke)


/obj/effect/particle_effect/fluid/smoke/process(seconds_per_tick)
	lifetime -= seconds_per_tick SECONDS
	if(lifetime <= 0)
		kill_smoke()
		return FALSE
	for(var/mob/living/smoker in loc) // In case smoke somehow winds up in a locker or something this should still behave sanely.
		smoke_mob(smoker, seconds_per_tick)
	return TRUE

/**
 * Handles the effects of this smoke on any mobs it comes into contact with.
 *
 * Arguments:
 * - [smoker][/mob/living/carbon]: The mob that is being exposed to this smoke.
 * - seconds_per_tick: A scaling factor for the effects this has. Primarily based off of tick rate to normalize effects to units of rate/sec.
 *
 * Returns whether the smoke effect was applied to the mob.
 */
/obj/effect/particle_effect/fluid/smoke/proc/smoke_mob(mob/living/carbon/smoker, seconds_per_tick)
	if(!istype(smoker))
		return FALSE
	if(lifetime < 1)
		return FALSE
	if(!smoker.can_breathe_gas())
		return FALSE
	if(smoker.smoke_delay)
		return FALSE

	smoker.smoke_delay = TRUE
	addtimer(VARSET_CALLBACK(smoker, smoke_delay, FALSE), 1 SECONDS)
	return TRUE

/**
 * Makes the smoke react to nearby opening/closing airlocks and the like.
 * Makes it possible for smoke to spread through airlocks that open after the edge of the smoke cloud has already spread past them.
 *
 * Arguments:
 * - [source][/turf]: The turf that has been touched by an atmos adjacency change.
 */
/obj/effect/particle_effect/fluid/smoke/proc/react_to_atmos_adjacency_changes(turf/source)
	SIGNAL_HANDLER
	if(!group)
		return NONE
	if(spread_bucket)
		return NONE
	SSsmoke.queue_spread(src)

/// A factory which produces clouds of smoke.
/datum/effect_system/fluid_spread/smoke
	effect_type = /obj/effect/particle_effect/fluid/smoke

/////////////////////////////////////////////
// Transparent smoke
/////////////////////////////////////////////

/// Same as the base type, but the smoke produced is not opaque
/datum/effect_system/fluid_spread/smoke/transparent
	effect_type = /obj/effect/particle_effect/fluid/smoke/transparent

/// Same as the base type, but is not opaque.
/obj/effect/particle_effect/fluid/smoke/transparent
	opacity = FALSE

/**
 * A helper proc used to spawn small puffs of smoke.
 *
 * Arguments:
 * - range: The amount of smoke to produce as number of steps from origin covered.
 * - amount: The amount of smoke to produce as the total desired coverage area. Autofilled from the range arg if not set.
 * - location: Where to produce the smoke cloud.
 * - smoke_type: The smoke typepath to spawn.
 */
/proc/do_smoke(range = 0, amount = DIAMOND_AREA(range), atom/holder = null, location = null, smoke_type = /obj/effect/particle_effect/fluid/smoke, log = FALSE)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.effect_type = smoke_type
	smoke.set_up(amount = amount, holder = holder, location = location)
	smoke.start(log = log)

/////////////////////////////////////////////
// Quick smoke
/////////////////////////////////////////////

/// Smoke that dissipates as quickly as possible.
/obj/effect/particle_effect/fluid/smoke/quick
	lifetime = 1 SECONDS
	opacity = FALSE

/// A factory which produces smoke that dissipates as quickly as possible.
/datum/effect_system/fluid_spread/smoke/quick
	effect_type = /obj/effect/particle_effect/fluid/smoke/quick

/////////////////////////////////////////////
// Bad smoke
/////////////////////////////////////////////

/// Smoke that makes you cough and reduces the power of lasers.
/obj/effect/particle_effect/fluid/smoke/bad
	lifetime = 8 SMOKE_TICK_TO_SECONDS
	var/beam_resistance = 2

/obj/effect/particle_effect/fluid/smoke/bad/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/particle_effect/fluid/smoke/bad/smoke_mob(mob/living/carbon/smoker)
	. = ..()
	if(!.)
		return

	smoker.drop_from_hands()
	smoker.adjustOxyLoss(1)
	smoker.emote("cough")

/**
 * Reduces the power of any beam projectile that passes through the smoke.
 *
 * Arguments:
 * - [source][/datum]: The location that has just been entered. If [/datum/element/connect_loc] is working this is [src.loc][/atom/var/loc].
 * - [arrived][/atom/movable]: The atom that has just entered the source location.
 * - [old_loc][/atom]: The location the entering atom just was in.
 * - [old_locs][/list/atom]: The set of locations the entering atom was just in.
 */
/obj/effect/particle_effect/fluid/smoke/bad/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(istype(arrived, /obj/item/projectile/beam))
		var/obj/item/projectile/beam/beam = arrived
		beam.damage = (beam.damage / beam_resistance)

/// A factory which produces smoke that makes you cough.
/datum/effect_system/fluid_spread/smoke/bad
	effect_type = /obj/effect/particle_effect/fluid/smoke/bad

/obj/effect/particle_effect/fluid/smoke/bad/solid
	lifetime = 9 SMOKE_TICK_TO_SECONDS

/////////////////////////////////////////////
// Solid smoke
/////////////////////////////////////////////

/datum/effect_system/fluid_spread/smoke/solid
	effect_type = /obj/effect/particle_effect/fluid/smoke/bad/solid
	var/effect_range

/datum/effect_system/fluid_spread/smoke/solid/set_up(range, amount, atom/holder, atom/location, effect_range, ...)
	. = ..()
	src.effect_range = effect_range

/datum/effect_system/fluid_spread/smoke/solid/start(log)
	var/location = src.location || get_turf(holder)
	for(var/turf/effect_location in view(effect_range, location))
		var/obj/effect/particle_effect/fluid/flood = new effect_type(effect_location, new /datum/fluid_group(amount))
		if(log) // Smoke is used as an aesthetic effect in a tonne of places and we don't want, say, a broken secway spamming admin chat.
			help_out_the_admins(flood, holder, location)
		flood.spread()

/////////////////////////////////////////////
// Bad Smoke (But Green (and Black))
/////////////////////////////////////////////

/// Green smoke that makes you cough.
/obj/effect/particle_effect/fluid/smoke/bad/green
	name = "green smoke"
	color = "#00ff00"

/obj/effect/particle_effect/fluid/smoke/bad/red
	name = "red smoke"
	color = "#af0033"

/obj/effect/particle_effect/fluid/smoke/bad/blue
	name = "blue smoke"
	color = "#88aaff"

/obj/effect/particle_effect/fluid/smoke/bad/bombarda
	name = "bombarda smoke"
	color = "#800080"
	lifetime = 20 SMOKE_TICK_TO_SECONDS

/// A factory which produces green smoke that makes you cough.
/datum/effect_system/fluid_spread/smoke/bad/green
	effect_type = /obj/effect/particle_effect/fluid/smoke/bad/green

/// Black smoke that makes you cough. (Actually dark grey)
/obj/effect/particle_effect/fluid/smoke/bad/black
	name = "black smoke"
	color = "#383838"
	opacity = FALSE

/// A factory which produces black smoke that makes you cough.
/datum/effect_system/fluid_spread/smoke/bad/black
	effect_type = /obj/effect/particle_effect/fluid/smoke/bad/black

/////////////////////////////////////////////
// Nanofrost smoke
/////////////////////////////////////////////

/// Light blue, transparent smoke which is usually paired with a blast that chills every turf in the area.
/obj/effect/particle_effect/fluid/smoke/freezing
	name = "nanofrost smoke"
	color = "#B2FFFF"
	opacity = FALSE

/// A factory which produces light blue, transparent smoke and a blast that chills every turf in the area.
/datum/effect_system/fluid_spread/smoke/freezing
	effect_type = /obj/effect/particle_effect/fluid/smoke/freezing
	/// The radius in which to chill every open turf.
	var/blast = 0
	/// The temperature to set the turfs air temperature to.
	var/temperature = 2
	/// Whether to weld every vent and air scrubber in the affected area shut.
	var/weldvents = TRUE
	/// Whether to make sure each affected turf is actually within range before cooling it.
	var/distcheck = TRUE

/**
 * Chills an open turf.
 *
 * Forces the air temperature to a specific value.
 * Transmutes all of the plasma in the air into nitrogen.
 * Extinguishes all fires and burning objects/mobs in the turf.
 * May freeze all vents and vent scrubbers shut.
 *
 * Arguments:
 * - [chilly][/turf/open]: The open turf to chill
 */
/datum/effect_system/fluid_spread/smoke/freezing/proc/Chilled(turf/simulated/chilly)
	if(!istype(chilly))
		return

	if(chilly.air)
		var/datum/gas_mixture/air = chilly.air
		if(!distcheck || get_dist(location, chilly) < blast) // Otherwise we'll get silliness like people using Nanofrost to kill people through walls with cold air
			air.temperature = temperature

		if(air.toxins)
			air.nitrogen += air.toxins
			air.toxins = 0

		for(var/obj/effect/hotspot/fire in chilly)
			qdel(fire)
		chilly.air_update_turf(FALSE, FALSE)

	if(weldvents)
		for(var/obj/machinery/atmospherics/unary/comp in chilly)
			if(!isnull(comp.welded) && !comp.welded) //must be an unwelded vent pump or vent scrubber.
				comp.welded = TRUE
				comp.update_appearance()
				comp.visible_message(span_danger("[comp] is frozen shut!"))

	// Extinguishes everything in the turf
	for(var/mob/living/potential_tinder in chilly)
		potential_tinder.ExtinguishMob()
	for(var/obj/item/potential_tinder in chilly)
		potential_tinder.extinguish()

/datum/effect_system/fluid_spread/smoke/freezing/set_up(range = 5, amount = DIAMOND_AREA(range), atom/holder, atom/location, blast_radius = 0)
	. = ..()
	blast = blast_radius

/datum/effect_system/fluid_spread/smoke/freezing/start(log = FALSE)
	if(blast)
		for(var/turf/T in RANGE_TURFS(blast, location))
			Chilled(T)
	return ..()

/// A variant of the base freezing smoke formerly used by the vent decontamination event.
/datum/effect_system/fluid_spread/smoke/freezing/decon
	temperature = T20C
	distcheck = FALSE
	weldvents = FALSE


/////////////////////////////////////////////
// Sleep smoke
/////////////////////////////////////////////

/// Smoke which knocks you out if you breathe it in.
/obj/effect/particle_effect/fluid/smoke/sleeping
	color = "#9C3636"
	lifetime = 10 SMOKE_TICK_TO_SECONDS

/obj/effect/particle_effect/fluid/smoke/sleeping/smoke_mob(mob/living/carbon/smoker, seconds_per_tick)
	if(..())
		smoker.Sleeping(20 SECONDS)
		smoker.emote("cough")
		return TRUE

/// A factory which produces sleeping smoke.
/datum/effect_system/fluid_spread/smoke/sleeping
	effect_type = /obj/effect/particle_effect/fluid/smoke/sleeping


/////////////////////////////////////////////
// Vomiting smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/fluid/smoke/vomiting
	color = "#752424"
	lifetime = 3 SMOKE_TICK_TO_SECONDS

/obj/effect/particle_effect/fluid/smoke/smoke_mob(mob/living/carbon/victim)
	. = ..()
	if(!.)
		return .
	victim.drop_from_active_hand()
	victim.vomit()
	INVOKE_ASYNC(victim, TYPE_PROC_REF(/mob, emote), "cough")


/datum/effect_system/fluid_spread/smoke/vomiting
	effect_type = /obj/effect/particle_effect/fluid/smoke/vomiting

/////////////////////////////////////////////
// Chem smoke
/////////////////////////////////////////////

/**
 * Smoke which contains reagents which it applies to everything it comes into contact with.
 */
/obj/effect/particle_effect/fluid/smoke/chem
	lifetime = 12 SECONDS

/obj/effect/particle_effect/fluid/smoke/chem/process(seconds_per_tick)
	. = ..()
	if(!.)
		return

	var/turf/location = get_turf(src)
	var/fraction = (seconds_per_tick SECONDS) / initial(lifetime)
	for(var/atom/movable/thing as anything in location)
		if(thing == src)
			continue
		reagents.reaction(thing, REAGENT_TOUCH, fraction)

	reagents.reaction(location, REAGENT_TOUCH, fraction)
	return TRUE

/obj/effect/particle_effect/fluid/smoke/chem/smoke_mob(mob/living/carbon/smoker, seconds_per_tick)
	if(lifetime < 1)
		return FALSE
	if(!istype(smoker))
		return FALSE
	if(!smoker.can_breathe_gas())
		return FALSE

	var/fraction = (seconds_per_tick SECONDS) / initial(lifetime)
	reagents.copy_to(smoker, reagents.total_volume, fraction)
	reagents.reaction(smoker, REAGENT_INGEST, fraction)
	return TRUE

/// Helper to quickly create a cloud of reagent smoke
/proc/do_chem_smoke(range = 0, amount = DIAMOND_AREA(range), atom/holder = null, location = null, reagent_type = /datum/reagent/water, smoke_type = /datum/effect_system/fluid_spread/smoke/chem, reagent_volume = 10, log = FALSE, color = null)
	var/datum/reagents/smoke_reagents = new/datum/reagents(reagent_volume)
	smoke_reagents.add_reagent(reagent_type, reagent_volume)

	var/datum/effect_system/fluid_spread/smoke/chem/smoke = new smoke_type
	smoke.attach(location)
	smoke.set_up(amount = amount, holder = holder, location = location, carry = smoke_reagents, silent = TRUE)
	smoke.start(log = log)


/// A factory which produces clouds of chemical bearing smoke.
/datum/effect_system/fluid_spread/smoke/chem
	/// Evil evil hack so we have something to "hold" our reagents
	var/datum/reagents/chemholder
	effect_type = /obj/effect/particle_effect/fluid/smoke/chem

/datum/effect_system/fluid_spread/smoke/chem/New()
	..()
	chemholder = new(1000)

/datum/effect_system/fluid_spread/smoke/chem/Destroy()
	QDEL_NULL(chemholder)
	return ..()


/datum/effect_system/fluid_spread/smoke/chem/set_up(range = 1, amount = DIAMOND_AREA(range), atom/holder, atom/location = null, datum/reagents/carry = null, silent = FALSE)
	. = ..()
	carry?.copy_to(chemholder, carry.total_volume)
	carry?.clear_reagents()

	if(silent)
		return

	var/list/contained_reagents = list()
	for(var/datum/reagent/reagent as anything in chemholder.reagent_list)
		contained_reagents += "[reagent.volume]u [reagent]"

	var/where = "[AREACOORD(location)]"
	var/contained = length(contained_reagents) ? "\[[contained_reagents.Join(", ")]\] @ [chemholder.chem_temp]K" : null
	if(carry.my_atom?.fingerprintslast) //Some reagents don't have a my_atom in some cases
		var/mob/M = get_mob_by_key(carry.my_atom.fingerprintslast)
		var/more = ""
		if(M)
			more = "[ADMIN_LOOKUPFLW(M)] "
		message_admins("Smoke: ([ADMIN_VERBOSEJMP(location)])[contained]. Key: [more ? more : carry.my_atom.fingerprintslast].")
		log_game("A chemical smoke reaction has taken place in ([where])[contained]. Last touched by [carry.my_atom.fingerprintslast].")
	else
		message_admins("Smoke: ([ADMIN_VERBOSEJMP(location)])[contained]. No associated key.")
		log_game("A chemical smoke reaction has taken place in ([where])[contained]. No associated key.")

/datum/effect_system/fluid_spread/smoke/chem/start(log = FALSE)
	var/start_loc = holder ? get_turf(holder) : src.location
	var/mixcolor = mix_color_from_reagents(chemholder.reagent_list)
	var/obj/effect/particle_effect/fluid/smoke/chem/smoke = new effect_type(start_loc, new /datum/fluid_group(amount))
	chemholder.copy_to(smoke, chemholder.total_volume)

	if(mixcolor)
		smoke.add_atom_colour(mixcolor, FIXED_COLOUR_PRIORITY) // give the smoke color, if it has any to begin with
	if(log)
		help_out_the_admins(smoke, holder, location)
	smoke.spread() // Making the smoke spread immediately.

/**
 * A version of chemical smoke with a very short lifespan.
 */
/obj/effect/particle_effect/fluid/smoke/chem/quick
	lifetime = 6 SECONDS
	opacity = FALSE
	alpha = 150

/datum/effect_system/fluid_spread/smoke/chem/quick
	effect_type = /obj/effect/particle_effect/fluid/smoke/chem/quick

/obj/effect/particle_effect/fluid/smoke/chem/quick/vapor
	lifetime = 2 SECONDS

/obj/effect/particle_effect/fluid/smoke/chem/quick/vapor/smoke_mob(mob/living/carbon/smoker, seconds_per_tick)
	if(!istype(smoker))
		return FALSE
	if(!smoker.can_breathe_gas())
		return FALSE

	smoker.emote("gasp")
	if(reagents.total_volume >= 60)
		smoker.AdjustLoseBreath(2 SECONDS)
	reagents.copy_to(smoker, REAGENT_EVAPORATION(reagents.total_volume))
	return TRUE

/datum/effect_system/fluid_spread/smoke/chem/quick/vapor
	effect_type = /obj/effect/particle_effect/fluid/smoke/chem/quick/vapor
