/datum/element/ammo_alarm
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY | ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/alarm_sound

/datum/element/ammo_alarm/Attach(datum/target, alarm_sound)
	. = ..()
	if(!isgun(target))
		return ELEMENT_INCOMPATIBLE

	src.alarm_sound = alarm_sound
	RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, PROC_REF(afterattack))
	return

/datum/element/ammo_alarm/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ITEM_AFTERATTACK, PROC_REF(afterattack))

/datum/element/ammo_alarm/proc/afterattack(obj/item/gun/source)
	SIGNAL_HANDLER
	if(source.chambered)
		REMOVE_TRAIT(source, TRAIT_AMMO_ALARMED, UNIQUE_TRAIT_SOURCE(src))
		return

	if(HAS_TRAIT(source, TRAIT_AMMO_ALARMED))
		return

	playsound(source.loc, alarm_sound, 40, TRUE)
	source.update_icon()
	ADD_TRAIT(source, TRAIT_AMMO_ALARMED, UNIQUE_TRAIT_SOURCE(src))
