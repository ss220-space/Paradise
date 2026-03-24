//MARK: Crafting recipe
/datum/crafting_recipe/food
	///The food types that are added to the result when the recipe is completed
	var/added_foodtypes = NONE
	///The food types that are removed to the result when the recipe is completed
	var/removed_foodtypes = NONE

/datum/crafting_recipe/food/New()
	. = ..()
	//rarely, but a few cooking recipes (cake cat & co) don't result food items.
	if(!ispath(result, /obj/item/reagent_containers/food))
		return

	// Food made from these recipes should inherit the food types of the food ingredients used in it
	// 'added_foodtypes' and 'added_foodtypes' exist to add and remove (un)desiderable types
	// If the food types of the result don't match when spawned compared to when crafted (with base ingredients), throw a warning.
	var/made_with_food = FALSE
	var/actual_foodtypes = added_foodtypes
	for(var/req_path in reqs)
		if(!ispath(req_path, /obj/item/reagent_containers/food))
			continue
		var/obj/item/reagent_containers/food/ingredient = req_path
		made_with_food = TRUE
		actual_foodtypes |= initial(ingredient.foodtype)
	if(!made_with_food)
		return
	actual_foodtypes &= ~removed_foodtypes
	var/obj/item/reagent_containers/food/result_path = result
	var/result_foodtypes = initial(result_path.foodtype)
	if(result_foodtypes != actual_foodtypes)
		var/text_flags = jointext(bitfield_to_list(result_foodtypes, FOOD_FLAGS),"|")
		var/text_craft_flags = jointext(bitfield_to_list(actual_foodtypes, FOOD_FLAGS),"|")
		stack_trace("the foodtype of [result_path] are [text_flags] when spawned but [text_craft_flags] when crafted.")

//MARK: Chemical reaction
/datum/chemical_reaction/food
	/// Typepath of food that is created on reaction
	var/atom/resulting_food_path

/datum/chemical_reaction/food/pre_reaction_other_checks(datum/reagents/holder)
	return TRUE

/datum/chemical_reaction/food/on_reaction(datum/reagents/holder, created_volume)
	if(resulting_food_path)
		var/atom/location = holder.my_atom.drop_location()
		for(var/i in 1 to created_volume)
			new resulting_food_path(location)


/datum/chemical_reaction/food/tofu
	name = "Tofu"
	id = "tofu"
	result = null
	required_reagents = list("soymilk" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 1
	resulting_food_path = /obj/item/reagent_containers/food/snacks/tofu

/datum/chemical_reaction/food/chocolate_bar
	name = "Chocolate Bar"
	id = "chocolate_bar"
	result = null
	required_reagents = list("soymilk" = 2, "cocoa" = 2, "sugar" = 2)
	result_amount = 1
	resulting_food_path = /obj/item/reagent_containers/food/snacks/chocolatebar

/datum/chemical_reaction/food/chocolate_bar2
	name = "Chocolate Bar"
	id = "chocolate_bar"
	result = null
	required_reagents = list("milk" = 2, "cocoa" = 2, "sugar" = 2)
	result_amount = 1
	resulting_food_path = /obj/item/reagent_containers/food/snacks/chocolatebar

/datum/chemical_reaction/food/soysauce
	name = "Soy Sauce"
	id = "soysauce"
	result = "soysauce"
	required_reagents = list("soymilk" = 1,"sodiumchloride" = 1, "water" = 8)
	result_amount = 10

/datum/chemical_reaction/food/cheesewheel
	name = "Cheesewheel"
	id = "cheesewheel"
	result = null
	required_reagents = list("milk" = 40)
	required_catalysts = list("enzyme" = 5)
	result_amount = 1
	resulting_food_path = /obj/item/reagent_containers/food/snacks/sliceable/cheesewheel

/datum/chemical_reaction/food/hot_ramen
	name = "Hot Ramen"
	id = "hot_ramen"
	result = "hot_ramen"
	required_reagents = list("water" = 1, "dry_ramen" = 3)
	result_amount = 3

/datum/chemical_reaction/food/hell_ramen
	name = "Hell Ramen"
	id = "hell_ramen"
	result = "hell_ramen"
	required_reagents = list("capsaicin" = 1, "hot_ramen" = 6)
	result_amount = 6

/datum/chemical_reaction/food/dough
	name = "Dough"
	id = "dough"
	result = null
	required_reagents = list("water" = 10, "flour" = 15)
	result_amount = 1
	mix_message = "The ingredients form a dough."
	resulting_food_path = /obj/item/reagent_containers/food/snacks/dough

/datum/chemical_reaction/food/cookiedough
	name = "Dough"
	id = "dough"
	result = null
	required_reagents = list("milk" = 10, "flour" = 10, "sugar" = 5)
	result_amount = 1
	mix_message = "The ingredients form a dough. It smells sweet and yummy."
	resulting_food_path = /obj/item/reagent_containers/food/snacks/cookiedough

/datum/chemical_reaction/food/corn_syrup
	name = "corn_syrup"
	id = "corn_syrup"
	result = "corn_syrup"
	required_reagents = list("corn_starch" = 1, "sacid" = 1)
	result_amount = 2
	min_temp = T0C + 100
	mix_message = "The mixture forms a viscous, clear fluid!"

/datum/chemical_reaction/food/vhfcs
	name = "vhfcs"
	id = "vhfcs"
	result = "vhfcs"
	required_reagents = list("corn_syrup" = 1)
	required_catalysts = list("enzyme" = 1)
	result_amount = 1
	mix_message = "The mixture emits a sickly-sweet smell."

/datum/chemical_reaction/food/cola
	name = "cola"
	id = "cola"
	result = "cola"
	required_reagents = list("carbon" = 1, "oxygen" = 1, "water" = 1, "sugar" = 1)
	result_amount = 4
	mix_message = "The mixture begins to fizz."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/food/fake_cheese
	name = "Fake cheese"
	id = "fake_cheese"
	result = "fake_cheese"
	required_reagents = list("vomit" = 5, "milk" = 5)
	result_amount = 5
	mix_message = "The mixture curdles up."

/datum/chemical_reaction/food/fake_cheese/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message(span_notice("A faint cheese-ish smell drifts through the air..."))

/datum/chemical_reaction/food/weird_cheese
	name = "Weird cheese"
	id = "weird_cheese"
	result = null
	required_reagents = list("green_vomit" = 5, "milk" = 5)
	result_amount = 1
	mix_message = "The disgusting mixture sloughs together horribly, emitting a foul stench."
	mix_sound = 'sound/goonstation/misc/gurggle.ogg'
	resulting_food_path = /obj/item/reagent_containers/food/snacks/weirdcheesewedge

/datum/chemical_reaction/food/hydrogenated_soybeanoil
	name = "Partially hydrogenated space-soybean oil"
	id = "hydrogenated_soybeanoil"
	result = "hydrogenated_soybeanoil"
	required_reagents = list("soybeanoil" = 1, "hydrogen" = 1)
	result_amount = 2
	min_temp = T0C + 250
	mix_message = "The mixture emits a burnt, oily smell."

/datum/chemical_reaction/food/meatslurry
	name = "Meat Slurry"
	id = "meatslurry"
	result = "meatslurry"
	required_reagents = list("corn_starch" = 1, "blood" = 1)
	result_amount = 2
	mix_message = "The mixture congeals into a bloody mass."
	mix_sound = 'sound/effects/blobattack.ogg'

/datum/chemical_reaction/food/gravy
	name = "Gravy"
	id = "gravy"
	result = "gravy"
	required_reagents = list("porktonium" = 1, "corn_starch" = 1, "milk" = 1)
	result_amount = 3
	min_temp = T0C + 100
	mix_message = "The substance thickens and takes on a meaty odor."

/datum/chemical_reaction/food/enzyme
	name = "Universal enzyme"
	id = "enzyme"
	result = "enzyme"
	required_reagents = list("vomit" = 1, "sugar" = 1)
	result_amount = 2
	min_temp = T0C + 480
	mix_message = "The mixture emits a horrible smell as you heat up the contents. Luckily, enzymes don't stink."
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

/datum/chemical_reaction/food/enzyme2
	name = "Universal enzyme"
	id = "enzyme"
	result = "enzyme"
	required_reagents = list("green_vomit" = 1, "sugar" = 1)
	result_amount = 2
	min_temp = T0C + 480
	mix_message = "The mixture emits a horrible smell as you heat up the contents. Luckily, enzymes don't stink."
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

/datum/chemical_reaction/food/protein_water
	name = "Разбавление протеина водой"
	id = "protein_water"
	result = "protein_liquid"
	required_reagents = list("protein" = 1, "water" = 4)
	result_amount = 5

/datum/chemical_reaction/food/protein_milk
	name = "Разбавление протеина молоком"
	id = "protein_milk"
	result = "protein_liquid_milk"
	required_reagents = list("protein" = 1, "milk" = 4)
	result_amount = 5

/datum/chemical_reaction/food/creatine_water
	name = "Разбавление креатина"
	id = "creatine_water"
	result = "creatine_liquid"
	required_reagents = list("creatine" = 3, "water" = 2)
	result_amount = 5
