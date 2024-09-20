GLOBAL_LIST_INIT(strippable_slugcat_items, create_strippable_list(list(
	/datum/strippable_item/slugcat_head,
	/datum/strippable_item/slugcat_hand,
	/datum/strippable_item/pet_collar
)))


/datum/strippable_item/slugcat_head
	key = STRIPPABLE_ITEM_HEAD

/datum/strippable_item/slugcat_head/get_item(atom/source)
	var/mob/living/simple_animal/pet/slugcat/slugcat_source = source
	if(!istype(slugcat_source))
		return

	return slugcat_source.inventory_head

/datum/strippable_item/slugcat_head/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/mob/living/simple_animal/pet/slugcat/slugcat_source = source
	if(!istype(slugcat_source))
		return

	INVOKE_ASYNC(source, TYPE_PROC_REF(/mob/living/simple_animal/pet/slugcat, place_on_head), equipping, user)

/datum/strippable_item/slugcat_head/finish_unequip(atom/source, mob/user)
	var/mob/living/simple_animal/pet/slugcat/slugcat_source = source
	if(!istype(slugcat_source))
		return

	INVOKE_ASYNC(source, TYPE_PROC_REF(/mob/living/simple_animal/pet/slugcat, remove_from_head), user)

/datum/strippable_item/slugcat_hand
	key = STRIPPABLE_ITEM_RHAND

/datum/strippable_item/slugcat_hand/get_item(atom/source)
	var/mob/living/simple_animal/pet/slugcat/slugcat_source = source
	if(!istype(slugcat_source))
		return

	return slugcat_source.inventory_hand

/datum/strippable_item/slugcat_hand/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/mob/living/simple_animal/pet/slugcat/slugcat_source = source
	if(!istype(slugcat_source))
		return

	INVOKE_ASYNC(source, TYPE_PROC_REF(/mob/living/simple_animal/pet/slugcat, place_to_hand), equipping, user)

/datum/strippable_item/slugcat_hand/finish_unequip(atom/source, mob/user)
	var/mob/living/simple_animal/pet/slugcat/slugcat_source = source
	if(!istype(slugcat_source))
		return

	INVOKE_ASYNC(source, TYPE_PROC_REF(/mob/living/simple_animal/pet/slugcat, remove_from_hand), user)
