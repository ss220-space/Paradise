/obj/effect/proc_holder/spell/conjure_item
	name = "Summon weapon"
	desc = "Обычное заклинание, которого не должно существовать. При этом вызывается экземпляр предмета определенного типа или, если таковой уже существует, он удаляется."
	clothes_req = FALSE
	var/obj/item/item
	var/item_type = /obj/item/banhammer
	school = "conjuration"
	base_cooldown = 15 SECONDS
	cooldown_min = 1 SECONDS


/obj/effect/proc_holder/spell/conjure_item/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/conjure_item/cast(list/targets, mob/user = usr)
	if(item)
		QDEL_NULL(item)
	else
		for(var/mob/living/carbon/C in targets)
			if(C.drop_from_active_hand())
				item = new item_type
				C.put_in_active_hand(item)


/obj/effect/proc_holder/spell/conjure_item/Destroy()
	QDEL_NULL(item)
	return ..()
