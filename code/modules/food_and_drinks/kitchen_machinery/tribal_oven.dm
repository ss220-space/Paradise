/obj/machinery/kitchen_machine/tribal_oven
	name = "stone oven"
	desc = "Огромная примитивная каменная печь, используемая для приготовления пищи."
	ru_names = list(
		NOMINATIVE = "каменная печь",
		GENITIVE = "каменной печи",
		DATIVE = "каменной печи",
		ACCUSATIVE = "каменную печь",
		INSTRUMENTAL = "каменной печью",
		PREPOSITIONAL = "каменной печи"
	)
	gender = FEMALE
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "oven_off"
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	recipe_type = RECIPE_TRIBAL_OVEN
	off_icon = "oven_off"
	on_icon = "oven_on"
	can_be_dirty = FALSE
	can_broke = FALSE
	efficiency = 1 //we don't have parts, soo
	transfer_reagents_from_ingredients = FALSE

/obj/machinery/kitchen_machine/tribal_oven/screwdriver_act()
	return FALSE

/obj/machinery/kitchen_machine/tribal_oven/wrench_act()
	return FALSE

/obj/machinery/kitchen_machine/crowbar_act()
	return FALSE
