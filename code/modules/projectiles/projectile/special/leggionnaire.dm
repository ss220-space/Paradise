/obj/projectile/legionnaire
	name = "bone"
	icon = 'icons/obj/mining.dmi'
	icon_state = "bone"
	damage = 25
	armour_penetration = 70
	speed = 1.2

/obj/projectile/legionnaire/get_ru_names()
	return list(
		NOMINATIVE = "кость",
		GENITIVE = "кости",
		DATIVE = "кости",
		ACCUSATIVE = "кость",
		INSTRUMENTAL = "костью",
		PREPOSITIONAL = "кости",
	)
