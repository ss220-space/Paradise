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
	return alist(
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
	return alist(
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



/**
 * Returns TRUE if this mob can currently cast EMPOWERED ashen spells.
 * Matches TG: the caster must be human, wearing the Scorched Mantle, and carrying more than 3 fire stacks.
 */
/proc/is_ash_empowered(mob/living/owner)
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	if(!istype(human_owner.wear_suit, /obj/item/clothing/suit/hooded/cultrobes/eldritch/ash))
		return FALSE
	return human_owner.fire_stacks > 3


// Toggle action for the Scorched Mantle's passive flame generation.
/datum/action/item_action/toggle_flames
	name = "Переключить пламя"


// Опалённая Мантия (Scorched Mantle) — Ash path robes.
// Completely fire-proof, and (matching TG) can passively set the wearer ablaze via a toggle. Building up
// fire stacks on yourself empowers your ashen spells (see is_ash_empowered). The wearer takes no fire damage.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash
	name = "опалённая мантия"
	desc = "Тлеющая мантия из пепла и углей. Жар не причиняет ей вреда — лишь питает её."
	icon_state = "eldritch_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/ash
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 35, "bio" = 20, "rad" = 20, "fire" = 100, "acid" = 20)
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF | LAVA_PROOF
	heat_protection = FULL_BODY
	max_heat_protection_temperature = 50000
	cold_protection = FULL_BODY
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	actions_types = list(/datum/action/item_action/toggle, /datum/action/item_action/toggle_flames)
	/// If our robes are actively generating flames on the wearer.
	var/flame_generation = FALSE
	/// Cooldown before our robes create more fire stacks.
	COOLDOWN_DECLARE(flame_creation)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/get_ru_names()
	return alist(
		NOMINATIVE = "опалённая мантия",
		GENITIVE = "опалённой мантии",
		DATIVE = "опалённой мантии",
		ACCUSATIVE = "опалённую мантию",
		INSTRUMENTAL = "опалённой мантией",
		PREPOSITIONAL = "опалённой мантии",
	)


// The base hooded robe routes every action button to ToggleHood; dispatch on the action type so the
// flame toggle button toggles flames instead.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/ui_action_click(mob/user, datum/action/action, leftclick)
	if(istype(action, /datum/action/item_action/toggle_flames))
		toggle_flames(user)
		return
	return ..()


/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	// Turn the flames off when the mantle leaves the wearer, mirroring TG's on_robes_lost.
	if(flame_generation)
		toggle_flames(user)


/// Starts/stops the passive generation of fire stacks on our wearer.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/proc/toggle_flames(mob/living/user)
	if(!isliving(user))
		return
	flame_generation = !flame_generation
	if(flame_generation)
		START_PROCESSING(SSobj, src)
	else
		user.ExtinguishMob()
		STOP_PROCESSING(SSobj, src)
	user.balloon_alert(user, flame_generation ? "пламя зажжено" : "пламя потушено")


/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, flame_creation))
		return
	var/mob/living/wearer = loc
	if(!isliving(wearer))
		STOP_PROCESSING(SSobj, src)
		flame_generation = FALSE
		return
	COOLDOWN_START(src, flame_creation, 5 SECONDS)
	wearer.adjust_fire_stacks(1)
	wearer.IgniteMob()


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/ash
	name = "капюшон опалённой мантии"
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 15, "bio" = 10, "rad" = 10, "fire" = 100, "acid" = 10)


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/ash/get_ru_names()
	return alist(
		NOMINATIVE = "капюшон опалённой мантии",
		GENITIVE = "капюшона опалённой мантии",
		DATIVE = "капюшону опалённой мантии",
		ACCUSATIVE = "капюшон опалённой мантии",
		INSTRUMENTAL = "капюшоном опалённой мантии",
		PREPOSITIONAL = "капюшоне опалённой мантии",
	)


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
	return alist(
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
	return alist(
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
	owner.update_worn_oversuit()
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
	owner.update_worn_oversuit()
	ADD_TRAIT(loc, TRAIT_RESIST_COLD, UID())
	loc.balloon_alert(loc, "плащ виден")
	loc.visible_message(span_notice("Калейдоскоп цветов обрушивается на [loc.declent_ru(NOMINATIVE)], вырисовывая ранее скрытый плащ!"))
