GLOBAL_LIST_INIT(strippable_snake_items, create_strippable_list(list(
	/datum/strippable_item/snake_head,
	/datum/strippable_item/pet_collar
)))


/datum/strippable_item/snake_head
	key = STRIPPABLE_ITEM_HEAD

/datum/strippable_item/snake_head/get_item(atom/source)
	var/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/snake_source = source
	if(!istype(snake_source))
		return

	return snake_source.inventory_head

/datum/strippable_item/snake_head/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/snake_source = source
	if(!istype(snake_source))
		return

	INVOKE_ASYNC(source, TYPE_PROC_REF(/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge, place_on_head), equipping, user)

/datum/strippable_item/snake_head/finish_unequip(atom/source, mob/user)
	var/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/snake_source = source
	if(!istype(snake_source))
		return

	INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, put_in_hands), snake_source.inventory_head)
	snake_source.inventory_head = null
	snake_source.update_snek_fluff()
	snake_source.update_appearance(UPDATE_OVERLAYS)
