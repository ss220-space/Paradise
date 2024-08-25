/obj/structure/door_assembly
	name = "airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "construction"
	anchored = FALSE
	density = TRUE
	max_integrity = 200
	var/overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
	var/state = AIRLOCK_ASSEMBLY_NEEDS_WIRES
	var/mineral
	var/base_name = "airlock"
	var/obj/item/airlock_electronics/airlock_electronics
	var/obj/item/access_control/access_electronics
	var/airlock_type = /obj/machinery/door/airlock //the type path of the airlock once completed
	var/glass_type = /obj/machinery/door/airlock/glass
	var/glass = 0 // 0 = glass can be installed. 1 = glass is already installed.
	var/created_name
	var/heat_proof_finished = 0 //whether to heat-proof the finished airlock
	var/previous_assembly = /obj/structure/door_assembly
	var/noglass = FALSE //airlocks with no glass version, also cannot be modified with sheets
	var/material_type = /obj/item/stack/sheet/metal
	var/material_amt = 4

/obj/structure/door_assembly/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_NAME|UPDATE_OVERLAYS)

/obj/structure/door_assembly/Destroy()
	QDEL_NULL(airlock_electronics)
	QDEL_NULL(access_electronics)
	return ..()

/obj/structure/door_assembly/examine(mob/user)
	. = ..()
	var/doorname = ""
	if(created_name)
		doorname = ", written on it is '[created_name]'"
	switch(state)
		if(AIRLOCK_ASSEMBLY_NEEDS_WIRES)
			if(anchored)
				. += "<span class='notice'>The anchoring bolts are <b>wrenched</b> in place, but the maintenance panel lacks <i>wiring</i>.</span>"
			else
				. += "<span class='notice'>The assembly is <b>welded together</b>, but the anchoring bolts are <i>unwrenched</i>.</span>"
		if(AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS)
			. += "<span class='notice'>The maintenance panel is <b>wired</b>, but the circuit slot is <i>empty</i>.</span>"
		if(AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER)
			. += "<span class='notice'>The circuit is <b>connected loosely</b> to its slot, but the maintenance panel is <i>unscrewed and open</i>.</span>"
			if(access_electronics)
				. += "<span class='notice'>The access control circuit is connected to its slot.</span>"
			else
				. += "<span class='notice'>The access control slot is empty.</span>"
	if(!mineral && !glass && !noglass)
		. += "<span class='notice'>There is a small <i>paper</i> placard on the assembly[doorname]. There are <i>empty</i> slots for glass windows and mineral covers.</span>"
	else if(!mineral && glass && !noglass)
		. += "<span class='notice'>There is a small <i>paper</i> placard on the assembly[doorname]. There are <i>empty</i> slots for mineral covers.</span>"
	else if(mineral && !glass && !noglass)
		. += "<span class='notice'>There is a small <i>paper</i> placard on the assembly[doorname]. There are <i>empty</i> slots for glass windows.</span>"
	else
		. += "<span class='notice'>There is a small <i>paper</i> placard on the assembly[doorname].</span>"

/obj/structure/door_assembly/attack_hand(mob/living/carbon/human/user)
	if(user.a_intent == INTENT_HARM && ishuman(user) && (user.dna.species.obj_damage + user.physiology.punch_obj_damage > 0))
		add_fingerprint(user)
		user.changeNext_move(CLICK_CD_MELEE)
		attack_generic(user, user.dna.species.obj_damage + user.physiology.punch_obj_damage)
		return
	. = ..()


/obj/structure/door_assembly/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		// The door assembly gets renamed to "Assembly - Foobar",
		// but the `t` returned from the proc is just "Foobar" without the prefix.
		var/new_name = rename_interactive(user, I)
		if(!isnull(new_name))
			created_name = new_name
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/stack/sheet))
		add_fingerprint(user)
		var/obj/item/stack/sheet/new_sheet = I
		if(noglass)	// yes it blocks all the sheets, dont ask why
			to_chat(user, span_warning("You cannot add [new_sheet] to [src]!"))
			return ATTACK_CHAIN_PROCEED
		if(glass || mineral)
			to_chat(user, span_warning("The [name] has been already improved by other material!"))
			return ATTACK_CHAIN_PROCEED
		if((!istype(new_sheet , /obj/item/stack/sheet/rglass) && !istype(new_sheet, /obj/item/stack/sheet/glass)) && \
			!(new_sheet.sheettype && (istype(new_sheet, /obj/item/stack/sheet/mineral) || istype(new_sheet, /obj/item/stack/sheet/wood))))
			to_chat(user, span_warning("This material is incompatible with [src]!"))
			return ATTACK_CHAIN_PROCEED
		if(new_sheet.get_amount() < 2)
			to_chat(user, span_warning("You need at least two sheets of [new_sheet.name]!"))
			return ATTACK_CHAIN_PROCEED
		new_sheet.play_tool_sound(src)
		user.visible_message(
			span_notice("[user] adds [new_sheet.name] to the airlock assembly."),
			span_notice("You start to install [new_sheet.name] into the airlock assembly..."),
		)
		if(!do_after(user, 4 SECONDS * new_sheet.toolspeed, src, category = DA_CAT_TOOL) || QDELETED(new_sheet) || glass || mineral)
			return ATTACK_CHAIN_PROCEED
		var/cached_sheettype = new_sheet.sheettype
		var/cached_name = new_sheet.name
		if(!new_sheet.use(2))
			to_chat(user, span_warning("At some point during construction you lost some material. Make sure you have two sheets before trying again."))
			return ATTACK_CHAIN_PROCEED
		if(cached_sheettype)	// not glass
			to_chat(user, span_notice("You install [cached_sheettype] plating into the airlock assembly."))
			var/assembly_path = text2path("/obj/structure/door_assembly/door_assembly_[cached_sheettype]")
			var/obj/structure/door_assembly/door_assembly = new assembly_path(loc)
			transfer_fingerprints_to(door_assembly)
			door_assembly.add_fingerprint(user)
			transfer_assembly_vars(src, door_assembly, TRUE)
			return ATTACK_CHAIN_BLOCKED_ALL
		to_chat(user, span_notice("You install [cached_name] windows into the airlock assembly."))
		glass = TRUE
		if(new_sheet.type == /obj/item/stack/sheet/rglass)
			heat_proof_finished = TRUE //reinforced glass makes the airlock heat-proof
		update_appearance(UPDATE_NAME|UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	switch(state)
		if(AIRLOCK_ASSEMBLY_NEEDS_WIRES)
			if(!iscoil(I))
				return ..()
			add_fingerprint(user)
			var/obj/item/stack/cable_coil/coil = I
			if(!anchored)
				to_chat(user, span_warning("You need to anchor the airlock assembly first!"))
				return ATTACK_CHAIN_PROCEED
			if(coil.get_amount() < 1)
				to_chat(user, span_warning("You need one length of cable to wire the airlock assembly!"))
				return ATTACK_CHAIN_PROCEED
			coil.play_tool_sound(src)
			user.visible_message(
				span_notice("[user] wires the airlock assembly."),
				span_notice("You start to wire the airlock assembly..."),
			)
			if(!do_after(user, 4 SECONDS * coil.toolspeed, src, category = DA_CAT_TOOL) || state != AIRLOCK_ASSEMBLY_NEEDS_WIRES || QDELETED(coil))
				return ATTACK_CHAIN_PROCEED
			if(!coil.use(1))
				to_chat(user, span_warning("At some point during construction you lost some cable. Make sure you have one lengths before trying again."))
				return ATTACK_CHAIN_PROCEED
			to_chat(user, span_notice("You wire the airlock assembly."))
			state = AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS
			update_appearance(UPDATE_NAME|UPDATE_OVERLAYS)
			return ATTACK_CHAIN_PROCEED_SUCCESS

		if(AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS)
			if(!istype(I, /obj/item/airlock_electronics))
				return ..()
			add_fingerprint(user)
			var/obj/item/airlock_electronics/new_circuit = I
			if(new_circuit.icon_state == "door_electronics_smoked")	// no time to change this now, FFS
				to_chat(user, span_warning("The [I.name] is broken."))
				return ATTACK_CHAIN_PROCEED
			if(new_circuit.access_electronics)
				if(access_electronics)
					to_chat(user, span_warning("The airlock assembly already has [access_electronics] installed."))
					return ATTACK_CHAIN_PROCEED
				if(new_circuit.access_electronics.emagged)
					to_chat(user, span_warning("The [new_circuit.name] has broken [new_circuit.access_electronics.name] installed."))
					return ATTACK_CHAIN_PROCEED
			new_circuit.play_tool_sound(src)
			user.visible_message(
				span_notice("[user] starts to install the airlock electronics into the airlock assembly."),
				span_notice("You start to install airlock electronics into the airlock assembly..."),
			)
			if(!do_after(user, 4 SECONDS * new_circuit.toolspeed, src, category = DA_CAT_TOOL) || state != AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS || I.icon_state == "door_electronics_smoked" || (new_circuit.access_electronics && (access_electronics || new_circuit.access_electronics.emagged)))
				return ATTACK_CHAIN_PROCEED
			if(!user.drop_transfer_item_to_loc(new_circuit, src))
				return ATTACK_CHAIN_PROCEED
			state = AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER
			QDEL_NULL(access_electronics)
			airlock_electronics = new_circuit
			var/feedback = "You install the airlock electronics"
			if(new_circuit.access_electronics)
				feedback += " with access control circuit attached to it"
				new_circuit.access_electronics.forceMove(src)
				access_electronics = new_circuit.access_electronics
				new_circuit.access_electronics = null
			to_chat(user, span_notice("[feedback]."))
			update_appearance(UPDATE_NAME|UPDATE_OVERLAYS)
			return ATTACK_CHAIN_BLOCKED_ALL

		if(AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER)
			if(!istype(I, /obj/item/access_control))
				return ..()
			add_fingerprint(user)
			var/obj/item/access_control/control = I
			if(access_electronics)
				to_chat(user, span_warning("The airlock assembly already has [access_electronics] installed."))
				return ATTACK_CHAIN_PROCEED
			if(control.emagged)
				to_chat(user, span_warning("The [control.name] is broken."))
				return ATTACK_CHAIN_PROCEED
			control.play_tool_sound(src)
			user.visible_message(
				span_notice("[user] installs the access control electronics into the airlock assembly."),
				span_notice("You start to install the access control electronics into the airlock assembly..."),
			)
			if(!do_after(user, 4 SECONDS * control.toolspeed, src, category = DA_CAT_TOOL) || state != AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER || access_electronics || control.emagged)
				return ATTACK_CHAIN_PROCEED
			if(!user.drop_transfer_item_to_loc(control, src))
				return ATTACK_CHAIN_PROCEED
			to_chat(user, span_notice("You install the access control electronics."))
			access_electronics = control
			return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/door_assembly/crowbar_act(mob/user, obj/item/I)
	if(state != AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER )
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message("[user] is removing the electronics from the airlock assembly...", "You start to remove electronics from the airlock assembly...")
	if(!I.use_tool(src, user, 4 SECONDS, volume = I.tool_volume) || state != AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER)
		return
	to_chat(user, "<span class='notice'>You remove the airlock electronics.</span>")
	state = AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS
	name = "wired airlock assembly"

	if(!airlock_electronics)
		airlock_electronics = new /obj/item/airlock_electronics(loc)
	else
		airlock_electronics.forceMove(loc)
		airlock_electronics = null

	if(access_electronics)
		access_electronics.forceMove(loc)
		access_electronics = null

	update_appearance(UPDATE_NAME|UPDATE_OVERLAYS)

/obj/structure/door_assembly/screwdriver_act(mob/user, obj/item/I)
	if(state != AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER )
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message("[user] is finishing the airlock...", \
							"<span class='notice'>You start finishing the airlock...</span>")
	. = TRUE
	if(!I.use_tool(src, user, 4 SECONDS, volume = I.tool_volume) || state != AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER)
		return
	to_chat(user, "<span class='notice'>You finish the airlock.</span>")
	var/obj/machinery/door/airlock/door
	if(glass)
		door = new glass_type(loc)
	else
		door = new airlock_type(loc)
	door.remove_shielding()
	door.setDir(dir)
	door.heat_proof = heat_proof_finished
	if(created_name)
		door.name = created_name
	else
		door.name = base_name
	door.previous_airlock = previous_assembly

	door.airlock_electronics = airlock_electronics
	door.id_tag = airlock_electronics.id
	airlock_electronics.forceMove(door)
	airlock_electronics = null

	if(access_electronics)
		door.has_access_electronics = TRUE
		door.access_electronics = access_electronics
		door.unres_sides = access_electronics.unres_access_from
		door.req_access = access_electronics.selected_accesses
		door.check_one_access = access_electronics.one_access
		access_electronics.forceMove(door)
		access_electronics = null
	else
		door.has_access_electronics = FALSE

	door.update_appearance()
	qdel(src)


/obj/structure/door_assembly/wirecutter_act(mob/user, obj/item/I)
	if(state != AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message("[user] is cutting the wires from the airlock assembly...", "You start to cut the wires from airlock assembly...")
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS)
		return
	to_chat(user, "<span class='notice'>You cut the wires from the airlock assembly.</span>")
	new/obj/item/stack/cable_coil(get_turf(user), 1)
	state = AIRLOCK_ASSEMBLY_NEEDS_WIRES
	update_appearance(UPDATE_NAME|UPDATE_OVERLAYS)


/obj/structure/door_assembly/wrench_act(mob/user, obj/item/I)
	if(state != AIRLOCK_ASSEMBLY_NEEDS_WIRES)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(anchored)
		user.visible_message("[user] is unsecuring the airlock assembly from the floor...", "You start to unsecure the airlock assembly from the floor...")
	else
		user.visible_message("[user] is securing the airlock assembly to the floor...", "You start to secure the airlock assembly to the floor...")
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != AIRLOCK_ASSEMBLY_NEEDS_WIRES)
		return
	to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secure the airlock assembly.</span>")
	set_anchored(!anchored)

/obj/structure/door_assembly/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(mineral)
		// damn wood
		var/mineral_path = (mineral == "wood") ? /obj/item/stack/sheet/wood : text2path("/obj/item/stack/sheet/mineral/[mineral]")
		visible_message("<span class='notice'>[user] welds the [mineral] plating off [src].</span>",\
			"<span class='notice'>You start to weld the [mineral] plating off [src]...</span>",\
			"<span class='warning'>You hear welding.</span>")
		if(!I.use_tool(src, user, 40, volume = I.tool_volume))
			return
		to_chat(user, "<span class='notice'>You weld the [mineral] plating off.</span>")
		new mineral_path(loc, 2)
		var/obj/structure/door_assembly/PA = new previous_assembly(loc)
		transfer_assembly_vars(src, PA)
	else if(glass)
		visible_message("<span class='notice'>[user] welds the glass panel out of [src].</span>",\
			"<span class='notice'>You start to weld the glass panel out of the [src]...</span>",\
			"<span class='warning'>You hear welding.</span>")
		if(!I.use_tool(src, user, 40, volume = I.tool_volume))
			return
		to_chat(user, "<span class='notice'>You weld the glass panel out.</span>")
		if(heat_proof_finished)
			new /obj/item/stack/sheet/rglass(loc)
			heat_proof_finished = FALSE
		else
			new /obj/item/stack/sheet/glass(loc)
		glass = FALSE
		update_appearance(UPDATE_NAME|UPDATE_OVERLAYS)
	else if(!anchored)
		visible_message("<span class='warning'>[user] disassembles [src].</span>", \
			"<span class='notice'>You start to disassemble [src]...</span>",\
			"<span class='warning'>You hear welding.</span>")
		if(!I.use_tool(src, user, 40, volume = I.tool_volume))
			return
		to_chat(user, "<span class='notice'>You disassemble the airlock assembly.</span>")
		deconstruct(TRUE)


/obj/structure/door_assembly/update_overlays()
	. = ..()
	if(!glass)
		. += get_airlock_overlay("fill_construction", icon)
	else if(glass)
		. += get_airlock_overlay("glass_construction", overlays_file)
	. += get_airlock_overlay("panel_c[state+1]", overlays_file)


/obj/structure/door_assembly/update_name(updates = ALL)
	. = ..()
	name = ""
	switch(state)
		if(AIRLOCK_ASSEMBLY_NEEDS_WIRES)
			if(anchored)
				name = "secured "
		if(AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS)
			name = "wired "
		if(AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER)
			name = "near finished "
	name += "[heat_proof_finished ? "heat-proofed " : ""][glass ? "window " : ""][base_name] assembly"


/obj/structure/door_assembly/proc/transfer_assembly_vars(obj/structure/door_assembly/source, obj/structure/door_assembly/target, previous = FALSE)
	target.glass = source.glass
	target.heat_proof_finished = source.heat_proof_finished
	target.created_name = source.created_name
	target.state = source.state
	target.anchored = source.anchored
	if(previous)
		target.previous_assembly = source.type
	if(airlock_electronics)
		target.airlock_electronics = source.airlock_electronics
		source.airlock_electronics.forceMove(target)
	if(access_electronics)
		target.access_electronics = source.access_electronics
		source.access_electronics.forceMove(target)
	target.update_appearance(UPDATE_NAME|UPDATE_OVERLAYS)
	qdel(source)

/obj/structure/door_assembly/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		var/turf/T = get_turf(src)
		if(!disassembled)
			material_amt = rand(2,4)
		new material_type(T, material_amt)
		if(glass)
			if(disassembled)
				if(heat_proof_finished)
					new /obj/item/stack/sheet/rglass(T)
				else
					new /obj/item/stack/sheet/glass(T)
			else
				new /obj/item/shard(T)
		if(mineral)
			var/mineral_path
			if(mineral == "wood")
				mineral_path = /obj/item/stack/sheet/wood
			else
				mineral_path = text2path("/obj/item/stack/sheet/mineral/[mineral]")
			new mineral_path(T, 2)
	qdel(src)
