/obj/item/grenade/smokebomb
	desc = "It is set to detonate in 2 seconds."
	name = "smoke bomb"
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "smokebomb"
	det_time = 2 SECONDS
	item_state = "flashbang"
	slot_flags = ITEM_SLOT_BELT

/obj/item/grenade/smokebomb/prime()
	. = ..()
	playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
	spawn(0)
		do_smoke(10, SMOKE_TYPE_BAD)
		sleep(10)
		do_smoke(10, SMOKE_TYPE_BAD)
		sleep(10)
		do_smoke(10, SMOKE_TYPE_BAD)
		sleep(10)
		do_smoke(10, SMOKE_TYPE_BAD)

	for(var/obj/structure/blob/B in view(8,src))
		var/damage = round(30/(get_dist(B,src)+1))
		B.take_damage(damage, BURN, "melee", 0)
	sleep(80)
	qdel(src)
	return
