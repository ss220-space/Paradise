/proc/overmap_ninja_vessel(mob/user)
	if(!ishuman(user))
		return null
	var/mob/living/carbon/human/human = user
	var/obj/item/clothing/suit/space/space_ninja/suit = human.get_item_by_slot(ITEM_SLOT_CLOTH_OUTER)
	if(!istype(suit))
		return null
	return suit.linked_overmap_vessel()

/proc/overmap_ninja_can_remote(mob/user, obj/overmap/entity/vessel)
	if(!user || !vessel)
		return FALSE
	return overmap_ninja_vessel(user) == vessel
