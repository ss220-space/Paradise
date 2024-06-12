/obj/item/clothing/mask/balaclava
	name = "balaclava"
	desc = "LOADSAMONEY"
	icon_state = "balaclava"
	item_state = "balaclava"
	w_class = WEIGHT_CLASS_SMALL
	can_toggle = TRUE
	actions_types = list(/datum/action/item_action/adjust)
	flags_inv = HIDENAME|HIDEFACIALHAIR|HIDEHEADHAIR
	adjusted_slot_flags = ITEM_SLOT_HEAD
	adjusted_flags_inv = HIDENAME|HIDEFACIALHAIR

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/mask.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/mask.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/mask.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/mask.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/mask.dmi'
		)


/obj/item/clothing/mask/balaclava/attack_self(mob/user)
	adjustmask(user)


/obj/item/clothing/mask/luchador
	name = "Luchador Mask"
	desc = "Worn by robust fighters, flying high to defeat their foes!"
	icon_state = "luchag"
	item_state = "luchag"
	flags_inv = HIDENAME|HIDEHAIR
	w_class = WEIGHT_CLASS_SMALL

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/mask.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/mask.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/mask.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/mask.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/mask.dmi'
		)

/obj/item/clothing/mask/luchador/tecnicos
	name = "Tecnicos Mask"
	desc = "Worn by robust fighters who uphold justice and fight honorably."
	icon_state = "luchador"
	item_state = "luchador"

/obj/item/clothing/mask/luchador/rudos
	name = "Rudos Mask"
	desc = "Worn by robust fighters who are willing to do anything to win."
	icon_state = "luchar"
	item_state = "luchar"
