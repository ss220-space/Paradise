/mob/living/silicon/Login()
	SetSleeping(0)
	if(mind && SSticker && SSticker.mode)
		SSticker.mode.remove_revolutionary(mind, 1)
		SSticker.mode.remove_cultist(mind, 1)
		SSticker.mode.remove_wizard(mind)
		SSticker.mode.remove_ninja(mind)
		mind.remove_antag_datum(/datum/antagonist/changeling)
		mind.remove_antag_datum(/datum/antagonist/vampire)
		mind.remove_antag_datum(/datum/antagonist/goon_vampire)
		mind.remove_antag_datum(/datum/antagonist/thief)
		SSticker.mode.remove_thrall(mind, 0)
		SSticker.mode.remove_shadowling(mind)
		SSticker.mode.remove_abductor(mind)
	..()
