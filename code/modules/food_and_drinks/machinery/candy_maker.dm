
/obj/machinery/kitchen_machine/candy_maker
	name = "candy machine"
	desc = "Мощный смеситель, предназначенный для производства кондитерских изделий. Настоящий кошмар дантиста и лучший друг диабета."
	icon = 'icons/obj/machines/cooking_machines.dmi'
	icon_state = "candymaker_off"
	cook_verbs = list("Wonderizing", "Scrumpdiddlyumptiousification", "Miracle-coating", "Flavorifaction")
	recipe_type = RECIPE_CANDY
	off_icon = "candymaker_off"
	on_icon = "candymaker_on"
	broken_icon = "candymaker_broke"
	dirty_icon = "candymaker_dirty"
	open_icon = "candymaker_open"

/obj/machinery/kitchen_machine/candy_maker/get_ru_names()
	return list(
		NOMINATIVE = "конфетный автомат",
		GENITIVE = "конфетного автомата",
		DATIVE = "конфетному автомату",
		ACCUSATIVE = "конфетный автомат",
		INSTRUMENTAL = "конфетным автоматом",
		PREPOSITIONAL = "конфетном автомате"
	)

// see code/modules/food/recipes_candy.dm for recipes

/*******************
*   Initialising
********************/

/obj/machinery/kitchen_machine/candy_maker/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/candy_maker(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/kitchen_machine/candy_maker/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/candy_maker(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/kitchen_machine/candy_maker/RefreshParts()
	var/E
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		E += M.rating
	efficiency = E
