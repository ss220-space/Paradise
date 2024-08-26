//craftable jewelry

/obj/item/clothing/accessory/necklace/gem
	name = "gem necklace"
	desc = "A simple necklace with a slot for gem."
	icon = 'icons/obj/clothing/jewelry.dmi'
	icon_state = "gem_necklace"
	item_state = "gem_necklace"
	slot_flags = ITEM_SLOT_NECK|ITEM_SLOT_ACCESSORY //trust me, I am 100% triplechecked this
	allow_duplicates = FALSE
	var/obj/item/gem/gem = null
	onmob_sheets = list(
		ITEM_SLOT_ACCESSORY_STRING = 'icons/mob/clothing/jewelry.dmi'
	)
	var/dragon_power = FALSE //user get additional bonuses for using draconic amber
	light_on = FALSE
	light_system = MOVABLE_LIGHT


/obj/item/clothing/accessory/necklace/gem/examine(mob/user)
	. = ..()
	if(!gem)
		. += span_notice("It looks like there is no gem inside.")
	if(dragon_power)
		. += span_notice("The necklace feels warm to touch.")


/obj/item/clothing/accessory/necklace/gem/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !istype(I, /obj/item/gem))
		return .

	add_fingerprint(user)
	var/obj/item/gem/new_gem = I
	if(!new_gem.insertable)
		to_chat(user, span_notice("You have no idea how to insert [new_gem] into [src]."))
		return .
	if(gem)
		to_chat(user, span_warning("The [name] already has [gem] inserted."))
		return .
	if(!user.drop_transfer_item_to_loc(new_gem, src))
		return .
	. |= ATTACK_CHAIN_BLOCKED_ALL
	to_chat(user, span_notice("You have carefully inserted [new_gem] into [src]."))
	gem = new_gem
	update_state()


/obj/item/clothing/accessory/necklace/gem/update_icon_state()
	if(!gem)
		icon_state = initial(icon_state)
		return
	switch(gem.type)
		if(/obj/item/gem/ruby)
			icon_state = "ruby_necklace"
		if(/obj/item/gem/sapphire)
			icon_state = "sapphire_necklace"
		if(/obj/item/gem/emerald)
			icon_state = "emerald_necklace"
		if(/obj/item/gem/topaz)
			icon_state = "topaz_necklace"
		if(/obj/item/gem/rupee)
			icon_state = "rupee_necklace"
		if(/obj/item/gem/magma)
			icon_state = "magma_necklace"
		if(/obj/item/gem/fdiamond)
			icon_state = "diamond_necklace"
		if(/obj/item/gem/void)
			icon_state = "void_necklace"
		if(/obj/item/gem/bloodstone)
			icon_state = "red_necklace"
		if(/obj/item/gem/purple)
			icon_state = "purple_necklace"
		if(/obj/item/gem/phoron)
			icon_state = "phoron_necklace"
		if(/obj/item/gem/amber)
			icon_state = "amber_necklace"
		else
			icon_state = initial(icon_state)


/obj/item/clothing/accessory/necklace/gem/update_name(updates = ALL)
	. = ..()
	if(!gem)
		name = initial(name)
		return .
	switch(gem.type)
		if(/obj/item/gem/ruby)
			name = "ruby necklace"
		if(/obj/item/gem/sapphire)
			name = "sapphire necklace"
		if(/obj/item/gem/emerald)
			name = "emerald necklace"
		if(/obj/item/gem/topaz)
			name = "topaz necklace"
		if(/obj/item/gem/rupee)
			name = "ruperium necklace"
		if(/obj/item/gem/magma)
			name = "auric necklace"
		if(/obj/item/gem/fdiamond)
			name = "diamond necklace"
		if(/obj/item/gem/void)
			name = "null necklace"
		if(/obj/item/gem/bloodstone)
			name = "ichorium necklace"
		if(/obj/item/gem/purple)
			name = "dilithium necklace"
		if(/obj/item/gem/phoron)
			name = "baroxuldium necklace"
		if(/obj/item/gem/amber)
			name = "draconic necklace"
		else
			name = initial(name)


/obj/item/clothing/accessory/necklace/gem/proc/update_state()
	if(!gem)
		resistance_flags = initial(resistance_flags)
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)
		set_light_on(FALSE)
		return
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)
	gem.set_light_on(FALSE)
	switch(gem.type)
		if(/obj/item/gem/magma)
			set_light_range_power_color(range = 3, power = 2, color = "#ff7b00")
			set_light_on(TRUE)
		if(/obj/item/gem/fdiamond)
			set_light_range_power_color(range = 3, power = 2, color = "#62cad5")
			set_light_on(TRUE)
		if(/obj/item/gem/void)
			set_light_range_power_color(range = 3, power = 2, color = "#4785a4")
			set_light_on(TRUE)
		if(/obj/item/gem/bloodstone)
			set_light_range_power_color(range = 4, power = 2, color = "#800000")
			set_light_on(TRUE)
		if(/obj/item/gem/purple)
			resistance_flags |= (INDESTRUCTIBLE|LAVA_PROOF|FIRE_PROOF|UNACIDABLE|ACID_PROOF)
			set_light_range_power_color(range = 3, power = 2, color = "#b90586")
			set_light_on(TRUE)
		if(/obj/item/gem/phoron)
			set_light_range_power_color(range = 3, power = 2, color = "#7d0692")
			set_light_on(TRUE)
		if(/obj/item/gem/amber)
			dragon_power = TRUE
			set_light_range_power_color(range = 3, power = 2, color = "#FFBF00")
			set_light_on(TRUE)


/obj/item/clothing/accessory/necklace/gem/on_attached(obj/item/clothing/under/new_suit, mob/attacher)
	. = ..()
	if(. && dragon_power && isliving(has_suit.loc))
		var/mob/living/wearer = has_suit.loc
		wearer.apply_status_effect(STATUS_EFFECT_DRAGON_STRENGTH)


/obj/item/clothing/accessory/necklace/gem/on_removed(mob/detacher)
	. = ..()
	if(.)
		var/obj/item/clothing/under/old_suit = .
		if(isliving(old_suit.loc))
			var/mob/living/wearer = old_suit.loc
			wearer.remove_status_effect(STATUS_EFFECT_DRAGON_STRENGTH)


/obj/item/clothing/accessory/necklace/gem/attached_equip(mob/living/user)
	if(dragon_power && isliving(user))
		user.apply_status_effect(STATUS_EFFECT_DRAGON_STRENGTH)


/obj/item/clothing/accessory/necklace/gem/attached_unequip(mob/living/user)
	if(dragon_power && isliving(user))
		user.remove_status_effect(STATUS_EFFECT_DRAGON_STRENGTH)


/obj/item/clothing/accessory/necklace/gem/equipped(mob/living/user, slot, initial = FALSE)
	. = ..()
	if(dragon_power && isliving(user) && slot == ITEM_SLOT_NECK)
		user.apply_status_effect(STATUS_EFFECT_DRAGON_STRENGTH)


/obj/item/clothing/accessory/necklace/gem/dropped(mob/living/user, slot, silent = FALSE)
	. = ..()
	if(dragon_power && isliving(user))
		user.remove_status_effect(STATUS_EFFECT_DRAGON_STRENGTH)

//bracers
/obj/item/clothing/gloves/jewelry_bracers
	name = "gem bracers"
	desc = "A simple golden bracers with a slot for gems."
	icon = 'icons/obj/clothing/jewelry.dmi'
	icon_state = "gem_bracers"
	item_state = "gem_bracers"
	onmob_sheets = list(
		ITEM_SLOT_GLOVES_STRING = 'icons/mob/clothing/jewelry.dmi'
	)
	var/obj/item/gem/gem = null
	transfer_prints = TRUE
	cold_protection = HANDS


/obj/item/clothing/gloves/jewelry_bracers/examine(mob/user)
	. = ..()
	if(!gem)
		. += span_notice("It looks like there is no gem inside.")


/obj/item/clothing/gloves/jewelry_bracers/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !istype(I, /obj/item/gem))
		return .

	add_fingerprint(user)
	var/obj/item/gem/new_gem = I
	if(!new_gem.simple)
		to_chat(user, span_notice("You have no idea how to insert [new_gem] into [src]."))
		return .
	if(gem)
		to_chat(user, span_warning("The [name] already has [gem] inserted."))
		return .
	if(!user.drop_transfer_item_to_loc(new_gem, src))
		return .
	. |= ATTACK_CHAIN_BLOCKED_ALL
	to_chat(user, span_notice("You carefully insert [new_gem] into [src]."))
	gem = new_gem
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)


/obj/item/clothing/gloves/jewelry_bracers/update_icon_state()
	if(!gem)
		icon_state = initial(icon_state)
		item_state = initial(item_state)
		update_equipped_item(update_speedmods = FALSE)
		return
	switch(gem.type)
		if(/obj/item/gem/ruby)
			icon_state = "ruby_bracers"
			item_state = "ruby_bracers"
		if(/obj/item/gem/sapphire)
			icon_state = "sapphire_bracers"
			item_state = "sapphire_bracers"
		if(/obj/item/gem/emerald)
			icon_state = "emerald_bracers"
			item_state = "emerald_bracers"
		if(/obj/item/gem/topaz)
			icon_state = "topaz_bracers"
			item_state = "topaz_bracers"
		else
			icon_state = initial(icon_state)
			item_state = initial(item_state)
	update_equipped_item(update_speedmods = FALSE)


/obj/item/clothing/gloves/jewelry_bracers/update_name(updates = ALL)
	. = ..()
	if(!gem)
		name = initial(name)
		return .
	switch(gem.type)
		if(/obj/item/gem/ruby)
			name = "ruby bracers"
		if(/obj/item/gem/sapphire)
			name = "sapphire bracers"
		if(/obj/item/gem/emerald)
			name = "emerald bracers"
		if(/obj/item/gem/topaz)
			name = "topaz bracers"
		else
			name = initial(name)

