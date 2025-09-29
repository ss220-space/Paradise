/datum/element/ammo_alarm
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY | ELEMENT_BESPOKE

	argument_hash_start_idx = 2

	var/alarm_sound

	var/alarmed = FALSE

/datum/element/ammo_alarm/Attach(datum/target, alarm_sound)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	src.alarm_sound = alarm_sound
	RegisterSignal(target, COMSIG_ITEM_REGISTER_AFTERATTACK, PROC_REF(afterattack))
	return

/datum/element/ammo_alarm/proc/afterattack(obj/item/gun/source)
	SIGNAL_HANDLER
	to_chat(world, source.chambered)
	to_chat(world, alarmed)
	if(!source.chambered && !alarmed)
		playsound(source.loc, alarm_sound, 40, TRUE)
		source.update_icon()
		alarmed = TRUE
