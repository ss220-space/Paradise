//craftable jewelry

/obj/item/clothing/accessory/necklace/gem
	name = "gem necklace"
	desc = "A simple necklace with a slot for gem."
	icon = 'icons/obj/clothing/jewelry.dmi'
	icon_state = "gem_necklace"
	item_state = "gem_necklace"
	slot_flags = SLOT_NECK | SLOT_TIE //trust me, I am 100% triplechecked this
	allow_duplicates = FALSE
	var/gem = null
	icon_override = 'icons/mob/jewelry/neck.dmi'
	var/dragon_power = FALSE //user get additional bonuses for using draconic amber
	var/necklace_light = FALSE //some lighting stuff


/obj/item/clothing/accessory/necklace/gem/examine(mob/user)
	. = ..()
	if(!gem)
		. += "<span class='notice'>It looks like there is no gem inside!</span>"
	if(dragon_power)
		. += "<span class='notice'>The necklace feels warm to touch.</span>"

/obj/item/clothing/accessory/necklace/gem/attackby(obj/item/gem/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/gem) && !I.insertable)
		to_chat(user, span_notice("You have no idea how to insert [I] into necklace."))
		return
	if(istype(I, /obj/item/gem) && I.insertable && !gem)
		I.light_range = 0
		I.light_power = 0
		I.light_color = null
		user.drop_transfer_item_to_loc(I, src)
		//generic gems
		if(istype(I, /obj/item/gem/ruby))
			name = "ruby necklace"
			icon_state = "ruby_necklace"
		if(istype(I, /obj/item/gem/sapphire))
			name = "sapphire necklace"
			icon_state = "sapphire_necklace"
		if(istype(I, /obj/item/gem/emerald))
			name = "emerald necklace"
			icon_state = "emerald_necklace"
		if(istype(I, /obj/item/gem/topaz))
			name = "topaz necklace"
			icon_state = "topaz_necklace"
		//fauna gems
		if(istype(I, /obj/item/gem/rupee))
			name = "ruperium necklace"
			icon_state = "rupee_necklace"
		if(istype(I, /obj/item/gem/magma))
			name = "auric necklace"
			icon_state = "magma_necklace"
			light_range = 3
			light_power = 2
			light_color = "#ff7b00"
		if(istype(I, /obj/item/gem/fdiamond))
			name = "diamond necklace"
			icon_state = "diamond_necklace"
			light_range = 3
			light_power = 2
			light_color = "#62cad5"
		//megafauna gems
		if(istype(I, /obj/item/gem/void))
			name = "null necklace"
			icon_state = "void_necklace"
			light_range = 3
			light_power = 2
			light_color = "#4785a4"
		if(istype(I, /obj/item/gem/bloodstone))
			name = "ichorium necklace"
			icon_state = "red_necklace"
			light_range = 4
			light_power = 2
			light_color = "#800000"
		if(istype(I, /obj/item/gem/purple))
			name = "dilithium necklace"
			icon_state = "purple_necklace"
			light_range = 3
			light_power = 2
			light_color = "#b90586"
		if(istype(I, /obj/item/gem/phoron))
			name = "baroxuldium necklace"
			icon_state = "phoron_necklace"
			light_range = 3
			light_power = 2
			light_color = "#7d0692"
		if(istype(I, /obj/item/gem/amber))
			name = "draconic necklace"
			icon_state = "amber_necklace"
			light_range = 3
			light_power = 2
			light_color = "#FFBF00"
			dragon_power = TRUE
		gem = I
		to_chat(user, span_notice("You carefully insert [I] into necklace."))
		update_light()

/obj/item/clothing/accessory/necklace/gem/on_attached(obj/item/clothing/under/S, mob/user)
	. = ..()
	if(isliving(user) && dragon_power)
		var/mob/living/M = user
		M.apply_status_effect(STATUS_EFFECT_DRAGON_STRENGTH)

/obj/item/clothing/accessory/necklace/gem/on_removed(mob/user)
	. = ..()
	if(isliving(user) && dragon_power)
		var/mob/living/M = user
		M.remove_status_effect(STATUS_EFFECT_DRAGON_STRENGTH)

/obj/item/clothing/accessory/necklace/gem/attached_unequip()
	if(isliving(usr) && dragon_power)
		var/mob/living/M = usr
		M.remove_status_effect(STATUS_EFFECT_DRAGON_STRENGTH)
	return ..()

/obj/item/clothing/accessory/necklace/gem/attached_equip()
	if(isliving(usr) && dragon_power)
		var/mob/living/M = usr
		M.apply_status_effect(STATUS_EFFECT_DRAGON_STRENGTH)
	return ..()

/obj/item/clothing/accessory/necklace/gem/equipped(mob/user, slot, initial)
	. = ..()
	if(isliving(user) && dragon_power && slot == slot_neck)
		var/mob/living/M = user
		M.apply_status_effect(STATUS_EFFECT_DRAGON_STRENGTH)

/obj/item/clothing/accessory/necklace/gem/dropped(mob/user)
	. = ..()
	var/mob/living/M = user
	if(isliving(user) && dragon_power && M.get_item_by_slot(slot_neck) == src)
		M.remove_status_effect(STATUS_EFFECT_DRAGON_STRENGTH)
