/datum/component/stick_it_in

/datum/component/stick_it_in/Initialize(...)
	if(!isitem(parent) || !(HAS_TRAIT(parent, TRAIT_EMBED_MELEE)))
		return COMPONENT_INCOMPATIBLE
	
/datum/component/stick_it_in/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(HarmAct))

/datum/component/stick_it_in/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK)

/datum/component/stick_it_in/proc/HarmAct(datum/source, mob/living/target, mob/living/user, params, def_zone)
	SIGNAL_HANDLER

	if(!ishuman(target) || !HAS_TRAIT(parent, TRAIT_EMBED_MELEE))
		return NONE
	if(!(user.a_intent == INTENT_DISARM))
		return NONE
	var/mob/living/carbon/human/H = target
	if(!(prob(40) || isthrowingmatart(H?.mind?.martial_art)))
		return NONE
	H.embed_item_inside(parent, user.zone_selected)
	
	return COMPONENT_CANCEL_ATTACK_CHAIN
	
