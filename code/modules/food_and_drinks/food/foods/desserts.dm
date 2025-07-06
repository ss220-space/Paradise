
//////////////////////
//	Ice Cream		//
//////////////////////

/obj/item/reagent_containers/food/snacks/icecream
	name = "ice cream"
	desc = "Вкусное мороженое."
	ru_names = list(
		NOMINATIVE = "мороженое",
		GENITIVE = "мороженого",
		DATIVE = "мороженому",
		ACCUSATIVE = "мороженое",
		INSTRUMENTAL = "мороженым",
		PREPOSITIONAL = "мороженом"
	)
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_cone"
	bitesize = 3
	list_reagents = list("nutriment" = 1, "sugar" = 3)
	tastes = list("мороженого" = 1)
	foodtype = SUGAR | DAIRY

/obj/item/reagent_containers/food/snacks/icecream/update_overlays()
	. = ..()
	. += mutable_appearance('icons/obj/kitchen.dmi', "icecream_color", color = mix_color_from_reagents(reagents.reagent_list))

/obj/item/reagent_containers/food/snacks/icecream/icecreamcone
	name = "ice cream cone"
	desc = "Вкусное мороженое в вафельном рожке."
	ru_names = list(
		NOMINATIVE = "рожок мороженого",
		GENITIVE = "рожка мороженого",
		DATIVE = "рожку мороженого",
		ACCUSATIVE = "рожок мороженого",
		INSTRUMENTAL = "рожком мороженого",
		PREPOSITIONAL = "рожке мороженого"
	)
	icon_state = "icecream_cone"
	volume = 50
	bitesize = 3
	list_reagents = list("nutriment" = 3, "sugar" = 7, "ice" = 2)

/obj/item/reagent_containers/food/snacks/icecream/icecreamcup
	name = "chocolate ice cream cone"
	desc = "Вкусное шоколадное мороженое."
	ru_names = list(
		NOMINATIVE = "шоколадное мороженое",
		GENITIVE = "шоколадного мороженого",
		DATIVE = "шоколадному мороженому",
		ACCUSATIVE = "шоколадное мороженое",
		INSTRUMENTAL = "шоколадным мороженым",
		PREPOSITIONAL = "шоколадном мороженом"
	)
	icon_state = "icecream_cup"
	volume = 50
	bitesize = 6
	list_reagents = list("nutriment" = 5, "chocolate" = 8, "ice" = 2)

/obj/item/reagent_containers/food/snacks/icecreamsandwich
	name = "icecream sandwich"
	desc = "Вкусное мороженое с печеньем."
	ru_names = list(
		NOMINATIVE = "мороженое-сэндвич",
		GENITIVE = "мороженого-сэндвича",
		DATIVE = "мороженому-сэндвичу",
		ACCUSATIVE = "мороженое-сэндвич",
		INSTRUMENTAL = "мороженым-сэндвичем",
		PREPOSITIONAL = "мороженом-сэндвиче"
	)
	icon_state = "icecreamsandwich"
	list_reagents = list("nutriment" = 2, "ice" = 2)
	foodtype = SUGAR | DAIRY


//////////////////////
//		Misc		//
//////////////////////

/obj/item/reagent_containers/food/snacks/friedbanana
	name = "fried banana"
	desc = "Господи, они поджарили банан! Как вкусно!"
	ru_names = list(
		NOMINATIVE = "жареный банан",
		GENITIVE = "жареного банана",
		DATIVE = "жареному банану",
		ACCUSATIVE = "жареный банан",
		INSTRUMENTAL = "жареным бананом",
		PREPOSITIONAL = "жареном банане"
	)
	icon_state = "friedbanana"
	list_reagents = list("sugar" = 10, "nutriment" = 8, "cornoil" = 4)
	foodtype = FRIED | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/ricepudding
	name = "rice pudding"
	desc = "Но где же варенье?!"
	ru_names = list(
		NOMINATIVE = "рисовый пудинг",
		GENITIVE = "рисового пудинга",
		DATIVE = "рисовому пудингу",
		ACCUSATIVE = "рисовый пудинг",
		INSTRUMENTAL = "рисовым пудингом",
		PREPOSITIONAL = "рисовом пудинге"
	)
	icon_state = "rpudding"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#FFFBDB"
	list_reagents = list("nutriment" = 7, "vitamin" = 2)
	tastes = list("риса" = 1, "сахара" = 1)
	foodtype = GRAIN | SUGAR

/obj/item/reagent_containers/food/snacks/spacylibertyduff
	name = "spacy liberty duff"
	desc = "Желейный десерт из кулинарной книги Альфреда Хаббарда."
	ru_names = list(
		NOMINATIVE = "космо-желе",
		GENITIVE = "космо-желе",
		DATIVE = "космо-желе",
		ACCUSATIVE = "космо-желе",
		INSTRUMENTAL = "космо-желе",
		PREPOSITIONAL = "космо-желе"
	)
	icon_state = "spacylibertyduff"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#42B873"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "psilocybin" = 6)
	tastes = list("желе" = 1, "грибов" = 1)
	foodtype = FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/amanitajelly
	name = "amanita jelly"
	desc = "Выглядит подозрительно токсично."
	ru_names = list(
		NOMINATIVE = "желе из мухоморов",
		GENITIVE = "желе из мухоморов",
		DATIVE = "желе из мухоморов",
		ACCUSATIVE = "желе из мухоморов",
		INSTRUMENTAL = "желе из мухоморов",
		PREPOSITIONAL = "желе из мухоморов"
	)
	icon_state = "amanitajelly"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#ED0758"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "amanitin" = 6, "psilocybin" = 3)
	tastes = list("желе" = 1, "грибов" = 1)
	foodtype = VEGETABLES | SUGAR
	log_eating = TRUE

/obj/item/reagent_containers/food/snacks/candiedapple
	name = "candied apple"
	desc = "Яблоко, покрытое сахарной карамелью."
	ru_names = list(
		NOMINATIVE = "яблоко в карамели",
		GENITIVE = "яблока в карамели",
		DATIVE = "яблоку в карамели",
		ACCUSATIVE = "яблоко в карамели",
		INSTRUMENTAL = "яблоком в карамели",
		PREPOSITIONAL = "яблоке в карамели"
	)
	icon_state = "candiedapple"
	filling_color = "#F21873"
	bitesize = 3
	list_reagents = list("nutriment" = 3, "sugar" = 5)
	tastes = list("яблока" = 2, "сахара" = 2)
	foodtype = FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/mint
	name = "mint"
	desc = "Она тонкая, как вафля."
	ru_names = list(
		NOMINATIVE = "мятная конфета",
		GENITIVE = "мятной конфеты",
		DATIVE = "мятной конфете",
		ACCUSATIVE = "мятную конфету",
		INSTRUMENTAL = "мятной конфетой",
		PREPOSITIONAL = "мятной конфете"
	)
	icon_state = "mint"
	bitesize = 1
	filling_color = "#F2F2F2"
	list_reagents = list("minttoxin" = 1)
