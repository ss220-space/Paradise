GLOBAL_LIST_EMPTY(rad_collectors)

/obj/machinery/power/rad_collector
	name = "radiation collector array"
	desc = "Устройство, преобразующее радиацию в полезную электрическую энергию с использованием плазмы."
	icon = 'icons/obj/engines_and_power/singularity.dmi'
	icon_state = "ca"
	anchored = FALSE
	density = TRUE
	req_access = list(ACCESS_ENGINE_EQUIP)
	max_integrity = 350
	integrity_failure = 80
	var/obj/item/tank/internals/plasma/loaded_tank = null
	var/last_power = 0
	var/active = FALSE
	var/locked = FALSE
	var/drainratio = 1

/obj/machinery/power/rad_collector/get_ru_names()
	return list(
		NOMINATIVE = "радиационный коллектор",
		GENITIVE = "радиационного коллектора",
		DATIVE = "радиационному коллектору",
		ACCUSATIVE = "радиационный коллектор",
		INSTRUMENTAL = "радиационным коллектором",
		PREPOSITIONAL = "радиационном коллекторе"
	)

/obj/machinery/power/rad_collector/Initialize(mapload)
	. = ..()
	GLOB.rad_collectors += src

/obj/machinery/power/rad_collector/Destroy()
	GLOB.rad_collectors -= src
	return ..()

/obj/machinery/power/rad_collector/process()
	if(!loaded_tank)
		return

	if(loaded_tank.air_contents.toxins() <= 0)
		investigate_log(span_red("out of fuel."), INVESTIGATE_ENGINE)
		loaded_tank.air_contents.set_toxins(0)
		playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
		eject()
	else
		loaded_tank.air_contents.set_toxins(max(0, loaded_tank.air_contents.toxins() - 0.001 * drainratio))

/obj/machinery/power/rad_collector/attack_hand(mob/user)
	if(..())
		return TRUE

	if(anchored)
		if(!locked)
			toggle_power()
			user.visible_message(
				"[user.name] turns the [name] [active ? "on" : "off"].",
				"You turn the [name] [active ? "on" : "off"]."
			)
			add_fingerprint(user)
			investigate_log("turned [active ? span_green("on") : span_red("off")] by [key_name_log(user)]. [loaded_tank ? "Fuel: [round(loaded_tank.air_contents.toxins() / 0.29)]%" : span_red("It is empty")].", INVESTIGATE_ENGINE)
		else
			to_chat(user, span_warning("The controls are locked!"))

/obj/machinery/power/rad_collector/attackby(obj/item/item, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(item, /obj/item/tank/internals/plasma))
		add_fingerprint(user)
		if(!anchored)
			to_chat(user, span_warning("The [name] should be secured to the floor first."))
			return ATTACK_CHAIN_PROCEED
		if(loaded_tank)
			to_chat(user, span_warning("The [name] already has a plasma tank loaded."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(item, src))
			return ..()
		to_chat(user, span_notice("You have loaded the plasma tank into [src]."))
		loaded_tank = item
		update_icon()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(item.GetID() || is_pda(item))
		add_fingerprint(user)
		if(!allowed(user))
			to_chat(user, span_warning("Access denied."))
			return ATTACK_CHAIN_PROCEED
		if(!active)
			locked = FALSE //just in case it somehow gets locked
			to_chat(user, span_warning("The controls can only be locked while [src] is active."))
			return ATTACK_CHAIN_PROCEED
		locked = !locked
		to_chat(user, span_notice("The controls are now [locked ? "locked." : "unlocked."]"))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/machinery/power/rad_collector/wrench_act(mob/living/user, obj/item/item)
	. = TRUE
	if(loaded_tank)
		add_fingerprint(user)
		to_chat(user, span_warning("You should remove the plasma tank first."))
		return .
	if(!item.use_tool(src, user, volume = item.tool_volume))
		return .
	set_anchored(!anchored)
	if(anchored)
		user.visible_message(
			span_notice("[user] has secured [src] to the floor."),
			span_notice("You have secured [src] to the floor."),
			span_hear("You hear a ratchet"),
		)
		connect_to_network()
	else
		user.visible_message(
			span_notice("[user] has unsecured [src] from floor."),
			span_notice("You have unsecured [src] from floor."),
			span_hear("You hear a ratchet"),
		)
		disconnect_from_network()

/obj/machinery/power/rad_collector/crowbar_act(mob/living/user, obj/item/item)
	. = TRUE
	add_fingerprint(user)
	if(!loaded_tank)
		to_chat(user, span_warning("The [name] has no loaded plasma tanks."))
		return .
	if(locked)
		to_chat(user, span_warning("The [name] is locked."))
		return .
	if(!item.use_tool(src, user, volume = item.tool_volume))
		return .
	eject(user)

/obj/machinery/power/rad_collector/multitool_act(mob/living/user, obj/item/item)
	. = TRUE
	if(!item.use_tool(src, user, volume = item.tool_volume))
		return .
	to_chat(user, span_notice("The [item.name] detects that [last_power]W were recently produced.."))

/obj/machinery/power/rad_collector/return_analyzable_air()
	if(loaded_tank)
		return loaded_tank.return_analyzable_air()
	return null

/obj/machinery/power/rad_collector/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(obj_flags & NODECONSTRUCT))
		eject()
		stat |= BROKEN

/obj/machinery/power/rad_collector/proc/eject(mob/user)
	locked = FALSE
	if(!loaded_tank)
		return
	loaded_tank.forceMove_turf()
	user?.put_in_hands(loaded_tank, ignore_anim = FALSE)
	loaded_tank = null
	if(active)
		toggle_power()
	else
		update_icon()

/obj/machinery/power/rad_collector/proc/receive_pulse(pulse_strength)
	if(loaded_tank && active)
		var/power_produced = 0
		power_produced = loaded_tank.air_contents.toxins() * pulse_strength * 20
		add_avail(power_produced)
		last_power = power_produced
		return

/obj/machinery/power/rad_collector/update_icon_state()
	icon_state = "ca[active ? "_on" : ""]"

/obj/machinery/power/rad_collector/update_overlays()
	. = ..()
	if(loaded_tank)
		add_overlay("ptank")
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		add_overlay(loaded_tank ? "on" : "error")

/obj/machinery/power/rad_collector/proc/toggle_power()
	active = !active
	if(active)
		flick("ca_active", src)
	else
		flick("ca_deactive", src)
	update_icon()

