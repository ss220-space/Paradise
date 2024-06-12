/mob/living/carbon/human/Login()
	if(player_logged)
		cut_overlay(image('icons/effects/effects.dmi', icon_state = "zzz_glow"))
	..()
	regenerate_icons()
	return
