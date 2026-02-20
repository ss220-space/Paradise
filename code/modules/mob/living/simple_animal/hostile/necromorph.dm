/mob/living/simple_animal/hostile/necromorph
	name = "necromorph leaper"
	desc = "Это... Человек? Почему его кости так неестественно торчат?"
	icon = 'icons\necromobs\64x64necros.dmi'
	icon_state = "leaper"
	icon_living = "leaper"
	icon_gib = "syndicate_gib"
	gender = FEMALE
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	cached_multiplicative_slowdown = 0.5
	maxHealth = 200
	health = 200
	obj_damage = 60
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "кромсает"
	speak_emote = list("шипит")
	tts_seed = "Ladyvashj"
	attack_sound = 'sound/necromobs/leaper_attack_3.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	nightvision = 10
	AI_delay_max = 0.5 SECONDS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	gold_core_spawnable = HOSTILE_SPAWN
	death_sound = 'sound/necromobs/leaper_death_1.ogg'
	deathmessage = "испускает жуткий крик тысячами голосов..."
	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/hostile/necromorph/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		heat_damage = 20, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/hostile/necromorph/brute
	name = "necromorph brute"
	desc = "Лавкрафтовское чудовище выглядещее как несколько человеческих тел, спаянных, слившихся в единое, гротескное чудовище."
	icon_state = "brute"
	icon_living = "brute"
	cached_multiplicative_slowdown = 4
	maxHealth = 800
	health = 800
	obj_damage = 60
	melee_damage_lower = 60
	melee_damage_upper = 60
	attacktext = "крушит с силой"
		attack_sound = 'sound/necromobs/brute_attack_1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	nightvision = 10
	AI_delay_max = 0.5 SECONDS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	gold_core_spawnable = HOSTILE_SPAWN
	death_sound = 'sound/necromobs/brute_death.ogg'
	deathmessage = "испускает жуткий крик тысячами голосов..."
	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/hostile/necromorph/ubermorph
	name = "ubermorph"
	desc = "Кажется или эта тварь смотрит на меня осмысленно?"
	icon_state = "brute"
	icon_state = "ubermorph"
	icon_living = "ubermorph"
	health = 3000
	maxHealth = 3000
	cached_multiplicative_slowdown = 3
	melee_damage_lower = 40
	melee_damage_upper = 40
	move_to_delay = 4
	status_flags = 0
	special_abillity = list(/obj/effect/proc_holder/spell/aoe/terror_slam)
		attack_sound = 'sound/necromobs/ubermorph_attack_1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	nightvision = 10
	AI_delay_max = 0.5 SECONDS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	gold_core_spawnable = HOSTILE_SPAWN
	death_sound = 'sound/necromobs/ubermorph_pain_5.ogg'
	deathmessage = "испускает жуткий крик тысячами голосов..."
	footstep_type = FOOTSTEP_MOB_CLAW

