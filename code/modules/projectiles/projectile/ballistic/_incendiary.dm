/obj/projectile/bullet/incendiary
	immolate = 4
	/// If TRUE, leaves a trail of hotspots as it flies, very very chaotic
	var/leaves_fire_trail = FALSE

/obj/projectile/bullet/incendiary/Move()
	. = ..()

	if(!leaves_fire_trail)
		return
	var/turf/location = get_turf(src)
	if(!location)
		return
	var/obj/effect/hotspot/hotspot = new /obj/effect/hotspot/fake(location)
	hotspot.temperature = 1000
	hotspot.recolor()
	location.hotspot_expose(700, 50)

/// Incendiary bullet that more closely resembles a real flamethrower sorta deal, no visible bullet, just flames.
/obj/projectile/bullet/incendiary/fire
	damage = 15
	range = 6
	alpha = 0
	pass_flags = PASSTABLE | PASSMOB
	impact_effect_type = null
	suppressed = TRUE
	damage_type = BURN
	flag = BOMB
	speed = 0.8
	immolate = 3
	leaves_fire_trail = TRUE

/obj/projectile/bullet/incendiary/fire/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/turf/location = get_turf(target)
	if(!location || location.density)
		return
	var/obj/effect/hotspot/hotspot = new /obj/effect/hotspot/fake(location)
	hotspot.temperature = 1000
	hotspot.recolor()
	location.hotspot_expose(700, 50)
