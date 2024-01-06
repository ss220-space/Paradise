
/mob/living/simple_animal/hostile/evil_pine
	name = "Giant pine"
	desc = "A very angry and big pine. Doesn't look like it wants to be Xmas tree..."
	icon = 'icons/mob/evil_pine.dmi'
	icon_state = "evil_pine"

	health = 120
	maxHealth = 120
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	robust_searching = 1
	armour_penetration = 10
	melee_damage_lower = 12
	melee_damage_upper = 28
	move_to_delay = 6
	del_on_death = TRUE
	universal_speak = TRUE
	loot = list(/obj/structure/flora/tree/pine/xmas,
				/obj/item/reagent_containers/food/snacks/gingercookie/ball,
				/obj/item/reagent_containers/food/snacks/gingercookie/ball,
				/obj/item/reagent_containers/food/snacks/gingercookie/ball,
				/obj/item/toy/pet_rock/naughty_coal,
				/obj/item/toy/pet_rock/naughty_coal,
				/obj/item/pizzabox/mushroom,
				)
	deathmessage = "Grrrrraaaaa!"
	death_sound = 'sound/misc/demon_dies.ogg'

	faction = list("hostile", "winter")
	weather_immunities = list("snow")

	speak = list("Your head will be my new ornament!", "I HATE HOLYDAYS!", "I WILL SMASH YOU!")
	speak_chance = 20
	turns_per_move = 1
	turns_since_move = 0
