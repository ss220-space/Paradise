/**
 * Player-only mob which is fast, can jaunt a short distance, and is dangerous at close range
 */
/mob/living/simple_animal/hostile/heretic_summon/ash_spirit
	name = "Дух Пепла"
	real_name = "Эшель"
	gender = MALE
	desc = "Живое облако пепла."
	icon_state = "ash_walker"
	icon_living = "ash_walker"
	maxHealth = 150
	health = 150
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_TURFS


/mob/living/simple_animal/hostile/heretic_summon/ash_spirit/get_ru_names()
	return list(
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
		/obj/effect/proc_holder/spell/pointed/cleave,
	)
	for(var/path in actions_to_add)
		AddSpell(new path)
