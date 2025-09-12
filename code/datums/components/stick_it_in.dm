#define MELEE_BONUS_EMBED 2

/datum/component/stick_it_in

/datum/component/stick_it_in/Initialize(...)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	
/datum/component/stick_it_in/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(HarmAct))

/datum/component/stick_it_in/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK)

/datum/component/stick_it_in/proc/HarmAct(datum/source, mob/living/target, mob/living/user, params, def_zone)
	SIGNAL_HANDLER

	if(!ishuman(target))
		return NONE

	if(!(user.a_intent == INTENT_DISARM))
		return NONE
	var/mob/living/carbon/human/target_human = target
	var/obj/item/parent_item = parent

	var/armor_level = target.run_armor_check(def_zone, MELEE)
	var/embed_chance = (parent_item.embed_chance * MELEE_BONUS_EMBED) - armor_level

	if(isthrowingmatart(target_human?.mind?.martial_art))
		embed_chance = embed_chance * 2

	if(armor_level > 50)
		embed_chance = 0
	
	if(prob(embed_chance))
		target_human.embed_item_inside(parent, user.zone_selected)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	return NONE
