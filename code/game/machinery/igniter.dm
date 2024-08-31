/obj/machinery/igniter
	name = "igniter"
	desc = "It's useful for igniting plasma."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "igniter1"
	plane = FLOOR_PLANE
	max_integrity = 300
	armor = list(melee = 50, bullet = 30, laser = 70, energy = 50, bomb = 20, bio = 0, rad = 0, fire = 100, acid = 70)
	resistance_flags = FIRE_PROOF
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4
	/// Are we on?
	var/on = FALSE
	/// ID to hook buttons into
	var/id = null


/obj/machinery/igniter/on
	on = TRUE


/obj/machinery/igniter/Initialize(mapload)
	. = ..()
	update_icon()


/obj/machinery/igniter/attack_ai(mob/user as mob)
	return attack_hand(user)


/obj/machinery/igniter/attack_hand(mob/user as mob)
	if(..())
		return
	add_fingerprint(user)

	use_power(50)
	on = !on
	update_icon()

	if(on)
		set_light(1, 1, "#ff821c", TRUE)
	else
		set_light_on(FALSE)


/obj/machinery/igniter/update_icon_state()
	if(stat & (NOPOWER|BROKEN))
		icon_state = "igniter0"
		return
	icon_state = "igniter[on]"


/obj/machinery/igniter/update_overlays()
	. = ..()
	underlays.Cut()
	if(on)
		underlays += emissive_appearance(icon, "igniter_lightmask", src)


/obj/machinery/igniter/process()	//ugh why is this even in process()? // AA 2022-08-02 - I guess it cant go anywhere else?
	if(on && !(stat & NOPOWER))
		var/turf/location = get_turf(src)
		if(isturf(location))
			location.hotspot_expose(1000, 500, 1)
	return TRUE


/obj/machinery/igniter/power_change(forced = FALSE)
	if(!..())
		return
	if(stat & NOPOWER)
		on = FALSE
	update_icon()


// Wall mounted remote-control igniter.

/obj/machinery/sparker
	name = "Mounted igniter"
	desc = "A wall-mounted ignition device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "migniter"
	resistance_flags = FIRE_PROOF
	var/id = null
	var/disable = FALSE
	var/last_spark = FALSE
	var/base_state = "migniter"
	anchored = TRUE


/obj/machinery/sparker/update_icon_state()
	if(disable)
		icon_state = "[base_state]-d"
	else if(powered())
		icon_state = "[base_state]"
	else
		icon_state = "[base_state]-p"


/obj/machinery/sparker/power_change(forced = FALSE)
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/sparker/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/detective_scanner))
		return ATTACK_CHAIN_PROCEED
	return ..()


/obj/machinery/sparker/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	disable = !disable
	user.visible_message(
		span_warning("[user] has [disable ? "disabled" : "reconnected"] [src]!"),
		span_warning("You [disable ? "disable" : "fix"] the connection to [src]."),
	)
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/sparker/attack_ai()
	if(anchored)
		return spark()


/obj/machinery/sparker/proc/spark()
	if(!powered())
		return

	if(disable || (last_spark && world.time < last_spark + 5 SECONDS))
		return

	flick("[base_state]-spark", src)
	do_sparks(2, 1, src)
	last_spark = world.time
	use_power(1000)

	var/turf/location = get_turf(src)
	if(isturf(location))
		location.hotspot_expose(1000, 500, 1)

	return TRUE


/obj/machinery/sparker/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	spark()
	..(severity)

