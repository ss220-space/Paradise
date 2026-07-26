/mob/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_DEFAULT

/mob/living/simple_animal/hostile/swarmer/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	if(user == src)
		return SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_RIGHT_CLICK_DEFAULT

	. = SWARMER_ACT_IMPOSSIBLE | SWARMER_ACT_IMPOSSIBLE_REASON_OVERRIDE
	balloon_alert(src, "вас чинят!")
	user.balloon_alert(user, "починка!")

	if(!do_after(user, SWARMER_REPAIR_DELAY(user), src, max_interact_count = 1))
		return

	if(!adjust_swarmer_metallic_resources(-SWARMER_REPAIR_COST))
		user.balloon_alert(user, "недостаточно ресурсов!")
		return

	adjustHealth(-SWARMER_REPAIR_AMOUNT(user))
