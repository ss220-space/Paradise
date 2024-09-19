/*Composed of 7 parts
3 Particle emitters
proc
emit_particle()

1 power box
the only part of this thing that uses power, can hack to mess with the pa/make it better

1 fuel chamber
contains procs for mixing gas and whatever other fuel it uses
mix_gas()

1 gas holder WIP
acts like a tank valve on the ground that you wrench gas tanks onto
proc
extract_gas()
return_gas()
attach_tank()
remove_tank()
get_available_mix()

1 End Cap

1 Control computer
interface for the pa, acts like a computer with an html menu for diff parts and a status report
all other parts contain only a ref to this
a /machine/, tells the others to do work
contains ref for all parts
proc
process()
check_build()

Setup map
  |EC|
CC|FC|
  |PB|
PE|PE|PE


Icon Addemdum
Icon system is much more robust, and the icons are all variable based.
Each part has a reference string, powered, strength, and contruction values.
Using this the update_icon() proc is simplified a bit (using for absolutely was problematic with naming),
so the icon_state comes out be:
"[reference][strength]", with a switch controlling construction_states and ensuring that it doesn't
power on while being contructed, and all these variables are set by the computer through it's scan list
Essential order of the icons:
Standard - [reference]
Wrenched - [reference]
Wired    - [reference]w
Closed   - [reference]c
Powered  - [reference]p[strength]
Strength being set by the computer and a null strength (Computer is powered off or inactive) returns a 'null', counting as empty
So, hopefully this is helpful if any more icons are to be added/changed/wondering what the hell is going on here

*/
#define ACCELERATOR_UNWRENCHED	0
#define ACCELERATOR_WRENCHED	1
#define ACCELERATOR_WIRED		2
#define ACCELERATOR_READY		3

/obj/structure/particle_accelerator
	name = "Particle Accelerator"
	desc = "Part of a Particle Accelerator."
	icon = 'icons/obj/engines_and_power/particle_accelerator.dmi'
	icon_state = "none"
	anchored = FALSE
	density = TRUE
	max_integrity = 500
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 90, "acid" = 80)
	var/obj/machinery/particle_accelerator/control_box/master = null
	var/construction_state = 0
	var/reference = null
	var/powered = 0
	var/strength = null
	var/desc_holder = null

/obj/structure/particle_accelerator/Destroy()
	construction_state = 0
	if(master)
		master.part_scan()
	return ..()

/obj/structure/particle_accelerator/end_cap
	name = "Alpha Particle Generation Array"
	desc_holder = "This is where Alpha particles are generated from \[REDACTED\]"
	icon_state = "end_cap"
	reference = "end_cap"


/obj/structure/particle_accelerator/verb/rotate()
	set name = "Rotate Clockwise"
	set category = "Object"
	set src in oview(1)

	rotate_accelerator(usr)

/obj/structure/particle_accelerator/AltClick(mob/user)
	rotate_accelerator(user)

/obj/structure/particle_accelerator/proc/rotate_accelerator(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	if(anchored)
		to_chat(user, "<span class='notice'>It is fastened to the floor!</span>")
		return
	dir = turn(dir, 270)


/obj/structure/particle_accelerator/examine(mob/user)
	. = ..()
	switch(construction_state)
		if(ACCELERATOR_UNWRENCHED)
			. += "<span class='notice'>\The [name]'s <i>anchoring bolts</i> are loose.</span>"
		if(ACCELERATOR_WRENCHED)
			. += "<span class='notice'>\The [name]'s anchoring bolts are <b>wrenched</b> in place, but it lacks <i>wiring</i>.</span>"
		if(ACCELERATOR_WIRED)
			. +=  "<span class='notice'>\The [name] is <b>wired</b>, but the maintenance panel is <i>unscrewed and open</i>.</span>"
		if(ACCELERATOR_READY)
			. += "<span class='notice'>\The [name] is assembled and the maintenence panel is <b>screwed shut</b>.</span>"
			if(powered)
				desc = desc_holder
	if(!anchored)
		. += "<span class='notice'><b>Alt-Click</b> to rotate it.</span>"

/obj/structure/particle_accelerator/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal (loc, 5)
	qdel(src)

/obj/structure/particle_accelerator/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	. = ..()
	if(master && master.active)
		master.toggle_power()
		investigate_log("was moved whilst active; it <font color='red'>powered down</font>.", INVESTIGATE_ENGINE)

/obj/machinery/particle_accelerator/control_box/blob_act(obj/structure/blob/B)
	if(prob(50) && !QDELETED(src))
		qdel(src)

/obj/structure/particle_accelerator/update_icon_state()
	switch(construction_state)
		if(ACCELERATOR_UNWRENCHED, ACCELERATOR_WRENCHED)
			icon_state="[reference]"
		if(ACCELERATOR_WIRED)
			icon_state="[reference]w"
		if(ACCELERATOR_READY)
			if(powered)
				icon_state="[reference]p[strength]"
			else
				icon_state="[reference]c"


/obj/structure/particle_accelerator/proc/update_state()
	if(master)
		master.update_state()
		return 0


/obj/structure/particle_accelerator/proc/report_ready(var/obj/O)
	if(O && (O == master))
		if(construction_state >= 3)
			return 1
	return 0


/obj/structure/particle_accelerator/proc/report_master()
	if(master)
		return master
	return 0


/obj/structure/particle_accelerator/proc/connect_master(var/obj/O)
	if(O && istype(O,/obj/machinery/particle_accelerator/control_box))
		if(O.dir == dir)
			master = O
			return 1
	return 0


/obj/structure/particle_accelerator/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(iscoil(I))
		add_fingerprint(user)
		var/obj/item/stack/cable_coil/coil = I
		if(construction_state != ACCELERATOR_WRENCHED)
			to_chat(user, span_warning("The [name] should be secured to the floor."))
			return ATTACK_CHAIN_PROCEED
		var/cached_sound = coil.usesound
		if(!coil.use(1))
			to_chat(user, span_warning("You need at least one length of the cable to proceed."))
			return ATTACK_CHAIN_PROCEED
		playsound(loc, cached_sound, 50, TRUE)
		user.visible_message(
			span_notice("[user] has wired [src]."),
			span_notice("You have wired [src]."),
		)
		construction_state = ACCELERATOR_WIRED
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/structure/particle_accelerator/screwdriver_act(mob/user, obj/item/I)
	if(construction_state != ACCELERATOR_WIRED && construction_state != ACCELERATOR_READY)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(construction_state == ACCELERATOR_WIRED)
		SCREWDRIVER_CLOSE_PANEL_MESSAGE
		construction_state = ACCELERATOR_READY

	else
		construction_state = ACCELERATOR_WIRED
		SCREWDRIVER_OPEN_PANEL_MESSAGE
	update_state()
	update_icon(UPDATE_ICON_STATE)

/obj/structure/particle_accelerator/wirecutter_act(mob/user, obj/item/I)
	if(construction_state != ACCELERATOR_WIRED)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	WIRECUTTER_SNIP_MESSAGE
	construction_state = ACCELERATOR_WRENCHED

/obj/structure/particle_accelerator/wrench_act(mob/user, obj/item/I)
	if(construction_state != ACCELERATOR_UNWRENCHED && construction_state != ACCELERATOR_WRENCHED)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(construction_state == ACCELERATOR_UNWRENCHED)
		set_anchored(TRUE)
		WRENCH_ANCHOR_MESSAGE
		construction_state = ACCELERATOR_WRENCHED
	else
		set_anchored(FALSE)
		WRENCH_UNANCHOR_MESSAGE
		construction_state = ACCELERATOR_UNWRENCHED
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/particle_accelerator
	name = "Particle Accelerator"
	desc = "Part of a Particle Accelerator."
	icon = 'icons/obj/engines_and_power/particle_accelerator.dmi'
	icon_state = "none"
	anchored = FALSE
	density = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	var/construction_state = 0
	var/active = 0
	var/reference = null
	var/powered = null
	var/strength = 0
	var/desc_holder = null


/obj/machinery/particle_accelerator/examine(mob/user)
	. = ..()
	. += "<span class='info'><b>Alt-Click</b> to rotate it.</span>"


/obj/machinery/particle_accelerator/verb/rotate()
	set name = "Rotate Clockwise"
	set category = "Object"
	set src in oview(1)

	rotate_accelerator(usr)

/obj/machinery/particle_accelerator/AltClick(mob/user)
	rotate_accelerator(user)


/obj/machinery/particle_accelerator/proc/rotate_accelerator(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	if(anchored)
		to_chat(user, "<span class='notice'>It is fastened to the floor!</span>")
		return
	dir = turn(dir, 270)


/obj/machinery/particle_accelerator/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(iscoil(I))
		add_fingerprint(user)
		var/obj/item/stack/cable_coil/coil = I
		if(construction_state != ACCELERATOR_WRENCHED)
			to_chat(user, span_warning("The [name] should be secured to the floor."))
			return ATTACK_CHAIN_PROCEED
		var/cached_sound = coil.usesound
		if(!coil.use(1))
			to_chat(user, span_warning("You need at least one length of the cable to proceed."))
			return ATTACK_CHAIN_PROCEED
		playsound(loc, cached_sound, 50, TRUE)
		user.visible_message(
			span_notice("[user] has wired [src]."),
			span_notice("You have wired [src]."),
		)
		construction_state = ACCELERATOR_WIRED
		update_icon()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/particle_accelerator/screwdriver_act(mob/user, obj/item/I)
	if(construction_state != ACCELERATOR_WIRED && construction_state != ACCELERATOR_READY)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(construction_state == ACCELERATOR_WIRED)
		SCREWDRIVER_CLOSE_PANEL_MESSAGE
		construction_state = ACCELERATOR_READY
		use_power = IDLE_POWER_USE
	else
		construction_state = ACCELERATOR_WIRED
		SCREWDRIVER_OPEN_PANEL_MESSAGE
		use_power = NO_POWER_USE
		update_state()
	update_icon()

/obj/machinery/particle_accelerator/wirecutter_act(mob/user, obj/item/I)
	if(construction_state != ACCELERATOR_WIRED)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	WIRECUTTER_SNIP_MESSAGE
	construction_state = ACCELERATOR_WRENCHED

/obj/machinery/particle_accelerator/wrench_act(mob/user, obj/item/I)
	if(construction_state != ACCELERATOR_UNWRENCHED && construction_state != ACCELERATOR_WRENCHED)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(construction_state == ACCELERATOR_UNWRENCHED)
		set_anchored(TRUE)
		WRENCH_ANCHOR_MESSAGE
		construction_state = ACCELERATOR_WRENCHED
	else
		set_anchored(FALSE)
		WRENCH_UNANCHOR_MESSAGE
		construction_state = ACCELERATOR_UNWRENCHED
	update_icon()


/obj/machinery/particle_accelerator/proc/update_state()
	return FALSE


#undef ACCELERATOR_UNWRENCHED
#undef ACCELERATOR_WRENCHED
#undef ACCELERATOR_WIRED
#undef ACCELERATOR_READY
