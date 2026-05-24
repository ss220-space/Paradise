/datum/chemical_reaction/paint_red
	name = "Red paint"
	id = "paint_red"
	result = "paint_red"
	required_reagents = list("water" = 1, "iron" = 1, "oxygen" = 1)
	result_amount = 3

/datum/chemical_reaction/paint_green
	name = "Green paint"
	id = "paint_green"
	result = "paint_green"
	required_reagents = list("water" = 1, "chromium" = 1, "oxygen" = 1)
	result_amount = 3

/datum/chemical_reaction/paint_blue
	name = "Blue paint"
	id = "paint_blue"
	result = "paint_blue"
	required_reagents = list("water" = 1, "copper" = 1, "silicon" = 1)
	result_amount = 3

/datum/chemical_reaction/paint_yellow
	name = "Yellow paint"
	id = "paint_yellow"
	result = "paint_yellow"
	required_reagents = list("paint_red" = 1, "paint_green" = 1)
	result_amount = 2

/datum/chemical_reaction/paint_violet
	name = "Violet paint"
	id = "paint_violet"
	result = "paint_violet"
	required_reagents = list("paint_red" = 1, "paint_blue" = 1)
	result_amount = 2

/datum/chemical_reaction/paint_green_alt
	name = "Green paint from paints"
	id = "paint_green_alt"
	result = "paint_green"
	required_reagents = list("paint_blue" = 1, "paint_yellow" = 1)
	result_amount = 2

/datum/chemical_reaction/paint_black
	name = "Black paint"
	id = "paint_black"
	result = "paint_black"
	required_reagents = list("water" = 1, "charcoal" = 1)
	result_amount = 2

/datum/chemical_reaction/paint_remover
	name = "Paint remover"
	id = "paint_remover"
	result = "paint_remover"
	required_reagents = list("water" = 1, "ethanol" = 2)
	result_amount = 3

/datum/chemical_reaction/paint_remover_vodka
	name = "Paint remover vodka"
	id = "paint_remover"
	result = "paint_remover"
	required_reagents = list("water" = 1, "vodka" = 2)
	result_amount = 3
