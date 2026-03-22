/// Radiation needs to be over this amount to get power
#define RAD_COLLECTOR_THRESHOLD 80
/// Amount of joules created for each rad point over RAD_COLLECTOR_THRESHOLD
#define RAD_COLLECTOR_COEFFICIENT 200

GLOBAL_LIST_EMPTY(rad_collectors)

/obj/machinery/power/energy_accumulator/rad_collector
	name = "radiation collector array"
	desc = "Устройство, преобразующее радиацию в полезную электрическую энергию с использованием плазмы."
	icon = 'icons/obj/engines_and_power/singularity.dmi'
	icon_state = "ca"
	req_access = list(ACCESS_ENGINE_EQUIP)
	max_integrity = 350
	integrity_failure = 80
	///Stores the loaded tank instance
	var/obj/item/tank/internals/plasma/loaded_tank = null
	///Is the collector working?
	var/active = FALSE
	///Is the collector locked with an id?
	var/locked = FALSE
	///Amount of gas removed per tick
	var/drain_ratio = 0.5
	///Multiplier for the amount of gas removed per tick
	var/powerproduction_drain = 0.001

/obj/machinery/power/energy_accumulator/rad_collector/get_ru_names()
	return list(
		NOMINATIVE = "радиационный коллектор",
		GENITIVE = "радиационного коллектора",
		DATIVE = "радиационному коллектору",
		ACCUSATIVE = "радиационный коллектор",
		INSTRUMENTAL = "радиационным коллектором",
		PREPOSITIONAL = "радиационном коллекторе"
	)

/obj/machinery/power/energy_accumulator/rad_collector/anchored
	anchored = TRUE

/obj/machinery/power/energy_accumulator/rad_collector/Initialize(mapload)
	. = ..()
	GLOB.rad_collectors += src

/obj/machinery/power/energy_accumulator/rad_collector/Destroy()
	GLOB.rad_collectors -= src
	return ..()

/obj/machinery/power/energy_accumulator/rad_collector/process(seconds_per_tick)
	if(!loaded_tank)
		return

	if(!loaded_tank.air_contents.toxins())
		investigate_log(span_red("out of fuel."), INVESTIGATE_ENGINE)
		playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
		eject()
		return

	var/gasdrained = min(powerproduction_drain * drain_ratio, loaded_tank.air_contents.toxins())
	loaded_tank.air_contents.set_toxins(loaded_tank.air_contents.toxins() - gasdrained)

	return ..()

/obj/machinery/power/energy_accumulator/rad_collector/attack_hand(mob/user)
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

/obj/machinery/power/energy_accumulator/rad_collector/attackby(obj/item/item, mob/user, params)
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

/obj/machinery/power/energy_accumulator/rad_collector/wrench_act(mob/living/user, obj/item/item)
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

/obj/machinery/power/energy_accumulator/rad_collector/crowbar_act(mob/living/user, obj/item/item)
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

/obj/machinery/power/energy_accumulator/rad_collector/return_analyzable_air()
	if(loaded_tank)
		return loaded_tank.return_analyzable_air()
	return null

/obj/machinery/power/energy_accumulator/rad_collector/examine(mob/user)
	. = ..()
	if(!active)
		. += span_notice("<b>[src]'s display displays the words:</b> \"Power production mode. Please insert <b>Plasma</b>.\"")
	. += span_notice("[src]'s display states that it has stored <b>[display_energy(get_stored_joules())]</b>, and is processing <b>[display_power(calculate_sustainable_power(), convert = FALSE)]</b>.")

/obj/machinery/power/energy_accumulator/rad_collector/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(obj_flags & NODECONSTRUCT))
		eject()
		stat |= BROKEN

/obj/machinery/power/energy_accumulator/rad_collector/proc/receive_pulse(pulse_strength)
	if(!loaded_tank || !active || pulse_strength <= RAD_COLLECTOR_THRESHOLD)
		return
	stored_energy += energy_to_power((pulse_strength - RAD_COLLECTOR_THRESHOLD) * RAD_COLLECTOR_COEFFICIENT)

/obj/machinery/power/energy_accumulator/rad_collector/proc/eject(mob/user)
	locked = FALSE
	if(!loaded_tank)
		return

	loaded_tank.forceMove_turf()
	user?.put_in_hands(loaded_tank, ignore_anim = FALSE)
	loaded_tank = null

	if(active)
		toggle_power()
	else
		update_appearance()

/obj/machinery/power/energy_accumulator/rad_collector/update_icon_state()
	icon_state = "ca[active ? "_on" : ""]"

/obj/machinery/power/energy_accumulator/rad_collector/update_overlays()
	. = ..()
	if(loaded_tank)
		add_overlay("ptank")

	if(stat & (NOPOWER|BROKEN))
		return

	if(active)
		add_overlay(loaded_tank ? "on" : "error")

/obj/machinery/power/energy_accumulator/rad_collector/proc/toggle_power()
	active = !active
	if(active)
		flick("ca_active", src)
	else
		flick("ca_deactive", src)

	update_icon()

#undef RAD_COLLECTOR_THRESHOLD
#undef RAD_COLLECTOR_COEFFICIENT
