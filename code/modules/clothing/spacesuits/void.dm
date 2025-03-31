//Voidsuits

/obj/item/clothing/head/helmet/space/nasavoid
	name = "SC TsAGI 10 helmet"
	desc = "The spacesuit helmet is of semi-rigid type, based on the design of SC TsAGI 5. It is a hood with reinforcing inserts."
	icon_state = "void-red"
	item_state = "void-red-helmet"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	flags_inv = HIDEMASK|HIDEHEADSETS|HIDEGLASSES|HIDENAME
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 25, BOMB = 40, BIO = 100, RAD = 75, FIRE = 75, ACID = 75)
	sprite_sheets = list(
		SPECIES_GREY = 'icons/mob/clothing/species/grey/helmet.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/helmet.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/helmet.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/vox/helmet.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi')

/obj/item/clothing/suit/space/nasavoid
	name = "SC TsAGI 10 spacesuit"
	desc = "Semi-rigid spacesuit, based on the design of SC TsAGI 5. It is a jumpsuit with reinforcing inserts."
	icon_state = "void-red"
	item_state = "void-red"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 25, BOMB = 40, BIO = 100, RAD = 75, FIRE = 75, ACID = 75)
	allowed = list(/obj/item/flashlight,/obj/item/tank/internals,/obj/item/multitool)
	sprite_sheets = list(
		SPECIES_GREY = 'icons/mob/clothing/species/grey/helmet.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/helmet.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/helmet.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/vox/helmet.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi')

/obj/item/clothing/head/helmet/space/nasavoid/old
	name = "NASA engineering helmet"
	desc = "Heavy duty industrial helmet for engineering work."
	icon_state = "void-red"
	item_state = "void-red-helmet"
	flash_protect = FLASH_PROTECTION_FLASH
	flash_protect = FLASH_PROTECTION_WELDER
	armor = list(MELEE = 30, BULLET = 30, LASER = 20, ENERGY = 25, BOMB = 75, BIO = 100, RAD = 90, FIRE = 100, ACID = 75)
	item_state = "void-red-helmet"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/suit/space/nasavoid/old
	name = "NASA engineering spacesuit"
	desc = "Tough engineering spacesuit. SC TsAGI 5 style, mechanical exoskeleton with steel inserts, equipped with welding protection for engineering work. Designed by NASA Division."
	icon_state = "void-red"
	item_state = "void-red"
	slowdown = 4
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool)
	armor = list(MELEE = 30, BULLET = 30, LASER = 20, ENERGY = 25, BOMB = 75, BIO = 100, RAD = 90, "fire" = 100, ACID = 75)
	item_state = "void-red"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

//Colors!!! - NO! Now there isn't. TSF ARMOR

/obj/item/clothing/head/helmet/space/nasavoid/green
	name = "SC TsAGI 9 Helmet"
	desc = "Rigid combat spacesuit shem based on the design of SC TsAGI 5. It is an armored hood with shrapnel protection, inserted ballistic plates. Made in TSF."
	icon_state = "void-green"
	armor = list(MELEE = 30, BULLET = 60, LASER = 40, ENERGY = 30, BOMB = 50, BIO = 100, RAD = 50, FIRE = 75, ACID = 75)
	item_state = "void-green-helmet"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/suit/space/nasavoid/green
	name = "SC TsAGI 9 spacesuit"
	desc = "Rigid combat spacesuit, based on the design of SC TsAGI 5. It is an armored suit with shrapnel protection, inserted ballistic plates. Made in TSF."
	icon_state = "void-green"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list(MELEE = 30, BULLET = 60, LASER = 40, ENERGY = 30, BOMB = 50, BIO = 100, RAD = 50, FIRE = 75, ACID = 75)
	slowdown = 4
	item_state = "void-green"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

//Nasa vip

/obj/item/clothing/head/helmet/space/nasavoid/ntblue
	name = "NASA helmet for VIPs"
	desc = "Semi-rigid spacesuit helmet for VIPs, based on the design of the SC TsAGI 5. It is a hood with steel inserts. Developed by a division of NASA."
	icon_state = "void-ntblue"
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 25, BOMB = 40, BIO = 100, RAD = 75, FIRE = 75, ACID = 75)
	item_state = "void-ntblue-helmet"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/suit/space/nasavoid/ntblue
	name = "NASA spacesuit for VIPs"
	desc = "Semi-rigid spacesuit for VIPs, based on the design of SC TsAGI 5. It is a jumpsuit with steel inserts. Developed by a division of NASA."
	icon_state = "void-ntblue"
	w_class = WEIGHT_CLASS_NORMAL
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 25, BOMB = 40, BIO = 100, RAD = 75, FIRE = 75, ACID = 75)
	item_state = "void-ntblue"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

//Nasa RnD

/obj/item/clothing/head/helmet/space/nasavoid/purple
	name = "NASA RnD helmet"
	desc = "A rigid spacesuit helmet for research work, based on the SC TsAGI 5 design. It is a sapper hood with modification for the space environment. Developed by a division of NASA."
	icon_state = "void-purple"
	flash_protect = FLASH_PROTECTION_WELDER
	armor = list(MELEE = 50, BULLET = 20, LASER = 10, ENERGY = 25, BOMB = 95, BIO = 100, RAD = 75, FIRE = 75, ACID = 75)
	item_state = "void-purple-helmet"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/suit/space/nasavoid/purple
	name = "NASA RnD spacesuit"
	desc = "A rigid spacesuit for research work, based on the SC TsAGI 5 design. It is a bomb suit with modification for space environment. Developed by a division of NASA."
	icon_state = "void-purple"
	armor = list(MELEE = 50, BULLET = 20, LASER = 10, ENERGY = 25, BOMB = 95, BIO = 100, RAD = 75, FIRE = 75, ACID = 75)
	slowdown = 4
	item_state = "void-purple"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

//Nasa Miner

/obj/item/clothing/head/helmet/space/nasavoid/yellow
	name = "NASA mining helmet"
	desc = "A rigid spacesuit helmet for mining work, based on the SC TsAGI 5 design. Is a reinforced helmet for working in the depths of rocky guts. Developed by a division of NASA."
	icon_state = "void-yellow"
	armor = list(MELEE = 65, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 30, BIO = 100, RAD = 50, FIRE = 50, ACID = 75)
	item_state = "void-yellow-helmet"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/suit/space/nasavoid/yellow
	name = "NASA mining spacesuit."
	desc = "Rigid spacesuit for mining operations, based on the SC TsAGI 5 design. Is a mechanical exoskeleton for working in the depths of rocky guts. Developed by a division of NASA."
	icon_state = "void-yellow"
	armor = list(MELEE = 65, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 30, BIO = 100, RAD = 50, FIRE = 50, ACID = 75)
	item_state = "void-yellow"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

//Nasa Med

/obj/item/clothing/head/helmet/space/nasavoid/ltblue
	name = "NASA medical helmet"
	desc = "Semi-rigid helmet of the paramedic spacesuit, based on the SC TsAGI 5 design. Combination of an emergency spacesuit and a chemical defense suit, with some inserts against mechanical damage. Developed by a division of NASA."
	icon_state = "void-light_blue"
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 30, BIO = 100, RAD = 75, FIRE = 90, ACID = 100)
	item_state = "void-light_blue-helmet"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/suit/space/nasavoid/ltblue
	name = "NASA medical spacesuit"
	desc = "Semi-rigid paramedic spacesuit based on the SC TsAGI 5 design. Combination of an emergency spacesuit and a chemical defense suit, with some inserts against mechanical damage. Developed by a division of NASA."
	icon_state = "void-light_blue"
	w_class = WEIGHT_CLASS_NORMAL
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 30, BIO = 100, RAD = 75, FIRE = 90, ACID = 100)
	item_state = "void-light_blue"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

//Captian's Suit, like the other captian's suit, but looks better, at the cost of armor

/obj/item/clothing/head/helmet/space/nasavoid/captain
	name = "NASA captain helmet"
	icon_state = "void-captian"
	desc = "Repainted semi-hard helmet from the VIP suit, same SC TsAGI 5 style. It is a hood with steel inserts."
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 25, BOMB = 40, BIO = 100, RAD = 75, FIRE = 75, ACID = 75)
	item_state = "void-captian-helmet"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/suit/space/nasavoid/captain
	name = "NASA captain spacesuit"
	icon_state = "void-captian"
	desc = "A repainted semi-hard suit for the VIPs, still the same SC TsAGI 5 style. It is a jumpsuit with steel inserts."
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 25, BOMB = 40, BIO = 100, RAD = 75, FIRE = 75, ACID = 75)
	item_state = "void-captian"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

//Syndi's suit, on par with a blood red softsuit

/obj/item/clothing/head/helmet/space/nasavoid/syndi
	name = "Blood red infantry helmet"
	icon_state = "void-syndi"
	desc = "A semi-rigid infantry helmet. SC TsAGI 5 style, plate ballistic armor, and Kevlar fabric, the design allows it to be folded into a backpack. Developer not listed."
	armor = list(MELEE = 40, BULLET = 50, LASER = 30, ENERGY = 25, BOMB = 30, BIO = 100, RAD = 30, FIRE = 80, ACID = 85)
	flash_protect = FLASH_PROTECTION_FLASH
	item_state = "void-syndi-helmet"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/suit/space/nasavoid/syndi
	name = "Blood red infantry suit."
	icon_state = "void-syndi"
	desc = "A semi-rigid infantry suit. SC TsAGI 5 style, plate ballistic armor, and Kevlar fabric, the design allows it to be folded into a backpack. Developer not listed."
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list(MELEE = 40, BULLET = 50, LASER = 30, ENERGY = 25, BOMB = 30, BIO = 100, RAD = 30, FIRE = 80, ACID = 85)
	item_state = "void-syndi"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

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
