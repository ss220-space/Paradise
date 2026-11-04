/obj/machinery/computer/helm
	name = "helm control console"
	desc = "Используется для навигации космического аппарата в гиперпространстве."
	icon_keyboard = "teleport_key"
	icon_screen = "comm"
	light_color = LIGHT_COLOR_CYAN
	circuit = /obj/item/circuitboard/helm
	var/obj/overmap/entity/vessel

	var/list/waypoints = list()

	var/list/preset_waypoints = list()
	var/obj/machinery/computer/camera_advanced/shuttle_docker/overmap/dock_picker
	var/helm_tab = "flight"

	var/radar_reach = OVERMAP_RADAR_TERRAIN_RANGE
	var/list/selected_weapons = list()

/obj/machinery/computer/helm/get_ru_names()
	return alist(
		NOMINATIVE = "консоль управления кораблём",
		GENITIVE = "консоли управления кораблём",
		DATIVE = "консоли управления кораблём",
		ACCUSATIVE = "консоль управления кораблём",
		INSTRUMENTAL = "консолью управления кораблём",
		PREPOSITIONAL = "консоли управления кораблём",
	)

/obj/machinery/computer/helm/Initialize(mapload)
	. = ..()
	GLOB.helm_computers += src
	dock_picker = new(src)
	if(SSovermap?.initialized)
		link_vessel()

/obj/machinery/computer/helm/Destroy()
	GLOB.helm_computers -= src
	if(vessel)
		UnregisterSignal(vessel, list(COMSIG_OVERMAP_NOTICE, COMSIG_OVERMAP_DISPLAY_CHANGED))
		vessel.helms -= src
	vessel = null
	QDEL_NULL(dock_picker)
	return ..()

/obj/machinery/computer/helm/proc/link_vessel()
	var/obj/overmap/entity/resolved = SSovermap?.resolve_vessel(src)
	if(!resolved)
		return
	if(vessel && vessel != resolved)
		UnregisterSignal(vessel, list(COMSIG_OVERMAP_NOTICE, COMSIG_OVERMAP_DISPLAY_CHANGED))
		vessel.helms -= src
	vessel = resolved
	resolved.helms |= src
	RegisterSignal(resolved, COMSIG_OVERMAP_NOTICE, PROC_REF(on_overmap_notice), override = TRUE)
	RegisterSignal(resolved, COMSIG_OVERMAP_DISPLAY_CHANGED, PROC_REF(on_overmap_display_changed), override = TRUE)

/obj/machinery/computer/helm/proc/can_pilot(mob/user)
	return isliving(user) && user.Adjacent(src)

/obj/machinery/computer/helm/proc/on_overmap_notice(datum/source, text)
	SIGNAL_HANDLER
	if(text)
		atom_say(text)

/obj/machinery/computer/helm/proc/on_overmap_display_changed()
	SIGNAL_HANDLER
	SStgui.update_uis(src)

/obj/machinery/computer/helm/proc/open_custom_dock_picker(mob/user)
	if(!vessel?.shuttle)
		to_chat(user, span_warning("Нет физического шаттла."))
		return FALSE
	if(!dock_picker)
		to_chat(user, span_warning("Камера посадки недоступна."))
		return FALSE
	var/obj/overmap/entity/host = vessel.get_dock_host()
	if(!host)
		to_chat(user, span_warning("Невозможно установить произвольную точку посадки."))
		return FALSE
	if(host && !host.dock_host?.allow_custom_landing)
		to_chat(user, span_warning("Гравитационные аномалии не позволяют использовать произвольные точки подлёта."))
		return FALSE
	SStgui.close_uis(src)
	dock_picker.bind_landing_host(host)
	dock_picker.shuttleId = vessel.shuttle.id
	dock_picker.shuttlePortId = "[vessel.shuttle.id]_overmap_custom_[host.UID()]"
	dock_picker.shuttlePortName = "Произвольная точка ([host.name])"
	dock_picker.shuttle_port = vessel.shuttle
	dock_picker.my_port = vessel.get_custom_dock(host)
	dock_picker.stat &= ~NOPOWER
	dock_picker.attack_hand(user)
	return TRUE

/obj/machinery/computer/helm/proc/add_waypoint(waypoint_name, waypoint_x, waypoint_y)
	if(!waypoint_name)
		waypoint_name = "Клетка [waypoint_x]-[waypoint_y]"
	waypoints.Cut()
	waypoints[waypoint_name] = list("x" = waypoint_x, "y" = waypoint_y)
	return waypoint_name
