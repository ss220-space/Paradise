/mob/living/carbon/human/Logout()
	..()
	if(mind && mind.active && stat != DEAD)
		add_overlay(image('icons/effects/effects.dmi', icon_state = "zzz_glow"))
