/datum/component/attack_effect_sleep
	var/stamina_damage
	var/sleep_time


/datum/component/attack_effect_sleep/Initialize(stamina_damage, sleep_time)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.stamina_damage = stamina_damage
	src.sleep_time = sleep_time
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SUCCESS, PROC_REF(on_attack_success))

/datum/component/attack_effect_sleep/Destroy(force)
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SUCCESS)
	. = ..()


/datum/component/attack_effect_sleep/proc/on_attack_success(datum/source, mob/living/target, mob/living/user, params, def_zone)
	SIGNAL_HANDLER

	if(!target || !user || !istype(target))
		return

	if(target.incapacitated(INC_IGNORE_RESTRAINED|INC_IGNORE_GRABBED))
		target.visible_message(
			span_danger("[user] puts [target] to sleep with [parent]!"),
			span_userdanger("You suddenly feel very drowsy!"),
		)
		target.Sleeping(sleep_time)
		add_attack_logs(user, target, "put to sleep with [parent]")
	target.apply_damage(stamina_damage, STAMINA)
