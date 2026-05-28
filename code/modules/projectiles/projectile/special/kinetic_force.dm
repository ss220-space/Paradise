/obj/projectile/kinetic
	name = "kinetic force"
	icon_state = null
	damage = 40
	hitsound = SFX_BULLET
	flag = BOMB
	range = 3
	/// How many `hardness` it takes from mineral turfs.
	var/power = 1
	/// Determines whether the pressure was low at the point of impact of the projectile and saves result here.
	var/pressure_decrease_active = FALSE
	/// The amount of damage we lost when shooting turfs with normal pressure.
	var/pressure_decrease = 0.25
	/// We keep the KA here to use the properties of its modkits when projectile hit the target.
	var/obj/item/gun/energy/kinetic_accelerator/kinetic_gun

/obj/projectile/kinetic/get_ru_names()
	return list(
		NOMINATIVE = "кинетическая сила",
		GENITIVE = "кинетической силы",
		DATIVE = "кинетической силе",
		ACCUSATIVE = "кинетическую силу",
		INSTRUMENTAL = "кинетической силой",
		PREPOSITIONAL = "кинетической силе"
	)

/obj/projectile/kinetic/Destroy()
	kinetic_gun = null
	return ..()

/obj/projectile/kinetic/prehit(atom/target)
	. = ..()
	if(.)
		if(kinetic_gun)
			for(var/obj/item/borg/upgrade/modkit/M in kinetic_gun.get_modkits())
				M.projectile_prehit(src, target, kinetic_gun)
		if(!lavaland_equipment_pressure_check(get_turf(target)))
			name = "weakened [name]"
			damage = damage * pressure_decrease
			pressure_decrease_active = TRUE

/obj/projectile/kinetic/on_range()
	strike_thing()
	..()

/obj/projectile/kinetic/on_hit(atom/target)
	strike_thing(target)
	. = ..()

/obj/projectile/kinetic/proc/strike_thing(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		target_turf = get_turf(src)
	if(kinetic_gun) // Hopefully whoever shot this was not very, very unfortunate.
		var/list/obj/item/borg/upgrade/modkit/mods = kinetic_gun.get_modkits()
		for(var/obj/item/borg/upgrade/modkit/M in mods)
			M.projectile_strike_predamage(src, target_turf, target, kinetic_gun)
		for(var/obj/item/borg/upgrade/modkit/M in mods)
			M.projectile_strike(src, target_turf, target, kinetic_gun)
	if(ismineralturf(target_turf))
		var/turf/simulated/mineral/mineral = target_turf
		mineral.attempt_drill(firer, FALSE, power)
	var/obj/effect/temp_visual/kinetic_blast/K = new /obj/effect/temp_visual/kinetic_blast(target_turf)
	K.color = color

/obj/projectile/kinetic/mech
	range = 5
	power = 3 // More power for the god of power!

/obj/projectile/kinetic/pod
	range = 4

/obj/projectile/kinetic/pod/regular
	damage = 50
	pressure_decrease = 0.5

/obj/projectile/kinetic/miner
	damage = 20
	speed = 0.9
	icon_state = "ka_tracer"
	range = MINER_DASH_RANGE

/obj/projectile/kinetic/miner/enraged
	damage = 35
