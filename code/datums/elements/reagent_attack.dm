/datum/element/reagent_attack
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH_ON_HOST_DESTROY
	id_arg_index = 2
	/// Which reagent we will inject
	var/reagent_id
	/// How much reagent we will inject
	var/reagent_amount
	/// Will we inject anyway or check can_inject
	var/piercing
	/// Limitation of our reagent in target
	var/reagent_limit
	/// Override zones over item or mob
	var/allowed_zones

/datum/element/reagent_attack/Attach(atom/source, reagent_id, reagent_amount, piercing, reagent_limit, list/allowed_zones)
	. = ..()

	if(!isitem(source) && !isliving(source))
		return ELEMENT_INCOMPATIBLE

	src.reagent_id = reagent_id
	src.reagent_amount = reagent_amount
	src.piercing = piercing
	src.reagent_limit = reagent_limit
	src.allowed_zones = allowed_zones

	if(isitem(source))
		RegisterSignal(source, COMSIG_ITEM_ATTACK, PROC_REF(item_attack))

	if(isliving(source))
		RegisterSignal(source, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(mob_attack))

/datum/element/reagent_attack/Detach(atom/source)
	. = ..()

	if(isitem(source))
		UnregisterSignal(source, COMSIG_ITEM_ATTACK)

	if(isliving(source))
		UnregisterSignal(source, COMSIG_LIVING_UNARMED_ATTACK)

/datum/element/reagent_attack/proc/item_attack(mob/target, mob/living/user, params, def_zone)
	SIGNAL_HANDLER

	var/picked_zone = allowed_zones ? pick(allowed_zones) : def_zone
	if(!can_inject(target, picked_zone))
		return

	INVOKE_ASYNC(src, PROC_REF(inject), user, target, picked_zone)

/datum/element/reagent_attack/proc/mob_attack(datum/source, mob/target, proximity_flag)
	SIGNAL_HANDLER

	if(!proximity_flag)
		return
		
	var/mob/mob = source
	var/picked_zone = allowed_zones ? pick(allowed_zones) : mob.zone_selected
	if(!can_inject(target, picked_zone))
		return

	INVOKE_ASYNC(src, PROC_REF(inject), mob, target, picked_zone)

/datum/element/reagent_attack/proc/can_inject(mob/living/carbon/target, target_zone)
	if(!istype(target)) 
		return FALSE

	if(reagent_limit && target.reagents.has_reagent(reagent_id, reagent_limit))
		return FALSE

	if(!piercing && !target.can_inject(null, FALSE, target_zone, FALSE))
		return FALSE

	return TRUE

/datum/element/reagent_attack/proc/inject(atom/source, mob/living/carbon/target, target_zone)
	if(reagent_id && reagent_amount)
		target.reagents.add_reagent(reagent_id, reagent_amount)
		
	SEND_SIGNAL(source, COMSIG_REAGENT_INJECTED, target, reagent_id, reagent_amount, target_zone) // custom injections!
	return

