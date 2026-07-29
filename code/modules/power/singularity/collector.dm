/// Radiation needs to be over this amount to get power
#define RAD_COLLECTOR_THRESHOLD 80
/// Amount of joules created for each rad point over RAD_COLLECTOR_THRESHOLD
#define RAD_COLLECTOR_COEFFICIENT 1200
/// Toxin moles in a fully filled plasma tank divided by 100; used to display fuel as a percentage.
#define RAD_COLLECTOR_FUEL_PERCENT_DIVISOR 0.3

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
	/// Fraction of the base plasma drain actually applied each tick (lower = leaner burn, longer fuel).
	var/drain_ratio = 0.5
	/// Base plasma (moles) burned per second, before drain_ratio is applied.
	var/powerproduction_drain = 0.02
	/// Share (0..1) of the wanted plasma burn we could actually supply last tick. Scales power output.
	var/last_drain_efficiency = 0

/obj/machinery/power/energy_accumulator/rad_collector/get_ru_names()
	return alist(
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
	// Only an active collector burns fuel; an idle one just keeps releasing whatever it already stored.
	if(!active || !loaded_tank)
		last_drain_efficiency = 0
		return ..()

	var/available_plasma = loaded_tank.air_contents.toxins()
	if(!available_plasma)
		investigate_log(span_red("out of fuel."), INVESTIGATE_ENGINE)
		playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
		eject()
		last_drain_efficiency = 0
		return ..()

	// Burn plasma at a steady rate; efficiency is the share of the wanted burn we could actually
	// supply this tick, so output stays full while fuelled and tapers off as the tank runs dry.
	var/wanted_drain = powerproduction_drain * drain_ratio * seconds_per_tick
	var/gas_drained = min(wanted_drain, available_plasma)
	loaded_tank.air_contents.set_toxins(available_plasma - gas_drained)
	last_drain_efficiency = wanted_drain ? gas_drained / wanted_drain : 0

	return ..()

/obj/machinery/power/energy_accumulator/rad_collector/attack_hand(mob/user)
	if(..())
		return TRUE
	if(!anchored)
		return
	if(locked)
		to_chat(user, span_warning("The controls are locked!"))
		return
	toggle_power()
	user.visible_message(
		"[user.name] turns the [name] [active ? "on" : "off"].",
		"You turn the [name] [active ? "on" : "off"]."
	)
	add_fingerprint(user)
	investigate_log("turned [active ? span_green("on") : span_red("off")] by [key_name_log(user)]. [loaded_tank ? "Fuel: [round(loaded_tank.air_contents.toxins() / RAD_COLLECTOR_FUEL_PERCENT_DIVISOR)]%" : span_red("It is empty")].", INVESTIGATE_ENGINE)

/obj/machinery/power/energy_accumulator/rad_collector/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.a_intent == INTENT_HARM)
		return NONE

	if(istype(tool, /obj/item/tank/internals/plasma))
		add_fingerprint(user)
		if(!anchored)
			to_chat(user, span_warning("The [name] should be secured to the floor first."))
			return ITEM_INTERACT_BLOCKING
		if(loaded_tank)
			to_chat(user, span_warning("The [name] already has a plasma tank loaded."))
			return ITEM_INTERACT_BLOCKING
		if(!user.drop_transfer_item_to_loc(tool, src))
			return NONE
		to_chat(user, span_notice("You have loaded the plasma tank into [src]."))
		loaded_tank = tool
		update_icon()
		return ITEM_INTERACT_SUCCESS

	if(tool.GetID() || is_pda(tool))
		add_fingerprint(user)
		if(!allowed(user))
			to_chat(user, span_warning("Access denied."))
			return ITEM_INTERACT_BLOCKING
		if(!active)
			locked = FALSE //just in case it somehow gets locked
			to_chat(user, span_warning("The controls can only be locked while [src] is active."))
			return ITEM_INTERACT_BLOCKING
		locked = !locked
		to_chat(user, span_notice("The controls are now [locked ? "locked." : "unlocked."]"))
		return ITEM_INTERACT_SUCCESS

	return NONE

/obj/machinery/power/energy_accumulator/rad_collector/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(loaded_tank)
		add_fingerprint(user)
		to_chat(user, span_warning("You should remove the plasma tank first."))
		return .
	if(!tool.use_tool(src, user, volume = tool.tool_volume))
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

/obj/machinery/power/energy_accumulator/rad_collector/crowbar_act(mob/living/user, obj/item/tool)
	. = TRUE
	add_fingerprint(user)
	if(!loaded_tank)
		to_chat(user, span_warning("The [name] has no loaded plasma tanks."))
		return .
	if(locked)
		to_chat(user, span_warning("The [name] is locked."))
		return .
	if(!tool.use_tool(src, user, volume = tool.tool_volume))
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
	// Output scales with how energetic the singularity pulse is and with how much plasma we are burning.
	var/rads_above_threshold = pulse_strength - RAD_COLLECTOR_THRESHOLD
	stored_energy += energy_to_power(rads_above_threshold * RAD_COLLECTOR_COEFFICIENT * last_drain_efficiency)

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
		. += "ptank"

	if(stat & (NOPOWER|BROKEN))
		return

	if(active)
		. += loaded_tank ? "on" : "error"

/obj/machinery/power/energy_accumulator/rad_collector/proc/toggle_power()
	active = !active
	if(active)
		flick("ca_active", src)
	else
		flick("ca_deactive", src)

	update_icon()

#undef RAD_COLLECTOR_THRESHOLD
#undef RAD_COLLECTOR_COEFFICIENT
#undef RAD_COLLECTOR_FUEL_PERCENT_DIVISOR
