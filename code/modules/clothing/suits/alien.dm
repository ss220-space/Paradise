//Unathi clothing.
/obj/item/clothing/suit/unathi
	sprite_sheets = list(
		SPECIES_MONKEY = list(ITEM_SLOT_CLOTH_OUTER_STRING = 'icons/mob/clothing/species/monkey/suit.dmi'),
		SPECIES_PLASMAMAN = list(ITEM_SLOT_CLOTH_OUTER_STRING = 'icons/mob/clothing/species/plasmaman/suit.dmi'),
		SPECIES_VOX = list(ITEM_SLOT_CLOTH_OUTER_STRING = 'icons/mob/clothing/species/vox/suit.dmi')
		)

/obj/item/clothing/suit/unathi/robe
	name = "roughspun robes"
	desc = "A traditional Unathi garment."
	icon_state = "robe-unathi"
	item_state = "robe-unathi"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/neck/mantle/unathi
	name = "hide mantle"
	desc = "A rather grisly selection of cured hides and skin, sewn together to form a ragged mantle."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "mantle-unathi"
	body_parts_covered = UPPER_TORSO
	sprite_sheets = list(
		SPECIES_MONKEY = list(ITEM_SLOT_NECK_STRING = 'icons/mob/clothing/species/monkey/neck.dmi'),
		SPECIES_VOX = list(ITEM_SLOT_NECK_STRING = 'icons/mob/clothing/species/vox/neck.dmi')
		)
