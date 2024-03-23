
/datum/fish
	var/fish_name = "generic fish"
	var/egg_item = /obj/item/fish_eggs
	///Path or list of paths to determine generated item. If list is passed [pickweight()] will be used to determine final item.
	///List can be associative [item = weight], otherwise every item in a list will have an equal chance to appear.
	var/fish_item = /obj/item/fish
	///Determines if the fish will attempt to breed with other types, set to `FALSE` if you want the fish to only lay eggs with its own species.
	var/crossbreeder = TRUE

/datum/fish/proc/special_interact(obj/machinery/fishtank/my_tank)
	return

/datum/fish/goldfish
	fish_name = "goldfish"
	egg_item = /obj/item/fish_eggs/goldfish
	fish_item = /obj/item/fish/goldfish

/datum/fish/glofish
	fish_name = "glofish"
	egg_item = /obj/item/fish_eggs/glofish
	fish_item = /obj/item/fish/glofish

/datum/fish/clownfish
	fish_name = "clownfish"
	egg_item = /obj/item/fish_eggs/clownfish
	fish_item = /obj/item/grown/bananapeel/clownfish

/datum/fish/shark
	fish_name = "shark"
	egg_item = /obj/item/fish_eggs/shark
	fish_item = /obj/item/fish/shark

/datum/fish/babycarp
	fish_name = "baby space carp"
	egg_item = /obj/item/fish_eggs/babycarp
	fish_item = /obj/item/fish/babycarp

/datum/fish/catfish
	fish_name = "catfish"
	egg_item = /obj/item/fish_eggs/catfish
	fish_item = /obj/item/fish/catfish

/datum/fish/catfish/special_interact(obj/machinery/fishtank/my_tank)
	if(!my_tank || !istype(my_tank))
		return
	if(my_tank.filth_level > 0 && prob(33))
		my_tank.adjust_filth_level(-0.1)

/datum/fish/salmon
	fish_name = "salmon"
	egg_item = /obj/item/fish_eggs/salmon
	fish_item = /obj/item/fish/salmon

/datum/fish/shrimp
	fish_name = "shrimp"
	egg_item = /obj/item/fish_eggs/shrimp
	fish_item = /obj/item/reagent_containers/food/snacks/shrimp
	crossbreeder = FALSE

/datum/fish/feederfish
	fish_name = "feeder fish"
	egg_item = /obj/item/fish_eggs/feederfish
	fish_item = /obj/item/reagent_containers/food/snacks/feederfish

/datum/fish/feederfish/special_interact(obj/machinery/fishtank/my_tank)
	if(!my_tank || !istype(my_tank))
		return
	if(my_tank.get_num_fish() < 2)
		return
	if(my_tank.food_level <= 5 && prob(25))
		my_tank.adjust_food_level(1)
		my_tank.kill_fish(src)

/datum/fish/electric_eel
	fish_name = "electric eel"
	egg_item = /obj/item/fish_eggs/electric_eel
	fish_item = /obj/item/fish/electric_eel
	crossbreeder = FALSE

/datum/fish/crayfish
	fish_name = "crayfish"
	egg_item = /obj/item/fish_eggs/crayfish
	fish_item = list(
		/obj/item/reagent_containers/food/snacks/crayfish_raw,
		/obj/item/reagent_containers/food/snacks/crayfish_raw_small,
	)
	crossbreeder = FALSE
