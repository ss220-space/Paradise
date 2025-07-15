
//////////////////////
//		Vendor		//
//////////////////////

/obj/item/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps."
	icon_state = "chips"
	bitesize = 1
	trash = /obj/item/trash/chips
	filling_color = "#E8C31E"
	junkiness = 20
	antable = FALSE
	list_reagents = list("nutriment" = 1, "sodiumchloride" = 1, "sugar" = 2)
	tastes = list("crisps" = 1)
	foodtype = JUNKFOOD | FRIED

/obj/item/reagent_containers/food/snacks/sosjerky
	name = "Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"
	desc = "Beef jerky made from the finest space cows."
	trash = /obj/item/trash/sosjerky
	filling_color = "#631212"
	junkiness = 25
	antable = FALSE
	list_reagents = list("protein" = 1, "sugar" = 3)
	tastes = list("chewy beef" = 1)
	foodtype = JUNKFOOD | MEAT

/obj/item/reagent_containers/food/snacks/pistachios
	name = "pistachios"
	icon_state = "pistachios"
	desc = "Deliciously salted pistachios. A perfectly valid choice..."
	trash = /obj/item/trash/pistachios
	filling_color = "#BAD145"
	junkiness = 20
	antable = FALSE
	list_reagents = list("plantmatter" = 2, "sodiumchloride" = 1, "sugar" = 2)
	tastes = list("pistachios" = 1)
	foodtype = JUNKFOOD

/obj/item/reagent_containers/food/snacks/no_raisin
	name = "4no Raisins"
	icon_state = "4no_raisins"
	desc = "Best raisins in the universe. Not sure why."
	trash = /obj/item/trash/raisins
	filling_color = "#343834"
	junkiness = 25
	antable = FALSE
	list_reagents = list("plantmatter" = 2, "sugar" = 2)
	tastes = list("dried raisins" = 1)
	foodtype = JUNKFOOD | FRUIT

/obj/item/reagent_containers/food/snacks/spacetwinkie
	name = "Space Twinkie"
	icon_state = "space_twinkie"
	desc = "Guaranteed to survive longer then you will."
	trash = /obj/item/trash/spacetwinkie
	filling_color = "#FFE591"
	junkiness = 25
	list_reagents = list("sugar" = 4)
	tastes = list("twinkies" = 1)
	foodtype = JUNKFOOD | SUGAR

/obj/item/reagent_containers/food/snacks/cheesiehonkers
	name = "Cheesie Honkers"
	icon_state = "cheesie_honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth."
	trash = /obj/item/trash/cheesie
	filling_color = "#FFA305"
	junkiness = 25
	antable = FALSE
	list_reagents = list("nutriment" = 1, "fake_cheese" = 2, "sugar" = 3)
	tastes = list("cheese" = 1, "crisps" = 2)
	foodtype = JUNKFOOD | DAIRY

/obj/item/reagent_containers/food/snacks/syndicake
	name = "Syndi-Cakes"
	icon_state = "syndi_cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	filling_color = "#FF5D05"
	trash = /obj/item/trash/syndi_cakes
	bitesize = 3
	antable = FALSE
	list_reagents = list("nutriment" = 4, "salglu_solution" = 5)
	tastes = list("sweetness" = 3, "cake" = 1)
	foodtype = JUNKFOOD

/obj/item/reagent_containers/food/snacks/tastybread
	name = "bread tube"
	desc = "Bread in a tube. Chewy and surprisingly tasty."
	icon_state = "tastybread"
	trash = /obj/item/trash/tastybread
	filling_color = "#A66829"
	junkiness = 20
	antable = FALSE
	list_reagents = list("protein" = 2, "sugar" = 2)
	tastes = list("bread" = 1)
	foodtype = JUNKFOOD | GRAIN

/obj/item/reagent_containers/food/snacks/doshik
	name = "Doshi Co"
	desc = "Very famous instant noodles. When opened, it brewes immediantly. Wow."
	icon_state = "doshik"
	trash = /obj/item/trash/doshik
	filling_color = "#d1a62f"
	junkiness = 20
	list_reagents = list("protein" = 3)
	tastes = list("doshi co" = 1, "pleasure" = 1)
	foodtype = JUNKFOOD | MEAT
	opened = FALSE

/obj/item/reagent_containers/food/snacks/doshik_spicy
	name = "Doshi Co Special"
	desc = "Very famous instant noodles. When opened, it brewes immediantly. Wow. It seems to have hot spices in it."
	icon_state = "doshikspicy"
	trash = /obj/item/trash/doshik
	filling_color = "#d16a2f"
	junkiness = 20
	list_reagents = list("protein" = 3, "capsaicin" = 5)
	tastes = list("doshi co" = 1, "pain" = 1, "pleasure" = 1)
	foodtype = JUNKFOOD | MEAT
	opened = FALSE

//////////////////////
//		Homemade	//
//////////////////////

/obj/item/reagent_containers/food/snacks/sosjerky/healthy
	name = "homemade beef jerky"
	desc = "Homemade beef jerky made from the finest space cows."
	list_reagents = list("nutriment" = 3, "vitamin" = 1)
	junkiness = 0
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/no_raisin/healthy
	name = "homemade raisins"
	desc = "homemade raisins, the best in all of spess."
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
