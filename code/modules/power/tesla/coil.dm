/obj/machinery/power/tesla_coil
	name = "tesla coil"
	desc = "For the union!"
	icon = 'icons/obj/engines_and_power/tesla/tesla_coil.dmi'
	icon_state = "coil0"
	anchored = FALSE
	density = TRUE

	// Executing a traitor caught releasing tesla was never this fun!
	can_buckle = TRUE
	buckle_lying = 0
	buckle_requires_restraints = TRUE

	///Flags of the zap that the coil releases when the wire is pulsed
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE
	///Multiplier for power conversion
	var/input_power_multiplier = 1
	///Cooldown between pulsed zaps
	var/zap_cooldown = 100
	///Reference to the last zap done
	var/last_zap = 0
	var/datum/wires/tesla_coil/wires = null

/obj/machinery/power/tesla_coil/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/tesla_coil(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	wires = new(src)
	RefreshParts()

/obj/machinery/power/tesla_coil/Destroy()
	SStgui.close_uis(wires)
	QDEL_NULL(wires)
	return ..()

/obj/machinery/power/tesla_coil/RefreshParts()
	var/power_multiplier = 0
	zap_cooldown = 100
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		power_multiplier += C.rating
		zap_cooldown -= (C.rating * 20)
	zap_cooldown = max(zap_cooldown, 10)
	input_power_multiplier = (0.85 * (power_multiplier * 0.25)) // Max out at 85% efficency.

/obj/machinery/power/tesla_coil/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("На дисплее состояния отображается: Выработка электроэнергии составляет [span_bold(input_power_multiplier*100)]%.<br>Интервал между ударами составляет [span_bold(zap_cooldown*0.1)] секунд.")


/obj/machinery/power/tesla_coil/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(issignaler(I))
		add_fingerprint(user)
		if(!panel_open)
			to_chat(user, span_warning("You should open the maintenance panel first."))
			return ATTACK_CHAIN_PROCEED
		wires.Interact(user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/power/tesla_coil/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_crowbar(user, I)

/obj/machinery/power/tesla_coil/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(panel_open)
		wires.Interact(user)

/obj/machinery/power/tesla_coil/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_screwdriver(user, "coil_open[anchored]", "coil[anchored]", I)

/obj/machinery/power/tesla_coil/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(panel_open)
		wires.Interact(user)

/obj/machinery/power/tesla_coil/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(default_unfasten_wrench(user, I))
		if(!anchored)
			disconnect_from_network()
		else
			connect_to_network()

/obj/machinery/power/tesla_coil/zap_act(power, zap_flags)
	if(!anchored || panel_open)
		return ..()

	ADD_TRAIT(src, TRAIT_BEING_SHOCKED, WAS_SHOCKED)
	addtimer(TRAIT_CALLBACK_REMOVE(src, TRAIT_BEING_SHOCKED, WAS_SHOCKED), 1 SECONDS)
	zap_buckle_check(power)

	if(zap_flags & ZAP_GENERATES_POWER)
		return power / 2

	var/power_produced = powernet ? power * input_power_multiplier : power
	add_avail(power_produced)
	flick("coilhit", src)
	return power - power_produced

/obj/machinery/power/tesla_coil/proc/zap()
	if((last_zap + zap_cooldown) > world.time || !powernet)
		return FALSE
	last_zap = world.time
	var/power = (powernet.avail) * 0.2 * input_power_multiplier  //Always always always use more then you output for the love of god
	power = min(surplus(), power) //Take the smaller of the two
	add_load(power)
	playsound(loc, 'sound/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
	tesla_zap(source = src, zap_range = 10, power = power, cutoff = 1e3, zap_flags = zap_flags)
	zap_buckle_check(power)

/obj/machinery/power/grounding_rod
	name = "grounding rod"
	desc = "Keeps an area from being fried by Edison's Bane."
	icon = 'icons/obj/engines_and_power/tesla/tesla_coil.dmi'
	icon_state = "grounding_rod0"
	anchored = FALSE
	density = TRUE

	can_buckle = TRUE
	buckle_lying = 0 // This is actually not TRUE/FALSE; this is an angle that gets multiplied by this number.
	buckle_requires_restraints = TRUE

/obj/machinery/power/grounding_rod/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/grounding_rod(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	RefreshParts()


/obj/machinery/power/grounding_rod/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/power/grounding_rod/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_screwdriver(user, "grounding_rod_open[anchored]", "grounding_rod[anchored]", I)

/obj/machinery/power/grounding_rod/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/machinery/power/grounding_rod/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_crowbar(user, I)

/obj/machinery/power/grounding_rod/zap_act(power, zap_flags)
	if(anchored && !panel_open)
		flick("grounding_rodhit", src)
		zap_buckle_check(power)
		//stored_energy += energy
		return FALSE
	else
		. = ..()
