// MARK: Base Glass
/obj/item/reagent_containers/cup/glass
	name = "drink"
	icon = 'icons/obj/drinks.dmi'
	icon_state = null
	possible_transfer_amounts = list(5,10,15,20,25,30,50)
	resistance_flags = NONE
	isGlass = TRUE

/obj/item/reagent_containers/cup/glass/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum, do_splash = TRUE)
	. = ..()
	if(!.) //if the bottle wasn't caught
		smash(hit_atom, throwingdatum?.get_thrower(), throwingdatum)

/obj/item/reagent_containers/cup/glass/proc/smash(atom/target, atom/thrower, datum/thrownthing/throwingdatum, break_top = FALSE)
	if(!isGlass)
		return FALSE
	if(QDELING(src) || !target) //Invalid loc
		return FALSE
	var/splash_target = QDELETED(target) ? target.drop_location() : target
	var/splash_thrower = ismob(thrower) ? thrower : null
	splash_reagents(splash_target, splash_thrower, allow_closed_splash = TRUE)
	var/obj/item/broken_bottle/broken = new (loc)
	broken.mimic_broken(src, target, break_top)
	post_smash(target, thrower, throwingdatum, broken)
	qdel(src)
	return TRUE

/obj/item/reagent_containers/cup/glass/proc/post_smash(atom/target, atom/thrower, datum/thrownthing/throwingdatum, obj/item/broken_bottle/broken)
	return

// MARK: Trophy
/obj/item/reagent_containers/cup/glass/trophy
	name = "pewter cup"
	desc = "Everyone gets a trophy."
	icon_state = "pewter_cup"
	force = 1
	throwforce = 1
	materials = list(MAT_METAL=100)
	possible_transfer_amounts = null
	volume = 5
	flags = CONDUCT
	resistance_flags = FIRE_PROOF
	isGlass = FALSE

/obj/item/reagent_containers/cup/glass/trophy/gold_cup
	name = "gold cup"
	desc = "You're winner!"
	icon_state = "golden_cup"
	w_class = WEIGHT_CLASS_BULKY
	force = 14
	throwforce = 10
	amount_per_transfer_from_this = 20
	materials = list(MAT_GOLD=1000)
	volume = 150

/obj/item/reagent_containers/cup/glass/trophy/silver_cup
	name = "silver cup"
	desc = "Best loser!"
	icon_state = "silver_cup"
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	throwforce = 8
	amount_per_transfer_from_this = 15
	materials = list(MAT_SILVER=800)
	volume = 100

/obj/item/reagent_containers/cup/glass/trophy/bronze_cup
	name = "bronze cup"
	desc = "At least you ranked!"
	icon_state = "bronze_cup"
	w_class = WEIGHT_CLASS_SMALL
	force = 5
	throwforce = 4
	materials = list(MAT_METAL=400)
	volume = 25

// MARK: Ice Cup
/obj/item/reagent_containers/cup/glass/ice
	name = "ice cup"
	desc = "Стаканчик льда. Не жуйте, а то горло болеть будет."
	icon_state = "icecup"
	list_reagents = list("ice" = 30)
	isGlass = FALSE

/obj/item/reagent_containers/cup/glass/ice/get_ru_names()
	return alist(
		NOMINATIVE = "стаканчик льда",
		GENITIVE = "стаканчика льда",
		DATIVE = "стаканчику льда",
		ACCUSATIVE = "стаканчик льда",
		INSTRUMENTAL = "стаканчиком льда",
		PREPOSITIONAL = "стаканчике льда",
	)

// MARK: Hot Drinks
/obj/item/reagent_containers/cup/glass/tea
	name = "Duke Purple tea"
	desc = "An insult to Duke Purple is an insult to the Space Queen! Any proper gentleman will fight you, if you sully this tea."
	icon_state = "teacup"
	item_state = "coffee"
	list_reagents = list("tea" = 30)

/obj/item/reagent_containers/cup/glass/tea/Initialize(mapload)
	. = ..()
	if(prob(20))
		reagents.add_reagent("mugwort", 3)

/obj/item/reagent_containers/cup/glass/mugwort
	name = "mugwort tea"
	desc = "A bitter herbal tea."
	icon_state = "manlydorfglass"
	item_state = "coffee"
	list_reagents = list("mugwort" = 30)

/obj/item/reagent_containers/cup/glass/h_chocolate
	name = "Dutch hot coco"
	desc = "Made in Space South America."
	icon_state = "hot_coco"
	item_state = "coffee"
	list_reagents = list("hot_coco" = 30, "sugar" = 5)
	resistance_flags = FREEZE_PROOF

/obj/item/reagent_containers/cup/glass/chocolate
	name = "hot chocolate"
	desc = "Made in Space Switzerland."
	icon_state = "hot_coco"
	item_state = "coffee"
	list_reagents = list("hot_coco" = 15, "chocolate" = 6, "water" = 9)
	resistance_flags = FREEZE_PROOF

// MARK: Weight-loss Shake
/obj/item/reagent_containers/cup/glass/weightloss
	name = "weight-loss shake"
	desc = "A shake designed to cause weight loss.  The package proudly proclaims that it is 'tapeworm free.'"
	icon_state = "weightshake"
	list_reagents = list("lipolicide" = 30, "chocolate" = 5)
	drink_type = GROSS
	isGlass = FALSE

// MARK: Liguid Food
/obj/item/reagent_containers/cup/glass/dry_ramen
	name = "cup ramen"
	desc = "Just add 10ml of water, self heats! A taste that reminds you of your school years."
	icon_state = "ramen"
	item_state = "ramen"
	list_reagents = list("dry_ramen" = 30)
	isGlass = FALSE

/obj/item/reagent_containers/cup/glass/dry_ramen/Initialize(mapload)
	. = ..()
	if(prob(20))
		reagents.add_reagent("enzyme", 3)

/obj/item/reagent_containers/cup/glass/chicken_soup
	name = "canned chicken soup"
	desc = "A delicious and soothing can of chicken noodle soup; just like spessmom used to microwave it."
	icon_state = "soupcan"
	item_state = "soupcan"
	list_reagents = list("chicken_soup" = 30)
	drink_type = JUNKFOOD
	isGlass = FALSE

/obj/item/reagent_containers/cup/glass/sillycup
	name = "paper cup"
	desc = "A paper water cup."
	icon_state = "water_cup_e"
	item_state = "coffee"
	possible_transfer_amounts = null
	volume = 10
	isGlass = FALSE

/obj/item/reagent_containers/cup/glass/sillycup/update_icon_state()
	icon_state = "water_cup[reagents.total_volume ? "" : "_e"]"

// MARK: Shaker
/obj/item/reagent_containers/cup/glass/shaker
	name = "shaker"
	desc = "A metal shaker to mix drinks in."
	icon_state = "shaker"
	materials = list(MAT_METAL=1500)
	volume = 100
	isGlass = FALSE

// MARK: Flasks
/obj/item/reagent_containers/cup/glass/flask
	name = "flask"
	desc = "Every good spaceman knows it's a good idea to bring along a couple of pints of whiskey wherever they go."
	icon_state = "flask"
	materials = list(MAT_METAL=250)
	volume = 60
	isGlass = FALSE

/obj/item/reagent_containers/cup/glass/flask/barflask
	desc = "For those who can't be bothered to hang out at the bar to drink."
	icon_state = "barflask"

/obj/item/reagent_containers/cup/glass/flask/gold
	name = "captain's flask"
	desc = "A gold flask belonging to the captain."
	icon_state = "flask_gold"
	materials = list(MAT_GOLD=500)

/obj/item/reagent_containers/cup/glass/flask/detflask
	name = "detective's flask"
	desc = "The detective's only true friend."
	icon_state = "detflask"
	list_reagents = list("whiskey" = 30)

/obj/item/reagent_containers/cup/glass/flask/hand_made
	name = "handmade flask"
	desc = "A wooden flask with a silver lid and bottom. It has a matte, dark blue paint on it with the initials \"W.H.\" etched in black."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "williamhackett"
	materials = list()

/obj/item/reagent_containers/cup/glass/flask/thermos
	name = "vintage thermos"
	desc = "An older thermos with a faint shine."
	icon_state = "thermos"
	volume = 50

/obj/item/reagent_containers/cup/glass/flask/shiny
	name = "shiny flask"
	desc = "A shiny metal flask. It appears to have a Greek symbol inscribed on it."
	icon_state = "shinyflask"
	volume = 50

/obj/item/reagent_containers/cup/glass/flask/lithium
	name = "lithium flask"
	desc = "A flask with a Lithium Atom symbol on it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "lithiumflask"
	volume = 50

// MARK: Misc
/obj/item/reagent_containers/cup/glass/britcup
	name = "cup"
	desc = "A cup with the british flag emblazoned on it."
	icon_state = "britcup"
	volume = 30

/obj/item/reagent_containers/cup/glass/oilcan
	name = "oil can"
	desc = "Contains oil intended for use on cyborgs, robots, and other synthetics."
	icon = 'icons/goonstation/objects/oil.dmi'
	icon_state = "oilcan"
	volume = 100

/obj/item/reagent_containers/cup/glass/oilcan/full
	list_reagents = list("oil" = 100)

/obj/item/reagent_containers/cup/glass/zaza
	name = "Cherry Zaza"
	desc = "I possess Zaza!"
	icon_state = "zaza_can"
	item_state = "zaza_can"
	volume = 80
	drink_type = SUGAR
	container_type = NONE
	list_reagents = list("zaza" = 80)
	can_lid = TRUE
	fill_icon_thresholds = list(50, 60, 65, 70, 75, 80)
	isGlass = FALSE

// MARK: Sport Food
/obj/item/reagent_containers/cup/glass/protein
	name = "банка протеина"
	desc = "Банка наполненная протеиновым порошком. Этот вид протеина был снят с производства. \
			Если вы встретили его, обратитесь к техподдержке."
	icon_state = "protein_zaza"
	item_state = "protein_zaza"
	volume = 80
	drink_type = GROSS
	list_reagents = list("protein" = 80)
	isGlass = FALSE

/obj/item/reagent_containers/cup/glass/protein/get_ru_names()
	return alist(
		NOMINATIVE = "банка протеина",
		GENITIVE = "банки протеина",
		DATIVE = "банке протеина",
		ACCUSATIVE = "банку протеина",
		INSTRUMENTAL = "банкой протеина",
		PREPOSITIONAL = "банке протеина",
	)

/obj/item/reagent_containers/cup/glass/protein/zaza
	name = "банка протеина (Заза)"
	desc = "Банка наполненная протеиновым порошком. \
			На самом деле не отличается от банки протеина со вкусом вишни ничем кроме изображения на этикетке."
	list_reagents = list("protein" = 70, "zaza" = 10)

/obj/item/reagent_containers/cup/glass/protein/zaza/get_ru_names()
	return alist(
		NOMINATIVE = "банка протеина (Заза)",
		GENITIVE = "банки протеина (Заза)",
		DATIVE = "банке протеина (Заза)",
		ACCUSATIVE = "банку протеина (Заза)",
		INSTRUMENTAL = "банкой протеина (Заза)",
		PREPOSITIONAL = "банке протеина (Заза)",
	)

/obj/item/reagent_containers/cup/glass/protein/cherry
	name = "банка протеина (Вишня)"
	desc = "Банка наполненная протеиновым порошком со вкусом вишни. \
			На самом деле не отличается от банки протеина со вкусом Зазы ничем кроме изображения на этикетке."
	icon_state = "protein_cherry"
	item_state = "protein_cherry"
	list_reagents = list("protein" = 70, "cherryshake" = 10)

/obj/item/reagent_containers/cup/glass/protein/cherry/get_ru_names()
	return alist(
		NOMINATIVE = "банка протеина (Вишня)",
		GENITIVE = "банки протеина (Вишня)",
		DATIVE = "банке протеина (Вишня)",
		ACCUSATIVE = "банку протеина (Вишня)",
		INSTRUMENTAL = "банкой протеина (Вишня)",
		PREPOSITIONAL = "банке протеина (Вишня)",
	)

/obj/item/reagent_containers/cup/glass/protein/chocolate
	name = "банка протеина (Шоколад)"
	desc = "Банка наполненная протеиновым порошком со вкусом шоколада. \
			Единственный вкус протеинового порошка не вызывающий отвращения при потреблении в неразбавленном виде."
	icon_state = "protein_chocolate"
	item_state = "protein_chocolate"
	list_reagents = list("protein" = 70, "chocolate" = 10)
	drink_type = SUGAR

/obj/item/reagent_containers/cup/glass/protein/chocolate/get_ru_names()
	return alist(
		NOMINATIVE = "банка протеина (Шоколад)",
		GENITIVE = "банки протеина (Шоколад)",
		DATIVE = "банке протеина (Шоколад)",
		ACCUSATIVE = "банку протеина (Шоколад)",
		INSTRUMENTAL = "банкой протеина (Шоколад)",
		PREPOSITIONAL = "банке протеина (Шоколад)",
	)

/obj/item/reagent_containers/cup/glass/protein/bananastrawberry
	name = "банка протеина (Банан и клубника)"
	desc = "Банка наполненная протеиновым порошком со вкусом банана и клубники. \
			До ребрендинга вместо банана и клубники была просто клубника."
	icon_state = "protein_bananastrawberry"
	item_state = "protein_bananastrawberry"
	list_reagents = list("protein" = 70, "banana" = 5, "strawwberry" = 5)

/obj/item/reagent_containers/cup/glass/protein/bananastrawberry/get_ru_names()
	return alist(
		NOMINATIVE = "банка протеина (Банан и клубника)",
		GENITIVE = "банки протеина (Банан и клубника)",
		DATIVE = "банке протеина (Банан и клубника)",
		ACCUSATIVE = "банку протеина (Банан и клубника)",
		INSTRUMENTAL = "банкой протеина (Банан и клубника)",
		PREPOSITIONAL = "банке протеина (Банан и клубника)",
	)

/obj/item/reagent_containers/cup/glass/guarana
	name = "ампула экстракта гуараны"
	desc = "Ампула содержащая экстракт гуараны — вещество стимулирующее мышечную активность. \
			На этикетке нарисована малина, не смотря на то, что в составе нет ничего связанного с ней."
	icon_state = "guarana_raspberry"
	item_state = "guarana_raspberry"
	list_reagents = list("guarana" = 10)
	isGlass = FALSE

/obj/item/reagent_containers/cup/glass/guarana/get_ru_names()
	return alist(
		NOMINATIVE = "ампула экстракта гуараны",
		GENITIVE = "ампулы экстракта гуараны",
		DATIVE = "ампуле экстракта гуараны",
		ACCUSATIVE = "ампулу экстракта гуараны",
		INSTRUMENTAL = "ампулой экстракта гуараны",
		PREPOSITIONAL = "ампуле экстракта гуараны",
	)

/obj/item/reagent_containers/cup/glass/creatine
	name = "бутылочка креатина"
	desc = "Бутылочка содержащая креатин — вещество повышающее скорость развития мышц. \
			На этикетке нарисована малина, не смотря на то, что в составе нет ничего связанного с ней."
	icon_state = "creatine"
	item_state = "creatine"
	list_reagents = list("creatine" = 10)
	isGlass = FALSE

/obj/item/reagent_containers/cup/glass/creatine/get_ru_names()
	return alist(
		NOMINATIVE = "бутылочка креатина",
		GENITIVE = "бутылочкы креатина",
		DATIVE = "бутылочке креатина",
		ACCUSATIVE = "бутылочку креатина",
		INSTRUMENTAL = "бутылочкой креатина",
		PREPOSITIONAL = "бутылочке креатина",
	)
