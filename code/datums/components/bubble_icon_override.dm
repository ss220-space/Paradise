/**
 * A component that overrides the bubble_icon variable when equipped or implanted
 * while having a simple priority system, so accessories have higher priority than
 * organs, for example.
 */
/datum/component/bubble_icon_override
	dupe_mode = COMPONENT_DUPE_ALLOWED
	can_transfer = TRUE //sure why not
	/// The override to the default bubble icon for the atom
	var/bubble_icon
	/// The priority of this bubble icon compared to others
	var/priority
	/// Currently cached owner mob that this component is registered to
	var/mob/living/current_owner
	/// Uniform that contains this accessory (if it's an accessory)
	var/obj/item/clothing/current_uniform

/datum/component/bubble_icon_override/Initialize(bubble_icon, priority)
	if(!isclothing(parent) && !isorgan(parent))
		return COMPONENT_INCOMPATIBLE
	src.bubble_icon = bubble_icon
	src.priority = priority

/datum/component/bubble_icon_override/RegisterWithParent()
	if(isclothing(parent))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
		// For accessories, also track movement and uniform signals
		if(isaccessory(parent))
			RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_accessory_moved))
			update_uniform_monitoring()
	else if(isorgan(parent))
		RegisterSignal(parent, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_organ_implanted))
		RegisterSignal(parent, COMSIG_ORGAN_REMOVED, PROC_REF(on_organ_removed))
	update_owner()

/datum/component/bubble_icon_override/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
		COMSIG_ORGAN_IMPLANTED,
		COMSIG_ORGAN_REMOVED,
		COMSIG_MOVABLE_MOVED,
	))
	if(current_uniform)
		UnregisterSignal(current_uniform, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_MOVED))
	if(current_owner)
		unregister_owner(current_owner)
	current_owner = null
	current_uniform = null

/datum/component/bubble_icon_override/proc/register_owner(mob/living/owner)
	if(owner == current_owner)
		return
	if(current_owner)
		unregister_owner(current_owner)
	current_owner = owner
	RegisterSignal(owner, COMSIG_GET_BUBBLE_ICON, PROC_REF(return_bubble_icon))
	get_bubble_icon(owner)

/datum/component/bubble_icon_override/proc/unregister_owner(mob/living/owner)
	if(owner != current_owner)
		return
	UnregisterSignal(owner, COMSIG_GET_BUBBLE_ICON)
	current_owner = null
	get_bubble_icon(owner)

/// Returns the potential wearer/owner of the object when the component is un/registered to/from it
/datum/component/bubble_icon_override/proc/get_bubble_icon_target()
	if(isorgan(parent))
		var/obj/item/organ/organ = parent
		return organ.owner

	var/obj/item/clothing/clothing = parent
	if(isaccessory(parent))
		var/obj/item/clothing/uniform = clothing.loc
		if(!istype(uniform))
			return null
		var/mob/living/wearer = uniform.loc
		if(istype(wearer) && (wearer.get_slot_by_item(uniform) & uniform.slot_flags))
			return wearer
		return null

	var/mob/living/wearer = clothing.loc
	if(istype(wearer) && (wearer.get_slot_by_item(clothing) & clothing.slot_flags))
		return wearer
	return null

/// Updates the current owner based on the actual state
/datum/component/bubble_icon_override/proc/update_owner()
	var/mob/living/new_owner = get_bubble_icon_target()
	if(new_owner == current_owner)
		return
	if(current_owner)
		unregister_owner(current_owner)
	if(new_owner)
		register_owner(new_owner)

/// Subscribes to uniform signals if this accessory is inside a uniform
/datum/component/bubble_icon_override/proc/update_uniform_monitoring()
	var/obj/item/clothing/accessory = parent
	var/obj/item/clothing/uniform = accessory.loc
	if(uniform == current_uniform)
		return
	if(current_uniform)
		UnregisterSignal(current_uniform, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_MOVED))
	current_uniform = uniform
	if(current_uniform)
		RegisterSignal(current_uniform, COMSIG_ITEM_EQUIPPED, PROC_REF(on_uniform_equipped))
		RegisterSignal(current_uniform, COMSIG_ITEM_DROPPED, PROC_REF(on_uniform_dropped))
		RegisterSignal(current_uniform, COMSIG_MOVABLE_MOVED, PROC_REF(on_uniform_moved))
	update_owner()

/datum/component/bubble_icon_override/proc/on_equipped(obj/item/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(slot & source.slot_flags)
		update_owner()

/datum/component/bubble_icon_override/proc/on_dropped(obj/item/source, mob/dropper)
	SIGNAL_HANDLER
	update_owner()

/datum/component/bubble_icon_override/proc/on_accessory_moved()
	SIGNAL_HANDLER
	update_uniform_monitoring()

/datum/component/bubble_icon_override/proc/on_uniform_equipped(obj/item/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(slot & source.slot_flags)
		update_owner()

/datum/component/bubble_icon_override/proc/on_uniform_dropped(obj/item/source, mob/dropper)
	SIGNAL_HANDLER
	update_owner()

/datum/component/bubble_icon_override/proc/on_uniform_moved()
	SIGNAL_HANDLER
	update_owner()

/datum/component/bubble_icon_override/proc/on_organ_implanted(obj/item/organ/source, mob/owner)
	SIGNAL_HANDLER
	update_owner()

/datum/component/bubble_icon_override/proc/on_organ_removed(obj/item/organ/source, mob/owner)
	SIGNAL_HANDLER
	update_owner()

/**
 * Get the bubble icon with the highest priority from all instances of bubble_icon_override
 * currently registered with the target.
 */
/datum/component/bubble_icon_override/proc/get_bubble_icon(mob/living/target)
	if(QDELETED(parent) || !target)
		return
	var/list/holder = list(null)
	SEND_SIGNAL(target, COMSIG_GET_BUBBLE_ICON, holder)
	target.bubble_icon = holder[1] || initial(target.bubble_icon)

/// Called when another component signals its bubble icon for priority comparison
/datum/component/bubble_icon_override/proc/return_bubble_icon(datum/source, list/holder)
	SIGNAL_HANDLER
	var/current_icon = holder[1]
	var/current_priority = current_icon ? holder[current_icon] : -INFINITY
	if(current_priority < priority)
		holder[1] = bubble_icon
		holder[bubble_icon] = priority
