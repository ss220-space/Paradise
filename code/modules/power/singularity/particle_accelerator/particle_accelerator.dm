/obj/structure/particle_accelerator
	name = "Particle Accelerator"
	desc = "Part of a Particle Accelerator."
	icon = 'icons/obj/engines_and_power/particle_accelerator.dmi'
	icon_state = null
	density = TRUE
	max_integrity = 500
	armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 90, ACID = 80)
	/// The control computer this part is bound to.
	var/obj/machinery/particle_accelerator/control_box/master = null
	/// Current assembly stage.
	var/construction_state = ACCELERATOR_UNWRENCHED
	/// icon_state prefix identifying which accelerator part this is (e.g. "end_cap").
	var/reference = null
	/// Whether the part is currently powered on. Affects which icon_state is chosen.
	var/powered = 0
	/// Current power level. Set by the control computer, used in icon_state.
	var/strength = null
	/// Description swapped into desc once the part is fully assembled and powered.
	var/desc_holder = null

/obj/structure/particle_accelerator/Destroy()
	construction_state = ACCELERATOR_UNWRENCHED
	update_master_ui()
	return ..()

/obj/structure/particle_accelerator/proc/update_master_ui()
	if(master)
		SStgui.update_uis(master)

/obj/structure/particle_accelerator/end_cap
	name = "Alpha Particle Generation Array"
	desc_holder = "This is where Alpha particles are generated from \[REDACTED\]"
	icon_state = "end_cap"
	reference = "end_cap"

/obj/structure/particle_accelerator/click_alt(mob/user)
	rotate_accelerator(user)
	return CLICK_ACTION_SUCCESS

/obj/structure/particle_accelerator/proc/rotate_accelerator(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	if(anchored)
		to_chat(user, span_notice("It is fastened to the floor!"))
		return
	dir = turn(dir, 270)

/obj/structure/particle_accelerator/examine(mob/user)
	. = ..()
	switch(construction_state)
		if(ACCELERATOR_UNWRENCHED)
			. += span_notice("[name]'s <i>anchoring bolts</i> are loose.")
		if(ACCELERATOR_WRENCHED)
			. += span_notice("[name]'s anchoring bolts are <b>wrenched</b> in place, but it lacks <i>wiring</i>.")
		if(ACCELERATOR_WIRED)
			. += span_notice("[name] is <b>wired</b>, but the maintenance panel is <i>unscrewed and open</i>.")
		if(ACCELERATOR_READY)
			. += span_notice("[name] is assembled and the maintenence panel is <b>screwed shut</b>.")
			if(powered)
				desc = desc_holder
	if(!anchored)
		. += span_notice("<b>Alt-Click</b> to rotate it.")

/obj/structure/particle_accelerator/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(drop_location(src), 5)
	qdel(src)

/obj/structure/particle_accelerator/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	. = ..()
	if(master?.active)
		master.toggle_power()
		investigate_log("was moved whilst active; it <font color='red'>powered down</font>.", INVESTIGATE_ENGINE)

/obj/structure/particle_accelerator/update_icon_state()
	switch(construction_state)
		if(ACCELERATOR_UNWRENCHED, ACCELERATOR_WRENCHED)
			icon_state = "[reference]"
		if(ACCELERATOR_WIRED)
			icon_state = "[reference]w"
		if(ACCELERATOR_READY)
			icon_state = powered ? "[reference]p[strength]" : "[reference]c"

/obj/structure/particle_accelerator/proc/update_state()
	if(master)
		master.update_state()
		return ACCELERATOR_UNWRENCHED

/obj/structure/particle_accelerator/proc/report_ready(obj/requester)
	if(requester && (requester == master))
		if(construction_state >= ACCELERATOR_READY)
			return ACCELERATOR_WRENCHED
	return ACCELERATOR_UNWRENCHED

/obj/structure/particle_accelerator/proc/report_master()
	if(master)
		return master
	return ACCELERATOR_UNWRENCHED

/obj/structure/particle_accelerator/proc/connect_master(obj/candidate)
	if(candidate && istype(candidate, /obj/machinery/particle_accelerator/control_box))
		if(candidate.dir == dir)
			master = candidate
			return ACCELERATOR_WRENCHED
	return ACCELERATOR_UNWRENCHED

/obj/structure/particle_accelerator/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.a_intent == INTENT_HARM || !iscoil(tool))
		return NONE
	add_fingerprint(user)
	if(construction_state != ACCELERATOR_WRENCHED)
		to_chat(user, span_warning("The [name] should be secured to the floor."))
		return ITEM_INTERACT_BLOCKING
	var/obj/item/stack/cable_coil/coil = tool
	var/cached_sound = coil.usesound
	if(!coil.use(1))
		to_chat(user, span_warning("You need at least one length of the cable to proceed."))
		return ITEM_INTERACT_BLOCKING
	playsound(loc, cached_sound, 50, TRUE)
	user.visible_message(
		span_notice("[user] has wired [src]."),
		span_notice("You have wired [src]."),
	)
	construction_state = ACCELERATOR_WIRED
	update_icon(UPDATE_ICON_STATE)
	update_master_ui()
	return ITEM_INTERACT_SUCCESS

/obj/structure/particle_accelerator/screwdriver_act(mob/user, obj/item/tool)
	if(construction_state != ACCELERATOR_WIRED && construction_state != ACCELERATOR_READY)
		return
	. = TRUE
	if(!tool.use_tool(src, user, 0, volume = tool.tool_volume))
		return
	if(construction_state == ACCELERATOR_WIRED)
		SCREWDRIVER_CLOSE_PANEL_MESSAGE
		construction_state = ACCELERATOR_READY
	else
		SCREWDRIVER_OPEN_PANEL_MESSAGE
		construction_state = ACCELERATOR_WIRED
	update_state()
	update_icon(UPDATE_ICON_STATE)
	update_master_ui()

/obj/structure/particle_accelerator/wirecutter_act(mob/user, obj/item/tool)
	if(construction_state != ACCELERATOR_WIRED)
		return
	. = TRUE
	if(!tool.use_tool(src, user, 0, volume = tool.tool_volume))
		return
	WIRECUTTER_SNIP_MESSAGE
	construction_state = ACCELERATOR_WRENCHED
	update_master_ui()

/obj/structure/particle_accelerator/wrench_act(mob/user, obj/item/tool)
	if(construction_state != ACCELERATOR_UNWRENCHED && construction_state != ACCELERATOR_WRENCHED)
		return
	. = TRUE
	if(!tool.use_tool(src, user, 0, volume = tool.tool_volume))
		return
	var/anchoring = (construction_state == ACCELERATOR_UNWRENCHED)
	set_anchored(anchoring)
	if(anchoring)
		WRENCH_ANCHOR_MESSAGE
		construction_state = ACCELERATOR_WRENCHED
	else
		WRENCH_UNANCHOR_MESSAGE
		construction_state = ACCELERATOR_UNWRENCHED
	update_icon(UPDATE_ICON_STATE)
	update_master_ui()

/obj/machinery/particle_accelerator
	name = "Particle Accelerator"
	desc = "Part of a Particle Accelerator."
	icon = 'icons/obj/engines_and_power/particle_accelerator.dmi'
	icon_state = null
	density = TRUE
	use_power = NO_POWER_USE
	/// Current assembly stage.
	var/construction_state = ACCELERATOR_UNWRENCHED
	/// Whether the machine is running (control computer is active and processing ticks).
	var/active = FALSE
	/// icon_state prefix identifying which accelerator part this is.
	var/reference = null
	/// Current power level. Set by the control computer, used in icon_state.
	var/strength = 0

/obj/machinery/particle_accelerator/examine(mob/user)
	. = ..()
	. += span_notice("<b>Alt-Click</b> to rotate it.")

/obj/machinery/particle_accelerator/click_alt(mob/user)
	rotate_accelerator(user)
	return CLICK_ACTION_SUCCESS

/obj/machinery/particle_accelerator/proc/rotate_accelerator(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	if(anchored)
		to_chat(user, span_notice("It is fastened to the floor!"))
		return
	dir = turn(dir, 270)

/obj/machinery/particle_accelerator/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.a_intent == INTENT_HARM || !iscoil(tool))
		return NONE
	add_fingerprint(user)
	if(construction_state != ACCELERATOR_WRENCHED)
		to_chat(user, span_warning("The [name] should be secured to the floor."))
		return ITEM_INTERACT_BLOCKING
	var/obj/item/stack/cable_coil/coil = tool
	var/cached_sound = coil.usesound
	if(!coil.use(1))
		to_chat(user, span_warning("You need at least one length of the cable to proceed."))
		return ITEM_INTERACT_BLOCKING
	playsound(loc, cached_sound, 50, TRUE)
	user.visible_message(
		span_notice("[user] has wired [src]."),
		span_notice("You have wired [src]."),
	)
	construction_state = ACCELERATOR_WIRED
	update_icon()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/particle_accelerator/screwdriver_act(mob/user, obj/item/tool)
	if(construction_state != ACCELERATOR_WIRED && construction_state != ACCELERATOR_READY)
		return
	. = TRUE
	if(!tool.use_tool(src, user, 0, volume = tool.tool_volume))
		return
	if(construction_state == ACCELERATOR_WIRED)
		SCREWDRIVER_CLOSE_PANEL_MESSAGE
		construction_state = ACCELERATOR_READY
		use_power = IDLE_POWER_USE
	else
		SCREWDRIVER_OPEN_PANEL_MESSAGE
		construction_state = ACCELERATOR_WIRED
		use_power = NO_POWER_USE
		update_state()
	update_icon()

/obj/machinery/particle_accelerator/wirecutter_act(mob/user, obj/item/tool)
	if(construction_state != ACCELERATOR_WIRED)
		return
	. = TRUE
	if(!tool.use_tool(src, user, 0, volume = tool.tool_volume))
		return
	WIRECUTTER_SNIP_MESSAGE
	construction_state = ACCELERATOR_WRENCHED

/obj/machinery/particle_accelerator/wrench_act(mob/user, obj/item/tool)
	if(construction_state != ACCELERATOR_UNWRENCHED && construction_state != ACCELERATOR_WRENCHED)
		return
	. = TRUE
	if(!tool.use_tool(src, user, 0, volume = tool.tool_volume))
		return
	var/anchoring = (construction_state == ACCELERATOR_UNWRENCHED)
	set_anchored(anchoring)
	if(anchoring)
		WRENCH_ANCHOR_MESSAGE
		construction_state = ACCELERATOR_WRENCHED
	else
		WRENCH_UNANCHOR_MESSAGE
		construction_state = ACCELERATOR_UNWRENCHED
	update_icon()

/obj/machinery/particle_accelerator/proc/update_state()
	return FALSE

