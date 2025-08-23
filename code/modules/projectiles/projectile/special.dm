/obj/projectile/ion
	name = "ion bolt"
	ru_names = list(
		NOMINATIVE = "ионный заряд",
		GENITIVE = "ионного заряда",
		DATIVE = "ионному заряду",
		ACCUSATIVE = "ионный заряд",
		INSTRUMENTAL = "ионным зарядом",
		PREPOSITIONAL = "ионном заряде"
	)
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	var/emp_range = 1
	impact_effect_type = /obj/effect/temp_visual/impact_effect/ion
	flag = "energy"
	hitsound = 'sound/weapons/tap.ogg'

/obj/projectile/ion/on_hit(var/atom/target, var/blocked = 0)
	. = ..()
	empulse(target, emp_range, emp_range, 1, cause = "[type] fired by [key_name(firer)]")
	return 1

/obj/projectile/ion/weak

/obj/projectile/ion/weak/on_hit(atom/target, blocked = 0)
	emp_range = 0
	. = ..()
	return 1

/obj/projectile/bullet/gyro
	name ="explosive bolt"
	ru_names = list(
		NOMINATIVE = "разрывной заряд",
		GENITIVE = "разрывного заряда",
		DATIVE = "разрывному заряду",
		ACCUSATIVE = "разрывной заряд",
		INSTRUMENTAL = "разрывным зарядом",
		PREPOSITIONAL = "разрывном заряде"
	)
	icon_state= "bolter"
	damage = 50
	flag = BULLET

/obj/projectile/bullet/gyro/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, devastation_range = -1, heavy_impact_range = 0, light_impact_range = 2, cause = "[type] fired by [key_name(firer)]")
	return 1

/obj/projectile/bullet/a40mm
	name ="40mm grenade"
	ru_names = list(
		NOMINATIVE = "40мм граната",
		GENITIVE = "40мм гранаты",
		DATIVE = "40мм гранате",
		ACCUSATIVE = "40мм гранату",
		INSTRUMENTAL = "40мм гранатой",
		PREPOSITIONAL = "40мм гранате"
	)
	desc = "USE A WEEL GUN"
	icon_state= "bolter"
	damage = 60
	flag = BULLET

/obj/projectile/bullet/a40mm/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, devastation_range = -1, heavy_impact_range = 0, light_impact_range = 2, flash_range = 1, adminlog = TRUE, flame_range = 3, cause = "[type] fired by [key_name(firer)]")
	return 1

/obj/projectile/temp
	name = "temperature beam"
	ru_names = list(
		NOMINATIVE = "температурный луч",
		GENITIVE = "температурного луча",
		DATIVE = "температурному лучу",
		ACCUSATIVE = "температурный луч",
		INSTRUMENTAL = "температурным лучом",
		PREPOSITIONAL = "температурном луче"
	)
	icon_state = "temp_4"
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	reflectability = REFLECTABILITY_ENERGY
	flag = "energy"
	var/temperature = 300
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	hitsound = 'sound/weapons/tap.ogg'

/obj/projectile/temp/New(loc, shot_temp)
	..()
	if(!isnull(shot_temp))
		temperature = shot_temp
	switch(temperature)
		if(501 to INFINITY)
			name = "searing beam"	//if emagged
			icon_state = "temp_8"
			ru_names = list(
				NOMINATIVE = "обжигающий луч",
				GENITIVE = "обжигающего луча",
				DATIVE = "обжигающему лучу",
				ACCUSATIVE = "обжигающий луч",
				INSTRUMENTAL = "обжигающим лучом",
				PREPOSITIONAL = "обжигающем луче"
			)
		if(400 to 500)
			name = "burning beam"	//temp at which mobs start taking HEAT_DAMAGE_LEVEL_2
			icon_state = "temp_7"
			ru_names = list(
				NOMINATIVE = "горящий луч",
				GENITIVE = "горящего луча",
				DATIVE = "горящему лучу",
				ACCUSATIVE = "горящий луч",
				INSTRUMENTAL = "горящим лучом",
				PREPOSITIONAL = "горящем луче"
			)
		if(360 to 400)
			name = "hot beam"		//temp at which mobs start taking HEAT_DAMAGE_LEVEL_1
			icon_state = "temp_6"
			ru_names = list(
				NOMINATIVE = "горячий луч",
				GENITIVE = "горячего луча",
				DATIVE = "горячему лучу",
				ACCUSATIVE = "горячий луч",
				INSTRUMENTAL = "горячим лучом",
				PREPOSITIONAL = "горячем луче"
			)
		if(335 to 360)
			name = "warm beam"		//temp at which players get notified of their high body temp
			icon_state = "temp_5"
			ru_names = list(
				NOMINATIVE = "теплый луч",
				GENITIVE = "теплого луча",
				DATIVE = "теплому лучу",
				ACCUSATIVE = "теплый луч",
				INSTRUMENTAL = "теплым лучом",
				PREPOSITIONAL = "теплом луче"
			)
		if(295 to 335)
			name = "ambient beam"
			icon_state = "temp_4"
			ru_names = list(
				NOMINATIVE = "рассеянный луч",
				GENITIVE = "рассеянного луча",
				DATIVE = "рассеянному лучу",
				ACCUSATIVE = "рассеянный луч",
				INSTRUMENTAL = "рассеянным лучом",
				PREPOSITIONAL = "рассеянном луче"
			)
		if(260 to 295)
			name = "cool beam"		//temp at which players get notified of their low body temp
			icon_state = "temp_3"
			ru_names = list(
				NOMINATIVE = "холодный луч",
				GENITIVE = "холодного луча",
				DATIVE = "холодному лучу",
				ACCUSATIVE = "холодный луч",
				INSTRUMENTAL = "холодным лучом",
				PREPOSITIONAL = "холодном луче"
			)
		if(200 to 260)
			name = "cold beam"		//temp at which mobs start taking COLD_DAMAGE_LEVEL_1
			icon_state = "temp_2"
			ru_names = list(
				NOMINATIVE = "холодный луч",
				GENITIVE = "холодного луча",
				DATIVE = "холодному лучу",
				ACCUSATIVE = "холодный луч",
				INSTRUMENTAL = "холодным лучом",
				PREPOSITIONAL = "холодном луче"
			)
		if(120 to 260)
			name = "ice beam"		//temp at which mobs start taking COLD_DAMAGE_LEVEL_2
			icon_state = "temp_1"
			ru_names = list(
				NOMINATIVE = "ледяной луч",
				GENITIVE = "ледяного луча",
				DATIVE = "ледяному лучу",
				ACCUSATIVE = "ледяной луч",
				INSTRUMENTAL = "ледяным лучом",
				PREPOSITIONAL = "ледяном луче"
			)
		if(-INFINITY to 120)
			name = "freeze beam"	//temp at which mobs start taking COLD_DAMAGE_LEVEL_3
			icon_state = "temp_0"
			ru_names = list(
				NOMINATIVE = "замораживающий луч",
				GENITIVE = "замораживающего луча",
				DATIVE = "замораживающему лучу",
				ACCUSATIVE = "замораживающий луч",
				INSTRUMENTAL = "замораживающим лучом",
				PREPOSITIONAL = "замораживающем луче"
			)
		else
			name = "temperature beam"//failsafe
			icon_state = "temp_4"
			ru_names = list(
				NOMINATIVE = "температурный луч",
				GENITIVE = "температурного луча",
				DATIVE = "температурному лучу",
				ACCUSATIVE = "температурный луч",
				INSTRUMENTAL = "температурным лучом",
				PREPOSITIONAL = "температурном луче"
			)


/obj/projectile/temp/on_hit(mob/living/carbon/human/target, blocked = 0, hit_zone)
	. = ..()
	if(!.)
		return .

	var/target_is_living = isliving(target)
	var/should_ignite = target_is_living && temperature > 500	//emagged

	if(ishuman(target))
		var/temp_diff = temperature - target.bodytemperature
		if(temperature < target.bodytemperature)
			// This returns a 0 - 1 value, which corresponds to the percentage of protection
			// based on what you're wearing and what you're exposed to
			var/thermal_protection = target.get_cold_protection(temperature)
			if(thermal_protection < 1)
				target.adjust_bodytemperature(temp_diff * (1 - thermal_protection))
		else
			var/thermal_protection = target.get_heat_protection(temperature)
			if(thermal_protection < 1)
				target.adjust_bodytemperature(temp_diff * (1 - thermal_protection))
			else
				should_ignite = FALSE

	else if(target_is_living)
		target.adjust_bodytemperature(temperature - target.bodytemperature)

	if(should_ignite)
		target.adjust_fire_stacks(0.5)
		target.IgniteMob()
		playsound(target.loc, 'sound/effects/bamf.ogg', 50, FALSE)


/obj/projectile/meteor
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
	icon_state = "small"
	damage = 0
	damage_type = BRUTE
	nodamage = TRUE
	flag = BULLET
	hitsound = 'sound/effects/meteorimpact.ogg'


/obj/projectile/meteor/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	if(blocked >= 100)
		return FALSE
	for(var/mob/mob in urange(10, src))
		if(!mob.stat)
			shake_camera(mob, 3, 1)

// FLORAGUN
/obj/projectile/energy/floraalpha
	name = "alpha somatoray"
	ru_names = list(
		NOMINATIVE = "альфа-соматорей",
		GENITIVE = "альфа-соматорея",
		DATIVE = "альфа-соматорею",
		ACCUSATIVE = "альфа-соматорей",
		INSTRUMENTAL = "альфа-соматореем",
		PREPOSITIONAL = "альфа-соматорее"
	)
	icon_state = "declone"
	damage = 2
	hitsound = 'sound/weapons/tap.ogg'
	damage_type = BURN
	nodamage = FALSE
	flag = "energy"
	range = 7
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	/// how strong the fire will be
	var/fire_stacks = 0.3

/obj/projectile/energy/floraalpha/prehit(atom/target)
	if(target && !HAS_TRAIT(target, TRAIT_PLANT_ORIGIN)) // burn damage for only plant
		damage = 0
	. = ..()

/obj/projectile/energy/floraalpha/on_range()
	strike_thing()
	. = ..()

/obj/projectile/energy/floraalpha/on_hit(atom/target, blocked = 0, hit_zone)
	strike_thing(target)
	. = ..()

/obj/projectile/energy/floraalpha/proc/strike_thing(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		target_turf = get_turf(src)
	new /obj/effect/temp_visual/pka_explosion/florawave(target_turf)
	for(var/currentTurf in RANGE_TURFS(1, target_turf))
		for(var/object in currentTurf)
			if(isdiona(object))
				var/mob/living/plant = object
				if(!plant.on_fire) // the hit has no effect if the target is on fire
					plant.adjust_fire_stacks(fire_stacks)
					plant.IgniteMob()
			else if(is_type_in_list(object, list(/obj/structure/glowshroom, /obj/structure/spacevine)))
				if(prob(5))
					new /obj/effect/decal/cleanable/molten_object(get_turf(object))
				else
					new /obj/effect/temp_visual/removing_flora(get_turf(object))
				qdel(object)

/obj/projectile/energy/floraalpha/emag
	range = 9
	damage = 15
	fire_stacks = 10

/obj/projectile/energy/florabeta
	name = "beta somatoray"
	ru_names = list(
		NOMINATIVE = "бета-соматорей",
		GENITIVE = "бета-соматорея",
		DATIVE = "бета-соматорею",
		ACCUSATIVE = "бета-соматорей",
		INSTRUMENTAL = "бета-соматореем",
		PREPOSITIONAL = "бета-соматорее"
	)
	icon_state = "energy"
	damage = 0
	hitsound = 'sound/weapons/tap.ogg'
	damage_type = TOX
	nodamage = TRUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	flag = "energy"

/obj/projectile/energy/floragamma
	name = "gamma somatoray"
	ru_names = list(
		NOMINATIVE = "гамма-соматорей",
		GENITIVE = "гамма-соматорея",
		DATIVE = "гамма-соматорею",
		ACCUSATIVE = "гамма-соматорей",
		INSTRUMENTAL = "гамма-соматореем",
		PREPOSITIONAL = "гамма-соматорее"
	)
	icon_state = "energy2"
	damage = 0
	hitsound = 'sound/weapons/tap.ogg'
	damage_type = TOX
	nodamage = TRUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	flag = "energy"

/obj/projectile/beam/mindflayer
	name = "flayer ray"
	ru_names = list(
		NOMINATIVE = "заряд мозгоёба",
		GENITIVE = "заряда мозгоёба",
		DATIVE = "заряду мозгоёба",
		ACCUSATIVE = "заряд мозгоёба",
		INSTRUMENTAL = "зарядом мозгоёба",
		PREPOSITIONAL = "заряде мозгоёба"
	)

/obj/projectile/beam/mindflayer/on_hit(var/atom/target, var/blocked = 0)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		M.apply_damage(20, BRAIN)
		M.AdjustHallucinate(20 SECONDS)
		M.last_hallucinator_log = name

/obj/projectile/clown
	name = "snap-pop"
	ru_names = list(
		NOMINATIVE = "щёлк-хлоп",
		GENITIVE = "щёлк-хлопа",
		DATIVE = "щёлк-хлопу",
		ACCUSATIVE = "щёлк-хлоп",
		INSTRUMENTAL = "щёлк-хлопом",
		PREPOSITIONAL = "щёлк-хлопе"
	)
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"
	nodamage = TRUE
	damage = 0


/obj/projectile/clown/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	if(blocked >= 100)
		return .
	do_sparks(3, 1, target)
	target.visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] взрывается!"))
	playsound(target, 'sound/effects/snap.ogg', 50, TRUE)
	if(isturf(target.loc) && !target.loc.density)
		new /obj/effect/decal/cleanable/ash(target.loc)


/obj/projectile/beam/wormhole
	name = "bluespace beam"
	ru_names = list(
		NOMINATIVE = "блюспейс-луч",
		GENITIVE = "блюспейс-луча",
		DATIVE = "блюспейс-лучу",
		ACCUSATIVE = "блюспейс-луч",
		INSTRUMENTAL = "блюспейс-лучом",
		PREPOSITIONAL = "блюспейс-луче"
	)
	icon_state = "spark"
	hitsound = SFX_SPARKS
	damage = 0
	color = "#33CCFF"
	nodamage = TRUE
	var/is_orange = FALSE

/obj/projectile/beam/wormhole/orange
	name = "orange bluespace beam"
	ru_names = list(
		NOMINATIVE = "оранжевый блюспейс-луч",
		GENITIVE = "оранжевого блюспейс-луча",
		DATIVE = "оранжевому блюспейс-лучу",
		ACCUSATIVE = "оранжевый блюспейс-луч",
		INSTRUMENTAL = "оранжевым блюспейс-лучом",
		PREPOSITIONAL = "оранжевом блюспейс-луче"
	)
	color = "#FF6600"
	is_orange = TRUE

/obj/projectile/beam/wormhole/on_hit(atom/target)
	if(ismob(target))
		if(is_teleport_allowed(target.z))
			var/turf/portal_destination = pick(orange(6, src))
			do_teleport(target, portal_destination)
		return ..()
	if(!firer_source_atom)
		qdel(src)
	var/obj/item/gun/energy/wormhole_projector/gun = firer_source_atom
	if(!(locate(/obj/effect/portal) in get_turf(target)))
		gun.create_portal(src)

/obj/projectile/bullet/frag12
	name ="explosive slug"
	ru_names = list(
		NOMINATIVE = "разрывная пуля",
		GENITIVE = "разрывной пули",
		DATIVE = "разрывной пуле",
		ACCUSATIVE = "разрывную пулю",
		INSTRUMENTAL = "разрывной пулей",
		PREPOSITIONAL = "разрывной пуле"
	)
	damage = 25
	weaken = 10 SECONDS

/obj/projectile/bullet/frag12/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, devastation_range = -1, heavy_impact_range = 0, light_impact_range = 1, cause = src)
	return 1

/obj/projectile/plasma
	name = "plasma blast"
	ru_names = list(
		NOMINATIVE = "плазменный луч",
		GENITIVE = "плазменного луча",
		DATIVE = "плазменному лучу",
		ACCUSATIVE = "плазменный луч",
		INSTRUMENTAL = "плазменным лучом",
		PREPOSITIONAL = "плазменном луче"
	)
	icon_state = "plasmacutter"
	damage_type = BRUTE
	damage = 5
	hitsound = SFX_BULLET
	range = 3
	dismemberment = 20
	dismember_limbs = TRUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser

/obj/projectile/plasma/on_hit(atom/target, pointblank = 0)
	. = ..()
	if(ismineralturf(target))
		if(isancientturf(target))
			visible_message(span_notice("Похоже, что эта порода устойчива ко всем шахтёрским инструментам, кроме кирки!"))
			forcedodge = 0
			return
		forcedodge = 1
		var/turf/simulated/mineral/M = target
		M.attempt_drill(firer)
	else
		forcedodge = 0

/obj/projectile/plasma/adv
	damage = 7
	range = 5

/obj/projectile/plasma/adv/mega
	icon_state = "plasmacutter_mega"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	range = 7

/obj/projectile/plasma/adv/mega/on_hit(atom/target)
	if(istype(target, /turf/simulated/mineral/gibtonite))
		var/turf/simulated/mineral/gibtonite/gib = target
		gib.defuse()
	. = ..()

/obj/projectile/plasma/adv/mega/shotgun
	damage = 2
	range = 6
	dismemberment = 0

/obj/projectile/plasma/adv/mech
	damage = 10
	range = 9

/obj/projectile/plasma/shotgun
	damage = 2
	range = 4
	dismemberment = 0

/obj/projectile/energy/teleport
	name = "teleportation burst"
	ru_names = list(
		NOMINATIVE = "вспышка телепортации",
		GENITIVE = "вспышки телепортации",
		DATIVE = "вспышке телепортации",
		ACCUSATIVE = "вспышку телепортации",
		INSTRUMENTAL = "вспышкой телепортации",
		PREPOSITIONAL = "вспышке телепортации"
	)
	icon_state = "bluespace"
	damage = 0
	nodamage = TRUE
	var/teleport_target = null

/obj/projectile/energy/teleport/New(loc, tele_target)
	..(loc)
	if(tele_target)
		teleport_target = tele_target

/obj/projectile/energy/teleport/on_hit(var/atom/target, var/blocked = 0)
	if(isliving(target))
		if(teleport_target)
			do_teleport(target, teleport_target, 0)//teleport what's in the tile to the beacon
		else
			do_teleport(target, target, 15) //Otherwise it just warps you off somewhere.
	add_attack_logs(firer, target, "Shot with a [type] [teleport_target ? "(Destination: [teleport_target])" : ""]")

/obj/projectile/snowball
	name = "snowball"
	ru_names = list(
		NOMINATIVE = "снежок",
		GENITIVE = "снежка",
		DATIVE = "снежку",
		ACCUSATIVE = "снежок",
		INSTRUMENTAL = "снежком",
		PREPOSITIONAL = "снежке"
	)
	icon_state = "snowball"
	hitsound = 'sound/items/dodgeball.ogg'
	damage = 4
	damage_type = BURN

/obj/projectile/snowball/on_hit(atom/target)	//chilling
	. = ..()
	if(isliving(target))
		var/mob/living/M = target
		M.adjust_bodytemperature(-50)	//each hit will drop your body temp, so don't get surrounded!
		M.ExtinguishMob()	//bright side, they counter being on fire!

/obj/projectile/ornament
	name = "ornament"
	ru_names = list(
		NOMINATIVE = "орнамент",
		GENITIVE = "орнамента",
		DATIVE = "орнаменту",
		ACCUSATIVE = "орнамент",
		INSTRUMENTAL = "орнаментом",
		PREPOSITIONAL = "орнаменте"
	)
	icon_state = "ornament-1"
	hitsound = 'sound/effects/glasshit.ogg'
	damage = 7
	damage_type = BRUTE

/obj/projectile/ornament/New()
	icon_state = pick("ornament-1", "ornament-2")
	..()

/obj/projectile/ornament/on_hit(atom/target)	//knockback
	..()
	if(!istype(target, /mob))
		return 0
	var/obj/T = target
	var/throwdir = get_dir(firer,target)
	T.throw_at(get_edge_target_turf(target, throwdir),5,5) // 10,10 tooooo much
	return 1

/obj/projectile/mimic
	name = "googly-eyed gun"
	hitsound = 'sound/weapons/genhit1.ogg'
	damage = 0
	nodamage = TRUE
	damage_type = BURN
	flag = "melee"
	var/obj/item/gun/stored_gun

/obj/projectile/mimic/New(loc, mimic_type)
	..(loc)
	if(mimic_type)
		stored_gun = new mimic_type(src)
		icon = stored_gun.icon
		icon_state = stored_gun.icon_state
		overlays = stored_gun.overlays
		SpinAnimation(20, -1)

/obj/projectile/mimic/on_hit(atom/target)
	..()
	var/turf/T = get_turf(src)
	var/obj/item/gun/G = stored_gun
	stored_gun = null
	G.forceMove(T)
	var/mob/living/simple_animal/hostile/mimic/copy/ranged/R = new /mob/living/simple_animal/hostile/mimic/copy/ranged(T, G, firer)
	if(ismob(target))
		R.GiveTarget(target)

/obj/projectile/bullet/a84mm_hedp
	name ="HEDP rocket"
	desc = "ИСПОЛЬЗУЙ ПНЕВМАТИЧЕСКИЙ ПИСТОЛЕТ"
	icon_state= "84mm-hedp"
	damage = 80
	//shrapnel thing
	var/shrapnel_range = 5
	var/max_shrapnel = 5
	var/embed_prob = 100
	var/embedded_type = /obj/item/embedded/shrapnel
	speed = 0.8 //rockets need to be slower than bullets
	var/anti_armour_damage = 200
	armour_penetration = 100
	dismemberment = 100
	ricochets_max = 0

/obj/projectile/bullet/a84mm_hedp/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, devastation_range = -1, heavy_impact_range = 1, light_impact_range = 3, flash_range = 1, adminlog = FALSE, flame_range = 6)

	if(ismecha(target))
		var/obj/mecha/M = target
		M.take_damage(anti_armour_damage)
	if(issilicon(target))
		var/mob/living/silicon/S = target
		S.take_overall_damage(anti_armour_damage*0.75, anti_armour_damage*0.25)

	for(var/turf/T in view(shrapnel_range, loc))
		for(var/mob/living/carbon/human/H in T)
			var/shrapnel_amount = max_shrapnel - T.Distance(target)
			if(shrapnel_amount > 0)
				embed_shrapnel(H, shrapnel_amount)

/obj/projectile/bullet/a84mm_hedp/proc/embed_shrapnel(mob/living/carbon/human/H, amount)
	for(var/i = 0, i < amount, i++)
		if(prob(embed_prob - H.getarmor(attack_flag = BOMB)))
			var/obj/item/embedded/S = new embedded_type(src)
			H.hitby(S, skipcatch = 1)
			S.throwforce = 1
			S.throw_speed = 1
			S.sharp = FALSE
		else
			to_chat(H, span_warning("Шрапнель отскакивает от вашей брони!"))

/obj/projectile/bullet/a84mm_he
	name ="HE missile"
	desc = "Boom."
	icon_state = "84mm-he"
	damage = 30
	speed = 0.8
	ricochets_max = 0

/obj/projectile/bullet/a84mm_he/on_hit(atom/target, blocked=0)
	..()
	explosion(target, devastation_range = 1, heavy_impact_range = 3, light_impact_range = 5, flash_range = 7) //devastating

/obj/projectile/limb
	name = "limb"
	icon = 'icons/mob/human_races/r_human.dmi'
	icon_state = "l_arm"
	speed = 2
	range = 3
	flag = "melee"
	damage = 20
	damage_type = BRUTE
	stun = 0.5
	eyeblur = 20

/obj/projectile/limb/New(loc, var/obj/item/organ/external/limb)
	..(loc)
	if(istype(limb))
		name = limb.name
		icon = limb.icobase
		icon_state = limb.icon_name
