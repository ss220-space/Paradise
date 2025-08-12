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


/obj/item/reagent_containers/food/drinks/protein
	name = "банка протеина"
	ru_names = list(
		NOMINATIVE = "банка протеина",
		GENITIVE = "банки протеина",
		DATIVE = "банке протеина",
		ACCUSATIVE = "банку протеина",
		INSTRUMENTAL = "банкой протеина",
		PREPOSITIONAL = "банке протеина",
	)
	desc = "Банка наполненная протеиновым порошком. Этот вид протеина был снят с производства. \
			Если вы встретили его, обратитесь к техподдержке."
	icon_state = "protein_zaza"
	item_state = "protein_zaza"
	volume = 80
	foodtype = GROSS
	list_reagents = list("protein" = 80)


/obj/item/reagent_containers/food/drinks/protein/zaza
	name = "банка протеина (Заза)"
	ru_names = list(
		NOMINATIVE = "банка протеина (Заза)",
		GENITIVE = "банки протеина (Заза)",
		DATIVE = "банке протеина (Заза)",
		ACCUSATIVE = "банку протеина (Заза)",
		INSTRUMENTAL = "банкой протеина (Заза)",
		PREPOSITIONAL = "банке протеина (Заза)",
	)
	desc = "Банка наполненная протеиновым порошком. \
			На самом деле не отличается от банки протеина со вкусом вишни ничем кроме изображения на этикетке."
	icon_state = "protein_zaza"
	item_state = "protein_zaza"
	list_reagents = list("protein" = 70, "zaza" = 10)


/obj/item/reagent_containers/food/drinks/protein/cherry
	name = "банка протеина (Вишня)"
	ru_names = list(
		NOMINATIVE = "банка протеина (Вишня)",
		GENITIVE = "банки протеина (Вишня)",
		DATIVE = "банке протеина (Вишня)",
		ACCUSATIVE = "банку протеина (Вишня)",
		INSTRUMENTAL = "банкой протеина (Вишня)",
		PREPOSITIONAL = "банке протеина (Вишня)",
	)
	desc = "Банка наполненная протеиновым порошком со вкусом вишни. \
			На самом деле не отличается от банки протеина со вкусом Зазы ничем кроме изображения на этикетке."
	icon_state = "protein_cherry"
	item_state = "protein_cherry"
	list_reagents = list("protein" = 70, "cherryshake" = 10)


/obj/item/reagent_containers/food/drinks/protein/chocolate
	name = "банка протеина (Шоколад)"
	ru_names = list(
		NOMINATIVE = "банка протеина (Шоколад)",
		GENITIVE = "банки протеина (Шоколад)",
		DATIVE = "банке протеина (Шоколад)",
		ACCUSATIVE = "банку протеина (Шоколад)",
		INSTRUMENTAL = "банкой протеина (Шоколад)",
		PREPOSITIONAL = "банке протеина (Шоколад)",
	)
	desc = "Банка наполненная протеиновым порошком со вкусом шоколада. \
			Единственный вкус протеинового порошка не вызывающий отвращения при потреблении в неразбавленном виде."
	icon_state = "protein_chocolate"
	item_state = "protein_chocolate"
	list_reagents = list("protein" = 70, "chocolate" = 10)
	foodtype = SUGAR


/obj/item/reagent_containers/food/drinks/protein/bananastrawberry
	name = "банка протеина (Банан и клубника)"
	ru_names = list(
		NOMINATIVE = "банка протеина (Банан и клубника)",
		GENITIVE = "банки протеина (Банан и клубника)",
		DATIVE = "банке протеина (Банан и клубника)",
		ACCUSATIVE = "банку протеина (Банан и клубника)",
		INSTRUMENTAL = "банкой протеина (Банан и клубника)",
		PREPOSITIONAL = "банке протеина (Банан и клубника)",
	)
	desc = "Банка наполненная протеиновым порошком со вкусом банана и клубники. \
			До ребрендинга вместо банана и клубники была просто клубника."
	icon_state = "protein_bananastrawberry"
	item_state = "protein_bananastrawberry"
	list_reagents = list("protein" = 70, "banana" = 5, "strawwberry" = 5)


/obj/item/reagent_containers/food/drinks/guarana
	name = "ампула экстракта гуараны"
	ru_names = list(
		NOMINATIVE = "ампула экстракта гуараны",
		GENITIVE = "ампулы экстракта гуараны",
		DATIVE = "ампуле экстракта гуараны",
		ACCUSATIVE = "ампулу экстракта гуараны",
		INSTRUMENTAL = "ампулой экстракта гуараны",
		PREPOSITIONAL = "ампуле экстракта гуараны",
	)
	desc = "Ампула содержащая экстракт гуараны – вещество стимулирующее мышечную активность. \
			На этикетке нарисована малина, не смотря на то, что в составе нет ничего связанного с ней."
	icon_state = "guarana_raspberry"
	item_state = "guarana_raspberry"
	list_reagents = list("guarana" = 10)


/obj/item/reagent_containers/food/drinks/creatine
	name = "бутылочка креатина"
	ru_names = list(
		NOMINATIVE = "бутылочка креатина",
		GENITIVE = "бутылочкы креатина",
		DATIVE = "бутылочке креатина",
		ACCUSATIVE = "бутылочку креатина",
		INSTRUMENTAL = "бутылочкой креатина",
		PREPOSITIONAL = "бутылочке креатина",
	)
	desc = "Бутылочка содержащая креатин – вещество повышающее скорость развития мышц. \
			На этикетке нарисована малина, не смотря на то, что в составе нет ничего связанного с ней."
	icon_state = "creatine"
	item_state = "creatine"
	list_reagents = list("creatine" = 10)
