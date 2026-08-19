// MARK: 9mm
/obj/projectile/bullet/weakbullet3
	damage = 23
	ricochet_chance = 10
	kinetic_force = 390
	armour_penetration = 22

/obj/projectile/bullet/toxinbullet
	damage = 15
	armour_penetration = 10
	kinetic_force = 270

/obj/projectile/bullet/incendiary/firebullet
	damage = 10
	armour_penetration = 10
	kinetic_force = 270

/obj/projectile/bullet/armourpiercing
	damage = 20
	armour_penetration = 41
	kinetic_force = 390

/obj/projectile/bullet/weakbullet4
	name = "rubber bullet"
	damage = 5
	icon_state = "bullet-r"
	ricochet_chance = 20
	kinetic_force = 690
	armour_penetration = -100
	softness = 90

// MARK: 10mm
/obj/projectile/bullet/midbullet3
	damage = 33
	ricochet_chance = 10
	kinetic_force = 450
	armour_penetration = 30

/obj/projectile/bullet/midbullet3/hp
	damage = 33
	armour_penetration = 16
	ricochets_max = 0
	softness = 50
	kinetic_force = 360

/obj/projectile/bullet/midbullet3/hp/on_hit(atom/target, blocked, hit_zone)
	. = ..(target, blocked, hit_zone)
	if(blocked >= 100)
		return
	var/mob/living/target_mob = target
	target_mob.Slowed(2 SECONDS, 2)

/obj/projectile/bullet/midbullet3/ap
	damage = 27
	armour_penetration = 40


/obj/projectile/bullet/midbullet3/fire
	immolate = 1

// MARK: .40 N&R
/obj/projectile/bullet/weakbullet3/fortynr
	damage = 24
	armour_penetration = 30
	kinetic_force = 520
	softness = 20

/obj/projectile/bullet/weakbullet3/fortynr/get_ru_names()
	return alist(
		NOMINATIVE = "пуля",
		GENITIVE = "пули",
		DATIVE = "пуле",
		ACCUSATIVE = "пулю",
		INSTRUMENTAL = "пулей",
		PREPOSITIONAL = "пуле",
	)

/obj/projectile/bullet/weakbullet4/get_ru_names()
	return alist(
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
	armour_penetration = 30
	kinetic_force = 690
	softness = 40

/obj/projectile/bullet/midbullet_AC2S
	damage = 23
	armour_penetration = 45
	kinetic_force = 880
	softness = 40

/obj/projectile/bullet/midbullet_r
	damage = 5
	armour_penetration = -100
	kinetic_force = 880
	softness = 90
	ricochet_chance = 20

// MARK: .45 N&R
/obj/projectile/bullet/weakbullet4/c45nr
	name = "45 N&R"
	damage = 15
	softness = 60
	kinetic_force = 370
	ricochet_chance = 10

// MARK: .45 Colt
/obj/projectile/bullet/c45colt
	damage = 26
	armour_penetration = 32
	kinetic_force = 530

/obj/projectile/bullet/c45colt/hp
	damage = 26
	armour_penetration = 10
	softness = 40
	kinetic_force = 400

/obj/projectile/bullet/c45colt/ap
	damage = 20
	armour_penetration = 40
	kinetic_force = 530

/obj/projectile/bullet/rubber45colt
	name = "rubber bullet"
	damage = 5
	softness = 90
	kinetic_force = 780
	armour_penetration = -100
	icon_state = "bullet-r"
	ricochet_chance = 20

//MARK: 12.7x55
/obj/projectile/bullet/c12_dot_7X55
	damage = 75
	kinetic_force = 1630
	armour_penetration = 40
	ricochet_chance = 33
	speed = 1


// MARK: .50AE
/obj/projectile/bullet/desert_eagle
	kinetic_force = 1420
	armour_penetration = 34
	softness = 20
	ricochet_chance = 10

// MARK: 7.62x25mm
/obj/projectile/bullet/ftt762
	name = "Fusty FMJ 7.62x25mm TT bullet"
	damage = 9
	kinetic_force = 170
	softness = 10
	armour_penetration = 15
	ricochet_chance = 10

/obj/projectile/bullet/ftt762/get_ru_names()
	return alist(
		NOMINATIVE = "старая пуля FMJ 7,62x25 мм TT",
		GENITIVE = "старой пули FMJ 7,62x25 мм TT",
		DATIVE = "старой пуле FMJ 7,62x25 мм TT",
		ACCUSATIVE = "старую пулю FMJ 7,62x25 мм TT",
		INSTRUMENTAL = "старой пулей FMJ 7,62x25 мм TT",
		PREPOSITIONAL = "старой пуле FMJ 7,62x25 мм TT",
	)
