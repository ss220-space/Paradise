/obj/item/clothing/head/hooded/cult_hoodie/eldritch
	name = "ominous hood"
	desc = "Рваный, покрытый пылью капюшон. Внутри виднеются жуткие глаза."
	icon_state = "eldritch"
	flags_inv = HIDEMASK|HIDEHEADSETS|HIDEGLASSES|HIDENAME|HIDEHAIR
	flash_protect = FLASH_PROTECTION_WELDER
	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi',
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
	name = "ominous mantle"
	desc = "Рваная, пыльная мантия. Внутри — видны жуткие глаза."
	gender = FEMALE
	icon_state = "eldritch_armor"
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/gun/projectile/shotgun/boltaction/lionhunter, /obj/item/flashlight/lantern/heretic)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50,"energy" = 50, "bomb" = 35, "bio" = 20, "fire" = 20, "acid" = 20)
	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi',
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

	. += span_notice("Позволяет использовать еретические заклинания при надетом капюшоне.")


/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock
	name = "shifting guise"
	desc = "Набор затенённых одеяний с глубоким капюшоном. Невозможно разглядеть, кто под ним скрывается."
	icon_state = "lock_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/lock
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 40, "bomb" = 40, "bio" = 40, "fire" = 40, "acid" = 40)
	/// Traits granted to a heretic wearer while hooded: AI-untrackable + the shifting guise (hidden identity/voice, silent steps).
	var/static/list/guise_traits = list(TRAIT_AI_UNTRACKABLE, TRAIT_SILENT_FOOTSTEPS, TRAIT_UNKNOWN_APPEARANCE, TRAIT_UNKNOWN_VOICE)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock/get_ru_names()
	return alist(
		NOMINATIVE = "изменчивая личина",
		GENITIVE = "изменчивой личины",
		DATIVE = "изменчивой личине",
		ACCUSATIVE = "изменчивую личину",
		INSTRUMENTAL = "изменчивой личиной",
		PREPOSITIONAL = "изменчивой личине",
	)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(slot != ITEM_SLOT_CLOTH_OUTER)
		return
	if(!isheretic(user))
		robes_side_effect(user)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	remove_guise(user)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock/EngageHood()
	. = ..()
	if(!.) // hood didn't actually go up (already up, no robe worn, head occupied, etc.)
		return
	if(isheretic(loc))
		grant_guise(loc)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock/RemoveHood()
	var/mob/living/wearer = isliving(hood?.loc) ? hood.loc : (isliving(loc) ? loc : null)
	. = ..()
	if(. && wearer) // RemoveHood only returns TRUE when the hood was actually up, i.e. the guise was active
		remove_guise(wearer)


/// Grants the full Shifting Guise to a heretic wearer: hidden identity/voice + silent steps, plus full camera camo.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock/proc/grant_guise(mob/living/user)
	user.add_traits(guise_traits, UID())
	user.AddComponent(/datum/component/camera_camo)


/// Strips the Shifting Guise. Idempotent: safe to call when it was never granted.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock/proc/remove_guise(mob/living/user)
	if(!user)
		return
	user.remove_traits(guise_traits, UID())
	qdel(user.GetComponent(/datum/component/camera_camo))


/// A non-heretic who dons the guise is violently relieved of everything they are carrying.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock/proc/robes_side_effect(mob/living/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/victim = user
	var/turf/our_turf = get_turf(victim)
	var/list/turf/nearby_turfs = RANGE_TURFS(5, our_turf) - our_turf
	for(var/obj/item/to_throw in victim.get_equipped_items())
		if(victim.drop_item_ground(to_throw))
			to_throw.throw_at(pick(nearby_turfs), 2, 1, spin = TRUE)


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/lock
	name = "shifting guise hood"
	icon_state = "lock_armor"
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 40, "bomb" = 40, "bio" = 40, "fire" = 40, "acid" = 40)


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/lock/get_ru_names()
	return alist(
		NOMINATIVE = "капюшон изменчивой личины",
		GENITIVE = "капюшона изменчивой личины",
		DATIVE = "капюшону изменчивой личины",
		ACCUSATIVE = "капюшон изменчивой личины",
		INSTRUMENTAL = "капюшоном изменчивой личины",
		PREPOSITIONAL = "капюшоне изменчивой личины",
	)

/datum/action/item_action/toggle_flames
	name = "Переключить пламя"
	button_icon_state = "fireball"
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon = 'icons/mob/actions/backgrounds.dmi'
	overlay_icon_state = "bg_heretic_border"


/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash
	name = "scorched mantle"
	desc = "Тлеющая мантия из пепла и углей. Жар не причиняет ей вреда — лишь питает её."
	icon_state = "ash_armor"
	flags_inv = HIDEJUMPSUIT
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/ash
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 35, "bio" = 20, "fire" = 100, "acid" = 20)
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


/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/ui_action_click(mob/user, datum/action/action, leftclick)
	if(istype(action, /datum/action/item_action/toggle_flames))
		toggle_flames(user)
		return
	return ..()


/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/dropped(mob/user, slot, silent = FALSE)
	. = ..()
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
	name = "scorched mantle hood"
	icon_state = "ash_armor"
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 15, "bio" = 10, "fire" = 100, "acid" = 10)


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/ash/get_ru_names()
	return alist(
		NOMINATIVE = "капюшон опалённой мантии",
		GENITIVE = "капюшона опалённой мантии",
		DATIVE = "капюшону опалённой мантии",
		ACCUSATIVE = "капюшон опалённой мантии",
		INSTRUMENTAL = "капюшоном опалённой мантии",
		PREPOSITIONAL = "капюшоне опалённой мантии",
	)


/datum/action/item_action/toggle_gravity
	name = "Переключить левитацию"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "cosmic_domain"
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon = 'icons/mob/actions/backgrounds.dmi'
	overlay_icon_state = "bg_heretic_border"


/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic
	name = "starwoven cloak"
	desc = "Сияющие самоцветы источают струйки силы, кружащие вокруг и окутывающие владельца тусклым сиянием. \
			Глядя на плащ, невозможно отделаться от ощущения, что за тобой наблюдают."
	icon_state = "cosmic_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/cosmic
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 35, "bio" = 20, "fire" = 20, "acid" = 20)
	clothing_flags = STOPSPRESSUREDAMAGE
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	actions_types = list(/datum/action/item_action/toggle, /datum/action/item_action/toggle_gravity)
	/// Traits granted to the wearer while levitation is enabled.
	var/static/list/levitation_traits = list(TRAIT_NEGATES_GRAVITY, TRAIT_MOVE_FLYING)
	/// Whether our robes are currently making the wearer weightless.
	var/weightless_enabled = FALSE


/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/get_ru_names()
	return alist(
		NOMINATIVE = "звёздотканый плащ",
		GENITIVE = "звёздотканого плаща",
		DATIVE = "звёздотканому плащу",
		ACCUSATIVE = "звёздотканый плащ",
		INSTRUMENTAL = "звёздотканым плащом",
		PREPOSITIONAL = "звёздотканом плаще",
	)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/update_icon_state()
	icon_state = "cosmic_armor[suit_adjusted ? "_hood" : ""]"


/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/ui_action_click(mob/user, datum/action/action, leftclick)
	if(istype(action, /datum/action/item_action/toggle_gravity))
		toggle_gravity(user)
		return
	return ..()


/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	if(weightless_enabled)
		toggle_gravity(user)


/// Toggles the wearer's free movement in zero gravity.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/proc/toggle_gravity(mob/living/user)
	if(!isliving(user))
		return
	weightless_enabled = !weightless_enabled
	if(weightless_enabled)
		user.add_traits(levitation_traits, "cosmic_robe_levitation")
		user.balloon_alert(user, "левитация включена")
	else
		user.remove_traits(levitation_traits, "cosmic_robe_levitation")
		user.balloon_alert(user, "левитация выключена")


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/cosmic
	name = "starwoven hood"
	icon_state = "cosmic_armor"
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 15, "bio" = 10, "fire" = 10, "acid" = 10)
	clothing_flags = STOPSPRESSUREDAMAGE
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/cosmic/get_ru_names()
	return alist(
		NOMINATIVE = "звёздотканый капюшон",
		GENITIVE = "звёздотканого капюшона",
		DATIVE = "звёздотканому капюшону",
		ACCUSATIVE = "звёздотканый капюшон",
		INSTRUMENTAL = "звёздотканым капюшоном",
		PREPOSITIONAL = "звёздотканом капюшоне",
	)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh
	name = "writhing embrace"
	desc = "Гниющая туша, а может, и несколько, скрученные в мясистые полипы, спутанные кишки и треснувшие кости. \
			Как такое вообще \"носят\" — выше всякого разумения. Оно шевелится, когда думает, что за ним не наблюдают."
	icon_state = "flesh_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/flesh
	armor = list("melee" = 70, "bullet" = 40, "laser" = 30, "energy" = 30, "bomb" = 35, "bio" = 100, "fire" = 0, "acid" = 100)
	/// The aura healing component on the wearer. Deleted when the robe is taken off.
	var/datum/component/healing_aura


/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh/get_ru_names()
	return alist(
		NOMINATIVE = "извивающиеся объятия",
		GENITIVE = "извивающихся объятий",
		DATIVE = "извивающимся объятиям",
		ACCUSATIVE = "извивающиеся объятия",
		INSTRUMENTAL = "извивающимися объятиями",
		PREPOSITIONAL = "извивающихся объятиях",
	)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(slot == ITEM_SLOT_CLOTH_OUTER)
		if(!healing_aura)
			healing_aura = user.AddComponent( \
				/datum/component/aura_healing, \
				range = 15, \
				brute_heal = 3, \
				burn_heal = 3, \
				blood_heal = 3, \
				suffocation_heal = 3, \
				stamina_heal = 15, \
				simple_heal = 3, \
				requires_visibility = FALSE, \
				limit_to_trait = TRAIT_HERETIC_SUMMON, \
				healing_color = COLOR_RED, \
			)
	else
		QDEL_NULL(healing_aura)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	QDEL_NULL(healing_aura)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh/Destroy()
	QDEL_NULL(healing_aura)
	return ..()


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/flesh
	name = "writhing embrace hood"
	icon_state = "flesh_armor"
	armor = list("melee" = 40, "bullet" = 25, "laser" = 20, "energy" = 20, "bomb" = 20, "bio" = 60, "fire" = 0, "acid" = 60)


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/flesh/get_ru_names()
	return alist(
		NOMINATIVE = "капюшон извивающихся объятий",
		GENITIVE = "капюшона извивающихся объятий",
		DATIVE = "капюшону извивающихся объятий",
		ACCUSATIVE = "капюшон извивающихся объятий",
		INSTRUMENTAL = "капюшоном извивающихся объятий",
		PREPOSITIONAL = "капюшоне извивающихся объятий",
	)


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/flesh/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(slot == ITEM_SLOT_HEAD && ishuman(user))
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
		hud.show_to(user)


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/flesh/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	if(ishuman(user))
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
		hud.hide_from(user)


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
	name = "reassembled raiment"
	desc = "Прикосновение к складкам этой простой на вид робы наполняет вас тревогой, \
			а один лишь беглый взгляд вызывает головокружение. \
			Что-то пульсирует под ней, словно силясь затянуть вас внутрь."
	icon_state = "rust_armor"
	item_state = "rust_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 50, BIO = 30, FIRE = 30, ACID = 30)
	/// TRUE while we are currently granting the empowered on-rust armor (and showing the rusted look).
	var/rusted = FALSE
	/// The turf we're watching for it becoming rusted under a standing wearer.
	var/turf/listening_turf
	/// Invisible animatable atom placed in the wearer's vis_contents; we flick the rust-in/out animation on it.
	var/atom/movable/rust_overlay
	/// Worn overlay mirroring rust_overlay through render_source, so the flicked animation shows on the mob.
	var/mutable_appearance/rust_appearance
	/// The rust overlay drawn on the suit's own (inventory/in-hand) icon.
	var/image/object_overlay
	/// The rust overlay drawn on the hood's (inventory) icon.
	var/image/hood_object_overlay
	/// Render-target id shared between rust_overlay and rust_appearance.
	var/render_id
	/// Static counter guaranteeing a unique render id per equip.
	var/static/overlay_id = 0


/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/get_ru_names()
	return alist(
		NOMINATIVE = "воссозданное одеяние",
		GENITIVE = "воссозданного одеяния",
		DATIVE = "воссозданному одеянию",
		ACCUSATIVE = "воссозданное одеяние",
		INSTRUMENTAL = "воссозданным одеянием",
		PREPOSITIONAL = "воссозданном одеянии",
	)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/examine(mob/user)
	. = ..()
	if(!isheretic(user))
		return
	. += span_notice("Ваша защита значительно усиливается, когда вы стоите на ржавчине.")


/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/update_icon_state()
	icon_state = "rust_armor[suit_adjusted ? "_hood" : ""]"


/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(slot == ITEM_SLOT_CLOTH_OUTER)
		setup_rust_overlay(user)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move), override = TRUE)
		register_turf_listener(user)
		update_rust_state(user)
	else
		teardown_rust_overlay(user)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	teardown_rust_overlay(user)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/Destroy()
	QDEL_NULL(rust_overlay)
	rust_appearance = null
	return ..()


/// Builds the invisible vis_contents atom we flick the rust animation on, plus the matching worn render-source
/// overlay and the static item-icon overlays.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/setup_rust_overlay(mob/living/user)
	if(rust_overlay || !isliving(user))
		return
	overlay_id++
	render_id = "*heretic_rust_overlay_[overlay_id]"
	rust_overlay = new()
	rust_overlay.icon = 'icons/mob/clothing/suit.dmi'
	rust_overlay.render_target = render_id
	rust_overlay.vis_flags |= VIS_INHERIT_DIR | VIS_INHERIT_LAYER | VIS_INHERIT_ID
	user.vis_contents += rust_overlay // invisible itself (render_target); we just mirror its sprite onto the worn robe
	rust_appearance = new /mutable_appearance()
	rust_appearance.render_source = render_id
	if(!object_overlay)
		object_overlay = image('icons/obj/clothing/suits.dmi', icon_state = "rust_armor_overlay")
	if(!hood_object_overlay)
		hood_object_overlay = image('icons/obj/clothing/hats.dmi', icon_state = "rust_armor_overlay")


/// Tears everything setup_rust_overlay built back down and reverts to the base (un-rusted) armor.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/teardown_rust_overlay(mob/living/user)
	if(isliving(user))
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	clear_turf_listener()
	reset_rust_armor(user)
	if(rust_overlay)
		if(isliving(user))
			user.vis_contents -= rust_overlay
		QDEL_NULL(rust_overlay)
	rust_appearance = null
	cut_overlay(object_overlay)
	var/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust/our_hood = hood
	our_hood?.cut_overlay(hood_object_overlay)


/// Signal proc for [COMSIG_MOVABLE_MOVED]: re-evaluate the on-rust armor bonus when the wearer moves.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/on_move(mob/living/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	register_turf_listener(source)
	update_rust_state(source)


/// Watches the wearer's current tile so the robe rusts the moment the floor becomes rusted under a standing
/// wearer too, not only when they walk onto existing rust.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/register_turf_listener(mob/living/wearer)
	var/turf/current = get_turf(wearer)
	if(listening_turf == current)
		return
	clear_turf_listener()
	listening_turf = current
	if(listening_turf)
		RegisterSignal(listening_turf, SIGNAL_ADDTRAIT(TRAIT_RUSTY), PROC_REF(on_turf_rusted))


/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/clear_turf_listener()
	if(!listening_turf)
		return
	UnregisterSignal(listening_turf, SIGNAL_ADDTRAIT(TRAIT_RUSTY))
	listening_turf = null


/// The tile under us just rusted - surge our armor if the wearer is standing here.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/on_turf_rusted(datum/source)
	SIGNAL_HANDLER
	var/mob/living/wearer = loc
	if(isliving(wearer))
		update_rust_state(wearer)


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
		update_rust(wearer)
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
	update_rust(wearer)


/// The worn-sprite state prefix for the current hood position. When the hood is up the suit's body sprite is
/// the hooded "rust_armor_hood" (which draws the cowl over the head - the head slot itself is blank); when
/// down it's the plain "rust_armor". The rust animation/overlay states mirror this prefix.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/rust_state_prefix()
	return suit_adjusted ? "rust_armor_hood" : "rust_armor"


/// Plays the rust-in / rust-out animation and toggles the static item-icon overlays. The worn animation is
/// driven by flicking rust_overlay (mirrored onto the mob via rust_appearance in worn_overlays). The hood the
/// player sees is the suit's own hood-up body sprite, so its rust uses the matching "_hood" overlay states.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/update_rust(mob/living/wearer)
	var/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust/our_hood = hood
	var/prefix = rust_state_prefix()
	if(rusted)
		if(rust_overlay)
			rust_overlay.icon_state = "[prefix]_overlay" // settle here once the rust-in flick finishes
			flick("[prefix]_on", rust_overlay)
		add_overlay(object_overlay)
		our_hood?.add_overlay(hood_object_overlay)
	else
		if(rust_overlay)
			rust_overlay.icon_state = null
			flick("[prefix]_off", rust_overlay)
		cut_overlay(object_overlay)
		our_hood?.cut_overlay(hood_object_overlay)
	if(ishuman(wearer))
		wearer.update_worn_oversuit()
		wearer.balloon_alert(wearer, rusted ? "ржавчина укрепляет броню" : "ржавчина спадает")


/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	. = ..()
	if(isinhands || !rust_appearance)
		return
	rust_overlay?.icon_state = rusted ? "[rust_state_prefix()]_overlay" : null
	. += rust_appearance


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust
	name = "reassembled raiment hood"
	desc = "Прикосновение к складкам этой простой на вид робы наполняет вас тревогой, \
			а один лишь беглый взгляд вызывает головокружение. \
			Что-то пульсирует под ней, словно силясь затянуть вас внутрь."
	icon_state = "rust_armor"
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 50, BIO = 30, FIRE = 30, ACID = 30)
	/// TRUE while granting the empowered on-rust armor.
	var/rusted = FALSE
	/// The turf we're watching for it becoming rusted under a standing wearer.
	var/turf/listening_turf


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust/get_ru_names()
	return alist(
		NOMINATIVE = "капюшон воссозданного одеяния",
		GENITIVE = "капюшона воссозданного одеяния",
		DATIVE = "капюшону воссозданного одеяния",
		ACCUSATIVE = "капюшон воссозданного одеяния",
		INSTRUMENTAL = "капюшоном воссозданного одеяния",
		PREPOSITIONAL = "капюшоне воссозданного одеяния",
	)


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(slot == ITEM_SLOT_HEAD)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move), override = TRUE)
		register_turf_listener(user)
		update_rust_state(user)
	else
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		clear_turf_listener()
		reset_rust_armor(user)


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	clear_turf_listener()
	reset_rust_armor(user)


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust/proc/on_move(mob/living/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	register_turf_listener(source)
	update_rust_state(source)


/// Watches the wearer's current tile so the hood also rusts the moment the floor rusts under a standing
/// wearer, not only when they walk onto existing rust.
/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust/proc/register_turf_listener(mob/living/wearer)
	var/turf/current = get_turf(wearer)
	if(listening_turf == current)
		return
	clear_turf_listener()
	listening_turf = current
	if(listening_turf)
		RegisterSignal(listening_turf, SIGNAL_ADDTRAIT(TRAIT_RUSTY), PROC_REF(on_turf_rusted))


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust/proc/clear_turf_listener()
	if(!listening_turf)
		return
	UnregisterSignal(listening_turf, SIGNAL_ADDTRAIT(TRAIT_RUSTY))
	listening_turf = null


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust/proc/on_turf_rusted(datum/source)
	SIGNAL_HANDLER
	var/mob/living/wearer = loc
	if(isliving(wearer))
		update_rust_state(wearer)


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


/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon
	name = "resplendent regalia"
	desc = "Переливающаяся мантия, сотканная из лунного света и зеркальных нитей. Она не защищает тело — \
			лишь освобождает разум от оков боли и страха."
	icon_state = "moon_armor"
	item_state = "moon_armor"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "fire" = 0, "acid" = 0)
	allowed = list(/obj/item/melee/sickly_blade/moon)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/moon
	/// Traits the regalia grants while worn - full immunity to disabling effects + pacification + no guns.
	var/static/list/regalia_traits = list(
		TRAIT_STUNIMMUNE,
		TRAIT_SLEEPIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_BATON_RESISTANCE,
		TRAIT_PACIFISM,
		TRAIT_NO_GUNS,
	)
	/// The moon brain-health readout shown while worn. All incoming damage becomes brain damage here, so
	/// brain health IS your effective health - the moon bar shows it.
	var/atom/movable/screen/moon_health/moon_health_hud


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
		умиротворяет и не позволяет пользоваться огнестрельным оружием. Атаковать клинком возможно только с Амулетом Лунного Света.")


/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(slot == ITEM_SLOT_CLOTH_OUTER)
		user.add_traits(regalia_traits, UID())
		RegisterSignal(user, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(nullify_damage), override = TRUE)
		RegisterSignal(user, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(convert_to_brain), override = TRUE)
		RegisterSignal(user, COMSIG_LIVING_DEATH, PROC_REF(gory_end), override = TRUE)
		show_moon_hud(user)
	else
		user.remove_traits(regalia_traits, UID())
		UnregisterSignal(user, list(COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, COMSIG_MOB_APPLY_DAMAGE, COMSIG_LIVING_DEATH))
		hide_moon_hud(user)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	user.remove_traits(regalia_traits, UID())
	UnregisterSignal(user, list(COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, COMSIG_MOB_APPLY_DAMAGE, COMSIG_LIVING_DEATH))
	hide_moon_hud(user)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/Destroy()
	if(moon_health_hud)
		QDEL_NULL(moon_health_hud)
	return ..()


/// Swaps the wearer's normal health/stamina readouts for the moon brain-health bar.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/show_moon_hud(mob/living/user)
	if(!ishuman(user) || moon_health_hud)
		return
	var/mob/living/carbon/human/human_user = user
	var/datum/hud/our_hud = human_user.hud_used
	if(!our_hud)
		return
	moon_health_hud = new(null, our_hud)
	for(var/atom/movable/screen/to_hide in list(human_user.healths, human_user.healthdoll, human_user.stamina_bar))
		if(to_hide)
			to_hide.invisibility = INVISIBILITY_ABSTRACT
	our_hud.infodisplay += moon_health_hud
	human_user.client?.screen += moon_health_hud
	RegisterSignal(human_user, COMSIG_LIVING_LIFE, PROC_REF(update_moon_hud), override = TRUE)
	update_moon_hud(human_user)


/// Restores the normal health readouts and tears down the moon bar.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/hide_moon_hud(mob/living/user)
	if(!moon_health_hud)
		return
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		UnregisterSignal(human_user, COMSIG_LIVING_LIFE)
		var/datum/hud/our_hud = human_user.hud_used
		our_hud?.infodisplay -= moon_health_hud
		human_user.client?.screen -= moon_health_hud
		for(var/atom/movable/screen/to_show in list(human_user.healths, human_user.healthdoll, human_user.stamina_bar))
			if(to_show)
				to_show.invisibility = 0
	QDEL_NULL(moon_health_hud)


/// Refreshes the moon bar from the wearer's current brain damage. Fired each Life tick while worn.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/update_moon_hud(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	if(!moon_health_hud || !iscarbon(source))
		return
	moon_health_hud.update_brain_health(source.get_organ_loss(INTERNAL_ORGAN_BRAIN))


/// Nullifies all incoming non-brain damage (adds a 0 multiplier). The regalia takes no real damage - it's
/// rerouted into brain damage in convert_to_brain() instead. Brain damage itself passes through untouched.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/nullify_damage(mob/living/user, list/damage_mods, damage, damagetype, def_zone, sharp, used_weapon)
	SIGNAL_HANDLER
	if(damagetype == BRAIN)
		return
	damage_mods += 0


/// Combat damage the wearer takes is rerouted into brain damage at HALF strength (10 brute/burn -> 5 brain),
/// so the regalia softens hits as it converts them. Direct, non-combat damage (no COMSIG_MOB_APPLY_DAMAGE) is
/// simply negated by nullify_damage above.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/convert_to_brain(mob/living/user, damage, damagetype, def_zone, blocked, sharp, used_weapon, spread_damage, forced)
	SIGNAL_HANDLER
	if(damage <= 0)
		return
	if(!(damagetype in list(BRUTE, BURN, OXY, TOX, CLONE)))
		return
	user.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, damage * 0.5)


/// Death while wearing the Resplendent Regalia is a gory end - the head bursts.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/gory_end(mob/living/user, gibbed)
	SIGNAL_HANDLER
	if(gibbed || !ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	var/obj/item/organ/external/head = human_user.get_organ(BODY_ZONE_HEAD)
	if(!head)
		return
	human_user.visible_message(span_warning("Голова [human_user.declent_ru(GENITIVE)] лопается с тошнотворным хрустом!"))
	new /obj/effect/gibspawner/human(get_turf(human_user))
	head.dismember()


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/moon
	name = "resplendent regalia hood"
	desc = "Переливающийся капюшон, сотканный из лунного света и зеркальных нитей."
	icon_state = "moon_armor"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "fire" = 0, "acid" = 0)


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/moon/get_ru_names()
	return alist(
		NOMINATIVE = "капюшон сияющего облачения",
		GENITIVE = "капюшона сияющего облачения",
		DATIVE = "капюшону сияющего облачения",
		ACCUSATIVE = "капюшон сияющего облачения",
		INSTRUMENTAL = "капюшоном сияющего облачения",
		PREPOSITIONAL = "капюшоне сияющего облачения",
	)


/atom/movable/screen/moon_health
	name = "Лунное Здоровье"
	icon = 'icons/hud/moon_health_64x64.dmi'
	icon_state = "moon_hud_1"
	base_icon_state = "moon_hud"
	screen_loc = "EAST-2:16,CENTER-1:0"


/// Picks the dial state for the given brain damage. master220 brains cap at 120 damage (tg's were ~200), so
/// the six tg stages are rescaled onto 0-120 here.
/atom/movable/screen/moon_health/proc/update_brain_health(brain_damage)
	switch(brain_damage)
		if(-INFINITY to 20)
			icon_state = "[base_icon_state]_1"
		if(21 to 40)
			icon_state = "[base_icon_state]_2"
		if(41 to 60)
			icon_state = "[base_icon_state]_3"
		if(61 to 90)
			icon_state = "[base_icon_state]_4"
		if(91 to 110)
			icon_state = "[base_icon_state]_5"
		if(111 to INFINITY)
			icon_state = "[base_icon_state]_6"


/datum/armor/eldritch_armor_blade
	melee = 50
	bullet = 50
	laser = 50
	energy = 50
	bomb = 50
	bio = 50
	fire = 50
	acid = 50


/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade
	name = "shattered panoply"
	desc = "Заострённые края этого древнего доспеха несут истину, ведомую лишь воинам: \
			истинного бойца не отличить от клинка, что он держит."
	icon_state = "blade_armor"
	item_state = "blade_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/blade
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 50, FIRE = 50, ACID = 50)
	siemens_coefficient = 0
	allowed = list(/obj/item/melee/sickly_blade)
	/// Traits granted while worn by a heretic (shock immunity + baton-knockdown resistance).
	var/static/list/panoply_traits = list(TRAIT_SHOCKIMMUNE, TRAIT_BATON_RESISTANCE)
	/// TRUE while the anti-thief blade barrage is mid-volley (so we don't stack volleys).
	var/murdering_with_blades = FALSE


/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/get_ru_names()
	return alist(
		NOMINATIVE = "расколотая паноплия",
		GENITIVE = "расколотой паноплии",
		DATIVE = "расколотой паноплии",
		ACCUSATIVE = "расколотую паноплию",
		INSTRUMENTAL = "расколотой паноплией",
		PREPOSITIONAL = "расколотой паноплии",
	)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/examine(mob/user)
	. = ..()
	if(!isheretic(user))
		return
	. += span_notice("Полностью защищает от шока и сопротивляется оглушению дубинками, пока надета.")


/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(slot != ITEM_SLOT_CLOTH_OUTER)
		user.remove_traits(panoply_traits, UID())
		return
	if(isheretic(user))
		user.add_traits(panoply_traits, UID())
	else
		INVOKE_ASYNC(src, PROC_REF(start_throwing_blades), user)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	user.remove_traits(panoply_traits, UID())
	murdering_with_blades = FALSE


/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/proc/start_throwing_blades(mob/living/target)
	if(murdering_with_blades)
		return
	murdering_with_blades = TRUE

	var/delay = 2 SECONDS
	for(var/knife in 1 to 100)
		if(!should_keep_cutting(target))
			break
		addtimer(CALLBACK(src, PROC_REF(cut_em_good), target), delay * knife)
		delay = max(0.5 SECONDS, delay - 0.1 SECONDS)


/// Keeps the barrage going only while the (living, non-heretic) victim is still wearing us.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/proc/should_keep_cutting(mob/living/target)
	if(QDELETED(target) || target.stat == DEAD || isheretic(target))
		return FALSE
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/human/human_target = target
	return human_target.wear_suit == src


/// Spawns one blade on a nearby free tile and hurls it at the victim; if there's no room, cuts them directly.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/proc/cut_em_good(mob/living/target)
	if(!should_keep_cutting(target))
		return

	var/list/turf/valid_turfs = get_blade_turfs(target)
	if(!length(valid_turfs))
		target.apply_damage(15, BRUTE, sharp = TRUE) // sharp brute also rolls bleeding, no room for a thrown blade
		return

	throw_blade(pick(valid_turfs), target)


/// Open, unblocked tiles a few steps out from the victim, that a blade can come flying from.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/proc/get_blade_turfs(mob/user)
	var/list/turf/valid_turfs = list()
	for(var/turf/simulated/floor/candidate in range(4, user))
		if(candidate.density || get_dist(candidate, user) < 2)
			continue
		valid_turfs |= candidate
	return valid_turfs


/// Materialises a magic knife on `target_turf` and throws it into the victim.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/proc/throw_blade(turf/target_turf, mob/living/user)
	var/obj/item/kitchen/knife/magic/knife = new(target_turf)
	knife.throw_at(user, 50, 5, spin = FALSE)


/obj/item/kitchen/knife/magic
	name = "magic knife"
	desc = "Призрачный клинок, который рвётся к плоти недостойного."
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "dio_knife"
	item_state = "knife"
	throwforce = 15
	armour_penetration = 200 // most importantly, this ignores armour and shields
	embed_chance = 100
	pass_flags = PASSTABLE | PASSGRILLE | PASSFLAPS


/obj/item/kitchen/knife/magic/get_ru_names()
	return alist(
		NOMINATIVE = "магический нож",
		GENITIVE = "магического ножа",
		DATIVE = "магическому ножу",
		ACCUSATIVE = "магический нож",
		INSTRUMENTAL = "магическим ножом",
		PREPOSITIONAL = "магическом ноже",
	)


/obj/item/kitchen/knife/magic/Initialize(mapload)
	. = ..()
	add_filter("dio_knife", 2, list("type" = "outline", "color" = "#ececff", "size" = 1))
	QDEL_IN(src, 30 SECONDS) // don't litter the floor with phantom knives


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/blade
	name = "shattered panoply hood"
	desc = "Заострённые края этого древнего доспеха несут истину, ведомую лишь воинам."
	icon_state = "blade_armor"
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 50, FIRE = 50, ACID = 50)
	siemens_coefficient = 0 // shock insulation, matching the suit


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/blade/get_ru_names()
	return alist(
		NOMINATIVE = "капюшон расколотой паноплии",
		GENITIVE = "капюшона расколотой паноплии",
		DATIVE = "капюшону расколотой паноплии",
		ACCUSATIVE = "капюшон расколотой паноплии",
		INSTRUMENTAL = "капюшоном расколотой паноплии",
		PREPOSITIONAL = "капюшоне расколотой паноплии",
	)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/void
	name = "hollow weave"
	desc = "Поначалу пустое полотно этих одежд словно мерцает слабым холодным светом. Но проследив \
			изгибы складок внимательнее, понимаешь: точнее будет сказать, что оно пожирает весь свет."
	icon_state = "void_armor"
	item_state = "void_armor"
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/void
	armor = list(MELEE = 40, BULLET = 40, LASER = 50, ENERGY = 50, BOMB = 40, BIO = 40, FIRE = 40, ACID = 40)
	/// Cooldown before we can go back into stealth
	COOLDOWN_DECLARE(stealth_cooldown)
	/// Timer before our stealth runs out
	var/stealth_timer


/obj/item/clothing/suit/hooded/cultrobes/eldritch/void/get_ru_names()
	return alist(
		NOMINATIVE = "полое плетение",
		GENITIVE = "полого плетения",
		DATIVE = "полому плетению",
		ACCUSATIVE = "полое плетение",
		INSTRUMENTAL = "полым плетением",
		PREPOSITIONAL = "полом плетении",
	)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/void/examine(mob/user)
	. = ..()
	if(!isheretic(user))
		return
	. += span_notice("Время от времени плетение полностью поглощает направленную на вас атаку и на несколько секунд скрывает вас из виду.")


/obj/item/clothing/suit/hooded/cultrobes/eldritch/void/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(slot != ITEM_SLOT_CLOTH_OUTER)
		return
	if(!isheretic(user) && isliving(user))
		INVOKE_ASYNC(src, PROC_REF(freeze_thief), user)


/// A heathen who puts the Hollow Weave on is instantly deep-frozen.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/void/proc/freeze_thief(mob/living/thief)
	if(QDELETED(thief) || isheretic(thief))
		return
	to_chat(thief, span_userdanger("Пустота высасывает из вас всё тепло!"))
	thief.adjust_bodytemperature(-INFINITY)
	thief.apply_status_effect(/datum/status_effect/freon)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/void/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	if(!timeleft(stealth_timer))
		return
	deltimer(stealth_timer)
	end_stealth(user)


/// Every 20s the weave nullifies one attack entirely and cloaks the wearer for 5s.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/void/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "атаку", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	. = ..()
	if(.)
		return
	if(!COOLDOWN_FINISHED(src, stealth_cooldown))
		return
	COOLDOWN_START(src, stealth_cooldown, 20 SECONDS)
	stealth_timer = addtimer(CALLBACK(src, PROC_REF(end_stealth), owner), 5 SECONDS, TIMER_STOPPABLE)
	owner.visible_message(
		span_danger("[DECLENT_RU_CAP(owner, NOMINATIVE)] растворяется в пустоте!"),
		span_userdanger("Плетение поглощает [attack_text] и скрывает вас из виду!"),
	)
	owner.alpha = 0
	return TRUE


/// Fades the wearer back into view once the short stealth runs out.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/void/proc/end_stealth(mob/living/carbon/human/owner)
	if(QDELETED(owner))
		return
	animate(owner, time = 1 SECONDS, alpha = initial(owner.alpha))


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/void
	name = "hollow weave hood"
	desc = "Поначалу пустое полотно этих одежд словно мерцает слабым холодным светом. Но проследив \
			изгибы складок внимательнее, понимаешь: точнее будет сказать, что оно пожирает весь свет."
	icon_state = "void_armor"
	armor = list(MELEE = 40, BULLET = 40, LASER = 50, ENERGY = 50, BOMB = 40, BIO = 40, FIRE = 40, ACID = 40)


/obj/item/clothing/head/hooded/cult_hoodie/eldritch/void/get_ru_names()
	return alist(
		NOMINATIVE = "капюшон полого плетения",
		GENITIVE = "капюшона полого плетения",
		DATIVE = "капюшону полого плетения",
		ACCUSATIVE = "капюшон полого плетения",
		INSTRUMENTAL = "капюшоном полого плетения",
		PREPOSITIONAL = "капюшоне полого плетения",
	)


/obj/item/clothing/head/hooded/cult_hoodie/void
	name = "void hood"
	desc = "Чёрный, как смола, не отражающий свет. Покрыт рунами. \
			С каждым импульсом его тьмы вы теряете понимание того, что видите."
	icon_state = "void_cloak"
	flags_inv = NONE
	flags_cover = NONE
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 15, "bio" = 10, "fire" = 15, "acid" = 0)
	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi',
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
	name = "void cloak"
	desc = "Чёрный, как смола, не отражающий свет. Покрытый рунами. \
			С каждым импульсом его тьмы вы теряете понимание того, что видите."
	icon_state = "void_cloak"
	allowed = list(/obj/item/melee/sickly_blade)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/void
	flags_inv = NONE
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30,"energy" = 30, "bomb" = 15, "bio" = 0, "fire" = 0, "acid" = 0)
	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi',
	)
	/// Whether the cloak is currently hidden (hood up). Starts TRUE so Initialize()'s make_visible() runs the initial focus setup.
	var/cloak_hidden = TRUE
	/// Hidden pockets sewn into the cloak. Lets the heretic stash ritual items.
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

	. += span_notice("Позволяет использовать еретические заклинания, пока капюшон опущен.")


/obj/item/clothing/suit/hooded/cultrobes/void/Initialize(mapload)
	. = ..()
	pockets = new(src)
	pockets.storage_slots = 3
	pockets.max_w_class = WEIGHT_CLASS_NORMAL // so a sickly blade / bodypart / organ can be hidden away
	pockets.max_combined_w_class = 5
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


/obj/item/clothing/suit/hooded/cultrobes/void/RemoveHood()
	. = ..()
	if(!.)
		return

	make_visible()


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
