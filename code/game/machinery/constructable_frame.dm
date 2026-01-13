// Construction | Deconstruction
#define STATE_EMPTY 1 // Add wires | Wrench to destroy
#define STATE_WIRED 2 // Add cicuit / Wrench to unchor/unanchor | Remove wires with wirecutters
#define STATE_COMPONENTS 3 // Add components / Wrench to unchor/unanchor | Remove circuit/components with crowbar

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

			if(istype(I, /obj/item/storage/bag/construction) && length(I.contents) && get_req_components_amt())
				var/obj/item/storage/bag/construction/bag = I
				INVOKE_ASYNC(src, PROC_REF(apply_parts_from_construction_bag), bag, user)
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

/obj/machinery/constructable_frame/machine_frame/proc/apply_parts_from_construction_bag(obj/item/storage/bag/construction/bag, mob/user, count = 0)
	for(var/path in req_components)
		if(req_components[path] <= 0 || !(locate(path) in bag))
			continue
		if(!do_after(user, 0.7 SECONDS, src, interaction_key = bag, max_interact_count = 1))
			return FALSE
		var/obj/item/part = (locate(path) in bag)
		bag.remove_from_storage(part, src)
		req_components[path]--
		components += part
		to_chat(user, span_notice("[part.declent_ru(NOMINATIVE)] вставлен[GEND_A_O_Y(part)]."))
		return apply_parts_from_construction_bag(bag, user, count + 1)
	balloon_alert(user, "вставлен[declension_ru(count, "а", "о", "о")] [count] детал[declension_ru(count, "ь", "и", "ей")]")
	return TRUE

#undef STATE_EMPTY
#undef STATE_WIRED
#undef STATE_COMPONENTS
