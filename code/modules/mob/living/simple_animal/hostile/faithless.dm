/mob/living/simple_animal/hostile/faithless
	name = "faithless"
	desc = "Воплощённая в жизнь вера в человечество Исполнителя желаний."
	gender = MALE
	icon_state = "faithless"
	icon_living = "faithless"
	icon_dead = "faithless_dead"
	speak_chance = 0
	turns_per_move = 5
	response_help = "проходит мимо"
	response_disarm = "толкает"
	response_harm = "бьёт"
	speed = 0
	maxHealth = 80
	health = 80
	obj_damage = 50
	harm_intent_damage = 10
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "сжимает"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	speak_emote = list("рычит")
	emote_taunt = list("воет")
	taunt_chance = 25
	footstep_type = FOOTSTEP_MOB_SHOE

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	faction = list("faithless")
	gold_core_spawnable = HOSTILE_SPAWN
	AI_delay_max = 0 SECONDS

/mob/living/simple_animal/hostile/faithless/get_ru_names()
	return list(
		NOMINATIVE = "неверующий",
		GENITIVE = "неверующего",
		DATIVE = "неверующему",
		ACCUSATIVE = "неверующего",
		INSTRUMENTAL = "неверующим",
		PREPOSITIONAL = "неверующем"
	)

/mob/living/simple_animal/hostile/faithless/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/hostile/faithless/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE

// Is it a balance?
/mob/living/simple_animal/hostile/faithless/AttackingTarget()
	. = ..()
	if(. && iscarbon(target))
		var/mob/living/carbon/C = target
		if(prob(12))
			C.Weaken(6 SECONDS)
			C.visible_message("<span class='danger'>\The [src] knocks down \the [C]!</span>", \
					"<span class='userdanger'>\The [src] knocks you down!</span>")
