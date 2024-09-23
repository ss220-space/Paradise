/datum/element/after_attacks_hub
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE
	var/list/after_attacks_effects = list()

/datum/element/after_attacks_hub/Attach(datum/target)
	. = ..()
	RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_after_attack))
	RegisterSignal(target, COMSIG_ITEM_REGISTER_AFTERATTACK, PROC_REF(on_register_after_attack))
	RegisterSignal(target, COMSIG_ITEM_UNREGISTER_AFTERATTACK, PROC_REF(on_unregister_after_attack))

/datum/element/after_attacks_hub/Detach(datum/source, force)
	UnregisterSignal(source, COMSIG_ITEM_AFTERATTACK)
	UnregisterSignal(source, COMSIG_ITEM_REGISTER_AFTERATTACK)
	UnregisterSignal(source, COMSIG_ITEM_UNREGISTER_AFTERATTACK)
	. = ..()

/datum/element/after_attacks_hub/proc/on_after_attack(datum/source, mob/living/target, mob/living/user, proximity, params, status)
	SIGNAL_HANDLER
	var/list/effects_list = after_attacks_effects[source]
	if(!effects_list || !effects_list.len)
		return
	var/signal_type = (ATTACK_CHAIN_SUCCESS_CHECK(status))? COMSIG_ITEM_AFTERATTACK_IF_SUCCESS : COMSIG_ITEM_AFTERATTACK_IF_BLOCKED
	for(var/datum/effect in effects_list)
		SEND_SIGNAL(effect, signal_type, target, user, proximity, params)



/datum/element/after_attacks_hub/proc/on_register_after_attack(datum/source, datum/component)
	SIGNAL_HANDLER
	var/list/effects_list = after_attacks_effects[source]
	if(!effects_list)
		after_attacks_effects[source] = list()
		effects_list = after_attacks_effects[source]
	effects_list |= component


/datum/element/after_attacks_hub/proc/on_unregister_after_attack(datum/source, datum/component)
	SIGNAL_HANDLER
	var/list/effects_list = after_attacks_effects[source]
	if(!effects_list || !effects_list.len)
		return
	effects_list -= component
