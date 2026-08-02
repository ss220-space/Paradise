/obj/structure/lattice/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	return SWARMER_ACT_POSSIBLE | SWARMER_ACT_POSSIBLE_ACTION_CONSUME

/obj/structure/lattice/integrate_amount()
	return 1

// We check for cables only on catwalks so far, so having this here is fine
/obj/structure/lattice/catwalk/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	var/turf/catwalk_turf = get_turf(src)
	if(locate(/obj/structure/cable) in catwalk_turf)
		return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_ENERGY
	return SWARMER_ACT_POSSIBLE | SWARMER_ACT_POSSIBLE_ACTION_CONSUME

/obj/structure/lattice/catwalk/integrate_amount()
	return 2

/obj/structure/lattice/catwalk/fireproof/swarmer_catwalk/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_TEAM

/obj/structure/disposalpipe/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_LIVING

/obj/structure/particle_accelerator/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_ENERGY

/obj/structure/reagent_dispensers/fueltank/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_LIVING

/obj/structure/cable/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_ENERGY

/obj/structure/cryofeed/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_LIVING

/obj/structure/ladder/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_DEFAULT
