/datum/reagent/phlogiston
	name = "Флогистон"
	id = "phlogiston"
	description = "Похоже, это жидкий огонь."
	reagent_state = LIQUID
	color = "#FFAF00"
	process_flags = ORGANIC | SYNTHETIC
	taste_description = "огня"
	var/temp_fire = 4000
	var/temp_deviance = 1000
	var/size_divisor = 40
	var/mob_burning =  6.6 // 33

/datum/reagent/phlogiston/reaction_turf(turf/T, volume)
	if(holder.chem_temp <= T0C - 50)
		return
	var/radius = min(max(0, volume / size_divisor), 8)
	fire_flash_log(holder, id)
	fireflash_sm(T, radius, rand(temp_fire - temp_deviance, temp_fire + temp_deviance), 500)

/datum/reagent/phlogiston/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume)
	if(holder.chem_temp <= T0C - 50)
		return
	M.adjust_fire_stacks(mob_burning)
	M.IgniteMob()
	if(method == REAGENT_INGEST)
		M.adjustFireLoss(min(max(10, volume * 2), 45))
		to_chat(M, span_warning("Жжётся!"))
		M.emote("scream")

/datum/reagent/phlogiston/on_mob_life(mob/living/M)
	if(holder.chem_temp <= T0C - 50)
		return
	M.adjust_fire_stacks(0.4)
	M.IgniteMob()
	return ..()

/datum/reagent/phlogiston/firedust
	name = "Флогистоновая пыль"
	id = "phlogiston_dust"
	description = "А это - твёрдый огонь. Как бы то ни было, это работает."
	temp_fire = 1500
	temp_deviance = 500
	size_divisor = 80
	mob_burning = 3 // 15

/datum/reagent/napalm
	name = "Напалм"
	id = "napalm"
	description = "Легковоспламеняющееся желеобразное топливо."
	reagent_state = LIQUID
	process_flags = ORGANIC | SYNTHETIC
	color = "#C86432"
	taste_description = "горения"

/datum/reagent/napalm/reaction_temperature(exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 100)
		var/radius = min(max(0, volume * 0.15), 8)
		var/turf/T = get_turf(holder.my_atom)
		fire_flash_log(holder, id)
		if(holder)
			holder.del_reagent(id)
		fireflash_sm(T, radius, rand(3000, 6000), 500)

/datum/reagent/napalm/reaction_turf(turf/T, volume)
	if(isspaceturf(T))
		return
	if(!T.reagents)
		T.create_reagents(volume)
	T.reagents.add_reagent("napalm", volume)

/datum/reagent/napalm/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		if(M.on_fire)
			M.adjust_fire_stacks(14)
			M.emote("scream")

/datum/reagent/napalm/on_mob_life(mob/living/M)
	if(M.on_fire)
		M.adjust_fire_stacks(2)
	return ..()

/datum/reagent/fuel
	name = "Сварочное топливо"
	id = "fuel"
	description = "Легковоспламеняющаяся смесь основных углеводородов, в основном ацетилена. Используется как для сварки, так и для органической химии, может быть переработано в более тяжёлое масло."
	reagent_state = LIQUID
	color = "#060606"
	drink_icon = "dr_gibb_glass"
	drink_name = "стакан сварочного топлива"
	drink_desc = "Если вы не являетесь промышленным инструментом, это, вероятно, небезопасно для употребления. Хотя ассистенты любят такое пить."
	taste_description = "mistakes"
	process_flags = ORGANIC | SYNTHETIC
	var/max_radius = 7
	var/min_radius = 0
	var/volume_radius_modifier = -0.15
	var/volume_radius_multiplier = 0.09
	var/explosion_threshold = 100
	var/min_explosion_radius = 0
	var/max_explosion_radius = 4
	var/volume_explosion_radius_multiplier = 0.005
	var/volume_explosion_radius_modifier = 0
	var/combustion_temp = T0C + 200

/datum/reagent/fuel/on_mob_life(mob/living/M)
	if(M.on_fire)
		M.adjust_fire_stacks(0.4)
	return ..()

/datum/reagent/fuel/reaction_temperature(exposed_temperature, exposed_volume)
	if(exposed_temperature > combustion_temp)
		if(volume < 1)
			if(holder)
				holder.del_reagent(id)
			return

		var/will_explode = volume >= explosion_threshold
		if(will_explode && holder.my_atom)
			// Log beforehand
			holder.my_atom.visible_message(span_danger("[capitalize(holder.my_atom.declent_ru(NOMINATIVE))] взрывается!"))
			message_admins("Fuel explosion ([holder.my_atom], reagent type: [id]) at [COORD(holder.my_atom.loc)]. Last touched by: [holder.my_atom.fingerprintslast ? "[holder.my_atom.fingerprintslast]" : "*null*"].")
			add_game_logs("Fuel explosion ([holder.my_atom], reagent type: [id]) at [COORD(holder.my_atom.loc)]. Last touched by: [holder.my_atom.fingerprintslast ? "[holder.my_atom.fingerprintslast]" : "*null*"].")
			holder.my_atom.investigate_log("A fuel explosion, last touched by [holder.my_atom.fingerprintslast ? "[holder.my_atom.fingerprintslast]" : "*null*"], triggered at [COORD(holder.my_atom.loc)].", INVESTIGATE_BOMB)

		var/turf/T = get_turf(holder.my_atom)
		if(holder) // Delete the fuel from the holder before we trigger the fireball
			holder.del_reagent(id)

		var/radius = min(max(min_radius, volume * volume_radius_multiplier + volume_radius_modifier), max_radius)
		fireflash_sm(T, radius, 2200 + radius * 250, radius * 50)
		if(will_explode)
			var/boomrange = min(max(min_explosion_radius, round(volume * volume_explosion_radius_multiplier + volume_explosion_radius_modifier)), max_explosion_radius)
			explosion(T, -1, -1, boomrange, 1, cause = "Fuel Reaction Temp.")

/datum/reagent/fuel/reaction_turf(turf/T, volume) //Don't spill the fuel, or you'll regret it
	if(isspaceturf(T))
		return
	if(!T.reagents)
		T.create_reagents(50)
	T.reagents.add_reagent("fuel", volume)

/datum/reagent/fuel/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)//Splashing people with welding fuel to make them easy to ignite!
	if(method == REAGENT_TOUCH)
		if(M.on_fire)
			M.adjust_fire_stacks(6)

/datum/reagent/plasma
	name = "Плазма"
	id = "plasma"
	description = "Жидкая форма необычного внеземного соединения."
	reagent_state = LIQUID
	color = "#7A2B94"
	taste_description = "пропадающих зря корпоративных активов"
	taste_mult = 1.5

/datum/reagent/plasma/reaction_temperature(exposed_temperature, exposed_volume)
	if(exposed_temperature >= T0C + 100)
		var/turf/T = get_turf(holder.my_atom)
		fire_flash_log(holder, id)
		if(holder)
			holder.del_reagent(id) // Remove first. Else fireflash triggers a reaction again
		fireflash(T, min(max(0, volume / 10), 8))

/datum/reagent/plasma/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(0.5, FALSE)
	if(holder.has_reagent("epinephrine"))
		holder.remove_reagent("epinephrine", 2)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.adjust_alien_plasma(10)
	return ..() | update_flags

/datum/reagent/plasma/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume)//Splashing people with plasma is stronger than fuel!
	if(method == REAGENT_TOUCH)
		if(M.on_fire)
			M.adjust_fire_stacks(6)


/datum/reagent/thermite
	name = "Термит"
	id = "thermite"
	description = "Термит вызывает алюминотермическую реакцию, известную как термитная реакция. Может использоваться для плавления замков. Или стен."
	reagent_state = SOLID
	color = "#673910" // rgb: 103, 57, 16
	process_flags = ORGANIC | SYNTHETIC
	taste_description = "ржавчины"

/datum/reagent/thermite/reaction_mob(mob/living/M, method= REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		if(M.on_fire)
			M.adjust_fire_stacks(20)

/datum/reagent/thermite/reaction_temperature(exposed_temperature, exposed_volume)
	var/turf/simulated/S = holder.my_atom
	if(!istype(S))
		return

	if(exposed_temperature >= T0C + 100)
		var/datum/reagents/Holder = holder
		var/Id = id
		var/Volume = volume
		fire_flash_log(holder, id)
		Holder.del_reagent(Id)
		fireflash_sm(S, 0, rand(20000, 25000) + Volume * 2500, 0, 0, 1)

/datum/reagent/thermite/reaction_turf(turf/simulated/S, volume)
	if(istype(S))
		if(!S.reagents)
			S.create_reagents(volume)
		S.reagents.add_reagent("thermite", volume)
		S.melting_olay = mutable_appearance('icons/effects/effects.dmi', icon_state = "thermite")
		S.add_overlay(S.melting_olay)
		if(S.active_hotspot)
			S.reagents.temperature_reagents(S.active_hotspot.temperature, 10, 300)

/datum/reagent/glycerol
	name = "Глицерин"
	id = "glycerol"
	description = "Глицерин - это простое полиольное соединение. Глицерин обладает сладким вкусом и низкой токсичностью."
	reagent_state = LIQUID
	color = "#808080" // rgb: 128, 128, 128
	taste_description = "сладости"

/datum/reagent/stabilizing_agent
	name = "Стабилизирующий агент"
	id = "stabilizing_agent"
	description = "Химикат, который стабилизирует обычно летучие соединения, не позволяя им немедленно вступать в реакцию."
	reagent_state = LIQUID
	color = "#FFFF00"
	taste_description = "стабильности"

/datum/reagent/clf3
	name = "Трифторид хлора"
	id = "clf3"
	description = "Крайне летучее вещество, обращаться с ним следует с особой осторожностью."
	reagent_state = LIQUID
	color = "#FF0000"
	metabolization_rate = 10 * REAGENTS_METABOLISM
	process_flags = ORGANIC | SYNTHETIC
	taste_mult = 0

/datum/reagent/clf3/on_mob_life(mob/living/M)
	if(M.on_fire)
		M.adjust_fire_stacks(1)
	return ..()

/datum/reagent/clf3/reaction_turf(turf/T, volume)
	if(volume < 3)
		return
	var/radius = min((volume - 3) * 0.15, 3)
	fire_flash_log(holder, id)
	fireflash_sm(T, radius, 4500 + volume * 500, 350)

/datum/reagent/clf3/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH || method == REAGENT_INGEST)
		M.adjust_fire_stacks(10)
		M.IgniteMob()
	if(method == REAGENT_INGEST)
		M.adjustFireLoss(min(max(15, volume * 2.5), 90))
		to_chat(M, span_warning("Жжётся!"))
		M.emote("scream")

/datum/reagent/sorium
	name = "Сорий"
	id = "sorium"
	description = "Отправляет всё в полет от точки взрыва."
	reagent_state = LIQUID
	color = "#FFA500"
	taste_description = "горького воздуха"

/datum/reagent/sorium/reaction_turf(turf/T, volume) // oh no
	if(prob(75))
		return
	if(isspaceturf(T))
		return
	if(!T.reagents)
		T.create_reagents(50)
	T.reagents.add_reagent("sorium", 5)

/datum/reagent/liquid_dark_matter
	name = "Жидкая тёмная материя"
	id = "liquid_dark_matter"
	description = "Всасывает всё в точку взрыва."
	reagent_state = LIQUID
	color = "#800080"
	taste_description = "горького вакуума"

/datum/reagent/liquid_dark_matter/reaction_turf(turf/T, volume) //Oh gosh, why
	if(prob(75))
		return
	if(isspaceturf(T))
		return
	if(!T.reagents)
		T.create_reagents(50)
	T.reagents.add_reagent("liquid_dark_matter", 5)

/datum/reagent/blackpowder
	name = "Чёрный порох"
	id = "blackpowder"
	description = "Взрывается. Сильно взрывается."
	reagent_state = LIQUID
	color = "#000000"
	metabolization_rate = 0.125 * REAGENTS_METABOLISM
	penetrates_skin = TRUE
	taste_description = "взрывов"

/datum/reagent/blackpowder/reaction_turf(turf/T, volume) //oh shit
	if(volume >= 5 && !isspaceturf(T))
		if(!locate(/obj/effect/decal/cleanable/dirt/blackpowder) in T) //let's not have hundreds of decals of black powder on the same turf
			new /obj/effect/decal/cleanable/dirt/blackpowder(T)

/datum/reagent/flash_powder
	name = "Порошок-вспышка"
	id = "flash_powder"
	description = "Создаёт очень яркую вспышку."
	reagent_state = LIQUID
	color = "#FFFF00"
	penetrates_skin = TRUE
	taste_description = "соли"

/datum/reagent/smoke_powder
	name = "Дымный порошок"
	id = "smoke_powder"
	description = "Создаёт большое облако дыма, в котором могут находиться реагенты."
	reagent_state = LIQUID
	color = "#808080"
	taste_description = "дыма"

/datum/reagent/sonic_powder
	name = "Звуковой порошок"
	id = "sonic_powder"
	description = "Производит оглушительный шум."
	reagent_state = LIQUID
	color = "#0000FF"
	penetrates_skin = TRUE
	taste_description = "шума"

/datum/reagent/cryostylane
	name = "Криостилан"
	id = "cryostylane"
	description = "Синтезируется с температурой в 20К. Пока в реакции с кислородом, медленно охлаждает все остальные вещества в теле существа до 0K."
	color = "#B2B2FF" // rgb: 139, 166, 233
	process_flags = ORGANIC | SYNTHETIC
	taste_description = "леденящей язык горечи"

/datum/reagent/cryostylane/on_new(data)
	..()
	START_PROCESSING(SSprocessing, src)

/datum/reagent/cryostylane/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/reagent/cryostylane/on_mob_life(mob/living/M) //TODO: code freezing into an ice cube
	if(M.reagents.has_reagent("oxygen"))
		M.reagents.remove_reagent("oxygen", 1)
		M.adjust_bodytemperature(-30)
	return ..()

/datum/reagent/cryostylane/process()
	if(..())
		if(holder.has_reagent("oxygen"))
			holder.remove_reagent("oxygen", 2)
			holder.remove_reagent("cryostylane", 2)
			holder.temperature_reagents(holder.chem_temp - 200)

/datum/reagent/cryostylane/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		M.ExtinguishMob()

/datum/reagent/cryostylane/reaction_turf(turf/simulated/T, volume)
	if(!istype(T))
		return
	if(volume >= 3)
		T.MakeSlippery(TURF_WET_ICE, 120 SECONDS)
	if(volume >= 5)
		for(var/mob/living/simple_animal/slime/M in T)
			M.adjustToxLoss(rand(15,30))

/datum/reagent/pyrosium
	name = "Пирозий"
	id = "pyrosium"
	description = "Синтезируется с температурой в 20К.  Пока в реакции с кислородом, медленно нагревает все остальные вещества в теле существа до 0K."
	color = "#B20000" // rgb: 139, 166, 233
	process_flags = ORGANIC | SYNTHETIC
	taste_description = "обжигающей язык горечи"

/datum/reagent/pyrosium/on_new(data)
	..()
	START_PROCESSING(SSprocessing, src)

/datum/reagent/pyrosium/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/reagent/pyrosium/on_mob_life(mob/living/M)
	if(M.reagents.has_reagent("oxygen"))
		M.reagents.remove_reagent("oxygen", 1)
		M.adjust_bodytemperature(30)
	return ..()

/datum/reagent/pyrosium/process()
	if(..())
		if(holder.has_reagent("oxygen"))
			holder.remove_reagent("oxygen", 2)
			holder.remove_reagent("pyrosium", 2)
			holder.temperature_reagents(holder.chem_temp + 200)

/datum/reagent/firefighting_foam
	name = "Противопожарная пена"
	id = "firefighting_foam"
	description = "Тетрахлорид углерода - это пена, используемая для тушения пожаров."
	reagent_state = LIQUID
	color = "#A0A090"
	var/cooling_temperature = 3 // more effective than water
	taste_description = "пены для огнетушителей"

/datum/reagent/firefighting_foam/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
// Put out fire
	if(method == REAGENT_TOUCH)
		M.adjust_fire_stacks(-10) // more effective than water

/datum/reagent/firefighting_foam/reaction_obj(obj/O, volume)
	O.extinguish()

/datum/reagent/firefighting_foam/reaction_turf(turf/simulated/T, volume)
	if(!istype(T))
		return
	var/CT = cooling_temperature
	new /obj/effect/decal/cleanable/flour/foam(T) //foam mess; clears up quickly.
	var/hotspot = (locate(/obj/effect/hotspot) in T)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = T.remove_air(T.air.total_moles())
		lowertemp.temperature = max(min(lowertemp.temperature-(CT*1000), lowertemp.temperature / CT), TCMB)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)

/datum/reagent/plasma_dust
	name = "Плазменная пыль"
	id = "plasma_dust"
	description = "Тонкая пыль из плазмы. Это химическое вещество обладает необычными мутагенными свойствами как для вирусов, так и для слаймов."
	color = "#500064" // rgb: 80, 0, 100
	taste_description = "пропадающих зря корпоративных активов"
	taste_mult = 1.5

/datum/reagent/plasma_dust/reaction_temperature(exposed_temperature, exposed_volume)
	if(exposed_temperature >= T0C + 100)
		var/turf/T = get_turf(holder.my_atom)
		fire_flash_log(holder, id)
		if(holder)
			holder.del_reagent(id) // Remove first. Else fireflash triggers a reaction again
		fireflash(T, min(max(0, volume / 10), 8))

/datum/reagent/plasma_dust/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(3, FALSE)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.adjust_alien_plasma(20)
	return ..() | update_flags

/datum/reagent/plasma_dust/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)//Splashing people with plasma dust is stronger than fuel!
	if(method == REAGENT_TOUCH)
		M.adjust_fire_stacks(volume / 5)
		return
	..()
