// MARK: Generic
/obj/projectile/temp
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

/obj/projectile/temp/get_ru_names()
	return list(
		NOMINATIVE = "температурный луч",
		GENITIVE = "температурного луча",
		DATIVE = "температурному лучу",
		ACCUSATIVE = "температурный луч",
		INSTRUMENTAL = "температурным лучом",
		PREPOSITIONAL = "температурном луче",
	)

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
				PREPOSITIONAL = "обжигающем луче",
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
				PREPOSITIONAL = "горящем луче",
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
				PREPOSITIONAL = "горячем луче",
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
				PREPOSITIONAL = "теплом луче",
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
				PREPOSITIONAL = "рассеянном луче",
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
				PREPOSITIONAL = "холодном луче",
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
				PREPOSITIONAL = "холодном луче",
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
				PREPOSITIONAL = "ледяном луче",
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
				PREPOSITIONAL = "замораживающем луче",
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
				PREPOSITIONAL = "температурном луче",
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
				target.smooth_body_temperature(target.bodytemperature + temp_diff * (1 - thermal_protection))
		else
			var/thermal_protection = target.get_heat_protection(temperature)
			if(thermal_protection < 1)
				target.smooth_body_temperature(target.bodytemperature + temp_diff * (1 - thermal_protection))
			else
				should_ignite = FALSE

	else if(target_is_living)
		target.smooth_body_temperature(temperature)

	if(should_ignite)
		target.adjust_fire_stacks(0.5)
		target.IgniteMob()
		playsound(target.loc, 'sound/effects/bamf.ogg', 50, FALSE)

// MARK: Basilisk
/obj/projectile/temp/basilisk
	name = "freezing blast"
	icon_state = "ice_2"
	temperature = 50

/obj/projectile/temp/basilisk/magmawing
	name = "scorching blast"
	icon_state = "lava"
	damage = 5
	nodamage = FALSE
	temperature = 700 //Heats you up!
	speed = 0.6

/obj/projectile/temp/basilisk/magmawing/get_ru_names()
	return list(
		NOMINATIVE = "опаляющий выброс",
		GENITIVE = "опаляющего выброса",
		DATIVE = "опаляющему выбросу",
		ACCUSATIVE = "опаляющий выброс",
		INSTRUMENTAL = "опаляющим выбросом",
		PREPOSITIONAL = "опаляющем выбросе",
	)

/obj/projectile/temp/basilisk/magmawing/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(.)
		var/mob/living/L = target
		if(istype(L))
			L.adjust_fire_stacks(3)
			L.IgniteMob()
			if(L.getFireLoss() > 50)
				explosion(L.loc, adminlog = FALSE, flame_range = 3)
				L.AdjustWeakened(1 SECONDS)

/obj/projectile/temp/basilisk/icewing
	damage = 5
	nodamage = FALSE
	speed = 0.6

/obj/projectile/temp/basilisk/icewing/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(.)
		var/mob/living/L = target
		if(istype(L))
			L.apply_status_effect(/datum/status_effect/freon/watcher)
