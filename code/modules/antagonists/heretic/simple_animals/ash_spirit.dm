/**
 * Player-only mob which is fast, can jaunt a short distance, and is dangerous at close range
 */
/mob/living/simple_animal/hostile/heretic_summon/ash_spirit
	name = "\improper Ash Spirit"
	real_name = "Эшель"
	gender = MALE
	desc = "Воплощение пепла, оставляющее за собой нескончаемое облако недолговечных угольков."
	icon_state = "ash_walker"
	icon_living = "ash_walker"
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_TURFS


/mob/living/simple_animal/hostile/heretic_summon/ash_spirit/get_ru_names()
	return alist(
		NOMINATIVE = "Дух Пепла",
		GENITIVE = "Духа Пепла",
		DATIVE = "Духу Пепла",
		ACCUSATIVE = "Духа Пепла",
		INSTRUMENTAL = "Духом Пепла",
		PREPOSITIONAL = "Духе Пепла",
	)


/mob/living/simple_animal/hostile/heretic_summon/ash_spirit/Initialize(mapload)
	. = ..()
	var/static/list/actions_to_add = list(
		/obj/effect/proc_holder/spell/fire_sworn,
		/obj/effect/proc_holder/spell/ethereal_jaunt/ash,
	)
	for(var/path in actions_to_add)
		AddSpell(new path)


/mob/living/simple_animal/hostile/heretic_summon/ash_spirit/Life(seconds, times_fired)
	. = ..()
	adjustBruteLoss(-3) // 3 health passively healing
