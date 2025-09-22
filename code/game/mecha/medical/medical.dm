/obj/mecha/medical
	turnsound = 'sound/mecha/mechmove01.ogg'

/obj/mecha/medical/New()
	..()
	trackers += new /obj/item/mecha_parts/mecha_tracking(src)
