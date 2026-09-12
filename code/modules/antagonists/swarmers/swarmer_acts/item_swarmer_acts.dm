
// Whether we actually consume it or not is handled based on integrate_amount separately
/obj/item/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	return SWARMER_ACT_POSSIBLE | SWARMER_ACT_POSSIBLE_ACTION_CONSUME

/obj/item/integrate_amount()
	if(!length(materials))
		return 0
	if(length(materials) && !materials[MAT_BIOMASS])
		return 1

/obj/item/deactivated_swarmer/integrate_amount()
	return 100

/obj/item/gun/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	return SWARMER_ACT_POSSIBLE | SWARMER_ACT_POSSIBLE_ACTION_DAMAGE
