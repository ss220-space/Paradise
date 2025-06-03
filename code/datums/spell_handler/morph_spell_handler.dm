/datum/spell_handler/morph
	/// How much food it costs the morph to use this
	var/hunger_cost = 0


/datum/spell_handler/morph/can_cast(mob/living/simple_animal/hostile/morph/user, charge_check, show_message, obj/effect/proc_holder/spell/spell)
	if(!istype(user))
		if(show_message)
			to_chat(user, span_warning("Вы не должны иметь возможности использовать эту способность! Составьте баг-репорт в Discord."))
		return FALSE

	if(user.gathered_food < hunger_cost)
		if(show_message)
			to_chat(user, span_warning("Для использования этой способности вам требуется не менее [hunger_cost] единиц[declension_ru(hunger_cost,"ы","","")] запасов пищи!"))
		return FALSE

	return TRUE


/datum/spell_handler/morph/spend_spell_cost(mob/living/simple_animal/hostile/morph/user, obj/effect/proc_holder/spell/spell)
	user.use_food(hunger_cost)


/datum/spell_handler/morph/before_cast(list/targets, mob/living/simple_animal/hostile/morph/user, obj/effect/proc_holder/spell/spell)
	return


/datum/spell_handler/morph/revert_cast(mob/living/simple_animal/hostile/morph/user, obj/effect/proc_holder/spell/spell)
	user.add_food(hunger_cost)
