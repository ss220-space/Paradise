// Being near space or in supermatter is handled in attack code, same with structures
/turf/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	return SWARMER_ACT_IMPOSSIBLE

/turf/simulated/wall/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	return SWARMER_ACT_POSSIBLE | SWARMER_ACT_POSSIBLE_ACTION_DAMAGE

/turf/simulated/mineral/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	return SWARMER_ACT_POSSIBLE | SWARMER_ACT_POSSIBLE_ACTION_DESTROY

// Since floors are everywhere (duh), reduce alert spam by just making it a default attack
/turf/simulated/floor/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_DEFAULT

/turf/simulated/floor/lava/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	if(!is_safe())
		new /obj/structure/lattice/catwalk/swarmer_catwalk(src)
	return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_OVERRIDE

/turf/simulated/floor/chasm/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	if(!is_safe())
		new /obj/structure/lattice/catwalk/swarmer_catwalk(src)
	return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_OVERRIDE
