/obj/mecha/medical
	turnsound = 'sound/mecha/mechmove01.ogg'
	allowed_equipment = MECH_EQUIPMENT_MEDICAL

/obj/mecha/medical/Initialize(mapload)
	. = ..()
	trackers += new /obj/item/mecha_parts/mecha_tracking(src)
