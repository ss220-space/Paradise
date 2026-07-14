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


/obj/effect/proc_holder/spell/shapeshift/eldritch/Shapeshift(mob/living/caster)
	..()
	var/mob/living/shape = caster.loc
	if(!istype(shape) || !(shape in current_shapes))
		return null

	RegisterSignal(shape, COMSIG_MOB_DEATH, PROC_REF(on_death))

	if(LAZYIN(caster.mob_spell_list, src))
		LAZYREMOVE(caster.mob_spell_list, src)
		shape.AddSpell(src)

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
	var/mob/living/simple_animal/animal
	for(var/mob/living/simple_animal/candidate in shape)
		if(candidate in current_casters)
			animal = candidate
			break

	if(animal)
		LAZYREMOVE(shape.mob_spell_list, src)

	. = ..()

	if(!QDELETED(animal))
		animal.shouldwakeup = old_shouldwakeup
		if(!LAZYIN(animal.mob_spell_list, src))
			animal.AddSpell(src)
