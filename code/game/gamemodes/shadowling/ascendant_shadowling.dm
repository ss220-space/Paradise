/mob/living/simple_animal/ascendant_shadowling
	name = "ascendant shadowling"
	desc = "A large, floating eldritch horror. It has pulsing markings all about its body and large horns. It seems to be floating without any form of support."
	icon = 'icons/mob/mob.dmi'
	icon_state = "shadowling_ascended"
	icon_living = "shadowling_ascended"
	speak = list("Azima'dox", "Mahz'kavek", "N'ildzak", "Kaz'vadosh")
	speak_emote = list("telepathically thunders", "telepathically booms")
	force_threshold = INFINITY //Can't die by normal means
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS
	health = 100000
	maxHealth = 100000
	speed = 0
	var/phasing = 0
	nightvision = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

	universal_speak = 1

	response_help   = "stares at"
	response_disarm = "flails at"
	response_harm   = "flails at"

	harm_intent_damage = 0
	melee_damage_lower = 60 //Was 35, buffed
	melee_damage_upper = 60
	attacktext = "кромсает"
	attack_sound = 'sound/weapons/slash.ogg'

	minbodytemp = 0
	maxbodytemp = INFINITY
	environment_smash = ENVIRONMENT_SMASH_RWALLS

	faction = list("faithless")


/mob/living/simple_animal/ascendant_shadowling/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/simple_flying)
	if(prob(35))
		icon_state = "NurnKal"
		icon_living = "NurnKal"
	update_icon(UPDATE_OVERLAYS)

/mob/living/simple_animal/ascendant_shadowling/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE //copypasta from carp code

/mob/living/simple_animal/ascendant_shadowling/ex_act(severity)
	return //You think an ascendant can be hurt by bombs? HA

/mob/living/simple_animal/ascendant_shadowling/singularity_act()
	return 0 //Well hi, fellow god! How are you today?


/mob/living/simple_animal/ascendant_shadowling/update_overlays()
	. = ..()
	. += "shadowling_ascended_ms"


/mob/living/simple_animal/ascendant_shadowling/proc/announce(text, size = 4, new_sound = null)
	var/message = "<font size=[size]><span class='shadowling'><b>\"[text]\"</font></span>"
	for(var/mob/M in GLOB.player_list)
		if(!isnewplayer(M) && M.client)
			to_chat(M, message)
			if(new_sound)
				M << new_sound
