	///Atmos effect - Yes, you can make creatures that require plasma or co2 to survive. N2O is a trace gas and handled separately, hence why it isn't here. It'd be hard to add it. Hard and me don't mix (Yes, yes make all the dick jokes you want with that.) - Errorage
	///Leaving something at 0 means it's off - has no maximum.

	///This damage is taken when atmos doesn't fit all the requirements above.

/**
 * ## atmos requirements element!
 *
 * bespoke element that deals damage to the attached mob when the atmos requirements aren't satisfied
 */

/datum/element/atmos_requirements
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH_ON_HOST_DESTROY
	id_arg_index = 2
	/// An assoc list of "what atmos does this mob require to survive in"
	var/list/atmos_requirements
	/// How much (brute) damage we take from being in unsuitable atmos.
	var/unsuitable_atmos_damage

/datum/element/atmos_requirements/Attach(datum/target, list/atmos_requirements, unsuitable_atmos_damage)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.atmos_requirements = atmos_requirements
	src.unsuitable_atmos_damage = unsuitable_atmos_damage
	RegisterSignal(target, COMSIG_LIVING_HANDLE_BREATHING, PROC_REF(on_life))

/datum/element/atmos_requirements/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_LIVING_HANDLE_BREATHING)

/datum/element/atmos_requirements/proc/on_life(mob/living/target, datum/gas_mixture/environment)
	SIGNAL_HANDLER

	if(!environment)
		return

	var/atmos_suitable = TRUE

	var/tox = environment.toxins
	var/oxy = environment.oxygen
	var/n2 = environment.nitrogen
	var/co2 = environment.carbon_dioxide

	if(atmos_requirements["min_oxy"] && oxy < atmos_requirements["min_oxy"])
		atmos_suitable = FALSE
		target.throw_alert("not_enough_oxy", /atom/movable/screen/alert/not_enough_oxy)
	else if(atmos_requirements["max_oxy"] && oxy > atmos_requirements["max_oxy"])
		atmos_suitable = FALSE
		target.throw_alert("too_much_oxy", /atom/movable/screen/alert/too_much_oxy)
	else
		target.clear_alert("not_enough_oxy")
		target.clear_alert("too_much_oxy")


	if(atmos_requirements["min_tox"] && tox < atmos_requirements["min_tox"])
		atmos_suitable = FALSE
		target.throw_alert("not_enough_tox", /atom/movable/screen/alert/not_enough_tox)
	else if(atmos_requirements["max_tox"] && tox > atmos_requirements["max_tox"])
		atmos_suitable = FALSE
		target.throw_alert("too_much_tox", /atom/movable/screen/alert/too_much_tox)
	else
		target.clear_alert("too_much_tox")
		target.clear_alert("not_enough_tox")


	if(atmos_requirements["min_n2"] && n2 < atmos_requirements["min_n2"])
		atmos_suitable = FALSE
	else if(atmos_requirements["max_n2"] && n2 > atmos_requirements["max_n2"])
		atmos_suitable = FALSE


	if(atmos_requirements["min_co2"] && co2 < atmos_requirements["min_co2"])
		atmos_suitable = FALSE
	else if(atmos_requirements["max_co2"] && co2 > atmos_requirements["max_co2"])
		atmos_suitable = FALSE

	if(!atmos_suitable)
		target.adjustBruteLoss(unsuitable_atmos_damage)
