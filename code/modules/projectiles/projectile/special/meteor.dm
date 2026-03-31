/obj/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small"
	damage = 0
	nodamage = TRUE
	hitsound = 'sound/effects/meteorimpact.ogg'

/obj/projectile/meteor/get_ru_names()
	return list(
		NOMINATIVE = "метеор",
		GENITIVE = "метеора",
		DATIVE = "метеору",
		ACCUSATIVE = "метеор",
		INSTRUMENTAL = "метеором",
		PREPOSITIONAL = "метеоре",
	)

/obj/projectile/meteor/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	if(blocked >= 100)
		return FALSE
	for(var/mob/mob in urange(10, src))
		if(!mob.stat)
			shake_camera(mob, 3, 1)
