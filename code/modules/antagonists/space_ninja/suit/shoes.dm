/**
 * # Ninja Shoes
 *
 * Space ninja's shoes.  Gives him armor on his feet.
 *
 * Space ninja's ninja shoes.  How mousey.  Gives him slip protection and protection against attacks.
 * Also are temperature resistant.
 *
 */
/obj/item/clothing/shoes/space_ninja
	name = "ninja shoes"
	desc = "A pair of ninja shoes. Excellent for running, have a modified sole that makes it harder for the wearer to slip and it's light yet sturdy."
	icon = 'icons/obj/ninjaobjects.dmi'
	lefthand_file = 'icons/mob/inhands/antag/ninja_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/ninja_righthand.dmi'
	icon_state = "ninja_boots"
	item_state = "ninja_boots"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	armor = list(MELEE = 40, BULLET = 30, LASER = 20,ENERGY = 15, BOMB = 30, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT
	permeability_coefficient = 1
	strip_delay = 120
	slowdown = 0
	clothing_traits = list(TRAIT_NEGATES_GRAVITY, TRAIT_NO_SLIP_WATER)
