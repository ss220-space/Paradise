#define RECHARGER_POWER_USAGE_GUN 250
#define RECHARGER_POWER_USAGE_MISC 200

/obj/machinery/recharger
	name = "recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger0"
	base_icon_state = "recharger"
	desc = "A charging dock for energy based weaponry."
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 4
	active_power_usage = 200
	pass_flags = PASSTABLE
	/// Allowed item to recharge
	var/list/allowed_devices = list(/obj/item/gun/energy, /obj/item/melee/baton, /obj/item/rcs, /obj/item/bodyanalyzer, /obj/item/handheld_chem_dispenser)
	/// Rechargin multiplier
	var/recharge_coeff = 1
	/// The item that is being charged
	var/obj/item/charging = null
	// Whether the recharger is actually transferring power or not, used for icon
	var/using_power = FALSE


/obj/machinery/recharger/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/recharger(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	RefreshParts()


/obj/machinery/recharger/RefreshParts()
	for(var/obj/item/stock_parts/capacitor/capacitor in component_parts)
		recharge_coeff = capacitor.rating


/obj/machinery/recharger/attackby(obj/item/G, mob/user, params)
	var/allowed = is_type_in_list(G, allowed_devices)

	if(!allowed)
		return ..()

	. = TRUE
	if(!anchored)
		to_chat(user, span_notice("[src] isn't connected to anything!"))
		return .
	if(panel_open)
		to_chat(user, span_warning("Close the maintenance panel first!"))
		return .
	if(charging)
		to_chat(user, span_warning("There's \a [charging] inserted in [src] already!"))
		return .

	//Checks to make sure he's not in space doing it, and that the area got proper power.
	var/area/our_area = get_area(src)
	if(!istype(our_area) || !our_area.power_equip)
		to_chat(user, span_warning("[src] blinks red as you try to insert [G]."))
		return .

	if(istype(G, /obj/item/gun/energy))
		var/obj/item/gun/energy/e_gun = G
		if(!e_gun.can_charge)
			to_chat(user, span_notice("Your gun has no external power connector."))
			return .

	if(!user.drop_transfer_item_to_loc(G, src))
		to_chat(user, span_warning("[G] is stuck to your hand!"))
		return .

	add_fingerprint(user)
	charging = G
	use_power = ACTIVE_POWER_USE
	using_power = check_cell_needs_recharging(get_cell_from(G))
	update_icon()


/obj/machinery/recharger/crowbar_act(mob/user, obj/item/I)
	if(panel_open && !charging && default_deconstruction_crowbar(user, I))
		return TRUE


/obj/machinery/recharger/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!anchored)
		to_chat(user, span_warning("[src] needs to be secured down first!"))
		return
	if(charging)
		to_chat(user, span_warning("Remove the charging item first!"))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	panel_open = !panel_open
	if(panel_open)
		SCREWDRIVER_OPEN_PANEL_MESSAGE
	else
		SCREWDRIVER_CLOSE_PANEL_MESSAGE
	update_icon()


/obj/machinery/recharger/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(panel_open)
		to_chat(user, span_warning("Close the maintenance panel first!"))
		return
	if(charging)
		to_chat(user, span_warning("Remove the charging item first!"))
		return
	default_unfasten_wrench(user, I, 0)


/obj/machinery/recharger/attack_hand(mob/user)
	if(issilicon(user))
		return

	add_fingerprint(user)
	if(charging)
		charging.update_icon()
		charging.forceMove_turf()
		user.put_in_hands(charging, ignore_anim = FALSE)
		charging = null
		use_power = IDLE_POWER_USE
		update_icon()


/obj/machinery/recharger/attack_tk(mob/user)
	if(charging)
		charging.update_icon()
		charging.forceMove(loc)
		charging = null
		use_power = IDLE_POWER_USE
		update_icon()


/obj/machinery/recharger/process()
	if(stat & (NOPOWER|BROKEN) || !anchored || panel_open)
		return
	if(!charging)
		return
	var/old_power_state = using_power
	using_power = try_recharging_if_possible()
	if(using_power != old_power_state)
		update_icon()


/obj/machinery/recharger/emp_act(severity)
	if(stat & (NOPOWER|BROKEN) || !anchored)
		..(severity)
		return

	if(istype(charging, /obj/item/gun/energy))
		var/obj/item/gun/energy/E = charging
		if(E.cell)
			E.cell.emp_act(severity)

	else if(istype(charging, /obj/item/melee/baton))
		var/obj/item/melee/baton/B = charging
		if(B.cell)
			B.cell.charge = 0
	..(severity)

/obj/machinery/recharger/power_change(forced = FALSE)
	if(!..())
		return
	if(stat & NOPOWER)
		set_light_on(FALSE)
	else
		set_light(1, LIGHTING_MINIMUM_POWER)
	update_icon()


/obj/machinery/recharger/update_icon_state()
	if(panel_open)
		icon_state = "[base_icon_state]open"
		return
	if(stat & (NOPOWER|BROKEN) || !anchored)
		icon_state = "[base_icon_state]off"
		return
	if(charging)
		if(using_power)
			icon_state = "[base_icon_state]1"
		else
			icon_state = "[base_icon_state]2"
		return
	icon_state = initial(icon_state)


/obj/machinery/recharger/update_overlays()
	. = ..()
	underlays.Cut()

	if((stat & NOPOWER) || panel_open)
		return

	underlays += emissive_appearance(icon, "[icon_state]_lightmask")


/obj/machinery/recharger/proc/get_cell_from(obj/item/I)
	if(istype(I, /obj/item/gun/energy))
		var/obj/item/gun/energy/E = I
		return E.cell

	if(istype(I, /obj/item/melee/baton))
		var/obj/item/melee/baton/B = I
		return B.cell

	if(istype(I, /obj/item/rcs))
		var/obj/item/rcs/R = I
		return R.rcell

	if(istype(I, /obj/item/bodyanalyzer))
		var/obj/item/bodyanalyzer/B = I
		return B.cell

	return null

/obj/machinery/recharger/proc/check_cell_needs_recharging(obj/item/stock_parts/cell/C)
	if(!C || C.charge >= C.maxcharge)
		return FALSE
	return TRUE

/obj/machinery/recharger/proc/recharge_cell(obj/item/stock_parts/cell/C, power_usage)
	C.give(C.chargerate * recharge_coeff)
	use_power(power_usage)

/obj/machinery/recharger/proc/try_recharging_if_possible()
	var/obj/item/stock_parts/cell/C = get_cell_from(charging)
	if(!check_cell_needs_recharging(C))
		return FALSE

	if(istype(charging, /obj/item/gun/energy))
		recharge_cell(C, RECHARGER_POWER_USAGE_GUN)

		var/obj/item/gun/energy/E = charging
		E.on_recharge()
	else
		recharge_cell(C, RECHARGER_POWER_USAGE_MISC)

	return TRUE

/obj/machinery/recharger/examine(mob/user)
	. = ..()
	if(charging && (!in_range(user, src) && !issilicon(user) && !isobserver(user)))
		. += span_warning("You're too far away to examine [src]'s contents and display!")
		return

	if(charging)
		. += span_notice("\The [src] contains:")
		. += span_notice("- \A [charging].")
		if(!(stat & (NOPOWER|BROKEN)))
			var/obj/item/stock_parts/cell/C = charging.get_cell()
			. += span_notice("The status display reads:")
			if(using_power)
				. += span_notice("- Recharging <b>[(C.chargerate/C.maxcharge)*100]%</b> cell charge per cycle.")
			if(charging)
				. += span_notice("- \The [charging]'s cell is at <b>[C.percent()]%</b>.")

// Atlantis: No need for that copy-pasta code, just use var to store icon_states instead.
/obj/machinery/recharger/wallcharger
	name = "wall recharger"
	icon_state = "wrecharger0"
	base_icon_state = "wrecharger"

#undef RECHARGER_POWER_USAGE_GUN
#undef RECHARGER_POWER_USAGE_MISC
