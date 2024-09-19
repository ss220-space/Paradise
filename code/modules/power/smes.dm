// the SMES
// stores power

#define SMESMAXCHARGELEVEL 200000
#define SMESMAXOUTPUT 200000
#define SMESRATE 0.05			// rate of internal charge to external power



/obj/machinery/power/smes
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit."
	icon_state = "smes"
	density = TRUE
	use_power = NO_POWER_USE

	var/capacity = 5e6 // maximum charge
	var/charge = 0 // actual charge

	var/input_attempt = TRUE 		// 1 = attempting to charge, 0 = not attempting to charge
	var/inputting = TRUE 			// 1 = actually inputting, 0 = not inputting
	var/input_level = 50000 		// amount of power the SMES attempts to charge by
	var/input_level_max = 200000 	// cap on input_level
	var/input_available = 0 		// amount of charge available from input last tick

	var/output_attempt = TRUE 		// 1 = attempting to output, 0 = not attempting to output
	var/outputting = TRUE			// 1 = actually outputting, 0 = not outputting
	var/output_level = 50000		// amount of power the SMES attempts to output
	var/output_level_max = 200000	// cap on output_level
	var/output_used = 0				// amount of power actually outputted. may be less than output_level if the powernet returns excess power

	var/name_tag = null
	var/obj/machinery/power/terminal/terminal = null

/obj/machinery/power/smes/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/smes(null)
	component_parts += new /obj/item/stock_parts/cell/high(null)
	component_parts += new /obj/item/stock_parts/cell/high(null)
	component_parts += new /obj/item/stock_parts/cell/high(null)
	component_parts += new /obj/item/stock_parts/cell/high(null)
	component_parts += new /obj/item/stock_parts/cell/high(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

	dir_loop:
		for(var/d in GLOB.cardinal)
			var/turf/T = get_step(src, d)
			for(var/obj/machinery/power/terminal/term in T)
				if(term && term.dir == turn(d, 180))
					terminal = term
					break dir_loop

	if(!terminal)
		stat |= BROKEN
		return
	terminal.master = src
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/power/smes/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/smes(null)
	component_parts += new /obj/item/stock_parts/cell/hyper(null)
	component_parts += new /obj/item/stock_parts/cell/hyper(null)
	component_parts += new /obj/item/stock_parts/cell/hyper(null)
	component_parts += new /obj/item/stock_parts/cell/hyper(null)
	component_parts += new /obj/item/stock_parts/cell/hyper(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/power/smes/on_construction()
	connect_to_network()
	return ..()

/obj/machinery/power/smes/RefreshParts()
	var/IO = 0
	var/C = 0
	for(var/obj/item/stock_parts/capacitor/CP in component_parts)
		IO += CP.rating
	input_level_max = 200000 * IO
	output_level_max = 200000 * IO
	for(var/obj/item/stock_parts/cell/PC in component_parts)
		C += PC.maxcharge
	capacity = C / (15000) * 1e6


/obj/machinery/power/smes/update_overlays()
	. = ..()
	if((stat & BROKEN) || panel_open)
		return

	. += "smes-op[outputting]"

	if(inputting)
		. += "smes-oc[inputting]"
	else if(input_attempt)
		. += "smes-oc0"

	var/clevel = chargedisplay()
	if(clevel > 0)
		. += "smes-og[clevel]"


/obj/machinery/power/smes/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	//exchanging parts using the RPE
	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	//building and linking a terminal
	if(iscoil(I))
		add_fingerprint(user)
		var/obj/item/stack/cable_coil/coil = I
		if(terminal)	//is there already a terminal ?
			to_chat(user, span_warning("This SMES already has a power terminal."))
			return ATTACK_CHAIN_PROCEED
		var/terminal_dir = get_dir(user, src)
		if(ISDIAGONALDIR(terminal_dir))	//we don't want diagonal click
			to_chat(user, span_warning("You should face the SMES from any cardinal direction."))
			return ATTACK_CHAIN_PROCEED
		if(!panel_open)	//is the panel open ?
			to_chat(user, span_warning("You should open the maintenance panel first."))
			return ATTACK_CHAIN_PROCEED
		var/turf/terminal_turf = get_step(src, REVERSE_DIR(terminal_dir))
		if(!terminal_turf.can_have_cabling() || terminal_turf.intact)	//is the floor plating removed or is it a spaceturf ?
			to_chat(user, span_warning("You should remove or change the floor plating beneath you."))
			return ATTACK_CHAIN_PROCEED
		if(user.loc == loc)	// somehow???
			to_chat(user, span_warning("You must not be on the same tile as the SMES."))
			return ATTACK_CHAIN_PROCEED
		if(coil.get_amount() < 10)
			to_chat(user, span_warning("You need at least ten length of cable to construct a power terminal."))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] starts to construct the cable terminal for the SMES."),
			span_notice("You start to construct the cable terminal for the SMES..."),
		)
		coil.play_tool_sound(src)
		if(!do_after(user, 5 SECONDS * coil.toolspeed, src, category = DA_CAT_TOOL) || !panel_open || !terminal_turf.can_have_cabling() || terminal_turf.intact || QDELETED(coil))
			return ATTACK_CHAIN_PROCEED
		var/obj/structure/cable/node = terminal_turf.get_cable_node()
		if(prob(50) && electrocute_mob(user, node, node, 1, TRUE))
			do_sparks(5, TRUE, src)
			return ATTACK_CHAIN_BLOCKED_ALL
		if(!coil.use(10))
			to_chat(user, span_warning("At some point during construction you lost some cable. Make sure you have ten lengths before trying again."))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] has finished the construction of the cable terminal for the SMES."),
			span_notice("You have finished the construction of the cable terminal for the SMES."),
		)
		make_terminal(terminal_dir, terminal_turf)
		terminal.add_fingerprint(user)
		terminal.connect_to_network()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/power/smes/screwdriver_act(mob/living/user, obj/item/I)
	. = default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I)
	if(.)
		update_icon(UPDATE_OVERLAYS)


/obj/machinery/power/smes/wrench_act(mob/living/user, obj/item/I)
	. = default_change_direction_wrench(user, I)
	if(!.)
		return .
	terminal = null
	var/turf/terminal_turf = get_step(src, dir)
	for(var/obj/machinery/power/terminal/check_terminal in terminal_turf)
		if(check_terminal.dir == turn(dir, 180))
			terminal = check_terminal
			terminal.master = src
			to_chat(user, span_notice("Terminal found."))
			break
	if(!terminal)
		to_chat(user, span_warning("No power source found."))
		return .
	stat &= ~BROKEN
	update_icon(UPDATE_OVERLAYS)


/obj/machinery/power/smes/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	add_fingerprint(user)
	if(QDELETED(terminal))
		to_chat(user, span_warning("The [name] has no power terminal."))
		return .
	var/turf/terminal_turf = get_turf(terminal)
	if(terminal_turf.intact)
		to_chat(user, span_warning("You should expose the power terminal first."))
		return .
	if(!panel_open)
		to_chat(user, span_warning("You cannot dismantle the power terminal while the maintenance panel is closed."))
		return .
	to_chat(user, span_notice("You start to dismantle the power terminal..."))
	user.visible_message(
		span_notice("[user] starts to dismantle the power terminal."),
		span_notice("You start to dismantle the power terminal..."),
	)
	if(!I.use_tool(src, user, 5 SECONDS, volume = I.tool_volume) || QDELETED(terminal) || terminal_turf.intact || !panel_open)
		return .
	if(prob(50) && electrocute_mob(user, terminal.powernet, terminal, 1, TRUE)) //animate the electrocution if uncautious and unlucky
		do_sparks(5, TRUE, src)
		return .
	user.visible_message(
		span_notice("[user] has dismantled the power terminal."),
		span_notice("You have dismantled the power terminal."),
	)
	var/obj/item/stack/cable_coil/coil = new(terminal_turf, 10)	//give the wires back and delete the terminal
	terminal.transfer_fingerprints_to(coil)
	coil.add_fingerprint(user)
	inputting = 0 //stop inputting, since we have don't have a terminal anymore
	qdel(terminal)


/obj/machinery/power/smes/crowbar_act(mob/living/user, obj/item/I)
	return default_deconstruction_crowbar(user, I)


/obj/machinery/power/smes/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null
		return TRUE
	return FALSE


/obj/machinery/power/smes/proc/make_terminal(tempDir, tempLoc)
	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	terminal = new /obj/machinery/power/terminal(tempLoc)
	terminal.dir = tempDir
	terminal.master = src


/obj/machinery/power/smes/Destroy()
	if(SSticker && SSticker.current_state == GAME_STATE_PLAYING)
		var/area/area = get_area(src)
		if(area)
			message_admins("SMES deleted at [ADMIN_VERBOSEJMP(src)]")
			add_game_logs("SMES deleted at [AREACOORD(src)]")
			investigate_log("<font color='red'>deleted</font> at [AREACOORD(src)]", INVESTIGATE_ENGINE)
	if(terminal)
		disconnect_terminal()
	return ..()

/obj/machinery/power/smes/proc/chargedisplay()
	return round(5.5*charge/(capacity ? capacity : 5e6))

/obj/machinery/power/smes/process()
	if(stat & BROKEN)
		return

	//store machine state to see if we need to update the icon overlays
	var/last_disp = chargedisplay()
	var/last_chrg = inputting
	var/last_onln = outputting

	//inputting
	if(terminal && input_attempt)
		input_available = terminal.surplus()

		if(inputting)
			if(input_available > 0)		// if there's power available, try to charge

				var/load = min(min((capacity-charge)/SMESRATE, input_level), input_available)		// charge at set rate, limited to spare capacity

				charge += load * SMESRATE	// increase the charge

				terminal.add_load(load) // add the load to the terminal side network

			else					// if not enough capcity
				inputting = FALSE		// stop inputting

		else
			if(input_attempt && input_available > 0)
				inputting = TRUE
	else
		inputting = FALSE

	//outputting
	if(output_attempt)
		if(outputting)
			output_used = min( charge/SMESRATE, output_level)		//limit output to that stored

			if (add_avail(output_used))				// add output to powernet if it exists (smes side)
				charge -= output_used*SMESRATE		// reduce the storage (may be recovered in /restore() if excessive)
			else
				outputting = FALSE

			if(output_used < 0.0001)		// either from no charge or set to 0
				outputting = FALSE
				investigate_log("lost power and turned <font color='red'>off</font>", INVESTIGATE_ENGINE)
		else if(output_attempt && charge > output_level && output_level > 0)
			outputting = TRUE
		else
			output_used = 0
	else
		outputting = FALSE

	// only update icon if state changed
	if(last_disp != chargedisplay() || last_chrg != inputting || last_onln != outputting)
		update_icon(UPDATE_OVERLAYS)



// called after all power processes are finished
// restores charge level to smes if there was excess this ptick
/obj/machinery/power/smes/proc/restore()
	if(stat & BROKEN)
		return

	if(!outputting)
		output_used = 0
		return

	var/excess = powernet.netexcess		// this was how much wasn't used on the network last ptick, minus any removed by other SMESes

	excess = min(output_used, excess)				// clamp it to how much was actually output by this SMES last ptick

	excess = min((capacity-charge)/SMESRATE, excess)	// for safety, also limit recharge by space capacity of SMES (shouldn't happen)

	// now recharge this amount

	var/clev = chargedisplay()

	charge += excess * SMESRATE			// restore unused power
	powernet.netexcess -= excess		// remove the excess from the powernet, so later SMESes don't try to use it

	output_used -= excess

	if(clev != chargedisplay() ) //if needed updates the icons overlay
		update_icon(UPDATE_OVERLAYS)
	return

/obj/machinery/power/smes/attack_ai(mob/user)
	add_hiddenprint(user)
	ui_interact(user)

/obj/machinery/power/smes/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/power/smes/attack_hand(mob/user)
	if(..())
		return TRUE

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/power/smes/ui_interact(mob/user, datum/tgui/ui = null)
	if(stat & BROKEN)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Smes", name)
		ui.open()

/obj/machinery/power/smes/ui_data(mob/user)
	var/list/data = list(
		"capacity" = capacity,
		"capacityPercent" = round(100*charge/capacity, 0.1),
		"charge" = charge,
		"inputAttempt" = input_attempt,
		"inputting" = inputting,
		"inputLevel" = input_level,
		"inputLevel_text" = DisplayPower(input_level),
		"inputLevelMax" = input_level_max,
		"inputAvailable" = input_available,
		"outputAttempt" = output_attempt,
		"outputting" = outputting,
		"outputLevel" = output_level,
		"outputLevel_text" = DisplayPower(output_level),
		"outputLevelMax" = output_level_max,
		"outputUsed" = round(output_used),
	)
	return data

/obj/machinery/power/smes/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("tryinput")
			inputting(!input_attempt)
			update_icon(UPDATE_OVERLAYS)
		if("tryoutput")
			outputting(!output_attempt)
			update_icon(UPDATE_OVERLAYS)
		if("input")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "min")
				target = 0
			else if(target == "max")
				target = input_level_max
			else if(adjust)
				target = input_level + adjust
			else if(text2num(target) != null)
				target = text2num(target)
			else
				. = FALSE
			if(.)
				input_level = clamp(target, 0, input_level_max)
		if("output")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "min")
				target = 0
			else if(target == "max")
				target = output_level_max
			else if(adjust)
				target = output_level + adjust
			else if(text2num(target) != null)
				target = text2num(target)
			else
				. = FALSE
			if(.)
				output_level = clamp(target, 0, output_level_max)
		else
			. = FALSE
	if(.)
		log_smes(usr)

/obj/machinery/power/smes/proc/log_smes(mob/user)
		investigate_log("input/output; [input_level>output_level?"<font color='green'>":"<font color='red'>"][input_level]/[output_level]</font> | Charge: [charge] | Output-mode: [output_attempt?"<font color='green'>on</font>":"<font color='red'>off</font>"] | Input-mode: [input_attempt?"<font color='green'>auto</font>":"<font color='red'>off</font>"] by [user ? key_name_log(user) : "outside forces"]", INVESTIGATE_ENGINE)

/obj/machinery/power/smes/proc/ion_act()
	if(is_station_level(src.z))
		if(prob(1)) //explosion
			for(var/mob/M in viewers(src))
				M.show_message("<span class='warning'>The [src.name] is making strange noises!</span>", 3, "<span class='warning'>You hear sizzling electronics.</span>", 2)
			sleep(10*pick(4,5,6,7,10,14))
			var/datum/effect_system/smoke_spread/smoke = new
			smoke.set_up(3, 0, src.loc)
			smoke.attach(src)
			smoke.start()
			explosion(src.loc, -1, 0, 1, 3, 1, 0, cause = src)
			qdel(src)
			return
		if(prob(15)) //Power drain
			do_sparks(3, 1, src)
			if(prob(50))
				emp_act(1)
			else
				emp_act(2)
		if(prob(5)) //smoke only
			var/datum/effect_system/smoke_spread/smoke = new
			smoke.set_up(3, 0, src.loc)
			smoke.attach(src)
			smoke.start()


/obj/machinery/power/smes/proc/inputting(var/do_input)
	input_attempt = do_input
	if(!input_attempt)
		inputting = 0

/obj/machinery/power/smes/proc/outputting(var/do_output)
	output_attempt = do_output
	if(!output_attempt)
		outputting = 0

/obj/machinery/power/smes/emp_act(severity)
	inputting(rand(0, 1))
	outputting(rand(0, 1))
	output_level = rand(0, output_level_max)
	input_level = rand(0, input_level_max)
	charge -= 1e6/severity
	if(charge < 0)
		charge = 0
	update_icon(UPDATE_OVERLAYS)
	log_smes()
	..()

/obj/machinery/power/smes/engineering
	charge = 2e6 // Engineering starts with some charge for singulo

/obj/machinery/power/smes/magical
	name = "magical power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. Magically produces power."
	capacity = 9000000
	output_level = 250000

/obj/machinery/power/smes/magical/process()
	capacity = INFINITY
	charge = INFINITY
	..()

/obj/machinery/power/smes/vintage
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. Old but not useless."
	icon_state = "oldsmes"
	capacity = 2500000

#undef SMESRATE
