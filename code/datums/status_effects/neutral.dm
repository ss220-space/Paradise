//entirely neutral or internal status effects go here

/datum/status_effect/crusher_damage //tracks the damage dealt to this mob by kinetic crushers
	id = "crusher_damage"
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/total_damage = 0

/datum/status_effect/syphon_mark
	id = "syphon_mark"
	duration = 50
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	on_remove_on_mob_delete = TRUE
	var/obj/item/borg/upgrade/modkit/bounty/reward_target

/datum/status_effect/syphon_mark/on_creation(mob/living/new_owner, obj/item/borg/upgrade/modkit/bounty/new_reward_target)
	. = ..()
	if(.)
		reward_target = new_reward_target

/datum/status_effect/syphon_mark/on_apply()
	if(owner.stat == DEAD)
		return FALSE
	return ..()

/datum/status_effect/syphon_mark/proc/get_kill()
	if(!QDELETED(reward_target))
		reward_target.get_kill(owner)

/datum/status_effect/syphon_mark/tick()
	if(owner.stat == DEAD)
		get_kill()
		qdel(src)

/datum/status_effect/syphon_mark/on_remove()
	get_kill()
	. = ..()

/datum/status_effect/high_five
	id = "high_five"
	duration = 50
	alert_type = null

/datum/status_effect/high_five/on_remove()
	owner.visible_message("[owner.name] не дождал[genderize_ru(owner.gender,"ся","ась","ось","ись")] ответа…")

/datum/status_effect/adaptive_learning
	id = "adaptive_learning"
	duration = 300
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	var/bonus_damage = 0


/datum/status_effect/charging
	id = "charging"
	alert_type = null

/datum/status_effect/delayed
	id = "delayed_status_effect"
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	var/prevent_signal = null
	var/datum/callback/expire_proc = null

/datum/status_effect/delayed/on_creation(mob/living/new_owner, new_duration, datum/callback/new_expire_proc, new_prevent_signal = null)
	if(!new_duration || !istype(new_expire_proc))
		qdel(src)
		return
	duration = new_duration
	expire_proc = new_expire_proc
	. = ..()
	if(new_prevent_signal)
		RegisterSignal(owner, new_prevent_signal, PROC_REF(prevent_action))
		prevent_signal = new_prevent_signal

/datum/status_effect/proc/prevent_action()
	SIGNAL_HANDLER
	qdel(src)

/datum/status_effect/delayed/on_remove()
	if(prevent_signal)
		UnregisterSignal(owner, prevent_signal)
	. = ..()

/datum/status_effect/delayed/on_timeout()
	. = ..()
	expire_proc.Invoke()
