/mob/living/simple_animal/hostile/retaliate/luu
	name = "Майор Луу"
	real_name = "Майор Луу"
	voice_name = "неизвестный голос"
	desc = "Неудачный эксперимент Nanotrasen по созданию технологии, позволяющей использовать карпа в качестве оружия. Этот совсем не пугающий карп теперь служит домашним животным начальника службы безопасности."
	faction = list("carp")
	icon_state = "magicarp"
	icon_living = "magicarp"
	icon_dead = "magicarp_dead"
	icon_gib = "magicarp_gib"
	tts_seed = "Peon"
	turns_per_move = 8
	response_help = "pets"
	emote_hear = list("chitters")
	maxHealth = 250
	health = 250
	harm_intent_damage = 3
	melee_damage_lower = 15
	melee_damage_upper = 20
	unique_pet = TRUE
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 2, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	gender = MALE