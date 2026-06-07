// MARK: .38
/obj/projectile/bullet/weakbullet2
	name = "rubber bullet"
	damage = 5
	stamina = 35
	icon_state = "bullet-r"
	ricochet_chance = 20

/obj/projectile/bullet/weakbullet2/get_ru_names()
	return list(
		NOMINATIVE = "резиновая пуля",
		GENITIVE = "резиновой пули",
		DATIVE = "резиновой пуле",
		ACCUSATIVE = "резиновую пулю",
		INSTRUMENTAL = "резиновой пулей",
		PREPOSITIONAL = "резиновой пуле",
	)

/obj/projectile/bullet/hp38
	damage = 35
	armour_penetration = -50
	ricochets_max = 0 //no ricochets for HP
	sharp = TRUE //for dismember bodypart and double bleeding

/obj/projectile/bullet/hp38/on_hit(atom/target, blocked, hit_zone)
	if(..(target, blocked))
		var/mob/living/carbon/carbon_target = target
		if(istype(carbon_target))
			carbon_target.Slowed(2 SECONDS, 2)

// MARK: .38 Finger gun
/obj/projectile/bullet/weakbullet2/invisible
	name = "invisible bullet"
	damage = 0
	weaken = 2 SECONDS
	stamina = 45
	icon_state = null
	hitsound_wall = null

/obj/projectile/bullet/weakbullet2/invisible/get_ru_names()
	return list(
		NOMINATIVE = "невидимая пуля",
		GENITIVE = "невидимой пули",
		DATIVE = "невидимой пуле",
		ACCUSATIVE = "невидимую пулю",
		INSTRUMENTAL = "невидимой пулей",
		PREPOSITIONAL = "невидимой пуле",
	)

/obj/projectile/bullet/weakbullet2/invisible/fake
	weaken = 0
	stamina = 0
	nodamage = TRUE
	log_override = TRUE

// MARK: .36
/obj/projectile/bullet/midbullet2
	damage = 25
	ricochet_chance = 10

// MARK: .257 Improvised
/obj/projectile/bullet/weakbullet3/c257

/obj/projectile/bullet/weakbullet3/c257/phosphorus/on_hit(atom/target, blocked, hit_zone)
	do_sparks(rand(1, 3), FALSE, target)
	if(..(target, blocked))
		var/mob/living/target_living = target

		if(target_living.check_eye_prot() == FLASH_PROTECTION_FLASH)	// Just a visual effect for sunglasses users.
			target_living.flash_eyes(intensity = 2, visual = TRUE)
		else
			target_living.flash_eyes(affect_silicon = TRUE)
