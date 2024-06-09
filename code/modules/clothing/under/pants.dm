/obj/item/clothing/under/pants
	gender = PLURAL
	body_parts_covered = LOWER_TORSO|LEGS
	displays_id = FALSE

/obj/item/clothing/under/pants/equipped(mob/user, slot, initial)
	. = ..()

	if(ishuman(user) && slot == ITEM_SLOT_CLOTH_INNER)
		var/mob/living/carbon/human/H = user
		if(H.undershirt != "Nude")
			var/additional_body_parts = UPPER_TORSO|ARMS
			body_parts_covered |= additional_body_parts
			return
	body_parts_covered = LOWER_TORSO|LEGS

/obj/item/clothing/under/pants/classicjeans
	name = "classic jeans"
	desc = "You feel cooler already."
	icon_state = "jeansclassic"
	item_color = "jeansclassic"

/obj/item/clothing/under/pants/mustangjeans
	name = "Must Hang jeans"
	desc = "Made in the finest space jeans factory this side of Alpha Centauri."
	icon_state = "jeansmustang"
	item_color = "jeansmustang"

/obj/item/clothing/under/pants/blackjeans
	name = "black jeans"
	desc = "Only for those who can pull it off."
	icon_state = "jeansblack"
	item_color = "jeansblack"

/obj/item/clothing/under/pants/youngfolksjeans
	name = "Young Folks jeans"
	desc = "For those tired of boring old jeans. Relive the passion of your youth!"
	icon_state = "jeansyoungfolks"
	item_color = "jeansyoungfolks"

/obj/item/clothing/under/pants/white
	name = "white pants"
	desc = "Plain white pants. Boring."
	icon_state = "whitepants"
	item_color = "whitepants"

/obj/item/clothing/under/pants/red
	name = "red pants"
	desc = "Bright red pants. Overflowing with personality."
	icon_state = "redpants"
	item_color = "redpants"

/obj/item/clothing/under/pants/black
	name = "black pants"
	desc = "These pants are dark, like your soul."
	icon_state = "blackpants"
	item_color = "blackpants"

/obj/item/clothing/under/pants/tan
	name = "tan pants"
	desc = "Some tan pants. You look like a white collar worker with these on."
	icon_state = "tanpants"
	item_color = "tanpants"

/obj/item/clothing/under/pants/blue
	name = "blue pants"
	desc = "Stylish blue pants. These go well with a lot of clothes."
	icon_state = "bluepants"
	item_color = "bluepants"

/obj/item/clothing/under/pants/track
	name = "track pants"
	desc = "A pair of track pants, for the athletic."
	icon_state = "trackpants"
	item_color = "trackpants"

/obj/item/clothing/under/pants/jeans
	name = "jeans"
	desc = "A nondescript pair of tough blue jeans."
	icon_state = "jeans"
	item_color = "jeans"

/obj/item/clothing/under/pants/khaki
	name = "khaki pants"
	desc = "A pair of dust beige khaki pants."
	icon_state = "khaki"
	item_color = "khaki"

/obj/item/clothing/under/pants/camo
	name = "camo pants"
	desc = "A pair of woodland camouflage pants. Probably not the best choice for a space station."
	icon_state = "camopants"
	item_color = "camopants"

/obj/item/clothing/under/pants/camo/commando
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)

/obj/item/clothing/under/pants/galifepants
	name = "check breeches"
	desc = "Штаны широкого фасона в бёдрах."
	icon_state = "galifepants"
	item_state = "galifepants"
	item_color = "galifepants"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/uniform.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/uniform.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/uniform.dmi'
		)

/obj/item/clothing/under/pants/sandpants
	name = "long sand pants"
	desc = "Брюки песочного цвета, расклешённые от колена."
	icon_state = "sandpants"
	item_state = "sandpants"
	item_color = "sandpants"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/uniform.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/uniform.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/uniform.dmi'
		)
