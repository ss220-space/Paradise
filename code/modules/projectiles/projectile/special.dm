/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	var/emp_range = 1
	impact_effect_type = /obj/effect/temp_visual/impact_effect/ion
	flag = "energy"
	hitsound = 'sound/weapons/tap.ogg'

/obj/item/projectile/ion/on_hit(var/atom/target, var/blocked = 0)
	. = ..()
	empulse(target, emp_range, emp_range, 1, cause = "[type] fired by [key_name(firer)]")
	return 1

/obj/item/projectile/ion/weak

/obj/item/projectile/ion/weak/on_hit(atom/target, blocked = 0)
	emp_range = 0
	. = ..()
	return 1

/obj/item/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50
	flag = "bullet"

/obj/item/projectile/bullet/gyro/on_hit(var/atom/target, var/blocked = 0)
	..()
	explosion(target, -1, 0, 2, cause = "[type] fired by [key_name(firer)]")
	return 1

/obj/item/projectile/bullet/a40mm
	name ="40mm grenade"
	desc = "USE A WEEL GUN"
	icon_state= "bolter"
	damage = 60
	flag = "bullet"

/obj/item/projectile/bullet/a40mm/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, -1, 0, 2, 1, 0, flame_range = 3, cause = "[type] fired by [key_name(firer)]")
	return 1

/obj/item/projectile/temp
	name = "temperature beam"
	icon_state = "temp_4"
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	reflectability = REFLECTABILITY_ENERGY
	flag = "energy"
	var/temperature = 300
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	hitsound = 'sound/weapons/tap.ogg'

/obj/item/projectile/temp/New(loc, shot_temp)
	..()
	if(!isnull(shot_temp))
		temperature = shot_temp
	switch(temperature)
		if(501 to INFINITY)
			name = "searing beam"	//if emagged
			icon_state = "temp_8"
		if(400 to 500)
			name = "burning beam"	//temp at which mobs start taking HEAT_DAMAGE_LEVEL_2
			icon_state = "temp_7"
		if(360 to 400)
			name = "hot beam"		//temp at which mobs start taking HEAT_DAMAGE_LEVEL_1
			icon_state = "temp_6"
		if(335 to 360)
			name = "warm beam"		//temp at which players get notified of their high body temp
			icon_state = "temp_5"
		if(295 to 335)
			name = "ambient beam"
			icon_state = "temp_4"
		if(260 to 295)
			name = "cool beam"		//temp at which players get notified of their low body temp
			icon_state = "temp_3"
		if(200 to 260)
			name = "cold beam"		//temp at which mobs start taking COLD_DAMAGE_LEVEL_1
			icon_state = "temp_2"
		if(120 to 260)
			name = "ice beam"		//temp at which mobs start taking COLD_DAMAGE_LEVEL_2
			icon_state = "temp_1"
		if(-INFINITY to 120)
			name = "freeze beam"	//temp at which mobs start taking COLD_DAMAGE_LEVEL_3
			icon_state = "temp_0"
		else
			name = "temperature beam"//failsafe
			icon_state = "temp_4"


/obj/item/projectile/temp/on_hit(mob/living/carbon/human/target, blocked = 0, hit_zone)
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


/obj/item/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small"
	damage = 0
	damage_type = BRUTE
	nodamage = TRUE
	flag = "bullet"
	hitsound = 'sound/effects/meteorimpact.ogg'


/obj/item/projectile/meteor/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	if(blocked >= 100)
		return FALSE
	for(var/mob/mob in urange(10, src))
		if(!mob.stat)
			shake_camera(mob, 3, 1)

// FLORAGUN
/obj/item/projectile/energy/floraalpha
	name = "alpha somatoray"
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

/obj/item/projectile/energy/floraalpha/prehit(atom/target)
	if(target && !HAS_TRAIT(target, TRAIT_PLANT_ORIGIN)) // burn damage for only plant
		damage = 0
	. = ..()

/obj/item/projectile/energy/floraalpha/on_range()
	strike_thing()
	. = ..()

/obj/item/projectile/energy/floraalpha/on_hit(atom/target, blocked = 0, hit_zone)
	strike_thing(target)
	. = ..()

/obj/item/projectile/energy/floraalpha/proc/strike_thing(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		target_turf = get_turf(src)
	new /obj/effect/temp_visual/explosion/florawave(target_turf)
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

/obj/item/projectile/energy/floraalpha/emag
	range = 9
	damage = 15
	fire_stacks = 10

/obj/item/projectile/energy/florabeta
	name = "beta somatoray"
	icon_state = "energy"
	damage = 0
	hitsound = 'sound/weapons/tap.ogg'
	damage_type = TOX
	nodamage = TRUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	flag = "energy"

/obj/item/projectile/energy/floragamma
	name = "gamma somatoray"
	icon_state = "energy2"
	damage = 0
	hitsound = 'sound/weapons/tap.ogg'
	damage_type = TOX
	nodamage = TRUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	flag = "energy"

/obj/item/projectile/beam/mindflayer
	name = "flayer ray"

/obj/item/projectile/beam/mindflayer/on_hit(var/atom/target, var/blocked = 0)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		M.apply_damage(20, BRAIN)
		M.AdjustHallucinate(20 SECONDS)
		M.last_hallucinator_log = name

/obj/item/projectile/clown
	name = "snap-pop"
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"
	nodamage = TRUE
	damage = 0


/obj/item/projectile/clown/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	if(blocked >= 100)
		return .
	do_sparks(3, 1, target)
	target.visible_message(span_warning("The [name] explodes!"))
	playsound(target, 'sound/effects/snap.ogg', 50, TRUE)
	if(isturf(target.loc) && !target.loc.density)
		new /obj/effect/decal/cleanable/ash(target.loc)


/obj/item/projectile/beam/wormhole
	name = "bluespace beam"
	icon_state = "spark"
	hitsound = "sparks"
	damage = 0
	color = "#33CCFF"
	nodamage = TRUE
	var/is_orange = FALSE

/obj/item/projectile/beam/wormhole/orange
	name = "orange bluespace beam"
	color = "#FF6600"
	is_orange = TRUE

/obj/item/projectile/beam/wormhole/on_hit(atom/target)
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

/obj/item/projectile/bullet/frag12
	name ="explosive slug"
	damage = 25
	weaken = 10 SECONDS

/obj/item/projectile/bullet/frag12/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, -1, 0, 1, cause = src)
	return 1

/obj/item/projectile/plasma
	name = "plasma blast"
	icon_state = "plasmacutter"
	damage_type = BRUTE
	damage = 5
	hitsound = "bullet"
	range = 3
	dismemberment = 20
	dismember_limbs = TRUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser

/obj/item/projectile/plasma/on_hit(atom/target, pointblank = 0)
	. = ..()
	if(ismineralturf(target))
		if(isancientturf(target))
			visible_message("<span class='notice'>This rock appears to be resistant to all mining tools except pickaxes!</span>")
			forcedodge = 0
			return
		forcedodge = 1
		var/turf/simulated/mineral/M = target
		M.attempt_drill(firer)
	else
		forcedodge = 0

/obj/item/projectile/plasma/adv
	damage = 7
	range = 5

/obj/item/projectile/plasma/adv/mega
	icon_state = "plasmacutter_mega"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	range = 7

/obj/item/projectile/plasma/adv/mega/on_hit(atom/target)
	if(istype(target, /turf/simulated/mineral/gibtonite))
		var/turf/simulated/mineral/gibtonite/gib = target
		gib.defuse()
	. = ..()

/obj/item/projectile/plasma/adv/mega/shotgun
	damage = 2
	range = 6
	dismemberment = 0

/obj/item/projectile/plasma/adv/mech
	damage = 10
	range = 9

/obj/item/projectile/plasma/shotgun
	damage = 2
	range = 4
	dismemberment = 0

/obj/item/projectile/energy/teleport
	name = "teleportation burst"
	icon_state = "bluespace"
	damage = 0
	nodamage = TRUE
	var/teleport_target = null

/obj/item/projectile/energy/teleport/New(loc, tele_target)
	..(loc)
	if(tele_target)
		teleport_target = tele_target

/obj/item/projectile/energy/teleport/on_hit(var/atom/target, var/blocked = 0)
	if(isliving(target))
		if(teleport_target)
			do_teleport(target, teleport_target, 0)//teleport what's in the tile to the beacon
		else
			do_teleport(target, target, 15) //Otherwise it just warps you off somewhere.
	add_attack_logs(firer, target, "Shot with a [type] [teleport_target ? "(Destination: [teleport_target])" : ""]")

/obj/item/projectile/snowball
	name = "snowball"
	icon_state = "snowball"
	hitsound = 'sound/items/dodgeball.ogg'
	damage = 4
	damage_type = BURN

/obj/item/projectile/snowball/on_hit(atom/target)	//chilling
	. = ..()
	if(isliving(target))
		var/mob/living/M = target
		M.adjust_bodytemperature(-50)	//each hit will drop your body temp, so don't get surrounded!
		M.ExtinguishMob()	//bright side, they counter being on fire!

/obj/item/projectile/ornament
	name = "ornament"
	icon_state = "ornament-1"
	hitsound = 'sound/effects/glasshit.ogg'
	damage = 7
	damage_type = BRUTE

/obj/item/projectile/ornament/New()
	icon_state = pick("ornament-1", "ornament-2")
	..()

/obj/item/projectile/ornament/on_hit(atom/target)	//knockback
	..()
	if(!istype(target, /mob))
		return 0
	var/obj/T = target
	var/throwdir = get_dir(firer,target)
	T.throw_at(get_edge_target_turf(target, throwdir),5,5) // 10,10 tooooo much
	return 1

/obj/item/projectile/mimic
	name = "googly-eyed gun"
	hitsound = 'sound/weapons/genhit1.ogg'
	damage = 0
	nodamage = TRUE
	damage_type = BURN
	flag = "melee"
	var/obj/item/gun/stored_gun

/obj/item/projectile/mimic/New(loc, mimic_type)
	..(loc)
	if(mimic_type)
		stored_gun = new mimic_type(src)
		icon = stored_gun.icon
		icon_state = stored_gun.icon_state
		overlays = stored_gun.overlays
		SpinAnimation(20, -1)

/obj/item/projectile/mimic/on_hit(atom/target)
	..()
	var/turf/T = get_turf(src)
	var/obj/item/gun/G = stored_gun
	stored_gun = null
	G.forceMove(T)
	var/mob/living/simple_animal/hostile/mimic/copy/ranged/R = new /mob/living/simple_animal/hostile/mimic/copy/ranged(T, G, firer)
	if(ismob(target))
		R.GiveTarget(target)

/obj/item/projectile/bullet/a84mm_hedp
	name ="\improper HEDP rocket"
	desc = "USE A WEEL GUN"
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

/obj/item/projectile/bullet/a84mm_hedp/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, -1, 1, 3, 1, 0, flame_range = 6)

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

/obj/item/projectile/bullet/a84mm_hedp/proc/embed_shrapnel(mob/living/carbon/human/H, amount)
	for(var/i = 0, i < amount, i++)
		if(prob(embed_prob - H.getarmor(attack_flag = BOMB)))
			var/obj/item/embedded/S = new embedded_type(src)
			H.hitby(S, skipcatch = 1)
			S.throwforce = 1
			S.throw_speed = 1
			S.sharp = FALSE
		else
			to_chat(H, "<span class='warning'>Shrapnel bounces off your armor!</span>")

/obj/item/projectile/bullet/a84mm_he
	name ="\improper HE missile"
	desc = "Boom."
	icon_state = "84mm-he"
	damage = 30
	speed = 0.8
	ricochets_max = 0

/obj/item/projectile/bullet/a84mm_he/on_hit(atom/target, blocked=0)
	..()
	explosion(target, 1, 3, 5, 7) //devastating

/obj/item/projectile/limb
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

/obj/item/projectile/limb/New(loc, var/obj/item/organ/external/limb)
	..(loc)
	if(istype(limb))
		name = limb.name
		icon = limb.icobase
		icon_state = limb.icon_name
