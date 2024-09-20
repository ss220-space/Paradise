/turf/simulated/floor/plating
	name = "plating"
	icon_state = "plating"
	icon = 'icons/turf/floors/plating.dmi'
	intact = FALSE
	floor_tile = null
	baseturf = /turf/baseturf_bottom

	var/unfastened = FALSE

	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	real_layer = PLATING_LAYER

/turf/simulated/floor/plating/Initialize(mapload)
	. = ..()
	icon_plating = icon_state
	update_icon()

/turf/simulated/floor/plating/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/simulated/floor/plating/burnt_states()
	return list("floorscorched1", "floorscorched2")

/turf/simulated/floor/plating/damaged/Initialize(mapload)
	. = ..()
	break_tile()

/turf/simulated/floor/plating/burnt/Initialize(mapload)
	. = ..()
	burn_tile()

/turf/simulated/floor/plating/update_icon_state()
	if(!broken && !burnt)
		icon_state = icon_plating //Because asteroids are 'platings' too.

/turf/simulated/floor/plating/examine(mob/user)
	. = ..()

	if(unfastened)
		. += span_warning("It has been unfastened.")


/turf/simulated/floor/plating/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	if(istype(I, /obj/item/stack/rods))
		add_fingerprint(user)
		var/obj/item/stack/rods/rods = I
		if(broken || burnt)
			to_chat(user, span_warning("Repair the plating first!"))
			return .
		if(rods.get_amount() < 2)
			to_chat(user, span_warning("You need at least two rods to make a reinforced floor!"))
			return .
		to_chat(user, span_notice("You begin reinforcing the floor..."))
		var/cached_use_sound = rods.usesound
		if(!do_after(user, 3 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL) || broken || burnt || istype(src, /turf/simulated/floor/engine) || QDELETED(rods) || !rods.use(2))
			return .
		ChangeTurf(/turf/simulated/floor/engine)
		playsound(src, cached_use_sound, 80, TRUE)
		to_chat(user, span_notice("You reinforce the floor."))
		return .|ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/tile))
		add_fingerprint(user)
		var/obj/item/stack/tile/tile = I
		if(broken || burnt)
			to_chat(user, span_warning("This section is too damaged to support a tile! Use a welder to fix the damage."))
			return .
		var/cached_type = tile.turf_type
		if(!tile.use(1))
			to_chat(user, span_warning("You need at least one sheet of [tile] to construct a tile."))
			return .
		to_chat(user, span_notice("You have constructed a new tile."))
		ChangeTurf(cached_type)
		playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
		return .|ATTACK_CHAIN_BLOCKED_ALL

	if(is_glass_sheet(I))
		add_fingerprint(user)
		var/obj/item/stack/sheet/glass = I
		if(broken || burnt)
			to_chat(user, span_warning("Repair the plating first!"))
			return .
		if(glass.get_amount() < 2)
			to_chat(user, span_warning("You need at least two sheets to build a transparent floor!"))
			return .
		to_chat(user, span_notice("You start swapping the plating to transparent one..."))
		var/cached_type = glass.type
		var/cached_sound = glass.usesound
		if(!do_after(user, 3 SECONDS * glass.toolspeed, src, category = DA_CAT_TOOL) || broken || burnt || transparent_floor || QDELETED(glass) || !glass.use(2))
			return .
		if(ispath(cached_type, /obj/item/stack/sheet/plasmaglass)) //So, what type of glass floor do we want today?
			ChangeTurf(/turf/simulated/floor/glass/plasma)
		else if(ispath(cached_type, /obj/item/stack/sheet/plasmarglass))
			ChangeTurf(/turf/simulated/floor/glass/reinforced/plasma)
		else if(ispath(cached_type, /obj/item/stack/sheet/glass))
			ChangeTurf(/turf/simulated/floor/glass)
		else if(ispath(cached_type, /obj/item/stack/sheet/rglass))
			ChangeTurf(/turf/simulated/floor/glass/reinforced)
		else if(ispath(cached_type, /obj/item/stack/sheet/titaniumglass))
			ChangeTurf(/turf/simulated/floor/glass/titanium)
		else if(ispath(cached_type, /obj/item/stack/sheet/plastitaniumglass))
			ChangeTurf(/turf/simulated/floor/glass/titanium/plasma)
		playsound(src, cached_sound, 80, TRUE)
		to_chat(user, span_notice("You swap the plating to transparent one."))
		new /obj/item/stack/sheet/metal(src, 2)
		return .|ATTACK_CHAIN_BLOCKED_ALL


/turf/simulated/floor/plating/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	to_chat(user, span_notice("You start [unfastened ? "fastening" : "unfastening"] [src]."))
	. = TRUE
	if(!I.use_tool(src, user, 20, volume = I.tool_volume))
		return
	to_chat(user, span_notice("You [unfastened ? "fasten" : "unfasten"] [src]."))
	unfastened = !unfastened

/turf/simulated/floor/plating/welder_act(mob/user, obj/item/I)
	if(!broken && !burnt && !unfastened)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(unfastened)
		to_chat(user, span_warning("You start removing [src], exposing space after you're done!"))
		if(!I.use_tool(src, user, 50, volume = I.tool_volume * 2)) //extra loud to let people know something's going down
			return
		new /obj/item/stack/tile/plasteel(get_turf(src))
		remove_plating(user)
		return
	if(I.use_tool(src, user, volume = I.tool_volume)) //If we got this far, something needs fixing
		to_chat(user, span_notice("You fix some dents on the broken plating."))
		cut_overlay(current_overlay)
		current_overlay = null
		burnt = FALSE
		broken = FALSE
		update_icon()

/turf/simulated/floor/plating/remove_plating(mob/user)
	if(baseturf == /turf/baseturf_bottom)
		ReplaceWithLattice()
	else
		TerraformTurf(baseturf)

/turf/simulated/floor/plating/airless
	icon_state = "plating"
	name = "airless plating"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/plating/airless/Initialize(mapload)
	. = ..()
	name = "plating"

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	var/insulated = FALSE
	heat_capacity = 325000
	explosion_vertical_block = 2
	floor_tile = /obj/item/stack/rods
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/engine/break_tile()
	return //unbreakable

/turf/simulated/floor/engine/burn_tile()
	return //unburnable

/turf/simulated/floor/engine/make_plating(make_floor_tile = FALSE, mob/user, force = FALSE)
	if(force)
		..(make_floor_tile, user)
	return //unplateable

/turf/simulated/floor/engine/attack_hand(mob/user)
	user.Move_Pulled(src)

/turf/simulated/floor/engine/pry_tile(obj/item/C, mob/user, silent = FALSE)
	return

/turf/simulated/floor/engine/acid_act(acidpwr, acid_volume)
	acidpwr = min(acidpwr, 50) //we reduce the power so reinf floor never get melted.
	. = ..()


/turf/simulated/floor/engine/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume) || !istype(src, /turf/simulated/floor/engine))
		return .
	make_plating(make_floor_tile = FALSE, force = TRUE)
	var/obj/item/stack/rods/rods = new(src, 2)
	rods.add_fingerprint(user)


/turf/simulated/floor/engine/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	if(istype(I, /obj/item/stack/sheet/plasteel)) //Insulating the floor
		add_fingerprint(user)
		var/obj/item/stack/sheet/plasteel/plasteel = I
		if(insulated)
			to_chat(user, span_warning("The [name] is already insulatedt!"))
			return .
		if(plasteel.get_amount() < 1)
			to_chat(user, span_warning("You need at least one sheet of plasteel to do this!"))
			return .
		to_chat(user, span_notice("You start insulating [src]..."))
		if(!do_after(user, 4 SECONDS * plasteel.toolspeed, src, category = DA_CAT_TOOL) || insulated || QDELETED(plasteel) || !plasteel.use(1))
			return .
		to_chat(user, span_notice("You finish insulating [src]."))
		ChangeTurf(/turf/simulated/floor/engine/insulated)
		return .|ATTACK_CHAIN_BLOCKED_ALL


/turf/simulated/floor/engine/ex_act(severity)
	switch(severity)
		if(1)
			ChangeTurf(baseturf)
		if(2)
			if(prob(50))
				ChangeTurf(baseturf)

/turf/simulated/floor/engine/blob_act(obj/structure/blob/B)
	if(prob(25))
		ChangeTurf(baseturf)

/turf/simulated/floor/engine/cult
	name = "engraved floor"
	icon_state = "cult"
	var/holy = FALSE


/turf/simulated/floor/engine/cult/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON_STATE)


/turf/simulated/floor/engine/cult/update_icon_state()
	if(SSticker?.cultdat && !holy)
		icon_state = SSticker.cultdat.cult_floor_icon_state
		return
	icon_state = initial(icon_state)


/turf/simulated/floor/engine/cult/narsie_act()
	return

/turf/simulated/floor/engine/cult/ratvar_act()
	. = ..()
	if(istype(src, /turf/simulated/floor/engine/cult)) //if we haven't changed type
		var/previouscolor = color
		color = "#FAE48C"
		animate(src, color = previouscolor, time = 8)

/turf/simulated/floor/engine/cult/holy
	icon_state = "holy"
	holy = TRUE

//air filled floors; used in atmos pressure chambers

/turf/simulated/floor/engine/n20
	name = "\improper N2O floor"
	sleeping_agent = 6000
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/engine/co2
	name = "\improper CO2 floor"
	carbon_dioxide = 50000
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/engine/plasma
	name = "plasma floor"
	toxins = 70000
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/engine/o2
	name = "\improper O2 floor"
	oxygen = 100000
	nitrogen = 0

/turf/simulated/floor/engine/n2
	name = "\improper N2 floor"
	nitrogen = 100000
	oxygen = 0

/turf/simulated/floor/engine/air
	name = "air floor"
	oxygen = 2644
	nitrogen = 10580


/turf/simulated/floor/engine/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(floor_tile)
			if(prob(30))
				make_plating(make_floor_tile = TRUE, force = TRUE)
		else if(prob(30))
			ReplaceWithLattice()

/turf/simulated/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/engine/insulated
	name = "insulated reinforced floor"
	icon_state = "engine"
	insulated = TRUE
	explosion_vertical_block = 3
	thermal_conductivity = 0

/turf/simulated/floor/engine/insulated/vacuum
	name = "insulated vacuum floor"
	icon_state = "engine"
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/plating/ironsand
	name = "Iron Sand"
	icon = 'icons/turf/floors/ironsand.dmi'
	icon_state = "ironsand1"

/turf/simulated/floor/plating/ironsand/Initialize(mapload)
	. = ..()
	icon_state = "ironsand[rand(1,15)]"

/turf/simulated/floor/plating/ironsand/remove_plating()
	return

/turf/simulated/floor/plating/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/plating/snow/ex_act(severity)
	return

/turf/simulated/floor/plating/snow/remove_plating()
	return

/turf/simulated/floor/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/snow/ex_act(severity)
	return

/turf/simulated/floor/snow/pry_tile(obj/item/C, mob/user, silent = FALSE)
	return

/turf/simulated/floor/plating/metalfoam
	name = "foamed metal plating"
	icon_state = "metalfoam"
	var/metal = MFOAM_ALUMINUM

/turf/simulated/floor/plating/metalfoam/iron
	icon_state = "ironfoam"
	metal = MFOAM_IRON

/turf/simulated/floor/plating/metalfoam/update_icon_state()
	switch(metal)
		if(MFOAM_ALUMINUM)
			icon_state = "metalfoam"
		if(MFOAM_IRON)
			icon_state = "ironfoam"


/turf/simulated/floor/plating/metalfoam/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	if(istype(I, /obj/item/stack/sheet/metal))
		add_fingerprint(user)
		var/obj/item/stack/sheet/metal/metal = I
		if(metal.get_amount() < 2)
			to_chat(user, span_warning("You need at least two metal sheets to replace a foam!"))
			return .
		to_chat(user, span_notice("You start swapping the foam with metal sheets..."))
		var/cached_sound = metal.usesound
		if(!do_after(user, 3 SECONDS * metal.toolspeed, src, category = DA_CAT_TOOL) || !istype(src, /turf/simulated/floor/plating/metalfoam) || QDELETED(metal) || !metal.use(1))
			return .
		ChangeTurf(/turf/simulated/floor/plating, FALSE, FALSE)
		add_fingerprint(user)
		playsound(src, cached_sound, 80, TRUE)
		to_chat(user, span_notice("You swap the foam with the metal plating."))
		return .|ATTACK_CHAIN_BLOCKED_ALL

	if(I.force)
		user.do_attack_animation(src)
		var/smash_prob = max(0, I.force * 17 - metal * 25) // A crowbar will have a 60% chance of a breakthrough on alum, 35% on iron
		if(!prob(smash_prob))
			user.visible_message(
				span_warning("[user]'s [I.name] bounces against [src]!"),
				span_warning("Your [I.name] bounces against [src]!"),
			)
			return .
		// YAR BE CAUSIN A HULL BREACH
		user.visible_message(
			span_warning("[user] smashes through [src] with [I]!"),
			span_warning("You have smashed through [src] with [I]!"),
		)
		smash()
		add_fingerprint(user)
		return .|ATTACK_CHAIN_BLOCKED_ALL



/turf/simulated/floor/plating/metalfoam/attack_animal(mob/living/simple_animal/M)
	M.do_attack_animation(src)
	if(M.melee_damage_upper == 0)
		M.visible_message(span_notice("[M] nudges \the [src]."))
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		M.visible_message(span_danger("\The [M] [M.attacktext] [src]!"))
		smash(src)

/turf/simulated/floor/plating/metalfoam/attack_alien(mob/living/carbon/alien/humanoid/M)
	M.visible_message(span_danger("[M] tears apart \the [src]!"))
	smash(src)

/turf/simulated/floor/plating/metalfoam/burn_tile()
	smash()

/turf/simulated/floor/plating/metalfoam/proc/smash()
	ChangeTurf(baseturf)

/turf/simulated/floor/plating/ice
	name = "ice sheet"
	desc = "A sheet of solid ice. Looks slippery."
	icon = 'icons/turf/floors/ice_turfs.dmi'
	base_icon_state = "ice_turfs"
	icon_state = "unsmooth"
	oxygen = 22
	nitrogen = 82
	temperature = 180
	baseturf = /turf/simulated/floor/plating/ice
	slowdown = 1
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_FLOOR_ICE
	smoothing_groups = SMOOTH_GROUP_FLOOR_ICE

/turf/simulated/floor/plating/ice/Initialize(mapload)
	. = ..()
	MakeSlippery(TURF_WET_PERMAFROST, INFINITY, 0, INFINITY, TRUE)

/turf/simulated/floor/plating/ice/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/simulated/floor/plating/ice/smooth
	icon_state = "smooth"
