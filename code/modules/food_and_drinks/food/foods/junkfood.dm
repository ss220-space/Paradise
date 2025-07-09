
//////////////////////
//		Vendor		//
//////////////////////

/obj/item/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "\"Что за хрустяшки\" команданта Райкера."
	ru_names = list(
		NOMINATIVE = "чипсы",
		GENITIVE = "чипсов",
		DATIVE = "чипсам",
		ACCUSATIVE = "чипсы",
		INSTRUMENTAL = "чипсами",
		PREPOSITIONAL = "чипсах"
	)
	icon_state = "chips"
	bitesize = 1
	trash = /obj/item/trash/chips
	filling_color = "#E8C31E"
	junkiness = 20
	antable = FALSE
	list_reagents = list("nutriment" = 1, "sodiumchloride" = 1, "sugar" = 2)
	tastes = list("чипсов" = 1)
	foodtype = JUNKFOOD | FRIED

/obj/item/reagent_containers/food/snacks/sosjerky
	name = "Scaredy's Private Reserve Beef Jerky"
	desc = "Вяленое мясо премиум-класса. Взято из личных запасов Джона Трейзена!"
	ru_names = list(
		NOMINATIVE = "вяленое мясо \"Стратегический Запас\"",
		GENITIVE = "вяленого мяса \"Стратегический Запас\"",
		DATIVE = "вяленому мясу \"Стратегический Запас\"",
		ACCUSATIVE = "вяленое мясо \"Стратегический Запас\"",
		INSTRUMENTAL = "вяленым мясом \"Стратегический Запас\"",
		PREPOSITIONAL = "вяленом мясе \"Стратегический Запас\""
	)
	icon_state = "sosjerky"
	trash = /obj/item/trash/sosjerky
	filling_color = "#631212"
	junkiness = 25
	antable = FALSE
	list_reagents = list("protein" = 1, "sugar" = 3)
	tastes = list("вяленой говядины" = 1)
	foodtype = JUNKFOOD | MEAT

/obj/item/reagent_containers/food/snacks/pistachios
	name = "pistachios"
	desc = "Восхитительно солёные фисташки. Вполне достойный выбор..."
	ru_names = list(
		NOMINATIVE = "фисташки",
		GENITIVE = "фисташек",
		DATIVE = "фисташкам",
		ACCUSATIVE = "фисташки",
		INSTRUMENTAL = "фисташками",
		PREPOSITIONAL = "фисташках"
	)
	icon_state = "pistachios"
	trash = /obj/item/trash/pistachios
	filling_color = "#BAD145"
	junkiness = 20
	antable = FALSE
	list_reagents = list("plantmatter" = 2, "sodiumchloride" = 1, "sugar" = 2)
	tastes = list("фисташек" = 1)
	foodtype = JUNKFOOD

/obj/item/reagent_containers/food/snacks/no_raisin
	name = "1984 Raisins"
	desc = "Лучший изюм во времени и пространстве. Непонятно, почему."
	ru_names = list(
		NOMINATIVE = "изюм \"1984\"",
		GENITIVE = "изюма \"1984\"",
		DATIVE = "изюму \"1984\"",
		ACCUSATIVE = "изюм \"1984\"",
		INSTRUMENTAL = "изюмом \"1984\"",
		PREPOSITIONAL = "изюме \"1984\""
	)
	icon_state = "1984_raisins"
	trash = /obj/item/trash/raisins
	filling_color = "#343834"
	junkiness = 25
	antable = FALSE
	list_reagents = list("plantmatter" = 2, "sugar" = 2)
	tastes = list("сушеного изюма" = 1)
	foodtype = JUNKFOOD | FRUIT

/obj/item/reagent_containers/food/snacks/spacetwinkie
	name = "Space Twinkie"
	desc = "Гарантированно переживёт своего владельца."
	ru_names = list(
		NOMINATIVE = "космический Твинки",
		GENITIVE = "космического Твинки",
		DATIVE = "космическому Твинки",
		ACCUSATIVE = "космический Твинки",
		INSTRUMENTAL = "космическим Твинки",
		PREPOSITIONAL = "космическом Твинки"
	)
	icon_state = "space_twinkie"
	trash = /obj/item/trash/spacetwinkie
	filling_color = "#FFE591"
	junkiness = 25
	list_reagents = list("sugar" = 4)
	tastes = list("twinkies" = 1)
	foodtype = JUNKFOOD | SUGAR

/obj/item/reagent_containers/food/snacks/cheesiehonkers
	name = "Cheesie Honkers"
	desc = "Сырные закуски на один укус, которые устроят хонкинг во рту."
	ru_names = list(
		NOMINATIVE = "сырные хонкерсы",
		GENITIVE = "сырных хонкерсов",
		DATIVE = "сырным хонкерсам",
		ACCUSATIVE = "сырные хонкерсы",
		INSTRUMENTAL = "сырными хонкерсами",
		PREPOSITIONAL = "сырных хонкерсах"
	)
	icon_state = "cheesie_honkers"
	trash = /obj/item/trash/cheesie
	filling_color = "#FFA305"
	junkiness = 25
	antable = FALSE
	list_reagents = list("nutriment" = 1, "fake_cheese" = 2, "sugar" = 3)
	tastes = list("сыра" = 1, "чипсов" = 2)
	foodtype = JUNKFOOD | DAIRY

/obj/item/reagent_containers/food/snacks/syndicake
	name = "Syndi-Cakes"
	desc = "Невероятно сочные пирожные, которые так же вкусны после ядерного взрыва."
	ru_names = list(
		NOMINATIVE = "синдикейк",
		GENITIVE = "синдикейка",
		DATIVE = "синдикейку",
		ACCUSATIVE = "синдикейк",
		INSTRUMENTAL = "синдикейком",
		PREPOSITIONAL = "синдикейке"
	)
	icon_state = "syndi_cakes"
	filling_color = "#FF5D05"
	trash = /obj/item/trash/syndi_cakes
	bitesize = 3
	antable = FALSE
	list_reagents = list("nutriment" = 4, "salglu_solution" = 5)
	tastes = list("сладостей" = 3, "пирога" = 1)
	foodtype = JUNKFOOD

/obj/item/reagent_containers/food/snacks/tastybread
	name = "bread tube"
	desc = "Хлеб в хлебной трубочке. Жевательный и на удивление вкусный."
	ru_names = list(
		NOMINATIVE = "хлебная трубочка",
		GENITIVE = "хлебной трубочки",
		DATIVE = "хлебной трубочке",
		ACCUSATIVE = "хлебную трубочку",
		INSTRUMENTAL = "хлебной трубочкой",
		PREPOSITIONAL = "хлебной трубочке"
	)
	icon_state = "tastybread"
	trash = /obj/item/trash/tastybread
	filling_color = "#A66829"
	junkiness = 20
	antable = FALSE
	list_reagents = list("protein" = 2, "sugar" = 2)
	tastes = list("хлеба" = 1)
	foodtype = JUNKFOOD | GRAIN

/obj/item/reagent_containers/food/snacks/doshik
	name = "Doshi Co"
	desc = "Легендарная лапша быстрого приготовления. Заваривается мгновенно после вскрытия. Вау!"
	ru_names = list(
		NOMINATIVE = "Доши Ко",
		GENITIVE = "Доши Ко",
		DATIVE = "Доши Ко",
		ACCUSATIVE = "Доши Ко",
		INSTRUMENTAL = "Доши Ко",
		PREPOSITIONAL = "Доши Ко"
	)
	icon_state = "doshik"
	trash = /obj/item/trash/doshik
	filling_color = "#d1a62f"
	junkiness = 20
	list_reagents = list("protein" = 3)
	tastes = list("Доши Ко" = 1, "удовольствия" = 1)
	foodtype = JUNKFOOD | MEAT
	opened = FALSE

/obj/item/reagent_containers/food/snacks/doshik_spicy
	name = "Doshi Co Special"
	desc = "Легендарная лапша быстрого приготовления. Заваривается мгновенно после вскрытия. Вау! Судя по всему, тут острые специи!"
	ru_names = list(
		NOMINATIVE = "Доши Ко Спешла",
		GENITIVE = "Доши Ко Спешл",
		DATIVE = "Доши Ко Спешл",
		ACCUSATIVE = "Доши Ко Спешл",
		INSTRUMENTAL = "Доши Ко Спешл",
		PREPOSITIONAL = "Доши Ко Спешл"
	)
	icon_state = "doshikspicy"
	trash = /obj/item/trash/doshik
	filling_color = "#d16a2f"
	junkiness = 20
	list_reagents = list("protein" = 3, "capsaicin" = 5)
	tastes = list("Доши Ко" = 1, "боли" = 1, "удовольствия" = 1)
	foodtype = JUNKFOOD | MEAT
	opened = FALSE

//////////////////////
//		Homemade	//
//////////////////////

/obj/item/reagent_containers/food/snacks/sosjerky/healthy
	name = "homemade beef jerky"
	desc = "Домашнее вяленое мясо из лучших космических коров."
	ru_names = list(
		NOMINATIVE = "домашняя говядина",
		GENITIVE = "домашней говядины",
		DATIVE = "домашней говядине",
		ACCUSATIVE = "домашнюю говядину",
		INSTRUMENTAL = "домашней говядиной",
		PREPOSITIONAL = "домашней говядине"
	)
	list_reagents = list("nutriment" = 3, "vitamin" = 1)
	junkiness = 0
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/no_raisin/healthy
	name = "homemade raisins"
	desc = "Домашний изюм, лучший во всём космосе."
	ru_names = list(
		NOMINATIVE = "домашний изюм",
		GENITIVE = "домашнего изюма",
		DATIVE = "домашнему изюму",
		ACCUSATIVE = "домашний изюм",
		INSTRUMENTAL = "домашним изюмом",
		PREPOSITIONAL = "домашнем изюме"
	)
	list_reagents = list("nutriment" = 3, "vitamin" = 2)
	junkiness = 0
	foodtype = FRUIT

//////////////////////
//		Other		//
//////////////////////

/obj/item/reagent_containers/food/snacks/proteinbar_banana
	name = "протеиновый батончик \"Банановый рай\""
	ru_names = list(
		NOMINATIVE = "протеиновый батончик \"Банановый рай\"",
		GENITIVE = "протеинового батончика \"Банановый рай\"",
		DATIVE = "протеиновому батончику \"Банановый рай\"",
		ACCUSATIVE = "протеиновый батончик \"Банановый рай\"",
		INSTRUMENTAL = "протеиновым батончиком \"Банановый рай\"",
		PREPOSITIONAL = "протеиновом батончике \"Банановый рай\"",
	)
	desc = "Специализированный пищевой продукт с высоким содержанием белка. \
			Разработан филиалом Donk Co расположенным на планете клоунов."
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "proteinbar_bananza"
	filling_color = "#d1a62f"
	junkiness = 5
	list_reagents = list("protein" = 10, "banana" = 5, "sugar" = 3)
	tastes = list("банана" = 1, "удовольствия" = 1)
	foodtype = JUNKFOOD
	opened = FALSE


/obj/item/reagent_containers/food/snacks/proteinbar_cherry
	name = "протеиновый батончик \"Вишнёвая слаймодевочка\""
	ru_names = list(
		NOMINATIVE = "протеиновый батончик \"Вишнёвая слаймодевочка\"",
		GENITIVE = "протеинового батончика \"Вишнёвая слаймодевочка\"",
		DATIVE = "протеиновому батончику \"Вишнёвая слаймодевочка\"",
		ACCUSATIVE = "протеиновый батончик \"Вишнёвая слаймодевочка\"",
		INSTRUMENTAL = "протеиновым батончиком \"Вишнёвая слаймодевочка\"",
		PREPOSITIONAL = "протеиновом батончике \"Вишнёвая слаймодевочка\"",
	)
	desc = "Специализированный пищевой продукт с высоким содержанием белка. \
			Долгое время существовал миф, будто в его состав входит слизь одной известной слаймолюдки."
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "proteinbar_cherry"
	filling_color = "#d1a62f"
	junkiness = 5
	list_reagents = list("protein" = 10, "cherryjelly" = 5, "sugar" = 3, "slimejelly" = 1)
	tastes = list("вишни" = 1, "удовольствия" = 1)
	foodtype = JUNKFOOD
	opened = FALSE


/obj/item/reagent_containers/food/snacks/proteinbar_beef
	name = "протеиновый батончик \"Наследие Бурёнки\""
	ru_names = list(
		NOMINATIVE = "протеиновый батончик \"Наследие Бурёнки\"",
		GENITIVE = "протеинового батончика \"Наследие Бурёнки\"",
		DATIVE = "протеиновому батончику \"Наследие Бурёнки\"",
		ACCUSATIVE = "протеиновый батончик \"Наследие Бурёнки\"",
		INSTRUMENTAL = "протеиновым батончиком \"Наследие Бурёнки\"",
		PREPOSITIONAL = "протеиновом батончике \"Наследие Бурёнки\"",
	)
	desc = "Специализированный пищевой продукт с высоким содержанием белка. \
			Во время производства ни одна корова не пострадала."
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "proteinbar_beef"
	filling_color = "#d1a62f"
	junkiness = 5
	list_reagents = list("protein" = 12)
	tastes = list("говядины" = 1, "удовольствия" = 1)
	foodtype = JUNKFOOD
	opened = FALSE
