//////////////////////
//	Lunch-box	//
//////////////////////

/obj/item/reagent_containers/food/snacks/lunchBoxPizza
	name = "Pizza lunch"
	icon_state = "lunch_Pizza"
	desc = "Perfect pizza, in box."
	trash = /obj/item/stack/sheet/plastic
	list_reagents = list("nutriment" = 7)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lunchBoxMochi
	name = "Mochi lunch"
	icon_state = "lunch_mochi"
	desc = "Perfect mochi in box."
	trash = /obj/item/stack/sheet/plastic
	list_reagents = list("nutriment" = 7)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/lunchBoxMonkeyvyha
	name = "Monkeyvyha"
	icon_state = "lunch_monkeyvuha"
	desc = "Hmm.. Something familiar and strange. But there must be another animal inside."
	trash = /obj/item/stack/sheet/plastic
	list_reagents = list("????" = 30, "vodka" = 20, "toxin" = 5 )
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lunchBoxByter
	name = "Byter lunch"
	icon_state = "lunch_byter"
	desc = "Perfect byter in box."
	trash = /obj/item/stack/sheet/plastic
	list_reagents = list("nutriment" = 7)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lunchBoxFrenchFries
	name = "French fries lunch"
	icon_state = "lunch_frenchFries"
	desc = "Perfect fries in box."
	trash = /obj/item/stack/sheet/plastic
	list_reagents = list("nutriment" = 7)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lunchBoxVOX
	name = "Vox lunch"
	icon_state = "lunch_Vox"
	desc = "Vox chiken meat in box."
	trash = /obj/item/stack/sheet/plastic
	list_reagents = list("nutriment" = 7)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lunchBoxBurger
	name = "Burger lunch"
	icon_state = "lunch_Burger"
	desc = "Zoomers like burger in box."
	trash = /obj/item/stack/sheet/plastic

	list_reagents = list("nutriment" = 7)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lunchBoxSushi
	name = "Sushi lunch"
	icon_state = "lunch_Sushi"
	desc = "Real good Sushi in box."
	trash = /obj/item/stack/sheet/plastic
	list_reagents = list("nutriment" = 8)
	foodtype = MEAT

//////////////////////
//		Mexican		//
//////////////////////

/obj/item/reagent_containers/food/snacks/taco
	name = "taco"
	desc = "Take a bite!"
	icon_state = "taco"
	bitesize = 3
	list_reagents = list("nutriment" = 7, "vitamin" = 1)
	tastes = list("taco" = 4, "meat" = 2, "cheese" = 2, "lettuce" = 1)
	foodtype = MEAT | VEGETABLES

/obj/item/reagent_containers/food/snacks/burrito
	name = "burrito"
	desc = "Meat, beans, cheese, and rice wrapped up as an easy-to-hold meal."
	icon_state = "burrito"
	trash = /obj/item/trash/plate
	filling_color = "#A36A1F"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("torilla" = 2, "meat" = 3)
	foodtype = MEAT | VEGETABLES


/obj/item/reagent_containers/food/snacks/chimichanga
	name = "chimichanga"
	desc = "Time to eat a chimi-f***ing-changa."
	icon_state = "chimichanga"
	trash = /obj/item/trash/plate
	filling_color = "#A36A1F"
	list_reagents = list("omnizine" = 4, "cheese" = 2) //Deadpool reference. Deal with it.
	foodtype = MEAT | VEGETABLES

/obj/item/reagent_containers/food/snacks/enchiladas
	name = "enchiladas"
	desc = "Viva la Mexico!"
	icon_state = "enchiladas"
	trash = /obj/item/trash/tray
	filling_color = "#A36A1F"
	bitesize = 4
	list_reagents = list("nutriment" = 8, "capsaicin" = 6)
	tastes = list("hot peppers" = 1, "meat" = 3, "cheese" = 1, "sour cream" = 1)
	foodtype = MEAT | VEGETABLES

/obj/item/reagent_containers/food/snacks/cornchips
	name = "corn chips"
	desc = "Goes great with salsa! OLE!"
	icon_state = "chips"
	bitesize = 1
	trash = /obj/item/trash/chips
	filling_color = "#E8C31E"
	list_reagents = list("nutriment" = 3)
	foodtype = FRIED | GRAIN


//////////////////////
//		Chinese		//
//////////////////////

/obj/item/reagent_containers/food/snacks/chinese/chowmein
	name = "chow mein"
	desc = "What is in this anyways?"
	icon_state = "chinese1"
	junkiness = 25
	antable = FALSE
	list_reagents = list("nutriment" = 1, "beans" = 3, "msg" = 4, "sugar" = 2)
	tastes = list("noodle" = 1, "vegetables" = 1)
	foodtype = FRIED | VEGETABLES

/obj/item/reagent_containers/food/snacks/chinese/sweetsourchickenball
	name = "sweet & sour chicken balls"
	desc = "Is this chicken cooked? The odds are better than wok paper scissors."
	icon_state = "chickenball"
	item_state = "chinese3"
	junkiness = 25
	list_reagents = list("nutriment" = 2, "msg" = 4, "sugar" = 2)
	tastes = list("chicken" = 1, "sweetness" = 1)
	foodtype = FRIED | MEAT

/obj/item/reagent_containers/food/snacks/chinese/tao
	name = "Admiral Yamamoto carp"
	desc = "Tastes like chicken."
	icon_state = "chinese2"
	junkiness = 25
	antable = FALSE
	list_reagents = list("nutriment" = 1, "protein" = 1, "msg" = 4, "sugar" = 4)
	tastes = list("chicken" = 1)
	foodtype = FRIED | MEAT

/obj/item/reagent_containers/food/snacks/chinese/newdles
	name = "chinese newdles"
	desc = "Made fresh, weekly!"
	icon_state = "chinese3"
	junkiness = 25
	antable = FALSE
	list_reagents = list("nutriment" = 1, "msg" = 4, "sugar" = 3)
	tastes = list("noodles" = 1)
	foodtype = FRIED | GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/chinese/rice
	name = "fried rice"
	desc = "A timeless classic."
	icon_state = "chinese4"
	item_state = "chinese2"
	junkiness = 20
	antable = FALSE
	list_reagents = list("nutriment" = 1, "rice" = 3, "msg" = 4, "sugar" = 2)
	tastes = list("rice" = 1)
	foodtype = FRIED | GRAIN | VEGETABLES


//////////////////////
//	Japanese		//
//////////////////////

/obj/item/reagent_containers/food/snacks/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#F0F2E4"
	list_reagents = list("nutriment" = 5)
	tastes = list("custard" = 1)
	foodtype = DAIRY

/obj/item/reagent_containers/food/snacks/yakiimo
	name = "yaki imo"
	desc = "Made with roasted sweet potatoes!"
	icon_state = "yakiimo"
	trash = /obj/item/trash/plate
	list_reagents = list("nutriment" = 5, "vitamin" = 4)
	filling_color = "#8B1105"
	tastes = list("sweet potato" = 1)
	foodtype = VEGETABLES | SUGAR


//////////////////////
//	Middle Eastern	//
//////////////////////

/obj/item/reagent_containers/food/snacks/kabob
	name = "-kabob"
	icon_state = "kabob"
	desc = "Human meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#A85340"
	list_reagents = list("nutriment" = 8)
	foodtype = MEAT | FRIED

/obj/item/reagent_containers/food/snacks/monkeykabob
	name = "meat-kabob"
	icon_state = "kabob"
	desc = "Delicious meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#A85340"
	list_reagents = list("nutriment" = 8)
	foodtype = MEAT | FRIED

/obj/item/reagent_containers/food/snacks/tofukabob
	name = "tofu-kabob"
	icon_state = "kabob"
	desc = "Vegan meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#FFFEE0"
	list_reagents = list("nutriment" = 8)
	foodtype = VEGETABLES | FRIED
