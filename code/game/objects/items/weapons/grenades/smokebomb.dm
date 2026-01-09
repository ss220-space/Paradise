/obj/item/grenade/smokebomb
	name = "smoke bomb"
	desc = "Взрывчатое устройство, предназначенное для ручного подрыва. При детонации испускает дым, \
			создающий дымовую завесу."
	icon_state = "smokebomb"
	det_time = 2 SECONDS
	var/datum/effect_system/fluid_spread/smoke/bad/smoke

/obj/item/grenade/smokebomb/get_ru_names()
	return list(
		NOMINATIVE = "дымовая граната",
		GENITIVE = "дымовой гранаты",
		DATIVE = "дымовой гранате",
		ACCUSATIVE = "дымовую гранату",
		INSTRUMENTAL = "дымовой гранатой",
		PREPOSITIONAL = "дымовой гранате"
	)

/obj/item/grenade/smokebomb/New()
	..()
	smoke = new
	smoke.attach(src)

/obj/item/grenade/smokebomb/Destroy()
	QDEL_NULL(smoke)
	return ..()

/obj/item/grenade/smokebomb/prime()
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(start_smoke))

/obj/item/grenade/smokebomb/proc/start_smoke()
	playsound(src.loc, 'sound/effects/smoke.ogg', 50, TRUE, -3)
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
		B.take_damage(damage, BURN, MELEE, 0)
	sleep(80)
	qdel(src)
	return
