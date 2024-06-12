/obj/item/clothing/under/shadowling
	name = "blackened flesh"
	desc = "Black, chitinous skin with thin red veins."
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_uniform"
	origin_tech = null
	item_flags = ABSTRACT|DROPDEL
	has_sensor = FALSE
	displays_id = FALSE
	onmob_sheets = list(
		ITEM_SLOT_CLOTH_INNER_STRING = NONE
	)
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF


/obj/item/clothing/under/shadowling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)


/obj/item/clothing/suit/space/shadowling
	name = "chitin shell"
	desc = "Dark, semi-transparent shell. Protects against vacuum, but not against the light of the stars." //Still takes damage from spacewalking but is immune to space itself
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_suit"
	body_parts_covered = FULL_BODY //Shadowlings are immune to space
	cold_protection = FULL_BODY
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEGLOVES | HIDESHOES | HIDEJUMPSUIT
	onmob_sheets = list(
		ITEM_SLOT_CLOTH_OUTER_STRING = NONE
	)
	slowdown = 0
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	heat_protection = null //You didn't expect a light-sensitive creature to have heat resistance, did you?
	max_heat_protection_temperature = null
	armor = list(melee = 25, bullet = 25, laser = 0, energy = 10, bomb = 25, bio = 100, rad = 100, fire = 100, acid = 100)
	item_flags = ABSTRACT|DROPDEL
	species_restricted = null


/obj/item/clothing/suit/space/shadowling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)


/obj/item/clothing/shoes/shadowling
	name = "chitin feet"
	desc = "Charred-looking feet. They have minature hooks that latch onto flooring."
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_shoes"
	onmob_sheets = list(
		ITEM_SLOT_FEET_STRING = NONE
	)

	resistance_flags = LAVA_PROOF|FIRE_PROOF|ACID_PROOF
	item_flags = ABSTRACT|DROPDEL
	clothing_traits = list(TRAIT_NO_SLIP_ALL)


/obj/item/clothing/shoes/shadowling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)


/obj/item/clothing/mask/gas/shadowling
	name = "chitin mask"
	desc = "A mask-like formation with slots for facial features. A red film covers the eyes."
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_mask"
	onmob_sheets = list(
		ITEM_SLOT_MASK_STRING = NONE
	)
	origin_tech = null
	siemens_coefficient = 0
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	item_flags = ABSTRACT|DROPDEL
	flags_cover = MASKCOVERSEYES	//We don't need to cover mouth


/obj/item/clothing/mask/gas/shadowling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)


/obj/item/clothing/gloves/shadowling
	name = "chitin hands"
	desc = "An electricity-resistant covering of the hands."
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_gloves"
	onmob_sheets = list(
		ITEM_SLOT_GLOVES_STRING = NONE
	)
	origin_tech = null
	siemens_coefficient = 0
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	item_flags = ABSTRACT|DROPDEL


/obj/item/clothing/gloves/shadowling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)


/obj/item/clothing/head/shadowling
	name = "chitin helm"
	desc = "A helmet-like enclosure of the head."
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_helmet"
	onmob_sheets = list(
		ITEM_SLOT_HEAD_STRING = NONE
	)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	origin_tech = null
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	clothing_flags = STOPSPRESSUREDMAGE
	item_flags = ABSTRACT|DROPDEL
	flags_cover = HEADCOVERSEYES	//We don't need to cover mouth


/obj/item/clothing/head/shadowling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)


/obj/item/clothing/glasses/shadowling
	name = "crimson eyes"
	desc = "A shadowling's eyes. Very light-sensitive and can detect body heat through walls."
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_glasses"
	onmob_sheets = list(
		ITEM_SLOT_EYES_STRING = NONE
	)
	origin_tech = null
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flash_protect = -1
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	item_flags = ABSTRACT|DROPDEL


/obj/item/clothing/glasses/shadowling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

