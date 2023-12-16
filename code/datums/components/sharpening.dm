/**
 * Sharpening component
 *
 * Makes an item sharpenable with a whetstone
 *
 */
/datum/component/sharpening
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/damage_increase
	var/can_sharpened = TRUE

/datum/component/sharpening/Initialize(damage_increase = 0)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.damage_increase = damage_increase

//datum/component/sharpening/InheritComponent()


/datum/component/sharpening/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_SHARPEN_ACT, PROC_REF(on_sharpen))

/datum/component/sharpening/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_SHARPEN_ACT))

/datum/component/sharpening/proc/on_sharpen(obj/item/item, amount, max_amount)
	SIGNAL_HANDLER

	if(!item)
		return COMPONENT_BLOCK_SHARPEN_BLOCKED

	var/obj/item/twohanded/twohanded = item
	if(istype(twohanded) && twohanded.wielded)
		return COMPONENT_BLOCK_SHARPEN_BLOCKED

	if(!can_sharpened)
		return COMPONENT_BLOCK_SHARPEN_ALREADY

	if(item.force >= max_amount || item.throwforce >= max_amount || istype(item, /obj/item/melee/energy) || istype(item, /obj/item/melee/mantisblade))
		return COMPONENT_BLOCK_SHARPEN_MAXED

	var/signal_out = SEND_SIGNAL(item, COMSIG_ITEM_SHARPEN_TWOHANDED, amount, max_amount)
	if(!signal_out && item.GetComponent(/datum/component/two_handed))
		return COMPONENT_BLOCK_SHARPEN_BLOCKED

	if(signal_out)
		damage_increase = signal_out
	else
		damage_increase = min(amount, (max_amount - item.force))
	can_sharpened = FALSE
	item.force += damage_increase
	item.throwforce += damage_increase

	return COMPONENT_BLOCK_SHARPEN_APPLIED
