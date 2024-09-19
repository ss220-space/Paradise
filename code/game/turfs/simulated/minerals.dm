/**********************Mineral deposits**************************/

/turf/simulated/mineral //wall piece
	name = "rock"
	icon = 'icons/turf/smoothrocks.dmi'
	icon_state = "smoothrocks-0"
	base_icon_state = "smoothrocks"
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_MINERAL_WALLS
	smoothing_groups = SMOOTH_GROUP_MINERAL_WALLS
	baseturf = /turf/simulated/floor/plating/asteroid/airless
	opacity = TRUE
	density = TRUE
	blocks_air = TRUE
	init_air = FALSE
	layer = EDGED_TURF_LAYER
	// We're a BIG wall, larger then 32x32, so we need to be on the game plane
	// Otherwise we'll draw under shit in weird ways
	plane = GAME_PLANE
	var/environment_type = "asteroid"
	var/turf/simulated/floor/plating/turf_type = /turf/simulated/floor/plating/asteroid/airless
	var/mineralType = null
	var/mineralAmt = 1
	var/spread = 0 //will the seam spread?
	var/spreadChance = 0 //the percentual chance of an ore spreading to the neighbouring tiles
	var/scan_state = "" //Holder for the image we display when we're pinged by a mining scanner
	var/defer_change = 0
	var/mine_time = 4 SECONDS //Changes how fast the turf is mined by pickaxes, multiplied by toolspeed
	/// Should this be set to the normal rock colour on init?
	var/should_reset_color = TRUE
	var/hardness = 1 //how hard the material is, we'll have to have more powerful stuff if we want to blast harder materials.
	/// Typecache of all the instruments allowed to dig us.
	/// Populated in [/turf/simulated/mineral/proc/generate_picks()].
	var/list/allowed_picks_typecache
	COOLDOWN_DECLARE(last_act)


/turf/simulated/mineral/Initialize(mapload)
	. = ..()
	generate_picks()
	if(should_reset_color)
		color = null
	if(mineralType && mineralAmt && spread && spreadChance)
		for(var/dir in GLOB.cardinal)
			if(prob(spreadChance))
				var/turf/T = get_step(src, dir)
				if(istype(T, /turf/simulated/mineral/random))
					Spread(T)


/// Generates typecache of tools allowed to dig this mineral
/turf/simulated/mineral/proc/generate_picks()
	allowed_picks_typecache = typecacheof(list(
		/obj/item/pickaxe,
		/obj/item/pen/survival,
	))


/turf/simulated/mineral/proc/Spread(turf/T)
	T.ChangeTurf(type)

/turf/simulated/mineral/shuttleRotate(rotation)
	setDir(angle2dir(rotation + dir2angle(dir)))
	queue_smooth(src)

/turf/simulated/mineral/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	if(turf_type)
		underlay_appearance.icon = initial(turf_type.icon)
		underlay_appearance.icon_state = initial(turf_type.icon_state)
		return TRUE
	return ..()


/turf/simulated/mineral/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !isturf(user.loc) || !COOLDOWN_FINISHED(src, last_act) || !is_type_in_typecache(I, allowed_picks_typecache))
		return .

	COOLDOWN_START(src, last_act, mine_time * I.toolspeed * user.get_actionspeed_by_category(DA_CAT_TOOL))	// Prevents message spam

	if(!user.IsAdvancedToolUser())
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return .

	I.play_tool_sound(src)
	to_chat(user, span_notice("You start picking..."))
	if(!do_after(user, mine_time * I.toolspeed, src, category = DA_CAT_TOOL))
		if(istype(src, /turf/simulated/mineral))
			COOLDOWN_RESET(src, last_act)
		return .

	to_chat(user, span_notice("You finish cutting into the rock."))
	I.play_tool_sound(src)
	. |= (ATTACK_CHAIN_BLOCKED_ALL)
	attempt_drill(user)
	SSblackbox.record_feedback("tally", "pick_used_mining", 1, I.name)


/turf/simulated/mineral/proc/gets_drilled(mob/user, triggered_by_explosion = FALSE, override_bonus = FALSE)
	var/cached_mineralType = mineralType
	var/cached_mineralAmt = mineralAmt
	for(var/obj/effect/temp_visual/mining_overlay/M in src)
		qdel(M)
	ChangeTurf(turf_type, defer_change)
	addtimer(CALLBACK(src, PROC_REF(AfterChange)), 1, TIMER_UNIQUE)
	playsound(src, 'sound/effects/break_stone.ogg', 50, TRUE) //beautiful destruction
	if(cached_mineralType && cached_mineralAmt > 0)
		if(triggered_by_explosion && !override_bonus)
			cached_mineralAmt += 2	//bonus if it was exploded, USE EXPLOSIVES WOOO
		new cached_mineralType(src, cached_mineralAmt)
		if(is_mining_level(z))
			SSticker?.score?.score_ore_mined++ // Only include ore spawned on mining level
		SSblackbox.record_feedback("tally", "ore_mined", cached_mineralAmt, cached_mineralType)


/turf/simulated/mineral/proc/attempt_drill(mob/user,triggered_by_explosion = FALSE, power = 1)
	hardness -= power
	if(hardness <= 0)
		gets_drilled(user,triggered_by_explosion)
	else
		update_icon()


/turf/simulated/mineral/update_overlays()
	. = ..()
	// Mineral turfs are big, so they need to be on the game plane at a high layer
	// But they're also turfs, so we need to cut them out from the light mask plane
	// So we draw them as if they were on the game plane, and then overlay a copy onto
	// The wall plane (so emissives/light masks behave)
	// I am so sorry
	var/static/mutable_appearance/wall_overlay = mutable_appearance()
	wall_overlay.icon = icon
	wall_overlay.icon_state = icon_state
	SET_PLANE_EXPLICIT(wall_overlay, WALL_PLANE, src)
	. += wall_overlay

	if(hardness != initial(hardness))
		var/amount = hardness
		var/mutable_appearance/cracks = mutable_appearance('icons/turf/mining.dmi',"rock_cracks_[amount]",ON_EDGED_TURF_LAYER)
		var/matrix/M = new
		//M.Translate(4,4)
		cracks.transform = M
		. += cracks


/turf/simulated/mineral/attack_animal(mob/living/simple_animal/user)
	if((user.environment_smash & ENVIRONMENT_SMASH_WALLS) || (user.environment_smash & ENVIRONMENT_SMASH_RWALLS))
		attempt_drill()
	..()

/turf/simulated/mineral/attack_alien(mob/living/carbon/alien/M)
	to_chat(M, span_notice("You start digging into the rock..."))
	playsound(src, 'sound/effects/break_stone.ogg', 50, TRUE)
	if(do_after(M, 4 SECONDS, src))
		to_chat(M, span_notice("You tunnel into the rock."))
		attempt_drill(M)


/turf/simulated/mineral/Bumped(atom/movable/moving_atom)
	. = ..()

	if(ishuman(moving_atom))
		var/mob/living/carbon/human/human = moving_atom
		var/active_hand = human.get_active_hand()
		if(is_type_in_typecache(active_hand, allowed_picks_typecache))
			INVOKE_ASYNC(src, TYPE_PROC_REF(/atom, attackby), active_hand, human)
		return

	if(isrobot(moving_atom))
		var/mob/living/silicon/robot/robot = moving_atom
		if(is_type_in_typecache(robot.module_active, allowed_picks_typecache))
			INVOKE_ASYNC(src, TYPE_PROC_REF(/atom, attackby), robot.module_active, robot)
		return

	if(ismecha(moving_atom))
		var/obj/mecha/mecha = moving_atom
		if(istype(mecha.selected, /obj/item/mecha_parts/mecha_equipment/drill))
			mecha.selected.action(src)


/turf/simulated/mineral/acid_melt()
	ChangeTurf(baseturf)

/turf/simulated/mineral/ex_act(severity)
	..()
	switch(severity)
		if(3)
			if (prob(75))
				attempt_drill(null,TRUE,2)
			else if(prob(90))
				attempt_drill(null,TRUE,1)
		if(2)
			if (prob(90))
				attempt_drill(null,TRUE,2)
			else
				attempt_drill(null,TRUE,1)
		if(1)
			attempt_drill(null,TRUE,3)

/turf/simulated/mineral/ancient
	name = "ancient rock"
	desc = "A rare asteroid rock that appears to be resistant to all mining tools except pickaxes!"
	smooth = SMOOTH_BITMASK
	mine_time = 6 SECONDS
	color = COLOR_ANCIENT_ROCK
	layer = MAP_EDITOR_TURF_LAYER
	real_layer = TURF_LAYER
	should_reset_color = FALSE
	mineralAmt = 2
	mineralType = /obj/item/stack/ore/glass/basalt/ancient
	baseturf = /turf/simulated/floor/plating/asteroid/ancient


/turf/simulated/mineral/ancient/generate_picks()
	allowed_picks_typecache = typecacheof(list(
		/obj/item/pickaxe,
	))


/turf/simulated/mineral/ancient/burn_down()
	return

/turf/simulated/mineral/ancient/rpd_act()
	return

/turf/simulated/mineral/ancient/acid_act(acidpwr, acid_volume)
	return

/turf/simulated/mineral/ancient/ex_act(severity)
	switch(severity)
		if(3)
			return
		if(2)
			if(prob(75))
				gets_drilled(null, 1)
		if(1)
			gets_drilled(null, 1)
	return TRUE

/turf/simulated/mineral/ancient/outer
	name = "cold ancient rock"
	desc = "A rare and dense asteroid rock that appears to be resistant to everything except diamond and sonic tools! Can not be used to create portals to hell."
	mine_time = 15 SECONDS
	color = COLOR_COLD_ROCK
	temperature = TCMB
	baseturf = /turf/simulated/floor/plating/asteroid/ancient/airless


/turf/simulated/mineral/ancient/outer/generate_picks()
	allowed_picks_typecache = typecacheof(list(
		/obj/item/pickaxe/drill/jackhammer,
		/obj/item/pickaxe/diamond,
		/obj/item/pickaxe/drill/cyborg/diamond,
		/obj/item/pickaxe/drill/diamonddrill,
	))


/turf/simulated/mineral/ancient/outer/ex_act(severity)
	return

/turf/simulated/mineral/random
	var/mineralSpawnChanceList = list(/turf/simulated/mineral/uranium = 5, /turf/simulated/mineral/diamond = 1, /turf/simulated/mineral/gold = 10,
		/turf/simulated/mineral/silver = 12, /turf/simulated/mineral/plasma = 20, /turf/simulated/mineral/iron = 40, /turf/simulated/mineral/titanium = 11,
		/turf/simulated/mineral/gibtonite = 4, /turf/simulated/mineral/bscrystal = 1)
		//Currently, Adamantine won't spawn as it has no uses. -Durandan
	var/mineralChance = 6
	var/display_icon_state = "rock"

/turf/simulated/mineral/random/Initialize(mapload)

	mineralSpawnChanceList = typelist("mineralSpawnChanceList", mineralSpawnChanceList)

	if(display_icon_state)
		icon_state = display_icon_state
	. = ..()
	if (prob(mineralChance))
		var/path = pickweight(mineralSpawnChanceList)
		var/turf/T = ChangeTurf(path, FALSE, TRUE)

		if(T && ismineralturf(T))
			var/turf/simulated/mineral/M = T
			M.mineralAmt = rand(1, 2) + max(0,((hardness - 1) * 1)) //1 bonus ore for every hardness above 1
			M.environment_type = environment_type
			M.turf_type = turf_type
			M.baseturf = baseturf
			src = M
			M.levelupdate()

/turf/simulated/mineral/random/high_chance
	icon_state = "rock_highchance"
	mineralChance = 20
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium = 35, /turf/simulated/mineral/diamond = 30, /turf/simulated/mineral/gold = 45, /turf/simulated/mineral/titanium = 45,
		/turf/simulated/mineral/silver = 50, /turf/simulated/mineral/plasma = 50, /turf/simulated/mineral/bscrystal = 20, /turf/simulated/mineral/gem = 20)

/turf/simulated/mineral/random/high_chance/clown
	mineralChance = 40
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium = 35, /turf/simulated/mineral/diamond = 2, /turf/simulated/mineral/gold = 5, /turf/simulated/mineral/silver = 5,
		/turf/simulated/mineral/iron = 30, /turf/simulated/mineral/clown = 15, /turf/simulated/mineral/mime = 15, /turf/simulated/mineral/bscrystal = 10, /turf/simulated/mineral/gem = 10)

/turf/simulated/mineral/random/high_chance/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/lava/mapping_lava
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium/volcanic = 35, /turf/simulated/mineral/diamond/volcanic = 30, /turf/simulated/mineral/gold/volcanic = 45, /turf/simulated/mineral/titanium/volcanic = 45,
		/turf/simulated/mineral/silver/volcanic = 50, /turf/simulated/mineral/plasma/volcanic = 50, /turf/simulated/mineral/bscrystal/volcanic = 20, /turf/simulated/mineral/gem/volcanic = 20)

/turf/simulated/mineral/random/low_chance
	icon_state = "rock_lowchance"
	mineralChance = 4
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium = 2, /turf/simulated/mineral/diamond = 1, /turf/simulated/mineral/gold = 4, /turf/simulated/mineral/titanium = 4,
		/turf/simulated/mineral/silver = 6, /turf/simulated/mineral/plasma = 15, /turf/simulated/mineral/iron = 40,
		/turf/simulated/mineral/gibtonite = 2, /turf/simulated/mineral/bscrystal = 1, /turf/simulated/mineral/gem = 1)

/turf/simulated/mineral/random/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/lava/mapping_lava
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

	mineralChance = 14
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium/volcanic = 5, /turf/simulated/mineral/diamond/volcanic = 0.5, /turf/simulated/mineral/gold/volcanic = 10, /turf/simulated/mineral/titanium/volcanic = 11,
		/turf/simulated/mineral/silver/volcanic = 12, /turf/simulated/mineral/plasma/volcanic = 20, /turf/simulated/mineral/iron/volcanic = 40,
		/turf/simulated/mineral/gibtonite/volcanic = 4, /turf/simulated/mineral/bscrystal/volcanic = 0.5, /turf/simulated/mineral/gem/volcanic = 1)

/turf/simulated/mineral/random/labormineral
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium = 3, /turf/simulated/mineral/diamond = 1, /turf/simulated/mineral/gold = 8, /turf/simulated/mineral/titanium = 8,
		/turf/simulated/mineral/silver = 20, /turf/simulated/mineral/plasma = 30, /turf/simulated/mineral/iron = 95,
		/turf/simulated/mineral/gibtonite = 2)
	icon_state = "rock_labor"

/turf/simulated/mineral/random/labormineral/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/lava/mapping_lava
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium/volcanic = 3, /turf/simulated/mineral/diamond/volcanic = 1, /turf/simulated/mineral/gold/volcanic = 8, /turf/simulated/mineral/titanium/volcanic = 8,
		/turf/simulated/mineral/silver/volcanic = 20, /turf/simulated/mineral/plasma/volcanic = 30, /turf/simulated/mineral/bscrystal/volcanic = 1,  /turf/simulated/mineral/gem/volcanic = 1, /turf/simulated/mineral/gibtonite/volcanic = 2,
		/turf/simulated/mineral/iron/volcanic = 95)

/turf/simulated/mineral/random/volcanic/hard
	name = "hardened basalt"
	icon_state = "smoothrocks_hard-0"
	icon = 'icons/turf/smoothrocks_hard.dmi'
	base_icon_state = "smoothrocks_hard"
	mineralChance = 24
	hardness = 2
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium/volcanic/hard = 10, /turf/simulated/mineral/diamond/volcanic/hard = 2, /turf/simulated/mineral/gold/volcanic/hard = 10,
		/turf/simulated/mineral/titanium/volcanic/hard = 21, /turf/simulated/mineral/magmite/volcanic/hard = 0.5, /turf/simulated/mineral/silver/volcanic/hard = 12,
		/turf/simulated/mineral/plasma/volcanic/hard = 20, /turf/simulated/mineral/bscrystal/volcanic/hard = 2, /turf/simulated/mineral/gibtonite/volcanic/hard = 4,
		/turf/simulated/mineral/iron/volcanic/hard = 40, /turf/simulated/mineral/gem/volcanic/hard = 2)

/turf/simulated/mineral/random/volcanic/hard/double
	name = "hardened volcanic basalt"
	icon_state = "smoothrocks_volcanic-0"
	icon = 'icons/turf/smoothrocks_volcanic.dmi'
	base_icon_state = "smoothrocks_volcanic"
	mineralChance = 60
	hardness = 3
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium/volcanic/hard/double = 15, /turf/simulated/mineral/diamond/volcanic/hard/double = 3, /turf/simulated/mineral/gold/volcanic/hard/double = 15,
		/turf/simulated/mineral/titanium/volcanic/hard/double = 31, /turf/simulated/mineral/magmite/volcanic/hard/double = 2, /turf/simulated/mineral/silver/volcanic/hard/double = 12,
		/turf/simulated/mineral/plasma/volcanic/hard/double = 25, /turf/simulated/mineral/bscrystal/volcanic/hard/double = 3, /turf/simulated/mineral/gibtonite/volcanic/hard/double = 4,
		/turf/simulated/mineral/iron/volcanic/hard/double = 45, /turf/simulated/mineral/gem/volcanic/hard/double = 5, /turf/simulated/mineral/clown/volcanic/hard/double = 2,
		/turf/simulated/mineral/mime/volcanic/hard/double = 2)

/turf/simulated/mineral/random/volcanic/hard/double/high_chance
	icon_state = "rock_highchance"
	mineralChance = 60
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium/volcanic/hard/double = 25, /turf/simulated/mineral/diamond/volcanic/hard/double = 7, /turf/simulated/mineral/gold/volcanic/hard/double = 45,
		/turf/simulated/mineral/titanium/volcanic/hard/double = 45, /turf/simulated/mineral/silver/volcanic/hard/double = 20, /turf/simulated/mineral/plasma/volcanic/hard/double = 50,
		/turf/simulated/mineral/bscrystal/volcanic/hard/double = 7, /turf/simulated/mineral/magmite/volcanic/hard/double = 3, /turf/simulated/mineral/gem/volcanic/hard/double = 7,
		/turf/simulated/mineral/clown/volcanic/hard/double = 5, /turf/simulated/mineral/mime/volcanic/hard/double = 5)

// Actual minerals
/turf/simulated/mineral/iron
	mineralType = /obj/item/stack/ore/iron
	spreadChance = 20
	spread = 1
	scan_state = "rock_iron"

/turf/simulated/mineral/iron/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/iron/volcanic/hard
	name = "hardened basalt"
	icon = 'icons/turf/smoothrocks_hard.dmi'
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/simulated/mineral/iron/volcanic/hard/double
	name = "hardened volcanic basalt"
	icon = 'icons/turf/smoothrocks_volcanic.dmi'
	base_icon_state = "smoothrocks_volcanic"
	hardness = 3

/turf/simulated/mineral/uranium
	mineralType = /obj/item/stack/ore/uranium
	spreadChance = 5
	spread = 1
	scan_state = "rock_uranium"

/turf/simulated/mineral/uranium/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/uranium/volcanic/hard
	name = "hardened basalt"
	icon = 'icons/turf/smoothrocks_hard.dmi'
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/simulated/mineral/uranium/volcanic/hard/double
	name = "hardened volcanic basalt"
	icon = 'icons/turf/smoothrocks_volcanic.dmi'
	base_icon_state = "smoothrocks_volcanic"
	hardness = 3

/turf/simulated/mineral/diamond
	mineralType = /obj/item/stack/ore/diamond
	spreadChance = 0
	spread = 1
	scan_state = "rock_diamond"

/turf/simulated/mineral/diamond/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/diamond/volcanic/hard
	name = "hardened basalt"
	icon = 'icons/turf/smoothrocks_hard.dmi'
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/simulated/mineral/diamond/volcanic/hard/double
	name = "hardened volcanic basalt"
	icon = 'icons/turf/smoothrocks_volcanic.dmi'
	base_icon_state = "smoothrocks_volcanic"
	hardness = 3

/turf/simulated/mineral/gold
	mineralType = /obj/item/stack/ore/gold
	spreadChance = 5
	spread = 1
	scan_state = "rock_gold"

/turf/simulated/mineral/gold/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/gold/volcanic/hard
	name = "hardened basalt"
	icon = 'icons/turf/smoothrocks_hard.dmi'
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/simulated/mineral/gold/volcanic/hard/double
	name = "hardened volcanic basalt"
	icon = 'icons/turf/smoothrocks_volcanic.dmi'
	base_icon_state = "smoothrocks_volcanic"
	hardness = 3

/turf/simulated/mineral/silver
	mineralType = /obj/item/stack/ore/silver
	spreadChance = 5
	spread = 1
	scan_state = "rock_silver"

/turf/simulated/mineral/silver/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/silver/volcanic/hard
	name = "hardened basalt"
	icon = 'icons/turf/smoothrocks_hard.dmi'
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/simulated/mineral/silver/volcanic/hard/double
	name = "hardened volcanic basalt"
	icon = 'icons/turf/smoothrocks_volcanic.dmi'
	base_icon_state = "smoothrocks_volcanic"
	hardness = 3

/turf/simulated/mineral/titanium
	mineralType = /obj/item/stack/ore/titanium
	spreadChance = 5
	spread = 1
	scan_state = "rock_titanium"

/turf/simulated/mineral/titanium/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/titanium/volcanic/hard
	name = "hardened basalt"
	icon = 'icons/turf/smoothrocks_hard.dmi'
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/simulated/mineral/titanium/volcanic/hard/double
	name = "hardened volcanic basalt"
	icon = 'icons/turf/smoothrocks_volcanic.dmi'
	base_icon_state = "smoothrocks_volcanic"
	hardness = 3

/turf/simulated/mineral/plasma
	mineralType = /obj/item/stack/ore/plasma
	spreadChance = 8
	spread = 1
	scan_state = "rock_plasma"

/turf/simulated/mineral/plasma/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/plasma/volcanic/hard
	name = "hardened basalt"
	icon = 'icons/turf/smoothrocks_hard.dmi'
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/simulated/mineral/plasma/volcanic/hard/double
	name = "hardened volcanic basalt"
	icon = 'icons/turf/smoothrocks_volcanic.dmi'
	base_icon_state = "smoothrocks_volcanic"
	hardness = 3

/turf/simulated/mineral/clown
	mineralType = /obj/item/stack/ore/bananium
	mineralAmt = 3
	spreadChance = 0
	spread = 0
	scan_state = "rock_clown"

/turf/simulated/mineral/clown/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/clown/volcanic/hard
	name = "hardened basalt"
	icon = 'icons/turf/smoothrocks_hard.dmi'
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/simulated/mineral/clown/volcanic/hard/double
	name = "hardened volcanic basalt"
	icon = 'icons/turf/smoothrocks_volcanic.dmi'
	base_icon_state = "smoothrocks_volcanic"
	hardness = 3

/turf/simulated/mineral/mime
	mineralType = /obj/item/stack/ore/tranquillite
	mineralAmt = 3
	spreadChance = 0
	spread = 0
	scan_state = "rock_mime"

/turf/simulated/mineral/mime/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/mime/volcanic/hard
	name = "hardened basalt"
	icon = 'icons/turf/smoothrocks_hard.dmi'
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/simulated/mineral/mime/volcanic/hard/double
	name = "hardened volcanic basalt"
	icon = 'icons/turf/smoothrocks_volcanic.dmi'
	base_icon_state = "smoothrocks_volcanic"
	hardness = 3

/turf/simulated/mineral/bscrystal
	mineralType = /obj/item/stack/ore/bluespace_crystal
	mineralAmt = 1
	spreadChance = 0
	spread = 0
	scan_state = "rock_bscrystal"

/turf/simulated/mineral/bscrystal/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/bscrystal/volcanic/hard
	name = "hardened basalt"
	icon = 'icons/turf/smoothrocks_hard.dmi'
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/simulated/mineral/bscrystal/volcanic/hard/double
	name = "hardened volcanic basalt"
	icon = 'icons/turf/smoothrocks_volcanic.dmi'
	base_icon_state = "smoothrocks_volcanic"
	hardness = 3

/turf/simulated/mineral/gem
	mineralType = /obj/item/gem/random
	spread = 0
	mineralAmt = 1
	scan_state = "rock_Gem"

/turf/simulated/mineral/gem/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/gem/volcanic/hard
	name = "hardened basalt"
	icon = 'icons/turf/smoothrocks_hard.dmi'
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/simulated/mineral/gem/volcanic/hard/double
	name = "hardened volcanic basalt"
	icon = 'icons/turf/smoothrocks_volcanic.dmi'
	base_icon_state = "smoothrocks_volcanic"
	hardness = 3

/turf/simulated/mineral/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt
	baseturf = /turf/simulated/floor/plating/asteroid/basalt
	oxygen = 14
	nitrogen = 23
	temperature = 300

/turf/simulated/mineral/volcanic/lava_land_surface
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/lava/mapping_lava
	defer_change = 1

/turf/simulated/mineral/volcanic/lava_land_surface/hard
	name = "hardened basalt"
	icon = 'icons/turf/smoothrocks_hard.dmi'
	base_icon_state = "smoothrocks_hard"

/turf/simulated/mineral/volcanic/lava_land_surface/hard/double
	name = "hardened volcanic basalt"
	icon = 'icons/turf/smoothrocks_volcanic.dmi'
	base_icon_state = "smoothrocks_volcanic"
	hardness = 3

//gibtonite state defines
#define GIBTONITE_UNSTRUCK 0
#define GIBTONITE_ACTIVE 1
#define GIBTONITE_STABLE 2
#define GIBTONITE_DETONATE 3

// Gibtonite
/turf/simulated/mineral/gibtonite
	mineralAmt = 1
	spreadChance = 0
	spread = 0
	scan_state = "rock_gibtonite"
	var/det_time = 8 //Countdown till explosion, but also rewards the player for how close you were to detonation when you defuse it
	var/stage = GIBTONITE_UNSTRUCK //How far into the lifecycle of gibtonite we are
	var/activated_ckey = null //These are to track who triggered the gibtonite deposit for logging purposes
	var/activated_name = null
	var/mutable_appearance/activated_overlay

/turf/simulated/mineral/gibtonite/Initialize(mapload)
	det_time = rand(8,10) //So you don't know exactly when the hot potato will explode
	. = ..()


/turf/simulated/mineral/gibtonite/attackby(obj/item/I, mob/user, params)
	. = ..()

	var/static/list/allowed_scan_tools = typecacheof(list(
		/obj/item/mining_scanner,
		/obj/item/mecha_parts/mecha_equipment/mining_scanner,
		/obj/item/t_scanner/adv_mining_scanner,
	))
	if(ATTACK_CHAIN_CANCEL_CHECK(.) || stage != GIBTONITE_ACTIVE || !isturf(user.loc) || !is_type_in_typecache(I, allowed_scan_tools))
		return .

	. |= ATTACK_CHAIN_SUCCESS
	user.visible_message(
		span_notice("[user] holds [I] to [src]..."),
		span_notice("You use [I] to locate where to cut off the chain reaction and attempt to stop it...")
	)
	defuse()


/turf/simulated/mineral/gibtonite/proc/explosive_reaction(mob/user = null, triggered_by_explosion = 0)
	if(stage == GIBTONITE_UNSTRUCK)
		activated_overlay = mutable_appearance('icons/turf/smoothrocks.dmi', "rock_Gibtonite_active", ON_EDGED_TURF_LAYER)
		add_overlay(activated_overlay)
		name = "gibtonite deposit"
		desc = "An active gibtonite reserve. Run!"
		stage = GIBTONITE_ACTIVE
		visible_message(span_danger("There was gibtonite inside! It's going to explode!"))
		var/turf/bombturf = get_turf(src)

		var/notify_admins = 0
		if(!is_mining_level(z))
			notify_admins = 1
			if(!triggered_by_explosion)
				message_admins("[key_name_admin(user)] has triggered a gibtonite deposit reaction at [ADMIN_VERBOSEJMP(bombturf)].")
			else
				message_admins("An explosion has triggered a gibtonite deposit reaction at [ADMIN_VERBOSEJMP(bombturf)].")

		if(!triggered_by_explosion)
			add_game_logs("has triggered a gibtonite deposit reaction at [AREACOORD(bombturf)].", user)
		else
			add_game_logs("An explosion has triggered a gibtonite deposit reaction at [AREACOORD(bombturf)]")

		countdown(notify_admins)

/turf/simulated/mineral/gibtonite/proc/countdown(notify_admins = 0)
	set waitfor = 0
	while(istype(src, /turf/simulated/mineral/gibtonite) && stage == GIBTONITE_ACTIVE && det_time > 0 && mineralAmt >= 1)
		det_time--
		sleep(5)
	if(istype(src, /turf/simulated/mineral/gibtonite))
		if(stage == GIBTONITE_ACTIVE && det_time <= 0 && mineralAmt >= 1)
			var/turf/bombturf = get_turf(src)
			mineralAmt = 0
			stage = GIBTONITE_DETONATE
			explosion(bombturf,1,3,5, adminlog = notify_admins, cause = src)

/turf/simulated/mineral/gibtonite/proc/defuse()
	if(stage == GIBTONITE_ACTIVE)
		cut_overlay(activated_overlay)
		activated_overlay.icon_state = "rock_Gibtonite_inactive"
		add_overlay(activated_overlay)
		desc = "An inactive gibtonite reserve. The ore can be extracted."
		stage = GIBTONITE_STABLE
		if(det_time < 0)
			det_time = 0
		visible_message(span_notice("The chain reaction was stopped! The gibtonite had [det_time] reactions left till the explosion!"))

/turf/simulated/mineral/gibtonite/attempt_drill(mob/user, triggered_by_explosion = 0)
	if(stage == GIBTONITE_UNSTRUCK && mineralAmt >= 1) //Gibtonite deposit is activated
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg', 50, TRUE)
		explosive_reaction(user, triggered_by_explosion)
		return
	if(stage == GIBTONITE_ACTIVE && mineralAmt >= 1) //Gibtonite deposit goes kaboom
		var/turf/bombturf = get_turf(src)
		mineralAmt = 0
		stage = GIBTONITE_DETONATE
		explosion(bombturf,1,2,5, adminlog = 0)
	if(stage == GIBTONITE_STABLE) //Gibtonite deposit is now benign and extractable. Depending on how close you were to it blowing up before defusing, you get better quality ore.
		var/obj/item/twohanded/required/gibtonite/gibtonite = new(src)
		if(det_time <= 0)
			gibtonite.quality = 3
		else if(det_time >= 1 && det_time <= 2)
			gibtonite.quality = 2
		gibtonite.update_icon(UPDATE_ICON_STATE)

	ChangeTurf(turf_type, defer_change)
	addtimer(CALLBACK(src, PROC_REF(AfterChange)), 1, TIMER_UNIQUE)


/turf/simulated/mineral/gibtonite/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/gibtonite/volcanic/hard
	name = "hardened basalt"
	icon = 'icons/turf/smoothrocks_hard.dmi'
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/simulated/mineral/gibtonite/volcanic/hard/double
	name = "hardened volcanic basalt"
	icon = 'icons/turf/smoothrocks_volcanic.dmi'
	base_icon_state = "smoothrocks_volcanic"
	hardness = 3

#undef GIBTONITE_UNSTRUCK
#undef GIBTONITE_ACTIVE
#undef GIBTONITE_STABLE
#undef GIBTONITE_DETONATE

//magmite
/turf/simulated/mineral/magmite
	mineralType = /obj/item/magmite
	spread = 0
	scan_state = "rock_Magmite"

/turf/simulated/mineral/magmite/gets_drilled(mob/user, triggered_by_explosion = FALSE)
	if(!triggered_by_explosion)
		mineralAmt = 0
	..(user,triggered_by_explosion,TRUE)

/turf/simulated/mineral/magmite/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt
	baseturf = /turf/simulated/floor/plating/asteroid/basalt
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/magmite/volcanic/hard
	name = "hardened basalt"
	icon = 'icons/turf/smoothrocks_hard.dmi'
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/simulated/mineral/magmite/volcanic/hard/double
	name = "hardened volcanic basalt"
	icon = 'icons/turf/smoothrocks_volcanic.dmi'
	base_icon_state = "smoothrocks_volcanic"
	hardness = 3
