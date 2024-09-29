/datum/element/after_attack/attack_effect_sleep
	/// How much stamina damage we deal on a successful hit against a living, non-cyborg mob.
	var/stamina_damage
	/// How long will the victim sleep.
	var/sleep_time


/datum/element/after_attack/attack_effect_sleep/Attach(datum/target, stamina_damage, sleep_time)
	. = ..()
	src.stamina_damage = stamina_damage
	src.sleep_time = sleep_time



/datum/element/after_attack/attack_effect_sleep/on_success(datum/source, mob/living/target, mob/living/user, proximity, params)
	..()

	if(!target || !user || !istype(target))
		return

	if(target.incapacitated(INC_IGNORE_RESTRAINED|INC_IGNORE_GRABBED))
		target.visible_message(
			span_danger("[user] puts [target] to sleep with [source]!"),
			span_userdanger("You suddenly feel very drowsy!"),
		)
		target.Sleeping(sleep_time)
		add_attack_logs(user, target, "put to sleep with [source]")
	target.apply_damage(stamina_damage, STAMINA)
