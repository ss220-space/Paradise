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
	RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, PROC_REF(afterattack))
	RegisterSignal(target, COMSIG_PARENT_ATTACKBY, PROC_REF(attack_by))
	return

/datum/element/ammo_alarm/proc/afterattack(obj/item/gun/source)
	SIGNAL_HANDLER
	to_chat(world, source.chambered)
	to_chat(world, alarmed)
	if(!source.chambered && !alarmed)
		playsound(source.loc, alarm_sound, 40, TRUE)
		source.update_icon()
		alarmed = TRUE

/datum/element/ammo_alarm/proc/attack_by(obj/item/attacker, obj/item/gun/source)
	SIGNAL_HANDLER

	if(istype(source, /obj/item/gun/energy/specter) && is_spectercell(attacker))
		alarmed = FALSE
	if(istype(source, /obj/item/gun/projectile/automatic) && istype(attacker, /obj/item/ammo_box/magazine))
		alarmed = FALSE
	return

