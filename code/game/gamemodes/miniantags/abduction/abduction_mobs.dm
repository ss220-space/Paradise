/mob/living/simple_animal/hostile/abductor
	name = "Abductor Agent"
	desc = "Мезафлорп?"
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "abductor"
	icon_living = "abductor"
	turns_per_move = 5
	response_help = "pokes the"
	response_disarm = "shoves the"
	response_harm = "hits the"
	speed = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "бьёт"
	attack_sound = 'sound/weapons/egloves.ogg'
	unsuitable_atmos_damage = 15
	faction = list("syndicate")
	check_friendly_fire = TRUE
	loot = list(/obj/effect/gibspawner/human)
	del_on_death = TRUE
	sentience_type = SENTIENCE_OTHER
	footstep_type = FOOTSTEP_MOB_SHOE
	AI_delay_max = 0 SECONDS

/mob/living/simple_animal/hostile/abductor/get_ru_names()
	return alist(
		NOMINATIVE = "агент-абдуктор",
		GENITIVE = "агента-абдуктора",
		DATIVE = "агенту-абдуктору",
		ACCUSATIVE = "агента-абдуктора",
		INSTRUMENTAL = "агентом-абдуктором",
		PREPOSITIONAL = "агенте-абдукторе",
	)

/mob/living/simple_animal/hostile/abductor/ranged
	icon_state = "abductor_ranged"
	icon_living = "abductor_ranged"
	melee_damage_lower = 10
	melee_damage_upper = 10
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5
	ranged_cooldown_time = 5 SECONDS
	projectilesound = 'sound/weapons/laser.ogg'
	casingtype = /obj/item/ammo_casing/energy/laser
