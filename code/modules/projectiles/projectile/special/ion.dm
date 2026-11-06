/obj/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/ion
	flag = "energy"
	hitsound = 'sound/weapons/tap.ogg'
	/// Heavy emp range
	var/heavy_emp_range = 0
	/// Light emp range
	var/light_emp_range = 1
	/// Chance of a heavy emp happening, if distance to an atom is equal to heavy range
	var/equal_to_heavy_distance_emp_chance = 100

/obj/projectile/ion/get_ru_names()
	return alist(
		NOMINATIVE = "ионный заряд",
		GENITIVE = "ионного заряда",
		DATIVE = "ионному заряду",
		ACCUSATIVE = "ионный заряд",
		INSTRUMENTAL = "ионным зарядом",
		PREPOSITIONAL = "ионном заряде",
	)

/obj/projectile/ion/on_hit(atom/target, blocked = 0)
	. = ..()
	empulse(target, heavy_emp_range, light_emp_range, 1, cause = "[type] fired by [key_name(firer)]", heavy_emp_chance = equal_to_heavy_distance_emp_chance)
	return TRUE

/obj/projectile/ion/weak
	light_emp_range = 0
	equal_to_heavy_distance_emp_chance = 50
