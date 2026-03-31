/obj/projectile/tether
	name = "tether"
	icon_state = "tether_projectile"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	speed = 2
	damage = 15
	range = 20
	hitsound = 'sound/weapons/batonextend.ogg'
	hitsound_wall = 'sound/weapons/batonextend.ogg'
	ricochet_chance = 0

/obj/projectile/tether/proc/make_chain()
	if(!firer)
		return
	chain = Beam(firer, icon_state = "line", icon = 'icons/obj/clothing/modsuit/mod_modules.dmi', time = 10 SECONDS, maxdistance = 15)

/obj/projectile/tether/on_hit(atom/target)
	. = ..()
	if(!firer || !isliving(firer))
		return
	var/mob/living/living_firer = firer
	living_firer.apply_status_effect(STATUS_EFFECT_IMPACT_IMMUNE)
	living_firer.throw_at(target, 15, 1, living_firer, FALSE, FALSE, callback = CALLBACK(living_firer, TYPE_PROC_REF(/mob/living, remove_status_effect), STATUS_EFFECT_IMPACT_IMMUNE))

/obj/projectile/tether/Destroy()
	QDEL_NULL(chain)
	return ..()
