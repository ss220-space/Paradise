
//////////////////////
//		Breads		//
//////////////////////

/obj/item/reagent_containers/food/snacks/sliceable/bread/meat
	name = "meatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "meatbread"
	slice_path = /obj/item/reagent_containers/food/snacks/meatbreadslice
	slices_num = 5
	filling_color = "#FF7575"
	list_reagents = list("protein" = 20, "nutriment" = 10, "vitamin" = 5)
	tastes = list("bread" = 10, "meat" = 10)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/meatbreadslice
	name = "meatbread slice"
	desc = "A slice of delicious meatbread."
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "meatbreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#FF7575"
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/sliceable/bread/xeno
	name = "xenomeatbread loaf"
	desc = "The culinary base of every self-respecting eloquent gentleman. Extra Heretical."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "xenomeatbread"
	slice_path = /obj/item/reagent_containers/food/snacks/xenomeatbreadslice
	slices_num = 5
	filling_color = "#8AFF75"
	list_reagents = list("protein" = 20, "nutriment" = 10, "vitamin" = 5)
	tastes = list("bread" = 10, "acid" = 10)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/xenomeatbreadslice
	name = "xenomeatbread slice"
	desc = "A slice of delicious meatbread. Extra Heretical."
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "xenobreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#8AFF75"
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/sliceable/bread/spider
	name = "spider meat loaf"
	desc = "Reassuringly green meatloaf made from spider meat."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "spidermeatbread"
	slice_path = /obj/item/reagent_containers/food/snacks/spidermeatbreadslice
	slices_num = 5
	list_reagents = list("protein" = 20, "nutriment" = 10, "toxin" = 15, "vitamin" = 5)
	tastes = list("bread" = 10, "cobwebs" = 5)
	foodtype = GRAIN | MEAT | TOXIC

/obj/item/reagent_containers/food/snacks/spidermeatbreadslice
	name = "spider meat bread slice"
	desc = "A slice of meatloaf made from an animal that most likely still wants you dead."
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "xenobreadslice"
	trash = /obj/item/trash/plate
	list_reagents = list("toxin" = 2)
	foodtype = GRAIN | MEAT | TOXIC

/obj/item/reagent_containers/food/snacks/sliceable/bread/banana
	name = "banana-nut bread"
	desc = "A heavenly and filling treat."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "bananabread"
	slice_path = /obj/item/reagent_containers/food/snacks/bananabreadslice
	slices_num = 5
	filling_color = "#EDE5AD"
	list_reagents = list("banana" = 20, "nutriment" = 20)
	tastes = list("bread" = 10)
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/bananabreadslice
	name = "banana-nut bread slice"
	desc = "A slice of delicious banana bread."
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "bananabreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#EDE5AD"
	tastes = list("bread" = 10)
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/sliceable/bread/tofu
	name = "tofubread"
	icon_state = "Like meatbread but for vegetarians. Not guaranteed to give superpowers."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "tofubread"
	slice_path = /obj/item/reagent_containers/food/snacks/tofubreadslice
	slices_num = 5
	filling_color = "#F7FFE0"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("bread" = 10, "tofu" = 10)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/tofubreadslice
	name = "tofubread slice"
	desc = "A slice of delicious tofubread."
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "tofubreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#F7FFE0"
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/sliceable/bread
	name = "bread"
	desc =  "Some plain old Earthen bread."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "bread"
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice
	slices_num = 6
	filling_color = "#FFE396"
	list_reagents = list("nutriment" = 10)
	tastes = list("bread" = 10)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/sliceable/bread/on_teleported()
	if(length(GLOB.bread_monsters) < GLOB.bread_monsters_maxcap)
		new /mob/living/simple_animal/hostile/bread_monster(get_turf(src))
		qdel(src)
	return

/obj/item/reagent_containers/food/snacks/breadslice
	name = "bread slice"
	desc = "A slice of home."
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "breadslice"
	trash = /obj/item/trash/plate
	filling_color = "#D27332"
	list_reagents = list("nutriment" = 2, "bread" = 5)
	tastes = list("bread" = 10)
	foodtype = GRAIN


/obj/item/reagent_containers/food/snacks/breadslice/stale
	name = "stale bread"
	desc = "Похоже, ваши похитители позаботились о вашем питании."
	gender = MALE
	trash = null
	list_reagents = list("nutriment" = 7, "bread" = 5)

/obj/item/reagent_containers/food/snacks/breadslice/stale/get_ru_names()
	return list(
		NOMINATIVE = "чёрствый хлеб",
		GENITIVE = "чёрствого хлеба",
		DATIVE = "чёрствому хлебу",
		ACCUSATIVE = "чёрствый хлеб",
		INSTRUMENTAL = "чёрствым хлебом",
		PREPOSITIONAL = "чёрством хлебе"
	)

/obj/item/reagent_containers/food/snacks/breadslice/moldy
	name = "moldy bread"
	gender = MALE
	trash = null
	list_reagents = list("nutriment" = 2, "bread" = 5, "fungus" = 1)

/obj/item/reagent_containers/food/snacks/breadslice/moldy/get_ru_names()
	return list(
			NOMINATIVE = "заплесневелый хлеб",
			GENITIVE = "заплесневелого хлеба",
			DATIVE = "заплесневелому хлебу",
			ACCUSATIVE = "заплесневелый хлеб",
			INSTRUMENTAL = "заплесневелым хлебом",
			PREPOSITIONAL = "заплесневелом хлебе"
		)

/obj/item/reagent_containers/food/snacks/breadslice/burned
	name = "burned bread slice"
	desc = "A slice of slightly burned bread. Probably it's not the best idea to eat this..."
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "breadslice"
	trash = /obj/item/trash/plate
	filling_color = "#D27332"
	list_reagents = list("nutriment" = 2, "bread" = 5, "????" = 2)
	tastes = list("bread" = 10)
	foodtype = GRAIN | TOXIC

/obj/item/reagent_containers/food/snacks/sliceable/creamcheesebread
	name = "cream cheese bread"
	desc = "Yum yum yum!"
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "creamcheesebread"
	slice_path = /obj/item/reagent_containers/food/snacks/creamcheesebreadslice
	slices_num = 5
	filling_color = "#FFF896"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("bread" = 10, "cheese" = 10)
	foodtype = GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/creamcheesebreadslice
	name = "cream cheese bread slice"
	desc = "A slice of yum!"
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "creamcheesebreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#FFF896"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("bread" = 10, "cheese" = 10)
	foodtype = GRAIN | DAIRY


//////////////////////
//		Misc		//
//////////////////////

/obj/item/reagent_containers/food/snacks/bun
	name = "bun"
	desc = "The base for any self-respecting burger."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "bun"
	list_reagents = list("nutriment" = 1)
	tastes = list("bun" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/bunbun
	name = "Bun Bun"
	desc = "A small bread monkey fashioned from two burger buns."
	icon_state = "bunbun"
	list_reagents = list("nutriment" = 2)
	tastes = list("bun" = 2)
	bitesize = 2
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/flatbread
	name = "flatbread"
	desc = "Bland but filling."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "flatbread"
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bread" = 2)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/baguette
	name = "baguette"
	desc = "Bon appetit!"
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "baguette"
	item_state = "baguette"
	filling_color = "#E3D796"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bread" = 2)
	foodtype = GRAIN
	slot_flags = ITEM_SLOT_BELT

/obj/item/reagent_containers/food/snacks/baguette/get_ru_names()
	return list(
		NOMINATIVE = "багет",
		GENITIVE = "багета",
		DATIVE = "багету",
		ACCUSATIVE = "багет",
		INSTRUMENTAL = "багетом",
		PREPOSITIONAL = "багете"
	)

/obj/item/reagent_containers/food/snacks/baguette/combat
	sharp = TRUE
	force = 20
	block_chance = 40

/obj/item/reagent_containers/food/snacks/twobread
	name = "two bread"
	desc = "It is very bitter and winy."
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "twobread"
	filling_color = "#DBCC9A"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "vitamin" = 2)
	tastes = list("bread" = 2)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/toast
	name = "toast"
	desc = "Yeah! Toast!"
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "toast"
	filling_color = "#B2580E"
	bitesize = 3
	list_reagents = list("nutriment" = 3)
	tastes = list("toast" = 2)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/jelliedtoast
	name = "jellied toast"
	desc = "A slice of bread covered with delicious jam."
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "jellytoast"
	trash = /obj/item/trash/plate
	filling_color = "#B572AB"
	bitesize = 3
	tastes = list("toast" = 1, "jelly" = 1)
	foodtype = GRAIN | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/jelliedtoast/cherry
	list_reagents = list("nutriment" = 1, "cherryjelly" = 5, "vitamin" = 2)

/obj/item/reagent_containers/food/snacks/jelliedtoast/slime
	list_reagents = list("nutriment" = 1, "slimejelly" = 5, "vitamin" = 2)

/obj/item/reagent_containers/food/snacks/rofflewaffles
	name = "roffle waffles"
	desc = "Waffles from Roffle. Co."
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles
	filling_color = "#FF00F7"
	bitesize = 4
	list_reagents = list("nutriment" = 8, "psilocybin" = 2, "vitamin" = 2)
	tastes = list("waffle" = 1, "mushrooms" = 1)
	foodtype = GRAIN | SUGAR | VEGETABLES

/obj/item/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Mmm, waffles."
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "waffles"
	trash = /obj/item/trash/waffles
	filling_color = "#E6DEB5"
	list_reagents = list("nutriment" = 8, "vitamin" = 1)
	foodtype = GRAIN | SUGAR


