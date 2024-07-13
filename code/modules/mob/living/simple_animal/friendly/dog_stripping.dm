//dog's stippable items

GLOBAL_LIST_INIT(strippable_corgi_items, create_strippable_list(list(
	/datum/strippable_item/dog_head,
	/datum/strippable_item/dog_back,
	/datum/strippable_item/pet_collar
)))

GLOBAL_LIST_INIT(strippable_muhtar_items, create_strippable_list(list(
	/datum/strippable_item/dog_head,
	/datum/strippable_item/dog_mask,
	/datum/strippable_item/pet_collar
)))


/datum/strippable_item/dog_head
	key = STRIPPABLE_ITEM_HEAD

/datum/strippable_item/dog_head/get_item(atom/source)
	var/mob/living/simple_animal/pet/dog/dog_source = source
	if(!istype(dog_source))
		return

	return dog_source.inventory_head

/datum/strippable_item/dog_head/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/mob/living/simple_animal/pet/dog/dog_source = source
	if(!istype(dog_source))
		return

	INVOKE_ASYNC(source, TYPE_PROC_REF(/mob/living/simple_animal/pet/dog, place_on_head), equipping, user)

/datum/strippable_item/dog_head/finish_unequip(atom/source, mob/user)
	var/mob/living/simple_animal/pet/dog/dog_source = source
	if(!istype(dog_source))
		return

	user.put_in_hands(dog_source.inventory_head)
	dog_source.inventory_head = null
	dog_source.update_dog_fluff()
	dog_source.update_appearance(UPDATE_OVERLAYS)

/datum/strippable_item/pet_collar
	key = STRIPPABLE_ITEM_PET_COLLAR

/datum/strippable_item/pet_collar/get_item(atom/source)
	var/mob/living/simple_animal/pet_source = source
	if(!istype(pet_source))
		return

	return pet_source.pcollar

/datum/strippable_item/pet_collar/try_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!istype(equipping, /obj/item/clothing/accessory/petcollar))
		to_chat(user, span_warning("That's not a collar."))
		return FALSE

	return TRUE

/datum/strippable_item/pet_collar/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/mob/living/simple_animal/pet_source = source
	if(!istype(pet_source))
		return

	pet_source.add_collar(equipping, user)

/datum/strippable_item/pet_collar/finish_unequip(atom/source, mob/user)
	var/mob/living/simple_animal/pet_source = source
	if(!istype(pet_source))
		return

	pet_source.remove_collar(user.drop_location(), user)


/datum/strippable_item/dog_back
	key = STRIPPABLE_ITEM_BACK

/datum/strippable_item/dog_back/get_item(atom/source)
	var/mob/living/simple_animal/pet/dog/dog_source = source
	if(!istype(dog_source))
		return

	return dog_source.inventory_back

/datum/strippable_item/dog_back/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/mob/living/simple_animal/pet/dog/dog_source = source
	if(!istype(dog_source))
		return
	if(!ispath(equipping.dog_fashion, /datum/dog_fashion/back))
		var/mob/living/simple_animal/pet/dog/dog = source
		to_chat(user, span_warning("You set [equipping] on [source]'s back, but it falls off!"))
		equipping.forceMove(source.drop_location())
		if(prob(25))
			step_rand(equipping)
		var/old_dir = dog.dir
		dog.spin(7, 1)
		dog.setDir(old_dir)
		return

	equipping.forceMove(dog_source)
	dog_source.inventory_back = equipping
	dog_source.update_dog_fluff()
	dog_source.regenerate_icons()

/datum/strippable_item/dog_back/finish_unequip(atom/source, mob/user)
	var/mob/living/simple_animal/pet/dog/dog_source = source
	if(!istype(dog_source))
		return

	user.put_in_hands(dog_source.inventory_back)
	dog_source.inventory_back = null
	dog_source.update_dog_fluff()
	dog_source.regenerate_icons()

/datum/strippable_item/dog_mask
	key = STRIPPABLE_ITEM_MASK

/datum/strippable_item/dog_mask/get_item(atom/source)
	var/mob/living/simple_animal/pet/dog/dog_source = source
	if(!istype(dog_source))
		return

	return dog_source.inventory_mask

/datum/strippable_item/dog_mask/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/mob/living/simple_animal/pet/dog/dog_source = source
	if(!istype(dog_source))
		return

	//The objects that secdogs can wear on their faces.
	if(!ispath(equipping.muhtar_fashion, /datum/muhtar_fashion/mask))
		to_chat(user, span_warning("You set [equipping] on [src]'s face, but it falls off!"))
		equipping.forceMove(dog_source.drop_location())
		if(prob(25))
			step_rand(equipping)
		var/old_dir = dog_source.dir
		dog_source.spin(7, 1)
		dog_source.setDir(old_dir)

	equipping.forceMove(dog_source)
	dog_source.inventory_mask = equipping
	dog_source.update_dog_fluff()
	dog_source.regenerate_icons()

/datum/strippable_item/dog_mask/finish_unequip(atom/source, mob/user)
	var/mob/living/simple_animal/pet/dog/dog_source = source
	if(!istype(dog_source))
		return

	user.put_in_hands(dog_source.inventory_mask)
	dog_source.inventory_mask = null
	dog_source.update_dog_fluff()
	dog_source.regenerate_icons()
	dog_source.update_appearance(UPDATE_OVERLAYS)
