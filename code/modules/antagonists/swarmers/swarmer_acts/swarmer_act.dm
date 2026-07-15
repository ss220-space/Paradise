/**
 * # Proc that defines if an atom can be acted at all by swarmers.
 *
 * Must return one of two main flags, with possible combinations:
 * * SWARMER_ACT_POSSIBLE - if we can swarmer act this atom
 * * * SWARMER_ACT_POSSIBLE_ACTION_DAMAGE - if we should only damage the atom
 * * * SWARMER_ACT_POSSIBLE_ACTION_DISMANTLE - if we should slowly dismantle the atom
 * * * SWARMER_ACT_POSSIBLE_ACTION_CONSUME - if the atom should be immediately consumed with resources gained
 * * * SWARMER_ACT_POSSIBLE_ACTION_DESTROY - if the atom should be immediately consumed without resources gained
 *
 * * SWARMER_ACT_IMPOSSIBLE - if we can't swarmer act this atom
 * * * SWARMER_ACT_IMPOSSIBLE_REASON_ENERGY - if the reason is because it's energy related
 * * * SWARMER_ACT_IMPOSSIBLE_REASON_LIVING - if the reason is because it affects crew's survivability
 * * * SWARMER_ACT_IMPOSSIBLE_REASON_ATMOS - if the reason is because it's atmos related
 * * * SWARMER_ACT_IMPOSSIBLE_REASON_TEAM - if the reason is because the act would sabotage the team
 * * * SWARMER_ACT_IMPOSSIBLE_REASON_OVERRIDE = if action's default behaviour is completely different from original purpose
 * * * SWARMER_ACT_IMPOSSIBLE_REASON_DEFAULT - if we should just attack normally (example: ladders)
 */
/atom/proc/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	return SWARMER_ACT_POSSIBLE | SWARMER_ACT_POSSIBLE_ACTION_DAMAGE

/// Returns how many resources a swarmer gets from consuming an atom.
/// Will runtime if [SWARMER_ACT_POSSIBLE_ACTION_DAMAGE] was used in swarmer_act, and the value returned here is null.
/atom/proc/integrate_amount()
	return
