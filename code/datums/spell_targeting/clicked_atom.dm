/**
 * A simple spell targeting system. Will return the clicked atom as a target. Only works for 1 target max and is basically a dumbed down [/datum/spell_targeting/click]
 */
/datum/spell_targeting/clicked_atom
	use_intercept_click = TRUE

/datum/spell_targeting/clicked_atom/choose_targets(mob/user, obj/effect/proc_holder/spell/spell, params, atom/clicked_atom)
	if(clicked_atom)
		click_params = params
		return list(clicked_atom)
	else
		return null

/**
 * Like [/datum/spell_targeting/clicked_atom], but only returns the clicked atom if the spell considers it a
 * valid target (spell.valid_target). This lets a pointed spell reject a misclick (empty space / scenery)
 * BEFORE perform() runs - so no invocation, sound, or cooldown is spent. And because try_perform() bails on
 * empty targets before removing the click interceptor, the ability stays armed for an immediate retry.
 */
/datum/spell_targeting/clicked_atom/validated/choose_targets(mob/user, obj/effect/proc_holder/spell/spell, params, atom/clicked_atom)
	if(clicked_atom && spell.valid_target(clicked_atom, user))
		click_params = params
		return list(clicked_atom)
	return null

