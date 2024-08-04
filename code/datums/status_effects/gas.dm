/datum/status_effect/freon
	id = "frozen"
	duration = 10 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/freon
	var/icon/cube
	var/ice_state = "ice_cube"
	var/can_melt = TRUE

/atom/movable/screen/alert/status_effect/freon
	name = "Frozen Solid"
	desc = "You're frozen inside an ice cube, and cannot move! You can still do stuff, like shooting. Resist out of the cube!"
	icon_state = "frozen"

/datum/status_effect/freon/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_RESIST, PROC_REF(owner_resist))
	RegisterSignal(owner, COMSIG_CARBON_APPLY_OVERLAY, PROC_REF(update_overlay))
	if(!owner.stat)
		to_chat(owner, "<span class='userdanger'>You become frozen in a cube!</span>")
	cube = icon('icons/effects/freeze.dmi', ice_state)
	update_overlay()
	owner.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/freon/tick(seconds_between_ticks)
	if(can_melt && owner.bodytemperature >= BODYTEMP_NORMAL)
		qdel(src)

/datum/status_effect/freon/proc/update_overlay()
	if(!owner)
		return
	owner.cut_overlay(cube)
	owner.add_overlay(cube)

/datum/status_effect/freon/proc/owner_resist()
	to_chat(owner, "You start breaking out of the ice cube!")
	if(do_after(owner, 4 SECONDS, owner, NONE))
		if(!QDELETED(src))
			to_chat(owner, "You break out of the ice cube!")
			qdel(src)

/datum/status_effect/freon/on_remove()
	if(!owner.stat)
		to_chat(owner, "The cube melts!")
	owner.cut_overlay(cube)
	owner.adjust_bodytemperature(100)
	UnregisterSignal(owner, list(COMSIG_CARBON_APPLY_OVERLAY, COMSIG_LIVING_RESIST))
	owner.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), TRAIT_STATUS_EFFECT(id))


/datum/status_effect/freon/watcher
	duration = 1.5 SECONDS
	can_melt = FALSE
