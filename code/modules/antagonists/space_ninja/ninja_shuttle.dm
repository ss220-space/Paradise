/obj/machinery/computer/shuttle/ninja
	name = "Spider Clan \"Ombra\" shuttle console"
	desc = "Используется для вызова и отправки шаттла \"Ombra\"."
	icon_keyboard = "generic_key"
	icon_screen = "ninja_shuttle"
	req_access = list()
	bubble_icon = "syndibot"
	shuttleId = "ombra"
	possible_destinations = "ombra_home;ombra_away;ombra_custom"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	obj_flags = NODECONSTRUCT

/obj/machinery/computer/shuttle/ninja/Initialize(mapload)
	. = ..()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_OVERMAP_NINJA_CONSOLE, src)

/obj/machinery/computer/camera_advanced/shuttle_docker/ninja
	name = "Spider Clan \"Ombra\" shuttle navigation computer"
	desc = "Используется, чтобы указать точное местоположение для отправки шаттла \"Ombra\"."
	icon_screen = "ninja_navigation"
	icon_keyboard = "generic_key"
	shuttleId = "ombra"
	shuttlePortId = "ombra_custom"
	bubble_icon = "syndibot"
	view_range = 13
	x_offset = -5
	y_offset = -1
	see_hidden = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	obj_flags = NODECONSTRUCT

/area/shuttle/ninja
	icon_state = "shuttlegrn"
	name = "Spider Clan \"Ombra\" Shuttle"
	nad_allowed = TRUE
	area_flags = NONE

/proc/overmap_virtual_console_ok(mob/user, obj/overmap/entity/vessel)
	if(!user || user.incapacitated())
		return FALSE
	return overmap_ninja_can_remote(user, vessel)

/obj/machinery/computer/helm/virtual
	name = "remote helm"
	invisibility = INVISIBILITY_ABSTRACT
	density = FALSE
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/computer/helm/virtual/Initialize(mapload)
	. = ..()
	stat &= ~NOPOWER
	if(vessel)
		UnregisterSignal(vessel, list(COMSIG_OVERMAP_MOVED, COMSIG_OVERMAP_NOTICE, COMSIG_OVERMAP_DISPLAY_CHANGED))
		vessel.helms -= src
		vessel = null

/obj/machinery/computer/helm/virtual/link_vessel()
	return

/obj/machinery/computer/helm/virtual/powered(chan)
	return TRUE

/obj/machinery/computer/helm/virtual/ui_status(mob/user, datum/ui_state/state)
	if(overmap_virtual_console_ok(user, vessel))
		return UI_INTERACTIVE
	return UI_CLOSE

/obj/machinery/computer/helm/virtual/proc/bind_target(obj/overmap/entity/target)
	if(!target)
		return
	if(vessel && vessel != target)
		UnregisterSignal(vessel, list(COMSIG_OVERMAP_MOVED, COMSIG_OVERMAP_NOTICE, COMSIG_OVERMAP_DISPLAY_CHANGED))
		vessel.helms -= src
	vessel = target
	target.helms |= src
	RegisterSignal(target, COMSIG_OVERMAP_MOVED, PROC_REF(on_overmap_moved), override = TRUE)
	RegisterSignal(target, COMSIG_OVERMAP_NOTICE, PROC_REF(on_overmap_notice), override = TRUE)
	RegisterSignal(target, COMSIG_OVERMAP_DISPLAY_CHANGED, PROC_REF(on_overmap_display_changed), override = TRUE)
	update_map_view()

/obj/machinery/computer/sensors/virtual
	name = "remote sensors"
	invisibility = INVISIBILITY_ABSTRACT
	density = FALSE
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE
	can_print = FALSE
	can_dump = FALSE

/obj/machinery/computer/sensors/virtual/Initialize(mapload)
	. = ..()
	stat &= ~NOPOWER
	if(vessel)
		UnregisterSignal(vessel, list(COMSIG_OVERMAP_MOVED, COMSIG_OVERMAP_DISPLAY_CHANGED))
		vessel.unregister_sensor(src)
		vessel = null

/obj/machinery/computer/sensors/virtual/link_vessel()
	return

/obj/machinery/computer/sensors/virtual/powered(chan)
	return TRUE

/obj/machinery/computer/sensors/virtual/can_run()
	if(!vessel)
		return FALSE
	if(!vessel.has_working_sensor(view_mode))
		return FALSE
	if(view_mode == OVERMAP_SENSOR_KIND_LONG)
		return vessel.has_working_sensor(OVERMAP_SENSOR_KIND_LONG)
	return TRUE

/obj/machinery/computer/sensors/virtual/ui_status(mob/user, datum/ui_state/state)
	if(overmap_virtual_console_ok(user, vessel))
		return UI_INTERACTIVE
	return UI_CLOSE

/obj/machinery/computer/sensors/virtual/proc/bind_target(obj/overmap/entity/target)
	if(!target)
		return
	if(vessel && vessel != target)
		UnregisterSignal(vessel, list(COMSIG_OVERMAP_MOVED, COMSIG_OVERMAP_DISPLAY_CHANGED))
		vessel.unregister_sensor(src)
	target.register_sensor(src)
	RegisterSignal(target, COMSIG_OVERMAP_MOVED, PROC_REF(on_overmap_moved), override = TRUE)
	RegisterSignal(target, COMSIG_OVERMAP_DISPLAY_CHANGED, PROC_REF(on_overmap_display_changed), override = TRUE)
	if(!target.has_working_sensor(view_mode))
		if(target.has_working_sensor(OVERMAP_SENSOR_KIND_LONG))
			view_mode = OVERMAP_SENSOR_KIND_LONG
		else if(target.has_working_sensor(OVERMAP_SENSOR_KIND_SHORT))
			view_mode = OVERMAP_SENSOR_KIND_SHORT
	update_map_view()

/obj/machinery/transponder/virtual
	name = "remote transponder"
	invisibility = INVISIBILITY_ABSTRACT
	density = FALSE
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/transponder/virtual/Initialize(mapload)
	. = ..()
	stat &= ~NOPOWER
	GLOB.transponders -= src
	if(vessel)
		if(vessel.transponder == src)
			vessel.unregister_transponder(src)
		vessel = null

/obj/machinery/transponder/virtual/link_vessel()
	return

/obj/machinery/transponder/virtual/powered(chan)
	return TRUE

/obj/machinery/transponder/virtual/is_transmitting()
	return distress || broadcasting

/obj/machinery/transponder/virtual/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OvermapTransponder", name)
		ui.open()

/obj/machinery/transponder/virtual/ui_status(mob/user, datum/ui_state/state)
	if(overmap_virtual_console_ok(user, vessel))
		return UI_INTERACTIVE
	return UI_CLOSE

/obj/machinery/transponder/virtual/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(stat & BROKEN)
		stat &= ~BROKEN
	return ..()

/obj/machinery/transponder/virtual/proc/bind_target(obj/overmap/entity/target)
	if(!target)
		return
	vessel = target
	var/obj/machinery/transponder/real = target.transponder
	if(real && real != src)
		broadcast_name = real.broadcast_name
		broadcast_color = real.broadcast_color
		icon_preset = real.icon_preset
		distress = real.distress
		broadcasting = real.broadcasting
		identity_locked = real.identity_locked
		QDEL_LIST(iff_channels)
		iff_channels = list()
		real.ensure_iff_channels()
		for(var/datum/overmap_iff_channel/channel as anything in real.iff_channels)
			iff_channels += new /datum/overmap_iff_channel(channel.id, channel.label, channel.permanent, channel.receive, channel.transmit)
		return
	adopt_vessel_identity()

/obj/machinery/transponder/virtual/push_to_vessel()
	if(!vessel)
		return
	var/obj/machinery/transponder/real = vessel.transponder
	if(real && real != src)
		real.broadcast_name = broadcast_name
		real.broadcast_color = broadcast_color
		real.icon_preset = icon_preset
		real.distress = distress
		real.broadcasting = broadcasting
		real.identity_locked = identity_locked
		QDEL_LIST(real.iff_channels)
		real.iff_channels = list()
		for(var/datum/overmap_iff_channel/channel as anything in iff_channels)
			real.iff_channels += new /datum/overmap_iff_channel(channel.id, channel.label, channel.permanent, channel.receive, channel.transmit)
		real.push_to_vessel()
		return
	. = ..()
	if(!vessel.transponder)
		vessel.register_transponder(src)

/obj/machinery/computer/helm/virtual/power_change(forced = FALSE)
	stat &= ~NOPOWER

/obj/machinery/computer/sensors/virtual/power_change(forced = FALSE)
	stat &= ~NOPOWER

/obj/machinery/transponder/virtual/power_change(forced = FALSE)
	stat &= ~NOPOWER
	if(vessel)
		vessel.sync_transponder()
