/obj/item/storage/box/cool_clothes_kit
	icon = 'icons/obj/affiliates.dmi'
	desc = "Невероятно стильная коробка."
	icon_state = "bond_bundle"

/obj/item/storage/box/cool_clothes_kit/populate_contents()
	new /obj/item/clothing/under/suit_jacket/bond(src)
	new /obj/item/clothing/suit/storage/lawyer/blackjacket/bond(src)
	new /obj/item/clothing/gloves/combat/bond(src)
	new /obj/item/clothing/shoes/laceup/bond(src)
	new /obj/item/clothing/glasses/sunglasses(src)

/obj/item/storage/box/cool_clothes_kit/New()
	if(prob(5))
		icon_state = "joker"
		new /obj/item/toy/plushie/blahaj/twohanded(src)

	. = ..()

/obj/item/clothing/under/suit_jacket/bond
	armor = list(melee = 10, bullet = 20, laser = 10, energy = 10, bomb = 10, bio = 0, rad = 0, fire = 30, acid = 0)

/obj/item/clothing/gloves/combat/bond
	name = "black gloves"
	desc = "These gloves are fire-resistant."
	icon_state = "black"
	item_state = "bgloves"
	item_color = "black"
	armor = list(melee = 25, bullet = 25, laser = 15, energy = 15, bomb = 25, bio = 0, rad = 0, fire = 30, acid = 60)

/obj/item/clothing/suit/storage/lawyer/blackjacket/bond
	desc = "Стильная куртка, усиленная слоем брони, защищающим туловище."
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/gun/projectile/revolver, /obj/item/gun/projectile/automatic/pistol, /obj/item/twohanded/garrote, /obj/item/gun/projectile/automatic/toy/pistol/riot, /obj/item/gun/syringe/syndicate)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	armor = list(melee = 25, bullet = 25, laser = 15, energy = 15, bomb = 25, bio = 0, rad = 0, fire = 30, acid = 60)

/obj/item/clothing/shoes/laceup/bond
	armor = list(melee = 25, bullet = 25, laser = 15, energy = 15, bomb = 25, bio = 0, rad = 0, fire = 30, acid = 60)
