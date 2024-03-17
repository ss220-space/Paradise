// It is a gizmo that flashes a small area

/obj/machinery/flasher
	name = "Mounted flash"
	desc = "A wall-mounted flashbulb device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mflash1"
	base_icon_state = "mflash"
	max_integrity = 250
	integrity_failure = 100
	damage_deflection = 10
	anchored = TRUE
	var/id = null
	/// Area of effect, this is roughly the size of brig cell.
	var/range = 2
	var/disable = FALSE
	/// Don't want it getting spammed like regular flashes
	var/last_flash = 0
	/// How weakened targets are when flashed.
	var/strength = 10 SECONDS


/obj/machinery/flasher/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/flasher/portable //Portable version of the flasher. Only flashes when anchored
	name = "portable flasher"
	desc = "A portable flashing device. Wrench to activate and deactivate. Cannot detect slow movements."
	icon_state = "pflash1"
	base_icon_state = "pflash"
	strength = 8 SECONDS
	anchored = FALSE
	density = TRUE

/obj/machinery/flasher/portable/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/proximity_monitor)


/obj/machinery/flasher/power_change(forced = FALSE)
	if(!..())
		return
	if(stat & NOPOWER)
		set_light_on(FALSE)
	else
		set_light(1, LIGHTING_MINIMUM_POWER)
	update_icon()


/obj/machinery/flasher/update_icon_state()
	. = ..()
	if((stat & NOPOWER) || !anchored)
		icon_state = "[base_icon_state]1-p"
	else
		icon_state = "[base_icon_state]1"


/obj/machinery/flasher/update_overlays()
	. = ..()
	underlays.Cut()
	if(stat & NOPOWER)
		return

	if(anchored)
		. += "[base_icon_state]-s"
		underlays += emissive_appearance(icon, "[base_icon_state]_lightmask")


//Let the AI trigger them directly.
/obj/machinery/flasher/attack_ai(mob/user)
	if(anchored)
		return flash()

/obj/machinery/flasher/attack_ghost(mob/user)
	if(anchored && user.can_advanced_admin_interact())
		return flash()

/obj/machinery/flasher/proc/flash()
	if(!(powered()))
		return

	if((disable) || (last_flash && world.time < last_flash + 150))
		return

	playsound(loc, 'sound/weapons/flash.ogg', 100, 1)
	flick("[base_icon_state]_flash", src)
	set_light(2, 1, COLOR_WHITE)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, set_light), 0), 2)
	last_flash = world.time
	use_power(1000)

	for(var/mob/living/L in viewers(src, null))
		if(get_dist(src, L) > range)
			continue

		if(L.flash_eyes(affect_silicon = 1))
			L.Weaken(strength)
			if(L.weakeyes)
				L.Weaken(strength * 1.5)
				L.visible_message(span_disarm("<b>[L]</b> gasps and shields [L.p_their()] eyes!"))

/obj/machinery/flasher/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(prob(75/severity))
		flash()
	..(severity)

/obj/machinery/flasher/portable/HasProximity(atom/movable/AM)
	if((disable) || (last_flash && world.time < last_flash + 150))
		return

	if(istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		if((M.m_intent != MOVE_INTENT_WALK) && (anchored))
			flash()

//Don't want to render prison breaks impossible
/obj/machinery/flasher/portable/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	disable = !disable
	if(disable)
		user.visible_message(span_warning("[user] has disconnected [src]'s flashbulb!"), span_warning("You disconnect [src]'s flashbulb!"))
	if(!disable)
		user.visible_message(span_warning("[user] has connected [src]'s flashbulb!"), span_warning("You connect [src]'s flashbulb!"))

/obj/machinery/flasher/portable/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	anchored = !anchored
	if(anchored)
		WRENCH_ANCHOR_MESSAGE
	else
		WRENCH_UNANCHOR_MESSAGE
	update_icon()

// Flasher button
/obj/machinery/flasher_button
	name = "flasher button"
	desc = "A remote control switch for a mounted flasher."
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	var/id = null
	var/active = 0
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/flasher_button/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/flasher_button/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)


/obj/machinery/flasher_button/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	add_fingerprint(user)
	use_power(5)

	active = TRUE
	update_icon(UPDATE_ICON_STATE)

	for(var/obj/machinery/flasher/flasher in GLOB.machines)
		if(flasher.id == id)
			INVOKE_ASYNC(flasher, TYPE_PROC_REF(/obj/machinery/flasher, flash))

	addtimer(CALLBACK(src, PROC_REF(reactivate_button)), 5 SECONDS)


/obj/machinery/flasher_button/proc/reactivate_button()
	active = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/flasher_button/update_icon_state()
	icon_state = "launcher[active ? "act" : "btt"]"

