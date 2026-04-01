/**
 * A component that overrides the bubble_icon variable when equipped or implanted
 * while having a simple priority system, so accessories have higher priority than
 * organs, for example.
 */
/datum/component/bubble_icon_override
	dupe_mode = COMPONENT_DUPE_ALLOWED
	can_transfer = TRUE
	/// The override to the default bubble icon for the atom
	var/bubble_icon
	/// The priority of this bubble icon compared to others
	var/priority
	/// The current mob that this component is registered to (to handle moving accessories)
	var/mob/living/current_owner

/datum/component/bubble_icon_override/Initialize(bubble_icon, priority)
	if(!isclothing(parent) && !isorgan(parent))
		return COMPONENT_INCOMPATIBLE
	src.bubble_icon = bubble_icon
	src.priority = priority

/datum/component/bubble_icon_override/RegisterWithParent()
	if(isclothing(parent))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
		if(isaccessory(parent))
			RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	else if(isorgan(parent))
		RegisterSignal(parent, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_organ_implanted))
		RegisterSignal(parent, COMSIG_ORGAN_REMOVED, PROC_REF(on_organ_removed))
	var/mob/living/target = get_bubble_icon_target()
	if(target)
		register_owner(target)

/datum/component/bubble_icon_override/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
		COMSIG_ORGAN_IMPLANTED,
		COMSIG_ORGAN_REMOVED,
		COMSIG_MOVABLE_MOVED,
	))
	if(current_owner)
		unregister_owner(current_owner)

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
	UnregisterSignal(owner, list(COMSIG_GET_BUBBLE_ICON))
	get_bubble_icon(owner)
	current_owner = null

/// Returns the potential wearer/owner of the object when the component is un/registered to/from it
/datum/component/bubble_icon_override/proc/get_bubble_icon_target()
	if(isclothing(parent))
		var/obj/item/clothing/clothing = parent
		if(istype(clothing, /obj/item/clothing/accessory))
			var/obj/item/clothing/under/uniform = clothing.loc
			if(!istype(uniform))
				return null
			clothing = uniform
		var/mob/living/wearer = clothing.loc
		if(istype(wearer) && (wearer.get_slot_by_item(clothing) & clothing.slot_flags))
			return wearer
	else if(isorgan(parent))
		var/obj/item/organ/organ = parent
		return organ.owner
	return null

/datum/component/bubble_icon_override/proc/on_equipped(obj/item/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(slot & source.slot_flags)
		register_owner(equipper)

/datum/component/bubble_icon_override/proc/on_dropped(obj/item/source, mob/dropper)
	SIGNAL_HANDLER
	unregister_owner(dropper)

/datum/component/bubble_icon_override/proc/on_moved(datum/source, atom/old_loc, direction, forced)
	SIGNAL_HANDLER
	var/mob/living/new_owner = get_bubble_icon_target()
	if(new_owner != current_owner)
		if(current_owner)
			unregister_owner(current_owner)
		if(new_owner)
			register_owner(new_owner)

/datum/component/bubble_icon_override/proc/on_organ_implanted(obj/item/organ/source, mob/owner)
	SIGNAL_HANDLER
	register_owner(owner)

/datum/component/bubble_icon_override/proc/on_organ_removed(obj/item/organ/source, mob/owner)
	SIGNAL_HANDLER
	unregister_owner(owner)

/**
 * Get the bubble icon with the highest priority from all instances of bubble_icon_override
 * currently registered with the target.
 */
/datum/component/bubble_icon_override/proc/get_bubble_icon(mob/living/target)
	if(QDELETED(parent))
		return
	var/list/holder = list(null)
	SEND_SIGNAL(target, COMSIG_GET_BUBBLE_ICON, holder)
	var/bubble_icon = holder[1]
	target.bubble_icon = bubble_icon || initial(target.bubble_icon)

/datum/component/bubble_icon_override/proc/return_bubble_icon(datum/source, list/holder)
	SIGNAL_HANDLER
	var/enemy_priority = holder[holder[1]]
	if(enemy_priority < priority)
		holder[1] = bubble_icon
		holder[bubble_icon] = priority
