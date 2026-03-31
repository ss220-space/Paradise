#define ELECTROLYZER_MODE_STANDBY "standby"
#define ELECTROLYZER_MODE_WORKING "working"
/obj/machinery/power/electrolyzer
	name = "gas electrolyzer"
	desc = "A nifty little machine that is able to produce hydrogen when supplied with water vapor and enough power, allowing for on-the-go hydrogen production! Nanotrasen is not responsible for any accidents that may occur from sudden hydrogen combustion or explosions. It seems it needs around 350 kW of power to funtion properly."
	anchored = FALSE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 80, ACID = 10)
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos.dmi'
	icon_state = "electrolyzer-off"
	density = TRUE
	resistance_flags = FIRE_PROOF
	max_integrity = 250
	///used to check if there is a cell in the machine
	var/obj/item/stock_parts/cell/cell
	/// whether or not we're actively using power/seeking water vapor in the air
	var/on = FALSE
	///check what mode the machine should be (WORKING, STANDBY)
	var/mode = ELECTROLYZER_MODE_STANDBY
	///Increase the amount of moles worked on, changed by upgrading the manipulator tier
	var/working_power = 1
	///Decrease the amount of power usage, changed by upgrading the capacitor tier
	var/efficiency = 0.5
	var/datum/gas_mixture/gas

/obj/machinery/power/electrolyzer/Initialize(mapload)
	. = ..()
	if(ispath(cell))
		cell = new cell(src)
	component_parts = list()
	component_parts += new /obj/item/circuitboard/electrolyzer(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	if(!powernet)
		connect_to_network()

	if(powernet)
		RegisterSignal(powernet)

	RefreshParts()
	update_appearance(UPDATE_ICON)
	register_context()

/obj/machinery/power/electrolyzer/RefreshParts()
	. = ..()
	var/power = 0
	var/cap = 0
	for(var/obj/item/stock_parts/manipulator/manipulator in component_parts)
		power += manipulator.rating / 10
	for(var/obj/item/stock_parts/capacitor/capacitor in component_parts)
		cap += capacitor.rating

	working_power = power //used in the amount of moles processed

	efficiency = (cap + 1) * 0.5 //used in the amount of charge in power cell uses

/obj/machinery/power/electrolyzer/Destroy()
	if(cell)
		QDEL_NULL(cell)
	return ..()

/obj/machinery/power/electrolyzer/on_deconstruction(disassembled)
	if(cell)
		cell = null
	return ..()

/obj/machinery/power/electrolyzer/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Turn [on ? "off" : "on"]"
	if(!held_item)
		return CONTEXTUAL_SCREENTIP_SET
	switch(held_item.tool_behaviour)
		if(TOOL_SCREWDRIVER)
			context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] panel"
		if(TOOL_WRENCH)
			context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "Unan" : "An"]chor"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/power/electrolyzer/get_cell()
	return cell

/obj/machinery/power/electrolyzer/examine(mob/user)
	. = ..()
	. += "\The [src] is [on ? "on" : "off"], and the panel is [panel_open ? "open" : "closed"]."

	if(cell)
		. += "The charge meter reads [cell ? round(cell.percent(), 1) : 0]%."
	else
		. += "There is no power cell installed."
	if(in_range(user, src) || isobserver(user))
		. += span_notice("<b>Alt-click</b> to toggle [on ? "off" : "on"].")
		. += span_notice("<b>Anchor</b> to drain power from APC instead of cell")
	. += span_notice("It will drain power from the [anchored ? "area's APC" : "internal power cell"].")


/obj/machinery/power/electrolyzer/attackby(obj/item/I, mob/user, list/modifiers, list/attack_modifiers)
	add_fingerprint(user)
	if(iscell(I))
		if(!panel_open)
			balloon_alert(user, "open panel!")
			return ATTACK_CHAIN_BLOCKED_ALL
		if(cell)
			balloon_alert(user, "cell inside!")
			return ATTACK_CHAIN_BLOCKED_ALL
		if(!user.transfer_item_to_loc(I, src))
			return ATTACK_CHAIN_PROCEED
		cell = I
		I.add_fingerprint(usr)
		balloon_alert(user, "inserted cell")
		SStgui.update_uis(src)

		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/machinery/power/electrolyzer/wrench_act(mob/living/user, obj/item/I)
	return default_unfasten_wrench(user, I)

/obj/machinery/power/electrolyzer/screwdriver_act(mob/user, obj/item/I)
	I.play_tool_sound(src, 50)
	toggle_panel_open()
	balloon_alert(user, "[panel_open ? "opened" : "closed"] panel")
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/machinery/power/electrolyzer/crowbar_act(mob/living/user, obj/item/I)
	return default_deconstruction_crowbar(user, I)

/obj/machinery/power/electrolyzer/click_alt(mob/user)
	if(panel_open)
		balloon_alert(user, "close panel!")
		return CLICK_ACTION_BLOCKING
	toggle_power(user)
	return CLICK_ACTION_SUCCESS

/obj/machinery/power/electrolyzer/proc/toggle_power(mob/user)
	if(!anchored && !cell)
		balloon_alert(user, "insert cell or anchor!")
		return
	on = !on
	mode = ELECTROLYZER_MODE_STANDBY
	update_appearance(UPDATE_ICON)
	balloon_alert(user, "turned [on ? "on" : "off"]")

/obj/machinery/power/electrolyzer/process()
	if(!on && !(stat & NOPOWER))
		return

	if((!cell || cell.charge <= 0) && !anchored)
		on = FALSE
		update_appearance(UPDATE_ICON)
		return

	var/turf/our_turf = loc
	if(!istype(our_turf))
		if(mode != ELECTROLYZER_MODE_STANDBY)
			mode = ELECTROLYZER_MODE_STANDBY
			update_appearance(UPDATE_ICON)
		return

	var/new_mode = on ? ELECTROLYZER_MODE_WORKING : ELECTROLYZER_MODE_STANDBY //change the mode to working if the machine is on

	if(mode != new_mode) //check if the mode is set correctly
		mode = new_mode
		update_appearance(UPDATE_ICON)

	if(mode == ELECTROLYZER_MODE_STANDBY)
		return

	var/power_to_use = (50 * (3 * working_power) * working_power) / (efficiency + working_power)
	if(anchored)
		use_power(power_to_use)
	else
		cell.use(power_to_use)

	var/datum/milla_safe/electrolyzer_process/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/electrolyzer_process

/datum/milla_safe/electrolyzer_process/on_run(obj/machinery/power/electrolyzer/electrolyzer)
	var/turf/location = get_turf(electrolyzer)
	var/datum/gas_mixture/env = get_turf_air(location)
	electrolyzer.call_reactions(env)

/obj/machinery/power/electrolyzer/update_icon_state()
	icon_state = "electrolyzer-[on ? "[mode]" : "off"]"
	return ..()

/obj/machinery/power/electrolyzer/update_overlays()
	. = ..()
	if(panel_open)
		. += "electrolyzer-open"

/obj/machinery/power/electrolyzer/proc/call_reactions(datum/gas_mixture/env)
	env.electrolyze(working_power = working_power)

/obj/machinery/power/electrolyzer/attack_hand(mob/user)
	. = ..()
	ui_interact(user)

/obj/machinery/power/electrolyzer/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/power/electrolyzer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Electrolyzer", name)
		ui.open()

/obj/machinery/power/electrolyzer/ui_data()
	var/list/data = list()
	data["open"] = panel_open
	data["on"] = on
	data["hasPowercell"] = !isnull(cell)
	data["anchored"] = anchored
	if(cell)
		data["powerLevel"] = round(cell.percent(), 1)
	return data

/obj/machinery/power/electrolyzer/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			toggle_power(ui.user)
			. = TRUE
		if("eject")
			if(panel_open && cell)
				cell.forceMove(drop_location())
				cell = null
				. = TRUE

#undef ELECTROLYZER_MODE_STANDBY
#undef ELECTROLYZER_MODE_WORKING
