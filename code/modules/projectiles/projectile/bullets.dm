/obj/projectile/bullet
	name = "bullet"
	ru_names = list(
		NOMINATIVE = "пуля",
		GENITIVE = "пули",
		DATIVE = "пуле",
		ACCUSATIVE = "пулю",
		INSTRUMENTAL = "пулей",
		PREPOSITIONAL = "пуле"
	)
	icon_state = "bullet"
	damage = 50
	damage_type = BRUTE
	flag = "bullet"
	hitsound = "bullet"
	hitsound_wall = "ricochet"
	impact_effect_type = /obj/effect/temp_visual/impact_effect

/obj/projectile/bullet/slug
	armour_penetration = 40
	damage = 30

/obj/projectile/bullet/weakbullet //beanbag, heavy stamina damage
	name = "beanbag slug"
	ru_names = list(
		NOMINATIVE = "патрон \"Погремушка\"",
		GENITIVE = "патрона \"Погремушка\"",
		DATIVE = "патрону \"Погремушка\"",
		ACCUSATIVE = "патрон \"Погремушка\"",
		INSTRUMENTAL = "патроном \"Погремушка\"",
		PREPOSITIONAL = "патроне \"Погремушка\""
	)
	damage = 5
	stamina = 55

/obj/projectile/bullet/weakbullet/booze

/obj/projectile/bullet/weakbullet/booze/on_hit(atom/target, blocked = 0)
	if(..(target, blocked))
		var/mob/living/M = target
		M.AdjustDizzy(40 SECONDS)
		M.AdjustSlur(40 SECONDS)
		M.AdjustConfused(40 SECONDS)
		M.AdjustEyeBlurry(40 SECONDS)
		M.AdjustDrowsy(40 SECONDS)
		M.AdjustDrunk(50 SECONDS)
		for(var/datum/reagent/consumable/ethanol/A in M.reagents.reagent_list)
			M.AdjustParalysis(4 SECONDS)
			M.AdjustDizzy(20 SECONDS)
			M.AdjustSlur(20 SECONDS)
			M.AdjustConfused(20 SECONDS)
			M.AdjustEyeBlurry(20 SECONDS)
			M.AdjustDrowsy(20 SECONDS)
			A.volume += 5 //Because we can

/obj/projectile/bullet/weakbullet2  //detective revolver
	name = "rubber bullet"
	ru_names = list(
		NOMINATIVE = "резиновая пуля",
		GENITIVE = "резиновой пули",
		DATIVE = "резиновой пуле",
		ACCUSATIVE = "резиновую пулю",
		INSTRUMENTAL = "резиновой пулей",
		PREPOSITIONAL = "резиновой пуле"
	)
	damage = 5
	stamina = 35
	icon_state = "bullet-r"

/obj/projectile/bullet/hp38 //Detective hollow-point
	damage = 33
	armour_penetration = -50

/obj/projectile/bullet/hp38/on_hit(atom/target, blocked, hit_zone)
	if(..(target, blocked))
		var/mob/living/M = target
		M.Slowed(2 SECONDS)

/obj/projectile/bullet/weakbullet2/invisible //finger gun bullets
	name = "invisible bullet"
	ru_names = list(
		NOMINATIVE = "невидимая пуля",
		GENITIVE = "невидимой пули",
		DATIVE = "невидимой пуле",
		ACCUSATIVE = "невидимую пулю",
		INSTRUMENTAL = "невидимой пулей",
		PREPOSITIONAL = "невидимой пуле"
	)
	damage = 0
	weaken = 2 SECONDS
	stamina = 45
	icon_state = null
	hitsound_wall = null

/obj/projectile/bullet/weakbullet2/invisible/fake
	weaken = 0
	stamina = 0
	nodamage = TRUE
	log_override = TRUE

/obj/projectile/bullet/weakbullet3
	damage = 20

/obj/projectile/bullet/weakbullet3/foursix
	damage = 15

/obj/projectile/bullet/weakbullet3/foursix/ap
	damage = 12
	armour_penetration = 40

/obj/projectile/bullet/weakbullet3/foursix/tox
	damage = 10
	damage_type = TOX
	armour_penetration = 10

/obj/projectile/bullet/weakbullet3/fortynr
	name = "bullet"
	ru_names = list(
		NOMINATIVE = "пуля",
		GENITIVE = "пули",
		DATIVE = "пуле",
		ACCUSATIVE = "пулю",
		INSTRUMENTAL = "пулей",
		PREPOSITIONAL = "пуле"
	)
	damage = 25
	stamina = 20

/obj/projectile/bullet/weakbullet4
	name = "rubber bullet"
	ru_names = list(
		NOMINATIVE = "резиновая пуля",
		GENITIVE = "резиновой пули",
		DATIVE = "резиновой пуле",
		ACCUSATIVE = "резиновую пулю",
		INSTRUMENTAL = "резиновой пулей",
		PREPOSITIONAL = "резиновой пуле"
	)
	damage = 5
	stamina = 30
	icon_state = "bullet-r"

/obj/projectile/bullet/weakbullet4/c9mmte
	name = "9mm TE"
	damage = 7
	stamina = 15

/obj/projectile/bullet/toxinbullet
	damage = 15
	damage_type = TOX

/obj/projectile/bullet/incendiary

/obj/projectile/bullet/incendiary/on_hit(atom/target, blocked = 0)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(4)
		M.IgniteMob()

/obj/projectile/bullet/incendiary/firebullet
	damage = 10

/obj/projectile/bullet/incendiary/foursix
	damage = 10
	armour_penetration = 10

/obj/projectile/bullet/armourpiercing
	damage = 17
	armour_penetration = 10

/obj/projectile/bullet/pellet
	name = "pellet"
	ru_names = list(
		NOMINATIVE = "гранула",
		GENITIVE = "гранулы",
		DATIVE = "грануле",
		ACCUSATIVE = "гранулу",
		INSTRUMENTAL = "гранулой",
		PREPOSITIONAL = "грануле"
	)
	damage = 14
	tile_dropoff = 0.75
	tile_dropoff_s = 1.25
	armour_penetration = -20

/obj/projectile/bullet/pellet/nuclear
	damage = 15.5
	tile_dropoff = 0

/obj/projectile/bullet/pellet/bioterror
	damage = 9
	irradiate = 20
	tile_dropoff = 0

/obj/projectile/bullet/pellet/bioterror/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..()
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/C = target
		C.apply_damage(9, TOX)

/obj/projectile/bullet/pellet/flechette
	name = "flechette"
	ru_names = list(
		NOMINATIVE = "флешетта",
		GENITIVE = "флешетты",
		DATIVE = "флешетте",
		ACCUSATIVE = "флешетту",
		INSTRUMENTAL = "флешеттой",
		PREPOSITIONAL = "флешетте"
	)
	damage = 16.5
	tile_dropoff = 0
	armour_penetration = 20

/obj/projectile/bullet/pellet/rubber
	name = "rubber pellet"
	ru_names = list(
		NOMINATIVE = "резиновый шарик",
		GENITIVE = "резинового шарика",
		DATIVE = "резиновому шарику",
		ACCUSATIVE = "резиновый шарик",
		INSTRUMENTAL = "резиновым шариком",
		PREPOSITIONAL = "резиновом шарике"
	)
	damage = 3
	stamina = 15
	icon_state = "bullet-r"

/obj/projectile/bullet/pellet/weak
	tile_dropoff = 0.55		//Come on it does 6 damage don't be like that.
	damage = 8

/obj/projectile/bullet/pellet/weak/New()
	range = rand(1, 8)
	..()

/obj/projectile/bullet/pellet/weak/on_range()
 	do_sparks(1, TRUE, src)
 	..()

/obj/projectile/bullet/pellet/overload
	damage = 3

/obj/projectile/bullet/pellet/overload/New()
	range = rand(1, 10)
	..()

/obj/projectile/bullet/pellet/assassination
	damage = 12
	tile_dropoff = 1	// slightly less damage and greater damage falloff compared to normal buckshot

/obj/projectile/bullet/pellet/assassination/on_hit(atom/target, blocked = 0)
	if(..(target, blocked))
		var/mob/living/M = target
		M.AdjustSilence(4 SECONDS)	// HELP MIME KILLING ME IN MAINT

/obj/projectile/bullet/pellet/overload/on_hit(atom/target, blocked = 0)
 	..()
 	explosion(target, 0, 0, 2, cause = src)

/obj/projectile/bullet/pellet/overload/on_range()
 	explosion(src, 0, 0, 2, cause = src)
 	do_sparks(3, 3, src)
 	..()

/obj/projectile/bullet/midbullet
	damage = 20
	stamina = 33 //four rounds from the c20r knocks people down

/obj/projectile/bullet/midbullet_AC2S
	damage = 20
	stamina = 40 //three rounds from the AC 2 Special knocks people down

/obj/projectile/bullet/midbullet_r
	damage = 5
	stamina = 33 //Still four rounds to knock people down

/obj/projectile/bullet/midbullet2
	damage = 25

/obj/projectile/bullet/midbullet3
	damage = 30

/obj/projectile/bullet/midbullet3/hp
	damage = 50
	armour_penetration = -50

/obj/projectile/bullet/midbullet3/hp/on_hit(atom/target, blocked, hit_zone)
	if(..(target, blocked))
		var/mob/living/M = target
		M.Slowed(2 SECONDS)

/obj/projectile/bullet/midbullet3/ap
	damage = 27
	armour_penetration = 40

/obj/projectile/bullet/midbullet3/fire/on_hit(atom/target, blocked = 0)
	if(..(target, blocked))
		var/mob/living/M = target
		M.adjust_fire_stacks(1)
		M.IgniteMob()

/obj/projectile/bullet/heavybullet
	damage = 35

/obj/projectile/bullet/stunshot	//taser slugs for shotguns, nothing special
	name = "stunshot"
	ru_names = list(
		NOMINATIVE = "оглушающая пуля",
		GENITIVE = "оглушающей пули",
		DATIVE = "оглушающей пуле",
		ACCUSATIVE = "оглушающую пулю",
		INSTRUMENTAL = "оглушающей пулей",
		PREPOSITIONAL = "оглушающей пуле"
	)
	damage = 5
	weaken = 2 SECONDS
	stutter = 2 SECONDS
	stamina = 25
	jitter = 40 SECONDS
	range = 7
	icon_state = "spark"
	color = "#FFFF00"

/obj/projectile/bullet/incendiary/shell
	name = "incendiary slug"
	ru_names = list(
		NOMINATIVE = "зажигательная пуля",
		GENITIVE = "зажигательной пули",
		DATIVE = "зажигательной пуле",
		ACCUSATIVE = "зажигательную пулю",
		INSTRUMENTAL = "зажигательной пулей",
		PREPOSITIONAL = "зажигательной пуле"
	)
	damage = 20

/obj/projectile/bullet/incendiary/shell/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	. = ..()
	var/turf/location = get_turf(src)
	if(location)
		new /obj/effect/hotspot(location)
		location.hotspot_expose(700, 50, 1)

/obj/projectile/bullet/incendiary/shell/dragonsbreath
	name = "dragonsbreath round"
	ru_names = list(
		NOMINATIVE = "пуля \"Дыхание дракона\"",
		GENITIVE = "пули \"Дыхание дракона\"",
		DATIVE = "пуле \"Дыхание дракона\"",
		ACCUSATIVE = "пулю \"Дыхание дракона\"",
		INSTRUMENTAL = "пулей \"Дыхание дракона\"",
		PREPOSITIONAL = "пуле \"Дыхание дракона\""
	)
	damage = 5

/obj/projectile/bullet/incendiary/shell/dragonsbreath/nuclear
	damage = 13.5

/obj/projectile/bullet/incendiary/shell/dragonsbreath/mecha
	name = "liquidlava round"
	ru_names = list(
		NOMINATIVE = "пуля \"жидкая лава\"",
		GENITIVE = "пули \"жидкая лава\"",
		DATIVE = "пуле \"жидкая лава\"",
		ACCUSATIVE = "пулю \"жидкая лава\"",
		INSTRUMENTAL = "пулей \"жидкая лава\"",
		PREPOSITIONAL = "пуле \"жидкая лава\""
	)
	damage = 20

/obj/projectile/bullet/meteorshot
	name = "meteor"
	ru_names = list(
		NOMINATIVE = "метеор",
		GENITIVE = "метеора",
		DATIVE = "метеору",
		ACCUSATIVE = "метеор",
		INSTRUMENTAL = "метеором",
		PREPOSITIONAL = "метеоре"
	)
	icon = 'icons/obj/meteor.dmi'
	icon_state = "dust"
	damage = 30
	weaken = 4 SECONDS
	hitsound = 'sound/effects/meteorimpact.ogg'

/obj/projectile/bullet/meteorshot/on_hit(atom/target, blocked = 0)
	..()
	if(istype(target, /atom/movable))
		var/atom/movable/M = target
		var/atom/throw_target = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
		M.throw_at(throw_target, 3, 2)

/obj/projectile/bullet/meteorshot/New()
	..()
	SpinAnimation()

/obj/projectile/bullet/meteorshot/weak
	damage = 50
	weaken = 6 SECONDS
	stun = 6 SECONDS

/obj/projectile/bullet/mime
	damage = 0
	stun = 2 SECONDS
	weaken = 2 SECONDS
	stamina = 45
	slur = 40 SECONDS
	stutter = 40 SECONDS

/obj/projectile/bullet/mime/on_hit(atom/target, blocked = 0)
	..(target, blocked)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.Silence(20 SECONDS)
	else if(istype(target, /obj/mecha/combat/honker))
		var/obj/mecha/chassis = target
		chassis.occupant_message("A mimetech anti-honk bullet has hit \the [chassis]!")
		chassis.use_power(chassis.get_charge() / 2)
		for(var/obj/item/mecha_parts/mecha_equipment/weapon/honker in chassis.equipment)
			honker.set_ready_state(FALSE)

/obj/projectile/bullet/dart
	name = "dart"
	ru_names = list(
		NOMINATIVE = "дротик",
		GENITIVE = "дротика",
		DATIVE = "дротику",
		ACCUSATIVE = "дротик",
		INSTRUMENTAL = "дротиком",
		PREPOSITIONAL = "дротике"
	)
	icon_state = "cbbolt"
	damage = 6
	var/volume = 50
	var/piercing = FALSE

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
				target.visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] рикошетит!"), \
									span_userdanger("Ваша защита отражает[declent_ru(ACCUSATIVE)]!"))
	..(target, blocked, hit_zone)
	reagents.set_reacting(TRUE)
	reagents.handle_reactions()
	return TRUE

/obj/projectile/bullet/dart/metalfoam

/obj/projectile/bullet/dart/metalfoam/New()
	..()
	reagents.add_reagent("aluminum", 15)
	reagents.add_reagent("fluorosurfactant", 5)
	reagents.add_reagent("sacid", 5)

//This one is for future syringe guns update
/obj/projectile/bullet/dart/syringe
	name = "syringe"
	ru_names = list(
		NOMINATIVE = "шприц",
		GENITIVE = "шприца",
		DATIVE = "шприцу",
		ACCUSATIVE = "шприц",
		INSTRUMENTAL = "шприцем",
		PREPOSITIONAL = "шприце"
	)
	icon = 'icons/obj/chemical.dmi'
	icon_state = "syringeproj"
	volume = 15

/obj/projectile/bullet/dart/syringe/tranquilizer

/obj/projectile/bullet/dart/syringe/tranquilizer/New()
	..()
	reagents.add_reagent("haloperidol", 15)

/obj/projectile/bullet/neurotoxin
	name = "neurotoxin spit"
	ru_names = list(
		NOMINATIVE = "слюна с нейротоксином",
		GENITIVE = "слюны с нейротоксином",
		DATIVE = "слюне с нейротоксином",
		ACCUSATIVE = "слюну с нейротоксином",
		INSTRUMENTAL = "слюной с нейротоксином",
		PREPOSITIONAL = "слюне с нейротоксином"
	)
	icon_state = "neurotoxin"
	damage = 33
	damage_type = TOX
	weaken = 1 SECONDS

/obj/projectile/bullet/neurotoxin/prehit(atom/target)
	if(isalien(target))
		weaken = 0
		nodamage = TRUE
	if(isobj(target) || issilicon(target) || ismachineperson(target))
		damage_type = BURN
	. = ..()

/obj/projectile/bullet/cap
	name = "cap"
	damage = 0
	nodamage = TRUE

/obj/projectile/bullet/cap/fire()
	loc = null
	qdel(src)

/obj/projectile/bullet/f545 // Rusted AK
	name = "Fusty FMJ 5.45 bullet"
	ru_names = list(
		NOMINATIVE = "старая пуля FMJ 5.45",
		GENITIVE = "старой пули FMJ 5.45",
		DATIVE = "старой пуле FMJ 5.45",
		ACCUSATIVE = "старую пулю FMJ 5.45",
		INSTRUMENTAL = "старой пулей FMJ 5.45",
		PREPOSITIONAL = "старой пуле FMJ 5.45"
	)
	damage = 18
	stamina = 6

/obj/projectile/bullet/ftt762 // Rusted PPSh
	name = "Fusty FMJ 7.62 TT bullet"
	ru_names = list(
		NOMINATIVE = "старая пуля FMJ 7.62 TT",
		GENITIVE = "старой пули FMJ 7.62 TT",
		DATIVE = "старой пуле FMJ 7.62 TT",
		ACCUSATIVE = "старую пулю FMJ 7.62 TT",
		INSTRUMENTAL = "старой пулей FMJ 7.62 TT",
		PREPOSITIONAL = "старой пуле FMJ 7.62 TT"
	)
	damage = 8
	stamina = 1
	armour_penetration = 5

/obj/projectile/bullet/weakbullet3/c257
	damage = 20

/obj/projectile/bullet/weakbullet3/c257/phosphorus/on_hit(atom/target, blocked, hit_zone)
	do_sparks(rand(1, 3), FALSE, target)
	if(..(target, blocked))
		var/mob/living/target_living = target

		if(target_living.check_eye_prot() == FLASH_PROTECTION_FLASH)	// Just a visual effect for sunglasses users.
			target_living.flash_eyes(intensity = 2, visual = TRUE)
		else
			target_living.flash_eyes(affect_silicon = TRUE)
