
//////////////////////
//	Raw Pasta		//
//////////////////////

/obj/item/reagent_containers/food/snacks/spaghetti
	name = "spaghetti"
	desc = "A bundle of raw spaghetti."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "spaghetti"
	filling_color = "#EDDD00"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("raw pasta" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/macaroni
	name = "macaroni twists"
	desc = "These are little twists of raw macaroni."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "macaroni"
	filling_color = "#EDDD00"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("raw pasta" = 1)
	foodtype = GRAIN

//////////////////////
//	Pasta Dishes	//
//////////////////////

/obj/item/reagent_containers/food/snacks/boiledspaghetti
	name = "boiled spaghetti"
	desc = "A plain dish of noodles. This sucks."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "spaghettiboiled"
	trash = /obj/item/trash/plate
	filling_color = "#FCEE81"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("pasta" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/pastatomato
	name = "spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "pastatomato"
	trash = /obj/item/trash/plate
	filling_color = "#DE4545"
	bitesize = 4
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/drink/tomatojuice = 10, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pasta" = 1, "tomato" = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/meatballspaghetti
	name = "spaghetti & meatballs"
	desc = "Now thats a nice'a meatball!"
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "meatballspaghetti"
	trash = /obj/item/trash/plate
	filling_color = "#DE4545"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/medicine/synaptizine = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pasta" = 1, "tomato" = 1, "meat" = 1)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/spesslaw
	name = "spesslaw"
	desc = "A lawyer's favourite."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "spesslaw"
	filling_color = "#DE4545"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/medicine/synaptizine = 10, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("pasta" = 1, "tomato" = 1, "meat" = 2)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/macncheese
	name = "mac 'n' cheese"
	desc = "One of the most comforting foods in the world. Apparently."
	w_class = WEIGHT_CLASS_SMALL
	trash = /obj/item/trash/snack_bowl
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "macncheese"
	filling_color = "#ffe45d"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/cheese = 4)
	tastes = list("pasta" = 1, "cheese" = 1, "comfort" = 1)
	foodtype = GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/lasagna
	name = "Lasagna"
	desc = "Tajara are supposed to love to eat this, but the tomato really doesn't work well."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "lasagna"
	filling_color = "#E18712"
	list_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/msg = 3, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/drink/tomatojuice = 10)
	tastes = list("pasta" = 1, "cheese" = 1, "tomato" = 1, "meat" = 1)
	foodtype = GRAIN | DAIRY | VEGETABLES | MEAT

/obj/item/reagent_containers/food/snacks/chowmein
	name = "Chowmein"
	desc = "Nihao!"
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "chowmein"
	trash = /obj/item/trash/plate
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/protein = 6)
	tastes = list("pasta" = 1, "carrot" = 1, "cabage" = 1, "meat" = 1)
	bitesize = 3
	foodtype = GRAIN | VEGETABLES | MEAT

/obj/item/reagent_containers/food/snacks/beefnoodles
	name = "Beef noodles"
	desc = "So simple, but so yummy!"
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "beefnoodles"
	trash = /obj/item/trash/snack_bowl
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/plantmatter = 3)
	tastes = list("pasta" = 1, "cabage" = 1, "meat" = 2)
	foodtype = GRAIN | VEGETABLES | MEAT
