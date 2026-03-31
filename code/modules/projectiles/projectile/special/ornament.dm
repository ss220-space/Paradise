// Some Santa mode shit, I guess
/obj/projectile/ornament
	name = "ornament"
	icon_state = "ornament-1"
	hitsound = 'sound/effects/glasshit.ogg'
	damage = 7

/obj/projectile/ornament/get_ru_names()
	return list(
		NOMINATIVE = "орнамент",
		GENITIVE = "орнамента",
		DATIVE = "орнаменту",
		ACCUSATIVE = "орнамент",
		INSTRUMENTAL = "орнаментом",
		PREPOSITIONAL = "орнаменте",
	)

/obj/projectile/ornament/New()
	icon_state = pick("ornament-1", "ornament-2")
	..()

/obj/projectile/ornament/on_hit(atom/target)	//knockback
	..()
	if(!ismob(target))
		return 0
	var/obj/T = target
	var/throwdir = get_dir(firer,target)
	T.throw_at(get_edge_target_turf(target, throwdir),5,5) // 10,10 tooooo much
	return 1
