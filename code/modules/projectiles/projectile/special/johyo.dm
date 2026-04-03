/obj/projectile/johyo
	name = "Jōhyō"
	icon_state = "kunai"
	icon = 'icons/obj/ninjaobjects.dmi'
	damage = 5
	armour_penetration = 100
	hitsound = 'sound/weapons/whip.ogg'
	knockdown = 2 SECONDS

/obj/projectile/johyo/fire(setAngle)
	if(firer)
		firer.say(pick("Get over here!", "Come here!"))
		chain = firer.Beam(src, icon_state = "chain_dark", time = INFINITY, maxdistance = INFINITY)
	. = ..()

/obj/projectile/johyo/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/target_living = target
		var/turf/firer_turf = get_turf(firer)
		if(!target_living.anchored && target_living.loc)
			target_living.visible_message(span_danger("[target_living.declent_ru(NOMINATIVE)] зацепля[PLUR_ET_YUT(target_living)]ся за цепь [firer.declent_ru(GENITIVE)]!"))

			ADD_TRAIT(target_living, TRAIT_UNDENSE, UNIQUE_TRAIT_SOURCE(src))	// Ensures the hook does not hit the target multiple times
			target_living.forceMove(firer_turf)
			REMOVE_TRAIT(target_living, TRAIT_UNDENSE, UNIQUE_TRAIT_SOURCE(src))

/obj/projectile/johyo/Destroy()
	QDEL_NULL(chain)
	return ..()
