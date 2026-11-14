/obj/effect/ship_spawner
	name = "ship spawner"
	desc = "TEMP123TEMP"
	icon = 'icons/obj/device.dmi'
	icon_state = "pinonfar"
	invisibility = INVISIBILITY_ABSTRACT
	var/template_id
	var/dock_id
	var/loading = FALSE

/obj/effect/ship_spawner/Initialize(mapload)
	. = ..()
	SSshuttle.pending_ship_spawners |= src
	if(SSshuttle.initialized)
		return INITIALIZE_HINT_LATELOAD

/obj/effect/ship_spawner/LateInitialize()
	..()
	spawn_ship()

/obj/effect/ship_spawner/Destroy()
	SSshuttle.pending_ship_spawners -= src
	SSshuttle.loading_ship_templates -= src
	return ..()

/obj/effect/ship_spawner/proc/spawn_ship()
	if(QDELETED(src) || loading)
		return null
	loading = TRUE
	var/obj/docking_port/mobile/ship
	try
		var/datum/map_template/shuttle/template = GLOB.shuttle_templates[template_id]
		if(!istype(template))
			throw EXCEPTION("Unknown shuttle template [template_id].")
		var/list/port = template.get_mobile_port_data()
		if(port?["count"] != 1)
			throw EXCEPTION("Shuttle template [template_id] must contain exactly one mobile docking port.")
		if(port["id"] && SSshuttle.assoc_mobile[port["id"]])
			throw EXCEPTION("Mobile docking port [port["id"]] already exists.")
		var/turf/anchor = get_turf(src)
		if(!anchor || (locate(/obj/docking_port/mobile) in anchor))
			throw EXCEPTION("Ship spawner [template_id] has no free anchor turf.")
		var/obj/docking_port/stationary/active_dock = locate() in anchor
		var/turf/origin = locate(anchor.x - port["x"] + 1, anchor.y - port["y"] + 1, anchor.z)
		if(!origin || !template.fits_in_map_bounds(origin))
			throw EXCEPTION("Shuttle template [template_id] does not fit inside the map.")
		SSshuttle.loading_ship_templates[src] = list(origin.x, origin.y, origin.x + template.width - 1, origin.y + template.height - 1, origin.z)
		if(!template.load(origin))
			throw EXCEPTION("Could not load shuttle template [template_id].")
		ship = locate(/obj/docking_port/mobile) in get_turf(src)
		if(!ship || ship.type != port["type"])
			throw EXCEPTION("Shuttle template [template_id] did not create its mobile docking port.")
		ship.timid = FALSE
		ship.register()
		SSovermap.area_shuttle_cache_ready = FALSE
		SSshuttle.loading_ship_templates -= src
		if(!isnull(dock_id))
			ship.roundstart_move = dock_id
		else if(active_dock)
			ship.roundstart_move = active_dock.id
		if(SSshuttle.initialized && ship.roundstart_move)
			ship.dockRoundstart()
		if(SSovermap.initialized)
			SSovermap.get_or_register_shuttle(ship)
	catch(var/exception/error)
		SSshuttle.loading_ship_templates -= src
		loading = FALSE
		stack_trace("Ship spawner [template_id] at ([x], [y], [z]) failed: [error]")
		return null
	loading = FALSE
	qdel(src)
	return ship

/datum/controller/subsystem/shuttle/proc/is_loading_ship_template(atom/source)
	if(!length(loading_ship_templates))
		return FALSE
	var/turf/spot = get_turf(source)
	if(!spot)
		return FALSE
	for(var/obj/effect/ship_spawner/spawner, record in loading_ship_templates)
		var/list/bounds = record
		if(spot.z == bounds[5] && spot.x >= bounds[1] && spot.y >= bounds[2] && spot.x <= bounds[3] && spot.y <= bounds[4])
			return TRUE
	return FALSE

/obj/effect/ship_spawner/vox_shuttle
	template_id = "roundstart_vox_shuttle"

/obj/effect/ship_spawner/sit
	template_id = "roundstart_sit"

/obj/effect/ship_spawner/syndicate
	template_id = "roundstart_syndicate"

/obj/effect/ship_spawner/steel_rain
	template_id = "roundstart_steel_rain"

/obj/effect/ship_spawner/sst
	template_id = "roundstart_sst"

/obj/effect/ship_spawner/mining
	template_id = "roundstart_mining"

/obj/effect/ship_spawner/laborcamp
	template_id = "roundstart_laborcamp"

/obj/effect/ship_spawner/addition_goal
	template_id = "roundstart_addition_goal"

/obj/effect/ship_spawner/ruins_civil_shuttle
	template_id = "roundstart_ruins_civil_shuttle"

/obj/effect/ship_spawner/ruins_transport_shuttle
	template_id = "roundstart_ruins_transport_shuttle"

/obj/effect/ship_spawner/funeral
	template_id = "roundstart_funeral"

/obj/effect/ship_spawner/pod2
	template_id = "roundstart_pod2"

/obj/effect/ship_spawner/pod1
	template_id = "roundstart_pod1"

/obj/effect/ship_spawner/shit_rain
	template_id = "roundstart_shit_rain"

/obj/effect/ship_spawner/ombra
	template_id = "roundstart_ombra"

/obj/effect/ship_spawner/ferry
	template_id = "roundstart_ferry"

/obj/effect/ship_spawner/admin
	template_id = "roundstart_admin"

/obj/effect/ship_spawner/trade_sol
	template_id = "roundstart_trade_sol"

/obj/effect/ship_spawner/gamma_shuttle
	template_id = "roundstart_gamma_shuttle"

/obj/effect/ship_spawner/supply
	template_id = "roundstart_supply"

/obj/effect/ship_spawner/pod4
	template_id = "roundstart_pod4"

/obj/effect/ship_spawner/pod3
	template_id = "roundstart_pod3"

/obj/effect/ship_spawner/specops
	template_id = "roundstart_specops"

/obj/effect/ship_spawner/emergency
	template_id = "roundstart_emergency"

/obj/effect/ship_spawner/pirateship
	template_id = "roundstart_pirateship"

/obj/effect/ship_spawner/pirateship_ruin
	template_id = "roundstart_pirateship_ruin"

/obj/effect/ship_spawner/pirateship_colony
	template_id = "roundstart_pirateship_colony"
