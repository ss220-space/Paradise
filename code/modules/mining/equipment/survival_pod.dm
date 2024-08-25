/area/survivalpod
	name = "\improper Emergency Shelter"
	icon_state = "away"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE

/obj/item/survivalcapsule
	name = "bluespace shelter capsule"
	desc = "An emergency shelter stored within a pocket of bluespace."
	icon_state = "capsule"
	icon = 'icons/obj/mining.dmi'
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "engineering=3;bluespace=3"
	var/template_id = "shelter_alpha"
	var/datum/map_template/shelter/template
	var/used = FALSE
	var/emagged = FALSE

/obj/item/survivalcapsule/emag_act(mob/user)
	if(!emagged)
		if(user)
			to_chat(user, "<span class='warning'>You short out the safeties, allowing it to be placed in the station sector.</span>")
		emagged = TRUE
		return
	if(user)
		to_chat(user, "<span class='warning'>The safeties are already shorted out!</span>")

/obj/item/survivalcapsule/proc/get_template()
	if(template)
		return
	template = GLOB.shelter_templates[template_id]
	if(!template)
		log_runtime("Shelter template ([template_id]) not found!", src)
		qdel(src)

/obj/item/survivalcapsule/examine(mob/user)
	. = ..()
	get_template()
	. += "<span class='notice'>This capsule has the [template.name] stored.</span>"
	. += "<span class='notice'>[template.description]</span>"

/obj/item/survivalcapsule/attack_self(mob/user)
	. = ..()
	if(.)
		return .
	//Can't grab when capsule is New() because templates aren't loaded then
	get_template()
	if(used)
		return FALSE
	var/turf/UT = get_turf(user)
	if((check_level_trait(UT.z, STATION_LEVEL)) && !emagged)
		to_chat(user, span_notice("Error. Deployment was attempted on the station sector. Deployment aborted."))
		playsound(user, 'sound/machines/buzz-sigh.ogg', 15, TRUE)
		return
	loc.visible_message("<span class='warning'>[src] begins to shake. Stand back!</span>")
	used = TRUE
	addtimer(CALLBACK(src, PROC_REF(expand), user), 5 SECONDS)
	return TRUE

/// Expands the capsule into a full shelter, placing the template at the item's location (NOT triggerer's location)
/obj/item/survivalcapsule/proc/expand(mob/triggerer)
	if(QDELETED(src))
		return
	var/turf/deploy_location = get_turf(src)
	if((check_level_trait(deploy_location.z, STATION_LEVEL)) && !emagged)
		to_chat(triggerer, span_notice("Error. Expanding was attempted on the station sector. Expanding aborted."))
		playsound(triggerer, 'sound/machines/buzz-sigh.ogg', 15, TRUE)
		return
	var/status = template.check_deploy(deploy_location)
	switch(status)
		if(SHELTER_DEPLOY_BAD_AREA)
			loc.visible_message(span_warning("[src] will not function in this area."))
		if(SHELTER_DEPLOY_BAD_TURFS, SHELTER_DEPLOY_ANCHORED_OBJECTS)
			loc.visible_message(span_warning("[src] doesn't have room to deploy! You need to clear a [template.width]x[template.height] area!"))

	if(status != SHELTER_DEPLOY_ALLOWED)
		used = FALSE
		return

	yote_nearby(deploy_location)
	template.load(deploy_location, centered = TRUE)
	trigger_admin_alert(triggerer, deploy_location)
	playsound(src, 'sound/effects/phasein.ogg', 100, TRUE)
	new /obj/effect/particle_effect/smoke(get_turf(src))
	qdel(src)

/// Throws any mobs near the deployed location away from the item / shelter
/// Does some math to make closer mobs get thrown further
/obj/item/survivalcapsule/proc/yote_nearby(turf/deploy_location)
	var/width = template.width
	var/height = template.height
	var/base_x_throw_distance = ceil(width / 2)
	var/base_y_throw_distance = ceil(height / 2)
	for(var/mob/living/did_not_stand_back in range(loc, "[width]x[height]"))
		var/dir_to_center = get_dir(deploy_location, did_not_stand_back) || pick(GLOB.alldirs)
		// Aiming to throw the target just enough to get them out of the range of the shelter
		// IE: Stronger if they're closer, weaker if they're further away
		var/throw_dist = 0
		var/x_component = abs(did_not_stand_back.x - deploy_location.x)
		var/y_component = abs(did_not_stand_back.y - deploy_location.y)
		if(ISDIAGONALDIR(dir_to_center))
			throw_dist = ceil(sqrt(base_x_throw_distance ** 2 + base_y_throw_distance ** 2) - (sqrt(x_component ** 2 + y_component ** 2)))
			did_not_stand_back.forceMove(get_ranged_target_turf(deploy_location, dir_to_center, throw_dist))
		else if(dir_to_center & (NORTH|SOUTH))
			throw_dist = base_y_throw_distance - y_component + 1
			did_not_stand_back.forceMove(get_ranged_target_turf(deploy_location, dir_to_center, base_y_throw_distance))
		else if(dir_to_center & (EAST|WEST))
			throw_dist = base_x_throw_distance - x_component + 1
			did_not_stand_back.forceMove(get_ranged_target_turf(deploy_location, dir_to_center, base_x_throw_distance))
		did_not_stand_back.Knockdown(6 SECONDS)
		did_not_stand_back.throw_at(
			target = get_edge_target_turf(did_not_stand_back, dir_to_center),
			range = throw_dist,
			speed = 3,
			force = MOVE_FORCE_VERY_STRONG,
		)

/// Logs if the capsule was triggered, by default only if it happened on non-lavaland
/obj/item/survivalcapsule/proc/trigger_admin_alert(mob/triggerer, turf/trigger_loc)
	//only report capsules away from the mining/lavaland level
	if(is_mining_level(trigger_loc.z))
		return

	message_admins("[ADMIN_LOOKUPFLW(triggerer)] activated a bluespace capsule away from the mining level!")
	add_game_logs("activated a bluespace capsule away from the mining level at [COORD(trigger_loc)]", triggerer)

/obj/item/survivalcapsule/luxury
	name = "luxury bluespace shelter capsule"
	desc = "An exorbitantly expensive luxury suite stored within a pocket of bluespace."
	origin_tech = "engineering=3;bluespace=4"
	template_id = "shelter_beta"

/obj/item/survivalcapsule/luxuryelite
	name = "luxury elite bar capsule"
	desc = "A luxury bar in a capsule. Bartender required and not included."
	template_id = "shelter_charlie"

//Pod turfs and objects

//Window
/obj/structure/window/shuttle/survival_pod
	name = "pod window"
	icon = 'icons/obj/smooth_structures/pod_window.dmi'
	icon_state = "smooth"
	base_icon_state = "pod_window"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 100
	fulltile = TRUE
	flags = PREVENT_CLICK_UNDER
	reinf = TRUE
	heat_resistance = 1600
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 100)
	smooth = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_SURVIVAL_TITANIUM_WALLS + SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_WINDOW_FULLTILE
	explosion_block = 3
	level = 3
	glass_type = /obj/item/stack/sheet/titaniumglass
	glass_amount = 2

/obj/structure/window/reinforced/survival_pod
	name = "pod window"
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "pwindow"


/obj/structure/window/reinforced/survival_pod/unhittable
	obj_flags = IGNORE_HITS


//Floors
/turf/simulated/floor/pod
	name = "pod floor"
	icon_state = "podfloor"
	icon_regular_floor = "podfloor"
	floor_tile = /obj/item/stack/tile/pod

/turf/simulated/floor/pod/light
	icon_state = "podfloor_light"
	icon_regular_floor = "podfloor_light"
	floor_tile = /obj/item/stack/tile/pod/light

/turf/simulated/floor/pod/dark
	icon_state = "podfloor_dark"
	icon_regular_floor = "podfloor_dark"
	floor_tile = /obj/item/stack/tile/pod/dark

/turf/simulated/floor/pod/dark/outside //used in lavaland ruins
	oxygen = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface::oxygen //used :: to match outside atmos
	nitrogen = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface::nitrogen
	temperature = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface::temperature
	planetary_atmos = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface::planetary_atmos

//Door
/obj/machinery/door/airlock/survival_pod
	icon = 'icons/obj/doors/airlocks/survival/survival.dmi'
	overlays_file = 'icons/obj/doors/airlocks/survival/survival_overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_pod

/obj/machinery/door/airlock/survival_pod/glass
	opacity = FALSE
	glass = TRUE

/obj/structure/door_assembly/door_assembly_pod
	name = "pod airlock assembly"
	icon = 'icons/obj/doors/airlocks/survival/survival.dmi'
	base_name = "pod airlock"
	overlays_file = 'icons/obj/doors/airlocks/survival/survival_overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/survival_pod
	glass_type = /obj/machinery/door/airlock/survival_pod/glass

//Windoor
/obj/machinery/door/window/survival_pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "windoor"
	base_state = "windoor"

//Table
/obj/structure/table/survival_pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "table"
	smooth = NONE
	can_be_flipped = FALSE

//Sleeper
/obj/machinery/sleeper/survival_pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "sleeper-open"
	density = FALSE

/obj/machinery/sleeper/survival_pod/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/sleeper/survival(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

//NanoMed
/obj/machinery/vending/wallmed/survival_pod
	name = "survival pod medical supply"
	desc = "Wall-mounted Medical Equipment dispenser. This one seems just a tiny bit smaller."
	req_access = list()

	products = list(/obj/item/stack/medical/splint = 2,
					/obj/item/reagent_containers/food/pill/patch/silver_sulf = 2,
					/obj/item/reagent_containers/food/pill/patch/styptic = 2,
					/obj/item/reagent_containers/hypospray/autoinjector = 1,
					/obj/item/healthanalyzer = 1)
	contraband = list()

//Computer
/obj/item/gps/computer
	name = "pod computer"
	icon_state = "pod_computer"
	icon = 'icons/obj/lavaland/pod_computer.dmi'
	anchored = TRUE
	density = TRUE
	pixel_y = -32


/obj/item/gps/computer/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	user.visible_message(
		span_warning("[user] disassembles [src]."),
		span_notice("You start to disassemble [src]..."),
		span_italics("You hear clanking and banging noises."),
	)
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		return .
	var/obj/item/gps/gps = new(loc)
	transfer_prints_to(gps)
	gps.add_fingerprint(user)
	qdel(src)


/obj/item/gps/computer/ui_state(mob/user)
	return GLOB.default_state

/obj/item/gps/computer/attack_hand(mob/user)
	attack_self(user)

//Bed
/obj/structure/bed/pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "bed"

//Survival Storage Unit
/obj/machinery/smartfridge/survival_pod
	name = "survival pod storage"
	desc = "A heated storage unit."
	icon_state = "donkvendor"
	icon = 'icons/obj/lavaland/donkvendor.dmi'
	light_range = 8
	light_power = 1.2
	light_color = "#DDFFD3"
	max_n_of_items = 10
	pixel_y = -4
	obj_flags = NODECONSTRUCT
	var/empty = FALSE

/obj/machinery/smartfridge/survival_pod/Initialize(mapload)
	. = ..()

	if(empty)
		return

	for(var/i in 1 to 5)
		var/obj/item/reagent_containers/food/snacks/warmdonkpocket_weak/W = new(src)
		load(W)
	if(prob(50))
		var/obj/item/storage/pill_bottle/dice/D = new(src)
		load(D)
	else
		var/obj/item/instrument/guitar/G = new(src)
		load(G)

/obj/machinery/smartfridge/survival_pod/update_overlays()
	return

/obj/machinery/smartfridge/survival_pod/accept_check(obj/item/O)
	return isitem(O) && !(O.item_flags & ABSTRACT)

/obj/machinery/smartfridge/survival_pod/default_unfasten_wrench()
	return FALSE

/obj/machinery/smartfridge/survival_pod/empty
	name = "dusty survival pod storage"
	desc = "A heated storage unit. This one's seen better days."
	empty = TRUE

//Fans
/obj/structure/fans
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "fans"
	name = "environmental regulation system"
	desc = "A large machine releasing a constant gust of air."
	anchored = TRUE
	density = TRUE
	var/arbitraryatmosblockingvar = 1
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 5

/obj/structure/fans/Initialize(loc)
	. = ..()
	air_update_turf(1)

/obj/structure/fans/Destroy()
	arbitraryatmosblockingvar = 0
	air_update_turf(1)
	return ..()

/obj/structure/fans/CanAtmosPass(turf/T, vertical)
	return !arbitraryatmosblockingvar

/obj/structure/fans/deconstruct()
	if(!(obj_flags & NODECONSTRUCT))
		if(buildstacktype)
			new buildstacktype(loc, buildstackamount)
	qdel(src)


/obj/structure/fans/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	user.visible_message(
		span_warning("[user] disassembles [src]."),
		span_notice("You start to disassemble [src]..."),
		span_italics("You hear clanking and banging noises."),
	)
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		return .
	deconstruct()


/obj/structure/fans/tiny
	name = "tiny fan"
	desc = "A tiny fan, releasing a thin gust of air."
	layer = TURF_LAYER+0.1
	density = FALSE
	icon_state = "fan_tiny"
	buildstackamount = 2

/obj/structure/fans/tiny/invisible
	name = "air flow blocker"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	invisibility = INVISIBILITY_ABSTRACT
//Signs
/obj/structure/sign/mining
	name = "nanotrasen mining corps sign"
	desc = "A sign of relief for weary miners, and a warning for would-be competitors to Nanotrasen's mining claims."
	icon = 'icons/turf/walls/survival_pod_walls.dmi'
	icon_state = "ntpod"

/obj/structure/sign/mining/survival
	name = "shelter sign"
	desc = "A high visibility sign designating a safe shelter."
	icon = 'icons/turf/walls/survival_pod_walls.dmi'
	icon_state = "survival"

//Fluff
/obj/structure/tubes
	icon_state = "tubes"
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	name = "tubes"
	anchored = TRUE
	layer = MOB_LAYER - 0.2
	density = FALSE


/obj/structure/tubes/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	user.visible_message(
		span_warning("[user] disassembles [src]."),
		span_notice("You start to disassemble [src]..."),
		span_italics("You hear clanking and banging noises."),
	)
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		return .
	var/obj/item/stack/rods/rods = new(loc)
	transfer_prints_to(rods)
	rods.add_fingerprint(user)
	qdel(src)


/obj/item/fakeartefact
	name = "expensive forgery"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	var/possible = list(/obj/item/ship_in_a_bottle,
						/obj/item/gun/energy/pulse,
						/obj/item/sleeping_carp_scroll,
						/obj/item/shield/changeling,
						/obj/item/lava_staff,
						/obj/item/hierophant_club,
						/obj/item/melee/energy_katana,
						/obj/item/storage/toolbox/green/memetic,
						/obj/item/gun/projectile/automatic/l6_saw,
						/obj/item/gun/magic/staff/chaos,
						/obj/item/gun/magic/staff/spellblade,
						/obj/item/gun/magic/wand/death,
						/obj/item/gun/magic/wand/fireball,
						/obj/item/stack/telecrystal/hundred,
						/obj/item/banhammer)

/obj/item/fakeartefact/New()
	. = ..()
	var/obj/item/I = pick(possible)
	name = initial(I.name)
	icon = initial(I.icon)
	desc = initial(I.desc)
	icon_state = initial(I.icon_state)
	item_state = initial(I.item_state)
