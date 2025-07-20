/**
 * Player-only mob which is fast, can jaunt a short distance, and is dangerous at close range
 */
/mob/living/simple_animal/hostile/heretic_summon/ash_spirit
	name = "Дух Пепла"
	ru_names = list(
		NOMINATIVE = "Дух Пепла",
		GENITIVE = "Духа Пепла",
		DATIVE = "Духу Пепла",
		ACCUSATIVE = "Духа Пепла",
		INSTRUMENTAL = "Духом Пепла",
		PREPOSITIONAL = "Духе Пепла",
	)
	real_name = "Эшель"
	gender = MALE
	desc = "Живое облако пепла."
	icon_state = "ash_walker"
	icon_living = "ash_walker"
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_TURFS

/mob/living/simple_animal/hostile/heretic_summon/ash_spirit/Initialize(mapload)
	. = ..()
	var/static/list/actions_to_add = list(
		/obj/effect/proc_holder/spell/fire_sworn,
		/obj/effect/proc_holder/spell/ethereal_jaunt/ash,
		/obj/effect/proc_holder/spell/pointed/cleave,
	)
	grant_actions_by_list(actions_to_add)
