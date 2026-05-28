/obj/projectile/hook
	name = "hook"
	icon_state = "hook"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	damage = 25
	armour_penetration = 100
	hitsound = 'sound/effects/splat.ogg'
	weaken = 2 SECONDS
	ricochet_chance = 0

/obj/projectile/hook/get_ru_names()
	return list(
		NOMINATIVE = "крюк",
		GENITIVE = "крюка",
		DATIVE = "крюку",
		ACCUSATIVE = "крюк",
		INSTRUMENTAL = "крюком",
		PREPOSITIONAL = "крюке",
	)

/obj/projectile/hook/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_RICOCHET, INNATE_TRAIT)

/obj/projectile/hook/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "chain", time = INFINITY, maxdistance = INFINITY)
	..()
	//TODO: root the firer until the chain returns

/obj/projectile/hook/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		var/turf/firer_turf = get_turf(firer)
		var/mob/living/L = target
		if(!L.anchored && L.loc)
			L.visible_message(span_danger("[firer] зацепля[PLUR_ET_YUT(firer)] [L.declent_ru(ACCUSATIVE)] [declent_ru(INSTRUMENTAL)]!"))
			ADD_TRAIT(L, TRAIT_UNDENSE, UNIQUE_TRAIT_SOURCE(src)) // Ensures the hook does not hit the target multiple times
			L.forceMove(firer_turf)
			REMOVE_TRAIT(L, TRAIT_UNDENSE, UNIQUE_TRAIT_SOURCE(src))

/obj/projectile/hook/Destroy()
	QDEL_NULL(chain)
	return ..()
