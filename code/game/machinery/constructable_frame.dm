// Construction | Deconstruction
#define STATE_EMPTY			1 // Add wires | Wrench to destroy
#define STATE_WIRED			2 // Add cicuit / Wrench to unchor/unanchor | Remove wires with wirecutters
#define STATE_COMPONENTS	3 // Add components / Wrench to unchor/unanchor | Remove circuit/components with crowbar

/obj/machinery/constructable_frame //Made into a seperate type to make future revisions easier.
	name = "machine frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	max_integrity = 250
	var/obj/item/circuitboard/circuit
	var/list/components
	var/list/req_components
	/// User-friendly names of components
	var/list/req_component_names
	var/state = STATE_EMPTY


/obj/machinery/constructable_frame/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 5)
		if(state >= 2)
			new /obj/item/stack/cable_coil(loc, 5)
		if(circuit)
			circuit.forceMove(loc)
			circuit = null
	return ..()


/obj/machinery/constructable_frame/obj_break(damage_flag)
	deconstruct()


/obj/machinery/constructable_frame/proc/update_lists(list/circuit_components)
	req_components = circuit_components.Copy()
	components = list()
	req_component_names = list()
	for(var/atom/path as anything in req_components)
		req_component_names[path] = initial(path.name)


/obj/machinery/constructable_frame/proc/get_req_components_amt()
	var/amt = 0
	for(var/path in req_components)
		amt += req_components[path]
	return amt


/obj/machinery/constructable_frame/proc/get_req_desc()
	. = ""

	if(!req_components || !req_component_names)
		return

	var/hasContent = FALSE
	var/components_len = length(req_components)
	. = "<span class='notice'>Required components:"
	for(var/i = 1 to components_len)
		var/tname = req_components[i]
		var/amt = req_components[tname]
		if(!amt)
			continue
		var/use_and = (i == components_len)
		. += "[(hasContent ? (use_and ? ", and" : ",") : "")] <b>[amt]</b> [amt == 1 ? req_component_names[tname] : "[req_component_names[tname]]\s"]"
		hasContent = TRUE

	if(hasContent)
		. += ".</span>"
	else
		. = span_notice("Does not require any more components.")


/obj/machinery/constructable_frame/machine_frame/examine(mob/user)
	. = ..()
	. += span_notice("It is [anchored ? "<b>bolted</b> to the floor" : "<b>unbolted</b>"].")
	switch(state)
		if(STATE_EMPTY)
			. += span_notice("The frame is constructed, but it is missing a <i>wiring</i>.")
		if(STATE_WIRED)
			. += span_notice("The frame is <b>wired</b>, but it is missing a <i>circuit board</i>")
		if(STATE_COMPONENTS)
			var/required = get_req_desc()
			if(required)
				. += required


/obj/machinery/constructable_frame/machine_frame/update_icon_state()
	switch(state)
		if(STATE_EMPTY)
			icon_state = "box_0"
		if(STATE_WIRED)
			icon_state = "box_1"
		if(STATE_COMPONENTS)
			icon_state = "box_2"


/obj/machinery/constructable_frame/machine_frame/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	add_fingerprint(user)
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume))
		return .

	if(state == STATE_EMPTY)
		deconstruct(TRUE)
		to_chat(user, span_notice("You dismantle the frame."))
		return .

	if(anchored)
		set_anchored(FALSE)
		WRENCH_UNANCHOR_MESSAGE
		return .

	if(isinspace())
		to_chat(user, span_warning("You cannot tightens the bolts in space!"))
		return .

	set_anchored(TRUE)
	WRENCH_ANCHOR_MESSAGE


/obj/machinery/constructable_frame/machine_frame/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	add_fingerprint(user)
	if(state != STATE_WIRED)
		return .

	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume) || state != STATE_WIRED)
		return .

	state = STATE_EMPTY
	WIRECUTTER_SNIP_MESSAGE
	update_icon(UPDATE_ICON_STATE)
	new /obj/item/stack/cable_coil(loc, 5)


/obj/machinery/constructable_frame/machine_frame/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	add_fingerprint(user)
	if(state != STATE_COMPONENTS)
		return .

	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume) || state != STATE_COMPONENTS)
		return .

	state = STATE_WIRED
	circuit.forceMove(loc)
	circuit = null

	if(length(components))
		to_chat(user, span_notice("You remove the circuit board and other components."))
		for(var/obj/item/component in components)
			component.forceMove(loc)
	else
		to_chat(user, span_notice("You remove the circuit board."))

	name = initial(name)
	desc = initial(desc)
	req_components = null
	components = null
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/constructable_frame/machine_frame/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	add_fingerprint(user)
	if(state != STATE_COMPONENTS)
		return .

	var/component_check = TRUE
	for(var/component in req_components)
		if(req_components[component] > 0)
			component_check = FALSE
			break

	if(!component_check)
		to_chat(user, span_warning("Machine frame requires more components!"))
		return .

	if(!I.use_tool(src, user, 5 SECONDS, volume = I.tool_volume))
		return .

	to_chat(user, span_notice("You finish the construction."))
	var/obj/machinery/new_machine = new circuit.build_path(loc)
	new_machine.on_construction()
	for(var/obj/component in new_machine.component_parts)
		qdel(component)
	new_machine.component_parts = list()
	for(var/obj/component in src)
		component.loc = null
		new_machine.component_parts += component
	circuit.loc = null
	new_machine.RefreshParts()
	transfer_fingerprints_to(new_machine)
	qdel(src)


/obj/machinery/constructable_frame/machine_frame/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	add_fingerprint(user)
	. = ATTACK_CHAIN_PROCEED

	switch(state)
		if(STATE_EMPTY)
			if(!iscoil(I))
				return ..()

			var/obj/item/stack/cable_coil/coil = I
			if(coil.get_amount() < 5)
				to_chat(user, span_warning("You need five lengths of cable to wire the frame."))
				return .

			playsound(loc, coil.usesound, 50, TRUE)
			to_chat(user, span_notice("You start to add cables to the frame..."))
			if(!do_after(user, 2 SECONDS * coil.toolspeed, src, category = DA_CAT_TOOL) || state != STATE_EMPTY || QDELETED(coil))
				return .

			if(!coil.use(5))
				to_chat(user, span_warning("At some point during construction you lost some cable. Make sure you have five lengths before trying again."))
				return .

			state = STATE_WIRED
			update_icon(UPDATE_ICON_STATE)
			to_chat(user, span_notice("You add cables to the frame."))
			return ATTACK_CHAIN_PROCEED_SUCCESS

		if(STATE_WIRED)
			if(!istype(I, /obj/item/circuitboard))
				return ..()

			var/obj/item/circuitboard/new_circuit = I
			if(new_circuit.board_type != "machine")
				to_chat(user, span_warning("This frame does not accept circuit boards of this type!"))
				return .

			if(!user.drop_transfer_item_to_loc(new_circuit, src))
				return ..()

			state = STATE_COMPONENTS
			circuit = new_circuit
			name += " ([new_circuit.board_name])"
			if(length(circuit.req_components))
				update_lists(circuit.req_components)
			else
				stack_trace("Circuit without req_components list, placed in [src].")
			playsound(loc, new_circuit.usesound, 50, TRUE)
			to_chat(user, span_notice("You add the circuit board to the frame."))
			update_icon(UPDATE_ICON_STATE)
			return ATTACK_CHAIN_BLOCKED_ALL

		if(STATE_COMPONENTS)
			if(istype(I, /obj/item/storage/part_replacer) && length(I.contents) && get_req_components_amt())
				var/obj/item/storage/part_replacer/replacer = I
				var/list/added_components = list()
				var/list/part_list = list()

				//Assemble a list of current parts, then sort them by their rating!
				for(var/obj/item/stock_parts/co in replacer)
					part_list += co

				for(var/path in req_components)
					while(req_components[path] > 0 && (locate(path) in part_list))
						var/obj/item/part = (locate(path) in part_list)
						added_components[part] = path
						replacer.remove_from_storage(part, src)
						req_components[path]--
						part_list -= part

				for(var/obj/item/stock_parts/part in added_components)
					components += part
					to_chat(user, span_notice("[part.name] applied."))
				replacer.play_rped_sound()
				return ATTACK_CHAIN_PROCEED_SUCCESS

			if(isitem(I))
				var/success = FALSE
				for(var/path in req_components)
					var/is_stack = isstack(I)
					if(istype(I, path) && (req_components[path] > 0) && (!HAS_TRAIT(I, TRAIT_NODROP) || is_stack))
						success = TRUE
						playsound(loc, I.usesound, 50, TRUE)
						if(is_stack)
							var/obj/item/stack/stack = I
							var/camt = min(stack.get_amount(), req_components[path])
							var/obj/item/stack/new_stack
							if(stack.is_cyborg && stack.cyborg_construction_stack)
								new_stack = new stack.cyborg_construction_stack(src, camt)
							else
								new_stack = new stack.type(src, camt)
							new_stack.update_icon()
							stack.use(camt)
							components += new_stack
							req_components[path] -= camt
							break
						user.drop_transfer_item_to_loc(I, src)
						components += I
						req_components[path]--
						break

				if(!success)
					to_chat(user, span_warning("You cannot add that to the machine!"))

				return ATTACK_CHAIN_BLOCKED_ALL


#undef STATE_EMPTY
#undef STATE_WIRED
#undef STATE_COMPONENTS


//Machine Frame Circuit Boards
/*Common Parts: Parts List: Ignitor, Timer, Infra-red laser, Infra-red sensor, t_scanner, Capacitor, Valve, sensor unit,
micro-manipulator, glass sheets, beaker, Microlaser, matter bin, power cells.
Note: Once everything is added to the public areas, will add MAT_METAL and MAT_GLASS to circuit boards since autolathe won't be able
to destroy them and players will be able to make replacements.
*/
/obj/item/circuitboard/vendor
	board_name = "Booze-O-Mat Vendor"
	board_type = "machine"
	origin_tech = "programming=1"
	build_path = /obj/machinery/vending/boozeomat
	req_components = list(/obj/item/vending_refill/boozeomat = 1)

	var/static/list/station_vendors = list(
		"Booze-O-Mat" =							/obj/machinery/vending/boozeomat,
		"Solar's Best Hot Drinks" =				/obj/machinery/vending/coffee,
		"Getmore Chocolate Corp" =				/obj/machinery/vending/snack,
		"Mr. Chang" =							/obj/machinery/vending/chinese,
		"Robust Softdrinks" =					/obj/machinery/vending/cola,
		"ShadyCigs Deluxe" =					/obj/machinery/vending/cigarette,
		"Hatlord 9000" =						/obj/machinery/vending/hatdispenser,
		"Suitlord 9000" =						/obj/machinery/vending/suitdispenser,
		"Shoelord 9000" =						/obj/machinery/vending/shoedispenser,
		"AutoDrobe" =							/obj/machinery/vending/autodrobe,
		"ClothesMate" =							/obj/machinery/vending/clothing,
		"NanoMed Plus" =						/obj/machinery/vending/medical,
		"NanoMed" =								/obj/machinery/vending/wallmed,
		"Vendomat" =							/obj/machinery/vending/assist,
		"YouTool" =								/obj/machinery/vending/tool,
		"Engi-Vend" =							/obj/machinery/vending/engivend,
		"NutriMax" =							/obj/machinery/vending/hydronutrients,
		"MegaSeed Servitor" =					/obj/machinery/vending/hydroseeds,
		"Sustenance Vendor" =					/obj/machinery/vending/sustenance,
		"Plasteel Chef's Dinnerware Vendor" =	/obj/machinery/vending/dinnerware,
		"PTech" =								/obj/machinery/vending/cart,
		"Robotech Deluxe" =						/obj/machinery/vending/robotics,
		"Robco Tool Maker" =					/obj/machinery/vending/engineering,
		"BODA" =								/obj/machinery/vending/sovietsoda,
		"SecTech" =								/obj/machinery/vending/security,
		"CritterCare" =							/obj/machinery/vending/crittercare,
		"Departament Security ClothesMate" =	/obj/machinery/vending/clothing/departament/security,
		"Departament Medical ClothesMate" = 	/obj/machinery/vending/clothing/departament/medical,
		"Departament Engineering ClothesMate" = /obj/machinery/vending/clothing/departament/engineering,
		"Departament Science ClothesMate" =		/obj/machinery/vending/clothing/departament/science,
		"Departament Cargo ClothesMate" =		/obj/machinery/vending/clothing/departament/cargo,
		"Departament Law ClothesMate" =			/obj/machinery/vending/clothing/departament/law,
		"Service Departament ClothesMate Botanical" = /obj/machinery/vending/clothing/departament/service/botanical,
		"Service Departament ClothesMate Chaplain" 	= /obj/machinery/vending/clothing/departament/service/chaplain,
		"RoboFriends" =                         /obj/machinery/vending/pai,
		"Customat" =						 	/obj/machinery/customat,)

	var/static/list/unique_vendors = list(
		"ShadyCigs Ultra" =						/obj/machinery/vending/cigarette/beach,
		"SyndiWallMed" =						/obj/machinery/vending/wallmed/syndicate,
		"SyndiMed Plus" =						/obj/machinery/vending/medical/syndicate_access,
	)

/obj/item/circuitboard/vendor/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/choice = tgui_input_list(user, "Choose a new brand", "Select an Item", station_vendors)
	if(!choice)
		return
	set_type(choice)

/obj/item/circuitboard/vendor/proc/set_type(type)
	var/static/list/buildable_vendors = station_vendors + unique_vendors
	var/obj/machinery/vending/typepath = buildable_vendors[type]
	build_path = typepath
	board_name = "[type] Vendor"
	format_board_name()
	req_components = list(initial(typepath.refill_canister) = 1)

/obj/item/circuitboard/smes
	board_name = "SMES"
	build_path = /obj/machinery/power/smes
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=3;engineering=3"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/stock_parts/cell = 5,
							/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/smes/vintage
	board_name = "SMES"
	build_path = /obj/machinery/power/smes/vintage
	origin_tech = "programming=2;powerstorage=2;engineering=2"
	req_components = list(
							/obj/item/stack/cable_coil = 7,
							/obj/item/stock_parts/cell = 7,
							/obj/item/stock_parts/capacitor = 3)

/obj/item/circuitboard/emitter
	board_name = "Emitter"
	build_path = /obj/machinery/power/emitter
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=4;engineering=4"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/power_compressor
	board_name = "Power Compressor"
	build_path = /obj/machinery/power/compressor
	board_type = "machine"
	origin_tech = "programming=4;powerstorage=4;engineering=4"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/stock_parts/manipulator = 6)

/obj/item/circuitboard/power_turbine
	board_name = "Power Turbine"
	build_path = /obj/machinery/power/turbine
	board_type = "machine"
	origin_tech = "programming=4;powerstorage=4;engineering=4"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/stock_parts/capacitor = 6)

/obj/item/circuitboard/thermomachine
	board_name = "Freezer"
	desc = "Use screwdriver to switch between heating and cooling modes."
	build_path = /obj/machinery/atmospherics/unary/cold_sink/freezer
	board_type = "machine"
	origin_tech = "programming=3;plasmatech=3"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stack/sheet/glass = 1)


/obj/item/circuitboard/thermomachine/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	if(build_path == /obj/machinery/atmospherics/unary/cold_sink/freezer)
		build_path = /obj/machinery/atmospherics/unary/heat_reservoir/heater
		board_name = "Heater"
		to_chat(user, span_notice("You set the board to heating."))
	else
		build_path = /obj/machinery/atmospherics/unary/cold_sink/freezer
		board_name = "Freezer"
		to_chat(user, span_notice("You set the board to cooling."))


/obj/item/circuitboard/recharger
	board_name = "Recharger"
	build_path = /obj/machinery/recharger
	board_type = "machine"
	origin_tech = "powerstorage=3;materials=2"
	req_components = list(/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/snow_machine
	board_name = "Snow Machine"
	build_path = /obj/machinery/snow_machine
	board_type = "machine"
	origin_tech = "programming=2;materials=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/biogenerator
	board_name = "Biogenerator"
	build_path = /obj/machinery/biogenerator
	board_type = "machine"
	origin_tech = "programming=2;biotech=3;materials=3"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/plantgenes
	board_name = "Plant DNA Manipulator"
	build_path = /obj/machinery/plantgenes
	board_type = "machine"
	origin_tech = "programming=3;biotech=3"
	req_components = list(
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stock_parts/scanning_module = 1)

/obj/item/circuitboard/plantgenes/vault

/obj/item/circuitboard/seed_extractor
	board_name = "Seed Extractor"
	build_path = /obj/machinery/seed_extractor
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/hydroponics
	board_name = "Hydroponics Tray"
	build_path = /obj/machinery/hydroponics/constructable
	board_type = "machine"
	origin_tech = "programming=1;biotech=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/microwave
	board_name = "Microwave"
	build_path = /obj/machinery/kitchen_machine/microwave
	board_type = "machine"
	origin_tech = "programming=2;magnets=2"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/oven
	board_name = "Oven"
	build_path = /obj/machinery/kitchen_machine/oven
	board_type = "machine"
	origin_tech = "programming=2;magnets=2"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 5,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/grill
	board_name = "Grill"
	build_path = /obj/machinery/kitchen_machine/grill
	board_type = "machine"
	origin_tech = "programming=2;magnets=2"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 5,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/candy_maker
	board_name = "Candy Maker"
	build_path = /obj/machinery/kitchen_machine/candy_maker
	board_type = "machine"
	origin_tech = "programming=2;magnets=2"
	req_components = list(
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 5,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/deepfryer
	board_name = "Deep Fryer"
	build_path = /obj/machinery/cooker/deepfryer
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 5)

/obj/item/circuitboard/gibber
	board_name = "Gibber"
	build_path = /obj/machinery/gibber
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/tesla_coil
	board_name = "Tesla Coil"
	build_path = /obj/machinery/power/tesla_coil
	board_type = "machine"
	origin_tech = "programming=3;magnets=3;powerstorage=3"
	req_components = list(
							/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/grounding_rod
	board_name = "Grounding Rod"
	build_path = /obj/machinery/power/grounding_rod
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=3;magnets=3;plasmatech=2"
	req_components = list(
							/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/processor
	board_name = "Food Processor"
	build_path = /obj/machinery/processor
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/recycler
	board_name = "Recycler"
	build_path = /obj/machinery/recycler
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/dnaforensics
	board_name = "Анализатор ДНК"
	build_path = /obj/machinery/dnaforensics
	board_type = "machine"
	origin_tech = "programming=2;combat=2"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stock_parts/manipulator = 1,)

/obj/item/circuitboard/microscope
	board_name = "Электронный микроскоп"
	build_path = /obj/machinery/microscope
	board_type = "machine"
	origin_tech = "programming=2;combat=2"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/smartfridge
	board_name = "Smartfridge"
	build_path = /obj/machinery/smartfridge
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1)
	var/static/list/fridge_names_paths = list(
							"SmartFridge" = /obj/machinery/smartfridge,
							"Seed Storage" = /obj/machinery/smartfridge/seeds,
							"Refrigerated Medicine Storage" = /obj/machinery/smartfridge/medbay,
							"Slime Extract Storage" = /obj/machinery/smartfridge/secure/extract,
							"Secure Refrigerated Medicine Storage" = /obj/machinery/smartfridge/secure/medbay/organ,
							"Smart Chemical Storage" = /obj/machinery/smartfridge/secure/chemistry,
							"Smart Virus Storage" = /obj/machinery/smartfridge/secure/chemistry/virology,
							"Drink Showcase" = /obj/machinery/smartfridge/drinks,
							"Disk Storage" = /obj/machinery/smartfridge/disks,
							"Dish Showcase" = /obj/machinery/smartfridge/dish)


/obj/item/circuitboard/smartfridge/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/choice = tgui_input_list(user, "Circuit Setting", "What would you change the board setting to?", fridge_names_paths)
	if(!choice)
		return
	set_type(user, choice)

/obj/item/circuitboard/smartfridge/proc/set_type(mob/user, type)
	if(!ispath(type))
		board_name = type
		type = fridge_names_paths[type]
	else
		for(var/name in fridge_names_paths)
			if(fridge_names_paths[name] == type)
				board_name = name
				break
	build_path = type
	format_board_name()
	if(user)
		to_chat(user, span_notice("You set the board to [board_name]."))

/obj/item/circuitboard/monkey_recycler
	board_name = "Monkey Recycler"
	build_path = /obj/machinery/monkey_recycler
	board_type = "machine"
	origin_tech = "programming=1;biotech=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/holopad
	board_name = "AI Holopad"
	build_path = /obj/machinery/hologram/holopad
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/chem_dispenser
	board_name = "Chem Dispenser"
	build_path = /obj/machinery/chem_dispenser
	board_type = "machine"
	origin_tech = "materials=4;programming=4;plasmatech=4;biotech=3"
	req_access = list(ACCESS_TOX, ACCESS_CHEMISTRY, ACCESS_SYNDICATE_SCIENTIST)
	req_components = list(	/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stock_parts/cell = 1)

/obj/item/circuitboard/chem_dispenser/botanical
	board_name = "Botanical Chem Dispenser"
	build_path = /obj/machinery/chem_dispenser/botanical

/obj/item/circuitboard/chem_master
	board_name = "ChemMaster 3000"
	build_path = /obj/machinery/chem_master
	board_type = "machine"
	origin_tech = "materials=3;programming=2;biotech=3"
	req_components = list(
							/obj/item/reagent_containers/glass/beaker = 2,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/chem_master/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/new_name = "ChemMaster"
	var/new_path = /obj/machinery/chem_master

	if(build_path == /obj/machinery/chem_master)
		new_name = "CondiMaster"
		new_path = /obj/machinery/chem_master/condimaster

	build_path = new_path
	name = "circuit board ([new_name] 3000)"
	to_chat(user, span_notice("You change the circuit board setting to \"[new_name]\"."))

/obj/item/circuitboard/chem_master/condi_master
	board_name = "CondiMaster 3000"
	build_path = /obj/machinery/chem_master/condimaster

/obj/item/circuitboard/chem_heater
	board_name = "Chemical Heater"
	build_path = /obj/machinery/chem_heater
	board_type = "machine"
	origin_tech = "programming=2;engineering=2;biotech=2"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/reagentgrinder
	board_name = "All-In-One Grinder"
	build_path = /obj/machinery/reagentgrinder/empty
	board_type = "machine"
	origin_tech = "materials=2;engineering=2;biotech=2"
	req_components = list(
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/stock_parts/matter_bin = 1)

//Almost the same recipe as destructive analyzer to give people choices.
/obj/item/circuitboard/experimentor
	board_name = "E.X.P.E.R.I-MENTOR"
	build_path = /obj/machinery/r_n_d/experimentor
	board_type = "machine"
	origin_tech = "magnets=1;engineering=1;programming=1;biotech=1;bluespace=2"
	req_components = list(
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/stock_parts/micro_laser = 2)

/obj/item/circuitboard/destructive_analyzer
	board_name = "Destructive Analyzer"
	build_path = /obj/machinery/r_n_d/destructive_analyzer
	board_type = "machine"
	origin_tech = "magnets=2;engineering=2;programming=2"
	req_components = list(
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/autolathe
	board_name = "Autolathe"
	build_path = /obj/machinery/autolathe
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 3,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/protolathe
	board_name = "Protolathe"
	build_path = /obj/machinery/r_n_d/protolathe
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/chem_dispenser/soda
	board_name = "Soda Machine"
	build_path = /obj/machinery/chem_dispenser/soda

/obj/item/circuitboard/chem_dispenser/beer
	board_name = "Beer Machine"
	build_path = /obj/machinery/chem_dispenser/beer

/obj/item/circuitboard/circuit_imprinter
	board_name = "Circuit Imprinter"
	build_path = /obj/machinery/r_n_d/circuit_imprinter
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/pacman
	board_name = "PACMAN-type Generator"
	build_path = /obj/machinery/power/port_gen/pacman
	board_type = "machine"
	origin_tech = "programming=2;powerstorage=3;plasmatech=3;engineering=3"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/pacman/super
	board_name = "SUPERPACMAN-type Generator"
	build_path = /obj/machinery/power/port_gen/pacman/super
	origin_tech = "programming=3;powerstorage=4;engineering=4"

/obj/item/circuitboard/pacman/mrs
	board_name = "MRSPACMAN-type Generator"
	build_path = /obj/machinery/power/port_gen/pacman/mrs
	origin_tech = "programming=3;powerstorage=4;engineering=4;plasmatech=4"

/obj/item/circuitboard/rdserver
	board_name = "R&D Server"
	build_path = /obj/machinery/r_n_d/server
	board_type = "machine"
	origin_tech = "programming=3"
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/scanning_module = 1)

/obj/item/circuitboard/mechfab
	board_name = "Exosuit Fabricator"
	build_path = /obj/machinery/mecha_part_fabricator
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/mechfab/syndicate
	board_name = "Syndicate Exosuit Fabricator"
	icon_state = "syndicate_circuit"
	build_path = /obj/machinery/mecha_part_fabricator/syndicate
	origin_tech = "programming=2;engineering=2;syndicate=5"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stack/telecrystal = 25)

/obj/item/circuitboard/podfab
	board_name = "Spacepod Fabricator"
	build_path = /obj/machinery/mecha_part_fabricator/spacepod
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/sheet/glass = 1)


/obj/item/circuitboard/clonepod
	board_name = "Experimental Biomass Pod"
	build_path = /obj/machinery/clonepod
	board_type = "machine"
	origin_tech = "programming=2;biotech=2"
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/scanning_module = 2,
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stock_parts/capacitor/quadratic = 5)

/obj/item/circuitboard/clonescanner
	board_name = "\improper DNA Scanner"
	build_path = /obj/machinery/dna_scannernew
	board_type = "machine"
	origin_tech = "programming=2;biotech=2"
	req_components = list(
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stack/cable_coil = 2,)

/obj/item/circuitboard/mech_recharger
	board_name = "Mech Bay Recharger"
	build_path = /obj/machinery/mech_bay_recharge_port
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=3;engineering=3"
	req_components = list(
							/obj/item/stack/cable_coil = 1,
							/obj/item/stock_parts/capacitor = 5)

/obj/item/circuitboard/teleporter_hub
	board_name = "Teleporter Hub"
	build_path = /obj/machinery/teleport/hub
	board_type = "machine"
	origin_tech = "programming=3;engineering=4;bluespace=4;materials=4"
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 3,
							/obj/item/stock_parts/matter_bin = 1)

/obj/item/circuitboard/teleporter_station
	board_name = "Teleporter Station"
	build_path = /obj/machinery/teleport/station
	board_type = "machine"
	origin_tech = "programming=4;engineering=4;bluespace=4;plasmatech=3"
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 2,
							/obj/item/stock_parts/capacitor = 2,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/teleporter_perma
	board_name = "Permanent Teleporter"
	build_path = /obj/machinery/teleport/perma
	board_type = "machine"
	origin_tech = "programming=3;engineering=4;bluespace=4;materials=4"
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 3,
							/obj/item/stock_parts/matter_bin = 1)
	var/target


/obj/item/circuitboard/teleporter_perma/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/gps))
		add_fingerprint(user)
		var/obj/item/gps/gps = I
		if(gps.locked_location)
			target = get_turf(gps.locked_location)
			to_chat(user, span_caution("You upload the data from [gps]"))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/circuitboard/telesci_pad
	board_name = "Telepad"
	build_path = /obj/machinery/telepad
	board_type = "machine"
	origin_tech = "programming=4;engineering=3;plasmatech=4;bluespace=4"
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 2,
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/quantumpad
	board_name = "Quantum Pad"
	build_path = /obj/machinery/quantumpad
	board_type = "machine"
	origin_tech = "programming=3;engineering=3;plasmatech=3;bluespace=4"
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 1,
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 1)
	var/emagged = FALSE

// syndie pads can be created by emagging normal quantumpads
/obj/item/circuitboard/quantumpad/emag_act(mob/user)
	if(!emagged)
		if(user)
			user.visible_message(span_warning("Sparks fly out of the [src]!"), span_notice("You emag the [src], rewriting it's protocols for redspace usage."))
			playsound(src.loc, 'sound/effects/sparks4.ogg', 50, TRUE)
		emagged = TRUE
		name = "circuit board (Syndicate Quantum Pad)"
		build_path = /obj/machinery/syndiepad
		board_type = "machine"
		req_components = list(
								/obj/item/stack/telecrystal = 5,
								/obj/item/stock_parts/capacitor = 1,
								/obj/item/stock_parts/manipulator = 1,
								/obj/item/stack/cable_coil = 1)
	return
// syndie pads by Furukai

/obj/item/circuitboard/quantumpad/syndiepad
	board_name = "Syndicate Quantum Pad"
	build_path = /obj/machinery/syndiepad
	board_type = "machine"
	origin_tech = "programming=3;engineering=3;plasmatech=3;bluespace=4;syndicate=6" //Технология достойная подобного уровня нелегала как по мне
	req_components = list(
							/obj/item/stack/telecrystal = 5,
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 1)
	emagged = TRUE

/obj/item/circuitboard/roboquest_pad

	board_name = "Robotics Request Quantum Pad"
	build_path = /obj/machinery/roboquest_pad
	board_type = "machine"
	origin_tech = "programming=3;engineering=3;plasmatech=3;bluespace=5"
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 5,
							/obj/item/stack/cable_coil = 15)

/obj/item/circuitboard/sleeper
	board_name = "Sleeper"
	build_path = /obj/machinery/sleeper
	board_type = "machine"
	origin_tech = "programming=3;biotech=2;engineering=3"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stack/sheet/glass = 2)

/obj/item/circuitboard/sleeper/syndicate
	board_name = "Sleeper - Syndicate"
	build_path = /obj/machinery/sleeper/syndie

/obj/item/circuitboard/sleeper/survival
	board_name = "Sleeper - Survival Pod"
	build_path = /obj/machinery/sleeper/survival_pod


/obj/item/circuitboard/bodyscanner
	board_name = "Body Scanner"
	build_path = /obj/machinery/bodyscanner
	board_type = "machine"
	origin_tech = "programming=3;biotech=2;engineering=3"
	req_components = list(
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/stack/sheet/glass = 2)

/obj/item/circuitboard/cryo_tube
	board_name = "Cryotube"
	build_path = /obj/machinery/atmospherics/unary/cryo_cell
	board_type = "machine"
	origin_tech = "programming=4;biotech=3;engineering=4;plasmatech=3"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stack/sheet/glass = 4)

/obj/item/circuitboard/cyborgrecharger
	board_name = "Cyborg Recharger"
	build_path = /obj/machinery/recharge_station
	board_type = "machine"
	origin_tech = "powerstorage=3;engineering=3"
	req_components = list(
							/obj/item/stock_parts/capacitor = 2,
							/obj/item/stock_parts/cell = 1,
							/obj/item/stock_parts/manipulator = 1)

// Telecomms circuit boards:
/obj/item/circuitboard/tcomms/relay
	board_name = "Telecommunications Relay"
	build_path = /obj/machinery/tcomms/relay
	board_type = "machine"
	origin_tech = "programming=2;engineering=2;bluespace=2"
	req_components = list(/obj/item/stock_parts/manipulator = 2, /obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/tcomms/core
	board_name = "Telecommunications Core"
	build_path = /obj/machinery/tcomms/core
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(/obj/item/stock_parts/manipulator = 2, /obj/item/stack/cable_coil = 2)
// End telecomms circuit boards

/obj/item/circuitboard/ore_redemption
	board_name = "Ore Redemption"
	build_path = /obj/machinery/mineral/ore_redemption
	board_type = "machine"
	origin_tech = "programming=1;engineering=2"
	req_components = list(
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/assembly/igniter = 1)

/obj/item/circuitboard/ore_redemption/golem
	board_name = "Ore Redemption - Golem"
	build_path = /obj/machinery/mineral/ore_redemption/golem

/obj/item/circuitboard/ore_redemption/labor
	board_name = "Ore Redemption - Labour"
	build_path = /obj/machinery/mineral/ore_redemption/labor

/obj/item/circuitboard/mining_equipment_vendor
	board_name = "Mining Equipment Vendor"
	build_path = /obj/machinery/mineral/equipment_vendor
	board_type = "machine"
	origin_tech = "programming=1;engineering=3"
	req_components = list(
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stock_parts/matter_bin = 3)

/obj/item/circuitboard/mining_equipment_vendor/golem
	board_name = "Golem Equipment Vendor"
	build_path = /obj/machinery/mineral/equipment_vendor/golem

/obj/item/circuitboard/mining_equipment_vendor/labor
	board_name = "Labour Equipment Vendor"
	build_path = /obj/machinery/mineral/equipment_vendor/labor

/obj/item/circuitboard/clawgame
	board_name = "Claw Game"
	build_path = /obj/machinery/arcade/claw
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 5,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/minesweeper
	board_name = "Сапер"
	build_path = /obj/machinery/arcade/minesweeper
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 5,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/prize_counter
	board_name = "Prize Counter"
	build_path = /obj/machinery/prize_counter
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stack/cable_coil = 1)

/obj/item/circuitboard/gameboard
	board_name = "Virtual Gameboard"
	build_path = /obj/machinery/gameboard
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 3,
							/obj/item/stack/sheet/glass = 1)
