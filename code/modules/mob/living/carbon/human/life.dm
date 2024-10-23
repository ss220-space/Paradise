/mob/living/carbon/human/Life(seconds, times_fired)
	set invisibility = 0

	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return

	. = ..()

	if(QDELETED(src))
		return FALSE

	life_tick++

	voice = GetVoice()
	tts_seed = GetTTSVoice()

	if(.) //not dead

		handle_pain()
		handle_heartbeat()
		dna.species.handle_life(src)
		if(!client)
			dna.species.handle_npc(src)

	if(stat != DEAD)
		//Stuff jammed in your limbs hurts
		handle_embedded_objects()

	if(stat == DEAD)
		handle_decay()
		if(isnucleation(src))
			dna.species.handle_death(FALSE, src)

	//Update our name based on whether our face is obscured/disfigured
	name = get_visible_name()
	pulse = handle_pulse(times_fired)

	var/datum/antagonist/vampire/vamp = mind?.has_antag_datum(/datum/antagonist/vampire)
	if(vamp && life_tick == 1)
		regenerate_icons() // Make sure the inventory updates

	var/datum/antagonist/ninja/ninja = mind?.has_antag_datum(/datum/antagonist/ninja)
	if(ninja)
		ninja.handle_ninja()
		if(life_tick == 1)
			regenerate_icons() // Make sure the inventory updates

	if(player_ghosted > 0 && stat == CONSCIOUS && job && !HAS_TRAIT(src, TRAIT_RESTRAINED))
		handle_ghosted()

	if(stat != DEAD)
		return TRUE

/mob/living/carbon/human/proc/handle_ghosted()
	if(key)
		player_ghosted = 0
	else
		player_ghosted++
		if(player_ghosted % 150 == 0)
			force_cryo_human(src)


/mob/living/carbon/human/handle_SSD(seconds_per_tick)
	. = ..()
	if(!. || !job || istype(loc, /obj/machinery/cryopod) || !CONFIG_GET(number/auto_cryo_ssd_mins))
		return .

	if(player_logged < (CONFIG_GET(number/auto_cryo_ssd_mins) MINUTES))
		return .

	var/turf/our_turf = get_turf(src)
	if(!our_turf || !is_station_level(our_turf.z))
		return .

	cryo_ssd(src)
	var/area/our_area = get_area(src)
	if(our_area.fast_despawn)
		force_cryo_human(src)


/mob/living/carbon/human/calculate_affecting_pressure(pressure)
	var/pressure_difference = abs( pressure - ONE_ATMOSPHERE )

	// Determines how much the clothing you are wearing protects you in percent.
	var/pressure_adjustment_coefficient = 1
	if(isclothing(wear_suit) && isclothing(head))
		var/obj/item/clothing/suit = wear_suit
		var/obj/item/clothing/helmet = head
		// Complete set of pressure-proof suit worn, assume fully sealed.
		if((suit.clothing_flags & STOPSPRESSUREDMAGE) && (helmet.clothing_flags & STOPSPRESSUREDMAGE))
			pressure_adjustment_coefficient = 0
	pressure_adjustment_coefficient = max(pressure_adjustment_coefficient,0) //So it isn't less than 0
	pressure_difference = pressure_difference * pressure_adjustment_coefficient
	if(pressure > ONE_ATMOSPHERE)
		return ONE_ATMOSPHERE + pressure_difference
	else
		return ONE_ATMOSPHERE - pressure_difference


/mob/living/carbon/human/handle_disabilities()
	//Vision //god knows why this is here
	var/obj/item/organ/vision = dna?.species?.get_vision_organ(src)
	if(vision == NO_VISION_ORGAN)
		SetEyeBlind(0)
		SetEyeBlurry(0)
	else if(!vision || vision.is_traumatized())	// Vision organs cut out or broken? Permablind.
		SetEyeBlind(4 SECONDS)

	if(getBrainLoss() >= 60 && stat != DEAD)
		if(prob(3))
			var/list/s1 = list("Я [pick("ПОНИ","ЯЩЕР","ТАЯРА","КОТЁНОК","ВУЛЬП","ДРАСК","ПТИЧКА","ВОКСИК","МАШИНА","БОЕВОЙ МЕХ","РАКЕТА")] [pick("НЬЕЕЕЕЕЕЕЕЕЕ","СКРЭЭЭЭЭЭЭЭЭ","МЯУ","НЯ~","РАВР","ГАВ-ГАВ","ХИССССС","ВРУУУМ-ВРУУУУМ","ПИУ-ПИУ","ЧУ-ЧУ")]!",
							   "Без кислорода блоб не распространяется?",
							   "КАПИТАН - КОМДОН",
							   "[pick("", "Этот чёртов маньяк,")] [pick("Жордж", "Джордж", "Горж", "Грудж")] [pick("Меленс", "Мэлонс", "Мвырлнс")] убивает меня ПАМА;ГИТЕ!!!",
							   "Можишь пж дать [pick("теликенез","халга","эпелепсию")]?",
							   "ООООО МОЯ ОБОРОНА",
							   "Джонни, эти синдикатовцы даже в СБ!",
							   "Блоп в турбине",
							   "не бей пж!11!",
							   "АХАХААХАХАХАХАХАХХАХХАХАХ!",
							   "ПАМАГИТЕ ЩЕТКУРИТИ",
							   "ВОКсЫ нЕ мОГут ЛюБИТь",
							   "Мой папа владеет этой станцией",
							   "Повар добавил [pick("ПРОТЕИН", "туолетную воду", "муравьёв", "энзимы","акулу","виТамины","РеАктивный МутАген","ТеСлиум","сКрэКтониум")] в [pick("мой суп","мою шОверму","мой рЭйнбургер","мой зеЛёный Сольент","мои СушИ","мой борш")]!",
							   "У ОБЕЗЬЯН ТАЗЕРЫ!",
							   "кМ потраТел мои ;поенты на [pick("бОевые дробавики","ризИновые перЧатке","кУчу херни!")]",
							   "EI'NATH!",
							   "ПОДЪЁМ ХРЮШКИ!",
							   "эта [pick("был мой младшей брат!!","была мая невеста","был мой осТавшЕйся друк","был Мой деДдом","былА мая люБов","была моя жена","был мой муж","маИ малЕнькие ДеТи","МаЯ разУмнАя коШка","быЛ мой косЯк")]!!!")

			var/list/s2 = list("ФУС РО ДА",
							   "Гребаные мандарины!!!",
							   "Праверь меня",
							   "Моё лицо!",
							   "СПОКОЙНО БЛЯТЬ!",
							   "ВАААААААААГХ!!!",
							   "Папробуй догани!",
							   "ЗА ИМПЕРАТОРА!",
							   "У кЛоунА лиМитка!",
							   "это всё дварфы, чел, всё дварфы",
							   "СПЕЙС МАРИНЫ",
							   "Мввыы ссдееллалии этво вво имя хаосса",
							   "Фотареалистичные тикстуры",
							   "Любоф цвятёт",
							   "ПАКЕТЫ!!!",
							   "[pick("ГДЕ МОЙ","МНЕ НУЖЕН","ДАЙ МНЕ МОЙ","ОКУНИ МЕНЯ В")] [pick("ДЕРМАЛИН","АЛКИЗИН","ДИЛОВИН","ИНАПРОВАЛИН","БИКАРДИН","ГИПЕРЗИН","КЕЛОТАН","ЛЕПОРАЗИН","СОЛЬ","МАННИТОЛ","КРИОКСАДОН","СПЕЙС ЛУБ","КАППУЛЕТИУМ","ЛСД")]!",
							   "ВоИмЯФлАфИ",
							   "У меНя еСтЬ Лююди на Цк!!!",
							   "П-п-помогите т-т-теха",
							   "Ани идут, ани ИДУТ! АНИ ИДУТ!!!",
							   "КОНЕЦ БЛИЗОК!",
							   "Помогите [pick("маг","убийца","генокрад","культ","морф","демон","нюка","вампир!","воксы!","клоун!")] [pick("в турбине","на мостике","на ЦК","в медбее","в бриге","в инженерке","на базе синдиката","на спутнике ИИ","в моей голове","в дормах")]!",
							   "Я ГОТОВ УМЕРЕТЬ ВО ИМЯ [pick("РИТУАЛА","СВОБОДЫ","ЗАРПЛАТЫ","ОЧКОВ","ТЕХНОЛОГИЙ","СОБАКИ","СИРОПА","ПУШИСТЫХ ДРУЗЕЙ","ЛУТА ИЗ ГЕЙТА")]",
							   "УБИЙ ИХ, [pick("ПЕТУХ","КИРА-КЛОЙН","КЛУВНИ","МИМАНЬЯК","БОМБЯЩИЯ ТАЯРА","ОФЕЦЕР","МОРФЛЕНГ","НАС-РИ")]!")
			switch(pick(1,2,3))
				if(1)
					say(pick(s1))
				if(2)
					say(pick(s2))
				if(3)
					emote("drool")

/mob/living/carbon/human/handle_mutations_and_radiation()
	for(var/datum/dna/gene/gene as anything in GLOB.dna_genes)
		if(gene.is_active(src))
			gene.OnMobLife(src)
	if(!ignore_gene_stability && gene_stability < GENETIC_DAMAGE_STAGE_1)
		var/instability = DEFAULT_GENE_STABILITY - gene_stability
		if(prob(instability * 0.1))
			adjustFireLoss(min(5, instability * 0.67))
			to_chat(src, "<span class='danger'>You feel like your skin is burning and bubbling off!</span>")
		if(gene_stability < GENETIC_DAMAGE_STAGE_2)
			if(prob(instability * 0.83))
				adjustCloneLoss(min(4, instability * 0.05))
				to_chat(src, "<span class='danger'>You feel as if your body is warping.</span>")
			if(prob(instability * 0.1))
				adjustToxLoss(min(5, instability * 0.67))
				to_chat(src, "<span class='danger'>You feel weak and nauseous.</span>")
			if(gene_stability < GENETIC_DAMAGE_STAGE_3 && prob(1))
				to_chat(src, "<span class='biggerdanger'>You feel incredibly sick... Something isn't right!</span>")
				spawn(300)
					if(gene_stability < GENETIC_DAMAGE_STAGE_3)
						gib()

	if(radiation)
		if(isnucleation(src))
			radiation = clamp(radiation, 0, 800) // Типа кристаллы СМ лучше вбирают радиацию и поэтому у нуклей больший запас, а так - что бы эффекты снизу вообще работали
			switch(radiation)
				if(1 to 399)
					radiation = max(radiation-1, 0) // Что бы не копилась бесконечно малое кол-во, но все ещё можно было получать эффект снизу при достаточном облучении
					return
				if(400 to INFINITY)
					if(prob(50))
						reagents.add_reagent("radium", 1)
						radiation = max(radiation-50, 0)
						return

		if(!HAS_TRAIT(src, TRAIT_RADIMMUNE))
			radiation = clamp(radiation, 0, 200)

			var/autopsy_damage = 0
			switch(radiation)
				if(1 to 49)
					radiation = max(radiation-1, 0)
					if(prob(25))
						apply_damages(burn = 1, tox = 1, spread_damage = TRUE)
						autopsy_damage = 2

				if(50 to 74)
					radiation = max(radiation-2, 0)
					apply_damages(burn = 1, tox = 1, spread_damage = TRUE)
					autopsy_damage = 2
					if(prob(5))
						radiation = max(radiation-5, 0)
						Weaken(6 SECONDS)
						to_chat(src, "<span class='danger'>You feel weak.</span>")
						emote("collapse")

				if(75 to 100)
					radiation = max(radiation-2, 0)
					apply_damages(burn = 2, tox = 2, spread_damage = TRUE)
					autopsy_damage = 4
					if(prob(2))
						to_chat(src, "<span class='danger'>You mutate!</span>")
						randmutb(src)
						check_genes()

				if(101 to 150)
					radiation = max(radiation-3, 0)
					apply_damages(burn = 3, tox = 2, spread_damage = TRUE)
					autopsy_damage = 5
					if(prob(4))
						to_chat(src, "<span class='danger'>You mutate!</span>")
						randmutb(src)
						check_genes()

				if(151 to INFINITY)
					radiation = max(radiation-3, 0)
					apply_damages(burn = 3, tox = 2, spread_damage = TRUE)
					autopsy_damage = 5
					if(prob(6))
						to_chat(src, "<span class='danger'>You mutate!</span>")
						randmutb(src)
						check_genes()

			if(autopsy_damage)
				var/obj/item/organ/external/chest/chest = get_organ(BODY_ZONE_CHEST)
				if(chest)
					chest.add_autopsy_data("Radiation Poisoning", autopsy_damage)

/mob/living/carbon/human/breathe()
	if(!dna.species.breathe(src))
		..()


/mob/living/carbon/human/check_breath(datum/gas_mixture/breath)

	var/obj/item/organ/internal/lungs = get_organ_slot(INTERNAL_ORGAN_LUNGS)

	if(!lungs || (lungs && lungs.is_dead()))
		if(health >= HEALTH_THRESHOLD_CRIT)
			adjustOxyLoss(HUMAN_MAX_OXYLOSS + 1)
		else
			adjustOxyLoss(HUMAN_MAX_OXYLOSS)

		if(dna.species)
			var/datum/species/species = dna.species

			if(species.breathid == "o2")
				throw_alert(ALERT_NOT_ENOUGH_OXYGEN, /atom/movable/screen/alert/not_enough_oxy)
			else if(species.breathid == "tox")
				throw_alert(ALERT_NOT_ENOUGH_TOX, /atom/movable/screen/alert/not_enough_tox)
			else if(species.breathid == "co2")
				throw_alert( ALERT_NOT_ENOUGH_CO2, /atom/movable/screen/alert/not_enough_co2)
			else if(species.breathid == "n2")
				throw_alert(ALERT_NOT_ENOUGH_NITRO, /atom/movable/screen/alert/not_enough_nitro)

		return FALSE
	else if(istype(lungs, /obj/item/organ/internal/lungs))
		var/obj/item/organ/internal/lungs/really_lungs = lungs
		really_lungs.check_breath(breath, src)


// USED IN DEATHWHISPERS
/mob/living/carbon/human/proc/isInCrit()
	// Health is in deep shit and we're not already dead
	return health <= HEALTH_THRESHOLD_CRIT && stat != DEAD


/mob/living/carbon/human/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return

	var/loc_temp = get_temperature(environment)
//	to_chat(world, "Loc temp: [loc_temp] - Body temp: [bodytemperature] - Fireloss: [getFireLoss()] - Thermal protection: [get_main_thermal_protection()] - Fire protection: [thermal_protection + add_fire_protection(loc_temp)] - Heat capacity: [environment_heat_capacity] - Location: [loc] - src: [src]")

	//Body temperature is adjusted in two steps. Firstly your body tries to stabilize itself a bit.
	if(stat != DEAD)
		body_thermal_regulation(loc_temp)

	// After then, it reacts to the surrounding atmosphere based on your thermal protection
	// If we are on fire, we do not heat up or cool down based on surrounding gases
	// Works only if environment temperature is not comfortable for our species
	if(!on_fire && (loc_temp < dna.species.cold_level_1 || loc_temp > dna.species.heat_level_1 || bodytemperature <= dna.species.cold_level_1 || bodytemperature >= dna.species.heat_level_1))
		if(loc_temp < bodytemperature)
			//Place is colder than we are
			var/thermal_protection = get_cold_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				adjust_bodytemperature(max((1-thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_COLD_DIVISOR), BODYTEMP_COOLING_MAX))
		else
			//Place is hotter than we are
			var/thermal_protection = get_heat_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				adjust_bodytemperature(min((1-thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR), BODYTEMP_HEATING_MAX))

	// +/- 50 degrees from 310.15K is the 'safe' zone, where no damage is dealt.
	if(bodytemperature > dna.species.heat_level_1)
		//Body temperature is too hot.
		if(HAS_TRAIT(src, TRAIT_GODMODE))
			return TRUE	//godmode
		var/mult = dna.species.heatmod * physiology.heat_mod
		if(mult>0)
			if(bodytemperature >= dna.species.heat_level_1 && bodytemperature <= dna.species.heat_level_2)
				throw_alert("temp", /atom/movable/screen/alert/hot, 1)
				take_overall_damage(burn=mult*HEAT_DAMAGE_LEVEL_1, used_weapon = "High Body Temperature")
			if(bodytemperature > dna.species.heat_level_2 && bodytemperature <= dna.species.heat_level_3)
				throw_alert("temp", /atom/movable/screen/alert/hot, 2)
				take_overall_damage(burn=mult*HEAT_DAMAGE_LEVEL_2, used_weapon = "High Body Temperature")
			if(bodytemperature > dna.species.heat_level_3 && bodytemperature < INFINITY)
				throw_alert("temp", /atom/movable/screen/alert/hot, 3)
				if(on_fire)
					take_overall_damage(burn=mult*HEAT_DAMAGE_LEVEL_3, used_weapon = "Fire")
				else
					take_overall_damage(burn=mult*HEAT_DAMAGE_LEVEL_2, used_weapon = "High Body Temperature")
		else
			mult = abs(mult)
			if(bodytemperature >= dna.species.heat_level_1 && bodytemperature <= dna.species.heat_level_2)
				heal_overall_damage(burn=mult*HEAT_DAMAGE_LEVEL_1)
			if(bodytemperature > dna.species.heat_level_2 && bodytemperature <= dna.species.heat_level_3)
				heal_overall_damage(burn=mult*HEAT_DAMAGE_LEVEL_2)
			if(bodytemperature > dna.species.heat_level_3 && bodytemperature < INFINITY)
				heal_overall_damage(burn=mult*HEAT_DAMAGE_LEVEL_3)

	else if(bodytemperature < dna.species.cold_level_1)
		if(HAS_TRAIT(src, TRAIT_GODMODE))
			return TRUE
		if(stat == DEAD)
			return TRUE

		if(!istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
			var/mult = dna.species.coldmod * physiology.cold_mod
			if(mult>0)
				add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/cold, multiplicative_slowdown = ((dna.species.cold_level_1 - bodytemperature) / COLD_SLOWDOWN_FACTOR))
				if(bodytemperature < dna.species.cold_level_2 && prob(0.3))
					var/datum/disease/virus/cold/D = new
					D.Contract(src)
				if(bodytemperature >= dna.species.cold_level_2 && bodytemperature <= dna.species.cold_level_1)
					throw_alert("temp", /atom/movable/screen/alert/cold, 1)
					take_overall_damage(burn=mult*COLD_DAMAGE_LEVEL_1, used_weapon = "Low Body Temperature")
				if(bodytemperature >= dna.species.cold_level_3 && bodytemperature < dna.species.cold_level_2)
					throw_alert("temp", /atom/movable/screen/alert/cold, 2)
					take_overall_damage(burn=mult*COLD_DAMAGE_LEVEL_2, used_weapon = "Low Body Temperature")
				if(bodytemperature > -INFINITY && bodytemperature < dna.species.cold_level_3)
					throw_alert("temp", /atom/movable/screen/alert/cold, 3)
					take_overall_damage(burn=mult*COLD_DAMAGE_LEVEL_3, used_weapon = "Low Body Temperature")
				else
					clear_alert("temp")
			else
				mult = abs(mult)
				if(bodytemperature >= dna.species.cold_level_2 && bodytemperature <= dna.species.cold_level_1)
					heal_overall_damage(burn=mult*COLD_DAMAGE_LEVEL_1)
				if(bodytemperature >= dna.species.cold_level_3 && bodytemperature < dna.species.cold_level_2)
					heal_overall_damage(burn=mult*COLD_DAMAGE_LEVEL_2)
				if(bodytemperature > -INFINITY && bodytemperature < dna.species.cold_level_3)
					heal_overall_damage(burn=mult*COLD_DAMAGE_LEVEL_3)
				else
					clear_alert("temp")
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/cold)
		clear_alert("temp")

	// Account for massive pressure differences.  Done by Polymorph
	// Made it possible to actually have something that can protect against high pressure... Done by Errorage. Polymorph now has an axe sticking from his head for his previous hardcoded nonsense!

	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return TRUE	//godmode

	if(adjusted_pressure >= dna.species.hazard_high_pressure)
		if(HAS_TRAIT(src, TRAIT_RESIST_HEAT))
			clear_alert("pressure")
		else
			var/pressure_damage = min( ( (adjusted_pressure / dna.species.hazard_high_pressure) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE) * physiology.pressure_mod * physiology.brute_mod
			take_overall_damage(brute = pressure_damage, used_weapon = "High Pressure")
			throw_alert("pressure", /atom/movable/screen/alert/highpressure, 2)

	else if(adjusted_pressure >= dna.species.warning_high_pressure)
		throw_alert("pressure", /atom/movable/screen/alert/highpressure, 1)
	else if(adjusted_pressure >= dna.species.warning_low_pressure)
		clear_alert("pressure")
	else if(adjusted_pressure >= dna.species.hazard_low_pressure)
		throw_alert("pressure", /atom/movable/screen/alert/lowpressure, 1)
	else
		if(HAS_TRAIT(src, TRAIT_RESIST_COLD))
			clear_alert("pressure")
		else
			var/pressure_damage = LOW_PRESSURE_DAMAGE * physiology.pressure_mod * physiology.brute_mod
			take_overall_damage(brute = pressure_damage, used_weapon = "Low Pressure")
			throw_alert("pressure", /atom/movable/screen/alert/lowpressure, 2)


///FIRE CODE
/mob/living/carbon/human/handle_fire()
	. = ..()
	if(!. || HAS_TRAIT(src, TRAIT_RESIST_HEAT))
		return
	var/thermal_protection_main = get_main_thermal_protection()
	var/thermal_protection_secondary = get_secondary_thermal_protection()

	if(thermal_protection_main >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
		return

	if(thermal_protection_main >= FIRE_SUIT_MAX_TEMP_PROTECT)
		adjust_bodytemperature(11 * (1 - thermal_protection_secondary))
	else
		adjust_bodytemperature((BODYTEMP_HEATING_MAX + (fire_stacks * 12)) * (1 - thermal_protection_secondary))
		var/datum/antagonist/vampire/vamp = mind?.has_antag_datum(/datum/antagonist/vampire)
		if(vamp && !vamp.get_ability(/datum/vampire_passive/full) && stat != DEAD)
			vamp.bloodusable = max(vamp.bloodusable - 5, 0)


/mob/living/carbon/human/proc/get_main_thermal_protection()
	if(HAS_TRAIT(src, TRAIT_RESIST_HEAT))
		return FIRE_IMMUNITY_MAX_TEMP_PROTECT

	var/thermal_protection = 0 //Simple check to estimate how protected we are against multiple temperatures
	if(wear_suit)
		if(wear_suit.max_heat_protection_temperature >= FIRE_SUIT_MAX_TEMP_PROTECT)
			thermal_protection += (wear_suit.max_heat_protection_temperature*0.7)
	if(head)
		if(head.max_heat_protection_temperature >= FIRE_HELM_MAX_TEMP_PROTECT)
			thermal_protection += (head.max_heat_protection_temperature*THERMAL_PROTECTION_HEAD)
	thermal_protection = round(thermal_protection)
	return thermal_protection

/mob/living/carbon/human/proc/get_secondary_thermal_protection()
	var/result = 0

	result += getarmor(BODY_ZONE_HEAD, FIRE) / 100 * THERMAL_PROTECTION_HEAD
	result += getarmor(BODY_ZONE_CHEST, FIRE) / 100 * THERMAL_PROTECTION_UPPER_TORSO
	result += getarmor(BODY_ZONE_PRECISE_GROIN, FIRE) / 100 * THERMAL_PROTECTION_LOWER_TORSO

	result += getarmor(BODY_ZONE_L_ARM, FIRE) / 100 * THERMAL_PROTECTION_ARM_LEFT
	result += getarmor(BODY_ZONE_PRECISE_L_HAND, FIRE) / 100 * THERMAL_PROTECTION_HAND_LEFT
	result += getarmor(BODY_ZONE_R_ARM, FIRE) / 100 * THERMAL_PROTECTION_ARM_RIGHT
	result += getarmor(BODY_ZONE_PRECISE_R_HAND, FIRE) / 100 * THERMAL_PROTECTION_HAND_RIGHT

	result += getarmor(BODY_ZONE_L_LEG, FIRE) / 100 * THERMAL_PROTECTION_LEG_LEFT
	result += getarmor(BODY_ZONE_PRECISE_L_FOOT, FIRE) / 100 * THERMAL_PROTECTION_FOOT_LEFT
	result += getarmor(BODY_ZONE_R_LEG, FIRE) / 100 * THERMAL_PROTECTION_LEG_RIGHT
	result += getarmor(BODY_ZONE_PRECISE_R_FOOT, FIRE) / 100 * THERMAL_PROTECTION_FOOT_RIGHT

	return result

//END FIRE CODE

/mob/living/carbon/human/proc/body_thermal_regulation(loc_temp)
	var/body_temperature_difference = dna.species.body_temperature - bodytemperature

	if(bodytemperature <= dna.species.cold_level_1) //260.15 is 310.15 - 50, the temperature where you start to feel effects.
		adjust_bodytemperature(max(metabolism_efficiency * (body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_AUTORECOVERY_MINIMUM))
	if(bodytemperature >= dna.species.heat_level_1) //360.15 is 310.15 + 50, the temperature where you start to feel effects.
		adjust_bodytemperature(min(metabolism_efficiency * (body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), -BODYTEMP_AUTORECOVERY_MINIMUM))	//We're dealing with negative numbers

	// simple thermal regulation when the body temperature is OK for our species
	if(bodytemperature > dna.species.cold_level_1 && bodytemperature < dna.species.heat_level_1)
		// if environment temperature is within the safe levels we are using it to shift recovery slightly
		var/enviro_shift = (loc_temp < dna.species.heat_level_1) && (loc_temp > dna.species.cold_level_1) ? ((loc_temp - bodytemperature) / dna.species.body_temperature) : 0

		if(dna.species.body_temperature < bodytemperature)
			// body temperature is HIGHER than that of our species, we are cooling
			var/clothing_factor = 2 - get_heat_protection(loc_temp) // thermal clothing with heat protection slows down recovery
			adjust_bodytemperature(max(clothing_factor * metabolism_efficiency * ((body_temperature_difference + enviro_shift) / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_COOLING_MAX))
		else
			// body temperature is LOWER than that of our species, we are heating
			var/clothing_factor = 2 - get_cold_protection(loc_temp) // thermal clothing with cold protection slows down recovery
			adjust_bodytemperature(min(clothing_factor * metabolism_efficiency * ((body_temperature_difference + enviro_shift) / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_HEATING_MAX))


	//This proc returns a number made up of the flags for body parts which you are protected on. (such as HEAD, UPPER_TORSO, LOWER_TORSO, etc. See setup.dm for the full list)
/mob/living/carbon/human/proc/get_heat_protection_flags(temperature) //Temperature is the temperature you're being exposed to.
	var/thermal_protection_flags = 0
	//Handle normal clothing
	if(head)
		if(head.max_heat_protection_temperature && head.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= head.heat_protection
	if(wear_suit)
		if(wear_suit.max_heat_protection_temperature && wear_suit.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= wear_suit.heat_protection
	if(w_uniform)
		if(w_uniform.max_heat_protection_temperature && w_uniform.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= w_uniform.heat_protection
	if(shoes)
		if(shoes.max_heat_protection_temperature && shoes.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= shoes.heat_protection
	if(gloves)
		if(gloves.max_heat_protection_temperature && gloves.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= gloves.heat_protection
	if(neck)
		if(neck.max_heat_protection_temperature && neck.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= neck.heat_protection
	if(wear_mask)
		if(wear_mask.max_heat_protection_temperature && wear_mask.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= wear_mask.heat_protection

	return thermal_protection_flags

/mob/living/carbon/human/proc/get_heat_protection(temperature) //Temperature is the temperature you're being exposed to.

	if(HAS_TRAIT(src, TRAIT_RESIST_HEAT))
		return 1

	var/thermal_protection_flags = get_heat_protection_flags(temperature)

	var/thermal_protection = 0.0
	if(thermal_protection_flags)
		if(thermal_protection_flags & HEAD)
			thermal_protection += THERMAL_PROTECTION_HEAD
		if(thermal_protection_flags & UPPER_TORSO)
			thermal_protection += THERMAL_PROTECTION_UPPER_TORSO
		if(thermal_protection_flags & LOWER_TORSO)
			thermal_protection += THERMAL_PROTECTION_LOWER_TORSO
		if(thermal_protection_flags & LEG_LEFT)
			thermal_protection += THERMAL_PROTECTION_LEG_LEFT
		if(thermal_protection_flags & LEG_RIGHT)
			thermal_protection += THERMAL_PROTECTION_LEG_RIGHT
		if(thermal_protection_flags & FOOT_LEFT)
			thermal_protection += THERMAL_PROTECTION_FOOT_LEFT
		if(thermal_protection_flags & FOOT_RIGHT)
			thermal_protection += THERMAL_PROTECTION_FOOT_RIGHT
		if(thermal_protection_flags & ARM_LEFT)
			thermal_protection += THERMAL_PROTECTION_ARM_LEFT
		if(thermal_protection_flags & ARM_RIGHT)
			thermal_protection += THERMAL_PROTECTION_ARM_RIGHT
		if(thermal_protection_flags & HAND_LEFT)
			thermal_protection += THERMAL_PROTECTION_HAND_LEFT
		if(thermal_protection_flags & HAND_RIGHT)
			thermal_protection += THERMAL_PROTECTION_HAND_RIGHT


	return min(1,thermal_protection)

	//See proc/get_heat_protection_flags(temperature) for the description of this proc.
/mob/living/carbon/human/proc/get_cold_protection_flags(temperature)
	var/thermal_protection_flags = 0
	//Handle normal clothing

	if(head)
		if(head.min_cold_protection_temperature && head.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= head.cold_protection
	if(wear_suit)
		if(wear_suit.min_cold_protection_temperature && wear_suit.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= wear_suit.cold_protection
	if(w_uniform)
		if(w_uniform.min_cold_protection_temperature && w_uniform.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= w_uniform.cold_protection
	if(shoes)
		if(shoes.min_cold_protection_temperature && shoes.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= shoes.cold_protection
	if(gloves)
		if(gloves.min_cold_protection_temperature && gloves.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= gloves.cold_protection
	if(neck)
		if(neck.min_cold_protection_temperature && neck.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= neck.cold_protection
	if(wear_mask)
		if(wear_mask.min_cold_protection_temperature && wear_mask.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= wear_mask.cold_protection

	return thermal_protection_flags

/mob/living/carbon/human/proc/get_cold_protection(temperature)

	if(HAS_TRAIT(src, TRAIT_RESIST_COLD))
		return 1 //Fully protected from the cold.

	temperature = max(temperature, TCMB) //There is an occasional bug where the temperature is miscalculated in areas with a small amount of gas on them, so this is necessary to ensure that that bug does not affect this calculation. Space's temperature is 2.7K and most suits that are intended to protect against any cold, protect down to 2.0K.
	var/thermal_protection_flags = get_cold_protection_flags(temperature)

	var/thermal_protection = 0.0
	if(thermal_protection_flags)
		if(thermal_protection_flags & HEAD)
			thermal_protection += THERMAL_PROTECTION_HEAD
		if(thermal_protection_flags & UPPER_TORSO)
			thermal_protection += THERMAL_PROTECTION_UPPER_TORSO
		if(thermal_protection_flags & LOWER_TORSO)
			thermal_protection += THERMAL_PROTECTION_LOWER_TORSO
		if(thermal_protection_flags & LEG_LEFT)
			thermal_protection += THERMAL_PROTECTION_LEG_LEFT
		if(thermal_protection_flags & LEG_RIGHT)
			thermal_protection += THERMAL_PROTECTION_LEG_RIGHT
		if(thermal_protection_flags & FOOT_LEFT)
			thermal_protection += THERMAL_PROTECTION_FOOT_LEFT
		if(thermal_protection_flags & FOOT_RIGHT)
			thermal_protection += THERMAL_PROTECTION_FOOT_RIGHT
		if(thermal_protection_flags & ARM_LEFT)
			thermal_protection += THERMAL_PROTECTION_ARM_LEFT
		if(thermal_protection_flags & ARM_RIGHT)
			thermal_protection += THERMAL_PROTECTION_ARM_RIGHT
		if(thermal_protection_flags & HAND_LEFT)
			thermal_protection += THERMAL_PROTECTION_HAND_LEFT
		if(thermal_protection_flags & HAND_RIGHT)
			thermal_protection += THERMAL_PROTECTION_HAND_RIGHT

	return min(1,thermal_protection)


/mob/living/carbon/human/proc/get_covered_bodyparts()
	var/covered = 0

	if(head)
		covered |= head.body_parts_covered
	if(wear_suit)
		covered |= wear_suit.body_parts_covered
	if(w_uniform)
		covered |= w_uniform.body_parts_covered
	if(shoes)
		covered |= shoes.body_parts_covered
	if(gloves)
		covered |= gloves.body_parts_covered
	if(neck)
		covered |= neck.body_parts_covered
	if(wear_mask)
		covered |= wear_mask.body_parts_covered

	return covered

/mob/living/carbon/human/handle_chemicals_in_body()
	..()

	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return 0	//godmode

	var/is_vamp = isvampire(src)

	if(!HAS_TRAIT(src, TRAIT_NO_HUNGER) || is_vamp)
		if(HAS_TRAIT_FROM(src, TRAIT_FAT, FATNESS_TRAIT))
			if(overeatduration < 100)
				REMOVE_TRAIT(src, TRAIT_FAT, FATNESS_TRAIT)
		else
			if(overeatduration > 500 && !HAS_TRAIT(src, TRAIT_NO_FAT))
				ADD_TRAIT(src, TRAIT_FAT, FATNESS_TRAIT)

		// nutrition decrease
		if(nutrition >= 0 && stat != DEAD)
			handle_nutrition_alerts()
			// THEY HUNGER
			var/hunger_rate = is_vamp ? HUNGER_FACTOR_VAMPIRE : HUNGER_FACTOR * dna.species.hunger_drain_mod * physiology.hunger_mod
			if(satiety > 0)
				satiety--
			if(satiety < 0)
				satiety++
				if(prob(round(-satiety/40)))
					Jitter(10 SECONDS)
				hunger_rate *= 3
			adjust_nutrition(-hunger_rate)

		if(nutrition > NUTRITION_LEVEL_FULL)
			if(overeatduration < 600) //capped so people don't take forever to unfat
				overeatduration++

		else
			if(overeatduration > 1)
				if(HAS_TRAIT(src, TRAIT_OBESITY))
					overeatduration -= 1 // Those with obesity gene take twice as long to unfat
				else
					overeatduration -= 2

		if(!ismachineperson(src) && !isLivingSSD(src) && nutrition < NUTRITION_LEVEL_HYPOGLYCEMIA) //Gosh damn snowflakey IPCs
			var/datum/disease/critical/hypoglycemia/D = new
			D.Contract(src)

		//metabolism change
		if(nutrition > NUTRITION_LEVEL_FAT)
			metabolism_efficiency = 1
		else if(nutrition > NUTRITION_LEVEL_FED && satiety > 80)
			if(metabolism_efficiency != 1.25)
				to_chat(src, "<span class='notice'>You feel vigorous.</span>")
				metabolism_efficiency = 1.25
		else if(nutrition < NUTRITION_LEVEL_STARVING + 50)
			if(metabolism_efficiency != 0.8)
				to_chat(src, "<span class='notice'>You feel sluggish.</span>")
			metabolism_efficiency = 0.8
		else
			if(metabolism_efficiency == 1.25)
				to_chat(src, "<span class='notice'>You no longer feel vigorous.</span>")
			metabolism_efficiency = 1

	if(HAS_TRAIT(src, TRAIT_NO_INTORGANS))
		return

	handle_trace_chems()

/mob/living/carbon/human/proc/has_booze() //checks if the human has ethanol or its subtypes inside
	for(var/A in reagents.reagent_list)
		var/datum/reagent/R = A
		if(istype(R, /datum/reagent/consumable/ethanol))
			return 1
	return 0

/mob/living/carbon/human/handle_critical_condition()
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return 0

	var/guaranteed_death_threshold = health + (getOxyLoss() * 0.5) - (getFireLoss() * 0.67) - (getBruteLoss() * 0.67)

	if(getBrainLoss() >= 120 || (guaranteed_death_threshold) <= -500)
		death()
		return

	if(getBrainLoss() >= 100) // braindeath
		AdjustLoseBreath(20 SECONDS, bound_lower = 0, bound_upper = 50 SECONDS)
		Weaken(60 SECONDS)

	if(!check_death_method())
		if(health <= HEALTH_THRESHOLD_DEAD)
			var/deathchance = min(99, ((getBrainLoss() * -5) + (health + (getOxyLoss() / 2))) * -0.01)
			if(prob(deathchance))
				death()
				return

		if(health <= HEALTH_THRESHOLD_CRIT)
			if(prob(5))
				emote(pick("faint", "collapse", "cry", "moan", "gasp", "shudder", "shiver"))
			SetStuttering(10 SECONDS)
			EyeBlurry(10 SECONDS)
			if(prob(7))
				AdjustConfused(4 SECONDS)
			if(prob(5))
				Paralyse(4 SECONDS)
			switch(health)
				if(-INFINITY to -100)
					adjustOxyLoss(1)
					if(prob(health * -0.1))
						if(ishuman(src))
							var/mob/living/carbon/human/H = src
							H.set_heartattack(TRUE)
					if(prob(health * -0.2))
						var/datum/disease/critical/heart_failure/D = new
						D.Contract(src)
					Paralyse(10 SECONDS)
				if(-99 to -80)
					adjustOxyLoss(1)
					if(prob(4))
						to_chat(src, "<span class='userdanger'>Your chest hurts...</span>")
						Paralyse(4 SECONDS)
						var/datum/disease/critical/heart_failure/D = new
						D.Contract(src)
				if(-79 to -50)
					adjustOxyLoss(1)
					if(prob(10))
						var/datum/disease/critical/shock/D = new
						D.Contract(src)
					if(prob(health * -0.08))
						var/datum/disease/critical/heart_failure/D = new
						D.Contract(src)
					if(prob(6))
						to_chat(src, "<span class='userdanger'>You feel [pick("horrible pain", "awful", "like shit", "absolutely awful", "like death", "like you are dying", "nothing", "warm", "sweaty", "tingly", "really, really bad", "horrible")]!</span>")
						Weaken(6 SECONDS)
					if(prob(3))
						Paralyse(4 SECONDS)
				if(-49 to 0)
					adjustOxyLoss(1)
					if(prob(3))
						var/datum/disease/critical/shock/D = new
						D.Contract(src)
					if(prob(5))
						to_chat(src, "<span class='userdanger'>You feel [pick("terrible", "awful", "like shit", "sick", "numb", "cold", "sweaty", "tingly", "horrible")]!</span>")
						Weaken(6 SECONDS)


#define BODYPART_PAIN_REDUCTION 5

/mob/living/carbon/human/update_health_hud()
	if(!client)
		return
	if(dna.species.update_health_hud())
		return
	else

		var/shock_reduction = 0
		if(HAS_TRAIT(src, TRAIT_NO_PAIN_HUD))
			shock_reduction = INFINITY
		else
			shock_reduction = shock_reduction()

		if(healths)
			var/health_amount = get_perceived_trauma(shock_reduction)
			if(..(health_amount)) //not dead
				switch(hal_screwyhud)
					if(SCREWYHUD_CRIT)
						healths.icon_state = "health6"
					if(SCREWYHUD_DEAD)
						healths.icon_state = "health7"
					if(SCREWYHUD_HEALTHY)
						healths.icon_state = "health0"

		if(healthdoll)
			if(stat == DEAD)
				healthdoll.icon_state = "healthdoll_DEAD"
				healthdoll.cut_overlays()
				var/obj/item/organ/external/tail/bodypart_tail = get_organ(BODY_ZONE_TAIL)
				if(bodypart_tail?.dna?.species?.tail)
					healthdoll.add_overlay("[bodypart_tail.dna.species.tail]_DEAD")
			else
				var/list/new_overlays = list()
				var/list/cached_overlays = healthdoll.cached_healthdoll_overlays
				// Use the dead health doll as the base, since we have proper "healthy" overlays now
				healthdoll.icon_state = "healthdoll_DEAD"
				for(var/obj/item/organ/external/bodypart as anything in bodyparts)
					var/damage = bodypart.burn_dam + bodypart.brute_dam
					damage -= shock_reduction / BODYPART_PAIN_REDUCTION
					var/comparison = (bodypart.max_damage/5)
					var/icon_num = 0
					if(damage > 0)
						icon_num = 1
					if(damage > (comparison))
						icon_num = 2
					if(damage > (comparison*2))
						icon_num = 3
					if(damage > (comparison*3))
						icon_num = 4
					if(damage > (comparison*4))
						icon_num = 5
					if(istype(bodypart, /obj/item/organ/external/tail) && bodypart.dna?.species.tail)
						new_overlays += "[bodypart.dna.species.tail][icon_num]"
					if(istype(bodypart, /obj/item/organ/external/wing) && bodypart.dna?.species.tail)
						new_overlays += "[bodypart.dna.species.wing][icon_num]"
					else
						new_overlays += "[bodypart.limb_zone][icon_num]"
				healthdoll.add_overlay(new_overlays - cached_overlays)
				healthdoll.cut_overlay(cached_overlays - new_overlays)
				healthdoll.cached_healthdoll_overlays = new_overlays

		if(health <= HEALTH_THRESHOLD_CRIT)
			throw_alert("succumb", /atom/movable/screen/alert/succumb)
		else
			clear_alert("succumb")

#undef BODYPART_PAIN_REDUCTION


/mob/living/carbon/human/proc/handle_nutrition_alerts() //This is a terrible abuse of the alert system; something like this should be a HUD element
	var/new_hunger
	switch(nutrition)
		if(NUTRITION_LEVEL_FULL to INFINITY)
			new_hunger = "fat"
		if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
			new_hunger = "full"
		if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
			new_hunger = "well_fed"
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			new_hunger = "fed"
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			new_hunger = "hungry"
		else
			new_hunger = "starving"

	if(HAS_TRAIT(src, TRAIT_NO_HUNGER) && !isvampire(src))
		new_hunger = "full"

	if(dna.species.hunger_type)
		new_hunger += "/[dna.species.hunger_type]"

	if(dna.species.hunger_level != new_hunger)
		dna.species.hunger_level = new_hunger
		throw_alert(ALERT_NUTRITION, text2path("/atom/movable/screen/alert/hunger/[new_hunger]"), icon_override = dna.species.hunger_icon)
		med_hud_set_status()

/mob/living/carbon/human/proc/handle_embedded_objects()
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		for(var/obj/item/thing in bodypart.embedded_objects)
			if(prob(thing.embedded_pain_chance))
				apply_damage(thing.w_class * thing.embedded_pain_multiplier, def_zone = bodypart)
				to_chat(src, span_userdanger("[thing] embedded in your [bodypart.name] hurts!"))

			if(prob(thing.embedded_fall_chance))
				bodypart.remove_embedded_object(thing)
				apply_damage(thing.w_class * thing.embedded_fall_pain_multiplier, def_zone = bodypart)
				visible_message(
					span_danger("[thing] falls out of [name]'s [bodypart.name]!"),
					span_userdanger("[thing] falls out of your [bodypart.name]!"),
				)


/mob/living/carbon/human/proc/handle_pulse(times_fired)
	if(times_fired % 5 == 1)
		return pulse	//update pulse every 5 life ticks (~1 tick/sec, depending on server load)

	if(HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return PULSE_NONE //No blood, no pulse.

	if(stat == DEAD)
		return PULSE_NONE	//that's it, you're dead, nothing can influence your pulse

	if(undergoing_cardiac_arrest())
		return PULSE_NONE

	var/temp = PULSE_NORM

	if(blood_volume <= BLOOD_VOLUME_BAD)//how much blood do we have
		temp = PULSE_THREADY	//not enough :(

	if(HAS_TRAIT(src, TRAIT_FAKEDEATH))
		temp = PULSE_NONE		//pretend that we're dead. unlike actual death, can be inflienced by meds

	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.heart_rate_decrease)
				if(temp <= PULSE_THREADY && temp >= PULSE_NORM)
					temp--
					break

		for(var/datum/reagent/R in reagents.reagent_list)//handles different chems' influence on pulse
			if(R.heart_rate_increase)
				if(temp <= PULSE_FAST && temp >= PULSE_NONE)
					temp++
					break

		for(var/datum/reagent/R in reagents.reagent_list) //To avoid using fakedeath
			if(R.heart_rate_stop)
				temp = PULSE_NONE
				break

	return temp

/mob/living/carbon/human/proc/handle_decay()
	var/decaytime = world.time - timeofdeath

	if(HAS_TRAIT(src, TRAIT_NO_DECAY))
		return

	if(reagents.has_reagent("formaldehyde")) //embalming fluid stops decay
		return

	if(decaytime <= 6000) //10 minutes for decaylevel1 -- stinky
		return

	if(decaytime > 6000 && decaytime <= 12000)//20 minutes for decaylevel2 -- bloated and very stinky
		decaylevel = 1

	if(decaytime > 12000 && decaytime <= 18000)//30 minutes for decaylevel3 -- rotting and gross
		decaylevel = 2

	if(decaytime > 18000 && decaytime <= 27000)//45 minutes for decaylevel4 -- skeleton
		decaylevel = 3

	if(decaytime > 27000)
		decaylevel = 4
		makeSkeleton()
		return //No puking over skeletons, they don't smell at all!

	if(!isturf(loc))
		return

	for(var/mob/living/carbon/human/H in view(decaylevel, src) - src)
		if(prob(0.3 * decaylevel))
			var/datum/disease/virus/cadaver/D = new()
			D.Contract(H, CONTACT, need_protection_check = TRUE)
		if(prob(2))
			var/obj/item/clothing/mask/M = H.wear_mask
			if(M && (M.flags_cover & MASKCOVERSMOUTH))
				continue
			if(HAS_TRAIT(H, TRAIT_NO_BREATH))
				continue //no puking if you can't smell!
			// Humans can lack a mind datum, y'know
			if(H.mind && (H.mind.assigned_role == JOB_TITLE_DETECTIVE || H.mind.assigned_role == JOB_TITLE_CORONER))
				continue //too cool for puke
			to_chat(H, "<span class='warning'>You smell something foul...</span>")
			H.fakevomit()

/mob/living/carbon/human/proc/handle_heartbeat()
	var/client/C = src.client
	if(C && C.prefs.sound & SOUND_HEARTBEAT) //disable heartbeat by pref
		var/obj/item/organ/internal/heart/H = get_int_organ(/obj/item/organ/internal/heart)

		if(!H) //H.status will runtime if there is no H (obviously)
			return

		if(H.is_robotic()) //Handle robotic hearts specially with a wuuuubb. This also applies to machine-people.
			if(isinspace())
				//PULSE_THREADY - maximum value for pulse, currently it 5.
				//High pulse value corresponds to a fast rate of heartbeat.
				//Divided by 2, otherwise it is too slow.
				var/rate = (PULSE_THREADY - 2)/2 //machine people (main target) have no pulse, manually subtract standard human pulse (2). Mechanic-heart humans probably have a pulse, but 'advanced neural systems' keep the heart rate steady, or something

				if(heartbeat >= rate)
					heartbeat = 0
					src << sound('sound/effects/electheart.ogg',0,0,CHANNEL_HEARTBEAT,30)//Credit to GhostHack (www.ghosthack.de) for sound.

				else
					heartbeat++
				return
			return

		if(pulse == PULSE_NONE)
			return

		if(pulse >= PULSE_2FAST || isinspace())
			//PULSE_THREADY - maximum value for pulse, currently it 5.
			//High pulse value corresponds to a fast rate of heartbeat.
			//Divided by 2, otherwise it is too slow.
			var/rate = (PULSE_THREADY - pulse)/2

			if(heartbeat >= rate)
				heartbeat = 0
				src << sound('sound/effects/singlebeat.ogg',0,0,CHANNEL_HEARTBEAT,50)
			else
				heartbeat++

/*
	Called by life(), instead of having the individual hud items update icons each tick and check for status changes
	we only set those statuses and icons upon changes.  Then those HUD items will simply add those pre-made images.
	This proc below is only called when those HUD elements need to change as determined by the mobs hud_updateflag.
*/

/mob/living/carbon/human/proc/can_heartattack()
	if(HAS_TRAIT(src, TRAIT_NO_BLOOD) && !dna.species.forced_heartattack)
		return FALSE
	if(HAS_TRAIT(src, TRAIT_NO_INTORGANS))
		return FALSE
	return TRUE

/mob/living/carbon/human/proc/undergoing_cardiac_arrest()
	if(!can_heartattack())
		return FALSE
	var/obj/item/organ/internal/heart/heart = get_int_organ(/obj/item/organ/internal/heart)
	if(istype(heart))
		if(heart.is_dead())
			return TRUE
		if(heart.beating)
			return FALSE
	return TRUE

/mob/living/carbon/human/proc/set_heartattack(status)
	if(!can_heartattack())
		return FALSE

	var/obj/item/organ/internal/heart/heart = get_int_organ(/obj/item/organ/internal/heart)
	if(!istype(heart))
		return FALSE

	heart.beating = !status
	return TRUE

/mob/living/carbon/human/handle_heartattack()
	if(!can_heartattack() || !undergoing_cardiac_arrest() || reagents.has_reagent("corazone"))
		return
	if(getOxyLoss())
		adjustBrainLoss(3)
	else if(prob(10))
		adjustBrainLoss(1)
	Weaken(10 SECONDS)
	AdjustLoseBreath(40 SECONDS, bound_lower = 0, bound_upper = 50 SECONDS)
	adjustOxyLoss(20)



// Need this in species.
//#undef HUMAN_MAX_OXYLOSS
//#undef HUMAN_CRIT_MAX_OXYLOSS
