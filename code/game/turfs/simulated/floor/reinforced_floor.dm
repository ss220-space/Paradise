/turf/simulated/floor/engine
	name = "reinforced floor"
	desc = "Extremely sturdy."
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = INFINITY
	explosion_vertical_block = 2
	floor_tile = /obj/item/stack/rods
	footstep = FOOTSTEP_PLATING
	var/insulated = FALSE

/turf/open/floor/engine/examine(mob/user)
	. += ..()
	. += span_notice("The reinforcement rods are <b>wrenched</b> firmly in place.")

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

/turf/simulated/floor/engine/ex_act(severity, target)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			ChangeTurf(baseturf)
		if(EXPLODE_HEAVY)
			if(prob(50))
				ChangeTurf(baseturf)

/turf/simulated/floor/engine/blob_consume()
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
		animate(src, color = previouscolor, time = 0.8 SECONDS)

/turf/simulated/floor/engine/cult/holy
	icon_state = "holy"
	holy = TRUE

/turf/simulated/floor/engine/cult/lavaland_air
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND

//air filled floors; used in atmos pressure chambers

/turf/simulated/floor/engine/n20
	name = "N2O floor"
	sleeping_agent = 6000
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/engine/co2
	name = "CO2 floor"
	carbon_dioxide = 50000
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/engine/plasma
	name = "plasma floor"
	toxins = 70000
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/engine/o2
	name = "O2 floor"
	oxygen = 100000
	nitrogen = 0

/turf/simulated/floor/engine/n2
	name = "N2 floor"
	nitrogen = 100000
	oxygen = 0

/turf/simulated/floor/engine/air
	name = "air floor"
	oxygen = 2644
	nitrogen = 10580

/turf/simulated/floor/engine/agent_b
	name = "agent B floor"
	agent_b = 10000
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/engine/hydrogen
	name = "H2 floor"
	hydrogen = 100000
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/engine/water_vapor
	name = "H2O floor"
	water_vapor = 10000
	oxygen = 0
	nitrogen = 0
	temperature = 716

/turf/simulated/floor/engine/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(floor_tile)
			if(prob(30))
				make_plating(make_floor_tile = TRUE, force = TRUE)
		else if(prob(30))
			ReplaceWithLattice()

/turf/simulated/floor/engine/vacuum
	name = "vacuum floor"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/engine/lavaland_air
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND

/turf/simulated/floor/engine/insulated
	name = "insulated reinforced floor"
	insulated = TRUE
	explosion_vertical_block = 3
	thermal_conductivity = 0

/turf/simulated/floor/engine/insulated/vacuum
	name = "insulated vacuum floor"
	oxygen = 0
	nitrogen = 0
