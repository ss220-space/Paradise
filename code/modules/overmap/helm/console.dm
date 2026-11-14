/obj/machinery/computer/helm
	parent_type = /obj/machinery/computer/ship_console
	name = "helm control console"
	desc = "Используется для навигации космического аппарата в гиперпространстве."
	icon_keyboard = "teleport_key"
	icon_screen = "comm"
	light_color = LIGHT_COLOR_CYAN
	circuit = /obj/item/circuitboard/helm

	var/list/waypoints = list()

	var/list/preset_waypoints = list()
	var/obj/machinery/computer/camera_advanced/shuttle_docker/overmap/dock_picker
	var/helm_tab = "flight"


/obj/machinery/computer/helm/get_ru_names()
	return alist(
		NOMINATIVE = "консоль управления кораблём",
		GENITIVE = "консоли управления кораблём",
		DATIVE = "консоли управления кораблём",
		ACCUSATIVE = "консоль управления кораблём",
		INSTRUMENTAL = "консолью управления кораблём",
		PREPOSITIONAL = "консоли управления кораблём",
	)

/obj/machinery/computer/helm/Destroy()
	QDEL_NULL(dock_picker)
	return ..()

/obj/machinery/computer/helm/proc/can_pilot(mob/user)
	return isliving(user) && user.Adjacent(src)

/obj/machinery/computer/helm/proc/open_custom_dock_picker(mob/user)
	if(!vessel?.shuttle)
		to_chat(user, span_warning("Нет физического шаттла."))
		return FALSE
	if(!dock_picker)
		dock_picker = new(src)
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

/obj/machinery/computer/helm/click_alt(mob/user)
	if(!can_pilot(user) || user.incapacitated() || (stat & (NOPOWER|BROKEN)))
		return NONE
	link_vessel()
	toggle_helm(user)
	return CLICK_ACTION_SUCCESS

/obj/machinery/computer/helm/proc/toggle_helm(mob/user)
	var/datum/component/overmap_flight/nav = vessel?.flight
	if(!nav || vessel.overmap_pod)
		return FALSE
	if(nav.pilot == user)
		nav.release_pilot()
		return TRUE
	if(!can_pilot(user) || user.incapacitated() || (stat & (NOPOWER|BROKEN)) || !allowed(user))
		return FALSE
	if(nav.pilot)
		to_chat(user, span_warning("За штурвалом уже [nav.pilot.name]."))
	else if(vessel.is_programmed_locked() || vessel.is_overmap_jammed())
		to_chat(user, span_warning("Ручное управление недоступно."))
	else if(vessel.docking_approach?.aligning)
		to_chat(user, span_warning("Выполняется автодоводка. Сначала отмените стыковку."))
	else if(!vessel.can_steer())
		to_chat(user, span_warning("Судно не может маневрировать."))
	else if(vessel.docked_ship)
		to_chat(user, span_warning("Судно пристыковано к [vessel.docked_ship.get_overmap_display_name()]."))
	else if(vessel.is_jumping())
		to_chat(user, span_warning("Идёт гиперпрыжок."))
	else
		nav.take_pilot(user, src)
		return TRUE
	return FALSE
