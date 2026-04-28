// MARK: Slugs
/obj/projectile/bullet/slug
	armour_penetration = 10
	damage = 36

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

// MARK: Tasel slug
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

// MARK: Indendiary slugs
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
		NOMINATIVE = "пуля \"Жидкая лава\"",
		GENITIVE = "пули \"Жидкая лава\"",
		DATIVE = "пуле \"Жидкая лава\"",
		ACCUSATIVE = "пулю \"Жидкая лава\"",
		INSTRUMENTAL = "пулей \"Жидкая лава\"",
		PREPOSITIONAL = "пуле \"Жидкая лава\"",
	)

// MARK: Frag-12
/obj/projectile/bullet/frag12
	name = "explosive slug"
	damage = 20
	knockdown = 5 SECONDS
	ricochets_max = 0

/obj/projectile/bullet/frag12/get_ru_names()
	return list(
		NOMINATIVE = "разрывная пуля",
		GENITIVE = "разрывной пули",
		DATIVE = "разрывной пуле",
		ACCUSATIVE = "разрывную пулю",
		INSTRUMENTAL = "разрывной пулей",
		PREPOSITIONAL = "разрывной пуле",
	)

/obj/projectile/bullet/frag12/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, devastation_range = -1, heavy_impact_range = 0, light_impact_range = 1, cause = "frag 12 fired by [key_name(firer)]")
	return 1

// MARK: Meteorshot slugs
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

// MARK: Pellets
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

