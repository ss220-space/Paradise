// No args for restraints because robots don't have those
/mob/living/silicon/robot/incapacitated(ignore_flags)
	return lockcharge || HAS_TRAIT(src, TRAIT_INCAPACITATED) || !is_component_functioning("actuator")


/mob/living/silicon/robot/has_vision(information_only = FALSE)
	return ..(information_only) && ((stat == DEAD && information_only) || is_component_functioning("camera"))


/mob/living/silicon/robot/update_stat(reason = "none given", should_log = FALSE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		..()
		update_headlamp()
		return
	if(stat != DEAD)
		if(health <= -maxHealth) //die only once
			death()
			update_headlamp(TRUE, 0)
			return
		if(!is_component_functioning("actuator") || !is_component_functioning("power cell") || HAS_TRAIT(src, TRAIT_KNOCKEDOUT) || getOxyLoss() > maxHealth * 0.5)
			if(stat != UNCONSCIOUS)
				set_stat(UNCONSCIOUS)
				update_headlamp(TRUE, 0)
		else
			if(stat != CONSCIOUS)
				set_stat(CONSCIOUS)
				update_headlamp(FALSE, 0)
		update_icons()
	else
		if(health > 0)
			update_revive()
			var/mob/dead/observer/ghost = get_ghost()
			if(ghost)
				to_chat(ghost, "<span class='ghostalert'>Your cyborg shell has been repaired, re-enter if you want to continue!</span> (Verbs -> Ghost -> Re-enter corpse)")
				ghost << sound('sound/effects/genetics.ogg')
			add_misc_logs(src, "revived, trigger reason: [reason]")
	..()


/mob/living/silicon/robot/update_revive(updating = TRUE, defib_revive = FALSE)
	. = ..(updating)
	if(.)
		update_icons()


/mob/living/silicon/robot/on_knockedout_trait_loss(datum/source)
	. = ..()
	set_stat(CONSCIOUS) //This is a horrible hack, but silicon code forced my hand
	update_stat()

