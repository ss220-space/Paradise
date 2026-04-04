/obj/projectile/contractor_hook
	name = "Hardlight hook"
	icon_state = "hard_hook"
	damage = 0
	stamina = 25
	hitsound = 'sound/weapons/whip.ogg'
	weaken = 2 SECONDS
	ricochet_chance = 0
	range = 7

/obj/projectile/contractor_hook/get_ru_names()
	return list(
		NOMINATIVE = "крюк из твёрдого света",
		GENITIVE = "крюка из твёрдого света",
		DATIVE = "крюку из твёрдого света",
		ACCUSATIVE = "крюк из твёрдого света",
		INSTRUMENTAL = "крюком из твёрдого света",
		PREPOSITIONAL = "крюке из твёрдого света",
	)

/obj/projectile/contractor_hook/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "hard_chain", time = INFINITY, maxdistance = INFINITY)
	..()

/obj/projectile/contractor_hook/on_hit(atom/target, blocked = 0)
	. = ..()
	if(blocked >= 100)
		return 0
	var/turf/firer_turf = get_turf(firer)
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	if(living_target.anchored || !living_target.loc)
		return
	living_target.visible_message(span_danger("[living_target] был захвачен крюком [firer]!"))
	ADD_TRAIT(living_target, TRAIT_UNDENSE, UNIQUE_TRAIT_SOURCE(src))	// Ensures the hook does not hit the target multiple times
	living_target.forceMove(firer_turf)
	REMOVE_TRAIT(living_target, TRAIT_UNDENSE, UNIQUE_TRAIT_SOURCE(src))

/obj/projectile/contractor_hook/Destroy()
	QDEL_NULL(chain)
	return ..()
