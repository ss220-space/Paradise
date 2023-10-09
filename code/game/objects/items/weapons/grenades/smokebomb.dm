/obj/item/grenade/smokebomb
	desc = "It is set to detonate in 2 seconds."
	name = "smoke bomb"
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "flashbang"
	det_time = 20
	item_state = "flashbang"
	slot_flags = SLOT_BELT

/obj/item/grenade/smokebomb/Initialize(mapload)
	. = ..()

/obj/item/grenade/smokebomb/prime()
	playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
	var/datum/effect_system/fluid_spread/smoke/bad/smoke = new
	smoke.set_up(5, holder = src, location = src)
	smoke.start()
	for(var/obj/structure/blob/B in view(8,src))
		var/damage = round(30/(get_dist(B,src)+1))
		B.take_damage(damage, BURN, "melee", 0)
	sleep(80)
	qdel(src)
	return
