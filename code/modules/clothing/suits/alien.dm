//Unathi clothing.
/obj/item/clothing/suit/unathi
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/unathi/robe
	name = "roughspun robes"
	desc = "Традиционный гардеробный элемент унати."
	ru_names = list(
		NOMINATIVE = "грубошерстные одеяния",
		GENITIVE = "грубошерстных одеяний",
		DATIVE = "грубошерстным одеяниям",
		ACCUSATIVE = "грубошерстные одеяния",
		INSTRUMENTAL = "грубошерстными одеяниями",
		PREPOSITIONAL = "грубошерстных одеяниях"
	)
	icon_state = "robe-unathi"
	item_state = "robe-unathi"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/neck/mantle/unathi
	name = "hide mantle"
	desc = "Довольно жуткая подборка выделанных шкур, сшитых вместе, чтобы получилась рваная накидка."
	ru_names = list(
		NOMINATIVE = "накидка из шкур",
		GENITIVE = "накидки из шкур",
		DATIVE = "накидке из шкур",
		ACCUSATIVE = "накидку из шкур",
		INSTRUMENTAL = "накидкой из шкур",
		PREPOSITIONAL = "накидке из шкур"
	)
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "mantle-unathi"
	body_parts_covered = UPPER_TORSO
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/neck.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/neck.dmi'
		)
