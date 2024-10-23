/obj/structure/flora/ash
	gender = PLURAL
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER //sporangiums up don't shoot
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "l_mushroom"
	name = "large mushrooms"
	desc = "A number of large mushrooms, covered in a faint layer of ash and what can only be spores."
	anchored = TRUE
	var/harvested_name = "shortened mushrooms"
	var/harvested_desc = "Some quickly regrowing mushrooms, formerly known to be quite large."
	var/needs_sharp_harvest = TRUE
	var/harvest = /obj/item/reagent_containers/food/snacks/grown/ash_flora/shavings
	var/harvest_amount_low = 1
	var/harvest_amount_high = 3
	var/harvest_time = 60
	var/harvest_message_low = "You pick a mushroom, but fail to collect many shavings from its cap."
	var/harvest_message_med = "You pick a mushroom, carefully collecting the shavings from its cap."
	var/harvest_message_high = "You harvest and collect shavings from several mushroom caps."
	var/harvested = FALSE
	var/delete_on_harvest = FALSE
	var/base_icon
	var/regrowth_time_low = 8 MINUTES
	var/regrowth_time_high = 16 MINUTES

/obj/structure/flora/ash/Initialize(mapload)
	. = ..()
	base_icon = "[icon_state][rand(1, 4)]"
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
			to_chat(user, "<span class='notice'>[msg]</span>")
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
			span_notice("[user] starts to harvest [src] with [I]."),
			span_notice("You start to harvest [src]."),
		)
		if(!do_after(user, harvest_time * I.toolspeed, src, category = DA_CAT_TOOL) || harvested)
			return ATTACK_CHAIN_PROCEED
		harvest(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/flora/ash/attack_hand(mob/user)
	if(!harvested && !needs_sharp_harvest)
		user.visible_message("<span class='notice'>[user] starts to harvest from [src].</span>","<span class='notice'>You begin to harvest from [src].</span>")
		if(do_after(user, harvest_time, src))
			add_fingerprint(user)
			harvest(user)
	else
		..()

/obj/structure/flora/ash/tall_shroom //exists only so that the spawning check doesn't allow these spawning near other things
	regrowth_time_low = 4200

/obj/structure/flora/ash/leaf_shroom
	icon_state = "s_mushroom"
	name = "leafy mushrooms"
	desc = "A number of mushrooms, each of which surrounds a greenish sporangium with a number of leaf-like structures."
	harvested_name = "leafless mushrooms"
	harvested_desc = "A bunch of formerly-leafed mushrooms, with their sporangiums exposed. Scandalous?"
	harvest = /obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_leaf
	needs_sharp_harvest = FALSE
	harvest_amount_high = 4
	harvest_time = 20
	harvest_message_low = "You pluck a single, suitable leaf."
	harvest_message_med = "You pluck a number of leaves, leaving a few unsuitable ones."
	harvest_message_high = "You pluck quite a lot of suitable leaves."
	regrowth_time_low = 2400
	regrowth_time_high = 6000

/obj/structure/flora/ash/cap_shroom
	icon_state = "r_mushroom"
	name = "tall mushrooms"
	desc = "Several mushrooms, the larger of which have a ring of conks at the midpoint of their stems."
	harvested_name = "small mushrooms"
	harvested_desc = "Several small mushrooms near the stumps of what likely were larger mushrooms."
	harvest = /obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_cap
	harvest_amount_high = 4
	harvest_time = 50
	harvest_message_low = "You slice the cap off of a mushroom."
	harvest_message_med = "You slice off a few conks from the larger mushrooms."
	harvest_message_high = "You slice off a number of caps and conks from these mushrooms."
	regrowth_time_low = 3000
	regrowth_time_high = 5400

/obj/structure/flora/ash/stem_shroom
	icon_state = "t_mushroom"
	name = "numerous mushrooms"
	desc = "A large number of mushrooms, some of which have long, fleshy stems. They're radiating light!"
	light_range = 1.5
	light_power = 2.1
	harvested_name = "tiny mushrooms"
	harvested_desc = "A few tiny mushrooms around larger stumps. You can already see them growing back."
	harvest = /obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_stem
	harvest_amount_high = 4
	harvest_time = 40
	harvest_message_low = "You pick and slice the cap off of a mushroom, leaving the stem."
	harvest_message_med = "You pick and decapitate several mushrooms for their stems."
	harvest_message_high = "You acquire a number of stems from these mushrooms."
	regrowth_time_low = 3000
	regrowth_time_high = 6000

/obj/structure/flora/ash/cacti
	icon_state = "cactus"
	name = "fruiting cacti"
	desc = "Several prickly cacti, brimming with ripe fruit and covered in a thin layer of ash."
	harvested_name = "cacti"
	harvested_desc = "A bunch of prickly cacti. You can see fruits slowly growing beneath the covering of ash."
	harvest = /obj/item/reagent_containers/food/snacks/grown/ash_flora/cactus_fruit
	needs_sharp_harvest = FALSE
	harvest_amount_high = 2
	harvest_time = 10
	harvest_message_low = "You pick a cactus fruit."
	harvest_message_med = "You pick several cactus fruit." //shouldn't show up, because you can't get more than two
	harvest_message_high = "You pick a pair of cactus fruit."
	regrowth_time_low = 4800
	regrowth_time_high = 7200

/obj/structure/flora/ash/cacti/Initialize(mapload)
	. = ..()
	// min dmg 3, max dmg 6, prob(70)
	AddComponent(/datum/component/caltrop, 3, 6, 70)

/obj/structure/flora/ash/fireblossom
	icon_state = "fireblossom"
	name = "fire blossom"
	desc = "An odd flower that grows commonly near bodies of lava."
	harvested_name = "fire blossom stems"
	harvested_desc = "A few fire blossom stems, missing their flowers."
	harvest = /obj/item/reagent_containers/food/snacks/grown/ash_flora/fireblossom
	needs_sharp_harvest = FALSE
	light_range = 1.5
	light_power = 2.1
	light_color = "#FFFF66"
	harvest_amount_high = 3
	harvest_time = 10
	harvest_message_low = "You pluck a single, suitable flower."
	harvest_message_med = "You pluck a number of flowers, leaving a few unsuitable ones."
	harvest_message_high = "You pluck quite a lot of suitable flowers."
	regrowth_time_low = 2500
	regrowth_time_high = 4000

/obj/structure/flora/ash/coaltree
	icon_state = "coaltree"
	name = "coaltree"
	desc = "Небольшое мрачное дерево, растущее на просторах такой же мрачной планеты."
	harvested_name = "coaltree stump"
	harvested_desc = "Голый ствол дерева, оставшийся без своей уродливой кроны."
	harvest = /obj/item/reagent_containers/food/snacks/grown/ash_flora/coaltree_log
	harvest_amount_high = 5
	harvest_time = 40
	harvest_message_low = "Вы обрезаете небольшое дерево."
	harvest_message_med = "Вы обрезаете дерево среднего размера."
	harvest_message_high = "Вы обрезаете большое дерево."
	regrowth_time_low = 4000
	regrowth_time_high = 6000

/obj/item/reagent_containers/food/snacks/grown/ash_flora
	name = "mushroom shavings"
	desc = "Some shavings from a tall mushroom. With enough, might serve as a bowl."
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "mushroom_shavings"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_integrity = 100
	seed = /obj/item/seeds/lavaland/polypore
	wine_power = 0.2

/obj/item/reagent_containers/food/snacks/grown/ash_flora/Initialize(mapload)
	. = ..()
	pixel_x = rand(-4, 4)
	pixel_y = rand(-4, 4)

/obj/item/reagent_containers/food/snacks/grown/ash_flora/shavings //for actual crafting

/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_leaf
	name = "mushroom leaf"
	desc = "A leaf, from a mushroom."
	icon_state = "mushroom_leaf"
	seed = /obj/item/seeds/lavaland/porcini
	wine_power = 0.4

/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_cap
	name = "mushroom cap"
	desc = "The cap of a large mushroom."
	icon_state = "mushroom_cap"
	seed = /obj/item/seeds/lavaland/inocybe
	wine_power = 0.7

/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_stem
	name = "mushroom stem"
	desc = "A long mushroom stem. It's slightly glowing."
	icon_state = "mushroom_stem"
	seed = /obj/item/seeds/lavaland/ember
	wine_power = 0.6

/obj/item/reagent_containers/food/snacks/grown/ash_flora/cactus_fruit
	name = "cactus fruit"
	desc = "A cactus fruit covered in a thick, reddish skin. And some ash."
	icon_state = "cactus_fruit"
	seed = /obj/item/seeds/lavaland/cactus
	wine_power = 0.5

/obj/item/reagent_containers/food/snacks/grown/ash_flora/fireblossom
	name = "fire blossom"
	desc = "A flower from a fire blossom."
	icon_state = "fireblossom"
	slot_flags = ITEM_SLOT_HEAD
	seed = /obj/item/seeds/lavaland/fireblossom
	wine_power = 0.4

/obj/item/reagent_containers/food/snacks/grown/ash_flora/coaltree_log
	name = "coaltree log"
	desc = "Бревно угледрева, на ощупь мягкое."
	icon_state = "coaltree_log"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	item_state = "coaltree_log"
	seed = /obj/item/seeds/lavaland/coaltree
	wine_power = 0.5
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/reagent_containers/food/snacks/grown/ash_flora/coaltree_log/attackby(obj/item/I, mob/user, params)
	if(is_sharp(I))
		if(!isturf(loc))
			add_fingerprint(user)
			to_chat(user, span_warning("You cannot chop [src] [ismob(loc) ? "in inventory" : "in [loc]"]."))
			return ATTACK_CHAIN_PROCEED

		to_chat(user, span_notice("You have chopped [src] into planks."))
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
	desc = "These seeds grow into coaltree."
	icon_state = "seed-coaltree"
	species = "coaltree"
	plantname = "Coaltree"
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing.dmi'
	product = /obj/item/reagent_containers/food/snacks/grown/ash_flora/coaltree_log
	genes = list(/datum/plant_gene/trait/fire_resistance)
	reagents_add = list("nutriment" = 0.04, "coaltree_extract" = 0.1)

//CRAFTING

//what you can craft with these things
/datum/crafting_recipe/mushroom_bowl
	name = "Mushroom Bowl"
	result = /obj/item/reagent_containers/food/drinks/mushroom_bowl
	reqs = list(/obj/item/reagent_containers/food/snacks/grown/ash_flora/shavings = 5)
	time = 30
	category = CAT_PRIMAL

/obj/item/reagent_containers/food/drinks/mushroom_bowl
	name = "mushroom bowl"
	desc = "A bowl made out of mushrooms. Not food, though it might have contained some at some point."
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "mushroom_bowl"
	w_class = WEIGHT_CLASS_SMALL


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

/obj/structure/flora/ash/rock/style_2
	icon_state = "basalt2"

/obj/structure/flora/ash/rock/style_3
	icon_state = "basalt3"

/obj/structure/flora/ash/rock/style_4
	icon_state = "basalt4"

/obj/structure/flora/ash/rock/style_random/Initialize(mapload)
	. = ..()
	icon_state = "basalt[rand(1, 4)]"
