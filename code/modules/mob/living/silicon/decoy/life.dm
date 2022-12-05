/mob/living/silicon/decoy/Life(seconds, times_fired)
	return

/mob/living/silicon/decoy/updatehealth(reason = "none given")
	if(status_flags & GODMODE)
		return ..(reason)
	health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
	update_stat("updatehealth([reason])")

/mob/living/silicon/decoy/update_stat(reason = "none given")
	if(status_flags & GODMODE)
		return ..(reason)
	if(stat == DEAD)
		return
	if(health <= 0)
		death()
