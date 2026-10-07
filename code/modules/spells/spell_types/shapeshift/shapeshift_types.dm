
/datum/action/cooldown/spell/shapeshift/dragon
	name = "Dragon Form"
	desc = "Take on the shape a lesser ash drake after a short delay."
	invocation = "*scream"
	invocation_type = INVOCATION_SHOUT
	possible_shapes = list(/mob/living/simple_animal/hostile/megafauna/dragon/lesser)
	revert_on_death = FALSE

/datum/action/cooldown/spell/shapeshift/dragon/do_shapeshift(mob/living/caster)
	caster.visible_message(
		span_danger("[caster] screams in agony as bones and claws erupt out of their flesh!"),
		span_danger("You begin channeling the transformation.")
	)
	if(!do_after(caster, 5 SECONDS, caster, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM))
		to_chat(caster, span_warning("You lose concentration of the spell!"))
		return
	return ..()

/datum/action/cooldown/spell/shapeshift/dragon/do_unshapeshift(mob/living/caster)
	var/mob/living/simple_animal/hostile/megafauna/dragon/lesser/dragon = caster
	if(dragon.swooping)
		return
	return ..()

/datum/action/cooldown/spell/shapeshift/bats
	name = "Bat Form"
	desc = "Take on the shape of a swarm of bats."
	button_icon_state = "vampire_bats"
	possible_shapes = list(/mob/living/simple_animal/hostile/scarybat/batswarm)

/datum/action/cooldown/spell/shapeshift/bats/Grant(mob/grant_to)
	. = ..()
	to_chat(grant_to, span_notice("You have gained the ability to shapeshift into bat form. This is a weak form with no abilities, only useful for stealth."))

/datum/action/cooldown/spell/shapeshift/hellhound
	name = "Lesser Hellhound Form"
	desc = "Take on the shape of a Hellhound."
	background_icon_state = "bg_demon"
	button_icon_state = "glare"
	possible_shapes = list(/mob/living/simple_animal/hostile/hellhound)

/datum/action/cooldown/spell/shapeshift/hellhound/Grant(mob/grant_to)
	. = ..()
	to_chat(grant_to, span_notice("You have gained the ability to shapeshift into lesser hellhound form. This is a combat form with different abilities, tough but not invincible. It can regenerate itself over time by resting."))

/datum/action/cooldown/spell/shapeshift/hellhound/greater
	name = "Greater Hellhound Form"
	possible_shapes = list(/mob/living/simple_animal/hostile/hellhound/greater)

