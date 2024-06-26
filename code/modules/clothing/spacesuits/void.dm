
//Voidsuits
/obj/item/clothing/head/helmet/space/nasavoid
	name = "NASA Void Helmet"
	desc = "A high tech, NASA Centcom branch designed space suit helmet. Used for AI satellite maintenance."
	icon_state = "void-red"
	item_state = "void"
	flags_inv = HIDEMASK|HIDEHEADSETS
	sprite_sheets = list(
		SPECIES_GREY = list(ITEM_SLOT_HEAD_STRING = 'icons/mob/clothing/species/grey/helmet.dmi'),
		SPECIES_TAJARAN = list(ITEM_SLOT_HEAD_STRING = 'icons/mob/clothing/species/tajaran/helmet.dmi'),
		SPECIES_UNATHI = list(ITEM_SLOT_HEAD_STRING = 'icons/mob/clothing/species/unathi/helmet.dmi'),
		SPECIES_ASHWALKER_BASIC = list(ITEM_SLOT_HEAD_STRING = 'icons/mob/clothing/species/unathi/helmet.dmi'),
		SPECIES_ASHWALKER_SHAMAN = list(ITEM_SLOT_HEAD_STRING = 'icons/mob/clothing/species/unathi/helmet.dmi'),
		SPECIES_DRACONOID = list(ITEM_SLOT_HEAD_STRING = 'icons/mob/clothing/species/unathi/helmet.dmi'),
		SPECIES_VULPKANIN = list(ITEM_SLOT_HEAD_STRING = 'icons/mob/clothing/species/vulpkanin/helmet.dmi'),
		SPECIES_VOX = list(ITEM_SLOT_HEAD_STRING = 'icons/mob/clothing/species/vox/helmet.dmi')
		)

/obj/item/clothing/suit/space/nasavoid
	name = "NASA Void Suit"
	icon_state = "void-red"
	item_state = "void"
	desc = "A high tech, NASA Centcom branch designed space suit. Used for AI satellite maintenance."
	allowed = list(/obj/item/flashlight,/obj/item/tank/internals,/obj/item/multitool)
	sprite_sheets = list(
		SPECIES_TAJARAN = list(ITEM_SLOT_CLOTH_OUTER_STRING = 'icons/mob/clothing/species/tajaran/suit.dmi'),
		SPECIES_UNATHI = list(ITEM_SLOT_CLOTH_OUTER_STRING = 'icons/mob/clothing/species/unathi/suit.dmi'),
		SPECIES_ASHWALKER_BASIC = list(ITEM_SLOT_CLOTH_OUTER_STRING = 'icons/mob/clothing/species/unathi/suit.dmi'),
		SPECIES_ASHWALKER_SHAMAN = list(ITEM_SLOT_CLOTH_OUTER_STRING = 'icons/mob/clothing/species/unathi/suit.dmi'),
		SPECIES_DRACONOID = list(ITEM_SLOT_CLOTH_OUTER_STRING = 'icons/mob/clothing/species/unathi/suit.dmi'),
		SPECIES_VULPKANIN = list(ITEM_SLOT_CLOTH_OUTER_STRING = 'icons/mob/clothing/species/vulpkanin/suit.dmi'),
		SPECIES_VOX = list(ITEM_SLOT_CLOTH_OUTER_STRING = 'icons/mob/clothing/species/vox/suit.dmi')
		)

//Colors!!!
/obj/item/clothing/head/helmet/space/nasavoid/green
	icon_state = "void-green"

/obj/item/clothing/suit/space/nasavoid/green
	icon_state = "void-green"

/obj/item/clothing/head/helmet/space/nasavoid/ntblue
	icon_state = "void-ntblue"

/obj/item/clothing/suit/space/nasavoid/ntblue
	icon_state = "void-ntblue"

/obj/item/clothing/head/helmet/space/nasavoid/purple
	icon_state = "void-purple"

/obj/item/clothing/suit/space/nasavoid/purple
	icon_state = "void-purple"

/obj/item/clothing/head/helmet/space/nasavoid/yellow
	icon_state = "void-yellow"

/obj/item/clothing/suit/space/nasavoid/yellow
	icon_state = "void-yellow"

/obj/item/clothing/head/helmet/space/nasavoid/ltblue
	icon_state = "void-light_blue"

/obj/item/clothing/suit/space/nasavoid/ltblue
	icon_state = "void-light_blue"


//Captian's Suit, like the other captian's suit, but looks better, at the cost of armor
/obj/item/clothing/head/helmet/space/nasavoid/captain
	name = "Fancy Retro Void Helmet"
	icon_state = "void-captian"
	desc = "A high tech, NASA Centcom branch designed space suit helmet. Used for AI satellite maintenance. This one is fit for a captain."

/obj/item/clothing/suit/space/nasavoid/captain
	name = "Fancy NASA Void Suit"
	icon_state = "void-captian"
	desc = "A high tech, NASA Centcom branch designed space suit. Used for AI satellite maintenance. This one is fit for a captain."

//Syndi's suit, on par with a blood red softsuit

/obj/item/clothing/head/helmet/space/nasavoid/syndi
	name = "Blood Red Retro Void Helmet"
	icon_state = "void-syndi"
	desc = "A high tech, NASA Centcom branch designed space suit helmet. This one looks rather suspicious."
	flags_inv = HIDEMASK|HIDEHEADSETS|HIDEGLASSES|HIDENAME
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 80, "acid" = 85)

/obj/item/clothing/suit/space/nasavoid/syndi
	name = "Blood Red NASA Void Suit"
	icon_state = "void-syndi"
	desc = "A high tech, NASA Centcom branch designed space suit. This one looks rather suspicious."
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 80, "acid" = 85)

//random spawner

/obj/effect/nasavoidsuitspawner
	name = "NASA Void Suit Spawner"
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "void-red"
	desc = "You shouldn't see this, a spawner for NASA Void Suits."
	var/suits = list("red", "green", "ntblue", "purple", "yellow", "ltblue")

/obj/effect/nasavoidsuitspawner/New()
	. = ..()
	var/obj/item/clothing/head/helmet/space/nasavoid/H
	var/obj/item/clothing/suit/space/nasavoid/S
	switch(pick(suits))
		if("red")
			H = new /obj/item/clothing/head/helmet/space/nasavoid
			S = new /obj/item/clothing/suit/space/nasavoid
		if("green")
			H = new /obj/item/clothing/head/helmet/space/nasavoid/green
			S = new /obj/item/clothing/suit/space/nasavoid/green
		if("ntblue")
			H = new /obj/item/clothing/head/helmet/space/nasavoid/ntblue
			S = new /obj/item/clothing/suit/space/nasavoid/ntblue
		if("purple")
			H = new /obj/item/clothing/head/helmet/space/nasavoid/purple
			S = new /obj/item/clothing/suit/space/nasavoid/purple
		if("yellow")
			H = new /obj/item/clothing/head/helmet/space/nasavoid/yellow
			S = new /obj/item/clothing/suit/space/nasavoid/yellow
		if("ltblue")
			H = new /obj/item/clothing/head/helmet/space/nasavoid/ltblue
			S = new /obj/item/clothing/suit/space/nasavoid/ltblue
	var/turf/T = get_turf(src)
	if(H)
		H.forceMove(T)
	if(S)
		S.forceMove(T)
	qdel(src)
