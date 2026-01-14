/obj/machinery/quantumpad
	name = "quantum pad"
	desc = "A bluespace quantum-linked telepad used for teleporting objects to other quantum pads."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "qpad"
	anchored = TRUE
	idle_power_usage = 200
	active_power_usage = 5000
	var/teleport_cooldown = 400 //30 seconds base due to base parts
	var/teleport_speed = 50
	var/last_teleport //to handle the cooldown
	var/teleporting = FALSE //if it's in the process of teleporting
	var/power_efficiency = 1
	var/obj/machinery/quantumpad/linked_pad = null

/obj/machinery/quantumpad/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/quantumpad,
	))

	component_parts = list()
	component_parts += new /obj/item/circuitboard/quantumpad(null)
	component_parts += new /obj/item/stack/ore/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/quantumpad/Destroy()
	linked_pad = null
	return ..()

/obj/machinery/quantumpad/RefreshParts()
	var/E = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		E += C.rating
	power_efficiency = E
	E = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		E += M.rating
	teleport_speed = max(initial(teleport_speed) - (E*10), 0)
	teleport_cooldown = max(initial(teleport_cooldown) - (E * 100), 0)

/obj/machinery/quantumpad/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()

/obj/machinery/quantumpad/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_deconstruction_crowbar(user, I)

/obj/machinery/quantumpad/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/M = I
	if(panel_open)
		M.set_multitool_buffer(user, src)
	else
		linked_pad = M.buffer
		investigate_log("[key_name_log(user)] linked [src] to [M.buffer] at [COORD(linked_pad)].", INVESTIGATE_TELEPORTATION)
		to_chat(user, span_notice("You link the [src] to the one in the [I.name]'s buffer."))

/obj/machinery/quantumpad/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_deconstruction_screwdriver(user, "pad-o", initial(icon_state), I)

/obj/machinery/quantumpad/attack_hand(mob/user)
	if(panel_open)
		to_chat(user, span_warning("The panel must be closed before operating this machine!"))
		return

	if(!linked_pad || QDELETED(linked_pad))
		to_chat(user, span_warning("There is no linked pad!"))
		return

	if(world.time < last_teleport + teleport_cooldown)
		to_chat(user, span_warning("[src] is recharging power. Please wait [round((last_teleport + teleport_cooldown - world.time) / 10)] seconds."))
		return

	if(teleporting)
		to_chat(user, span_warning("[src] is charging up. Please wait."))
		return

	if(linked_pad.teleporting)
		to_chat(user, span_warning("Linked pad is busy. Please wait."))
		return

	if(linked_pad.stat & NOPOWER)
		to_chat(user, span_warning("Linked pad is not responding to ping."))
		return
	add_fingerprint(user)
	doteleport(user)

/obj/machinery/quantumpad/proc/sparks()
	do_sparks(5, TRUE, get_turf(src))

/obj/machinery/quantumpad/attack_ghost(mob/dead/observer/ghost)
	if(linked_pad)
		ghost.forceMove(get_turf(linked_pad))

/obj/machinery/quantumpad/proc/doteleport(mob/user, obj/machinery/quantumpad/target_pad = linked_pad)
	if(!target_pad)
		return
	playsound(get_turf(src), 'sound/weapons/flash.ogg', 25, TRUE)
	teleporting = TRUE

	addtimer(CALLBACK(src, PROC_REF(teleport_contents), user, target_pad), teleport_speed)

/obj/machinery/quantumpad/proc/teleport_contents(mob/user, obj/machinery/quantumpad/target_pad)
	teleporting = FALSE

	if(stat & NOPOWER)
		to_chat(user, span_warning("[src] is unpowered!"))
		return

	if(!target_pad || QDELETED(target_pad) || target_pad.stat & NOPOWER)
		to_chat(user, span_warning("Linked pad is not responding to ping. Teleport aborted."))
		return

	last_teleport = world.time

	// use a lot of power
	use_power(10000 / power_efficiency)
	sparks()
	target_pad.sparks()

	flick("[initial(icon_state)]-beam", src)
	playsound(get_turf(src), 'sound/weapons/emitter2.ogg', 25, TRUE)
	flick("[initial(target_pad.icon_state)]-beam", target_pad)
	playsound(get_turf(target_pad), 'sound/weapons/emitter2.ogg', 25, TRUE)
	var/tele_success = TRUE
	for(var/atom/movable/target in get_turf(src))
		if(target.anchored)
			continue

		if(isliving(target))
			var/mob/living/mob = target
			if(mob.buckled && mob.buckled.anchored)
				continue

		tele_success = do_teleport(target, get_turf(target_pad))

	if(!tele_success)
		to_chat(user, span_warning("Teleport failed due to bluespace interference."))

/obj/item/circuit_component/quantumpad
	display_name = "Квантовая платформа"
	desc = "Квантовая платформа, связанная через блюспейс. \
			Используется для телепортации предметов на другие квантовые платформы."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	var/datum/port/input/target_pad
	var/datum/port/output/failed

	var/obj/machinery/quantumpad/attached_pad

/obj/item/circuit_component/quantumpad/populate_ports()
	target_pad = add_input_port("Платформа", PORT_TYPE_ATOM)
	failed = add_output_port("Ошибка", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/quantumpad/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/quantumpad))
		attached_pad = shell

/obj/item/circuit_component/quantumpad/unregister_usb_parent(atom/movable/shell)
	attached_pad = null
	return ..()

/obj/item/circuit_component/quantumpad/input_received(datum/port/input/port)
	if(!attached_pad)
		return

	var/obj/machinery/quantumpad/targeted_pad = target_pad.value

	if((!attached_pad.linked_pad || QDELETED(attached_pad.linked_pad)) && !(targeted_pad && istype(targeted_pad)))
		failed.set_output(COMPONENT_SIGNAL)
		return

	if(world.time < attached_pad.last_teleport + attached_pad.teleport_cooldown)
		failed.set_output(COMPONENT_SIGNAL)
		return

	if(targeted_pad && istype(targeted_pad))
		if(attached_pad.teleporting || targeted_pad.teleporting)
			failed.set_output(COMPONENT_SIGNAL)
			return

		if(targeted_pad.stat & NOPOWER)
			failed.set_output(COMPONENT_SIGNAL)
			return
		attached_pad.doteleport(target_pad = targeted_pad)
	else
		if(attached_pad.teleporting || attached_pad.linked_pad.teleporting)
			failed.set_output(COMPONENT_SIGNAL)
			return

		if(attached_pad.linked_pad.stat & NOPOWER)
			failed.set_output(COMPONENT_SIGNAL)
			return
		attached_pad.doteleport(target_pad = attached_pad.linked_pad)
