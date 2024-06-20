/obj/item/tank/jetpack
	name = "Jetpack (Empty)"
	desc = "A tank of compressed gas for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	w_class = WEIGHT_CLASS_BULKY
	item_state = "jetpack"
	distribute_pressure = ONE_ATMOSPHERE * O2STANDARD
	actions_types = list(/datum/action/item_action/set_internals, /datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	var/gas_type = "oxygen"
	var/on = FALSE
	var/stabilize = FALSE
	var/skip_trails = FALSE
	var/thrust_callback


/obj/item/tank/jetpack/Initialize(mapload)
	. = ..()
	thrust_callback = CALLBACK(src, PROC_REF(allow_thrust), 0.01)
	configure_jetpack(stabilize, skip_trails)


/obj/item/tank/jetpack/Destroy()
	thrust_callback = null
	return ..()


/**
 * Configures/re-configures the jetpack component
 *
 * Arguments:
 * * stabilize - if `TRUE` jetpack owner will not be affected by newtonian movement
 * * skip_trails - if `TRUE` skips ion trails visualization
 */
/obj/item/tank/jetpack/proc/configure_jetpack(stabilize, skip_trails)
	if(!isnull(stabilize))
		src.stabilize = stabilize
	if(!isnull(skip_trails))
		src.skip_trails = skip_trails
	AddComponent(
		/datum/component/jetpack, \
		src.stabilize, \
		COMSIG_JETPACK_ACTIVATED, \
		COMSIG_JETPACK_DEACTIVATED, \
		JETPACK_ACTIVATION_FAILED, \
		thrust_callback, \
		/datum/effect_system/trail_follow/ion, \
		src.skip_trails \
	)


/obj/item/tank/jetpack/populate_gas()
	if(!gas_type)
		return
	switch(gas_type)
		if("oxygen")
			air_contents.oxygen = ((6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))
		if("carbon dioxide")
			air_contents.carbon_dioxide = ((6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))


/obj/item/tank/jetpack/item_action_slot_check(slot, mob/user)
	if(slot & ITEM_SLOT_BACK)
		return TRUE


/obj/item/tank/jetpack/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(on && !(slot & ITEM_SLOT_BACK))
		turn_off(user)


/obj/item/tank/jetpack/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	if(on)
		turn_off(user)


/obj/item/tank/jetpack/ui_action_click(mob/user, action, leftclick)
	if(istype(action, /datum/action/item_action/toggle_jetpack))
		cycle(user)
	else if(istype(action, /datum/action/item_action/jetpack_stabilization))
		if(on)
			configure_jetpack(!stabilize)
			to_chat(user, span_notice("You turn the jetpack stabilization [stabilize ? "on" : "off"]."))
			for(var/datum/action/existing as anything in actions)
				existing.UpdateButtonIcon()
	else
		toggle_internals(user)


/obj/item/tank/jetpack/proc/cycle(mob/user)
	if(user.incapacitated())
		return

	if(!on)
		if(turn_on(user))
			to_chat(user, span_notice("You turn the jetpack on."))
		else
			to_chat(user, span_notice("You fail to turn the jetpack on."))
			return
	else
		turn_off(user)
		to_chat(user, span_notice("You turn the jetpack off."))

	for(var/datum/action/action as anything in actions)
		action.UpdateButtonIcon()


/obj/item/tank/jetpack/update_icon_state()
	icon_state = "[initial(icon_state)][on ? "-on" : ""]"


/obj/item/tank/jetpack/proc/turn_on(mob/user)
	if(SEND_SIGNAL(src, COMSIG_JETPACK_ACTIVATED, user) & JETPACK_ACTIVATION_FAILED)
		return FALSE
	on = TRUE
	update_icon(UPDATE_ICON_STATE)
	return TRUE


/obj/item/tank/jetpack/proc/turn_off(mob/user)
	SEND_SIGNAL(src, COMSIG_JETPACK_DEACTIVATED, user)
	on = FALSE
	update_icon(UPDATE_ICON_STATE)


/// num argument is set on jetpack init, in a CALLBACK
/// use_fuel argument comes from an attached component (used to check if we can start and skips fuel usage)
/obj/item/tank/jetpack/proc/allow_thrust(num, use_fuel = TRUE)
	var/mob/user = get_owner()
	if(!user)
		return FALSE

	if(num < 0.005 || air_contents.total_moles() < num)
		turn_off(user)
		return FALSE

	// We've got the gas, it's chill
	if(!use_fuel)
		return TRUE

	var/datum/gas_mixture/removed = remove_air(num)
	if(removed.total_moles() < 0.005)
		turn_off(user)
		return FALSE

	var/turf/T = get_turf(src)
	T.assume_air(removed)
	return TRUE


/obj/item/tank/jetpack/proc/get_owner()
	if(ishuman(loc))
		return loc


/obj/item/tank/jetpack/improvised
	name = "improvised jetpack"
	desc = "A jetpack made from two air tanks, a fire extinguisher and some atmospherics equipment. It doesn't look like it can hold much."
	icon_state = "jetpack-improvised"
	item_state = "jetpack-improvised"
	volume = 20 //normal jetpacks have 70 volume
	gas_type = null //it starts empty


/obj/item/tank/jetpack/improvised/allow_thrust(num, use_fuel = TRUE)
	var/mob/user = get_owner()
	if(!user)
		return FALSE

	if(rand(0, 250) == 0)
		to_chat(user, span_notice("You feel your jetpack's engines cut out."))
		turn_off(user)
		return FALSE

	return ..()


/obj/item/tank/jetpack/void
	name = "Void Jetpack (Oxygen)"
	desc = "It works well in a void."
	icon_state = "jetpack-void"
	item_state =  "jetpack-void"

/obj/item/tank/jetpack/void/grey
	name = "Void Jetpack (Oxygen)"
	icon_state = "jetpack-void-grey"

/obj/item/tank/jetpack/void/gold
	name = "Retro Jetpack (Oxygen)"
	icon_state = "jetpack-void-gold"

/obj/item/tank/jetpack/oxygen
	name = "Jetpack (Oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	item_state = "jetpack"

/obj/item/tank/jetpack/oxygen/harness
	name = "jet harness (oxygen)"
	desc = "A lightweight tactical harness, used by those who don't want to be weighed down by traditional jetpacks."
	icon_state = "jetpack-mini"
	item_state = "jetpack-mini"
	volume = 40
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/tank/jetpack/oxygen/captain
	name = "Captain's jetpack"
	desc = "A compact, lightweight jetpack containing a high amount of compressed oxygen."
	icon_state = "jetpack-captain"
	item_state = "jetpack-captain"
	volume = 90
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //steal objective items are hard to destroy.

/obj/item/tank/jetpack/oxygen/security
	name = "security jetpack (oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas by security forces."
	icon_state = "jetpack-sec"
	item_state = "jetpack-sec"

/obj/item/tank/jetpack/carbondioxide
	name = "Jetpack (Carbon Dioxide)"
	desc = "A tank of compressed carbon dioxide for use as propulsion in zero-gravity areas. Painted black to indicate that it should not be used as a source for internals."
	distribute_pressure = 0
	icon_state = "jetpack-black"
	item_state =  "jetpack-black"
	gas_type = "carbon dioxide"

/obj/item/tank/jetpack/suit
	name = "hardsuit jetpack upgrade"
	desc = "A modular, compact set of thrusters designed to integrate with a hardsuit. It is fueled by a tank inserted into the suit's storage compartment."
	icon_state = "jetpack-mining"
	item_state = "jetpack-black"
	origin_tech = "materials=4;magnets=4;engineering=5"
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	volume = 1
	slot_flags = NONE
	gas_type = null
	fillable = FALSE
	var/datum/gas_mixture/temp_air_contents
	var/obj/item/tank/internals/tank
	var/obj/item/clothing/suit/space/our_suit


/obj/item/tank/jetpack/suit/Initialize(mapload)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	temp_air_contents = air_contents


/obj/item/tank/jetpack/suit/Destroy()
	our_suit = null
	tank = null
	temp_air_contents = null
	return ..()


/obj/item/tank/jetpack/suit/item_action_slot_check(slot, mob/user)
	return TRUE


/obj/item/tank/jetpack/suit/get_owner()
	if(our_suit && ishuman(our_suit.loc))
		return our_suit.loc


/obj/item/tank/jetpack/suit/attack_self()
	return


/obj/item/tank/jetpack/suit/examine(mob/user)
	. = ..(user, show_contents_info = FALSE)


/obj/item/tank/jetpack/suit/allow_thrust(num, use_fuel = TRUE)
	if(!our_suit)
		return FALSE
	if(!istype(tank, /obj/item/tank))
		return FALSE
	return ..()


/obj/item/tank/jetpack/suit/turn_on(mob/living/carbon/human/user)
	if(!ishuman(user))
		return FALSE
	if(!our_suit)
		to_chat(user, span_warning("[src] must be connected to your suit!"))
		return FALSE
	if(!istype(user.s_store, /obj/item/tank))
		to_chat(user, span_warning("You need a tank in your suit storage!"))
		return FALSE
	tank = user.s_store
	air_contents = tank.air_contents
	START_PROCESSING(SSobj, src)
	return ..()


/obj/item/tank/jetpack/suit/turn_off(mob/living/carbon/human/user)
	tank = null
	air_contents = temp_air_contents
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/tank/jetpack/suit/ninja
	name = "ninja jetpack upgrade"
	desc = "A modular, compact set of thrusters designed to integrate with ninja's suit. It is fueled by a tank inserted into the suit's storage compartment."
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "ninja_jetpack"
	actions_types = list(/datum/action/item_action/toggle_jetpack/ninja, /datum/action/item_action/jetpack_stabilization/ninja)


/obj/item/tank/jetpack/suit/ninja/allow_thrust(num, use_fuel = TRUE)
	var/mob/user = get_owner()
	if(!user)
		return FALSE
	if(!skip_trails && user.alpha == NINJA_ALPHA_INVISIBILITY)
		configure_jetpack(skip_trails = TRUE)
	else if(skip_trails && user.alpha != NINJA_ALPHA_INVISIBILITY)
		configure_jetpack(skip_trails = FALSE)
	return ..()


