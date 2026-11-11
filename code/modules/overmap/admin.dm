/obj/overmap/entity/admin_shell
	name = "admin helm"
	hidden_from_contacts = TRUE
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	overmap_kind = OVERMAP_KIND_OTHER
	var/obj/overmap/slave

/obj/overmap/entity/admin_shell/add_overmap_components()
	AddComponent(/datum/component/overmap_sensors)
	AddComponent(/datum/component/overmap_flight)

/obj/overmap/entity/admin_shell/proc/bind_slave(obj/overmap/token)
	slave = token
	name = token.get_overmap_display_name()
	icon = token.icon
	icon_state = token.icon_state
	sector = token.sector
	if(token.sector)
		token.sector.objects |= src
	speed = token.speed.Copy()
	position = token.position.Copy()
	if(token.loc)
		forceMove(token.loc)
	RegisterSignal(src, COMSIG_OVERMAP_MOVED, PROC_REF(sync_slave))
	RegisterSignal(token, COMSIG_QDELETING, PROC_REF(on_slave_qdel))

/obj/overmap/entity/admin_shell/proc/sync_slave()
	SIGNAL_HANDLER
	if(QDELETED(slave))
		return
	var/turf/here = loc
	if(isturf(here) && slave.loc != here)
		slave.forceMove(here)
	slave.sector = sector
	if(sector)
		sector.objects |= slave
	slave.speed = speed.Copy()
	slave.position = position.Copy()
	slave.update_overmap_pixel()
	slave.movable = TRUE
	slave.halted = halted

/obj/overmap/entity/admin_shell/proc/on_slave_qdel()
	SIGNAL_HANDLER
	slave = null
	qdel(src)

/obj/overmap/entity/admin_shell/Destroy()
	if(slave)
		UnregisterSignal(slave, COMSIG_QDELETING)
	slave = null
	return ..()

/obj/machinery/computer/helm/admin
	name = "admin helm"
	invisibility = INVISIBILITY_ABSTRACT
	density = FALSE
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/computer/helm/admin/Destroy()
	var/obj/overmap/entity/admin_shell/shell = vessel
	if(vessel?.flight?.pilot_helm == src)
		vessel.flight.release_pilot()
	. = ..()
	if(istype(shell) && !length(shell.helms))
		qdel(shell)

/obj/machinery/computer/helm/admin/ui_close(mob/user)
	. = ..()
	if(!QDELING(src))
		qdel(src)

/obj/machinery/computer/helm/admin/Initialize(mapload)
	. = ..()
	stat &= ~NOPOWER
	if(vessel)
		UnregisterSignal(vessel, list(COMSIG_OVERMAP_NOTICE, COMSIG_OVERMAP_DISPLAY_CHANGED))
		vessel.helms -= src
		vessel = null

/obj/machinery/computer/helm/admin/link_vessel()
	return

/obj/machinery/computer/helm/admin/powered(chan)
	return TRUE

/obj/machinery/computer/helm/admin/can_pilot(mob/user)
	return user?.client && check_rights_for(user.client, R_ADMIN | R_EVENT)

/obj/machinery/computer/helm/admin/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN | R_EVENT)

/obj/machinery/computer/helm/admin/ui_status(mob/user, datum/ui_state/state)
	if(user?.client && check_rights_for(user.client, R_ADMIN | R_EVENT))
		return UI_INTERACTIVE
	return UI_CLOSE

/obj/machinery/computer/helm/admin/proc/bind_target(obj/overmap/entity/target)
	if(!target)
		return
	if(vessel && vessel != target)
		UnregisterSignal(vessel, list(COMSIG_OVERMAP_NOTICE, COMSIG_OVERMAP_DISPLAY_CHANGED))
		vessel.helms -= src
	vessel = target
	target.helms |= src
	RegisterSignal(target, COMSIG_OVERMAP_NOTICE, PROC_REF(on_overmap_notice), override = TRUE)
	RegisterSignal(target, COMSIG_OVERMAP_DISPLAY_CHANGED, PROC_REF(on_overmap_display_changed), override = TRUE)
