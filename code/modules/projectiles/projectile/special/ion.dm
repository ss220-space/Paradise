/obj/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	var/emp_range = 1
	impact_effect_type = /obj/effect/temp_visual/impact_effect/ion
	flag = "energy"
	hitsound = 'sound/weapons/tap.ogg'

/obj/projectile/ion/get_ru_names()
	return list(
		NOMINATIVE = "ионный заряд",
		GENITIVE = "ионного заряда",
		DATIVE = "ионному заряду",
		ACCUSATIVE = "ионный заряд",
		INSTRUMENTAL = "ионным зарядом",
		PREPOSITIONAL = "ионном заряде",
	)

/obj/projectile/ion/on_hit(atom/target, blocked = 0)
	. = ..()
	empulse(target, emp_range, emp_range, 1, cause = "[type] fired by [key_name(firer)]")
	return 1

/obj/projectile/ion/weak

/obj/projectile/ion/weak/on_hit(atom/target, blocked = 0)
	emp_range = 0
	. = ..()
	return 1
