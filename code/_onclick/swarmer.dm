/mob/living/simple_animal/hostile/swarmer/resolve_right_click_attack(atom/target, list/modifiers)
	return target.attack_swarmer_secondary(src, modifiers)

/**
 * Called when a swarmer right clicks an atom.
 * For this to function, a swarmer_act on this atom type MUST return SWARMER_ACT_IMPOSSIBLE_REASON_DEFAULT flag.
 * Returns a SECONDARY_ATTACK_* value.
 */
/atom/proc/attack_swarmer_secondary(mob/living/simple_animal/hostile/swarmer/user, list/modifiers)
	return SECONDARY_ATTACK_CALL_NORMAL
