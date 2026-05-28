/obj/projectile/bullet/gyro
	name = "explosive bolt"
	icon_state= "bolter"
	ricochets_max = 0

/obj/projectile/bullet/gyro/get_ru_names()
	return list(
		NOMINATIVE = "разрывной заряд",
		GENITIVE = "разрывного заряда",
		DATIVE = "разрывному заряду",
		ACCUSATIVE = "разрывной заряд",
		INSTRUMENTAL = "разрывным зарядом",
		PREPOSITIONAL = "разрывном заряде",
	)

/obj/projectile/bullet/gyro/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, devastation_range = -1, heavy_impact_range = 0, light_impact_range = 2, cause = "[type] fired by [key_name(firer)]")
	return 1
