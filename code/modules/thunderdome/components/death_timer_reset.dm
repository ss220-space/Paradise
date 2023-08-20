/*
*	death_timer_reset: component designed for resetting time of death for ghosts when they
*	spawn for short-temp role such as Thunderdome player
*
*	Side effects: ghostizing from dead body even without gibbing, inability to enter it again.
*
*/

/datum/component/death_timer_reset
	var/death_time_before

/datum/component/death_timer_reset/Initialize(death_time)
	death_time_before = death_time
	RegisterSignal(parent, list(COMSIG_MOB_DEATH), PROC_REF(reset_death_time))

/**
 * A bit of a trick with ghostizing dead without possibility to return to left body.
 */
/datum/component/death_timer_reset/proc/reset_death_time()
	var/mob/living/L = parent
	var/mob/dead/observer/ghost = L.ghostize()
	if(ghost)
		ghost.can_reenter_corpse = FALSE
		ghost.timeofdeath = death_time_before
		//message_admins("time of death for [ghost.ckey] has been successfully reset to [death_time_before]") //debug message
	UnregisterSignal(parent, list(COMSIG_MOB_DEATH))

