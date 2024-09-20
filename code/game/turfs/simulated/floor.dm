//This is so damaged or burnt tiles or platings don't get remembered as the default tile
GLOBAL_LIST_INIT(icons_to_ignore_at_floor_init, list("damaged1","damaged2","damaged3","damaged4",
				"damaged5","panelscorched","floorscorched1","floorscorched2","platingdmg1","platingdmg2",
				"platingdmg3","plating","light_on","light_on_flicker1","light_on_flicker2",
				"warnplate", "warnplatecorner","metalfoam", "ironfoam",
				"light_on_clicker3","light_on_clicker4","light_on_clicker5","light_broken",
				"light_on_broken","light_off","wall_thermite","grass1","grass2","grass3","grass4",
				"asteroid","asteroid_dug",
				"asteroid0","asteroid1","asteroid2","asteroid3","asteroid4",
				"asteroid5","asteroid6","asteroid7","asteroid8","asteroid9","asteroid10","asteroid11","asteroid12",
				"oldburning","light-on-r","light-on-y","light-on-g","light-on-b", "wood", "wood-broken","wood-broken2", "wood-broken3", "wood-broken4", "wood-broken5", "wood-broken6", "wood-broken7",
				"wood-oak","wood-oak-broken", "wood-oak-broken2", "wood-oak-broken3", "wood-oak-broken4", "wood-oak-broken5", "wood-oak-broken6", "wood-oak-broken7",
				"wood-birch","wood-birch-broken", "wood-birch-broken2", "wood-birch-broken3", "wood-birch-broken4", "wood-birch-broken5", "wood-birch-broken6", "wood-birch-broken7",
				"wood-cherry","wood-cherry-broken", "wood-cherry-broken2", "wood-cherry-broken3", "wood-cherry-broken4", "wood-cherry-broken5", "wood-cherry-broken6", "wood-cherry-broken7",
				"fancy-wood-oak","fancy-wood-oak-broken", "fancy-wood-oak-broken2", "fancy-wood-oak-broken3", "fancy-wood-oak-broken4", "fancy-wood-oak-broken5", "fancy-wood-oak-broken6", "fancy-wood-oak-broken7",
				"fancy-wood-birch","fancy-wood-birch-broken", "fancy-wood-birch-broken2", "fancy-wood-birch-broken3", "fancy-wood-birch-broken4", "fancy-wood-birch-broken5", "fancy-wood-birch-broken6", "fancy-wood-birch-broken7",
				"fancy-wood-cherry","fancy-wood-cherry-broken", "fancy-wood-cherry-broken2", "fancy-wood-cherry-broken3", "fancy-wood-cherry-broken4", "fancy-wood-cherry-broken5", "fancy-wood-cherry-broken6", "fancy-wood-cherry-broken7",
				"light-fancy-wood","light-fancy-wood-broken", "light-fancy-wood-broken2", "light-fancy-wood-broken3", "light-fancy-wood-broken4", "light-fancy-wood-broken5", "light-fancy-wood-broken6", "light-fancy-wood-broken7",
				"carpetcorner", "carpetside", "carpet", "ironsand1", "ironsand2", "ironsand3", "ironsand4", "ironsand5",
				"ironsand6", "ironsand7", "ironsand8", "ironsand9", "ironsand10", "ironsand11",
				"ironsand12", "ironsand13", "ironsand14", "ironsand15"))

/turf/simulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "dont_use_this_tile"
	plane = FLOOR_PLANE
	var/icon_regular_floor = "floor" //used to remember what icon the tile should have by default
	var/floor_regular_dir = SOUTH  //used to remember what dir the tile should have by default
	var/icon_plating = "plating"
	thermal_conductivity = 0.040
	heat_capacity = 10000
	explosion_vertical_block = 1
	var/lava = 0
	var/broken = 0
	var/burnt = 0
	var/current_overlay = null
	var/floor_tile = null //tile that this floor drops
	var/prying_tool = TOOL_CROWBAR //What tool/s can we use to pry up the tile?
	var/keep_dir = TRUE //When false, resets dir to default on changeturf()
	smoothing_groups = SMOOTH_GROUP_FLOOR

	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/Initialize(mapload)
	. = ..()
	if(icon_state in GLOB.icons_to_ignore_at_floor_init) //so damaged/burned tiles or plating icons aren't saved as the default
		icon_regular_floor = "floor"
	else
		icon_regular_floor = icon_state
		floor_regular_dir = dir


/// Returns a list of every turf state considered "broken".
/// Will be randomly chosen if a turf breaks at runtime.
/turf/simulated/floor/proc/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/// Returns a list of every turf state considered "burnt".
/// Will be randomly chosen if a turf is burnt at runtime.
/turf/simulated/floor/proc/burnt_states()
	return list("floorscorched1", "floorscorched2")

/turf/simulated/floor/ex_act(severity)
	if(is_shielded())
		return
	switch(severity)
		if(1.0)
			ChangeTurf(baseturf)
		if(2.0)
			switch(pick(1,2;75,3))
				if(1)
					spawn(0)
						ReplaceWithLattice()
						if(prob(33)) new /obj/item/stack/sheet/metal(src)
				if(2)
					ChangeTurf(baseturf)
				if(3)
					if(prob(80))
						break_tile_to_plating()
					else
						break_tile()
					hotspot_expose(1000,CELL_VOLUME)
					if(prob(33)) new /obj/item/stack/sheet/metal(src)
		if(3.0)
			if(prob(50))
				break_tile()
				hotspot_expose(1000,CELL_VOLUME)
	return

/turf/simulated/floor/burn_down()
	ex_act(2)

/turf/simulated/floor/is_shielded()
	for(var/obj/structure/A in contents)
		if(A.level == 3)
			return 1

// Checks if the turf is safe to be on
/turf/simulated/floor/is_safe()
	if(!air)
		return FALSE
	var/datum/gas_mixture/Z = air
	var/pressure = Z.return_pressure()
	// Can most things breathe and tolerate the temperature and pressure?
	if(Z.oxygen < 16 || Z.toxins >= 0.05 || Z.carbon_dioxide >= 10 || Z.sleeping_agent >= 1 || (Z.temperature <= 270) || (Z.temperature >= 360) || (pressure <= 20) || (pressure >= 550))
		return FALSE
	return TRUE


/turf/simulated/floor/blob_act(obj/structure/blob/B)
	return

/turf/simulated/floor/update_overlays()
	. = ..()
	update_visuals()
	if(current_overlay)
		. += current_overlay

/turf/simulated/floor/proc/break_tile_to_plating()
	var/turf/simulated/floor/plating/T = make_plating(FALSE)
	T.break_tile()

/turf/simulated/floor/break_tile()
	if(broken)
		return
	current_overlay = pick(broken_states())
	broken = TRUE
	update_icon()

/turf/simulated/floor/burn_tile()
	if(burnt)
		return
	current_overlay = pick(burnt_states())
	burnt = TRUE
	update_icon()

/turf/simulated/floor/proc/make_plating(make_floor_tile, mob/user)	// Set `make_floor_tile` to FALSE, if `floor_tile` have another drop logic before calling this proc.
	if(make_floor_tile && floor_tile && !broken && !burnt)
		var/obj/item/stack/stack_dropped = new floor_tile(src)
		if(user)
			var/obj/item/stack/stack_offhand = user.get_inactive_hand()
			if(istype(stack_dropped) && istype(stack_offhand) && stack_offhand.can_merge(stack_dropped, inhand = TRUE))
				user.put_in_hands(stack_dropped, ignore_anim = FALSE)
	return ChangeTurf(/turf/simulated/floor/plating)

/turf/simulated/floor/ChangeTurf(turf/simulated/floor/T, defer_change = FALSE, keep_icon = TRUE, ignore_air = FALSE, copy_existing_baseturf = TRUE)
	if(!isfloorturf(src))
		return ..() //fucking turfs switch the fucking src of the fucking running procs
	if(!ispath(T, /turf/simulated/floor))
		return ..()

	var/old_icon = icon_regular_floor
	var/old_plating = icon_plating
	var/old_dir = dir
	var/old_regular_dir = floor_regular_dir
	var/old_transparent_floor = transparent_floor

	var/turf/simulated/floor/W = ..()

	var/obj/machinery/atmospherics/R
	var/obj/machinery/power/terminal/term

	if(keep_icon)
		W.icon_regular_floor = old_icon
		W.icon_plating = old_plating
	if(W.keep_dir)
		W.floor_regular_dir = old_regular_dir
		W.dir = old_dir
	if(W.transparent_floor != old_transparent_floor)
		for(R in W)
			R.update_icon()
		for(term in W)
			term.update_icon()
	for(R in W)
		R.update_underlays()
	W.update_icon()
	return W


/turf/simulated/floor/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	if(intact && transparent_floor != TURF_TRANSPARENT && istype(I, /obj/item/stack/tile))
		try_replace_tile(I, user, params)
		return .|ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/pipe))
		add_fingerprint(user)
		var/obj/item/pipe/pipe = I
		if(pipe.pipe_type == -1) // ANY PIPE
			return .
		if(!user.drop_transfer_item_to_loc(pipe, src))
			return .
		user.visible_message(
			span_notice("[user] slides [pipe] along [src]."),
			span_notice("You slide [pipe] along [src]."),
			span_italics("You hear the scrape of metal against something."),
		)
		if(pipe.is_bent_pipe())  // bent pipe rotation fix see construction.dm
			pipe.setDir(NORTHEAST)
			if(user.dir == NORTH)
				pipe.setDir(SOUTHEAST)
			else if(user.dir == SOUTH)
				pipe.setDir(NORTHWEST)
			else if(user.dir == EAST)
				pipe.setDir(SOUTHWEST)
		else
			pipe.setDir(user.dir)
		return .|ATTACK_CHAIN_BLOCKED_ALL


/turf/simulated/floor/crowbar_act(mob/user, obj/item/I)
	if(!intact)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	pry_tile(I, user, TRUE)

/turf/simulated/floor/proc/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	if(T.turf_type == type)
		return
	var/obj/item/thing = user.get_inactive_hand()
	if(!thing || prying_tool != thing.tool_behaviour)
		return
	var/turf/simulated/floor/plating/P = pry_tile(thing, user, TRUE)
	if(!istype(P))
		return
	P.attackby(T, user, params)

/turf/simulated/floor/proc/pry_tile(obj/item/C, mob/user, silent = FALSE)
	if(!silent)
		playsound(src, C.usesound, 80, 1)
	return remove_tile(user, silent)

/turf/simulated/floor/proc/remove_tile(mob/user, silent = FALSE, make_tile = TRUE)
	if(broken || burnt)
		broken = FALSE
		burnt = FALSE
		current_overlay = null
		make_tile = FALSE
		if(user && !silent)
			to_chat(user, span_danger("You remove the broken plating."))
	else
		if(user && !silent)
			to_chat(user, span_danger("You remove the floor tile."))
	return make_plating(make_tile, user)

/turf/simulated/floor/singularity_pull(S, current_size)
	..()
	if(current_size == STAGE_THREE)
		if(prob(30))
			make_plating(TRUE)
	else if(current_size == STAGE_FOUR)
		if(prob(50))
			make_plating(TRUE)
	else if(current_size >= STAGE_FIVE)
		if(floor_tile)
			if(prob(70))
				make_plating(TRUE)
		else if(prob(50))
			ReplaceWithLattice()

/turf/simulated/floor/narsie_act()
	if(prob(20))
		ChangeTurf(/turf/simulated/floor/engine/cult)

/turf/simulated/floor/ratvar_act()
	if(prob(20))
		ChangeTurf(/turf/simulated/floor/clockwork)

/turf/simulated/floor/acid_melt()
	ChangeTurf(baseturf)

/turf/simulated/floor/can_have_cabling()
	return !burnt && !broken

/turf/simulated/floor/rcd_deconstruct_act(mob/user, obj/item/rcd/our_rcd)
	. = ..()
	if(our_rcd.checkResource(5, user))
		to_chat(user, "Deconstructing floor...")
		playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
		if(do_after(user, 5 SECONDS * our_rcd.toolspeed, src, category = DA_CAT_TOOL))
			if(!our_rcd.useResource(5, user))
				return RCD_ACT_FAILED
			playsound(get_turf(our_rcd), our_rcd.usesound, 50, 1)
			add_attack_logs(user, src, "Deconstructed floor with RCD")
			src.ChangeTurf(baseturf)
			return RCD_ACT_SUCCESSFULL
		return RCD_ACT_FAILED
	to_chat(user, span_warning("ERROR! Not enough matter in unit to deconstruct this floor!"))
	playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
	return RCD_ACT_FAILED

/turf/simulated/floor/rcd_construct_act(mob/user, obj/item/rcd/our_rcd, rcd_mode)
	. = ..()
	if(locate(/obj/machinery/field) in src)
		to_chat(user, span_warning("ERROR! Due to safety protocols building is prohibited in high-energy field areas!"))
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		return RCD_ACT_FAILED
	switch(rcd_mode)
		if(RCD_MODE_TURF)
			if(our_rcd.checkResource(3, user))
				to_chat(user, "Building Wall...")
				playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
				if(do_after(user, 2 SECONDS * our_rcd.toolspeed, src, category = DA_CAT_TOOL))
					if(!our_rcd.useResource(3, user))
						return RCD_ACT_FAILED
					playsound(get_turf(our_rcd), our_rcd.usesound, 50, 1)
					add_attack_logs(user, src, "Constructed wall with RCD")
					ChangeTurf(our_rcd.wall_type)
					return RCD_ACT_SUCCESSFULL
				to_chat(user, span_warning("ERROR! Construction interrupted!"))
				return RCD_ACT_FAILED
			to_chat(user, span_warning("ERROR! Not enough matter in unit to construct this wall!"))
			playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
			return RCD_ACT_FAILED
		if(RCD_MODE_AIRLOCK)
			if(our_rcd.checkResource(10, user))
				to_chat(user, "Building Airlock...")
				playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
				if(do_after(user, 5 SECONDS * our_rcd.toolspeed, src, category = DA_CAT_TOOL))
					if(locate(/obj/machinery/door/airlock) in src.contents)
						return RCD_NO_ACT
					if(!our_rcd.useResource(10, user))
						return RCD_ACT_FAILED
					playsound(get_turf(our_rcd), our_rcd.usesound, 50, 1)
					var/obj/machinery/door/airlock/T = new our_rcd.door_type(src)
					add_attack_logs(user, T, "Constructed airlock with RCD")
					T.name = our_rcd.door_name
					T.autoclose = TRUE
					T.req_access = our_rcd.selected_accesses.Copy()
					T.check_one_access = our_rcd.one_access
					return RCD_ACT_SUCCESSFULL
				to_chat(user, span_warning("ERROR! Construction interrupted!"))
				return RCD_ACT_FAILED
			to_chat(user, span_warning("ERROR! Not enough matter in unit to construct this airlock!"))
			playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
			return RCD_ACT_FAILED
		if(RCD_MODE_WINDOW)
			if(locate(/obj/structure/grille) in src)
				return // We already have window
			if(!our_rcd.checkResource(2, user))
				to_chat(user, span_warning("ERROR! Not enough matter in unit to construct this window!"))
				playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
				return RCD_ACT_FAILED
			to_chat(user, "Constructing window...")
			playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
			if(!do_after(user, 2 SECONDS * our_rcd.toolspeed, src, category = DA_CAT_TOOL))
				to_chat(user, span_warning("ERROR! Construction interrupted!"))
				return RCD_ACT_FAILED
			if(locate(/obj/structure/grille) in src)
				return RCD_NO_ACT// We already have window
			if(!our_rcd.useResource(2, user))
				return RCD_ACT_FAILED
			playsound(get_turf(our_rcd), our_rcd.usesound, 50, 1)
			add_attack_logs(user, src, "Constructed window with RCD")
			new /obj/structure/grille(src)
			for(var/obj/structure/window/del_window in src)
				qdel(del_window)
			if(!our_rcd.fulltile_window)
				for(var/cdir in GLOB.cardinal)
					var/turf/T = get_step(src, cdir)
					if(locate(/obj/structure/grille) in T)
						for(var/obj/structure/window/del_window in T)
							if(del_window.dir == turn(cdir, 180))
								qdel(del_window)
					else  // Build a window!
						var/obj/structure/window/new_window = new our_rcd.window_type(src)
						new_window.dir = cdir
			else
				new our_rcd.window_type(src)
			ChangeTurf(our_rcd.floor_type, ignore_air = TRUE) // Platings go under windows.
			return RCD_ACT_SUCCESSFULL
		if(RCD_MODE_FIRELOCK)
			if(our_rcd.checkResource(8, user))
				to_chat(user, "Building Firelock...")
				playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
				if(do_after(user, 5 SECONDS * our_rcd.toolspeed, src, category = DA_CAT_TOOL))
					if(locate(/obj/machinery/door/firedoor) in src)
						return RCD_NO_ACT
					if(!our_rcd.useResource(8, user))
						return RCD_ACT_FAILED
					playsound(get_turf(our_rcd), our_rcd.usesound, 50, 1)
					new our_rcd.firelock_type(src)
					add_attack_logs(user, src, "Constructed firelock with RCD")
					return RCD_ACT_SUCCESSFULL
				to_chat(user, span_warning("ERROR! Construction interrupted!"))
				return RCD_ACT_FAILED
			to_chat(user, span_warning("ERROR! Not enough matter in unit to construct this Firelock!"))
			playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
			return RCD_ACT_FAILED
	return RCD_NO_ACT
