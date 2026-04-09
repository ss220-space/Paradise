// MARK: Dart
/obj/projectile/bullet/dart
	name = "dart"
	icon_state = "cbbolt"
	damage = 6
	ricochets_max = 0
	var/volume = 50
	var/piercing = FALSE

/obj/projectile/bullet/dart/get_ru_names()
	return list(
		NOMINATIVE = "дротик",
		GENITIVE = "дротика",
		DATIVE = "дротику",
		ACCUSATIVE = "дротик",
		INSTRUMENTAL = "дротиком",
		PREPOSITIONAL = "дротике",
	)

/obj/projectile/bullet/dart/New()
	..()
	create_reagents(volume)
	reagents.set_reacting(FALSE)

/obj/projectile/bullet/dart/on_hit(atom/target, blocked = 0, hit_zone)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		if(blocked != 100)
			if(M.can_inject(null, FALSE, hit_zone, piercing)) // Pass the hit zone to see if it can inject by whether it hit the head or the body.
				..()
				reagents.reaction(M, REAGENT_INGEST)
				reagents.trans_to(M, reagents.total_volume)
				return TRUE
			else
				blocked = 100
				target.visible_message(span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] рикошетит!"), \
									span_userdanger("Ваша защита отражает[declent_ru(ACCUSATIVE)]!"))
	..(target, blocked, hit_zone)
	reagents.set_reacting(TRUE)
	reagents.handle_reactions()
	return TRUE

// MARK: Metal foam
/obj/projectile/bullet/dart/metalfoam

/obj/projectile/bullet/dart/metalfoam/New()
	..()
	reagents.add_reagent("aluminum", 15)
	reagents.add_reagent("fluorosurfactant", 5)
	reagents.add_reagent("sacid", 5)

// MARK: Syring dart
/obj/projectile/bullet/dart/syringe
	name = "syringe"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "syringeproj"
	volume = 15

/obj/projectile/bullet/dart/syringe/get_ru_names()
	return list(
		NOMINATIVE = "шприц",
		GENITIVE = "шприца",
		DATIVE = "шприцу",
		ACCUSATIVE = "шприц",
		INSTRUMENTAL = "шприцем",
		PREPOSITIONAL = "шприце",
	)

/obj/projectile/bullet/dart/syringe/tranquilizer

/obj/projectile/bullet/dart/syringe/tranquilizer/New()
	..()
	reagents.add_reagent("haloperidol", 15)
