/area/spacepod
	name = "Spacepod"
	icon_state = "shuttle"
	requires_power = FALSE
	valid_territory = FALSE
	no_teleportlocs = TRUE
	holomap_should_draw = FALSE

/area/spacepod/hyperspace
	name = "Hyperspace"
	static_lighting = FALSE
	base_lighting_alpha = 255
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

/obj/machinery/computer/helm/pod/ui_status(mob/user, datum/ui_state/state)
	if(!overmap_pod_user_ok(user, loc))
		return UI_CLOSE
	return UI_INTERACTIVE

/obj/machinery/computer/helm/pod/can_pilot(mob/user)
	var/obj/spacepod/craft = loc
	return overmap_pod_user_ok(user, craft) && craft.pilot == user

/obj/machinery/computer/helm/pod/ui_interact(mob/user, datum/tgui/ui = null)
	if(!vessel)
		link_vessel()
	return ..()

/obj/machinery/transponder/pod
	name = "pod transponder"
	icon_preset = "pod"
	use_power = NO_POWER_USE
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
	adopt_vessel_identity()
	vessel.register_transponder(src)

/obj/machinery/transponder/pod/ui_status(mob/user, datum/ui_state/state)
	if(!overmap_pod_user_ok(user, loc))
		return UI_CLOSE
	return UI_INTERACTIVE

/obj/machinery/transponder/pod/ui_interact(mob/user, datum/tgui/ui = null)
	stat &= ~NOPOWER
	return ..()

/obj/machinery/overmap_intercom/pod
	name = "pod sector intercom"
	use_power = NO_POWER_USE
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
	generated_thrust = OVERMAP_POD_THRUST * 4
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
	return isspacepod(loc) ? OVERMAP_POD_CELL_BURN_MAX : OVERMAP_POD_CELL_BURN_BASE

/obj/machinery/ship_engine/pod/can_burn()
	if(!on || (stat & BROKEN))
		return FALSE
	var/obj/spacepod/craft = loc
	if(!isspacepod(craft) || !craft.battery || craft.health <= 0 || !COOLDOWN_FINISHED(craft, cooldown_emp))
		return FALSE
	return craft.battery.charge > 0

/obj/machinery/ship_engine/pod/resource_fraction(elapsed)
	var/obj/spacepod/craft = loc
	if(!isspacepod(craft) || !craft.battery)
		return 0
	var/cost = burn_cost() * thrust_limit * elapsed / (1 SECONDS)
	return clamp(craft.battery.charge / max(cost, 0.001), 0, 1)

/obj/machinery/ship_engine/pod/apply_thrust(elapsed = 1 SECONDS)
	if(!can_burn())
		return 0
	var/obj/spacepod/craft = loc
	var/fraction = resource_fraction(elapsed)
	var/cost = min(craft.battery.charge, burn_cost() * thrust_limit * elapsed / (1 SECONDS) * fraction)
	if(!craft.battery.use(cost))
		return 0
	return generated_thrust * thrust_limit * 4 * fraction

/obj/machinery/ship_engine/pod/get_status()
	if(!on || (stat & BROKEN))
		return ..()
	var/obj/spacepod/craft = loc
	if(!isspacepod(craft) || !craft.battery)
		return "Нет аккумулятора"
	if(craft.health <= 0)
		return "Под повреждён"
	if(!COOLDOWN_FINISHED(craft, cooldown_emp))
		return "Отключён ЭМИ"
	if(craft.battery.charge <= 0)
		return "Аккумулятор разряжен"
	return ..()

/obj/overmap/entity/pod/ship_power_report()
	. = ..()
	var/obj/item/stock_parts/cell/battery = pod?.battery
	.["cell_power"] = TRUE
	.["cell_charge"] = battery?.charge || 0
	.["cell_max"] = battery?.maxcharge || 0
	.["sources"] = !!battery

/proc/overmap_pod_user_ok(mob/user, obj/spacepod/craft)
	if(!user || !isspacepod(craft))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return user.loc == craft
