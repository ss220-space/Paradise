/obj/projectile/bullet
	name = "bullet"
	damage = 50
	hitsound = SFX_BULLET
	hitsound_wall = SFX_RICOCHET
	impact_effect_type = /obj/effect/temp_visual/impact_effect
	ricochets_max = 1
	ricochet_chance = 5

/obj/projectile/bullet/get_ru_names()
	return list(
		NOMINATIVE = "пуля",
		GENITIVE = "пули",
		DATIVE = "пуле",
		ACCUSATIVE = "пулю",
		INSTRUMENTAL = "пулей",
		PREPOSITIONAL = "пуле",
	)

/obj/projectile/bullet/on_ricochet(atom/A)
	. = ..()
	damage = damage / 2
	stamina = stamina / 2

/obj/projectile/bullet/on_hit(atom/target, blocked = 0)
	. = ..()
	if(!.)
		return
	if(!ismob(target))
		return
	var/datum/gun_recoil/recoil = GLOB.mob_hit_recoil
	var/shot_angle = get_angle(firer, target)
	var/rand_angle = (rand() - 0.5) * recoil.angle + shot_angle
	recoil_camera(target, recoil.strength, recoil.in_duration, recoil.back_duration, rand_angle)

/obj/projectile/bullet/slug
	armour_penetration = 40
	damage = 33

/obj/projectile/bullet/desert_eagle
	stamina = 33
	ricochet_chance = 10

/obj/projectile/bullet/weakbullet //beanbag, heavy stamina damage
	name = "beanbag slug"
	damage = 5
	stamina = 55
	ricochet_chance = 20 //rubber bullets - high ricochet chance

/obj/projectile/bullet/weakbullet/get_ru_names()
	return list(
		NOMINATIVE = "патрон \"Погремушка\"",
		GENITIVE = "патрона \"Погремушка\"",
		DATIVE = "патрону \"Погремушка\"",
		ACCUSATIVE = "патрон \"Погремушка\"",
		INSTRUMENTAL = "патроном \"Погремушка\"",
		PREPOSITIONAL = "патроне \"Погремушка\"",
	)

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

/obj/projectile/bullet/hp38 //Detective hollow-point
	damage = 35
	armour_penetration = -50
	ricochets_max = 0 //no ricochets for HP
	sharp = TRUE //for dismember bodypart and double bleeding

/obj/projectile/bullet/hp38/on_hit(atom/target, blocked, hit_zone)
	if(..(target, blocked))
		var/mob/living/carbon/carbon_target = target
		if(istype(carbon_target))
			carbon_target.Slowed(2 SECONDS, 2)

/obj/projectile/bullet/weakbullet2/invisible //finger gun bullets
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

//9mm bullet casing
/obj/projectile/bullet/weakbullet3
	damage = 23
	ricochet_chance = 10

//4.6x30mm bullet casing
/obj/projectile/bullet/weakbullet3/foursix
	damage = 15

/obj/projectile/bullet/weakbullet3/foursix/ap
	damage = 12
	armour_penetration = 40

/obj/projectile/bullet/weakbullet3/foursix/tox
	damage = 10
	damage_type = TOX
	armour_penetration = 10

//40nr bullet casing
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

/obj/projectile/bullet/weakbullet4
	name = "rubber bullet"
	damage = 5
	stamina = 30
	icon_state = "bullet-r"
	ricochet_chance = 20

/obj/projectile/bullet/weakbullet4/get_ru_names()
	return list(
		NOMINATIVE = "резиновая пуля",
		GENITIVE = "резиновой пули",
		DATIVE = "резиновой пуле",
		ACCUSATIVE = "резиновую пулю",
		INSTRUMENTAL = "резиновой пулей",
		PREPOSITIONAL = "резиновой пуле",
	)

//45 N&R bullet casing
/obj/projectile/bullet/weakbullet4/c45nr
	name = "45 N&R"
	damage = 12
	stamina = 15
	ricochet_chance = 10

/obj/projectile/bullet/toxinbullet
	damage = 15
	damage_type = TOX

/obj/projectile/bullet/incendiary
	immolate = 4
	/// If TRUE, leaves a trail of hotspots as it flies, very very chaotic
	var/leaves_fire_trail = FALSE

/obj/projectile/bullet/incendiary/Move()
	. = ..()

	if(!leaves_fire_trail)
		return
	var/turf/location = get_turf(src)
	if(!location)
		return
	var/obj/effect/hotspot/hotspot = new /obj/effect/hotspot/fake(location)
	hotspot.temperature = 1000
	hotspot.recolor()
	location.hotspot_expose(700, 50)

/obj/projectile/bullet/incendiary/firebullet
	damage = 10

/obj/projectile/bullet/incendiary/foursix
	damage = 10
	armour_penetration = 10

/// Incendiary bullet that more closely resembles a real flamethrower sorta deal, no visible bullet, just flames.
/obj/projectile/bullet/incendiary/fire
	damage = 15
	range = 6
	alpha = 0
	pass_flags = PASSTABLE | PASSMOB
	impact_effect_type = null
	suppressed = TRUE
	damage_type = BURN
	flag = BOMB
	speed = 0.8
	immolate = 3
	leaves_fire_trail = TRUE

/obj/projectile/bullet/incendiary/fire/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/turf/location = get_turf(target)
	if(!location || location.density)
		return
	var/obj/effect/hotspot/hotspot = new /obj/effect/hotspot/fake(location)
	hotspot.temperature = 1000
	hotspot.recolor()
	location.hotspot_expose(700, 50)

/obj/projectile/bullet/armourpiercing
	damage = 18
	armour_penetration = 10

/obj/projectile/bullet/pellet
	name = "pellet"
	damage = 14
	tile_dropoff = 0.75
	tile_dropoff_s = 1.25
	armour_penetration = -20
	ricochets_max = 0

/obj/projectile/bullet/pellet/get_ru_names()
	return list(
		NOMINATIVE = "гранула",
		GENITIVE = "гранулы",
		DATIVE = "грануле",
		ACCUSATIVE = "гранулу",
		INSTRUMENTAL = "гранулой",
		PREPOSITIONAL = "грануле",
	)

/obj/projectile/bullet/pellet/magnum
	damage = 15.5
	tile_dropoff = 0.4

/obj/projectile/bullet/pellet/bioterror
	damage = 9
	tile_dropoff = 0

/obj/projectile/bullet/pellet/bioterror/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..()
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/C = target
		C.apply_damage(9, TOX)

/obj/projectile/bullet/pellet/flechette
	name = "flechette"
	damage = 16.5
	tile_dropoff = 0
	armour_penetration = 20

/obj/projectile/bullet/pellet/flechette/get_ru_names()
	return list(
		NOMINATIVE = "флешетта",
		GENITIVE = "флешетты",
		DATIVE = "флешетте",
		ACCUSATIVE = "флешетту",
		INSTRUMENTAL = "флешеттой",
		PREPOSITIONAL = "флешетте",
	)

/obj/projectile/bullet/pellet/rubber
	name = "rubber pellet"
	damage = 3
	stamina = 15
	icon_state = "bullet-r"
	ricochets_max = 1
	ricochet_chance = 20

/obj/projectile/bullet/pellet/rubber/get_ru_names()
	return list(
		NOMINATIVE = "резиновый шарик",
		GENITIVE = "резинового шарика",
		DATIVE = "резиновому шарику",
		ACCUSATIVE = "резиновый шарик",
		INSTRUMENTAL = "резиновым шариком",
		PREPOSITIONAL = "резиновом шарике",
	)

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
	explosion(target, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 2, cause = src)

/obj/projectile/bullet/pellet/overload/on_range()
	explosion(src, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 2, cause = src)
	do_sparks(3, TRUE, src)
	..()

/obj/projectile/bullet/rubber45colt
	name = "rubber bullet"
	damage = 5
	stamina = 33
	icon_state = "bullet-r"
	ricochet_chance = 20

/obj/projectile/bullet/c45colt
	damage = 26

/obj/projectile/bullet/c45colt/hp
	damage = 35
	armour_penetration = -50

/obj/projectile/bullet/c45colt/ap
	damage = 18
	armour_penetration = 30

//.45 bullet casing
/obj/projectile/bullet/midbullet
	damage = 23
	stamina = 33 //four rounds from the c20r knocks people down

/obj/projectile/bullet/midbullet_AC2S
	damage = 23
	stamina = 40 //three rounds from the AC 2 Special knocks people down

//.45 rubber bullet casing
/obj/projectile/bullet/midbullet_r
	damage = 5
	stamina = 33 //Still four rounds to knock people down
	ricochet_chance = 20

//.36 bullet casing
/obj/projectile/bullet/midbullet2
	damage = 25
	ricochet_chance = 10

//10mm bullet casing
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

//5.56mm bullet casing
/obj/projectile/bullet/heavybullet
	damage = 36

/obj/projectile/bullet/stunshot	//taser slugs for shotguns, nothing special
	name = "stunshot"
	damage = 5
	weaken = 2 SECONDS
	stutter = 2 SECONDS
	stamina = 25
	jitter = 40 SECONDS
	range = 7
	icon_state = "spark"
	color = "#FFFF00"
	ricochets_max = 0

/obj/projectile/bullet/stunshot/get_ru_names()
	return list(
		NOMINATIVE = "оглушающая пуля",
		GENITIVE = "оглушающей пули",
		DATIVE = "оглушающей пуле",
		ACCUSATIVE = "оглушающую пулю",
		INSTRUMENTAL = "оглушающей пулей",
		PREPOSITIONAL = "оглушающей пуле",
	)

/obj/projectile/bullet/incendiary/shell
	name = "incendiary slug"
	damage = 20

/obj/projectile/bullet/incendiary/shell/get_ru_names()
	return list(
		NOMINATIVE = "зажигательная пуля",
		GENITIVE = "зажигательной пули",
		DATIVE = "зажигательной пуле",
		ACCUSATIVE = "зажигательную пулю",
		INSTRUMENTAL = "зажигательной пулей",
		PREPOSITIONAL = "зажигательной пуле",
	)

/obj/projectile/bullet/incendiary/shell/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	. = ..()
	var/turf/location = get_turf(src)
	if(location)
		var/obj/effect/hotspot/hotspot = new /obj/effect/hotspot/fake(location)
		hotspot.temperature = 1000
		hotspot.recolor()
		location.hotspot_expose(700, 50)
	if(prob(10))
		do_sparks(1, TRUE, src)

/obj/projectile/bullet/incendiary/shell/dragonsbreath
	name = "dragonsbreath round"
	damage = 15
	damage_type = BURN
	range = 10

/obj/projectile/bullet/incendiary/shell/dragonsbreath/get_ru_names()
	return list(
		NOMINATIVE = "пуля \"Дыхание дракона\"",
		GENITIVE = "пули \"Дыхание дракона\"",
		DATIVE = "пуле \"Дыхание дракона\"",
		ACCUSATIVE = "пулю \"Дыхание дракона\"",
		INSTRUMENTAL = "пулей \"Дыхание дракона\"",
		PREPOSITIONAL = "пуле \"Дыхание дракона\"",
	)

/obj/projectile/bullet/incendiary/shell/dragonsbreath/napalm
	damage = 14

/obj/projectile/bullet/incendiary/shell/dragonsbreath/mecha
	name = "liquidlava round"
	damage = 20
	damage_type = BRUTE
	range = 50

/obj/projectile/bullet/incendiary/shell/dragonsbreath/mecha/get_ru_names()
	return list(
		NOMINATIVE = "пуля \"жидкая лава\"",
		GENITIVE = "пули \"жидкая лава\"",
		DATIVE = "пуле \"жидкая лава\"",
		ACCUSATIVE = "пулю \"жидкая лава\"",
		INSTRUMENTAL = "пулей \"жидкая лава\"",
		PREPOSITIONAL = "пуле \"жидкая лава\"",
	)

/obj/projectile/bullet/meteorshot
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "dust"
	damage = 30
	weaken = 4 SECONDS
	hitsound = 'sound/effects/meteorimpact.ogg'
	ricochets_max = 0

/obj/projectile/bullet/meteorshot/get_ru_names()
	return list(
		NOMINATIVE = "метеор",
		GENITIVE = "метеора",
		DATIVE = "метеору",
		ACCUSATIVE = "метеор",
		INSTRUMENTAL = "метеором",
		PREPOSITIONAL = "метеоре",
	)

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
	icon_state = "cbbolt"
	damage = 6
	var/volume = 50
	var/piercing = FALSE
	ricochets_max = 0

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

/obj/projectile/bullet/dart/metalfoam

/obj/projectile/bullet/dart/metalfoam/New()
	..()
	reagents.add_reagent("aluminum", 15)
	reagents.add_reagent("fluorosurfactant", 5)
	reagents.add_reagent("sacid", 5)

//This one is for future syringe guns update
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

/obj/projectile/bullet/neurotoxin
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 33
	damage_type = TOX
	weaken = 1 SECONDS

/obj/projectile/bullet/neurotoxin/get_ru_names()
	return list(
		NOMINATIVE = "слюна с нейротоксином",
		GENITIVE = "слюны с нейротоксином",
		DATIVE = "слюне с нейротоксином",
		ACCUSATIVE = "слюну с нейротоксином",
		INSTRUMENTAL = "слюной с нейротоксином",
		PREPOSITIONAL = "слюне с нейротоксином",
	)

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
	damage = 20
	stamina = 6

/obj/projectile/bullet/f545/get_ru_names()
	return list(
		NOMINATIVE = "старая пуля FMJ 5.45",
		GENITIVE = "старой пули FMJ 5.45",
		DATIVE = "старой пуле FMJ 5.45",
		ACCUSATIVE = "старую пулю FMJ 5.45",
		INSTRUMENTAL = "старой пулей FMJ 5.45",
		PREPOSITIONAL = "старой пуле FMJ 5.45",
	)

/obj/projectile/bullet/ftt762 // Rusted PPSh
	name = "Fusty FMJ 7.62 TT bullet"
	damage = 9
	stamina = 1
	armour_penetration = 5
	ricochet_chance = 10

/obj/projectile/bullet/ftt762/get_ru_names()
	return list(
		NOMINATIVE = "старая пуля FMJ 7.62 TT",
		GENITIVE = "старой пули FMJ 7.62 TT",
		DATIVE = "старой пуле FMJ 7.62 TT",
		ACCUSATIVE = "старую пулю FMJ 7.62 TT",
		INSTRUMENTAL = "старой пулей FMJ 7.62 TT",
		PREPOSITIONAL = "старой пуле FMJ 7.62 TT",
	)

/obj/projectile/bullet/weakbullet3/c257

/obj/projectile/bullet/weakbullet3/c257/phosphorus/on_hit(atom/target, blocked, hit_zone)
	do_sparks(rand(1, 3), FALSE, target)
	if(..(target, blocked))
		var/mob/living/target_living = target

		if(target_living.check_eye_prot() == FLASH_PROTECTION_FLASH)	// Just a visual effect for sunglasses users.
			target_living.flash_eyes(intensity = 2, visual = TRUE)
		else
			target_living.flash_eyes(affect_silicon = TRUE)
