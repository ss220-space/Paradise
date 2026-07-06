// Given to heretic monsters.
/obj/effect/proc_holder/spell/shapeshift/eldritch
	name = "Метаморфоза" // 177013 :)
	desc = "Заклинание, позволяющее вам принять облик другого существа, приобретая его способности. \
			Сделав выбор, вы больше не сможете принимать другую форму."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"

	school = SCHOOL_FORBIDDEN
	invocation = "М'Т'М'РФ'З"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	possible_shapes = list(
		/mob/living/simple_animal/hostile/carp,
		/mob/living/simple_animal/mouse,
		/mob/living/simple_animal/pet/cat,
		/mob/living/simple_animal/pet/dog/corgi,
		/mob/living/simple_animal/pet/dog/fox,
		/mob/living/simple_animal/bot/secbot,
	)

	/// Stored AI-wake flag of the simple_animal caster (e.g. the Flesh Stalker) parked inside our borrowed form.
	var/old_shouldwakeup


// Restores two pieces the base shapeshift lacks, scoped to the heretic only:
//   1. a COMSIG_MOB_DEATH revert - without it, a summon that died in its borrowed animal form stayed dead
//      (the caster was left trapped, godmoded and mindless, inside the corpse).
//   2. silencing the parked simple_animal caster's AI so it doesn't wake up and wander while mindless.
// Returns the created shape so subtypes (the lock ascension) can read it from `.`.
/obj/effect/proc_holder/spell/shapeshift/eldritch/Shapeshift(mob/living/caster)
	..()
	var/mob/living/shape = caster.loc
	if(!istype(shape) || !(shape in current_shapes))
		return null

	RegisterSignal(shape, COMSIG_MOB_DEATH, PROC_REF(on_death))

	if(is_simple_animal(caster))
		var/mob/living/simple_animal/animal = caster
		animal.toggle_ai(AI_OFF)
		old_shouldwakeup = animal.shouldwakeup
		animal.shouldwakeup = FALSE

	return shape


/obj/effect/proc_holder/spell/shapeshift/eldritch/proc/on_death(mob/living/source)
	SIGNAL_HANDLER
	Restore(source)


/obj/effect/proc_holder/spell/shapeshift/eldritch/Restore(mob/living/shape)
	// Grab the parked caster before the base proc pulls it back out and qdels the shape.
	var/mob/living/simple_animal/animal
	for(var/mob/living/simple_animal/candidate in shape)
		if(candidate in current_casters)
			animal = candidate
			break

	. = ..()

	if(!QDELETED(animal))
		animal.shouldwakeup = old_shouldwakeup
