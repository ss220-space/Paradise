
//////////////////////
//	Tofu & Soy		//
//////////////////////

/obj/item/reagent_containers/food/snacks/tofu
	name = "tofu"
	icon_state = "tofu"
	desc = "We all love tofu."
	filling_color = "#FFFEE0"
	bitesize = 3
	list_reagents = list("plantmatter" = 2)
	tastes = list("tofu" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/fried_tofu
	name = "fried tofu"
	icon_state = "tofu"
	desc = "Proof that even vegetarians crave unhealthy foods."
	filling_color = "#FFFEE0"
	bitesize = 3
	list_reagents = list("plantmatter" = 3)
	tastes = list("tofu" = 1)
	foodtype = VEGETABLES | FRIED

/obj/item/reagent_containers/food/snacks/soydope
	name = "soy dope"
	desc = "Like regular dope, but for the health concious consumer."
	icon_state = "soydope"
	trash = /obj/item/trash/plate
	filling_color = "#C4BF76"
	list_reagents = list("nutriment" = 2)
	tastes = list("soy" = 1)
	foodtype = VEGETABLES


//////////////////////
//		Cheese		//
//////////////////////

/obj/item/reagent_containers/food/snacks/sliceable/cheesewheel
	name = "cheese wheel"
	desc = "A big wheel of delicious Cheddar."
	icon_state = "cheesewheel"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge
	slices_num = 5
	filling_color = "#FFF700"
	list_reagents = list("nutriment" = 15, "vitamin" = 5, "cheese" = 20)
	tastes = list("cheese" = 1)
	foodtype = DAIRY

/obj/item/reagent_containers/food/snacks/cheesewedge
	name = "cheese wedge"
	desc = "A wedge of delicious Cheddar. The cheese wheel it was cut from can't have gone far."
	icon_state = "cheesewedge"
	filling_color = "#FFF700"
	tastes = list("cheese" = 1)
	foodtype = DAIRY

/obj/item/reagent_containers/food/snacks/weirdcheesewedge
	name = "weird cheese"
	desc = "Some kind of... gooey, messy, gloopy thing. Similar to cheese, but only in the broad sense of the word."
	icon_state = "weirdcheesewedge"
	filling_color = "#00FF33"
	list_reagents = list("mercury" = 5, "lsd" = 5, "ethanol" = 5, "weird_cheese" = 5)
	foodtype = DAIRY | TOXIC


//////////////////////
//		Plants		//
//////////////////////

/obj/item/reagent_containers/food/snacks/hugemushroomslice
	name = "huge mushroom slice"
	desc = "A slice from a huge mushroom."
	icon_state = "hugemushroomslice"
	filling_color = "#E0D7C5"
	bitesize = 6
	list_reagents = list("plantmatter" = 3, "vitamin" = 1)
	tastes = list("mushroom" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/tomatomeat
	name = "tomato slice"
	desc = "A slice from a huge tomato."
	icon_state = "tomatomeat"
	filling_color = "#DB0000"
	bitesize = 6
	list_reagents = list("protein" = 2)
	tastes = list("tomato" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/cucumberslice
 	name = "cucumber slice"
 	desc = "A slice from a cucumber."
 	icon_state = "cucumberslice"
 	filling_color = "#00DB00"
 	bitesize = 6
 	list_reagents = list("kelotane" = 1)
 	tastes = list("cucumber" = 1)
 	foodtype = VEGETABLES


/obj/item/reagent_containers/food/snacks/cucumberslice/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/food/snacks/cucumberslice) && I != src)
		if(!user.is_in_hands(src))
			to_chat(user, span_warning("You need to hold both slices in hands."))
			return ATTACK_CHAIN_PROCEED
		var/obj/item/clothing/glasses/sunglasses/blindfold/cucumbermask/cucumbermask = new(drop_location())
		cucumbermask.add_fingerprint(user)
		to_chat(user, span_notice("You have completed [cucumbermask]."))
		user.temporarily_remove_item_from_inventory(src, force = TRUE)
		user.temporarily_remove_item_from_inventory(I, force = TRUE)
		user.put_in_hands(cucumbermask)
		qdel(src)
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/reagent_containers/food/snacks/watermelonslice
	name = "watermelon slice"
	desc = "A slice of watery goodness."
	icon_state = "watermelonslice" // Sprite created by https://github.com/binarysudoku for Goonstation, They have relicensed it for our use.
	filling_color = "#FF3867"
	tastes = list("watermelon" = 1)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/pineappleslice
	name = "pineapple slices"
	desc = "Rings of pineapple."
	icon_state = "pineappleslice" // Sprite created by https://github.com/binarysudoku for Goonstation, They have relicensed it for our use.
	filling_color = "#e5b437"
	tastes = list("pineapple" = 1)
	foodtype = FRUIT


//////////////////////
//		Dough		//
//////////////////////

/obj/item/reagent_containers/food/snacks/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "dough"
	list_reagents = list("nutriment" = 6)
	tastes = list("dough" = 1)
	foodtype = GRAIN


/obj/item/reagent_containers/food/snacks/dough/attackby(obj/item/I, mob/user, params)
	. = ..()

	// Dough + rolling pin = flat dough
	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !istype(I, /obj/item/kitchen/rollingpin))
		return .

	if(!isturf(loc))
		to_chat(user, span_warning("You cannot flatten [src] [ismob(loc) ? "in inventory" : "in [loc]"]."))
		return .

	var/static/list/acceptable_surfaces = typecacheof(list(
		/obj/structure/table,
		/obj/machinery/optable,
		/obj/item/storage/bag/tray,
	))
	var/acceptable = FALSE
	for(var/thing in loc)
		if(is_type_in_typecache(thing, acceptable_surfaces))
			acceptable = TRUE
			break
	if(!acceptable)
		to_chat(user, span_warning("You cannot flatten [src] here! You need a table or at least a tray to do it."))
		return .

	. |= ATTACK_CHAIN_BLOCKED_ALL
	var/obj/item/reagent_containers/food/snacks/sliceable/flatdough/flatdough = new(loc)
	transfer_fingerprints_to(flatdough)
	flatdough.add_fingerprint(user)
	to_chat(user, span_notice("You have flattened [src]."))
	qdel(src)


// slicable into 3xdoughslices
/obj/item/reagent_containers/food/snacks/sliceable/flatdough
	name = "flat dough"
	desc = "Some flattened dough."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "flat dough"
	slice_path = /obj/item/reagent_containers/food/snacks/doughslice
	slices_num = 3
	list_reagents = list("nutriment" = 6)
	tastes = list("dough" = 1)
	foodtype = GRAIN


/obj/item/reagent_containers/food/snacks/doughslice
	name = "dough slice"
	desc = "The building block of an impressive dish."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "doughslice"
	list_reagents = list("nutriment" = 1)
	tastes = list("dough" = 1)
	foodtype = GRAIN


/obj/item/reagent_containers/food/snacks/doughslice/attackby(obj/item/I, mob/user, params)
	. = ..()

	// Dough + rolling pin = flat dough
	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !istype(I, /obj/item/reagent_containers/food/snacks/rawcutlet))
		return .

	if(!isturf(loc))
		to_chat(user, span_warning("You cannot cannot make a pelmeni [src] [ismob(loc) ? "in inventory" : "in [loc]"]."))
		return .

	var/static/list/acceptable_surfaces = typecacheof(list(
		/obj/structure/table,
		/obj/machinery/optable,
		/obj/item/storage/bag/tray,
	))
	var/acceptable = FALSE
	for(var/thing in loc)
		if(is_type_in_typecache(thing, acceptable_surfaces))
			acceptable = TRUE
			break
	if(!acceptable)
		to_chat(user, span_warning("You cannot make a pelmeni here! You need a table or at least a tray to do it."))
		return .

	if(!user.drop_transfer_item_to_loc(I, src))
		return .

	. |= ATTACK_CHAIN_BLOCKED_ALL
	var/obj/item/reagent_containers/food/snacks/pelmeni/pelmeni = new(loc)
	transfer_fingerprints_to(pelmeni)
	pelmeni.add_fingerprint(user)
	to_chat(user, span_notice("You have made some pelmeni."))
	qdel(src)
	qdel(I)


///cookies by Ume

/obj/item/reagent_containers/food/snacks/cookiedough
	name = "pastry dough"
	icon = 'icons/obj/food/food_ingredients.dmi'
	desc = "The base for tasty cookies."
	icon_state = "cookiedough"
	list_reagents = list("nutriment" = 5, "sugar" = 1)
	tastes = list("dough" = 1, "sugar" = 1)
	foodtype = GRAIN|SUGAR
	var/flat = FALSE


/obj/item/reagent_containers/food/snacks/cookiedough/update_icon_state()
	icon_state = "cookiedough[flat ? "_flat" : ""]"


/obj/item/reagent_containers/food/snacks/cookiedough/update_name(updates = ALL)
	. = ..()
	name = flat ? "flat pastry dough" : initial(name)


/obj/item/reagent_containers/food/snacks/cookiedough/attackby(obj/item/I, mob/user, params)
	. = ..()

	// Dough + rolling pin = flat cookie dough // Flat dough + circular cutter = unbaked cookies
	var/rolling = istype(I, /obj/item/kitchen/rollingpin)
	if(ATTACK_CHAIN_CANCEL_CHECK(.) || (!rolling && !istype(I, /obj/item/kitchen/cutter)))
		return .

	if(!isturf(loc))
		to_chat(user, span_warning("You cannot [rolling ? "flatten" : "cut"] [src] [ismob(loc) ? "in inventory" : "in [loc]"]."))
		return .

	var/static/list/acceptable_surfaces = typecacheof(list(
		/obj/structure/table,
		/obj/machinery/optable,
		/obj/item/storage/bag/tray,
	))
	var/acceptable = FALSE
	for(var/thing in loc)
		if(is_type_in_typecache(thing, acceptable_surfaces))
			acceptable = TRUE
			break
	if(!acceptable)
		to_chat(user, span_warning("You cannot [rolling ? "flatten" : "cut"] [src] here! You need a table or at least a tray to do it."))
		return .

	if(rolling && flat)
		to_chat(user, span_warning("The [name] is already flat enough."))
		return .

	if(!rolling && !flat)
		to_chat(user, span_warning("You should roll it out first."))
		return .

	if(rolling)
		to_chat(user, span_notice("You have flattened [src]."))
		flat = TRUE
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)
		return .|ATTACK_CHAIN_SUCCESS

	. |= ATTACK_CHAIN_BLOCKED_ALL
	var/obj/item/reagent_containers/food/snacks/rawcookies/cookies = new(loc)
	transfer_fingerprints_to(cookies)
	cookies.add_fingerprint(user)
	to_chat(user, span_notice("You have cut [src] into raw cookies."))
	qdel(src)


/obj/item/reagent_containers/food/snacks/rawcookies
	name = "raw cookies"
	desc = "Ready for oven!"
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "unbaked_cookies"
	list_reagents = list("nutriment" = 5, "sugar" = 2)
	foodtype = GRAIN | SUGAR


/obj/item/reagent_containers/food/snacks/rawcookies/attackby(obj/item/I, mob/user, params)
	. = ..()

	// Dough + rolling pin = flat dough
	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !istype(I, /obj/item/reagent_containers/food/snacks/choc_pile))
		return .

	if(!isturf(loc))
		to_chat(user, span_warning("You need to put [src] on a surface to add [I]."))
		return .

	if(!user.drop_transfer_item_to_loc(I, src))
		return .

	. |= ATTACK_CHAIN_BLOCKED_ALL
	var/obj/item/reagent_containers/food/snacks/rawcookies/chocochips/chocochips = new(loc)
	transfer_fingerprints_to(chocochips)
	chocochips.add_fingerprint(user)
	to_chat(user, span_notice("You sprinkle [I] all over the cookies."))
	qdel(src)
	qdel(I)


/obj/item/reagent_containers/food/snacks/rawcookies/chocochips
	name = "raw cookies"
	desc = "Ready for oven! They have little pieces of chocolate all over them"
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "unbaked_cookies_choco"
	list_reagents = list("nutriment" = 5, "sugar" = 5, "chocolate" = 5)
	tastes = list("dough" = 1, "sugar" = 1, "chocolate" = 1)

//////////////////////
//	Chocolate		//
//////////////////////

/obj/item/reagent_containers/food/snacks/chocolatebar
	name = "chocolate bar"
	desc = "Such sweet, fattening food."
	icon_state = "chocolatebar"
	filling_color = "#7D5F46"
	list_reagents = list("nutriment" = 2, "sugar" = 5, "cocoa" = 2)
	tastes = list("chocolate" = 1)
	foodtype = SUGAR


/obj/item/reagent_containers/food/snacks/chocolatebar/attackby(obj/item/I, mob/user, params)
	. = ..()

	// chocolate crumbles/pile
	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !is_sharp(I))
		return .

	if(!isturf(loc))
		to_chat(user, span_warning("You cannot cut [src] [ismob(loc) ? "in inventory" : "in [loc]"]."))
		return .

	var/static/list/acceptable_surfaces = typecacheof(list(
		/obj/structure/table,
		/obj/machinery/optable,
		/obj/item/storage/bag/tray,
	))
	var/acceptable = FALSE
	for(var/thing in loc)
		if(is_type_in_typecache(thing, acceptable_surfaces))
			acceptable = TRUE
			break
	if(!acceptable)
		to_chat(user, span_warning("You cannot cut [src] here! You need a table or at least a tray to do it."))
		return .

	. |= ATTACK_CHAIN_BLOCKED_ALL
	var/obj/item/reagent_containers/food/snacks/choc_pile/choc_pile = new(loc)
	transfer_fingerprints_to(choc_pile)
	choc_pile.add_fingerprint(user)
	to_chat(user, span_notice("You have cut [src] into little crumbles."))
	qdel(src)


/obj/item/reagent_containers/food/snacks/choc_pile //for reagent chocolate being spilled on turfs
	name = "pile of chocolate"
	desc = "A pile of pure chocolate pieces."
	icon_state = "cocoa"
	filling_color = "#7D5F46"
	list_reagents = list("chocolate" = 5)
	tastes = list("chocolate" = 1)
	foodtype = SUGAR

//////////////////////
//		Misc		//
//////////////////////

/obj/item/reagent_containers/food/snacks/ectoplasm
	name = "ectoplasm"
	desc = "A luminescent blob of what scientists refer to as 'ghost goo'."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "ectoplasm"
	list_reagents = list("ectoplasm" = 10)
	tastes = list("spookiness" = 1)
	foodtype = GROSS
