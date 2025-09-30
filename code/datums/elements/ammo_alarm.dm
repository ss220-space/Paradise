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
	RegisterSignal(target, COMSIG_PARENT_ATTACKBY, PROC_REF(attack_by))
	return

/datum/element/ammo_alarm/proc/afterattack(obj/item/gun/source)
	SIGNAL_HANDLER
	if(!source.chambered && HAS_TRAIT(source, TRAIT_AMMO_ALARMED))
		playsound(source.loc, alarm_sound, 40, TRUE)
		source.update_icon()
		REMOVE_TRAIT(source, TRAIT_AMMO_ALARMED, UNIQUE_TRAIT_SOURCE)

/datum/element/ammo_alarm/proc/attack_by(obj/item/attacker, obj/item/gun/source)
	SIGNAL_HANDLER

	if(istype(source, /obj/item/gun/energy/specter) && is_spectercell(attacker))
		ADD_TRAIT(source, TRAIT_AMMO_ALARMED, UNIQUE_TRAIT_SOURCE)
	if(istype(source, /obj/item/gun/projectile/automatic) && istype(attacker, /obj/item/ammo_box/magazine))
		ADD_TRAIT(source, TRAIT_AMMO_ALARMED, UNIQUE_TRAIT_SOURCE)
	return

