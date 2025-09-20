/*
 * The 'fancy' path is for objects like donut boxes that show how many items are in the storage item on the sprite itself
 * .. Sorry for the shitty path name, I couldnt think of a better one.
 *
 * WARNING: var/icon_type is used for both examine text and sprite name. Please look at the procs below and adjust your sprite names accordingly
 *		TODO: Cigarette boxes should be ported to this standard
 *
 * Contains:
 *		Donut Box
 *		Egg Box
 *		Candle Box
 *		Crayon Box
 *		Cigarette Packs
 *		Cigcase
 *		Vial Box
 *		Aquatic Starter Kit
 */

/obj/item/storage/fancy
	icon = 'icons/obj/food/containers.dmi'
	resistance_flags = FLAMMABLE
	var/icon_type

/obj/item/storage/fancy/update_icon_state()
	icon_state = "[icon_type]box[length(contents)]"

/obj/item/storage/fancy/examine(mob/user)
	. = ..()
	. += fancy_storage_examine(user)

/obj/item/storage/fancy/proc/fancy_storage_examine(mob/user)
	. = list()
	if(in_range(user, src))
		var/len = LAZYLEN(contents)
		if(len <= 0)
			. += "There are no [icon_type]s left in the box."
		else if(len == 1)
			. += "There is one [icon_type] left in the box."
		else
			. += "There are [length(contents)] [icon_type]s in the box."

/*
 * MARK: Donut Box
 */

/obj/item/storage/fancy/donut_box
	name = "donut box"
	icon_type = "donut"
	icon_state = "donutbox_back"
	storage_slots = 6
	can_hold = list(/obj/item/reagent_containers/food/snacks/donut)
	icon_type = "donut"
	foldable = /obj/item/stack/sheet/cardboard
	foldable_amt = 1
	drop_sound = 'sound/items/handling/drop/cardboardbox_drop.ogg'
	pickup_sound =  'sound/items/handling/pickup/cardboardbox_pickup.ogg'
	use_sound = 'sound/items/handling/cardboard_box_rustle.ogg'

/obj/item/storage/fancy/donut_box/update_icon_state()
	return

/obj/item/storage/fancy/donut_box/update_overlays()
	. = ..()
	for(var/I = 1 to length(contents))
		var/obj/item/reagent_containers/food/snacks/donut/donut = contents[I]
		var/icon/new_donut_icon = icon(icon, "donut_[donut.donut_sprite_type]")
		new_donut_icon.Shift(EAST, 3 * (I - 1))
		. += new_donut_icon
	. += "donutbox_front"

/obj/item/storage/fancy/donut_box/populate_contents()
	for(var/i = 1 to storage_slots)
		new /obj/item/reagent_containers/food/snacks/donut(src)
	update_icon(UPDATE_OVERLAYS)


/obj/item/storage/fancy/donut_box/empty/populate_contents()
	update_icon(UPDATE_OVERLAYS)
	return

/*
 * MARK: Glowsticks Box
 */

/obj/item/storage/fancy/glowsticks_box
	name = "glowstick box"
	icon = 'icons/obj/chemglow_box.dmi'
	icon_type = "glowstick"
	icon_state = "chemglow_box_opened"
	item_state = "glowstick_box"
	storage_slots = 6
	can_hold = list(/obj/item/flashlight/flare/glowstick)
	icon_type = "chemglow"
	foldable = /obj/item/stack/sheet/cardboard
	foldable_amt = 2

/obj/item/storage/fancy/glowsticks_box/update_icon_state()
	if(length(contents) == 6)
		icon_state = "chemglow_box_closed"
	else
		icon_state = "chemglow_box_opened"

/obj/item/storage/fancy/glowsticks_box/update_overlays()
	. = ..()
	for(var/I = 1 to length(contents))
		var/obj/item/flashlight/flare/glowstick/chemglow = contents[I]
		var/icon/new_chemglow_icon = icon(icon, "chemglow_[chemglow.chemglow_sprite_type]")
		new_chemglow_icon.Shift(EAST, 2 * (I - 1))
		. += new_chemglow_icon

/obj/item/storage/fancy/glowsticks_box/populate_contents()
	for(var/i = 1 to storage_slots)
		new /obj/item/flashlight/flare/glowstick/random(src)
	update_icon(UPDATE_OVERLAYS)

/obj/item/storage/fancy/glowsticks_box/empty/populate_contents()
	update_icon(UPDATE_OVERLAYS)
	return

/*
 * MARK: Egg Box
 */

/obj/item/storage/fancy/egg_box
	icon_state = "eggbox"
	icon_type = "egg"
	item_state = "eggbox"
	name = "egg box"
	storage_slots = 12
	can_hold = list(/obj/item/reagent_containers/food/snacks/egg)
	drop_sound = 'sound/items/handling/drop/cardboardbox_drop.ogg'
	pickup_sound =  'sound/items/handling/pickup/cardboardbox_pickup.ogg'
	use_sound = 'sound/items/handling/cardboard_box_rustle_light.ogg'

/obj/item/storage/fancy/egg_box/populate_contents()
	for(var/I = 1 to storage_slots)
		new /obj/item/reagent_containers/food/snacks/egg(src)

/*
 * MARK: Candle Box
 */

/obj/item/storage/fancy/candle_box
	name = "Candle pack"
	desc = "A pack of red candles."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candlebox5"
	icon_type = "candle"
	item_state = "candlebox5"
	storage_slots = 5
	throwforce = 2
	slot_flags = ITEM_SLOT_BELT
	use_sound = SFX_PATCHPACK

/obj/item/storage/fancy/candle_box/full/populate_contents()
	for(var/I = 1 to storage_slots)
		new /obj/item/candle(src)

/obj/item/storage/fancy/candle_box/eternal
	name = "Eternal Candle pack"
	desc = "A pack of red candles made with a special wax."

/obj/item/storage/fancy/candle_box/eternal/populate_contents()
	for(var/I = 1 to storage_slots)
		new /obj/item/candle/eternal(src)

/*
 * MARK: Crayon Box
 */

/obj/item/storage/fancy/crayons
	name = "box of crayons"
	desc = "A box of crayons for all your rune drawing needs."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonbox"
	w_class = WEIGHT_CLASS_SMALL
	storage_slots = 8
	icon_type = "crayon"
	can_hold = list(/obj/item/toy/crayon)
	use_sound = SFX_PATCHPACK

/obj/item/storage/fancy/crayons/populate_contents()
	new /obj/item/toy/crayon/white(src)
	new /obj/item/toy/crayon/red(src)
	new /obj/item/toy/crayon/orange(src)
	new /obj/item/toy/crayon/yellow(src)
	new /obj/item/toy/crayon/green(src)
	new /obj/item/toy/crayon/blue(src)
	new /obj/item/toy/crayon/purple(src)
	new /obj/item/toy/crayon/black(src)
	update_icon(UPDATE_OVERLAYS)

/obj/item/storage/fancy/crayons/update_icon_state()
	return

/obj/item/storage/fancy/crayons/update_overlays()
	. = ..()
	for(var/obj/item/toy/crayon/crayon in contents)
		. += crayon.colourName

/obj/item/storage/fancy/crayons/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/crayon = I
		switch(crayon.colourName)
			if("mime")
				add_fingerprint(user)
				to_chat(user, span_notice("This crayon is too sad to be contained in this box."))
				return ATTACK_CHAIN_PROCEED
			if("rainbow")
				add_fingerprint(user)
				to_chat(user, span_notice("This crayon is too powerful to be contained in this box."))
				return ATTACK_CHAIN_PROCEED
	return ..()

/*
 * MARK: Cig Pack
 */

/obj/item/storage/fancy/cigarettes
	name = "cigarette packet"
	desc = "Самый популярный бренд Космических Сигарет, спонсор Космо-олимпийских игр."
	gender = FEMALE
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigpacket"
	item_state = "cigpacket"
	use_sound = 'sound/items/handling/cardboard_box_rustle_light.ogg'
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 2
	slot_flags = ITEM_SLOT_BELT
	storage_slots = 20
	max_combined_w_class = 20
	display_contents_with_number = 1
	can_hold = list(/obj/item/clothing/mask/cigarette,
		/obj/item/lighter,
		/obj/item/match)
	cant_hold = list(/obj/item/clothing/mask/cigarette/cigar,
		/obj/item/clothing/mask/cigarette/pipe,
		/obj/item/lighter/zippo)
	icon_type = "cigarette"
	var/cigarette_type = /obj/item/clothing/mask/cigarette
	var/static/list/cigpack_diseases = list("недоношенность", "онкозаболевания", "пародонтоз",\
					"преждевременное старение", "ампутация", "зависимость",\
					"импотенция", "мертворождение", "смерть в агонии",\
					"туберкулёз", "отмирание органов")

/obj/item/storage/fancy/cigarettes/get_ru_names()
	return list(
		NOMINATIVE = "пачка сигарет",
		GENITIVE = "пачки сигарет",
		DATIVE = "пачке сигарет",
		ACCUSATIVE = "пачку сигарет",
		INSTRUMENTAL = "пачкой сигарет",
		PREPOSITIONAL = "пачке сигарет"
	)

/obj/item/storage/fancy/cigarettes/Initialize(mapload)
	. = ..()
	var/cigpack_disease = pick(cigpack_diseases)
	desc += "\n На упаковке написано: \"[capitalize(cigpack_disease)]\"."

/obj/item/storage/fancy/cigarettes/populate_contents()
	for(var/i = 1 to storage_slots)
		new cigarette_type(src)

/obj/item/storage/fancy/cigarettes/update_icon_state()
	var/init_state = initial(icon_state)
	switch(length(contents))
		if(17 to INFINITY)
			icon_state = "[init_state]6"
		if(14 to 16)
			icon_state = "[init_state]5"
		if(11 to 13)
			icon_state = "[init_state]4"
		if(7 to 10)
			icon_state = "[init_state]3"
		if(4 to 6)
			icon_state = "[init_state]2"
		if(1 to 3)
			icon_state = "[init_state]1"
		else
			icon_state = "[init_state]0"

/obj/item/storage/fancy/cigarettes/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!ishuman(target) || user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		return ..()

	. = ATTACK_CHAIN_PROCEED
	var/obj/item/clothing/mask/cigarette/cigar = locate() in src
	if(!cigar)
		user.balloon_alert(user, "сигареты кончились!")
		return .

	if(target.equip_to_slot_if_possible(cigar, ITEM_SLOT_MASK, disable_warning = TRUE))
		. |= ATTACK_CHAIN_SUCCESS
		to_chat(user, span_notice("Вы берёте [cigar.declent_ru(ACCUSATIVE)] из пачки[target != user ? " и ловко кладёте её в рот [target.declent_ru(GENITIVE)]" : ""]."))
	else
		user.balloon_alert(user, "рот цели чем-то занят!")

/obj/item/storage/fancy/cigarettes/can_be_inserted(obj/item/item , stop_messages = 0)
	if(istype(item, /obj/item/match))
		var/obj/item/match/match = item
		if(match.lit)
			if(!stop_messages)
				usr.balloon_alert(usr, "сначала потушите!")
			return FALSE
	if(istype(item, /obj/item/lighter))
		var/obj/item/lighter/lighter = item
		if(lighter.lit)
			if(!stop_messages)
				usr.balloon_alert(usr, "сначала выключите!")
			return FALSE
	return ..()

/obj/item/storage/fancy/cigarettes/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!length(contents))
		C.stored_comms["wood"] += 1
		qdel(src)
		return TRUE
	return ..()

/obj/item/storage/fancy/cigarettes/dromedaryco
	name = "DromedaryCo packet"
	desc = "Упаковка 20 сигарет \"Марсианский Табак\". Надпись на упаковке гласит: \"Быстрее или медленнее – всё равно смерть вас настигнет.\""
	icon_state = "Dpacket"
	item_state = "Dpacket"

/obj/item/storage/fancy/cigarettes/dromedaryco/get_ru_names()
	return list(
		NOMINATIVE = "пачка \"Марсианский Табак\"",
		GENITIVE = "пачки \"Марсианский Табак\"",
		DATIVE = "пачке \"Марсианский Табак\"",
		ACCUSATIVE = "пачку \"Марсианский Табак\"",
		INSTRUMENTAL = "пачкой \"Марсианский Табак\"",
		PREPOSITIONAL = "пачке \"Марсианский Табак\""
	)


/obj/item/storage/fancy/cigarettes/syndicate
	name = "Syndicate Cigarettes"
	desc = "Упаковка двадцати зловещих сигарет. Надпись на упаковке гласит: \"Вкусно и Пончик\"."
	icon_state = "robustpacket"
	item_state = "robustpacket"

/obj/item/storage/fancy/cigarettes/syndicate/get_ru_names()
	return list(
		NOMINATIVE = "пачка сигарет Синдиката",
		GENITIVE = "пачки сигарет Синдиката",
		DATIVE = "пачке сигарет Синдиката",
		ACCUSATIVE = "пачку сигарет Синдиката",
		INSTRUMENTAL = "пачкой сигарет Синдиката",
		PREPOSITIONAL = "пачке сигарет Синдиката"
	)

/obj/item/storage/fancy/cigarettes/cigpack_syndicate
	name = "cigarette packet"
	desc = "Малоизвестная марка сигарет."
	icon_state = "syndiepacket"
	item_state = "syndiepacket"
	cigarette_type = /obj/item/clothing/mask/cigarette/syndicate

/obj/item/storage/fancy/cigarettes/cigpack_med
	name = "\"Dr. Denchigo\" Marijuana Packet"
	desc = "Упаковка 20 медицинских сигарет, выпускаемых по рецепту. Содержат марихуану."
	icon_state = "medpacket"
	item_state = "medpacket"
	cigarette_type = /obj/item/clothing/mask/cigarette/medical_marijuana

/obj/item/storage/fancy/cigarettes/cigpack_med/get_ru_names()
	return list(
		NOMINATIVE = "пачка сигарет \"Доктор Денчиго\"",
		GENITIVE = "пачки сигарет \"Доктор Денчиго\"",
		DATIVE = "пачке сигарет \"Доктор Денчиго\"",
		ACCUSATIVE = "пачку сигарет \"Доктор Денчиго\"",
		INSTRUMENTAL = "пачкой сигарет \"Доктор Денчиго\"",
		PREPOSITIONAL = "пачке сигарет \"Доктор Денчиго\""
	)

/obj/item/storage/fancy/cigarettes/cigpack_uplift
	name = "Uplift Smooth packet"
	desc = "Упаковка 20 сигарет \"Лёгкие на подъём\" со вкусом ментола."
	icon_state = "upliftpacket"
	item_state = "upliftpacket"
	cigarette_type = /obj/item/clothing/mask/cigarette/menthol

/obj/item/storage/fancy/cigarettes/cigpack_uplift/get_ru_names()
	return list(
		NOMINATIVE = "пачка сигарет \"Лёгкие на подъём\"",
		GENITIVE = "пачки сигарет \"Лёгкие на подъём\"",
		DATIVE = "пачке сигарет \"Лёгкие на подъём\"",
		ACCUSATIVE = "пачку сигарет \"Лёгкие на подъём\"",
		INSTRUMENTAL = "пачкой сигарет \"Лёгкие на подъём\"",
		PREPOSITIONAL = "пачке сигарет \"Лёгкие на подъём\""
	)

/obj/item/storage/fancy/cigarettes/cigpack_richard
	name = "Richard & Co cigarettes"
	desc = "Упаковка 20 сигарет \"Ричард и Компания\". Курево для самых отчаяных."
	cigarette_type = /obj/item/clothing/mask/cigarette/richard

/obj/item/storage/fancy/cigarettes/cigpack_richard/get_ru_names()
	return list(
		NOMINATIVE = "пачка сигарет \"Ричард и Компания\"",
		GENITIVE = "пачки сигарет \"Ричард и Компания\"",
		DATIVE = "пачке сигарет \"Ричард и Компания\"",
		ACCUSATIVE = "пачку сигарет \"Ричард и Компания\"",
		INSTRUMENTAL = "пачкой сигарет \"Ричард и Компания\"",
		PREPOSITIONAL = "пачке сигарет \"Ричард и Компания\""
	)

/obj/item/storage/fancy/cigarettes/cigpack_robust
	name = "Robust packet"
	desc = "Упаковка 20 сигарет \"Робаст\", популярных у безработных ассистентов."
	icon_state = "robustpacket"
	item_state = "robustpacket"

/obj/item/storage/fancy/cigarettes/cigpack_robust/get_ru_names()
	return list(
		NOMINATIVE = "пачка сигарет \"Робаст\"",
		GENITIVE = "пачки сигарет \"Робаст\"",
		DATIVE = "пачке сигарет \"Робаст\"",
		ACCUSATIVE = "пачку сигарет \"Робаст\"",
		INSTRUMENTAL = "пачкой сигарет \"Робаст\"",
		PREPOSITIONAL = "пачке сигарет \"Робаст\""
	)

/obj/item/storage/fancy/cigarettes/cigpack_robustgold
	name = "Robust Gold packet"
	desc = "Упаковка 20 сигарет \"Золотой Робаст\". Курево для настоящих мужиков."

	icon_state = "robustgpacket"
	item_state = "robustgpacket"
	cigarette_type = /obj/item/clothing/mask/cigarette/robustgold

/obj/item/storage/fancy/cigarettes/cigpack_robustgold/get_ru_names()
	return list(
		NOMINATIVE = "пачка сигарет \"Золотой Робаст\"",
		GENITIVE = "пачки сигарет \"Золотой Робаст\"",
		DATIVE = "пачке сигарет \"Золотой Робаст\"",
		ACCUSATIVE = "пачку сигарет \"Золотой Робаст\"",
		INSTRUMENTAL = "пачкой сигарет \"Золотой Робаст\"",
		PREPOSITIONAL = "пачке сигарет \"Золотой Робаст\""
	)

/obj/item/storage/fancy/cigarettes/cigpack_carp
	name = "Carp Classic packet"
	desc = "Упаковка 20 сигарет \"Дымящий Карп\". Надпись на упаковке гласит: \"Дарим клиентам рак лёгких с 2313 года\"."
	icon_state = "carppacket"
	item_state = "carppacket"

/obj/item/storage/fancy/cigarettes/cigpack_carp/get_ru_names()
	return list(
		NOMINATIVE = "Пачка сигарет \"Дымящий Карп\"",
		GENITIVE = "пачки сигарет \"Дымящий Карп\"",
		DATIVE = "пачке сигарет \"Дымящий Карп\"",
		ACCUSATIVE = "пачку сигарет \"Дымящий Карп\"",
		INSTRUMENTAL = "пачкой сигарет\"Дымящий Карп\"",
		PREPOSITIONAL = "пачке сигарет \"Дымящий Карп\""
	)

/obj/item/storage/fancy/cigarettes/cigpack_midori
	name = "Midori Tabako packet"
	desc = "Упаковка 20 сигарет \"Табак Мидори\". Вы не понимаете, что написано на упаковке, но пахнет прикольно."
	icon_state = "midoripacket"
	item_state = "midoripacket"

/obj/item/storage/fancy/cigarettes/cigpack_midori/get_ru_names()
	return list(
		NOMINATIVE = "пачка сигарет \"Табак Мидори\"",
		GENITIVE = "пачки сигарет \"Табак Мидори\"",
		DATIVE = "пачке сигарет \"Табак Мидори\"",
		ACCUSATIVE = "пачку сигарет \"Табак Мидори\"",
		INSTRUMENTAL = "пачкой сигарет \"Табак Мидори\"",
		PREPOSITIONAL = "пачке сигарет \"Табак Мидори\""
	)

/obj/item/storage/fancy/cigarettes/cigpack_shadyjims
	name ="Shady Jim's Super Slims"
	desc = "Упаковка 20 сигарет \"от Шейди Джима\". Надпись на упаковке гласит: \
		\"Теряете в весе? \
		Не можете поспевать за коллегами, убегая от Сингулярности? \
		Продолжаете набивать рот, не смотря ни на что? \
		Курите утонщающие сигареты от Шейди Джима и жир пропадёт у вас на глазах. Гарантированный результат!\""
	icon_state = "shadyjimpacket"
	item_state = "shadyjimpacket"
	cigarette_type = /obj/item/clothing/mask/cigarette/shadyjims

/obj/item/storage/fancy/cigarettes/cigpack_shadyjims/get_ru_names()
	return list(
		NOMINATIVE = "пачка сигарет \"от Шейди Джима\"",
		GENITIVE = "пачки сигарет \"от Шейди Джима\"",
		DATIVE = "пачке сигарет \"от Шейди Джима\"",
		ACCUSATIVE = "пачку сигарет \"от Шейди Джима\"",
		INSTRUMENTAL = "пачкой сигарет \"от Шейди Джима\"",
		PREPOSITIONAL = "пачке сигарет \"от Шейди Джима\""
	)

/obj/item/storage/fancy/cigarettes/cigpack_random
	name ="Embellished Enigma packet"
	desc = "Упаковка 20 сигарет \"Энигма\". Для истинных ценителей экзотики."
	icon_state = "shadyjimpacket"
	item_state = "shadyjimpacket"
	cigarette_type = /obj/item/clothing/mask/cigarette/random

/obj/item/storage/fancy/cigarettes/cigpack_random/get_ru_names()
	return list(
		NOMINATIVE = "пачка сигарет \"Энигма\"",
		GENITIVE = "пачки сигарет \"Энигма\"",
		DATIVE = "пачке сигарет \"Энигма\"",
		ACCUSATIVE = "пачку сигарет \"Энигма\"",
		INSTRUMENTAL = "пачкой сигарет \"Энигма\"",
		PREPOSITIONAL = "пачке сигарет \"Энигма\""
	)

/obj/item/storage/fancy/rollingpapers
	name = "rolling paper pack"
	desc = "Упаковка рулонной бумаги НаноТрейзен."
	gender = FEMALE
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper_pack"
	item_state = "cig_paper_pack"
	storage_slots = 10
	icon_type = "rolling paper"
	can_hold = list(/obj/item/rollingpaper)

/obj/item/storage/fancy/rollingpapers/get_ru_names()
	return list(
		NOMINATIVE = "упаковка рулонной бумаги",
		GENITIVE = "упаковки рулонной бумаги",
		DATIVE = "упаковке рулонной бумаги",
		ACCUSATIVE = "упаковку рулонной бумаги",
		INSTRUMENTAL = "упаковкой рулонной бумаги",
		PREPOSITIONAL = "упаковке рулонной бумаги"
	)

/obj/item/storage/fancy/rollingpapers/populate_contents()
	for(var/i in 1 to storage_slots)
		new /obj/item/rollingpaper(src)

/obj/item/storage/fancy/rollingpapers/update_icon_state()
	return

/obj/item/storage/fancy/rollingpapers/update_overlays()
	. = ..()
	if(!length(contents))
		. += "[icon_state]_empty"

/*
 * MARK: Cigcase
 */

/obj/item/storage/fancy/cigcase
	name = "Cigar Case"
	desc = "Делового вида футляр, в котором держат дорогие сигары."
	icon = 'icons/obj/cigarettes.dmi'
	gender = MALE
	icon_state = "cigarcase"
	icon_type = "cigar"
	item_state = "cigarcase"
	storage_slots = 7
	can_hold = list(/obj/item/clothing/mask/cigarette/cigar)

/obj/item/storage/fancy/cigcase/get_ru_names()
	return list(
		NOMINATIVE = "портсигар",
		GENITIVE = "портсигара",
		DATIVE = "портсигару",
		ACCUSATIVE = "портсигар",
		INSTRUMENTAL = "портсигаром",
		PREPOSITIONAL = "портсигаре"
	)

/obj/item/storage/fancy/cigcase/update_icon_state()
	icon_state = "[icon_type]case[length(contents)]"

/obj/item/storage/fancy/cigcase/populate_contents()
	for(var/I = 1 to storage_slots)
		new /obj/item/clothing/mask/cigarette/cigar(src)

/*
 * MARK: Vial Box
 */

/obj/item/storage/fancy/vials
	name = "vial storage box"
	icon = 'icons/obj/vialbox.dmi'
	icon_state = "vialbox6"
	icon_type = "vial"
	use_sound = 'sound/items/handling/cardboard_box_rustle_light.ogg'
	storage_slots = 6
	can_hold = list(/obj/item/reagent_containers/glass/beaker/vial)

/obj/item/storage/fancy/vials/populate_contents()
	for(var/I = 1 to storage_slots)
		new /obj/item/reagent_containers/glass/beaker/vial(src)

/obj/item/storage/lockbox/vials
	name = "secure vial storage box"
	desc = "A locked box for keeping things away from children."
	icon = 'icons/obj/vialbox.dmi'
	icon_state = "vialbox0"
	item_state = "syringe_kit"
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(/obj/item/reagent_containers/glass/beaker/vial)
	max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 6
	req_access = list(ACCESS_VIROLOGY)

/obj/item/storage/lockbox/vials/populate_contents()
	for(var/I = 1 to storage_slots)
		new /obj/item/reagent_containers/glass/beaker/vial(src)
	update_icon()

/obj/item/storage/lockbox/vials/update_icon_state()
	icon_state = "vialbox[length(contents)]"

/obj/item/storage/lockbox/vials/update_overlays()
	. = ..()
	if(!broken)
		. += "led[locked]"
		if(locked)
			. += "cover"
	else
		. += "ledb"

/*
 * MARK: Aquatic Starter Kit
 */

/obj/item/storage/firstaid/aquatic_kit
	name = "aquatic starter kit"
	desc = "Коробка со всем необходимым для ухода за аквариумом и его жителями."
	icon_state = "AquaticKit"
	throw_speed = 2
	throw_range = 8
	med_bot_skin = "fish"

/obj/item/storage/firstaid/aquatic_kit/get_ru_names()
	return list(
        NOMINATIVE = "набор для ухода за аквариумом",
        GENITIVE = "набора для ухода за аквариумом",
        DATIVE = "набору для ухода за аквариумом",
        ACCUSATIVE = "набор для ухода за аквариумом",
        INSTRUMENTAL = "набором для ухода за аквариумом",
        PREPOSITIONAL = "наборе для ухода за аквариумом"
	)

/obj/item/storage/firstaid/aquatic_kit/full/populate_contents()
	new /obj/item/egg_scoop(src)
	new /obj/item/fish_net(src)
	new /obj/item/tank_brush(src)
	new /obj/item/fishfood(src)
	new /obj/item/storage/bag/fish(src)
