/datum/component/after_attacks_hub
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// List of after-attack effects for various items
	var/list/after_attacks = list()

/datum/component/after_attacks_hub/Initialize(...)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE


/datum/component/after_attacks_hub/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_after_attack))
	RegisterSignal(parent, COMSIG_ITEM_REGISTER_AFTERATTACK, PROC_REF(on_register_after_attack))
	RegisterSignal(parent, COMSIG_ITEM_UNREGISTER_AFTERATTACK, PROC_REF(on_unregister_after_attack))


/datum/component/after_attacks_hub/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_ITEM_AFTERATTACK, COMSIG_ITEM_REGISTER_AFTERATTACK,COMSIG_ITEM_UNREGISTER_AFTERATTACK))


/datum/component/after_attacks_hub/proc/on_after_attack(datum/source, mob/living/target, mob/living/user, proximity, params, status)
	SIGNAL_HANDLER
	for(var/sender in after_attacks)
		call(sender, after_attacks[sender])(source, target, user, proximity, params, status);


/datum/component/after_attacks_hub/proc/on_register_after_attack(datum/source, datum/sender, proc_ref)
	SIGNAL_HANDLER
	after_attacks[sender] = proc_ref


/datum/component/after_attacks_hub/proc/on_unregister_after_attack(datum/source, datum/sender)
	SIGNAL_HANDLER
	after_attacks -= sender
	if(!after_attacks.len)
		qdel(src)
