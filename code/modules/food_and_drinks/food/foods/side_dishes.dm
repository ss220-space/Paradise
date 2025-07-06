
//////////////////////
//		Raw			//
//////////////////////

/obj/item/reagent_containers/food/snacks/rawsticks
	name = "raw potato sticks"
	desc = "Сырой картофель фри, не очень вкусно."
	ru_names = list(
		NOMINATIVE = "сырая картошка соломкой",
		GENITIVE = "сырой картошки соломкой",
		DATIVE = "сырой картошке соломкой",
		ACCUSATIVE = "сырую картошку соломкой",
		INSTRUMENTAL = "сырой картошкой соломкой",
		PREPOSITIONAL = "сырой картошке соломкой"
	)
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "rawsticks"
	list_reagents = list("plantmatter" = 3)
	tastes = list("сырой картошки" = 1)
	foodtype = VEGETABLES | RAW | GROSS


//////////////////////
//		Fried		//
//////////////////////

/obj/item/reagent_containers/food/snacks/fries
	name = "space fries"
	desc = "Также известен как: картофель фри, картошка свободы и т.д."
	ru_names = list(
		NOMINATIVE = "космический картофель фри",
		GENITIVE = "космического картофеля фри",
		DATIVE = "космическому картофелю фри",
		ACCUSATIVE = "космический картофель фри",
		INSTRUMENTAL = "космическим картофелем фри",
		PREPOSITIONAL = "космическом картофеле фри"
	)
	icon_state = "fries"
	trash = /obj/item/trash/plate
	filling_color = "#EDDD00"
	list_reagents = list("nutriment" = 4)
	tastes = list("картошки фри" = 3, "соли" = 1)
	foodtype = VEGETABLES | FRIED

/obj/item/reagent_containers/food/snacks/cheesyfries
	name = "cheesy fries"
	desc = "Картошка фри. Покрытая сыром. Ну очевидно же."
	ru_names = list(
		NOMINATIVE = "картофель фри с сыром",
		GENITIVE = "картофеля фри с сыром",
		DATIVE = "картофелю фри с сыром",
		ACCUSATIVE = "картофель фри с сыром",
		INSTRUMENTAL = "картофелем фри с сыром",
		PREPOSITIONAL = "картофеле фри с сыром"
	)
	icon_state = "cheesyfries"
	trash = /obj/item/trash/plate
	filling_color = "#EDDD00"
	list_reagents = list("nutriment" = 6)
	tastes = list("картошки фри" = 3, "сыра" = 1)
	foodtype = VEGETABLES | FRIED | DAIRY

/obj/item/reagent_containers/food/snacks/tatortot
	name = "tator tot"
	desc = "Большая жареная картофельная котлетка. Если много съесть – может завалить вас спать."
	ru_names = list(
		NOMINATIVE = "картофельный наггетс",
		GENITIVE = "картофельного наггетса",
		DATIVE = "картофельному наггетсу",
		ACCUSATIVE = "картофельный наггетс",
		INSTRUMENTAL = "картофельным наггетсом",
		PREPOSITIONAL = "картофельном наггетсе"
	)
	icon_state = "tatortot"
	list_reagents = list("nutriment" = 4)
	filling_color = "FFD700"
	tastes = list("жареной картошки" = 3, "истины" = 1)
	foodtype = VEGETABLES | FRIED

/obj/item/reagent_containers/food/snacks/onionrings
	name = "onion rings"
	desc = "Кольца лука в кляре."
	ru_names = list(
		NOMINATIVE = "луковые кольца",
		GENITIVE = "луковых колец",
		DATIVE = "луковым кольцам",
		ACCUSATIVE = "луковые кольца",
		INSTRUMENTAL = "луковыми кольцами",
		PREPOSITIONAL = "луковых кольцах"
	)
	icon_state = "onionrings"
	list_reagents = list("nutriment" = 3)
	filling_color = "#C0C9A0"
	gender = PLURAL
	tastes = list("лука" = 3, "кляра" = 1)
	foodtype = VEGETABLES | FRIED

/obj/item/reagent_containers/food/snacks/carrotfries
	name = "carrot fries"
	desc = "Вкусная жареная морковка соломкой."
	ru_names = list(
		NOMINATIVE = "морковка фри",
		GENITIVE = "морковки фри",
		DATIVE = "морковке фри",
		ACCUSATIVE = "морковку фри",
		INSTRUMENTAL = "морковкой фри",
		PREPOSITIONAL = "морковке фри"
	)
	icon_state = "carrotfries"
	trash = /obj/item/trash/plate
	filling_color = "#FAA005"
	list_reagents = list("plantmatter" = 3, "oculine" = 3, "vitamin" = 2)
	tastes = list("морковки" = 3, "соли" = 1)
	foodtype = VEGETABLES | FRIED


//////////////////////
//		Misc		//
//////////////////////

/obj/item/reagent_containers/food/snacks/beans
	name = "tin of beans"
	desc = "Музыкальные фрукты в менее музыкальной упаковке."
	ru_names = list(
		NOMINATIVE = "банка бобов",
		GENITIVE = "банки бобов",
		DATIVE = "банке бобов",
		ACCUSATIVE = "банку бобов",
		INSTRUMENTAL = "банкой бобов",
		PREPOSITIONAL = "банке бобов"
	)
	icon_state = "beans"
	list_reagents = list("nutriment" = 10, "beans" = 10, "vitamin" = 3)
	tastes = list("зёрен" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/mashed_potatoes //mashed taters
	name = "mashed potatoes"
	desc = "Мягкое, кремовое и непреодолимо вкусное картофельное пюре."
	ru_names = list(
		NOMINATIVE = "картофельное пюре",
		GENITIVE = "картофельного пюре",
		DATIVE = "картофельному пюре",
		ACCUSATIVE = "картофельное пюре",
		INSTRUMENTAL = "картофельным пюре",
		PREPOSITIONAL = "картофельном пюре"
	)
	icon_state = "mashedtaters"
	trash = /obj/item/trash/plate
	filling_color = "#D6D9C1"
	list_reagents = list("nutriment" = 5, "gravy" = 5, "mashedpotatoes" = 10, "vitamin" = 2)
	tastes = list("картофельного пюре" = 3, "подливки" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/stuffing
	name = "stuffing"
	desc = "Влажные пряные сухарики для начинки птичьих тушек. Приятного аппетита!"
	ru_names = list(
		NOMINATIVE = "хлебная начинка",
		GENITIVE = "хлебной начинки",
		DATIVE = "хлебной начинке",
		ACCUSATIVE = "хлебную начинку",
		INSTRUMENTAL = "хлебной начинкой",
		PREPOSITIONAL = "хлебной начинке"
	)
	icon_state = "stuffing"
	filling_color = "#C9AC83"
	list_reagents = list("nutriment" = 3)
	tastes = list("хлебных крошек" = 1, "зелени" = 1)
	foodtype = VEGETABLES | GRAIN

/obj/item/reagent_containers/food/snacks/loadedbakedpotato
	name = "loaded baked potato"
	desc = "Полностью запечённая."
	ru_names = list(
		NOMINATIVE = "фаршированная печёная картошка",
		GENITIVE = "фаршированной печёной картошки",
		DATIVE = "фаршированной печёной картошке",
		ACCUSATIVE = "фаршированную печёную картошку",
		INSTRUMENTAL = "фаршированной печёной картошкой",
		PREPOSITIONAL = "фаршированной печёной картошке"
	)
	icon_state = "loadedbakedpotato"
	filling_color = "#9C7A68"
	list_reagents = list("nutriment" = 6)
	tastes = list("картошки" = 1, "сыра" = 1, "зелени" = 1)
	foodtype = VEGETABLES | DAIRY

/obj/item/reagent_containers/food/snacks/boiledrice
	name = "boiled rice"
	desc = "Скучное блюдо из скучного риса."
	ru_names = list(
		NOMINATIVE = "варёный рис",
		GENITIVE = "варёного риса",
		DATIVE = "варёному рису",
		ACCUSATIVE = "варёный рис",
		INSTRUMENTAL = "варёным рисом",
		PREPOSITIONAL = "варёном рисе"
	)
	icon_state = "boiledrice"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#FFFBDB"
	list_reagents = list("nutriment" = 5, "vitamin" = 1)
	tastes = list("риса" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/roastparsnip
	name = "roast parsnip"
	desc = "Сладкий и хрустящий."
	ru_names = list(
		NOMINATIVE = "жареный пастернак",
		GENITIVE = "жареного пастернака",
		DATIVE = "жареному пастернаку",
		ACCUSATIVE = "жареный пастернак",
		INSTRUMENTAL = "жареным пастернаком",
		PREPOSITIONAL = "жареном пастернаке"
	)
	icon_state = "roastparsnip"
	trash = /obj/item/trash/plate
	list_reagents = list("nutriment" = 3, "vitamin" = 4)
	filling_color = "#FF5500"
	tastes = list("пастернака" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/plov
	name = "Plov"
	desc = "Смесь риса и овощей."
	ru_names = list(
		NOMINATIVE = "плов",
		GENITIVE = "плова",
		DATIVE = "плову",
		ACCUSATIVE = "плов",
		INSTRUMENTAL = "пловом",
		PREPOSITIONAL = "плове"
	)
	icon_state = "plov"
	trash = /obj/item/trash/plate
	list_reagents = list("nutriment" = 6, "protein" = 6, "plantmatter" = 6)
	tastes = list("вареного риса"= 1, "сырой котлеты" = 1, "лука" = 1)
	foodtype = VEGETABLES | MEAT | GRAIN
