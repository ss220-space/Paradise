
//////////////////////
//		Breads		//
//////////////////////

/obj/item/reagent_containers/food/snacks/sliceable/bread/meat
	name = "meatbread loaf"
	desc = "Кулинарная основа каждой уважающей себя джентьмен_ессы."
	ru_names = list(
		NOMINATIVE = "мясной батон",
		GENITIVE = "мясного батона",
		DATIVE = "мясному батону",
		ACCUSATIVE = "мясной батон",
		INSTRUMENTAL = "мясным батоном",
		PREPOSITIONAL = "мясном батоне"
	)
	icon_state = "meatbread"
	slice_path = /obj/item/reagent_containers/food/snacks/meatbreadslice
	slices_num = 5
	filling_color = "#FF7575"
	list_reagents = list("protein" = 20, "nutriment" = 10, "vitamin" = 5)
	tastes = list("хлеба" = 10, "мяса" = 10)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/meatbreadslice
	name = "meatbread slice"
	desc = "Ломтик вкуснейшего мясного хлеба."
	ru_names = list(
		NOMINATIVE = "ломтик мясного батона",
		GENITIVE = "ломтика мясного батона",
		DATIVE = "ломтику мясного батона",
		ACCUSATIVE = "ломтик мясного батона",
		INSTRUMENTAL = "ломтиком мясного батона",
		PREPOSITIONAL = "ломтике мясного батона"
	)
	icon_state = "meatbreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#FF7575"
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/sliceable/bread/xeno
	name = "xenomeatbread loaf"
	desc = "Кулинарная основа каждого уважающего себя джентльмена. Особенно еретичная."
	ru_names = list(
		NOMINATIVE = "батон с ксеномясом",
		GENITIVE = "батона с ксеномясом",
		DATIVE = "батону с ксеномясом",
		ACCUSATIVE = "батон с ксеномясом",
		INSTRUMENTAL = "батоном с ксеномясом",
		PREPOSITIONAL = "батоне с ксеномясом"
	)
	icon_state = "xenomeatbread"
	slice_path = /obj/item/reagent_containers/food/snacks/xenomeatbreadslice
	slices_num = 5
	filling_color = "#8AFF75"
	list_reagents = list("protein" = 20, "nutriment" = 10, "vitamin" = 5)
	tastes = list("хлеба" = 10, "кислоты" = 10)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/xenomeatbreadslice
	name = "xenomeatbread slice"
	desc = "Ломтик вкуснейшего мясного хлеба. Особенно еретичный."
	ru_names = list(
		NOMINATIVE = "ломтик батона с ксеномясом",
		GENITIVE = "ломтика батона с ксеномясом",
		DATIVE = "ломтику батона с ксеномясом",
		ACCUSATIVE = "ломтик батона с ксеномясом",
		INSTRUMENTAL = "ломтиком батона с ксеномясом",
		PREPOSITIONAL = "ломтике батона с ксеномясом"
	)
	icon_state = "xenobreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#8AFF75"
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/sliceable/bread/spider
	name = "spider meat loaf"
	desc = "Успокаивающе зелёный мясной батон из паучьего мяса."
	ru_names = list(
		NOMINATIVE = "паучий мясной батон",
		GENITIVE = "паучьего мясного батона",
		DATIVE = "паучьему мясному батону",
		ACCUSATIVE = "паучий мясной батон",
		INSTRUMENTAL = "паучьим мясным батоном",
		PREPOSITIONAL = "паучьем мясном батоне"
	)
	icon_state = "spidermeatbread"
	slice_path = /obj/item/reagent_containers/food/snacks/spidermeatbreadslice
	slices_num = 5
	list_reagents = list("protein" = 20, "nutriment" = 10, "toxin" = 15, "vitamin" = 5)
	tastes = list("хлеба" = 10, "паутины" = 5)
	foodtype = GRAIN | MEAT | TOXIC

/obj/item/reagent_containers/food/snacks/spidermeatbreadslice
	name = "spider meat bread slice"
	desc = "Ломтик мясного батона из существа, которое, скорее всего, всё ещё хочет вас убить."
	ru_names = list(
		NOMINATIVE = "ломтик паучьего батона",
		GENITIVE = "ломтика паучьего батона",
		DATIVE = "ломтику паучьего батона",
		ACCUSATIVE = "ломтик паучьего батона",
		INSTRUMENTAL = "ломтиком паучьего батона",
		PREPOSITIONAL = "ломтике паучьего батона"
	)
	icon_state = "xenobreadslice"
	trash = /obj/item/trash/plate
	list_reagents = list("toxin" = 2)
	foodtype = GRAIN | MEAT | TOXIC

/obj/item/reagent_containers/food/snacks/sliceable/bread/banana
	name = "banana-nut bread"
	desc = "Небесное и сытное угощение."
	ru_names = list(
		NOMINATIVE = "банановый хлеб с орехами",
		GENITIVE = "бананового хлеба с орехами",
		DATIVE = "банановому хлебу с орехами",
		ACCUSATIVE = "банановый хлеб с орехами",
		INSTRUMENTAL = "банановым хлебом с орехами",
		PREPOSITIONAL = "банановом хлебе с орехами"
	)
	icon_state = "bananabread"
	slice_path = /obj/item/reagent_containers/food/snacks/bananabreadslice
	slices_num = 5
	filling_color = "#EDE5AD"
	list_reagents = list("banana" = 20, "nutriment" = 20)
	tastes = list("хлеба" = 10)
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/bananabreadslice
	name = "banana-nut bread slice"
	desc = "Ломтик вкуснейшего бананового хлеба."
	ru_names = list(
		NOMINATIVE = "ломтик бананового хлеба",
		GENITIVE = "ломтика бананового хлеба",
		DATIVE = "ломтику бананового хлеба",
		ACCUSATIVE = "ломтик бананового хлеба",
		INSTRUMENTAL = "ломтиком бананового хлеба",
		PREPOSITIONAL = "ломтике бананового хлеба"
	)
	icon_state = "bananabreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#EDE5AD"
	tastes = list("хлеба" = 10)
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/sliceable/bread/tofu
	name = "tofubread"
	desc = "Как мясной батон, но для вегетарианцев. Не гарантирует суперспособностей."
	ru_names = list(
		NOMINATIVE = "тофу-батон",
		GENITIVE = "тофу-батона",
		DATIVE = "тофу-батону",
		ACCUSATIVE = "тофу-батон",
		INSTRUMENTAL = "тофу-батоном",
		PREPOSITIONAL = "тофу-батоне"
	)
	icon_state = "Like meatbread but for vegetarians. Not guaranteed to give superpowers." // lmao
	icon_state = "tofubread"
	slice_path = /obj/item/reagent_containers/food/snacks/tofubreadslice
	slices_num = 5
	filling_color = "#F7FFE0"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("хлеба" = 10, "тофу" = 10)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/tofubreadslice
	name = "tofubread slice"
	desc = "Ломтик вкуснейшего тофу-хлеба."
	ru_names = list(
		NOMINATIVE = "ломтик тофу-батона",
		GENITIVE = "ломтика тофу-батона",
		DATIVE = "ломтику тофу-батона",
		ACCUSATIVE = "ломтик тофу-батона",
		INSTRUMENTAL = "ломтиком тофу-батона",
		PREPOSITIONAL = "ломтике тофу-батона"
	)
	icon_state = "tofubreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#F7FFE0"
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/sliceable/bread
	name = "bread"
	desc = "Обычный земной хлеб."
	ru_names = list(
		NOMINATIVE = "хлеб",
		GENITIVE = "хлеба",
		DATIVE = "хлебу",
		ACCUSATIVE = "хлеб",
		INSTRUMENTAL = "хлебом",
		PREPOSITIONAL = "хлебе"
	)
	icon_state = "bread"
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice
	slices_num = 6
	filling_color = "#FFE396"
	list_reagents = list("nutriment" = 10)
	tastes = list("хлеба" = 10)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/sliceable/bread/on_teleported()
	if(length(GLOB.bread_monsters) < GLOB.bread_monsters_maxcap)
		new /mob/living/simple_animal/hostile/bread_monster(get_turf(src))
		qdel(src)
	return

/obj/item/reagent_containers/food/snacks/breadslice
	name = "bread slice"
	desc = "Ломтик домашнего хлеба."
	ru_names = list(
		NOMINATIVE = "ломтик хлеба",
		GENITIVE = "ломтика хлеба",
		DATIVE = "ломтику хлеба",
		ACCUSATIVE = "ломтик хлеба",
		INSTRUMENTAL = "ломтиком хлеба",
		PREPOSITIONAL = "ломтике хлеба"
	)
	icon_state = "breadslice"
	trash = /obj/item/trash/plate
	filling_color = "#D27332"
	list_reagents = list("nutriment" = 2, "bread" = 5)
	tastes = list("хлеба" = 10)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/breadslice/burned
	name = "burned bread slice"
	desc = "Ломтик слегка подгоревшего хлеба. Возможно, не лучшая идея это есть..."
	ru_names = list(
		NOMINATIVE = "подгоревший ломтик хлеба",
		GENITIVE = "подгоревшего ломтика хлеба",
		DATIVE = "подгоревшему ломтику хлеба",
		ACCUSATIVE = "подгоревший ломтик хлеба",
		INSTRUMENTAL = "подгоревшим ломтиком хлеба",
		PREPOSITIONAL = "подгоревшем ломтике хлеба"
	)
	icon_state = "breadslice"
	trash = /obj/item/trash/plate
	filling_color = "#D27332"
	list_reagents = list("nutriment" = 2, "bread" = 5, "????" = 2)
	tastes = list("хлеба" = 10)
	foodtype = GRAIN | TOXIC

/obj/item/reagent_containers/food/snacks/sliceable/creamcheesebread
	name = "cream cheese bread"
	desc = "Ням-ням-ням!"
	ru_names = list(
		NOMINATIVE = "хлеб с творожным сыром",
		GENITIVE = "хлеба с творожным сыром",
		DATIVE = "хлебу с творожным сыром",
		ACCUSATIVE = "хлеб с творожным сыром",
		INSTRUMENTAL = "хлебом с творожным сыром",
		PREPOSITIONAL = "хлебе с творожным сыром"
	)
	icon_state = "creamcheesebread"
	slice_path = /obj/item/reagent_containers/food/snacks/creamcheesebreadslice
	slices_num = 5
	filling_color = "#FFF896"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("хлеба" = 10, "сыра" = 10)
	foodtype = GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/creamcheesebreadslice
	name = "cream cheese bread slice"
	desc = "Ломтик ням-няма!"
	ru_names = list(
		NOMINATIVE = "ломтик хлеба с творожным сыром",
		GENITIVE = "ломтика хлеба с творожным сыром",
		DATIVE = "ломтику хлеба с творожным сыром",
		ACCUSATIVE = "ломтик хлеба с творожным сыром",
		INSTRUMENTAL = "ломтиком хлеба с творожным сыром",
		PREPOSITIONAL = "ломтике хлеба с творожным сыром"
	)
	icon_state = "creamcheesebreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#FFF896"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("хлеба" = 10, "сыра" = 10)
	foodtype = GRAIN | DAIRY


//////////////////////
//		Misc		//
//////////////////////

/obj/item/reagent_containers/food/snacks/bun
	name = "bun"
	desc = "Основа для любого уважающего себя бургера."
	ru_names = list(
		NOMINATIVE = "булочка для бургера",
		GENITIVE = "булочки для бургера",
		DATIVE = "булочке для бургера",
		ACCUSATIVE = "булочку для бургера",
		INSTRUMENTAL = "булочкой для бургера",
		PREPOSITIONAL = "булочке для бургера"
	)
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "bun"
	list_reagents = list("nutriment" = 1)
	tastes = list("bun" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/bunbun
	name = "\improper Bun Bun"
	desc = "Маленькая хлебная обезьянка, сделанная из двух булочек для бургера."
	ru_names = list(
		NOMINATIVE = "Бун-Бун",
		GENITIVE = "Бун-Буа",
		DATIVE = "Бун-Буну",
		ACCUSATIVE = "Бун-Буна",
		INSTRUMENTAL = "Бун-Буном",
		PREPOSITIONAL = "Бун-Буну"
	)
	icon_state = "bunbun"
	list_reagents = list("nutriment" = 2)
	tastes = list("булочки" = 2)
	bitesize = 2
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/flatbread
	name = "flatbread"
	desc = "Пресно, но сытно."
	ru_names = list(
		NOMINATIVE = "лаваш",
		GENITIVE = "лаваша",
		DATIVE = "лавашу",
		ACCUSATIVE = "лаваш",
		INSTRUMENTAL = "лавашом",
		PREPOSITIONAL = "лаваше"
	)
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "flatbread"
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("хлеба" = 2)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/baguette
	name = "baguette"
	desc = "Bon appetit!"
	ru_names = list(
		NOMINATIVE = "багет",
		GENITIVE = "багета",
		DATIVE = "багету",
		ACCUSATIVE = "багет",
		INSTRUMENTAL = "багетом",
		PREPOSITIONAL = "багете"
	)
	icon_state = "baguette"
	item_state = "baguette"
	filling_color = "#E3D796"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("хлеба" = 2)
	foodtype = GRAIN
	slot_flags = ITEM_SLOT_BELT

/obj/item/reagent_containers/food/snacks/baguette/combat
	sharp = TRUE
	force = 20
	block_chance = 40

/obj/item/reagent_containers/food/snacks/twobread
	name = "two bread"
	desc = "Очень горький, как слёзы."
	ru_names = list(
		NOMINATIVE = "два хлеба",
		GENITIVE = "двух хлебов",
		DATIVE = "двум хлебам",
		ACCUSATIVE = "два хлеба",
		INSTRUMENTAL = "двумя хлебами",
		PREPOSITIONAL = "двух хлебах"
	)
	icon_state = "twobread"
	filling_color = "#DBCC9A"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "vitamin" = 2)
	tastes = list("хлеба" = 2)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/toast
	name = "toast"
	desc = "Да! Тосты!"
	ru_names = list(
		NOMINATIVE = "тост",
		GENITIVE = "тоста",
		DATIVE = "тосту",
		ACCUSATIVE = "тост",
		INSTRUMENTAL = "тостом",
		PREPOSITIONAL = "тосте"
	)
	icon_state = "toast"
	filling_color = "#B2580E"
	bitesize = 3
	list_reagents = list("nutriment" = 3)
	tastes = list("тостов" = 2)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/jelliedtoast
	name = "jellied toast"
	desc = "Ломтик хлеба, покрытый вкуснейшим джемом."
	ru_names = list(
		NOMINATIVE = "тост с джемом",
		GENITIVE = "тоста с джемом",
		DATIVE = "тосту с джемом",
		ACCUSATIVE = "тост с джемом",
		INSTRUMENTAL = "тостом с джемом",
		PREPOSITIONAL = "тосте с джемом"
	)
	icon_state = "jellytoast"
	trash = /obj/item/trash/plate
	filling_color = "#B572AB"
	bitesize = 3
	tastes = list("тостов" = 1, "желе" = 1)
	foodtype = GRAIN | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/jelliedtoast/cherry
	list_reagents = list("nutriment" = 1, "cherryjelly" = 5, "vitamin" = 2)

/obj/item/reagent_containers/food/snacks/jelliedtoast/slime
	list_reagents = list("nutriment" = 1, "slimejelly" = 5, "vitamin" = 2)

/obj/item/reagent_containers/food/snacks/rofflewaffles
	name = "roffle waffles"
	desc = "Вафли от компании Роффл."
	ru_names = list(
		NOMINATIVE = "вафли от Роффл Ко.",
		GENITIVE = "вафель от Роффл Ко.",
		DATIVE = "вафлям от Роффл Ко.",
		ACCUSATIVE = "вафли от Роффл Ко.",
		INSTRUMENTAL = "вафлями от Роффл Ко.",
		PREPOSITIONAL = "вафлях от Роффл Ко."
	)
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles
	filling_color = "#FF00F7"
	bitesize = 4
	list_reagents = list("nutriment" = 8, "psilocybin" = 2, "vitamin" = 2)
	tastes = list("вафлей" = 1, "грибов" = 1)
	foodtype = GRAIN | SUGAR | VEGETABLES

/obj/item/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Ммм, вафли."
	ru_names = list(
		NOMINATIVE = "вафли",
		GENITIVE = "вафель",
		DATIVE = "вафлям",
		ACCUSATIVE = "вафли",
		INSTRUMENTAL = "вафлями",
		PREPOSITIONAL = "вафлях"
	)
	icon_state = "waffles"
	trash = /obj/item/trash/waffles
	filling_color = "#E6DEB5"
	list_reagents = list("nutriment" = 8, "vitamin" = 1)
	foodtype = GRAIN | SUGAR


