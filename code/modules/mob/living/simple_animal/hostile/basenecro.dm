/mob/living/simple_animal/hostile/basenecro
	name = "necromorph"
	desc = "Чёрт возьми, это ещё что за чертовщина!? У него изо рта бежит какая-то кислота..."
	icon = 'icons/necromobs/base_necromorph.dmi'
	icon_gib = "syndicate_gib"
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	health = 100
	maxHealth = 100
	cached_multiplicative_slowdown = 3
	melee_damage_lower = 20
	melee_damage_upper = 20
	attacktext = "кромсает"
	speak_emote = list("булькает")
	tts_seed = "Ladyvashj"
	attack_sound = 'sound/necromobs/infector_attack_1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	nightvision = 10
	AI_delay_max = 0.5 SECONDS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	gold_core_spawnable = HOSTILE_SPAWN
	death_sound = 'sound/necromobs/infector_death_4.ogg'
	deathmessage = "испускает жуткий крик тысячами голосов..."
	footstep_type = FOOTSTEP_MOB_CLAW
