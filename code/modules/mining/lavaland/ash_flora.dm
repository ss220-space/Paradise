/obj/structure/flora/ash
	gender = PLURAL
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER //sporangiums up don't shoot
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "l_mushroom1"
	base_icon_state = "l_mushroom"
	name = "large mushrooms"
	desc = "Несколько крупных грибов, покрытых тонким слоем пепла и, вероятно, спорами."
	anchored = TRUE
	var/harvested_name = "укороченные грибы"
	var/harvested_desc = "Быстро отрастающие грибы, ранее известные своими крупными размерами."
	var/needs_sharp_harvest = TRUE
	var/harvest = /obj/item/reagent_containers/food/snacks/grown/ash_flora/shavings
	var/harvest_amount_low = 1
	var/harvest_amount_high = 3
	var/harvest_time = 60
	var/harvest_message_low = "Вы срываете гриб, но собираете совсем немного стружки с его шляпки."
	var/harvest_message_med = "Вы аккуратно срываете гриб, собирая стружку с его шляпки."
	var/harvest_message_high = "Вы собираете урожай, получая стружку с нескольких грибных шляпок."
	var/harvested = FALSE
	var/delete_on_harvest = FALSE
	var/base_icon
	var/regrowth_time_low = 8 MINUTES
	var/regrowth_time_high = 16 MINUTES

/obj/structure/flora/ash/get_ru_names()
	return list(
		NOMINATIVE = "крупные грибы",
		GENITIVE = "крупных грибов",
		DATIVE = "крупным грибам",
		ACCUSATIVE = "крупные грибы",
		INSTRUMENTAL = "крупными грибами",
		PREPOSITIONAL = "крупных грибах"
	)

/obj/structure/flora/ash/Initialize(mapload)
	. = ..()
	base_icon = "[base_icon_state][rand(1, 4)]"
	icon_state = base_icon

/obj/structure/flora/ash/proc/harvest(user)
	if(harvested)
		return 0

	var/rand_harvested = rand(harvest_amount_low, harvest_amount_high)
	if(rand_harvested)
		if(user)
			var/msg = harvest_message_med
			if(rand_harvested == harvest_amount_low)
				msg = harvest_message_low
			else if(rand_harvested == harvest_amount_high)
				msg = harvest_message_high
			to_chat(user, span_notice("[msg]"))
		for(var/i in 1 to rand_harvested)
			new harvest(get_turf(src))

	icon_state = "[base_icon]p"
	name = harvested_name
	desc = harvested_desc
	harvested = TRUE
	if(delete_on_harvest)
		qdel(src)
		return 1
	addtimer(CALLBACK(src, PROC_REF(regrow)), rand(regrowth_time_low, regrowth_time_high))
	return 1

/obj/structure/flora/ash/proc/regrow()
	icon_state = base_icon
	name = initial(name)
	desc = initial(desc)
	harvested = FALSE


/obj/structure/flora/ash/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(is_sharp(I) && !harvested && needs_sharp_harvest)
		add_fingerprint(user)
		user.visible_message(
			span_notice("[user] начина[pluralize_ru(user.gender,"ет","ют")] собирать [declent_ru(ACCUSATIVE)] при помощи [I.declent_ru(GENITIVE)]."),
			span_notice("Вы начинаете собирать [src.declent_ru(ACCUSATIVE)]."),
		)
		if(!do_after(user, harvest_time * I.toolspeed, src, category = DA_CAT_TOOL) || harvested)
			return ATTACK_CHAIN_PROCEED
		harvest(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/flora/ash/attack_hand(mob/user)
	if(!harvested && !needs_sharp_harvest)
		user.visible_message(
			span_notice("[user] начина[pluralize_ru(user.gender,"ет","ют")] собирать [declent_ru(ACCUSATIVE)]."),
			span_notice("Вы начинаете собирать [src.declent_ru(ACCUSATIVE)]."),
		)
		if(do_after(user, harvest_time, src))
			add_fingerprint(user)
			harvest(user)
	else
		..()

/obj/structure/flora/ash/tall_shroom //exists only so that the spawning check doesn't allow these spawning near other things
	regrowth_time_low = 4200

/obj/structure/flora/ash/leaf_shroom
	name = "leafy mushrooms"
	desc = "Несколько грибов, каждый из которых окружает зеленоватый спорангий листоподобными структурами."
	icon_state = "s_mushroom1"
	base_icon_state = "s_mushroom"
	harvested_name = "безлистные грибы"
	harvested_desc = "Группа ранее покрытых листьями грибов с обнажёнными спорангиями. Неприлично, не правда ли?"
	harvest = /obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_leaf
	needs_sharp_harvest = FALSE
	harvest_amount_high = 4
	harvest_time = 20
	harvest_message_low = "Вы аккуратно отделяете один подходящий лист."
	harvest_message_med = "Вы собираете несколько листьев, оставляя непригодные."
	harvest_message_high = "Вы собираете значительное количество качественных листьев."
	regrowth_time_low = 2400
	regrowth_time_high = 6000

/obj/structure/flora/ash/leaf_shroom/get_ru_names()
	return list(
		NOMINATIVE = "лиственные грибы",
		GENITIVE = "лиственных грибов",
		DATIVE = "лиственным грибам",
		ACCUSATIVE = "лиственные грибы",
		INSTRUMENTAL = "лиственными грибами",
		PREPOSITIONAL = "лиственных грибах"
	)

/obj/structure/flora/ash/cap_shroom
	name = "tall mushrooms"
	desc = "Несколько грибов, у крупнейших экземпляров которых на середине ножки расположены копытовидные наросты."
	icon_state = "r_mushroom1"
	base_icon_state = "r_mushroom"
	harvested_name = "малые грибы"
	harvested_desc = "Несколько небольших грибов рядом с остатками более крупных грибов, которые, вероятно, были когда-то здесь."
	harvest = /obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_cap
	harvest_amount_high = 4
	harvest_time = 50
	harvest_message_low = "Вы срезаете шляпку с одного гриба."
	harvest_message_med = "Вы срезаете несколько наростов с крупных грибов."
	harvest_message_high = "Вы срезаете множество шляпок и наростов с этих грибов."
	regrowth_time_low = 3000
	regrowth_time_high = 5400

/obj/structure/flora/ash/cap_shroom/get_ru_names()
	return list(
		NOMINATIVE = "высокие грибы",
		GENITIVE = "высоких грибов",
		DATIVE = "высоким грибам",
		ACCUSATIVE = "высокие грибы",
		INSTRUMENTAL = "высокими грибами",
		PREPOSITIONAL = "высоких грибах"
	)

/obj/structure/flora/ash/stem_shroom

	name = "numerous mushrooms"
	desc = "Большое скопление грибов, некоторые из которых имеют длинные мясистые ножки. Они излучают свет!"
	icon_state = "t_mushroom1"
	base_icon_state = "t_mushroom"
	light_range = 1.5
	light_power = 2.1
	harvested_name = "мелкие грибы"
	harvested_desc = "Несколько крошечных грибов вокруг крупных пеньков. Уже заметно, как они отрастают вновь."
	harvest = /obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_stem
	harvest_amount_high = 4
	harvest_time = 40
	harvest_message_low = "Вы срезаете шляпку гриба, оставляя ножку."
	harvest_message_med = "Вы срезаете несколько грибов ради их ножек."
	harvest_message_high = "Вы собираете значительное количество грибных ножек."
	regrowth_time_low = 3000
	regrowth_time_high = 6000

/obj/structure/flora/ash/stem_shroom/get_ru_names()
	return list(
		NOMINATIVE = "скопление грибов",
		GENITIVE = "скопления грибов",
		DATIVE = "скоплению грибов",
		ACCUSATIVE = "скопление грибов",
		INSTRUMENTAL = "скоплением грибов",
		PREPOSITIONAL = "скоплении грибов"
	)

/obj/structure/flora/ash/cacti
	name = "fruiting cacti"
	desc = "Несколько колючих кактусов, усыпанных спелыми плодами и покрытых тонким слоем пепла."
	icon_state = "cactus1"
	base_icon_state = "cactus"
	harvested_name = "кактусы"
	harvested_desc = "Группа колючих кактусов. Сквозь пепельный покров уже виднеются растущие новые плоды."
	harvest = /obj/item/reagent_containers/food/snacks/grown/ash_flora/cactus_fruit
	needs_sharp_harvest = FALSE
	harvest_amount_high = 2
	harvest_time = 10
	harvest_message_low = "Вы собираете один кактусовый плод."
	harvest_message_med = "Вы собираете несколько плодов кактуса." //shouldn't show up, because you can't get more than two
	harvest_message_high = "Вы собираете пару кактусовых плодов."
	regrowth_time_low = 4800
	regrowth_time_high = 7200

/obj/structure/flora/ash/cacti/get_ru_names()
	return list(
		NOMINATIVE = "фруктовый кактус",
		GENITIVE = "фруктового кактуса",
		DATIVE = "фруктовому кактусу",
		ACCUSATIVE = "фруктовый кактус",
		INSTRUMENTAL = "фруктовым кактусом",
		PREPOSITIONAL = "фруктовом кактусе"
	)

/obj/structure/flora/ash/cacti/Initialize(mapload)
	. = ..()
	// min dmg 3, max dmg 6, prob(70)
	AddComponent(/datum/component/caltrop, 3, 6, 70)

/obj/structure/flora/ash/fireblossom
	name = "fire blossom"
	desc = "Странный цветок, который часто растёт возле лавовых потоков."
	icon_state = "fireblossom"
	base_icon_state = "fireblossom"
	harvested_name = "стебли огнецвета"
	harvested_desc = "Несколько стеблей огнецвета без соцветий."
	harvest = /obj/item/reagent_containers/food/snacks/grown/ash_flora/fireblossom
	needs_sharp_harvest = FALSE
	light_range = 1.5
	light_power = 2.1
	light_color = "#FFFF66"
	harvest_amount_high = 3
	harvest_time = 10
	harvest_message_low = "Вы срываете один подходящий цветок."
	harvest_message_med = "Вы срываете несколько цветков, оставляя непригодные."
	harvest_message_high = "Вы собираете большое количество качественных цветков."
	regrowth_time_low = 2500
	regrowth_time_high = 4000

/obj/structure/flora/ash/fireblossom/get_ru_names()
	return list(
		NOMINATIVE = "огнецвет",
		GENITIVE = "огнецвета",
		DATIVE = "огнецвету",
		ACCUSATIVE = "огнецвет",
		INSTRUMENTAL = "огнецветом",
		PREPOSITIONAL = "огнецвете"
	)

/obj/structure/flora/ash/coaltree
	icon_state = "coaltree1"
	base_icon_state = "coaltree"
	name = "coaltree"
	desc = "Небольшое мрачное дерево, растущее на просторах такой же мрачной планеты."
	gender = NEUTER
	harvested_name = "пень угледрева"
	harvested_desc = "Голый ствол дерева, оставшийся без своей уродливой кроны."
	harvest = /obj/item/reagent_containers/food/snacks/grown/ash_flora/coaltree_log
	harvest_amount_high = 5
	harvest_time = 40
	harvest_message_low = "Вы обрезаете небольшое дерево."
	harvest_message_med = "Вы обрезаете дерево среднего размера."
	harvest_message_high = "Вы обрезаете большое дерево."
	regrowth_time_low = 4000
	regrowth_time_high = 6000

/obj/structure/flora/ash/coaltree/get_ru_names()
	return list(
		NOMINATIVE = "угледрево",
		GENITIVE = "угледрева",
		DATIVE = "угледреву",
		ACCUSATIVE = "угледрево",
		INSTRUMENTAL = "угледревом",
		PREPOSITIONAL = "угледреве"
	)

/obj/item/reagent_containers/food/snacks/grown/ash_flora
	name = "mushroom shavings"
	desc = "Стружка с высокого гриба. В достаточном количестве может служить ёмкостью."
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "mushroom_shavings"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_integrity = 100
	seed = /obj/item/seeds/lavaland/polypore
	wine_power = 0.2

/obj/item/reagent_containers/food/snacks/grown/ash_flora/get_ru_names()
	return list(
		NOMINATIVE = "грибная стружка",
		GENITIVE = "грибной стружки",
		DATIVE = "грибной стружке",
		ACCUSATIVE = "грибную стружку",
		INSTRUMENTAL = "грибной стружкой",
		PREPOSITIONAL = "грибной стружке"
	)

/obj/item/reagent_containers/food/snacks/grown/ash_flora/Initialize(mapload)
	. = ..()
	pixel_x = rand(-4, 4)
	pixel_y = rand(-4, 4)

/obj/item/reagent_containers/food/snacks/grown/ash_flora/shavings //for actual crafting

/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_leaf
	name = "mushroom leaf"
	desc = "Лист, растущий на грибе."
	icon_state = "mushroom_leaf"
	seed = /obj/item/seeds/lavaland/porcini
	wine_power = 0.4

/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_leaf/get_ru_names()
	return list(
		NOMINATIVE = "грибной лист",
		GENITIVE = "грибного листа",
		DATIVE = "грибному листу",
		ACCUSATIVE = "грибной лист",
		INSTRUMENTAL = "грибным листом",
		PREPOSITIONAL = "грибном листе"
	)

/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_cap
	name = "mushroom cap"
	desc = "Шляпка крупного гриба."
	icon_state = "mushroom_cap"
	seed = /obj/item/seeds/lavaland/inocybe
	wine_power = 0.7

/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_cap/get_ru_names()
	return list(
		NOMINATIVE = "грибная шляпка",
		GENITIVE = "грибной шляпки",
		DATIVE = "грибной шляпке",
		ACCUSATIVE = "грибную шляпку",
		INSTRUMENTAL = "грибной шляпкой",
		PREPOSITIONAL = "грибной шляпке"
	)

/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_stem
	name = "mushroom stem"
	desc = "Длинная ножка гриба. Слегка светится."
	icon_state = "mushroom_stem"
	seed = /obj/item/seeds/lavaland/ember
	wine_power = 0.6

/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_stem/get_ru_names()
	return list(
		NOMINATIVE = "грибная ножка",
		GENITIVE = "грибной ножки",
		DATIVE = "грибной ножке",
		ACCUSATIVE = "грибную ножку",
		INSTRUMENTAL = "грибной ножкой",
		PREPOSITIONAL = "грибной ножке"
	)

/obj/item/reagent_containers/food/snacks/grown/ash_flora/cactus_fruit
	name = "cactus fruit"
	desc = "Плод кактуса с толстой красноватой кожурой. И слоем пепла."
	icon_state = "cactus_fruit"
	seed = /obj/item/seeds/lavaland/cactus
	wine_power = 0.5

/obj/item/reagent_containers/food/snacks/grown/ash_flora/cactus_fruit/get_ru_names()
	return list(
		NOMINATIVE = "плод кактуса",
		GENITIVE = "плода кактуса",
		DATIVE = "плоду кактуса",
		ACCUSATIVE = "плод кактуса",
		INSTRUMENTAL = "плодом кактуса",
		PREPOSITIONAL = "плоде кактуса"
	)

/obj/item/reagent_containers/food/snacks/grown/ash_flora/fireblossom
	name = "fire blossom"
	desc = "Обычный цветок огнецвета."
	icon_state = "fireblossom"
	slot_flags = ITEM_SLOT_HEAD
	seed = /obj/item/seeds/lavaland/fireblossom
	wine_power = 0.4

/obj/item/reagent_containers/food/snacks/grown/ash_flora/fireblossom/get_ru_names()
	return list(
		NOMINATIVE = "цветок огнецвета",
		GENITIVE = "цветка огнецвета",
		DATIVE = "цветку огнецвета",
		ACCUSATIVE = "цветок огнецвета",
		INSTRUMENTAL = "цветком огнецвета",
		PREPOSITIONAL = "цветке огнецвета"
	)

/obj/item/reagent_containers/food/snacks/grown/ash_flora/coaltree_log
	name = "coaltree log"
	desc = "Бревно угледрева, на ощупь мягкое."
	gender = NEUTER
	icon_state = "coaltree_log"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	item_state = "coaltree_log"
	seed = /obj/item/seeds/lavaland/coaltree
	wine_power = 0.5
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/reagent_containers/food/snacks/grown/ash_flora/coaltree_log/get_ru_names()
	return list(
		NOMINATIVE = "бревно угледрева",
		GENITIVE = "бревна угледрева",
		DATIVE = "бревну угледрева",
		ACCUSATIVE = "бревно угледрева",
		INSTRUMENTAL = "бревном угледрева",
		PREPOSITIONAL = "бревне угледрева"
	)

/obj/item/reagent_containers/food/snacks/grown/ash_flora/coaltree_log/attackby(obj/item/I, mob/user, params)
	if(is_sharp(I))
		if(!isturf(loc))
			add_fingerprint(user)
			to_chat(user, span_warning("Вы не можете рубить [declent_ru(ACCUSATIVE)] [ismob(loc) ? "в инвентаре" : "в [loc.declent_ru(PREPOSITIONAL)]"]."))
			return ATTACK_CHAIN_PROCEED

		to_chat(user, span_notice("Вы порубили [declent_ru(ACCUSATIVE)] на доски."))
		var/seed_modifier = 0
		if(seed)
			seed_modifier = round(seed.potency / 25)
		var/obj/item/stack/planks = new /obj/item/stack/sheet/wood(loc, 1 + seed_modifier)
		transfer_fingerprints_to(planks)
		planks.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

//SEEDS

/obj/item/seeds/lavaland
	name = "lavaland seeds"
	desc = "You should never see this."
	lifespan = 50
	endurance = 25
	maturation = 7
	production = 4
	yield = 4
	potency = 15
	growthstages = 3
	rarity = 20
	reagents_add = list("nutriment" = 0.1)
	resistance_flags = FIRE_PROOF

/obj/item/seeds/lavaland/cactus
	name = "pack of fruiting cactus seeds"
	desc = "These seeds grow into fruiting cacti."
	icon_state = "seed-cactus"
	species = "cactus"
	plantname = "Fruiting Cactus"
	product = /obj/item/reagent_containers/food/snacks/grown/ash_flora/cactus_fruit
	genes = list(/datum/plant_gene/trait/fire_resistance)
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	growthstages = 2
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.04, "vitfro" = 0.08)

/obj/item/seeds/lavaland/polypore
	name = "pack of polypore mycelium"
	desc = "This mycelium grows into bracket mushrooms, also known as polypores. Woody and firm, shaft miners often use them for makeshift crafts."
	icon_state = "mycelium-polypore"
	species = "polypore"
	plantname = "Polypore Mushrooms"
	product = /obj/item/reagent_containers/food/snacks/grown/ash_flora/shavings
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism, /datum/plant_gene/trait/fire_resistance)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	reagents_add = list("sugar" = 0.06, "ethanol" = 0.04, "stabilizing_agent" = 0.06, "minttoxin" = 0.02)

/obj/item/seeds/lavaland/porcini
	name = "pack of porcini mycelium"
	desc = "This mycelium grows into Boletus edulus, also known as porcini. Native to the late Earth, but discovered on Lavaland. Has culinary, medicinal and relaxant effects."
	icon_state = "mycelium-porcini"
	species = "porcini"
	plantname = "Porcini Mushrooms"
	product = /obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_leaf
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism, /datum/plant_gene/trait/fire_resistance)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	reagents_add = list("nutriment" = 0.06, "vitfro" = 0.04, "nicotine" = 0.04)


/obj/item/seeds/lavaland/inocybe
	name = "pack of inocybe mycelium"
	desc = "This mycelium grows into an inocybe mushroom, a species of Lavaland origin with hallucinatory and toxic effects."
	icon_state = "mycelium-inocybe"
	species = "inocybe"
	plantname = "Inocybe Mushrooms"
	product = /obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_cap
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism, /datum/plant_gene/trait/fire_resistance)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	reagents_add = list("lsd" = 0.04, "entpoly" = 0.08, "psilocybin" = 0.04)

/obj/item/seeds/lavaland/ember
	name = "pack of embershroom mycelium"
	desc = "This mycelium grows into embershrooms, a species of bioluminescent mushrooms native to Lavaland."
	icon_state = "mycelium-ember"
	species = "ember"
	plantname = "Embershroom Mushrooms"
	product = /obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_stem
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism, /datum/plant_gene/trait/glow, /datum/plant_gene/trait/fire_resistance)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	reagents_add = list("tinlux" = 0.04, "vitamin" = 0.02, "space_drugs" = 0.02)

/obj/item/seeds/lavaland/fireblossom
	name = "pack of fire blossom seeds"
	desc = "These seeds grow into fire blossoms."
	icon_state = "seed-fireblossom"
	species = "fireblossom"
	plantname = "Fire Blossom"
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	product = /obj/item/reagent_containers/food/snacks/grown/ash_flora/fireblossom
	genes = list(/datum/plant_gene/trait/fire_resistance, /datum/plant_gene/trait/glow/yellow)
	reagents_add = list("tinlux" = 0.04, "nutriment" = 0.03, "carbon" = 0.05)

/obj/item/seeds/lavaland/coaltree
	name = "pack of coaltree seeds"
	desc = "Эти семена вырастут в угледрево."
	gender = FEMALE
	icon_state = "seed-coaltree"
	species = "coaltree"
	plantname = "Coaltree"
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing.dmi'
	product = /obj/item/reagent_containers/food/snacks/grown/ash_flora/coaltree_log
	genes = list(/datum/plant_gene/trait/fire_resistance)
	reagents_add = list("nutriment" = 0.04, "coaltree_extract" = 0.1)

/obj/item/seeds/lavaland/coaltree/get_ru_names()
	return list(
		NOMINATIVE = "пачка семян угледрева",
		GENITIVE = "пачки семян угледрева",
		DATIVE = "пачке семян угледрева",
		ACCUSATIVE = "пачку семян угледрева",
		INSTRUMENTAL = "пачкой семян угледрева",
		PREPOSITIONAL = "пачке семян угледрева"
	)

//CRAFTING

//what you can craft with these things
/datum/crafting_recipe/mushroom_bowl
	name = "Mushroom Bowl"
	result = /obj/item/reagent_containers/food/drinks/mushroom_bowl
	reqs = list(/obj/item/reagent_containers/food/snacks/grown/ash_flora/shavings = 5)
	time = 30
	category = CAT_PRIMAL
	subcategory = CAT_MISC2

/obj/item/reagent_containers/food/drinks/mushroom_bowl
	name = "mushroom bowl"
	desc = "Мисковая чаша. Не еда, хотя когда-то могла содержать её."
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "mushroom_bowl"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/reagent_containers/food/drinks/mushroom_bowl/get_ru_names()
	return list(
		NOMINATIVE = "грибная чаша",
		GENITIVE = "грибной чаши",
		DATIVE = "грибной чаше",
		ACCUSATIVE = "грибную чашу",
		INSTRUMENTAL = "грибной чашей",
		PREPOSITIONAL = "грибной чаше"
	)

/obj/item/reagent_containers/food/drinks/mushroom_bowl/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/lavaland_dye))
		return ..()

	var/obj/item/lavaland_dye/dye = I
	to_chat(user, span_notice("Вы начали толочь селезёнку в ступке."))
	if(!do_after(user, 5 SECONDS, src, max_interact_count = 1, cancel_on_max = TRUE))
		return ..()

	var/obj/item/lavaland_mortar/new_item = new(loc)
	new_item.picked_dye = dye.picked_dye
	new_item.totem_dye = dye.totem_dye
	new_item.fluff_name = dye.fluff_name
	new_item.update_icon(UPDATE_ICON_STATE)

	user.put_in_hands(new_item)

	qdel(dye)
	qdel(src)
	return ATTACK_CHAIN_BLOCKED_ALL

/*********
 * Rocks *
 *********/
// (I know these aren't plants)

/obj/structure/flora/ash/rock
	name = "large rock"
	desc = "A volcanic rock. Pioneers used to ride these babies for miles."
	icon_state = "basalt1"
	density = TRUE
	resistance_flags = FIRE_PROOF
	harvest = /obj/item/stack/ore/glass/basalt
	harvest_time = 6 SECONDS
	harvest_amount_low = 10
	harvest_amount_high = 20
	harvest_message_low = "You finish mining the rock."
	harvest_message_med = "You finish mining the rock."
	harvest_message_high = "You finish mining the rock."
	delete_on_harvest = TRUE

/obj/structure/flora/ash/rock/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_ROCK, -20, 10)

/obj/structure/flora/ash/rock/style_2
	icon_state = "basalt2"

/obj/structure/flora/ash/rock/style_3
	icon_state = "basalt3"

/obj/structure/flora/ash/rock/style_4
	icon_state = "basalt4"

/obj/structure/flora/ash/rock/style_random/Initialize(mapload)
	. = ..()
	icon_state = "basalt[rand(1, 4)]"
