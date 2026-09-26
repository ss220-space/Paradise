// Holds the reflector clothing set //

/obj/item/clothing/gloves/reflector
	name = "reflector gloves"
	desc = "Высокотехнологичные перчатки, изготовленные из светоотражающего материала, предназначены для отражения энергетических лучей. Носить их — настоящее испытание для рук!"
	icon_state = "reflector"
	item_state = "reflector"
	armor = list(MELEE = 0, BULLET = 0, LASER = 50, ENERGY = 50, BOMB = 0, BIO = 0, FIRE = 50, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/gloves.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/gloves.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/gloves.dmi',
	)
	var/list/reflect_zones = list(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
	var/hit_reflect_chance = 50

/obj/item/clothing/gloves/reflector/get_ru_names()
	return alist(
		NOMINATIVE = "рефлекторные перчатки",
		GENITIVE = "рефлекторных перчаток",
		DATIVE = "рефлекторнным перчаткам",
		ACCUSATIVE = "рефлекторнные перчатки",
		INSTRUMENTAL = "рефлекторными перчатками",
		PREPOSITIONAL = "рефлекторных перчатках",
	)

/obj/item/clothing/gloves/reflector/IsReflect(def_zone)
	if(!(def_zone in reflect_zones))
		return FALSE
	if(prob(hit_reflect_chance))
		return TRUE

/obj/item/clothing/head/helmet/reflector
	name = "reflector hat"
	desc = "Высокотехнологичная шляпа, изготовленная из светоотражающего материала, предназначена для отражения энергетических лучей. В неё встроен защитный визор, который обладает повышенной устойчивостью к кислотам."
	icon_state = "reflector"
	item_state = "reflectorhat"
	flags_inv = HIDEHEADSETS
	flags_cover = HEADCOVERSEYES|HEADCOVERSMOUTH
	dog_fashion = null
	armor = list(MELEE = 10, BULLET = 10, LASER = 60, ENERGY = 60, BOMB = 0, BIO = 0, FIRE = 90, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/helmet.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/helmet.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/helmet.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/helmet.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/helmet.dmi',
	)
	var/list/reflect_zones = list(BODY_ZONE_HEAD)
	var/hit_reflect_chance = 50

/obj/item/clothing/head/helmet/reflector/get_ru_names()
	return alist(
		NOMINATIVE = "рефлекторная шляпа",
		GENITIVE = "рефлекторную шляпу",
		DATIVE = "рефлекторной шляпе",
		ACCUSATIVE = "рефлекторную шляпу",
		INSTRUMENTAL = "рефлекторной шляпой",
		PREPOSITIONAL = "рефлекторной шляпе",
	)

/obj/item/clothing/head/helmet/reflector/IsReflect(def_zone)
	if(!(def_zone in reflect_zones))
		return FALSE
	if(prob(hit_reflect_chance))
		return TRUE

/obj/item/clothing/shoes/reflector
	name = "reflector boots"
	desc = "Высокотехнологичные ботинки, изготовленные из светоотражающего материала, предназначены для отражения энергетических лучей. Довольно лёгкая, но не очень удобная обувь."
	icon_state = "reflector"
	item_state = "reflectorboots"
	armor = list(MELEE = 0, BULLET = 0, LASER = 50, ENERGY = 50, BOMB = 0, BIO = 0, FIRE = 50, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/shoes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/shoes.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/shoes.dmi',
	)
	var/list/reflect_zones = list(BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	var/hit_reflect_chance = 50

/obj/item/clothing/shoes/reflector/get_ru_names()
	return alist(
		NOMINATIVE = "рефлекторные ботинки",
		GENITIVE = "рефлекторных ботинок",
		DATIVE = "рефлекторным ботинкам",
		ACCUSATIVE = "рефлекторные ботинки",
		INSTRUMENTAL = "рефлекторными ботинками",
		PREPOSITIONAL = "рефлекторных ботинках",
	)

/obj/item/clothing/shoes/reflector/IsReflect(def_zone)
	if(!(def_zone in reflect_zones))
		return FALSE
	if(prob(hit_reflect_chance))
		return TRUE

/obj/item/clothing/suit/armor/reflector
	name = "reflector coat"
	desc = "Высокотехнологичное инновационное пальто, изготовленное из светоотражающего материала, предназначенное для отражения энергетических лучей. Сочетает в себе стиль и самые передовые технологии."
	icon_state = "reflector"
	item_state = "reflector"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	armor = list(MELEE = 10, BULLET = 10, LASER = 60, ENERGY = 60, BOMB = 0, BIO = 0, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
	)
	var/static/list/reflect_zones = list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	var/hit_reflect_chance = 50

/obj/item/clothing/suit/armor/reflector/get_ru_names()
	return alist(
		NOMINATIVE = "рефлекторное пальто",
		GENITIVE = "рефлекторное пальто",
		DATIVE = "рефлекторному пальто",
		ACCUSATIVE = "рефлекторное пальто",
		INSTRUMENTAL = "рефлекторным пальто",
		PREPOSITIONAL = "рефлекторном пальто",
	)

/obj/item/clothing/suit/armor/reflector/IsReflect(def_zone)
	if(!(def_zone in reflect_zones))
		return FALSE

	if(prob(hit_reflect_chance))
		return TRUE

	return FALSE
