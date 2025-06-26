/obj/effect/proc_holder/spell/conjure_item
	name = "Summon weapon"
	desc = "A generic spell that should not exist.  This summons an instance of a specific type of item, or if one already exists, un-summons it."
	clothes_req = FALSE
	var/obj/item/item
	var/item_type = /obj/item/banhammer
	school = "conjuration"
	base_cooldown = 15 SECONDS
	cooldown_min = 1 SECONDS


/obj/effect/proc_holder/spell/conjure_item/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/conjure_item/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/target = targets[1]
	if(!item)
		item = new item_type
		update_item(item)
	if(target.get_active_hand() != item)
		target.put_in_active_hand(item, TRUE)
		return
	QDEL_NULL(item)

/obj/effect/proc_holder/spell/conjure_item/proc/update_item(obj/item/item)
	return


/obj/effect/proc_holder/spell/conjure_item/Destroy()
	QDEL_NULL(item)
	return ..()
