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
	turns_per_move = 5
	butcher_results = list(/obj/item/reagent_containers/food/snacks/carpmeat = 2)
	response_help = "pets"
	emote_taunt = list("gnashes")
	taunt_chance = 30
	maxHealth = 125
	health = 125
	harm_intent_damage = 3
	obj_damage = 50
	melee_damage_lower = 15
	melee_damage_upper = 20
	attack_sound = 'sound/weapons/bite.ogg'
	attacktext = "кусает"
	speak_emote = list("gnashes")
	unique_pet = TRUE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	faction = list("carp")
	pressure_resistance = 200
	gold_core_spawnable = HOSTILE_SPAWN
	AI_delay_max = 0.5 SECONDS
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/luu/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_HEALS_FROM_CARP_RIFTS, INNATE_TRAIT)
	AddElement(/datum/element/simple_flying)

