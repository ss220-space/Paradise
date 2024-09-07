/obj/item/seeds/terraformers_plant/wallnut
	name = "pack of wallnut seeds"
	desc = "Эти семена выростут в Стенорех."
	icon_state = "seed-watermelon"
	species = "watermelon"
	plantname = "Wallnut"
	lifespan = 50
	endurance = 40
	growthstages = 4
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_dead = "watermelon-dead"
	mutatelist = list(/obj/item/seeds/terraformers_plant/wallnut/big)
	connected_simplemob = /mob/living/simple_animal/hostile/plant/wallnut

/obj/item/seeds/terraformers_plant/wallnut/big
	name = "pack of big wallnut seeds"
	desc = "Эти семена выростут в Большой Стенорех."
	icon_state = "seed-watermelon"
	plantname = "Big wallnut"
	growthstages = 12
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_dead = "watermelon-dead"
	connected_simplemob = /mob/living/simple_animal/hostile/plant/wallnut/big

/obj/item/seeds/terraformers_plant/wallnut/lantern
	name = "pack of Jack-o'-lantern seeds"
	desc = "These seeds grow into watermelon plants."
	plantname = "Watermelon Vines"
	product = /obj/item/reagent_containers/food/snacks/grown/watermelon
	lifespan = 50
	endurance = 40
	growthstages = 4
	plantname = "Jack-o'-lantern"
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	connected_simplemob = /mob/living/simple_animal/hostile/plant/wallnut/lantern
