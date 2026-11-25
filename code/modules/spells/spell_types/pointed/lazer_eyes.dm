/datum/action/cooldown/spell/pointed/projectile/lasereyes
	name = "Лазеры из глаз"
	desc = "Выстрел лазерами из глаз."
	spell_requirements = NONE
	cooldown_time = 1 SECONDS
	button_icon_state = "lazer_hulk"
	sound = 'sound/weapons/taser2.ogg'
	projectile_type = /obj/projectile/beam/laser/eyes
	unset_after_click = FALSE

/datum/action/cooldown/spell/pointed/projectile/lasereyes/Grant(mob/grant_to)
	. = ..()
	ADD_TRAIT(grant_to, TRAIT_LASEREYES, UNIQUE_TRAIT_SOURCE(src))

/datum/action/cooldown/spell/pointed/projectile/lasereyes/Remove(mob/living/remove_from)
	. = ..()
	REMOVE_TRAIT(remove_from, TRAIT_LASEREYES, UNIQUE_TRAIT_SOURCE(src))
