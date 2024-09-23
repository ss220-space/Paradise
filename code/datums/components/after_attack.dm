/**
 * Ancestor class for various post-attack effects. Requires /datum/element/after_attacks_hub to work
 */

/datum/component/after_attack
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Does the effect differ between a block and a successful attack
	var/has_block_different_effect = TRUE

/datum/component/after_attack/Initialize()
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/after_attack/_JoinParent()
	. = ..()
	parent.datum_components -= /datum/component/after_attack

/datum/component/after_attack/RegisterWithParent()
	SEND_SIGNAL(parent, COMSIG_ITEM_REGISTER_AFTERATTACK, src)
	RegisterSignal(src, COMSIG_ITEM_AFTERATTACK_IF_SUCCESS, PROC_REF(on_success))
	RegisterSignal(src, COMSIG_ITEM_AFTERATTACK_IF_BLOCKED, (has_block_different_effect)? PROC_REF(on_blocked) : PROC_REF(on_success))

/datum/component/after_attack/UnregisterFromParent()
	UnregisterSignal(src, COMSIG_ITEM_AFTERATTACK_IF_SUCCESS)
	UnregisterSignal(src, COMSIG_ITEM_AFTERATTACK_IF_BLOCKED)
	SEND_SIGNAL(parent, COMSIG_ITEM_UNREGISTER_AFTERATTACK, src)

/datum/component/after_attack/proc/on_success(datum/source, mob/living/target, mob/living/user, proximity, params)
	SIGNAL_HANDLER
	return

/datum/component/after_attack/proc/on_blocked(datum/source, mob/living/target, mob/living/user, proximity, params)
	SIGNAL_HANDLER
	return
