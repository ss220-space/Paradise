/**
 * Sharpening component
 *
 * Makes an item sharpenable with a whetstone
 *
 */
/datum/component/sharpening
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/damage_increase

/datum/component/sharpening/Initialize(damage_increase = 0)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.damage_increase = damage_increase

/datum/component/sharpening/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_SHARPEN_ACT, PROC_REF(on_sharpen))

/datum/component/sharpening/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_SHARPEN_ACT))

/datum/component/sharpening/proc/on_sharpen(obj/item/item, amount, max_amount)
	SIGNAL_HANDLER

	if(!item || HAS_TRAIT(item, TRAIT_WIELDED))
		return COMPONENT_BLOCK_SHARPEN_BLOCKED

	if(amount <= damage_increase)
		return COMPONENT_BLOCK_SHARPEN_ALREADY
	// Already sharpened items can only be sharpened with the best whetstone on the difference between them
	amount -= damage_increase

	var/force = item.force
	var/datum/component/two_handed/TH_component = item.GetComponent(/datum/component/two_handed)
	if(TH_component)
		force = TH_component.force_wielded

	var/obj/item/clothing/gloves/color/black/razorgloves/razorgloves = item
	if(istype(razorgloves))
		force = razorgloves.razor_damage_high

	if(force >= max_amount || item.throwforce >= max_amount || item.flags & NOSHARPENING)
		return COMPONENT_BLOCK_SHARPEN_MAXED

	damage_increase = min(damage_increase + amount, (max_amount - force))
	item.sharpen_act(damage_increase)

	return COMPONENT_BLOCK_SHARPEN_APPLIED
