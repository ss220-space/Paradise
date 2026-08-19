/obj/projectile/bullet/ancient_robot_bullet
	damage = 8
	kinetic_force = 210

/obj/projectile/bullet/rock
	name = "thrown rock"
	damage = 25
	kinetic_force = 1300
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small1"

/obj/projectile/bullet/rock/get_ru_names()
	return alist(
		NOMINATIVE = "брошенный камень",
		GENITIVE = "брошенного камня",
		DATIVE = "брошенному камню",
		ACCUSATIVE = "брошенный камень",
		INSTRUMENTAL = "брошенным камнем",
		PREPOSITIONAL = "брошенном камне",
	)
