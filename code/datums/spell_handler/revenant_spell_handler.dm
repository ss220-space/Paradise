/datum/spell_handler/revenant
	var/essence_cost
	/// How long it reveals the revenant in deciseconds
	var/reveal = 8 SECONDS
	/// How long it stuns the revenant in deciseconds
	var/stun = 2 SECONDS

/datum/spell_handler/revenant/New(cost = 0)
	essence_cost = cost

/datum/spell_handler/revenant/can_cast(mob/user, show_message, datum/action/cooldown/spell/spell)
	if(!istype(user, /mob/living/simple_animal/revenant))
		return FALSE
	var/mob/living/simple_animal/revenant/caster = user
	if(caster.castcheck(essence_cost, show_message, FALSE))
		return TRUE
	return FALSE

/datum/spell_handler/revenant/before_cast(list/targets, mob/user, datum/action/cooldown/spell/spell)
	var/mob/living/simple_animal/revenant/caster = user
	if(caster.castcheck(-essence_cost, TRUE))
		return TRUE
	return FALSE

/datum/spell_handler/revenant/after_cast(list/targets, mob/user, datum/action/cooldown/spell/spell)
	. = ..()
	var/mob/living/simple_animal/revenant/caster = user
	caster.reveal(reveal)
	caster.stun(stun)
