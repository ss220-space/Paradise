/datum/action/cooldown/spell/shapeshift/eldritch
	name = "Метаморфоза" // 177013 :)
	desc = "Заклинание, позволяющее вам принять облик другого существа, приобретая его способности. \
			Сделав выбор, вы больше не сможете принимать другую форму."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
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


/datum/action/cooldown/spell/shapeshift/eldritch/do_shapeshift(mob/living/caster)
	var/mob/living/shape = ..()
	if(!shape)
		return shape

	if(LAZYIN(caster.mob_spell_list, src))
		LAZYREMOVE(caster.mob_spell_list, src)
		shape.AddSpell(src)

	if(is_simple_animal(caster))
		var/mob/living/simple_animal/animal = caster
		animal.toggle_ai(AI_OFF)
		old_shouldwakeup = animal.shouldwakeup
		animal.shouldwakeup = FALSE

	return shape


/datum/action/cooldown/spell/shapeshift/eldritch/do_unshapeshift(mob/living/caster)
	LAZYREMOVE(caster.mob_spell_list, src)

	var/mob/living/unshifted = ..()
	if(QDELETED(unshifted))
		return unshifted

	if(is_simple_animal(unshifted))
		var/mob/living/simple_animal/animal = unshifted
		animal.shouldwakeup = old_shouldwakeup

	if(!LAZYIN(unshifted.mob_spell_list, src))
		unshifted.AddSpell(src)

	return unshifted
