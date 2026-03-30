/datum/status_effect/freon
	id = "frozen"
	duration = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/freon
	var/icon/cube
	var/ice_state = "ice_cube"
	var/can_melt = TRUE

/atom/movable/screen/alert/status_effect/freon
	name = "Заморожен намертво"
	desc = "Вы заморожены внутри ледяного куба и не можете двигаться! Вы всё ещё можете делать что-то, например, стрелять. Сопротивляйтесь, чтобы выбраться из куба!"
	icon_state = "frozen"

/datum/status_effect/freon/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_RESIST, PROC_REF(owner_resist))
	RegisterSignal(owner, COMSIG_CARBON_APPLY_OVERLAY, PROC_REF(update_overlay))
	if(!owner.stat)
		to_chat(owner, span_danger("Вы замерзаете в ледяном кубе!"))
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
	to_chat(owner, "Вы начинаете вырываться из ледяного куба!")
	if(do_after(owner, 4 SECONDS, owner, NONE))
		if(!QDELETED(src))
			to_chat(owner, "Вы вырываетесь из ледяного куба!")
			qdel(src)

/datum/status_effect/freon/on_remove()
	if(!owner.stat)
		to_chat(owner, "Ледяной куб тает!")
	owner.cut_overlay(cube)
	owner.adjust_bodytemperature(100)
	UnregisterSignal(owner, list(COMSIG_CARBON_APPLY_OVERLAY, COMSIG_LIVING_RESIST))
	owner.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), TRAIT_STATUS_EFFECT(id))

/datum/status_effect/freon/watcher
	duration = 1.5 SECONDS
	can_melt = FALSE

/datum/status_effect/hypernob_protection
	id = "hypernob_protection"
	duration = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/hypernob_protection

/datum/status_effect/hypernob_protection/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/atom/movable/screen/alert/status_effect/hypernob_protection
	name = "Hyper-Noblium Protection"
	desc = "The Hyper-Noblium around your body is protecting it from self-combustion and fires, but you feel sluggish..."
	icon_state = "hypernob_protection"

/datum/status_effect/hypernob_protection/on_apply()
	if(!ishuman(owner))
		CRASH("[type] status effect added to non-human owner: [owner ? owner.type : "null owner"]")
	var/mob/living/carbon/human/human_owner = owner
	human_owner.add_movespeed_modifier(/datum/movespeed_modifier/reagent/hypernoblium) //small slowdown as a tradeoff
	ADD_TRAIT(human_owner, TRAIT_NO_FIRE, TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/hypernob_protection/on_remove()
	if(!ishuman(owner))
		stack_trace("[type] status effect being removed from non-human owner: [owner ? owner.type : "null owner"]")
	var/mob/living/carbon/human/human_owner = owner
	human_owner.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/hypernoblium)
	REMOVE_TRAIT(human_owner, TRAIT_NO_FIRE, TRAIT_STATUS_EFFECT(id))
