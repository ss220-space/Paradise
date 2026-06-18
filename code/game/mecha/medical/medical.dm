/obj/mecha/medical
	turnsound = 'sound/mecha/mechmove01.ogg'
	allowed_equipment = MECH_EQUIPMENT_MEDICAL
	system_attach_allowed = TRUE

/obj/mecha/medical/Initialize(mapload)
	. = ..()
	trackers += new /obj/item/mecha_parts/mecha_tracking(src)
