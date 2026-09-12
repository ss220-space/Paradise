/obj/item/clothing/gloves/fingerless
	name = "fingerless gloves"
	desc = "Plain black gloves without fingertips for the hard working."
	icon_state = "fingerless"
	item_state = "fingerless"
	item_color = null	//So they don't wash.
	transfer_prints = TRUE
	clothing_flags = NONE
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	strip_delay = 40
	put_on_delay = 20
	clipped = 1
	undyeable = TRUE

/obj/item/clothing/gloves/cyborg
	desc = "beep boop borp"
	name = "cyborg gloves"
	icon_state = "black"
	item_state = "r_hands"

/obj/item/clothing/gloves/color/black/forensics
	name = "forensics gloves"
	desc = "These high-tech gloves don't leave any material traces on objects they touch. Perfect for leaving crime scenes undisturbed...both before and after the crime."
	icon_state = "forensics"
	can_leave_fibers = FALSE

/obj/item/clothing/gloves/botanic_leather
	desc = "These leather gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin."
	name = "botanist's leather gloves"
	icon_state = "leather"
	item_state = "ggloves"
	permeability_coefficient = 0.9
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 70, ACID = 30)

/obj/item/clothing/gloves/cursedclown
	name = "cursed white gloves"
	desc = "These things smell terrible, and they're all lumpy. Gross."
	icon_state = "latex"
	item_state = "lgloves"

/obj/item/clothing/gloves/cursedclown/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/gloves/brown_short_gloves
	name = "short leather gloves"
	desc = "Короткие облегающие перчатки из кожи."
	icon_state = "brown_short_gloves"
	item_state = "brown_short_gloves"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/gloves.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/gloves.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/gloves.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/gloves.dmi',
	)

/obj/item/clothing/gloves/adaptive_gloves
	name = "adaptive gloves"
	desc = "Перчатки с технологией \"Хамелеон\", позволяющие выбрать на постоянную основу из нескольких видов перчаток, созданных по последнему пику моды."
	icon_state = "transmog"
	item_state = "transmog"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/gloves.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/gloves.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/gloves.dmi',
	)

/obj/item/clothing/gloves/adaptive_gloves/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/item_skins)

/obj/item/clothing/gloves/adaptive_gloves/get_ru_names()
	return alist(
		NOMINATIVE = "адаптивные перчатки",
		GENITIVE = "адаптивных перчаток",
		DATIVE = "адаптивным перчаткам",
		ACCUSATIVE = "адаптивные перчатки",
		INSTRUMENTAL = "адаптивными перчатками",
		PREPOSITIONAL = "адаптивных перчатках",
	)
