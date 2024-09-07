/obj/item/seeds/terraformers_plant/pea_shooter
	name = "pack of pea shooter seeds"
	desc = "Эти семена выростут в Горохострел"
	icon_state = "seed-apple"
	species = "apple"
	plantname = "Pea shooter"
	product = /obj/item/reagent_containers/food/snacks/grown/apple
	lifespan = 55
	endurance = 35
	yield = 0
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "apple-grow"
	icon_dead = "apple-dead"
	mutatelist = list(/obj/item/seeds/terraformers_plant/pea_shooter/double, /obj/item/seeds/terraformers_plant/pea_shooter/frost)
	connected_simplemob = /mob/living/simple_animal/hostile/plant/pea_shooter

/obj/item/seeds/terraformers_plant/pea_shooter/double
	name = "pack of double pea shooter seeds"
	desc = "Эти семена выростут в Улучшенный Горохострел"
	plantname = "Double pea shooter"
	growthstages = 15
	mutatelist = list(/obj/item/seeds/terraformers_plant/pea_shooter/ultra)
	connected_simplemob = /mob/living/simple_animal/hostile/plant/pea_shooter/double

/obj/item/seeds/terraformers_plant/pea_shooter/ultra
	name = "pack of pea machine gun seeds"
	desc = "Эти семена выростут в Горохомет"
	plantname = "Pea machine gun"
	growthstages = 30
	mutatelist = list()
	connected_simplemob = /mob/living/simple_animal/hostile/plant/pea_shooter/ultra

/obj/item/seeds/terraformers_plant/pea_shooter/frost
	name = "pack of frost pea shooter seeds"
	desc = "Эти семена выростут в Морозный Горохострел"
	plantname = "Prost pea shooter"
	growthstages = 15
	mutatelist = list()
	connected_simplemob = /mob/living/simple_animal/hostile/plant/pea_shooter/frost
