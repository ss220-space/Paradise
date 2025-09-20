// Eldritch armor. Looks cool, hood lets you cast heretic spells.
/obj/item/clothing/head/hooded/cult_hoodie/eldritch
	name = "зловещий капюшон"
	desc = "Рваный, покрытый пылью капюшон. Внутри виднеются жуткие глаза."
	icon = 'icons/obj/clothing/helmet.dmi'
	//worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	icon_state = "eldritch"
	//item_state = "eldritch"
	flags_inv = HIDEMASK|HIDEHEADSETS|HIDEGLASSES|HIDENAME|HIDEHAIR
	//flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	//flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	flash_protect = FLASH_PROTECTION_WELDER
	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
	)


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/get_ru_names()
	return list(
		NOMINATIVE = "зловещий капюшон",
		GENITIVE = "зловещего капюшона",
		DATIVE = "зловещему капюшону",
		ACCUSATIVE = "зловещий капюшон",
		INSTRUMENTAL = "зловещим капюшоном",
		PREPOSITIONAL = "зловещем капюшоне",
	)


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/heretic_focus)


/obj/item/clothing/suit/hooded/cultrobes/eldritch
	name = "зловещая броня"
	desc = "Рваная, пыльная мантия. Внутри — видны жуткие глаза."
	gender = FEMALE
	icon_state = "eldritch_armor"
	//item_state = "eldritch_armor"
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/gun/projectile/automatic/sniper_rifle/lionhunter)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch
	// Slightly better than normal cult robes
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50,"energy" = 50, "bomb" = 35, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 20)
	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
	)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/get_ru_names()
	return list(
		NOMINATIVE = "зловещая броня",
		GENITIVE = "зловещей брони",
		DATIVE = "зловещей броне",
		ACCUSATIVE = "зловещую броню",
		INSTRUMENTAL = "зловещей бронёй",
		PREPOSITIONAL = "зловещей броне",
	)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/examine(mob/user)
	. = ..()
	if(!isheretic(user))
		return

	// Our hood gains the heretic_focus element.
	. += span_notice("Позволяет использовать еретические заклинания при надетом капюшоне.")



// Плащ Пустоты. Turns invisible with the hood up, lets you hide stuff.
/obj/item/clothing/head/hooded/cult_hoodie/void
	name = "капюшон пустоты"
	desc = "Чёрный, как смола, не отражающий свет. Покрытый рунами. \
			С каждой вспышкой вы теряете понимание того, что видите."
	icon = 'icons/obj/clothing/helmet.dmi'
	//worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	icon_state = "void_cloak"
	//item_state = "void_cloak"
	flags_inv = NONE
	flags_cover = NONE
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 15, "bio" = 10, "rad" = 0, "fire" = 15, "acid" = 0)
	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
	)


/obj/item/clothing/head/hooded/cult_hoodie/void/get_ru_names()
	return list(
		NOMINATIVE = "капюшон пустоты",
		GENITIVE = "капюшона пустоты",
		DATIVE = "капюшону пустоты",
		ACCUSATIVE = "капюшон пустоты",
		INSTRUMENTAL = "капюшоном пустоты",
		PREPOSITIONAL = "капюшоне пустоты"
	)


/obj/item/clothing/head/hooded/cult_hoodie/void/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_NO_STRIP, TRAIT_EXAMINE_SKIP), INNATE_TRAIT)


/obj/item/clothing/suit/hooded/cultrobes/void
	name = "плащ пустоты"
	desc = "Чёрный, как смола, не отражающий свет. Покрытый рунами. \
			С каждой вспышкой вы теряете понимание того, что видите."
	icon_state = "void_cloak"
	//item_state = "void_cloak"
	//item_state = null
	allowed = list(/obj/item/melee/sickly_blade)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/void
	flags_inv = NONE
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	// slightly worse than normal cult robes
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30,"energy" = 30, "bomb" = 15, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	//alternative_mode = TRUE
	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
	)


/obj/item/clothing/suit/hooded/cultrobes/void/get_ru_names()
	return list(
		NOMINATIVE = "плащ пустоты",
		GENITIVE = "плаща пустоты",
		DATIVE = "плащу пустоты",
		ACCUSATIVE = "плащ пустоты",
		INSTRUMENTAL = "плащом пустоты",
		PREPOSITIONAL = "плаще пустоты"
	)


/obj/item/clothing/suit/hooded/cultrobes/void/examine(mob/user)
	. = ..()
	if(!isheretic(user))
		return

	// Let examiners know this works as a focus only if the hood is down
	. += span_notice("Позволяет использовать еретические заклинания, пока капюшон опущен..")


/obj/item/clothing/suit/hooded/cultrobes/void/Initialize(mapload)
	. = ..()
	make_invisible()


/obj/item/clothing/suit/hooded/cultrobes/void/RemoveHood()
	. = ..()
	if(!.)
		return

	make_invisible()


/obj/item/clothing/suit/hooded/cultrobes/void/EngageHood()
	. = ..()
	if(!.)
		return

	make_visible()


/// Makes our cloak "invisible". Not the wearer, the cloak itself.
/obj/item/clothing/suit/hooded/cultrobes/void/proc/make_invisible()
	if(HAS_TRAIT_FROM(src, TRAIT_EXAMINE_SKIP, UID()))
		return

	add_traits(list(TRAIT_NO_STRIP, TRAIT_NO_WORN_ICON, TRAIT_EXAMINE_SKIP), UID())
	RemoveElement(/datum/element/heretic_focus)

	if(!isliving(loc))
		return

	var/mob/living/owner = loc
	owner.update_inv_wear_suit()
	REMOVE_TRAIT(loc, TRAIT_RESIST_COLD, UID())
	loc.balloon_alert(loc, "плащ скрыт")
	loc.visible_message(span_notice("Свет искажается вокруг [declent_ru(GENITIVE)]!"))


/// Makes our cloak "visible" again.
/obj/item/clothing/suit/hooded/cultrobes/void/proc/make_visible()
	if(!HAS_TRAIT_FROM(src, TRAIT_EXAMINE_SKIP, UID()))
		return

	remove_traits(list(TRAIT_NO_STRIP, TRAIT_NO_WORN_ICON, TRAIT_EXAMINE_SKIP), UID())
	AddElement(/datum/element/heretic_focus)

	if(!isliving(loc))
		return

	var/mob/living/owner = loc
	owner.update_inv_wear_suit()
	ADD_TRAIT(loc, TRAIT_RESIST_COLD, UID())
	loc.balloon_alert(loc, "плащ виден")
	loc.visible_message(span_notice("Калейдоскоп цветов обрушивается на [loc.declent_ru(NOMINATIVE)], вырисовывая ранее скрытый плащ!"))
