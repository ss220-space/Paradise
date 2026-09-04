/obj/machinery/computer/camera_advanced/shuttle_docker/overmap
	name = "overmap landing camera"
	desc = "Выбор произвольной точки посадки для шаттла."
	invisibility = INVISIBILITY_ABSTRACT
	density = FALSE
	use_power = NO_POWER_USE
	space_turfs_only = TRUE
	access_station = FALSE
	access_mining = FALSE
	access_away = FALSE
	access_derelict = FALSE
	shuttlePortName = "Произвольная точка"
	var/obj/overmap/entity/bound_host

/obj/machinery/computer/camera_advanced/shuttle_docker/overmap/Initialize(mapload)
	. = ..()
	stat &= ~NOPOWER

/obj/machinery/computer/camera_advanced/shuttle_docker/overmap/proc/bind_landing_host(obj/overmap/entity/host)
	bound_host = host
	var/datum/component/overmap_dock_host/pads = host?.dock_host
	access_station = pads?.z_kind == OVERMAP_DOCK_Z_STATION
	access_mining = pads?.z_kind == OVERMAP_DOCK_Z_MINING
	access_away = FALSE
	access_derelict = FALSE
	space_turfs_only = !pads?.planet_landing
	CalculateAvailable_z_lvls()
	QDEL_NULL(eyeobj)

/obj/machinery/computer/camera_advanced/shuttle_docker/overmap/proc/ruin_region()
	var/obj/overmap/entity/feature/ruin/ruin = bound_host
	if(!istype(ruin))
		return null
	return ruin.landing_region

/obj/machinery/computer/camera_advanced/shuttle_docker/overmap/proc/landing_z_allowed(z_level)
	if(!bound_host)
		return FALSE
	if(bound_host.dock_host)
		return bound_host.dock_host.allows_landing_z(z_level)
	var/datum/overmap_space_region/region = ruin_region()
	if(region)
		return z_level == region.space_z
	return FALSE

/obj/machinery/computer/camera_advanced/shuttle_docker/overmap/proc/clamp_landing_turf(turf/spot)
	var/datum/overmap_space_region/region = ruin_region()
	if(!region)
		return spot
	return region.clamp_space_turf(spot)

/obj/machinery/computer/camera_advanced/shuttle_docker/overmap/CreateEye()
	. = ..()
	if(!eyeobj)
		return
	var/turf/start
	var/obj/machinery/computer/helm/helm = loc
	if(istype(helm) && helm.vessel?.shuttle)
		var/obj/docking_port/stationary/docked = helm.vessel.shuttle.get_docked()
		if(docked && landing_z_allowed(docked.z))
			start = get_turf(docked)
	if(!start)
		var/datum/overmap_space_region/region = ruin_region()
		if(region)
			start = region.center_turf()
	if(!start)
		for(var/z_level in GLOB.space_manager.z_list)
			var/num_level = text2num(z_level)
			if(!landing_z_allowed(num_level))
				continue
			if(is_mining_level(num_level))
				var/obj/docking_port/stationary/mining_pad = SSshuttle.getDock("mining_away")
				if(mining_pad && mining_pad.z == num_level)
					start = get_turf(mining_pad)
					break
			for(var/i in 1 to 40)
				var/turf/candidate = locate(rand(12, world.maxx - 12), rand(12, world.maxy - 12), num_level)
				if(!candidate)
					continue
				if(bound_host.dock_host?.planet_landing)
					if(!overmap_lavaland_landing_blocked(candidate))
						start = candidate
						break
				else if(isspaceturf(candidate))
					start = candidate
					break
			if(start)
				break
	if(start)
		eyeobj.forceMove(clamp_landing_turf(start))

/obj/machinery/computer/camera_advanced/shuttle_docker/overmap/checkLandingTurf(turf/T, list/overlappers)
	var/datum/overmap_space_region/region = ruin_region()
	if(region)
		if(!T || !region.contains_space_turf(T))
			return SHUTTLE_DOCKER_BLOCKED
		if(shuttle_port && shuttle_port.shuttle_areas[T.loc])
			return SHUTTLE_DOCKER_LANDING_CLEAR
		if(space_turfs_only && !isspaceturf(T) && !isopenspaceturf(T))
			return SHUTTLE_DOCKER_BLOCKED
		for(var/obj/docking_port/port as anything in overlappers)
			if(!istype(port, /obj/docking_port/stationary))
				continue
			var/obj/docking_port/stationary/pad = port
			if(pad == my_port || istype(pad, /obj/docking_port/stationary/transit))
				continue
			return SHUTTLE_DOCKER_BLOCKED
		return SHUTTLE_DOCKER_LANDING_CLEAR
	. = ..()
	if(. == SHUTTLE_DOCKER_BLOCKED)
		return
	if(!landing_z_allowed(T.z))
		return SHUTTLE_DOCKER_BLOCKED
	if(bound_host.dock_host?.planet_landing && overmap_lavaland_landing_blocked(T))
		return SHUTTLE_DOCKER_BLOCKED
	for(var/obj/docking_port/port as anything in overlappers)
		if(!istype(port, /obj/docking_port/stationary))
			continue
		var/obj/docking_port/stationary/pad = port
		if(pad == my_port)
			continue
		if(istype(pad, /obj/docking_port/stationary/transit))
			continue
		return SHUTTLE_DOCKER_BLOCKED

/obj/machinery/computer/camera_advanced/shuttle_docker/overmap/powered(chan)
	return TRUE

/obj/machinery/computer/camera_advanced/shuttle_docker/overmap/is_operational()
	var/obj/machinery/computer/helm/helm = loc
	if(istype(helm))
		return helm.is_operational()
	return TRUE

/obj/machinery/computer/camera_advanced/shuttle_docker/overmap/check_eye(mob/user)
	var/obj/machinery/computer/helm/helm = loc
	if(!istype(helm) || (helm.stat & (NOPOWER|BROKEN)) || !helm.Adjacent(user) || user.incapacitated() || !user.has_vision())
		user.unset_machine()

/obj/machinery/computer/camera_advanced/shuttle_docker/overmap/attack_hand(mob/user)
	if(!iscarbon(user))
		return
	if(current_user && current_user != user)
		to_chat(user, span_warning("Консоль уже используется."))
		return
	if(!shuttle_port)
		shuttle_port = SSshuttle.getShuttle(shuttleId)
	if(QDELETED(shuttle_port))
		to_chat(user, span_warning("Нет связи с шаттлом."))
		return
	user.set_machine(src)
	if(!eyeobj)
		CreateEye()
	if(!eyeobj)
		user.unset_machine()
		to_chat(user, span_warning("Не удалось открыть камеру посадки."))
		return
	give_eye_control(user)
	if(get_turf(eyeobj))
		eyeobj.setLoc(get_turf(eyeobj))

/obj/machinery/computer/camera_advanced/shuttle_docker/overmap/placeLandingSpot()
	. = ..()
	var/obj/machinery/computer/helm/helm = loc
	if(!istype(helm) || !my_port || QDELETED(helm.vessel) || !bound_host)
		return
	my_port.overmap_dock_mode = OVERMAP_DOCK_MANUAL
	my_port.overmap_dock_label = "Произвольная точка"
	my_port.overmap_host_uid = bound_host.UID()
	if(!helm.vessel.custom_docks)
		helm.vessel.custom_docks = list()
	helm.vessel.custom_docks[bound_host.UID()] = my_port
	helm.vessel.selected_dock_id = my_port.id
	helm.vessel.overmap_shuttle?.owned_docks_dirty = TRUE

/atom/movable/screen/overmap_dock_ghost
	name = "shuttle footprint"
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "green"
	alpha = 160
	layer = ABOVE_HUD_LAYER
	plane = GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	del_on_map_removal = FALSE
	appearance_flags = RESET_COLOR | RESET_TRANSFORM | KEEP_APART

/atom/movable/screen/overmap_nav_blip
	name = "nav mark"
	icon = OVERMAP_ICON_FILE
	icon_state = OVERMAP_NAV_MARKER_STATE
	alpha = 0
	layer = ABOVE_HUD_LAYER
	plane = GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	del_on_map_removal = FALSE
	appearance_flags = RESET_COLOR | RESET_TRANSFORM | KEEP_APART
	color = "#5ad1ff"

/atom/movable/screen/overmap_self_ghost
	name = "local vessel"
	icon = OVERMAP_ICON_FILE
	icon_state = OVERMAP_ICON_SHUTTLE_C
	layer = ABOVE_HUD_LAYER
	plane = GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	del_on_map_removal = FALSE
	alpha = 0
	appearance_flags = RESET_COLOR | RESET_TRANSFORM | KEEP_APART
