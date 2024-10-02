/mob/living/carbon/human/update_stat(reason = "none given", should_log = FALSE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return ..()
	..()
	if(stat == DEAD)
		if(dna.species && dna.species.can_revive_by_healing)
			var/obj/item/organ/internal/brain/B = get_int_organ(/obj/item/organ/internal/brain)
			if(B)
				if((health >= (HEALTH_THRESHOLD_DEAD + HEALTH_THRESHOLD_CRIT) * 0.5) && getBrainLoss() < 120)
					update_revive()


/mob/living/carbon/human/update_nearsighted_effects()
	var/obj/item/clothing/glasses/our_glasses = glasses
	if(HAS_TRAIT(src, TRAIT_NEARSIGHTED) && (!istype(our_glasses) || !our_glasses.prescription))
		overlay_fullscreen("nearsighted", /atom/movable/screen/fullscreen/impaired, 1)
	else
		clear_fullscreen("nearsighted")


/mob/living/carbon/human/can_hear()
	if(dna?.species)
		return dna.species.can_hear(src)
	return ..() // Fallback if we don't have a species or DNA


/mob/living/carbon/human/has_vision(information_only = FALSE)
	if(dna?.species)
		return dna.species.has_vision(src, information_only)
	return ..()


/mob/living/carbon/human/check_death_method()
	return dna.species.dies_at_threshold
