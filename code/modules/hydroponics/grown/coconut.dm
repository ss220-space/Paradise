// Coconut
/obj/item/grown/coconut
	seed = /obj/item/seeds/coconut
	name = "Coconut"
	desc = "The young coconut is still green"
	icon_state = "coconut"
	item_state = "coconut"
	force = 10
	throwforce = 10
	throw_speed = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_TINY

/obj/item/seeds/coconut
	name = "pack of coconut seeds"
	desc = "Coconut planting device"
	icon_state = "seed-coconut"
	species = "coconut"
	plantname = "Coconut Tree"
	product = /obj/item/grown/coconut
	lifespan = 79
	endurance = 59
	production = 7
	maturation = 11
	yield = 5
	potency = 69
	growthstages = 6
	weed_rate = 4
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "coconut-grow"
	icon_dead = "coconut-dead"
	genes = list(/datum/plant_gene/trait/maxchem , /datum/plant_gene/trait/repeated_harvest)
	reagents_add = list("coconut_water" = 0.45, "shredded_coconut" = 0.15)


/obj/item/reagent_containers/food/snacks/piece_coconut
	name = "Piece coconut"
	desc = "Slice of old coconut has pulp"
	icon_state = "piece_coconut"
	item_state = "piece_coconut"
	list reagents = list("shredded_coconut" = 10)
	bitesize = 1

/obj/item/reagent_containers/food/snacks/grown/dry_coco
	name = "Dried coconut"
	desc = "The old coconut is already brown"
	icon_state = "dried_coconut"
	item_state = "dried_coconut"
	list_reagents = list("shredded_coconut" = 25)
	slice_path = /obj/item/reagent_containers/food/snacks/piece_coconut
	slices_num = 2
	bitesize = 2

/obj/item/grown/coconut/add_juice()
	..()
	force = round((5 + seed.potency / 2.5), 1)
