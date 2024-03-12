/**
 * A storage item intended to be used by other items to provide storage functionality.
 * Types that use this should consider overriding emp_act() and hear_talk(), unless they shield their contents somehow.
 */
/obj/item/storage/internal
	var/obj/item/master_item


/obj/item/storage/internal/New(obj/item/MI)
	master_item = MI
	loc = master_item
	name = master_item.name
	verbs -= /obj/item/verb/verb_pickup	//make sure this is never picked up.
	..()


/obj/item/storage/internal/Destroy()
	master_item = null
	return ..()


/obj/item/storage/internal/attack_hand()
	return		//make sure this is never picked up


/obj/item/storage/internal/mob_can_equip(mob/M, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, bypass_obscured = FALSE)
	return FALSE	//make sure this is never picked up


/**
 * Helper procs to cleanly implement internal storages - storage items that provide inventory slots for other items.
 * These procs are completely optional, it is up to the master item to decide when it's storage get's opened by calling open()
 * However they are helpful for allowing the master item to pretend it is a storage item itself.
 * If you are using these you will probably want to override attackby() as well.
 * See /obj/item/clothing/suit/storage for an example.
 * Items that use internal storage have the option of calling this to emulate default storage MouseDrop behaviour.
 * Returns `FALSE` if the master item's parent's MouseDrop() should be called, `TRUE` otherwise. It's strange, but no other way of
 * doing it without the ability to call another proc's parent, really.
 */
/obj/item/storage/internal/proc/handle_mousedrop(mob/living/carbon/human/user, obj/over_object)
	. = FALSE
	if(over_object == user && ishuman(user) && !user.incapacitated() && !ismecha(user.loc) && !is_ventcrawling(user) && user.Adjacent(master_item))
		open(user)
		master_item.add_fingerprint(user)
		return TRUE


/**
 * Items that use internal storage have the option of calling this to emulate default storage attack_hand behaviour.
 * Returns `FALSE` if the master item's parent's attack_hand() should be called, `TRUE` otherwise.
 * It's strange, but no other way of doing it without the ability to call another proc's parent, really.
 */
/obj/item/storage/internal/proc/handle_attack_hand(mob/living/carbon/human/user)
	. = TRUE
	if(master_item.loc != user || !ishuman(user) || user.incapacitated() || ismecha(user.loc) || is_ventcrawling(user))
		return FALSE

	//Prevents opening if it's in a pocket.
	if(!user.get_active_hand() && (master_item == user.l_store || master_item == user.r_store))
		user.temporarily_remove_item_from_inventory(master_item)
		user.put_in_hands(master_item)
		return .

	open(user)
	master_item.add_fingerprint(user)


/obj/item/storage/internal/Adjacent(atom/neighbor)
	return master_item.Adjacent(neighbor)
