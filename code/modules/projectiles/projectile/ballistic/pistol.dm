// MARK: 9mm
/obj/projectile/bullet/weakbullet3
	damage = 23
	ricochet_chance = 10

/obj/projectile/bullet/toxinbullet
	damage = 15
	damage_type = TOX

/obj/projectile/bullet/incendiary/firebullet
	damage = 10

/obj/projectile/bullet/armourpiercing
	damage = 18
	armour_penetration = 10

/obj/projectile/bullet/weakbullet4
	name = "rubber bullet"
	damage = 5
	stamina = 30
	icon_state = "bullet-r"
	ricochet_chance = 20

// MARK: 10mm
/obj/projectile/bullet/midbullet3
	damage = 33
	ricochet_chance = 10

/obj/projectile/bullet/midbullet3/hp
	damage = 50
	armour_penetration = -50
	ricochets_max = 0

/obj/projectile/bullet/midbullet3/hp/on_hit(atom/target, blocked, hit_zone)
	if(..(target, blocked))
		var/mob/living/M = target
		M.Slowed(2 SECONDS)

/obj/projectile/bullet/midbullet3/ap
	damage = 27
	armour_penetration = 40


/obj/projectile/bullet/midbullet3/fire
	immolate = 1

// MARK: .40 N&R
/obj/projectile/bullet/weakbullet3/fortynr
	damage = 28
	stamina = 20

/obj/projectile/bullet/weakbullet3/fortynr/get_ru_names()
	return list(
		NOMINATIVE = "пуля",
		GENITIVE = "пули",
		DATIVE = "пуле",
		ACCUSATIVE = "пулю",
		INSTRUMENTAL = "пулей",
		PREPOSITIONAL = "пуле",
	)

/obj/projectile/bullet/weakbullet4/get_ru_names()
	return list(
		NOMINATIVE = "резиновая пуля",
		GENITIVE = "резиновой пули",
		DATIVE = "резиновой пуле",
		ACCUSATIVE = "резиновую пулю",
		INSTRUMENTAL = "резиновой пулей",
		PREPOSITIONAL = "резиновой пуле",
	)

// MARK: .45
/obj/projectile/bullet/midbullet
	damage = 23
	stamina = 33 //four rounds from the c20r knocks people down

/obj/projectile/bullet/midbullet_AC2S
	damage = 23
	stamina = 40 //three rounds from the AC 2 Special knocks people down

/obj/projectile/bullet/midbullet_r
	damage = 5
	stamina = 33 //Still four rounds to knock people down
	ricochet_chance = 20

// MARK: .45 N&R
/obj/projectile/bullet/weakbullet4/c45nr
	name = "45 N&R"
	damage = 12
	stamina = 15
	ricochet_chance = 10

// MARK: .45 Colt
/obj/projectile/bullet/c45colt
	damage = 26

/obj/projectile/bullet/c45colt/hp
	damage = 35
	armour_penetration = -50

/obj/projectile/bullet/c45colt/ap
	damage = 18
	armour_penetration = 30

/obj/projectile/bullet/rubber45colt
	name = "rubber bullet"
	damage = 5
	stamina = 33
	icon_state = "bullet-r"
	ricochet_chance = 20

//MARK: 12.7x55
/obj/projectile/bullet/c12_dot_7X55
	damage = 75
	ricochet_chance = 33
	speed = 1


// MARK: .50AE
/obj/projectile/bullet/desert_eagle
	stamina = 33
	ricochet_chance = 10

// MARK: 7.62x25mm
/obj/projectile/bullet/ftt762
	name = "Fusty FMJ 7.62x25mm TT bullet"
	damage = 9
	stamina = 1
	armour_penetration = 5
	ricochet_chance = 10

/obj/projectile/bullet/ftt762/get_ru_names()
	return list(
		NOMINATIVE = "старая пуля FMJ 7,62x25 мм TT",
		GENITIVE = "старой пули FMJ 7,62x25 мм TT",
		DATIVE = "старой пуле FMJ 7,62x25 мм TT",
		ACCUSATIVE = "старую пулю FMJ 7,62x25 мм TT",
		INSTRUMENTAL = "старой пулей FMJ 7,62x25 мм TT",
		PREPOSITIONAL = "старой пуле FMJ 7,62x25 мм TT",
	)
