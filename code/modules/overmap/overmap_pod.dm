/area/spacepod
	name = "Spacepod"
	icon_state = "shuttle"
	requires_power = FALSE
	valid_territory = FALSE
	has_gravity = FALSE
	no_teleportlocs = TRUE
	holomap_should_draw = FALSE

/area/spacepod/hyperspace
	name = "Hyperspace"
	static_lighting = FALSE
	base_lighting_alpha = 255
	parallax_movedir = SOUTH
	moving = TRUE

/obj/machinery/computer/helm/pod
	name = "pod helm"
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	density = FALSE
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/computer/helm/pod/Initialize(mapload)
	. = ..()
	stat &= ~NOPOWER

/obj/machinery/computer/helm/pod/powered(chan)
	return TRUE

/obj/machinery/computer/helm/pod/link_vessel()
	var/obj/spacepod/craft = loc
	if(!isspacepod(craft) || !craft.overmap_vessel)
		return
	if(vessel && vessel != craft.overmap_vessel)
		vessel.helms -= src
	vessel = craft.overmap_vessel
	vessel.helms |= src
	update_map_view()

/obj/machinery/computer/helm/pod/check_eye(mob/user)
	if(!overmap_pod_user_ok(user, loc) || !vessel)
		unlook(user)

/obj/machinery/computer/helm/pod/ui_status(mob/user, datum/ui_state/state)
	if(!overmap_pod_user_ok(user, loc))
		return UI_CLOSE
	return UI_INTERACTIVE

/obj/machinery/computer/helm/pod/ui_interact(mob/user, datum/tgui/ui = null)
	if(!vessel)
		link_vessel()
	return ..()

/obj/machinery/transponder/pod
	name = "pod transponder"
	icon_preset = "pod"
	lock_icon = TRUE
	use_power = NO_POWER_USE
	density = FALSE
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/transponder/pod/Initialize(mapload)
	. = ..()
	stat &= ~NOPOWER

/obj/machinery/transponder/pod/powered(chan)
	return TRUE

/obj/machinery/transponder/pod/snap_to_wall()
	pixel_x = 0
	pixel_y = 0

/obj/machinery/transponder/pod/link_vessel()
	var/obj/spacepod/craft = loc
	if(!isspacepod(craft) || !craft.overmap_vessel)
		return
	if(vessel && vessel != craft.overmap_vessel)
		vessel.unregister_transponder(src)
	vessel = craft.overmap_vessel
	if(!broadcast_name)
		broadcast_name = craft.name
	vessel.register_transponder(src)

/obj/machinery/transponder/pod/ui_status(mob/user, datum/ui_state/state)
	if(!overmap_pod_user_ok(user, loc))
		return UI_CLOSE
	return UI_INTERACTIVE

/obj/machinery/transponder/pod/ui_interact(mob/user, datum/tgui/ui = null)
	stat &= ~NOPOWER
	return ..()

/obj/machinery/transponder/pod/syndicate
	broadcast_color = COLOR_RED
	broadcasting = FALSE
	preset_iff_ids = list(OVERMAP_IFF_SYNDICATE)

/obj/machinery/overmap_intercom/pod
	name = "pod sector intercom"
	use_power = NO_POWER_USE
	density = FALSE
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/overmap_intercom/pod/Initialize(mapload)
	. = ..()
	stat &= ~NOPOWER

/obj/machinery/overmap_intercom/pod/powered(chan)
	return TRUE

/obj/machinery/overmap_intercom/pod/snap_to_wall()
	pixel_x = 0
	pixel_y = 0

/obj/machinery/overmap_intercom/pod/link_vessel()
	var/obj/spacepod/craft = loc
	if(!isspacepod(craft) || !craft.overmap_vessel)
		return
	vessel = craft.overmap_vessel

/obj/machinery/overmap_intercom/pod/ui_status(mob/user, datum/ui_state/state)
	if(!overmap_pod_user_ok(user, loc))
		return UI_CLOSE
	return UI_INTERACTIVE

/obj/machinery/overmap_intercom/pod/ui_interact(mob/user, datum/tgui/ui = null)
	stat &= ~NOPOWER
	return ..()

/obj/machinery/ship_engine/pod
	name = "pod overmap drive"
	generated_thrust = OVERMAP_POD_THRUST
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	density = FALSE
	opacity = FALSE
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/ship_engine/pod/Initialize(mapload)
	. = ..()
	stat &= ~NOPOWER

/obj/machinery/ship_engine/pod/powered(chan)
	return TRUE

/obj/machinery/ship_engine/pod/link_vessel()
	var/obj/spacepod/craft = loc
	if(!isspacepod(craft) || !craft.overmap_vessel)
		return
	craft.overmap_vessel.register_engine(src)

/obj/machinery/ship_engine/pod/proc/burn_cost()
	var/obj/spacepod/craft = loc
	if(!isspacepod(craft))
		return OVERMAP_POD_CELL_BURN_BASE
	var/datum/component/overmap_flight/nav = craft.overmap_vessel?.flight
	var/power = nav?.held_thrust_power || 1
	if(nav?.held_brake)
		power = 1
	return clamp(round(OVERMAP_POD_CELL_BURN_BASE + (OVERMAP_POD_CELL_BURN_MAX - OVERMAP_POD_CELL_BURN_BASE) * power), 1, OVERMAP_POD_CELL_BURN_MAX)

/obj/machinery/ship_engine/pod/can_burn()
	if(!on || (stat & BROKEN))
		return FALSE
	var/obj/spacepod/craft = loc
	if(!isspacepod(craft) || !craft.battery)
		return FALSE
	return craft.battery.charge >= burn_cost()

/obj/machinery/ship_engine/pod/apply_thrust()
	if(!can_burn())
		return 0
	var/obj/spacepod/craft = loc
	if(!craft.battery.use(burn_cost()))
		return 0
	return get_thrust()

/proc/overmap_pod_user_ok(mob/user, obj/spacepod/craft)
	if(!user || !isspacepod(craft))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return user.loc == craft
