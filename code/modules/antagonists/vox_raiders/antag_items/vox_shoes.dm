/obj/item/clothing/shoes/roman/vox
	name = "vox sandals"
	desc = "Синтетические обертки подходящие для большинства типов ног."

/obj/item/clothing/shoes/magboots/vox
	name = "vox magclaws"
	desc = "Тяжелые бронированные налапочники для когтистых лап причудливой формы."
	item_state = "boots-vox"
	icon_state = "boots-vox"
	icon = 'icons/obj/clothing/species/vox/shoes.dmi'
	species_restricted = list(SPECIES_VOX, SPECIES_VOX_ARMALIS)
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/feet.dmi',
		SPECIES_VOX_ARMALIS = 'icons/mob/clothing/species/armalis/feet.dmi',
	)
	w_class = WEIGHT_CLASS_NORMAL
	armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 50, FIRE = 115, ACID = 50)
	resistance_flags = NONE
	slowdown_active = 1

/obj/item/clothing/shoes/magboots/vox/toggle_magpulse(mob/living/user, silent = FALSE)
	. = ..()
	if(magpulse)
		ADD_TRAIT(src, TRAIT_NODROP, "[CLOTHING_TRAIT]_[UID_of(src)]")
	else
		REMOVE_TRAIT(src, TRAIT_NODROP, "[CLOTHING_TRAIT]_[UID_of(src)]")

/obj/item/clothing/shoes/magboots/vox/update_icon_state()
	return

/obj/item/clothing/shoes/magboots/vox/item_action_slot_check(slot, mob/user, datum/action/action)
	if(slot == ITEM_SLOT_FEET)
		return TRUE

//In case they somehow come off while enabled.
/obj/item/clothing/shoes/magboots/vox/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	if(slot == ITEM_SLOT_FEET && magpulse)
		if(!silent)
			user.visible_message("The [src] go limp as they are removed from [usr]'s feet.", "The [src] go limp as they are removed from your feet.")
		toggle_magpulse(user, silent = TRUE)

/obj/item/clothing/shoes/magboots/vox/examine(mob/user)
	. = ..()
	if(magpulse)
		. += span_notice("It would be hard to take these off without relaxing your grip first.")//theoretically this message should only be seen by the wearer when the claws are equipped.

/obj/item/clothing/shoes/magboots/vox/combat
	name = "vox combat magclaws"
	desc = "Боевые бронированные налапочники для когтистых лап причудливой формы с улучшенным сцеплением с поверхностью."
	item_state = "boots-vox-combat"
	icon_state = "boots-vox-combat"
	permeability_coefficient = 0.01
	armor = list(MELEE = 50, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 80, FIRE = 450, ACID = 50)
	strip_delay = 10 SECONDS
	slowdown_active = SHOES_SLOWDOWN + 0.5

/obj/item/clothing/shoes/magboots/vox/heavy
	name = "vox heavy magclaws"
	desc = "Тяжелые бронированные налапочники для когтистых лап причудливой формы для ведения боевых действий и защит нижних конечностей от всевозможных угроз."
	item_state = "boots-vox-heavy"
	icon_state = "boots-vox-heavy"
	body_parts_covered = FEET|LEGS
	permeability_coefficient = 0.01
	armor = list(MELEE = 115, BULLET = 50, LASER = 75, ENERGY = 50, BOMB = 200, FIRE = 450, ACID = 200)
	strip_delay = 14 SECONDS
	slowdown_passive = SHOES_SLOWDOWN + 1
	slowdown_active = SHOES_SLOWDOWN + 3

/obj/item/clothing/shoes/magboots/vox/heavy/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

/obj/item/clothing/shoes/magboots/vox/scout
	name = "vox scout magclaws"
	desc = "Легкие налапочники для когтистых лап причудливой формы с продвинутым сцеплением с поверхностью для ускорение передвижения."
	item_state = "boots-vox-combat"
	icon_state = "boots-vox-combat"
	slowdown_passive = -0.25
	slowdown_active = 0
