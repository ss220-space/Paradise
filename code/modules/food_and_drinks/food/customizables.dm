/obj/item/proc/make_custom_food(obj/item/reagent_containers/food/snacks/snack, mob/user, custom_type)
	. = TRUE
	if(!istype(snack) || !user.can_unEquip(snack))
		return FALSE

	var/obj/item/reagent_containers/food/snacks/customizable/custom_snack = new custom_type(drop_location())
	custom_snack.add_ingredient(snack, user)
	qdel(src)


/obj/item/reagent_containers/food/snacks/breadslice/attackby(obj/item/I, mob/user, params)
	if(make_custom_food(I, user, /obj/item/reagent_containers/food/snacks/customizable/sandwich))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/reagent_containers/food/snacks/bun/attackby(obj/item/I, mob/user, params)
	if(make_custom_food(I, user, /obj/item/reagent_containers/food/snacks/customizable/burger))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/reagent_containers/food/snacks/sliceable/flatdough/attackby(obj/item/I, mob/user, params)
	if(make_custom_food(I, user, /obj/item/reagent_containers/food/snacks/customizable/pizza))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/reagent_containers/food/snacks/boiledspaghetti/attackby(obj/item/I, mob/user, params)
	if(make_custom_food(I, user, /obj/item/reagent_containers/food/snacks/customizable/pasta))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/trash/plate/attackby(obj/item/I, mob/user, params)
	if(make_custom_food(I, user, /obj/item/reagent_containers/food/snacks/customizable/fullycustom))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/trash/bowl
	name = "bowl"
	desc = "An empty bowl. Put some food in it to start making a soup."
	icon = 'icons/obj/food/custom.dmi'
	icon_state = "soup"


/obj/item/trash/bowl/attackby(obj/item/I, mob/user, params)
	if(make_custom_food(I, user, /obj/item/reagent_containers/food/snacks/customizable/soup))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/reagent_containers/food/snacks/customizable
	name = "sandwich"
	desc = "A sandwich! A timeless classic."
	icon = 'icons/obj/food/custom.dmi'
	icon_state = "sandwichcustom"
	var/baseicon = "sandwichcustom"
	var/basename = "sandwichcustom"
	bitesize = 4
	var/top = FALSE	//Do we have a top?
	/// The image of the top
	var/image/top_image
	var/snack_overlays = FALSE	//Do we stack?
	var/ingredient_limit = 40
	var/fullycustom = FALSE
	trash = /obj/item/trash/plate
	var/list/ingredients = list()
	list_reagents = list("nutriment" = 8)


/obj/item/reagent_containers/food/snacks/customizable/Initialize(mapload)
	. = ..()
	if(top)
		top_image = new(icon, "[baseicon]_top")
		add_overlay(top_image)
	if(snack_overlays)
		layer = ABOVE_ALL_MOB_LAYER	// all should see our monstrosity

/obj/item/reagent_containers/food/snacks/customizable/sandwich
	name = "sandwich"
	desc = "A sandwich! A timeless classic."
	icon_state = "breadslice"
	baseicon = "sandwichcustom"
	basename = "sandwich"
	snack_overlays = TRUE

/obj/item/reagent_containers/food/snacks/customizable/pizza
	name = "personal pizza"
	desc = "A personalized pan pizza meant for only one person."
	icon_state = "personal_pizza"
	baseicon = "personal_pizza"
	basename = "personal pizza"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)

/obj/item/reagent_containers/food/snacks/customizable/pasta
	name = "spaghetti"
	desc = "Noodles. With stuff. Delicious."
	icon_state = "pasta_bot"
	baseicon = "pasta_bot"
	basename = "pasta"
/obj/item/reagent_containers/food/snacks/customizable/cook/bread
	name = "bread"
	desc = "Tasty bread."
	icon_state = "breadcustom"
	baseicon = "breadcustom"
	basename = "bread"
	tastes = list("bread" = 10)

/obj/item/reagent_containers/food/snacks/customizable/cook/pie
	name = "pie"
	desc = "Tasty pie."
	icon_state = "piecustom"
	baseicon = "piecustom"
	basename = "pie"
	tastes = list("pie" = 1)

/obj/item/reagent_containers/food/snacks/customizable/cook/cake
	name = "cake"
	desc = "A popular band."
	icon_state = "cakecustom"
	baseicon = "cakecustom"
	basename = "cake"
	tastes = list("cake" = 1)

/obj/item/reagent_containers/food/snacks/customizable/cook/jelly
	name = "jelly"
	desc = "Totally jelly."
	icon_state = "jellycustom"
	baseicon = "jellycustom"
	basename = "jelly"

/obj/item/reagent_containers/food/snacks/customizable/cook/donkpocket
	name = "donk pocket"
	desc = "You wanna put a bangin-Oh nevermind."
	icon_state = "donkcustom"
	baseicon = "donkcustom"
	basename = "donk pocket"

/obj/item/reagent_containers/food/snacks/customizable/cook/kebab
	name = "kebab"
	desc = "Kebab or Kabab?"
	icon_state = "kababcustom"
	baseicon = "kababcustom"
	basename = "kebab"
	tastes = list("meat" = 3, "metal" = 1)

/obj/item/reagent_containers/food/snacks/customizable/cook/salad
	name = "salad"
	desc = "Very tasty."
	icon_state = "saladcustom"
	baseicon = "saladcustom"
	basename = "salad"
	tastes = list("leaves" = 1)

/obj/item/reagent_containers/food/snacks/customizable/cook/waffles
	name = "waffles"
	desc = "Made with love."
	icon_state = "wafflecustom"
	baseicon = "wafflecustom"
	basename = "waffles"
	tastes = list("waffles" = 1)

/obj/item/reagent_containers/food/snacks/customizable/candy/cookie
	name = "cookie"
	desc = "COOKIE!!1!"
	icon_state = "cookiecustom"
	baseicon = "cookiecustom"
	basename = "cookie"
	tastes = list("cookie" = 1)

/obj/item/reagent_containers/food/snacks/customizable/candy/cotton
	name = "flavored cotton candy"
	desc = "Who can take a sunrise, sprinkle it with dew,"
	icon_state = "cottoncandycustom"
	baseicon = "cottoncandycustom"
	basename = "flavored cotton candy"

/obj/item/reagent_containers/food/snacks/customizable/candy/gummybear
	name = "flavored giant gummy bear"
	desc = "Cover it in chocolate and a miracle or two,"
	icon_state = "gummybearcustom"
	baseicon = "gummybearcustom"
	basename = "flavored giant gummy bear"

/obj/item/reagent_containers/food/snacks/customizable/candy/gummyworm
	name = "flavored giant gummy worm"
	desc = "The Candy Man can 'cause he mixes it with love,"
	icon_state = "gummywormcustom"
	baseicon = "gummywormcustom"
	basename = "flavored giant gummy worm"

/obj/item/reagent_containers/food/snacks/customizable/candy/jellybean
	name = "flavored giant jelly bean"
	desc = "And makes the world taste good."
	icon_state = "jellybeancustom"
	baseicon = "jellybeancustom"
	basename = "flavored giant jelly bean"

/obj/item/reagent_containers/food/snacks/customizable/candy/jawbreaker
	name = "flavored jawbreaker"
	desc = "Who can take a rainbow, Wrap it in a sigh,"
	icon_state = "jawbreakercustom"
	baseicon = "jawbreakercustom"
	basename = "flavored jawbreaker"

/obj/item/reagent_containers/food/snacks/customizable/candy/candycane
	name = "flavored candy cane"
	desc = "Soak it in the sun and make strawberry-lemon pie,"
	icon_state = "candycanecustom"
	baseicon = "candycanecustom"
	basename = "flavored candy cane"

/obj/item/reagent_containers/food/snacks/customizable/candy/gum
	name = "flavored gum"
	desc = "The Candy Man can 'cause he mixes it with love and makes the world taste good. And the world tastes good 'cause the Candy Man thinks it should..."
	icon_state = "gumcustom"
	baseicon = "gumcustom"
	basename = "flavored gum"

/obj/item/reagent_containers/food/snacks/customizable/candy/donut
	name = "filled donut"
	desc = "Donut eat this!" // kill me
	icon_state = "donutcustom"
	baseicon = "donutcustom"
	basename = "filled donut"

/obj/item/reagent_containers/food/snacks/customizable/candy/bar
	name = "flavored chocolate bar"
	desc = "Made in a factory downtown."
	icon_state = "barcustom"
	baseicon = "barcustom"
	basename = "flavored chocolate bar"

/obj/item/reagent_containers/food/snacks/customizable/candy/sucker
	name = "flavored sucker"
	desc = "Suck suck suck."
	icon_state = "suckercustom"
	baseicon = "suckercustom"
	basename = "flavored sucker"

/obj/item/reagent_containers/food/snacks/customizable/candy/cash
	name = "flavored chocolate cash"
	desc = "I got piles!"
	icon_state = "cashcustom"
	baseicon = "cashcustom"
	basename = "flavored cash"

/obj/item/reagent_containers/food/snacks/customizable/candy/coin
	name = "flavored chocolate coin"
	desc = "Clink, clink, clink."
	icon_state = "coincustom"
	baseicon = "coincustom"
	basename = "flavored coin"

/obj/item/reagent_containers/food/snacks/customizable/fullycustom // In the event you fuckers find something I forgot to add a customizable food for.
	name = "on a plate"
	desc = "A unique dish."
	icon_state = "fullycustom"
	baseicon = "fullycustom"
	basename = "on a plate"
	ingredient_limit = 20
	fullycustom = TRUE

/obj/item/reagent_containers/food/snacks/customizable/soup
	name = "soup"
	desc = "A bowl with liquid and... stuff in it."
	icon_state = "soup"
	baseicon = "soup"
	basename = "soup"
	trash = /obj/item/trash/bowl
	tastes = list("soup" = 1)

/obj/item/reagent_containers/food/snacks/customizable/burger
	name = "burger bun"
	desc = "A bun for a burger. Delicious."
	icon_state = "burger"
	baseicon = "burgercustom"
	basename = "burger"
	top = TRUE
	snack_overlays = TRUE
	tastes = list("bun" = 4)


/obj/item/reagent_containers/food/snacks/customizable/Destroy()
	QDEL_LIST(ingredients)
	return ..()


/obj/item/reagent_containers/food/snacks/customizable/examine(mob/user)
	. = ..()
	if(LAZYLEN(ingredients))
		var/whatsinside = pick(ingredients)
		. += span_notice("You think you can see [whatsinside] in there.")


/obj/item/reagent_containers/food/snacks/customizable/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/reagent_containers/food/snacks))
		to_chat(user, span_warning("[I] isn't exactly something that you would want to eat."))
		return ..()

	if(!user.can_unEquip(I))
		return ..()

	if(add_ingredient(I, user))
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/**
 * Tries to add one ingredient and it's ingredients, if any and applicable, to this snack
 *
 * Arguments:
 * * snack - The ingredient that will be added
 * * user - chef
 */
/obj/item/reagent_containers/food/snacks/customizable/proc/add_ingredient(obj/item/reagent_containers/food/snacks/snack, mob/user)
	. = FALSE

	add_fingerprint(user)
	if(length(ingredients) > ingredient_limit)
		to_chat(user, span_warning("If you put anything else in or on [src] it's going to make a mess."))
		return .

	// Fully custom snacks don't add the ingredients. So no need to check
	var/fullycustom_check = !fullycustom && istype(snack, /obj/item/reagent_containers/food/snacks/customizable)
	if(fullycustom_check)
		var/obj/item/reagent_containers/food/snacks/customizable/origin = snack
		if(length(ingredients) + length(origin.ingredients) > ingredient_limit)
			to_chat(user, span_warning("Merging [snack] and [src] together is going to make a mess."))
			return .

	. = TRUE

	to_chat(user, span_notice("You add [snack] to [src]."))
	user.drop_transfer_item_to_loc(snack, src)
	snack.reagents.trans_to(src, snack.reagents.total_volume)

	var/list/added_ingredients = list(snack)

	// Only merge when it is not fullycustom. Else it looks weird
	if(fullycustom_check)
		var/obj/item/reagent_containers/food/snacks/customizable/origin = snack
		added_ingredients += origin.ingredients
		origin.ingredients.Cut()
		origin.name = initial(origin.name) // Reset the name for the examine text

	cooktype[basename] = TRUE
	add_ingredients(added_ingredients)
	name = newname()


/obj/item/reagent_containers/food/snacks/customizable/proc/add_ingredients(list/new_ingredients)
	cut_overlay(top_image) // Remove the top image so we can change it again

	var/ingredient_num = length(ingredients)
	ingredients += new_ingredients
	for(var/obj/item/reagent_containers/food/snacks/food as anything in new_ingredients)
		ingredient_num++
		var/image/ingredient_image
		if(!fullycustom)
			ingredient_image = new(icon, "[baseicon]_filling")
			if(!food.filling_color == "#FFFFFF")
				ingredient_image.color = food.filling_color
			else
				ingredient_image.color = pick("#FF0000", "#0000FF", "#008000", "#FFFF00")
			if(snack_overlays)
				ingredient_image.pixel_x = rand(2) - 1
				ingredient_image.pixel_y = ingredient_num * 2 + 1
		else
			ingredient_image = new(food.icon, food.icon_state)
			ingredient_image.pixel_x = rand(2) - 1
			ingredient_image.pixel_y = rand(2) - 1
			add_overlay(food.overlays)

		add_overlay(ingredient_image)

	if(top_image)
		top_image.pixel_x = rand(2) - 1
		top_image.pixel_y = ingredient_num * 2 + 1
		add_overlay(top_image)


/obj/item/reagent_containers/food/snacks/customizable/proc/newname()
	var/unsorteditems[0]
	var/sorteditems[0]
	var/unsortedtypes[0]
	var/sortedtypes[0]
	var/endpart = ""
	var/c = 0
	var/ci = 0
	var/ct = 0
	var/seperator = ""
	var/sendback = ""
	var/list/levels = list("", "double", "triple", "quad", "huge")

	for(var/obj/item/ing in ingredients)
		if(istype(ing, /obj/item/shard))
			continue


		if(istype(ing, /obj/item/reagent_containers/food/snacks/customizable))				// split the ingredients into ones with basenames (sandwich, burger, etc) and ones without, keeping track of how many of each there are
			var/obj/item/reagent_containers/food/snacks/customizable/gettype = ing
			if(unsortedtypes[gettype.basename])
				unsortedtypes[gettype.basename]++
				if(unsortedtypes[gettype.basename] > ct)
					ct = unsortedtypes[gettype.basename]
			else
				(unsortedtypes[gettype.basename]) = 1
				if(unsortedtypes[gettype.basename] > ct)
					ct = unsortedtypes[gettype.basename]
		else
			if(unsorteditems[ing.name])
				unsorteditems[ing.name]++
				if(unsorteditems[ing.name] > ci)
					ci = unsorteditems[ing.name]
			else
				unsorteditems[ing.name] = 1
				if(unsorteditems[ing.name] > ci)
					ci = unsorteditems[ing.name]

	sorteditems = sortlist(unsorteditems, ci)				//order both types going from the lowest number to the highest number
	sortedtypes = sortlist(unsortedtypes, ct)

	for(var/ings in sorteditems)			   //add the non-basename items to the name, sorting out the , and the and
		c++
		if(c == sorteditems.len - 1)
			seperator = " and "
		else if(c == sorteditems.len)
			seperator = " "
		else
			seperator = ", "

		if(sorteditems[ings] > levels.len)
			sorteditems[ings] = levels.len

		if(sorteditems[ings] <= 1)
			sendback +="[ings][seperator]"
		else
			sendback +="[levels[sorteditems[ings]]] [ings][seperator]"

	for(var/ingtype in sortedtypes)   // now add the types basenames, keeping the src one seperate so it can go on the end
		if(sortedtypes[ingtype] > levels.len)
			sortedtypes[ingtype] = levels.len
		if(ingtype == basename)
			if(sortedtypes[ingtype] < levels.len)
				sortedtypes[ingtype]++
			endpart = "[levels[sortedtypes[ingtype]]] decker [basename]"
			continue
		if(sortedtypes[ingtype] >= 2)
			sendback += "[levels[sortedtypes[ingtype]]] decker [ingtype] "
		else
			sendback += "[ingtype] "

	if(endpart)
		sendback += endpart
	else
		sendback += basename

	if(length(sendback) > 80)
		sendback = "[pick(list("absurd","colossal","enormous","ridiculous","massive","oversized","cardiac-arresting","pipe-clogging","edible but sickening","sickening","gargantuan","mega","belly-burster","chest-burster"))] [basename]"
	return sendback


/obj/item/reagent_containers/food/snacks/customizable/proc/sortlist(list/unsorted, highest)
	var/sorted[0]
	for(var/i = 1, i<= highest, i++)
		for(var/it in unsorted)
			if(unsorted[it] == i)
				sorted[it] = i
	return sorted

