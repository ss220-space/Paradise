/mob/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_DEFAULT

/mob/living/simple_animal/hostile/swarmer/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	var/mob/living/other_swarmer = usr
	if(other_swarmer == src)
		balloon_alert(src, "нельзя чинить себя!")
		return

	balloon_alert(src, "вас чинят!")
	other_swarmer.balloon_alert(other_swarmer, "починка!")

	if(!do_after(other_swarmer, SWARMER_REPAIR_DELAY(other_swarmer), src, max_interact_count = 1))
		return

	if(!adjust_swarmer_metallic_resources(-SWARMER_REPAIR_COST))
		other_swarmer.balloon_alert(other_swarmer, "недостаточно ресурсов!")
		return

	adjustHealth(-SWARMER_REPAIR_AMOUNT(other_swarmer))
	return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_OVERRIDE
