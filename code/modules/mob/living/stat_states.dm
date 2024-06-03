/mob/living/proc/can_be_revived()
	. = TRUE
	// if(health <= min_health)
	if(health <= HEALTH_THRESHOLD_DEAD)
		return FALSE

// death() is used to make a mob die

// handles revival through other means than cloning or adminbus (defib, IPC repair)
/mob/living/proc/update_revive(updating = TRUE, force = FALSE)
	if(stat != DEAD)
		return FALSE
	if(!force && !can_be_revived())
		return FALSE
	add_attack_logs(src, null, "Came back to life", ATKLOG_ALL)
	set_stat(CONSCIOUS)
	if(mind)
		GLOB.respawnable_list -= src
	timeofdeath = null
	if(updating)
		updatehealth("update revive")
		hud_used?.reload_fullscreen()

	SEND_SIGNAL(src, COMSIG_LIVING_REVIVE, updating)
	for(var/s in ownedSoullinks)
		var/datum/soullink/S = s
		S.ownerRevives(src)
	for(var/s in sharedSoullinks)
		var/datum/soullink/S = s
		S.sharerRevives(src)

	if(mind)
		for(var/obj/effect/proc_holder/spell/spell as anything in mind.spell_list)
			spell.updateButtonIcon()

	return TRUE

/mob/living/proc/check_death_method()
	return TRUE
