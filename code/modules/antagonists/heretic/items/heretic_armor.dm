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
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/gun/projectile/shotgun/boltaction/lionhunter)
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
// Without an explicit button icon the action fell back to the generic "default" sprite (the wrong
// ignition icon the user reported); point it at the heretic "flames" action icon to match TG's fireball button.
/datum/action/item_action/toggle_flames
	name = "Переключить пламя"
	// TG uses the "fireball" sprite for this toggle; master220's default action sheet (actions.dmi) has it.
	button_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "fireball"
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon = 'icons/mob/actions/backgrounds.dmi'
	overlay_icon_state = "bg_heretic_border"


// Опалённая Мантия (Scorched Mantle) — Ash path robes.
// Completely fire-proof, and (matching TG) can passively set the wearer ablaze via a toggle. Building up
// fire stacks on yourself empowers your ashen spells (see is_ash_empowered). The wearer takes no fire damage.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash
	name = "опалённая мантия"
	desc = "Тлеющая мантия из пепла и углей. Жар не причиняет ей вреда — лишь питает её."
	icon_state = "ash_armor"
	// Base eldritch robes set HIDESHOES, which made the wearer's shoes vanish. The Scorched Mantle
	// (matching TG) shouldn't hide footwear — only the jumpsuit.
	flags_inv = HIDEJUMPSUIT
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
	// Dedicated scorched-mantle hood sprites (ported from TG). The base eldritch hood's icons
	// only had an "eldritch" state, so without these the ash hood fell back to the wrong sprite.
	icon = 'icons/obj/clothing/heretic_ash_hood.dmi'
	icon_state = "ash_armor"
	// Paradise resolves the worn (on-mob) sprite via onmob_sheets[slot], not worn_icon.
	onmob_sheets = list(
		ITEM_SLOT_HEAD_STRING = 'icons/mob/clothing/heretic_ash_hood.dmi',
	)
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


// Собранный Раймент (Salvaged Remains / Reassembled Raiment) — Rust path robes.
// Matching TG: provides solid armor that surges to a much higher tier (plus pierce immunity) while the
// wearer stands on rusted tiles, and acts as a focus while hooded (inherited from the eldritch base).
// master220 uses /datum/armor datums + set_armor() rather than TG's armor_type, so we swap between the
// base and on-rust armor datums on movement.
/datum/armor/eldritch_armor_rust
	melee = 30
	bullet = 30
	laser = 30
	energy = 30
	bomb = 50
	bio = 30
	fire = 30
	acid = 30


/datum/armor/eldritch_armor_rust/on_rust
	melee = 60
	bullet = 60
	laser = 60
	energy = 60
	bomb = 100
	bio = 60
	fire = 60
	acid = 60


/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust
	name = "собранный раймент"
	desc = "Прикосновение к складкам этой простой робы наполняет вас тревогой. \
			Даже один взгляд вызывает головокружение. \
			Что-то пульсирует под ней, словно силясь затянуть вас внутрь."
	icon = 'icons/obj/clothing/heretic_rust_robe.dmi'
	icon_state = "rust_armor"
	item_state = "rust_armor"
	// master220 resolves the worn (on-mob) sprite via onmob_sheets[slot] - the rust robe keeps TG's
	// animated rust shimmer here.
	onmob_sheets = list(
		ITEM_SLOT_CLOTH_OUTER_STRING = 'icons/mob/clothing/heretic_rust_robe.dmi',
	)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 50, BIO = 30, FIRE = 30, ACID = 30)
	/// TRUE while we are currently granting the empowered on-rust armor.
	var/rusted = FALSE


/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/get_ru_names()
	return alist(
		NOMINATIVE = "собранный раймент",
		GENITIVE = "собранного раймента",
		DATIVE = "собранному райменту",
		ACCUSATIVE = "собранный раймент",
		INSTRUMENTAL = "собранным райментом",
		PREPOSITIONAL = "собранном райменте",
	)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/examine(mob/user)
	. = ..()
	if(!isheretic(user))
		return
	. += span_notice("Стоя на ржавчине, вы получаете значительно усиленную защиту.")


/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(slot == ITEM_SLOT_CLOTH_OUTER)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move), override = TRUE)
		update_rust_state(user)
	else
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		reset_rust_armor(user)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	reset_rust_armor(user)


/// Signal proc for [COMSIG_MOVABLE_MOVED]: re-evaluate the on-rust armor bonus when the wearer moves.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/on_move(mob/living/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	update_rust_state(source)


/// Grants the empowered on-rust armor (+ pierce immunity) while standing on a rusted tile, reverting otherwise.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/update_rust_state(mob/living/wearer)
	var/turf/wearer_turf = get_turf(wearer)
	if(HAS_TRAIT(wearer_turf, TRAIT_RUSTY))
		if(rusted)
			return
		rusted = TRUE
		set_armor(/datum/armor/eldritch_armor_rust/on_rust)
		if(isliving(wearer))
			ADD_TRAIT(wearer, TRAIT_PIERCEIMMUNE, UID())
		return
	reset_rust_armor(wearer)


/// Reverts to the base armor and removes the on-rust pierce immunity.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/reset_rust_armor(mob/living/wearer)
	if(!rusted)
		return
	rusted = FALSE
	set_armor(/datum/armor/eldritch_armor_rust)
	if(isliving(wearer))
		REMOVE_TRAIT(wearer, TRAIT_PIERCEIMMUNE, UID())


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust
	name = "капюшон собранного раймента"
	desc = "Прикосновение к складкам этой простой робы наполняет вас тревогой. \
			Даже один взгляд вызывает головокружение. \
			Что-то пульсирует под ней, словно силясь затянуть вас внутрь."
	icon = 'icons/obj/clothing/heretic_rust_hood.dmi'
	icon_state = "rust_armor"
	onmob_sheets = list(
		ITEM_SLOT_HEAD_STRING = 'icons/mob/clothing/heretic_rust_hood.dmi',
	)
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 50, BIO = 30, FIRE = 30, ACID = 30)
	/// TRUE while granting the empowered on-rust armor.
	var/rusted = FALSE


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust/get_ru_names()
	return alist(
		NOMINATIVE = "капюшон собранного раймента",
		GENITIVE = "капюшона собранного раймента",
		DATIVE = "капюшону собранного раймента",
		ACCUSATIVE = "капюшон собранного раймента",
		INSTRUMENTAL = "капюшоном собранного раймента",
		PREPOSITIONAL = "капюшоне собранного раймента",
	)


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(slot == ITEM_SLOT_HEAD)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move), override = TRUE)
		update_rust_state(user)
	else
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		reset_rust_armor(user)


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	reset_rust_armor(user)


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust/proc/on_move(mob/living/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	update_rust_state(source)


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust/proc/update_rust_state(mob/living/wearer)
	var/turf/wearer_turf = get_turf(wearer)
	if(HAS_TRAIT(wearer_turf, TRAIT_RUSTY))
		if(rusted)
			return
		rusted = TRUE
		set_armor(/datum/armor/eldritch_armor_rust/on_rust)
		return
	reset_rust_armor(wearer)


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust/proc/reset_rust_armor(mob/living/wearer)
	if(!rusted)
		return
	rusted = FALSE
	set_armor(/datum/armor/eldritch_armor_rust)


// Сияющее Облачение (Resplendent Regalia) — Moon path robes.
// Matching TG: the robe gives NO armor, but makes the wearer fully immune to disabling effects, pacifies
// them and prevents the use of firearms. The moon blade can still be used (and, with a Moonlight Amulet,
// used while pacified). TG also converts all incoming damage into brain damage and gibs you on death while
// wearing it - those two mechanics need a damage-intercept hook and are left for the runtime pass.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon
	name = "сияющее облачение"
	desc = "Переливающаяся мантия из лунного света и зеркальных нитей. Она не защищает тело — \
			лишь освобождает разум от оков боли и страха."
	// Moon robe sprites (item + worn) extracted from tg's armor sheet; the base cult-robe dmi has no
	// moon_armor state, which is why the regalia rendered with a wrong/blank sprite.
	icon = 'icons/obj/clothing/heretic_moon_robe.dmi'
	icon_state = "moon_armor"
	item_state = "moon_armor"
	// master220 resolves the worn (on-mob) sprite via onmob_sheets[slot].
	onmob_sheets = list(
		ITEM_SLOT_CLOTH_OUTER_STRING = 'icons/mob/clothing/heretic_moon_robe.dmi',
	)
	// The regalia has no protective value of its own (tg parity).
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	// Only the moon blade may be carried in it (no Lionhunter's Rifle).
	allowed = list(/obj/item/melee/sickly_blade/moon)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/moon
	/// The traits the regalia grants while worn - full immunity to disabling effects + pacification + no guns.
	var/static/list/regalia_traits = list(
		TRAIT_STUNIMMUNE,
		TRAIT_SLEEPIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_BATON_RESISTANCE,
		TRAIT_PACIFISM,
		TRAIT_NO_GUNS,
	)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/get_ru_names()
	return alist(
		NOMINATIVE = "сияющее облачение",
		GENITIVE = "сияющего облачения",
		DATIVE = "сияющему облачению",
		ACCUSATIVE = "сияющее облачение",
		INSTRUMENTAL = "сияющим облачением",
		PREPOSITIONAL = "сияющем облачении",
	)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/examine(mob/user)
	. = ..()
	if(!isheretic(user))
		return
	. += span_notice("Делает вас невосприимчивым к выводящим из строя эффектам, но не даёт брони, \
		пацифицирует и не позволяет пользоваться огнестрелом. Бить клинком можно только с Амулетом Лунного Света.")


/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(slot == ITEM_SLOT_CLOTH_OUTER)
		user.add_traits(regalia_traits, UID())
	else
		user.remove_traits(regalia_traits, UID())


/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	user.remove_traits(regalia_traits, UID())


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/moon
	name = "капюшон сияющего облачения"
	desc = "Переливающийся капюшон из лунного света и зеркальных нитей."
	icon = 'icons/obj/clothing/heretic_moon_hood.dmi'
	icon_state = "moon_armor"
	onmob_sheets = list(
		ITEM_SLOT_HEAD_STRING = 'icons/mob/clothing/heretic_moon_hood.dmi',
	)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/moon/get_ru_names()
	return alist(
		NOMINATIVE = "капюшон сияющего облачения",
		GENITIVE = "капюшона сияющего облачения",
		DATIVE = "капюшону сияющего облачения",
		ACCUSATIVE = "капюшон сияющего облачения",
		INSTRUMENTAL = "капюшоном сияющего облачения",
		PREPOSITIONAL = "капюшоне сияющего облачения",
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
	/// Whether the cloak is currently hidden (hood up). Starts TRUE so Initialize()'s make_visible() runs the initial focus setup.
	var/cloak_hidden = TRUE
	/// Hidden pockets sewn into the cloak (TG's void_cloak storage). Lets the heretic stash ritual items.
	var/obj/item/storage/internal/pockets


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
	// TG's void cloak has hidden pockets (/datum/storage/pockets/void_cloak). master220 has no /datum/storage,
	// so we use the engine's internal-storage item the same way /obj/item/clothing/suit/storage does.
	pockets = new(src)
	pockets.storage_slots = 3
	pockets.max_w_class = WEIGHT_CLASS_NORMAL // so a sickly blade / bodypart / organ can be hidden away
	pockets.max_combined_w_class = 5
	// Matches TG: crafted/worn with the hood DOWN -> cloak is visible and acts as a focus.
	make_visible()


/obj/item/clothing/suit/hooded/cultrobes/void/Destroy()
	QDEL_NULL(pockets)
	return ..()


/obj/item/clothing/suit/hooded/cultrobes/void/attack_hand(mob/user)
	if(!pockets || !pockets.handle_attack_hand(user))
		return ..()


/obj/item/clothing/suit/hooded/cultrobes/void/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	if(!pockets || !pockets.handle_mousedrop(user, over_object))
		return ..()


/obj/item/clothing/suit/hooded/cultrobes/void/attackby(obj/item/item, mob/user, params)
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !pockets)
		return .
	return pockets.attackby(item, user, params)


/obj/item/clothing/suit/hooded/cultrobes/void/emp_act(severity)
	. = ..()
	pockets?.emp_act(severity)


// RemoveHood() = lowering the hood (hood DOWN). TG: hood down -> cloak visible + focus.
/obj/item/clothing/suit/hooded/cultrobes/void/RemoveHood()
	. = ..()
	if(!.)
		return

	make_visible()


// EngageHood() = raising the hood (hood UP). TG: hood up -> cloak hidden, no focus.
/obj/item/clothing/suit/hooded/cultrobes/void/EngageHood()
	. = ..()
	if(!.)
		return

	make_invisible()


/// Makes our cloak "invisible" (hood up). Not the wearer, the cloak itself. Stops acting as a focus.
/obj/item/clothing/suit/hooded/cultrobes/void/proc/make_invisible()
	if(cloak_hidden)
		return
	cloak_hidden = TRUE

	add_traits(list(TRAIT_NO_STRIP, TRAIT_NO_WORN_ICON, TRAIT_EXAMINE_SKIP), UID())
	RemoveElement(/datum/element/heretic_focus)

	if(!isliving(loc))
		return

	var/mob/living/owner = loc
	owner.update_worn_oversuit()
	REMOVE_TRAIT(loc, TRAIT_RESIST_COLD, UID())
	loc.balloon_alert(loc, "плащ скрыт")
	loc.visible_message(span_notice("Свет искажается вокруг [declent_ru(GENITIVE)]!"))


/// Makes our cloak "visible" again (hood down). Acts as a focus.
/obj/item/clothing/suit/hooded/cultrobes/void/proc/make_visible()
	if(!cloak_hidden)
		return
	cloak_hidden = FALSE

	remove_traits(list(TRAIT_NO_STRIP, TRAIT_NO_WORN_ICON, TRAIT_EXAMINE_SKIP), UID())
	AddElement(/datum/element/heretic_focus)

	if(!isliving(loc))
		return

	var/mob/living/owner = loc
	owner.update_worn_oversuit()
	ADD_TRAIT(loc, TRAIT_RESIST_COLD, UID())
	loc.balloon_alert(loc, "плащ виден")
	loc.visible_message(span_notice("Калейдоскоп цветов обрушивается на [loc.declent_ru(NOMINATIVE)], вырисовывая ранее скрытый плащ!"))
