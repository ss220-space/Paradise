/**
 * Ancestor class for various post-attack effects. Requires /datum/component/after_attacks_hub for on_attack proc work
 */

/datum/element/after_attack
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE
	/// Does the effect differ between a block and a successful attack
	var/has_block_different_effect = TRUE


/datum/element/after_attack/Attach(datum/target)
	. = ..()
	SEND_SIGNAL(target, COMSIG_ITEM_REGISTER_AFTERATTACK, src, PROC_REF(on_attack))

/datum/element/after_attack/Detach(datum/source, force)
	SEND_SIGNAL(source, COMSIG_ITEM_UNREGISTER_AFTERATTACK, PROC_REF(on_attack))
	. = ..()

/datum/element/after_attack/proc/on_attack(datum/source, mob/living/target, mob/living/user, proximity, params, status)
	SIGNAL_HANDLER
	if(ATTACK_CHAIN_SUCCESS_CHECK(status) || !has_block_different_effect)
		on_success(source, target, user, proximity, params)
		return
	on_block(source, target, user, proximity, params)
	return

/datum/element/after_attack/proc/on_success(datum/source, mob/living/target, mob/living/user, proximity, params)

/datum/element/after_attack/proc/on_block(datum/source, mob/living/target, mob/living/user, proximity, params)
