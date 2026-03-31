// MARK: 5.56x45mm
/obj/projectile/bullet/heavybullet
	damage = 36

// MARK: 4.6x30mm
/obj/projectile/bullet/weakbullet3/foursix
	damage = 15

/obj/projectile/bullet/weakbullet3/foursix/ap
	damage = 12
	armour_penetration = 40

/obj/projectile/bullet/weakbullet3/foursix/tox
	damage = 10
	damage_type = TOX
	armour_penetration = 10

/obj/projectile/bullet/incendiary/foursix
	damage = 10
	armour_penetration = 10

// MARK: 5.45x39mm - Fusty
/obj/projectile/bullet/f545
	name = "Fusty FMJ 5.45 bullet"
	damage = 20
	stamina = 6

/obj/projectile/bullet/f545/get_ru_names()
	return list(
		NOMINATIVE = "старая пуля FMJ 5,45x39 мм",
		GENITIVE = "старой пули FMJ 5,45x39 мм",
		DATIVE = "старой пуле FMJ 5,45x39 мм",
		ACCUSATIVE = "старую пулю FMJ 5,45x39 мм",
		INSTRUMENTAL = "старой пулей FMJ 5,45x39 мм",
		PREPOSITIONAL = "старой пуле FMJ 5,45x39 мм",
	)
