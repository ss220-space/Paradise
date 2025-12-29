
/obj/machinery/kitchen_machine/microwave
	name = "microwave"
	desc = "Разогревает пищу с помощью СВЧ-излучения. Гарантирует, что ваша еда будет горячей снаружи и холодной внутри."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mw"
	cook_verbs = list("Нагревается", "Греется")
	recipe_type = RECIPE_MICROWAVE
	off_icon = "mw"
	on_icon = "mw1"
	broken_icon = "mwb"
	dirty_icon = "mwbloody"
	open_icon = "mw-o"
	pass_flags = PASSTABLE

/obj/machinery/kitchen_machine/microwave/get_ru_names()
	return list(
		NOMINATIVE = "микроволновка",
		GENITIVE = "микроволновки",
		DATIVE = "микроволновке",
		ACCUSATIVE = "микроволновку",
		INSTRUMENTAL = "микроволновкой",
		PREPOSITIONAL = "микроволновке"
	)

// see code/modules/food/recipes_microwave.dm for recipes

/*******************
*   Initialising
********************/

/obj/machinery/kitchen_machine/microwave/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/microwave(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()

/obj/machinery/kitchen_machine/microwave/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/microwave(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()

/obj/machinery/kitchen_machine/microwave/RefreshParts()
	var/E
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		E += M.rating
	efficiency = E
