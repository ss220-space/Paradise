/**
 * Sharpening component
 *
 * Makes an item sharpenable with a whetstone
 *
 */
/datum/component/delimb
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/delimb_chance = 0

/datum/component/delimb/Initialize(delimb_chance = 0)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.delimb_chance = delimb_chance

/datum/component/delimb/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_IMPACT_ZONE, PROC_REF(on_item_throw_impact))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(on_item_attack))

/datum/component/delimb/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_IMPACT_ZONE, COMSIG_ITEM_ATTACK))

/datum/component/delimb/proc/on_item_throw_impact(obj/item/item, mob/target, zone, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(zone == BODY_ZONE_HEAD)
		delimb_chance /= 2
	if(zone == BODY_ZONE_CHEST)
		delimb_chance = 0
	INVOKE_ASYNC(src, PROC_REF(delimb_zone), target, zone)
	qdel(src)

/datum/component/delimb/proc/on_item_attack(obj/item/item, mob/living/target, mob/living/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(delimb_zone), target, user.zone_selected)
	qdel(src)

/datum/component/delimb/proc/delimb_zone(mob/living/target, zone)
	if(prob(delimb_chance))
		var/obj/item/organ/external/affecting = target.get_organ(check_zone(zone))
		if(affecting && !affecting.cannot_amputate)
			affecting.droplimb(FALSE, DROPLIMB_SHARP)
