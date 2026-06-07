/obj/projectile/energy/declone
	name = "declone"
	icon_state = "declone"
	damage = 20
	hitsound = 'sound/weapons/plasma_cutter.ogg'
	damage_type = CLONE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	/// The chance to be irradiated on hit
	var/radiation_chance = 30

/obj/projectile/energy/declone/get_ru_names()
	return list(
		NOMINATIVE = "деклонер",
		GENITIVE = "деклонера",
		DATIVE = "деклонеру",
		ACCUSATIVE = "деклонер",
		INSTRUMENTAL = "деклонером",
		PREPOSITIONAL = "деклонере",
	)

/obj/projectile/energy/declone/on_hit(atom/target, blocked, hit_zone)
	if(ishuman(target) && prob(radiation_chance))
		radiation_pulse(target, max_range = 0, threshold = RAD_FULL_INSULATION)

	return ..()
