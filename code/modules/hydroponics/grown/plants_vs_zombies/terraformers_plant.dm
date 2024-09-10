/obj/item/seeds/terraformers_plant
	name = "pack of terraformers plants"
	desc = "Эти семяна не должны были появиться в игре."
	icon_state = "seed-apple"
	species = "apple"
	plantname = "Apple Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/apple
	lifespan = 55
	endurance = 35
	yield = 0
	production = 0
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "apple-grow"
	icon_dead = "apple-dead"
	var/mob/living/simple_animal/hostile/plant/connected_simplemob = /mob/living/simple_animal/hostile/bread_monster // I believe that this will never happen.
	nogenes = TRUE
	can_harvest = FALSE

/obj/item/seeds/terraformers_plant/on_grow(obj/machinery/hydroponics/tray)
	tray.connected_simplemob = new connected_simplemob(tray.loc)
	tray.RegisterSignal(tray.connected_simplemob, COMSIG_MOB_DEATH, TYPE_PROC_REF(/obj/machinery/hydroponics, on_connected_simplemob_death))
