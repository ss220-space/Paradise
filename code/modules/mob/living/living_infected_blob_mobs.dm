/mob/proc/can_be_blob()
	return FALSE

/mob/living/simple_animal/can_be_blob()
	return TRUE

/mob/living/carbon/human/can_be_blob()
	if(!dna)
		return FALSE
	return !(dna.species.name in BLOB_RESTRICTED_SPECIES)

/mob/living/simple_animal/imp/can_be_blob()
	return FALSE

/mob/living/simple_animal/borer/can_be_blob()
	return FALSE

/mob/living/simple_animal/demon/can_be_blob()
	return FALSE

/mob/living/simple_animal/revenant/can_be_blob()
	return FALSE

/mob/living/simple_animal/bot/can_be_blob()
	return FALSE

/mob/living/simple_animal/spiderbot/can_be_blob()
	return FALSE

/mob/living/simple_animal/ascendant_shadowling/can_be_blob()
	return FALSE

/mob/living/simple_animal/mouse/clockwork/can_be_blob()
	return FALSE

/mob/living/simple_animal/mouse/fluff/clockwork/can_be_blob()
	return FALSE

/mob/living/simple_animal/pet/dog/corgi/borgi/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/swarmer/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/guardian/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/blob/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/morph/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/construct/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/clockwork/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/alien/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/illusion/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/asteroid/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/malf_drone/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/statue/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/retaliate/syndirat/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/skeleton/retaliate/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/poison/terror_spider/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/megafauna/ancient_robot/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/megafauna/hierophant/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/megafauna/legion/can_be_blob()
	return FALSE

/mob/living/simple_animal/hostile/megafauna/swarmer_swarm_beacon/can_be_blob()
	return FALSE
