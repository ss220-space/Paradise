// MARK: Alpha
/obj/projectile/energy/floraalpha
	name = "alpha somatoray"
	icon_state = "declone"
	damage = 2
	range = 7
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	/// how strong the fire will be
	var/fire_stacks = 0.3

/obj/projectile/energy/floraalpha/get_ru_names()
	return list(
		NOMINATIVE = "альфа-соматорей",
		GENITIVE = "альфа-соматорея",
		DATIVE = "альфа-соматорею",
		ACCUSATIVE = "альфа-соматорей",
		INSTRUMENTAL = "альфа-соматореем",
		PREPOSITIONAL = "альфа-соматорее",
	)

/obj/projectile/energy/floraalpha/prehit(atom/target)
	if(target && !HAS_TRAIT(target, TRAIT_PLANT_ORIGIN)) // burn damage for only plant
		damage = 0
	. = ..()

/obj/projectile/energy/floraalpha/on_range()
	strike_thing()
	. = ..()

/obj/projectile/energy/floraalpha/on_hit(atom/target, blocked = 0, hit_zone)
	strike_thing(target)
	. = ..()

/obj/projectile/energy/floraalpha/proc/strike_thing(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		target_turf = get_turf(src)
	new /obj/effect/temp_visual/pka_explosion/florawave(target_turf)
	for(var/currentTurf in RANGE_TURFS(1, target_turf))
		for(var/object in currentTurf)
			if(isdiona(object))
				var/mob/living/plant = object
				if(!plant.on_fire) // the hit has no effect if the target is on fire
					plant.adjust_fire_stacks(fire_stacks)
					plant.IgniteMob()
			else if(is_type_in_list(object, list(/obj/structure/glowshroom, /obj/structure/spacevine)))
				if(prob(5))
					new /obj/effect/decal/cleanable/molten_object(get_turf(object))
				else
					new /obj/effect/temp_visual/removing_flora(get_turf(object))
				qdel(object)

/obj/projectile/energy/floraalpha/emag
	range = 9
	damage = 15
	fire_stacks = 10

// MARK: Beta
/obj/projectile/energy/florabeta
	name = "beta somatoray"
	icon_state = "energy"
	damage_type = TOX
	nodamage = TRUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser

/obj/projectile/energy/florabeta/get_ru_names()
	return list(
		NOMINATIVE = "бета-соматорей",
		GENITIVE = "бета-соматорея",
		DATIVE = "бета-соматорею",
		ACCUSATIVE = "бета-соматорей",
		INSTRUMENTAL = "бета-соматореем",
		PREPOSITIONAL = "бета-соматорее",
	)

// MARK: Gamma
/obj/projectile/energy/floragamma
	name = "gamma somatoray"
	icon_state = "energy2"
	damage_type = TOX
	nodamage = TRUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser

/obj/projectile/energy/floragamma/get_ru_names()
	return list(
		NOMINATIVE = "гамма-соматорей",
		GENITIVE = "гамма-соматорея",
		DATIVE = "гамма-соматорею",
		ACCUSATIVE = "гамма-соматорей",
		INSTRUMENTAL = "гамма-соматореем",
		PREPOSITIONAL = "гамма-соматорее",
	)
