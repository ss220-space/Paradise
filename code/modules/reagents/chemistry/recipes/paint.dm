/datum/chemical_reaction/paint_red
	name = "Red paint"
	id = "paint_red"
	result = /datum/reagent/paint/red
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/iron = 1, /datum/reagent/oxygen = 1)
	result_amount = 3

/datum/chemical_reaction/paint_green
	name = "Green paint"
	id = "paint_green"
	result = /datum/reagent/paint/green
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/chromium = 1, /datum/reagent/oxygen = 1)
	result_amount = 3

/datum/chemical_reaction/paint_blue
	name = "Blue paint"
	id = "paint_blue"
	result = /datum/reagent/paint/blue
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/copper = 1, /datum/reagent/silicon = 1)
	result_amount = 3

/datum/chemical_reaction/paint_yellow
	name = "Yellow paint"
	id = "paint_yellow"
	result = /datum/reagent/paint/yellow
	required_reagents = list(/datum/reagent/paint/red = 1, /datum/reagent/paint/green = 1)
	result_amount = 2

/datum/chemical_reaction/paint_violet
	name = "Violet paint"
	id = "paint_violet"
	result = /datum/reagent/paint/violet
	required_reagents = list(/datum/reagent/paint/red = 1, /datum/reagent/paint/blue = 1)
	result_amount = 2

/datum/chemical_reaction/paint_green_alt
	name = "Green paint from paints"
	id = "paint_green_alt"
	result = /datum/reagent/paint/green
	required_reagents = list(/datum/reagent/paint/blue = 1, /datum/reagent/paint/yellow = 1)
	result_amount = 2

/datum/chemical_reaction/paint_black
	name = "Black paint"
	id = "paint_black"
	result = /datum/reagent/paint/black
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/medicine/charcoal = 1)
	result_amount = 2

/datum/chemical_reaction/paint_remover
	name = "Paint remover"
	id = "paint_remover"
	result = /datum/reagent/paint_remover
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/consumable/ethanol = 2)
	result_amount = 3

/datum/chemical_reaction/paint_remover_vodka
	name = "Paint remover vodka"
	id = "paint_remover"
	result = /datum/reagent/paint_remover
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/consumable/ethanol/vodka = 2)
	result_amount = 3
