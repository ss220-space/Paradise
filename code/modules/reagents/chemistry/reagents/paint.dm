/datum/reagent/paint
	name = "Краска"
	id = "paint_"
	description = "Краска, используемая для покраски полов."
	reagent_state = LIQUID
	color = "#808080"
	taste_description = "краски"

/datum/reagent/paint/reaction_turf(turf/T, volume)
	if(!isspaceturf(T))
		T.add_atom_colour(color, WASHABLE_COLOUR_PRIORITY)

/datum/reagent/paint/reaction_obj(obj/O, volume)
	if(istype(O, /obj/item/light))
		O.add_atom_colour(color, WASHABLE_COLOUR_PRIORITY)

/datum/reagent/paint/red
	name = "Красная краска"
	id = "paint_red"
	color = "#FF0000"

/datum/reagent/paint/green
	name = "Зелёная краска"
	id = "paint_green"
	color = "#00FF00"

/datum/reagent/paint/blue
	name = "Синяя краска"
	id = "paint_blue"
	color = "#0000FF"

/datum/reagent/paint/yellow
	name = "Жёлтая краска"
	id = "paint_yellow"
	color = "#FFFF00"

/datum/reagent/paint/violet
	name = "Фиолетовая краска"
	id = "paint_violet"
	color = "#FF00FF"

/datum/reagent/paint/black
	name = "Чёрная краска"
	id = "paint_black"
	color = "#333333"

/datum/reagent/paint/white
	name = "Белая краска"
	id = "paint_white"
	color = "#FFFFFF"

/datum/reagent/paint_remover
	name = "Средство для удаления краски"
	id = "paint_remover"
	description = "Вещество, используемое для удаления краски с пола."
	reagent_state = LIQUID
	color = "#808080"
	taste_description = "спирта"

/datum/reagent/paint_remover/reaction_turf(turf/T, volume)
	if(!isspaceturf(T))
		T.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
