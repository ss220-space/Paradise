/datum/component/after_attacks_hub
	/// List of after-attack effects for various items
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/list/after_attacks_procs = list()
	var/list/after_attacks = list()

/datum/component/after_attacks_hub/Initialize(...)
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_after_attack))
	RegisterSignal(parent, COMSIG_ITEM_REGISTER_AFTERATTACK, PROC_REF(on_register_after_attack))
	RegisterSignal(parent, COMSIG_ITEM_UNREGISTER_AFTERATTACK, PROC_REF(on_unregister_after_attack))

/datum/component/after_attacks_hub/Destroy(force)
	UnregisterSignal(parent, COMSIG_ITEM_AFTERATTACK)
	UnregisterSignal(parent, COMSIG_ITEM_REGISTER_AFTERATTACK)
	UnregisterSignal(parent, COMSIG_ITEM_UNREGISTER_AFTERATTACK)
	. = ..()

/datum/component/after_attacks_hub/proc/on_after_attack(datum/source, mob/living/target, mob/living/user, proximity, params, status)
	SIGNAL_HANDLER
	for(var/ref in after_attacks_procs)
		call(after_attacks[ref], ref)(source, target, user, proximity, params, status);


/datum/component/after_attacks_hub/proc/on_register_after_attack(datum/source, datum/sender, proc_ref)
	SIGNAL_HANDLER
	after_attacks_procs |= proc_ref
	after_attacks[proc_ref] = sender


/datum/component/after_attacks_hub/proc/on_unregister_after_attack(datum/source, proc_ref)
	SIGNAL_HANDLER
	after_attacks_procs -= proc_ref
	after_attacks -= proc_ref
