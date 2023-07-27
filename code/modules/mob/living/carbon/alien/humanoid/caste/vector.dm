#define INJECT_LARVA_COOLDOWN 10 MINUTES

/mob/living/carbon/alien/humanoid/hunter/vector
	name = "alien vector"

/mob/living/carbon/alien/humanoid/hunter/New()
	if(name == "alien vector")
		name = text("alien hunter ([rand(1, 1000)])")
	real_name = name
	..()
	AddSpell(new /obj/effect/proc_holder/spell/alien_spell/impregnate)

/obj/effect/proc_holder/spell/alien_spell/impregnate
	name = "Inject Larva"
	desc = "Impregnate your victim with Alien Larva."
	plasma_cost = 0
	base_cooldown = INJECT_LARVA_COOLDOWN

/obj/effect/proc_holder/spell/alien_spell/impregnate/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new
	T.selection_type = SPELL_SELECTION_RANGE
	T.random_target = FALSE
	T.range = 1
	T.use_turf_of_user = TRUE
	T.allowed_type = /mob/living/carbon/human
	return T

/obj/effect/proc_holder/spell/alien_spell/impregnate/valid_target(target, user)
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human = target
		if(!length(human.grabbed_by))
			return FALSE
		for(var/obj/item/grab/grab in human.grabbed_by)
			if(grab.assailant == user)
				if(!(human.is_dead()))
					return TRUE
				else
					return FALSE
	return FALSE

/obj/effect/proc_holder/spell/alien_spell/impregnate/cast(list/targets, mob/user)
	var/mob/living/carbon/human = targets[1]
	if(!human)
		to_chat(user, span_warning("No victims found"))
		revert_cast(user)
		return

	if(!do_after_once(user, 5 SECONDS, target = human))
		to_chat(user, span_danger("Oh oh!"))
		revert_cast(user)
		return

	if(!human.get_int_organ(/obj/item/organ/internal/body_egg/alien_embryo))
		new /obj/item/organ/internal/body_egg/alien_embryo(human)
		to_chat(user, span_notice("You impregnated your victim."))
		to_chat(human, span_danger("You feel something is wrong..."))
		return
	else
		to_chat(user, span_danger("Impregnation failed!"))
		return




#undef INJECT_LARVA_COOLDOWN
