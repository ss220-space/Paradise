/// Gifts to give to players, will contain a nice toy or other fun item for them to play with.
/obj/item/gift
	name = "gift"
	desc = "Ураа!! Подарочееек!"
	icon = 'icons/obj/storage/wrapping.dmi'
	icon_state = "giftdeliverybox_map"
	item_state = "gift"
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_BULKY
	/// What type of thing are we guaranteed to spawn in with?
	var/obj/item/contains_type = null
	/// Whether to use the special Evil Santa gift list
	var/evil_santa_reward = FALSE

	/// Legacy shit for storage, useless, need to del it
	var/obj/item/gift = null

/obj/item/gift/get_ru_names()
	return list(
		NOMINATIVE = "подарок",
		GENITIVE = "подарка",
		DATIVE = "подарку",
		ACCUSATIVE = "подарок",
		INSTRUMENTAL = "подарком",
		PREPOSITIONAL = "подарке"
	)

/obj/item/gift/Initialize(mapload)
	. = ..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	base_pixel_x = pixel_x
	base_pixel_y = pixel_y
	if(!greyscale_colors)
		//Generate random valid colors for paper and ribbon
		var/generated_base_color = "#" + random_color()
		var/generated_ribbon_color = "#" + random_color()
		var/temp_base_hsv = RGBtoHSV(generated_base_color)
		var/temp_ribbon_hsv = RGBtoHSV(generated_ribbon_color)

		//If colors are too dark, set to original colors
		if(ReadHSV(temp_base_hsv)[3] < ReadHSV("7F7F7F")[3])
			generated_base_color = "#00FF00"
		if(ReadHSV(temp_ribbon_hsv)[3] < ReadHSV("7F7F7F")[3])
			generated_ribbon_color = "#FF0000"

		//Set layers to these colors, base then ribbon
		set_greyscale_colors(colors = list(generated_base_color, generated_ribbon_color))

	set_greyscale_config(text2path("/datum/greyscale_config/giftdeliverypackage[rand(1, 5)]"))


	if(!isnull(contains_type))
		return
	contains_type = get_gift_type()

/obj/item/gift/Destroy()
	QDEL_NULL(gift)
	return ..()

/obj/item/gift/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] заглядыва[PLUR_ET_YUT(user)] в [declent_ru(ACCUSATIVE)] и плачет до смерти! Похоже, [GEND_HE_SHE(user)] попал в список непослушных..."))
	return BRUTELOSS

/obj/item/gift/attack_self(mob/user)
	user.balloon_alert(user, "открытие подарка...")

	if(!do_after(user, 2.5 SECONDS, target = user))
		user.balloon_alert(user, "прервано!")
		return

	spawn_reward(user)

	qdel(src)

/obj/item/gift/proc/spawn_reward(mob/user)
	var/obj/item/thing = new contains_type(get_turf(user))

	if(QDELETED(thing)) // might contain something like metal rods that might merge with a stack on the ground
		user.visible_message(span_danger("О нет! В подарке, который открыл[GEND_A_O_I(user)] [user], ничего не оказалось!"))
		return

	user.visible_message(span_notice("[user] распаковыва[PLUR_ET_UT(user)] [declent_ru(ACCUSATIVE)] и обнаружива[PLUR_ET_UT(user)] внутри [thing.declent_ru(ACCUSATIVE)]!"))
	user.investigate_log("has unwrapped a present containing [thing.type].", INVESTIGATE_PRESENTS)
	user.put_in_hands(thing)
	thing.add_fingerprint(user)

/obj/item/gift/proc/get_gift_type()
	if(evil_santa_reward)
		return get_evil_santa_gift()

	var/static/list/gift_type_list = null

	if(isnull(gift_type_list))
		gift_type_list = list(
			/obj/item/ammo_box/magazine/toy/enforcer,
			/obj/item/banhammer,
			/obj/item/beach_ball,
			/obj/item/beach_ball/holoball,
			/obj/item/bikehorn,
			/obj/item/clothing/accessory/head_strip/black_cat,
			/obj/item/clothing/accessory/head_strip/comrad,
			/obj/item/clothing/accessory/head_strip/deathsquad,
			/obj/item/clothing/accessory/head_strip/federal,
			/obj/item/clothing/accessory/head_strip/fox,
			/obj/item/clothing/accessory/head_strip/frog,
			/obj/item/clothing/accessory/head_strip/greytide,
			/obj/item/clothing/accessory/head_strip/syndicate,
			/obj/item/clothing/accessory/head_strip/triforce,
			/obj/item/clothing/accessory/horrible,
			/obj/item/clothing/glasses/meson/heart,
			/obj/item/clothing/head/blob,
			/obj/item/clothing/head/new_year,
			/obj/item/clothing/mask/face/fawkes,
			/obj/item/clothing/neck/cloak/spacecloak,
			/obj/item/clothing/suit/space/new_year,
			/obj/item/clothing/suit/storage/zazalord,
			/obj/item/clothing/under/syndicate/tacticool,
			/obj/item/deck/cards,
			/obj/item/fluff/rapid_wheelchair_kit,
			/obj/item/grenade/confetti,
			/obj/item/grenade/smokebomb,
			/obj/item/grown/corncob,
			/obj/item/gun/projectile/automatic/toy,
			/obj/item/gun/projectile/automatic/toy/pistol/enforcer,
			/obj/item/gun/projectile/revolver/capgun,
			/obj/item/gun/projectile/shotgun/toy/crossbow,
			/obj/item/gun/projectile/shotgun/toy/tommygun,
			/obj/item/id_decal/centcom,
			/obj/item/id_decal/comrad,
			/obj/item/id_decal/emag,
			/obj/item/id_decal/federal,
			/obj/item/id_decal/gold,
			/obj/item/id_decal/prisoner,
			/obj/item/id_decal/silver,
			/obj/item/id_decal/syndie,
			/obj/item/instrument/guitar,
			/obj/item/instrument/violin,
			/obj/item/lipstick/random,
			/obj/item/melee/candy_sword,
			/obj/item/paicard,
			/obj/item/pen/invisible,
			/obj/item/pickaxe/silver,
			/obj/item/poster/random_contraband,
			/obj/item/reagent_containers/food/snacks/grown/ambrosia/deus,
			/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
			/obj/item/reagent_containers/food/snacks/sugar_coal,
			/obj/item/soap/deluxe,
			/obj/item/sord,
			/obj/item/spellbook/oneuse/fake_gib,
			/obj/item/stack/tile/fakespace/loaded,
			/obj/item/storage/belt/champion,
			/obj/item/storage/belt/utility/full,
			/obj/item/storage/box/fakesyndiesuit,
			/obj/item/storage/box/snappops,
			/obj/item/storage/fancy/crayons,
			/obj/item/storage/photo_album,
			/obj/item/storage/wallet,
			/obj/random/carp_plushie,
			/obj/random/figure,
			/obj/random/mech,
			/obj/random/plushie,
		)

		gift_type_list += subtypesof(/obj/item/clothing/head/collectable)
		gift_type_list += subtypesof(/obj/item/toy)

	var/gift_type = pick(gift_type_list)
	return gift_type

/obj/item/gift/proc/get_evil_santa_gift()
	var/static/list/evil_santa_gifts = list(
		/obj/item/storage/box/syndie_kit/mr_chang_technique,
		/obj/item/documents/syndicate/yellow/trapped,
		/obj/item/documents/nanotrasen,
		/obj/item/documents/syndicate/mining,
		/obj/item/paper/researchnotes,
		/obj/item/melee/energy/sword/pirate,
		/obj/item/stack/spacecash/c5000,
		/obj/item/stack/spacecash/c1000,
		/obj/item/storage/box/wizard/hardsuit,
		/obj/item/storage/box/syndie_kit/hardsuit,
		/obj/item/mod/control/pre_equipped/traitor,
		/obj/item/clothing/suit/space/hardsuit/champion/templar/premium,
		/obj/item/clothing/suit/space/hardsuit/soviet,
		/obj/item/clothing/suit/space/hardsuit/ancient,
		/obj/item/clothing/suit/space/eva/pirate/leader,
		/obj/item/clothing/head/helmet/space/eva/pirate/leader,
		/obj/item/hardsuit_shield/syndi,
		/obj/item/hardsuit_shield/wizard,
		/obj/vehicle/ridden/speedbike/red,
		/obj/vehicle/ridden/speedbike/red,
		/obj/vehicle/ridden/speedbike,
		/obj/vehicle/ridden/speedbike,
		/obj/vehicle/ridden/motorcycle,
		/obj/vehicle/ridden/motorcycle,
		/obj/vehicle/ridden/snowmobile/blue/key,
		/obj/vehicle/ridden/snowmobile/key,
		/obj/vehicle/ridden/car,
		/obj/item/dnainjector/insulation,
		/obj/item/dnainjector/nobreath,
		/obj/item/dnainjector/runfast,
		/obj/item/dnainjector/hulkmut,
		/obj/item/dnainjector/morph,
		/obj/item/dnainjector/xraymut,
		/obj/item/grenade/confetti,
		/obj/item/grenade/confetti,
		/obj/item/toy/plushie/pig,
		/obj/item/toy/plushie/pig,
		/obj/item/toy/plushie/pig,
		/obj/item/toy/xmas_cracker,
		/obj/item/toy/xmas_cracker,
		/obj/item/toy/pet_rock/naughty_coal,
		/obj/item/reagent_containers/food/snacks/sugar_coal,
	)
	return pick(evil_santa_gifts)

/obj/item/gift/evil_santa_reward
	evil_santa_reward = TRUE

/obj/item/gift/santa_special
	var/static/list/possible_tiers = list(
		/datum/loot_tier/first = 60,
		/datum/loot_tier/second = 15,
	)

/obj/item/gift/santa_special/spawn_reward(mob/user)
	var/tier_type = pick_weight_classic(possible_tiers)
	var/datum/loot_tier/loot_tier = new tier_type
	loot_tier.on_start_open(user, get_turf(user))

	user.visible_message(span_notice("[DECLENT_RU_CAP(user, NOMINATIVE)] распаковыва[PLUR_ET_UT(user)] [declent_ru(ACCUSATIVE)] и обнаружива[PLUR_ET_UT(user)] что-то интересное!"))
	user.investigate_log("has unwrapped a present containing [loot_tier.name].", INVESTIGATE_PRESENTS)


/*
 * Wrapping Paper
 */
/obj/item/stack/wrapping_paper
	name = "wrapping paper"
	desc = "Оберните подарки этой праздничной бумагой."
	icon = 'icons/map_icons/items/_item.dmi'
	icon_state = "/obj/item/stack/wrapping_paper/xmas"
	post_init_icon_state = "wrap_paper"
	greyscale_config = /datum/greyscale_config/wrap_paper
	item_flags = NOBLUDGEON
	amount = 25
	max_amount = 25
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/wrapping_paper
	singular_name = "wrapping paper"
	w_class = WEIGHT_CLASS_TINY

/obj/item/stack/wrapping_paper/Initialize(mapload)
	. = ..()
	if(!greyscale_colors)
		//Generate random valid colors for paper and ribbon
		var/generated_base_color = "#" + random_color()
		var/generated_ribbon_color = "#" + random_color()
		var/temp_base_hsv = RGBtoHSV(generated_base_color)
		var/temp_ribbon_hsv = RGBtoHSV(generated_ribbon_color)

		//If colors are too dark, set to original colors
		if(ReadHSV(temp_base_hsv)[3] < ReadHSV("7F7F7F")[3])
			generated_base_color = "#00FF00"
		if(ReadHSV(temp_ribbon_hsv)[3] < ReadHSV("7F7F7F")[3])
			generated_ribbon_color = "#FF0000"

		//Set layers to these colors, base then ribbon
		set_greyscale_colors(colors = list(generated_base_color, generated_ribbon_color))

/obj/item/stack/wrapping_paper/click_alt(mob/user)
	var/new_base = tgui_input_color(user, "", "Select a base color", color)
	var/new_ribbon = tgui_input_color(user, "", "Select a ribbon color", color)
	if(!new_base || !new_ribbon)
		return
	set_greyscale_colors(colors = list(new_base, new_ribbon))
	return TRUE

//preset wrapping paper meant to fill the original color configuration
/obj/item/stack/wrapping_paper/xmas
	greyscale_colors = "#00FF00#FF0000"

/obj/item/stack/wrapping_paper/get_ru_names()
	return list(
		NOMINATIVE = "обёрточная бумага",
		GENITIVE = "обёрточной бумаги",
		DATIVE = "обёрточной бумаге",
		ACCUSATIVE = "обёрточную бумагу",
		INSTRUMENTAL = "обёрточной бумагой",
		PREPOSITIONAL = "обёрточной бумаге"
	)

/obj/item/stack/wrapping_paper/attack_self(mob/user)
	to_chat(user, span_notice("Её нужно использовать на уже упакованной посылке!"))
