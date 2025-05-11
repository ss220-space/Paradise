/obj/item/grenade/smokebomb
	desc = "It is set to detonate in 2 seconds."
	name = "smoke bomb"
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "smokebomb"
	det_time = 2 SECONDS
	item_state = "flashbang"
	slot_flags = ITEM_SLOT_BELT
	var/datum/effect_system/fluid_spread/smoke/bad/smoke

/obj/item/grenade/smokebomb/New()
	..()
	smoke = new
	smoke.attach(src)

/obj/item/grenade/smokebomb/Destroy()
	QDEL_NULL(smoke)
	return ..()

/obj/item/grenade/smokebomb/prime()
	. = ..()
	playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
	smoke.set_up(amount = 10, location = loc)
	spawn(0)
		smoke.start()
		sleep(10)
		smoke.start()
		sleep(10)
		smoke.start()
		sleep(10)
		smoke.start()

	for(var/obj/structure/blob/B in view(8,src))
		var/damage = round(30/(get_dist(B,src)+1))
		B.take_damage(damage, BURN, "melee", 0)
	sleep(80)
	qdel(src)
	return
