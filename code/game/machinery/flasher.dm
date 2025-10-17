// It is a gizmo that flashes a small area

/obj/machinery/flasher
	name = "Mounted flash"
	desc = "A wall-mounted flashbulb device."
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
	/// How weakened targets are when flashed.
	var/strength = 10 SECONDS
	COOLDOWN_DECLARE(flash_cooldown)
	/// Duration of time between flashes.
	var/flash_cooldown_duration = 15 SECONDS


/obj/machinery/flasher/Initialize(mapload)
	. = ..()
	update_icon()


/obj/machinery/flasher/power_change(forced = FALSE)
	. = ..()
	if(.)
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
		underlays += emissive_appearance(icon, "[base_icon_state]_lightmask", src)


//Let the AI trigger them directly.
/obj/machinery/flasher/attack_ai(mob/user)
	if(disable || !COOLDOWN_FINISHED(src, flash_cooldown))
		return

	if(anchored)
		return flash()


/obj/machinery/flasher/attack_ghost(mob/user)
	if(anchored && user.can_advanced_admin_interact())
		return flash()


/obj/machinery/flasher/proc/flash()
	if(!powered())
		return

	if(disable || !COOLDOWN_FINISHED(src, flash_cooldown))
		return

	playsound(loc, 'sound/weapons/flash.ogg', 100, TRUE)
	flick("[base_icon_state]_flash", src)
	set_light(2, 1, COLOR_WHITE, TRUE)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, set_light_on), FALSE), 2)
	COOLDOWN_START(src, flash_cooldown, flash_cooldown_duration)
	use_power(1000)

	for(var/mob/living/L in viewers(src, null))
		if(get_dist(src, L) > range)
			continue

		if(L.flash_eyes(affect_silicon = TRUE))
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


/obj/machinery/flasher/portable //Portable version of the flasher. Only flashes when anchored
	name = "portable flasher"
	desc = "A portable flashing device. Wrench to activate and deactivate. Cannot detect slow movements."
	icon_state = "pflash1"
	base_icon_state = "pflash"
	strength = 8 SECONDS
	range = 1
	anchored = FALSE
	density = TRUE


/obj/machinery/flasher/portable/Initialize(mapload)
	. = ..()
	proximity_monitor = new(src, range)


/obj/machinery/flasher/portable/Destroy()
	. = ..()
	QDEL_NULL(proximity_monitor)


/obj/machinery/flasher/portable/HasProximity(atom/movable/proximity_check_mob)
	if(disable || !COOLDOWN_FINISHED(src, flash_cooldown))
		return

	if(iscarbon(proximity_check_mob))
		var/mob/living/carbon/proximity_carbon = proximity_check_mob
		if(proximity_carbon.m_intent != MOVE_INTENT_WALK && anchored)
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
	set_anchored(!anchored)
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

	for(var/obj/machinery/flasher/flasher in SSmachines.get_by_type(/obj/machinery/flasher))
		if(flasher.id == id)
			INVOKE_ASYNC(flasher, TYPE_PROC_REF(/obj/machinery/flasher, flash))

	addtimer(CALLBACK(src, PROC_REF(reactivate_button)), 5 SECONDS)


/obj/machinery/flasher_button/proc/reactivate_button()
	active = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/flasher_button/update_icon_state()
	icon_state = "launcher[active ? "act" : "btt"]"

