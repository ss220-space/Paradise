//////////////////The Monster

/mob/living/simple_animal/imp
	name = "imp"
	real_name = "imp"
	desc = "A large, menacing creature covered in armored black scales."
	speak_emote = list("cackles")
	emote_hear = list("cackles","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/mob.dmi'
	icon_state = "imp"
	icon_living = "imp"
	speed = 1
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/misc/demon_attack1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("hell")
	attacktext = "неистово терзает"
	maxHealth = 200
	health = 200
	healable = 0
	environment_smash = 1
	melee_damage_lower = 10
	melee_damage_upper = 15
	nightvision = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	var/playstyle_string = "<B><font size=3 color='red'>You are an imp,</font> a mischevious creature from hell. You are the lowest rank on the hellish totem pole  \
							Though you are not obligated to help, perhaps by aiding a higher ranking devil, you might just get a promotion.  However, you are incapable	\
							of intentionally harming a fellow devil.</B>"


/mob/living/simple_animal/imp/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 250, \
		maxbodytemp = INFINITY, \
	)

/mob/living/simple_animal/imp/Initialize(mapload)
	. = ..()
	add_movespeed_modifier(/datum/movespeed_modifier/imp_boost)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/imp_boost), 6 SECONDS)


/mob/living/simple_animal/imp/death(gibbed)
	..(1)
	playsound(get_turf(src),'sound/misc/demon_dies.ogg', 200, 1)
	visible_message("<span class='danger'>[src] screams in agony as it sublimates into a sulfurous smoke.</span>")
	ghostize()
	qdel(src)
