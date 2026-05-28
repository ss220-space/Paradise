/obj/projectile/herald
	name = "death bolt"
	icon_state = "chronobolt"
	damage = 15
	armour_penetration = 35
	speed = 2

/obj/projectile/herald/get_ru_names()
	return list(
		NOMINATIVE = "смертоносный заряд",
		GENITIVE = "смертоносного заряда",
		DATIVE = "смертоносному заряду",
		ACCUSATIVE = "смертоносный заряд",
		INSTRUMENTAL = "смертоносным зарядом",
		PREPOSITIONAL = "смертоносном заряде",
	)

/obj/projectile/herald/teleshot
	name = "golden bolt"
	damage = 25
	color = rgb(255,255,102)

/obj/projectile/herald/teleshot/get_ru_names()
	return list(
		NOMINATIVE = "золотой заряд",
		GENITIVE = "золотого заряда",
		DATIVE = "золотому заряду",
		ACCUSATIVE = "золотой заряд",
		INSTRUMENTAL = "золотым зарядом",
		PREPOSITIONAL = "золотом заряде",
	)

/obj/projectile/herald/prehit(atom/target)
	if(ismob(target) && ismob(firer))
		var/mob/living/mob_target = target
		if(mob_target.faction_check_mob(firer))
			nodamage = TRUE
			damage = 0
			return
		if(mob_target.buckled && mob_target.stat == DEAD)
			mob_target.dust() //no body cheese

/obj/projectile/herald/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ismineralturf(target))
		var/turf/simulated/mineral/M = target
		M.attempt_drill()

/obj/projectile/herald/teleshot/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(!istype(target, /mob/living/simple_animal/hostile/asteroid/elite/herald))
		firer.forceMove(get_turf(src))
