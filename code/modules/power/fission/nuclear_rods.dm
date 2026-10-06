/obj/item/nuclear_rod
	name = "Nuclear Control Rod"
	abstract_type = /obj/item/nuclear_rod
	icon = 'icons/obj/fission/reactor_rods.dmi'
	icon_state = "fuel_238"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE
	w_class = WEIGHT_CLASS_HUGE
	force = 15
	throwforce = 10
	/// The path of the object required to fabricate this rod. leave null for nothing
	var/required_object
	/// How much durability is left before the rod is useless
	var/durability
	/// The maximum amount of durability for this rod. Used for percentage calculations
	var/max_durability = 3000
	/// How fast does this rod degrade? higher = faster
	var/degradation_speed = 1
	/// How much heat does this rod add by default
	var/heat_amount = 0
	/// How does this rod affect its neighbors heating
	var/heat_amp_mod = 1
	/// Holds the current heat mod after durability loss
	var/current_heat_mod
	/// How much power does this rod add by default in watts
	var/power_amount = 0
	/// How does this rod affect its neighbors power production
	var/power_amp_mod = 1
	/// Holds the current power mod after durability loss
	var/current_power_mod
	var/radiation_range = 0
	var/radiation_treshhold = 0
	var/radiation_chance = 0
	/// How much Gamma Rad is emitted by this rod
	var/gamma_rad = 0
	/// What items need to be adjacent to this rod for it to function properly
	var/list/adjacent_requirements = list()
	/// Modifies the reactor's minimum operating temperature.
	var/minimum_temp_modifier = 0
	/// Modified the reactor's overheat threshold
	var/reactor_overheat_modifier = 0
	/// holds our component to modify
	var/datum/component/radioactive_emitter/rad_component
	/// Is this rod craftable at all via fabricators, or do they require other means?
	var/craftable = FALSE
	/// Does this rod require a science-upgraded fabricator?
	var/upgrade_required = FALSE
	var/radioactive

/obj/item/nuclear_rod/get_ru_names()
	return alist(
		NOMINATIVE = "ядерный управляющий стержень",
		GENITIVE = "ядерного управляющего стержня",
		DATIVE = "ядерному управляющему стержню",
		ACCUSATIVE = "ядерный управляющий стержень",
		INSTRUMENTAL = "ядерным управляющим стержнем",
		PREPOSITIONAL = "ядерном управляющем стержне",
	)

/// Returns the Russian name of the rod type based on its path.
/// If the type has not been encountered yet, it creates a temporary instance to warm up GLOB.cached_ru_names.
/proc/rod_ru_name(rod_path)
	if(!rod_path)
		return null
	var/alist/cached = GLOB.cached_ru_names[rod_path]
	if(length(cached))
		return cached[NOMINATIVE]
	var/obj/item/nuclear_rod/rod = new rod_path()
	var/ru_name = rod.declent_ru(NOMINATIVE)
	qdel(rod)
	return ru_name

/obj/item/nuclear_rod/Initialize(mapload)
	. = ..()
	durability = max_durability

/obj/item/nuclear_rod/examine(mob/user)
	. = ..()
	if(length(adjacent_requirements))
		var/list/templist = list()
		for(var/obj/item/nuclear_rod/requirement as anything in adjacent_requirements)
			templist += capitalize(rod_ru_name(requirement))
		var/requirement_list = russian_list(templist, and_text = ", ")
		. += "У этого стержня есть следующие требования к соседям: [requirement_list]"
	else
		. += "У этого стержня нет требований к соседям."

/obj/item/nuclear_rod/proc/get_durability_mod()
	var/temp_mod
	temp_mod = clamp(1.5 * (durability / max_durability) - 0.25, 0.25, 1)
	return temp_mod

/obj/item/nuclear_rod/proc/calc_stat_decrease()
	// Formula: y = (x * A) + (1 - A)
	var/durability_stat = get_durability_mod()
	current_power_mod = (power_amp_mod * durability_stat) + (1 - durability_stat)
	current_heat_mod = (heat_amp_mod * durability_stat) + (1 - durability_stat)

/obj/item/nuclear_rod/proc/start_rads(power_modifier = 1)
	rad_component = AddComponent(/datum/component/radioactive_emitter, range = radiation_range * power_modifier, threshold = radiation_treshhold * power_modifier, chance = radiation_chance * power_modifier)

/obj/item/nuclear_rod/proc/stop_rads()
	if(!rad_component)
		return
	rad_component.RemoveComponent()
	QDEL_NULL(rad_component)

/obj/item/nuclear_rod/proc/check_rad_shield()
	var/turf/location = get_turf(src)
	if(!location || !loc)
		stop_rads()
		return
	if(istype(location, /turf/simulated/floor/plasteel/reactor_pool))
		if(!rad_component)
			return
		else
			stop_rads()
	else if(istype(loc, /obj/machinery/atmospherics/reactor_chamber))
		stop_rads()
	else if(!rad_component)
		start_rads()

/obj/item/nuclear_rod/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	check_rad_shield()

/obj/item/nuclear_rod/fuel
	name = "any fuel rod"
	radiation_range = 1
	radiation_chance = 40
	abstract_type = /obj/item/nuclear_rod/fuel

	/// the amount of cycles needed to complete enrichment. 30 = ~1 minute
	var/enrichment_cycles = 25
	/// the total power amp mod needed to enrich
	var/power_enrich_threshold = 0
	/// How far we have progressed from to power enrichment
	var/power_enrich_progress = 0
	/// What power enrichment results in
	var/power_enrich_result
	/// the total heat amp mod needed to enrich
	var/heat_enrich_threshold = 0
	/// How far we have progressed from to power enrichment
	var/heat_enrich_progress = 0
	/// What heat enrichment results in
	var/heat_enrich_result

/obj/item/nuclear_rod/fuel/get_ru_names()
	return alist(
		NOMINATIVE = "любой топливный стержень",
		GENITIVE = "любого топливного стержня",
		DATIVE = "любому топливному стержню",
		ACCUSATIVE = "любой топливный стержень",
		INSTRUMENTAL = "любым топливным стержнем",
		PREPOSITIONAL = "любом топливном стержне",
	)

/obj/item/nuclear_rod/fuel/Initialize(mapload)
	. = ..()
	if(!is_crate(loc))
		check_rad_shield()

/obj/item/nuclear_rod/fuel/proc/enrich(power_mod, heat_mod)
	var/successful_enrichment = FALSE
	if(power_enrich_result)
		if(power_mod > power_enrich_threshold && power_enrich_progress < enrichment_cycles)
			power_enrich_progress++
			successful_enrichment = TRUE
	if(heat_enrich_result)
		if(heat_mod > heat_enrich_threshold && heat_enrich_progress < enrichment_cycles)
			heat_enrich_progress++
			successful_enrichment = TRUE
	return successful_enrichment

// MARK: Fuel Rods

/obj/item/nuclear_rod/fuel/uranium_238
	name = "uranium 238 fuel rod"
	desc = "Стандартный топливный стержень для большинства реакторов NGCR. Содержит едва ли достаточное количество урана-235, чтобы быть полезным."
	heat_amount = 5
	power_amount = 20 KILO WATTS
	heat_amp_mod = 1.8
	power_amp_mod = 1.1
	radiation_range = 4
	radiation_chance = 80
	heat_enrich_threshold = 10 // all uranium rods surrounding: 1.8 x 1.8 x 1.8 x 1.8
	power_enrich_threshold = 6.4 // all graphite rods surrounding: 1.6 x 1.6 x 1.6 x 1.6
	heat_enrich_result = /obj/item/nuclear_rod/fuel/weak_thorium
	power_enrich_result = /obj/item/nuclear_rod/fuel/weak_plutonium
	adjacent_requirements = list(/obj/item/nuclear_rod/moderator)
	craftable = TRUE
	materials = list(MAT_METAL = 2000, MAT_URANIUM = 1000)

/obj/item/nuclear_rod/fuel/uranium_238/get_ru_names()
	return alist(
		NOMINATIVE = "топливный стержень из урана-238",
		GENITIVE = "топливного стержня из урана-238",
		DATIVE = "топливному стержню из урана-238",
		ACCUSATIVE = "топливный стержень из урана-238",
		INSTRUMENTAL = "топливным стержнем из урана-238",
		PREPOSITIONAL = "топливном стержне из урана-238",
	)

/obj/item/nuclear_rod/fuel/weak_thorium
	name = "weak thorium fuel rod"
	desc = "Специализированный топливный стержень, переработанный из урана-238. Служит дольше обычного и выделяет меньше тепла."
	icon_state = "fuel_weakthor"
	heat_amount = 5
	power_amount = 20 KILO WATTS
	heat_amp_mod = 1.6
	power_amp_mod = 1.1
	max_durability = 5000
	radiation_range = 2
	radiation_chance = 60
	power_enrich_threshold = 8
	power_enrich_result = /obj/item/nuclear_rod/fuel/uranium_235
	adjacent_requirements = list(
		/obj/item/nuclear_rod/moderator,
		/obj/item/nuclear_rod/coolant,
	)

/obj/item/nuclear_rod/fuel/weak_thorium/get_ru_names()
	return alist(
		NOMINATIVE = "ослабленный ториевый топливный стержень",
		GENITIVE = "ослабленного ториевого топливного стержня",
		DATIVE = "ослабленному ториевому топливному стержню",
		ACCUSATIVE = "ослабленный ториевый топливный стержень",
		INSTRUMENTAL = "ослабленным ториевым топливным стержнем",
		PREPOSITIONAL = "ослабленном ториевом топливном стержне",
	)

/obj/item/nuclear_rod/fuel/weak_plutonium
	name = "weak plutonium fuel rod"
	desc = "Специализированный топливный стержень, переработанный из урана-238. Вырабатывает вдвое больше энергии, чем стандартное топливо из урана-238, но предъявляет более высокие требования к работе."
	icon_state = "fuel_weakplut"
	heat_amount = 10
	power_amount = 40 KILO WATTS
	heat_amp_mod = 1.6
	power_amp_mod = 1.1
	max_durability = 3500
	radiation_treshhold = RAD_VERY_LIGHT_INSULATION
	radiation_chance = 50
	heat_enrich_threshold = 14
	heat_enrich_result = /obj/item/nuclear_rod/fuel/uranium_235
	adjacent_requirements = list(
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/moderator,
		/obj/item/nuclear_rod/coolant,
	)

/obj/item/nuclear_rod/fuel/weak_plutonium/get_ru_names()
	return alist(
		NOMINATIVE = "ослабленный плутониевый топливный стержень",
		GENITIVE = "ослабленного плутониевого топливного стержня",
		DATIVE = "ослабленному плутониевому топливному стержню",
		ACCUSATIVE = "ослабленный плутониевый топливный стержень",
		INSTRUMENTAL = "ослабленным плутониевым топливным стержнем",
		PREPOSITIONAL = "ослабленном плутониевом топливном стержне",
	)

/obj/item/nuclear_rod/fuel/uranium_235
	name = "uranium 235 fuel rod"
	desc = "Продвинутый топливный стержень для большинства реакторов NGCR, изготовленный из изотопов урана-235 повышенной плотности."
	icon_state = "fuel_235"
	heat_amount = 20
	power_amount = 50 KILO WATTS
	heat_amp_mod = 2.2
	power_amp_mod = 1.3
	max_durability = 5000
	radiation_range = 3
	radiation_chance = 70
	heat_enrich_threshold = 25
	power_enrich_threshold = 18
	heat_enrich_result = /obj/item/nuclear_rod/fuel/thorium_salts
	power_enrich_result = /obj/item/nuclear_rod/fuel/enriched_plutonium
	origin_tech = "toxins=2"
	craftable = TRUE
	upgrade_required = TRUE
	adjacent_requirements = list(
		/obj/item/nuclear_rod/coolant/plasma_injector,
		/obj/item/nuclear_rod/moderator,
		/obj/item/nuclear_rod/moderator,
	)
	materials = list(MAT_METAL = 4000, MAT_URANIUM = 4000)

/obj/item/nuclear_rod/fuel/uranium_235/get_ru_names()
	return alist(
		NOMINATIVE = "топливный стержень из урана-235",
		GENITIVE = "топливного стержня из урана-235",
		DATIVE = "топливному стержню из урана-235",
		ACCUSATIVE = "топливный стержень из урана-235",
		INSTRUMENTAL = "топливным стержнем из урана-235",
		PREPOSITIONAL = "топливном стержне из урана-235",
	)

/obj/item/nuclear_rod/fuel/thorium_salts
	name = "thorium salts fuel rod"
	desc = "Специализированный топливный стержень, переработанный из урана-235. Хотя заметного прироста мощности у него нет, его поразительный запас прочности делает исчерпание за одну смену практически невозможным — если удастся справиться с теплом."
	icon_state = "fuel_richthor"
	heat_amount = 40
	power_amount = 35 KILO WATTS
	heat_amp_mod = 2.2
	power_amp_mod = 1.3
	max_durability = 15000
	radiation_range = 4
	radiation_chance = 80
	adjacent_requirements = list(
		/obj/item/nuclear_rod/moderator,
		/obj/item/nuclear_rod/fuel/uranium_235,
		/obj/item/nuclear_rod/fuel,
	)

/obj/item/nuclear_rod/fuel/thorium_salts/get_ru_names()
	return alist(
		NOMINATIVE = "топливный стержень из ториевых солей",
		GENITIVE = "топливного стержня из ториевых солей",
		DATIVE = "топливному стержню из ториевых солей",
		ACCUSATIVE = "топливный стержень из ториевых солей",
		INSTRUMENTAL = "топливным стержнем из ториевых солей",
		PREPOSITIONAL = "топливном стержне из ториевых солей",
	)

/obj/item/nuclear_rod/fuel/enriched_plutonium
	name = "enriched plutonium fuel rod"
	desc = "Специализированный топливный стержень, переработанный из урана-235. Чрезвычайно мощный: высокая выработка энергии и умеренная прочность. Однако его тепло представляет исключительную опасность."
	icon_state = "fuel_richplut"
	heat_amount = 60
	power_amount = 75 KILO WATTS
	heat_amp_mod = 4
	power_amp_mod = 1.6
	max_durability = 5000
	radiation_range = 4
	radiation_chance = 80
	power_enrich_threshold = 25
	power_enrich_result = /obj/item/nuclear_rod/fuel/americium
	adjacent_requirements = list(
		/obj/item/nuclear_rod/moderator/plasma_agitator,
		/obj/item/nuclear_rod/fuel/thorium_salts,
	)

/obj/item/nuclear_rod/fuel/enriched_plutonium/get_ru_names()
	return alist(
		NOMINATIVE = "топливный стержень из обогащённого плутония",
		GENITIVE = "топливного стержня из обогащённого плутония",
		DATIVE = "топливному стержню из обогащённого плутония",
		ACCUSATIVE = "топливный стержень из обогащённого плутония",
		INSTRUMENTAL = "топливным стержнем из обогащённого плутония",
		PREPOSITIONAL = "топливном стержне из обогащённого плутония",
	)

/obj/item/nuclear_rod/fuel/supermatter
	name = "supermatter fuel rod"
	desc = "Опасный топливный стержень, целиком изготовленный из суперматтерии и надёжно заключённый в специальный корпус. Из-за своих необычных свойств он полностью нейтрализует потенциальную энергию соседних стержней."
	icon_state = "fuel_sm"
	heat_amount = 1200
	power_amount = 800 KILO WATTS
	heat_amp_mod = 8
	power_amp_mod = 0.1
	max_durability = INFINITY
	radiation_treshhold = RAD_MEDIUM_INSULATION
	radiation_chance = 50
	adjacent_requirements = list(
		/obj/item/nuclear_rod/coolant/steam_hammerjet,
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/moderator,
	)

/obj/item/nuclear_rod/fuel/supermatter/get_ru_names()
	return alist(
		NOMINATIVE = "топливный стержень из суперматтерии",
		GENITIVE = "топливного стержня из суперматтерии",
		DATIVE = "топливному стержню из суперматтерии",
		ACCUSATIVE = "топливный стержень из суперматтерии",
		INSTRUMENTAL = "топливным стержнем из суперматтерии",
		PREPOSITIONAL = "топливном стержне из суперматтерии",
	)

/obj/item/nuclear_rod/fuel/americium
	name = "americium fuel rod"
	desc = "Специализированный топливный стержень, переработанный из обогащённого плутония. Вершина энергетики: его выработка почти не имеет себе равных, если укротить его чудовищный нагрев."
	icon_state = "fuel_americium"
	heat_amount = 100
	power_amount = 200 KILO WATTS
	heat_amp_mod = 6
	power_amp_mod = 3
	max_durability = 4000
	radiation_treshhold = RAD_MEDIUM_INSULATION
	radiation_chance = 50
	adjacent_requirements = list(
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/fuel,
	)

/obj/item/nuclear_rod/fuel/americium/get_ru_names()
	return alist(
		NOMINATIVE = "топливный стержень из америция",
		GENITIVE = "топливного стержня из америция",
		DATIVE = "топливному стержню из америция",
		ACCUSATIVE = "топливный стержень из америция",
		INSTRUMENTAL = "топливным стержнем из америция",
		PREPOSITIONAL = "топливном стержне из америция",
	)

/obj/item/nuclear_rod/fuel/bananium
	name = "bananium fuel rod"
	desc = "Самый весёлый из топливных стержней, лишённый каких-либо твёрдых свойств. Кто знает, что из него выйдет!"
	icon_state = "fuel_clown"
	radiation_treshhold = RAD_MEDIUM_INSULATION
	radiation_chance = 50
	craftable = TRUE
	upgrade_required = TRUE
	materials = list(MAT_TITANIUM = 2000, MAT_BANANIUM = 2000)

/obj/item/nuclear_rod/fuel/bananium/get_ru_names()
	return alist(
		NOMINATIVE = "топливный стержень из бананиума",
		GENITIVE = "топливного стержня из бананиума",
		DATIVE = "топливному стержню из бананиума",
		ACCUSATIVE = "топливный стержень из бананиума",
		INSTRUMENTAL = "топливным стержнем из бананиума",
		PREPOSITIONAL = "топливном стержне из бананиума",
	)


/obj/item/nuclear_rod/fuel/bananium/Initialize(mapload)
	max_durability = rand(1000, 10000)
	power_amp_mod = rand(1, 40) / 10
	heat_amp_mod = rand(5, 80) / 10
	power_amount = rand(10 KILO WATTS, 200 KILO WATTS)
	heat_amount = rand(10, 500)
	return ..()

/obj/item/nuclear_rod/fuel/meltdown
	name = "meltdown rod"
	desc = "Стержень работы Синдиката, способный вырабатывать огромное количество тепла, что в итоге приводит к перегреву реактора."
	icon_state = "fuel_syndie"
	heat_amount = 2000
	max_durability = INFINITY
	minimum_temp_modifier = 4000 // BIG hot
	reactor_overheat_modifier = -400
	radiation_range = 5
	radiation_chance = 80

/obj/item/nuclear_rod/fuel/meltdown/get_ru_names()
	return alist(
		NOMINATIVE = "аварийный стержень",
		GENITIVE = "аварийного стержня",
		DATIVE = "аварийному стержню",
		ACCUSATIVE = "аварийный стержень",
		INSTRUMENTAL = "аварийным стержнем",
		PREPOSITIONAL = "аварийном стержне",
	)

// MARK: Moderator Rods

/obj/item/nuclear_rod/moderator
	name = "any moderator rod"
	abstract_type = /obj/item/nuclear_rod/moderator
	icon_state = "mod_water"

/obj/item/nuclear_rod/moderator/get_ru_names()
	return alist(
		NOMINATIVE = "любой замедляющий стержень",
		GENITIVE = "любого замедляющего стержня",
		DATIVE = "любому замедляющему стержню",
		ACCUSATIVE = "любой замедляющий стержень",
		INSTRUMENTAL = "любым замедляющим стержнем",
		PREPOSITIONAL = "любом замедляющем стержне",
	)

/obj/item/nuclear_rod/moderator/heavy_water
	name = "heavy water moderator"
	desc = "Базовый замедляющий стержень, заполненный особой разновидностью воды, молекулы которой состоят из дейтерия вместо водорода."
	heat_amp_mod = 1.1
	power_amp_mod = 1.4
	craftable = TRUE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)

/obj/item/nuclear_rod/moderator/heavy_water/get_ru_names()
	return alist(
		NOMINATIVE = "замедляющий стержень из тяжёлой воды",
		GENITIVE = "замедляющего стержня из тяжёлой воды",
		DATIVE = "замедляющему стержню из тяжёлой воды",
		ACCUSATIVE = "замедляющий стержень из тяжёлой воды",
		INSTRUMENTAL = "замедляющим стержнем из тяжёлой воды",
		PREPOSITIONAL = "замедляющем стержне из тяжёлой воды",
	)

/obj/item/nuclear_rod/moderator/graphite
	name = "graphite moderator"
	desc = "Замедляющий стержень из слоёного графита. Настоящая классика работы реакторов деления с незапамятных времён."
	icon_state = "mod_graphite"
	heat_amp_mod = 1.3
	power_amp_mod = 1.6
	craftable = TRUE
	materials = list(MAT_METAL = 4000, MAT_PLASMA = 2000)
	adjacent_requirements = list(/obj/item/nuclear_rod/coolant)

/obj/item/nuclear_rod/moderator/graphite/get_ru_names()
	return alist(
		NOMINATIVE = "графитовый замедляющий стержень",
		GENITIVE = "графитового замедляющего стержня",
		DATIVE = "графитовому замедляющему стержню",
		ACCUSATIVE = "графитовый замедляющий стержень",
		INSTRUMENTAL = "графитовым замедляющим стержнем",
		PREPOSITIONAL = "графитовом замедляющем стержне",
	)

/obj/item/nuclear_rod/moderator/titanium
	name = "titanium moderator"
	desc = "Замедляющий стержень из литого титана. То, чего ему не хватает в усилении мощности, он компенсирует универсальностью и прочностью."
	icon_state = "mod_titanium"
	max_durability = 5500
	heat_amp_mod = 0.7
	power_amp_mod = 1.5
	craftable = TRUE
	materials = list(MAT_METAL = 2000, MAT_TITANIUM = 2000)

/obj/item/nuclear_rod/moderator/titanium/get_ru_names()
	return alist(
		NOMINATIVE = "титановый замедляющий стержень",
		GENITIVE = "титанового замедляющего стержня",
		DATIVE = "титановому замедляющему стержню",
		ACCUSATIVE = "титановый замедляющий стержень",
		INSTRUMENTAL = "титановым замедляющим стержнем",
		PREPOSITIONAL = "титановом замедляющем стержне",
	)

/obj/item/nuclear_rod/moderator/plasma_agitator
	name = "plasma agitator"
	desc = "Специализированный замедляющий стержень, повышающий скорость деления в топливных стержнях серией микровспышек. Недолговечен."
	icon_state = "mod_plasma"
	max_durability = 2250
	heat_amount = 20
	heat_amp_mod = 5
	power_amp_mod = 3
	craftable = TRUE
	upgrade_required = TRUE
	adjacent_requirements = list(
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/moderator,
	)
	materials = list(MAT_TITANIUM = 1000, MAT_PLASMA = 4000)

/obj/item/nuclear_rod/moderator/plasma_agitator/get_ru_names()
	return alist(
		NOMINATIVE = "плазменный агитатор",
		GENITIVE = "плазменного агитатора",
		DATIVE = "плазменному агитатору",
		ACCUSATIVE = "плазменный агитатор",
		INSTRUMENTAL = "плазменным агитатором",
		PREPOSITIONAL = "плазменном агитаторе",
	)

/obj/item/nuclear_rod/moderator/aluminum_reflector
	name = "liquid aluminum plate reflector"
	desc = "Специализированный замедляющий стержень, усиливающий выработку соседних топливных стержней. Однако температура жидкого алюминия заставит реактор работать в форсажном режиме."
	icon_state = "mod_aluminium"
	max_durability = 6000
	power_amount = -15 KILO WATTS
	heat_amp_mod = 5
	power_amp_mod = 3
	minimum_temp_modifier = 400
	reactor_overheat_modifier = 100
	craftable = TRUE
	upgrade_required = TRUE
	adjacent_requirements = list(
		/obj/item/nuclear_rod/coolant/nitrogen_circulator,
		/obj/item/nuclear_rod/moderator,
	)
	materials = list(MAT_TITANIUM = 1000, MAT_SILVER = 2000)

/obj/item/nuclear_rod/moderator/aluminum_reflector/get_ru_names()
	return alist(
		NOMINATIVE = "отражатель из жидкого алюминия",
		GENITIVE = "отражателя из жидкого алюминия",
		DATIVE = "отражателю из жидкого алюминия",
		ACCUSATIVE = "отражатель из жидкого алюминия",
		INSTRUMENTAL = "отражателем из жидкого алюминия",
		PREPOSITIONAL = "отражателе из жидкого алюминия",
	)

/obj/item/nuclear_rod/moderator/bluespace_agitator
	name = "bluespace crystal agitator"
	desc = "Продвинутый замедляющий стержень, вытягивающий дополнительные нейтроны из блюспейса, чтобы бомбардировать местные топливные стержни. Результат — колоссальный рост выработки энергии и тепла. Крайне универсален, но высокие требования к питанию ограничивают его применение."
	icon_state = "mod_bluespace"
	max_durability = 4000
	power_amount = -30 KILO WATTS
	heat_amp_mod = 12
	power_amp_mod = 5
	upgrade_required = TRUE
	craftable = TRUE
	materials = list(MAT_METAL = 2000, MAT_TITANIUM = 1000, MAT_BLUESPACE = 1000)

/obj/item/nuclear_rod/moderator/bluespace_agitator/get_ru_names()
	return alist(
		NOMINATIVE = "блюспейс-агитатор",
		GENITIVE = "блюспейс-агитатора",
		DATIVE = "блюспейс-агитатору",
		ACCUSATIVE = "блюспейс-агитатор",
		INSTRUMENTAL = "блюспейс-агитатором",
		PREPOSITIONAL = "блюспейс-агитаторе",
	)

/obj/item/nuclear_rod/moderator/diamond_plate
	name = "diamond reflector plates"
	desc = "Продвинутый замедляющий стержень, отражающий почти все нейтроны обратно к точке возникновения. Просто, стабильно, надёжно."
	icon_state = "mod_diamond"
	max_durability = 6000
	heat_amp_mod = 6.5
	power_amp_mod = 3.3
	reactor_overheat_modifier = 100
	craftable = TRUE
	upgrade_required = TRUE
	materials = list(MAT_METAL = 2000, MAT_TITANIUM = 1000, MAT_DIAMOND = 1000)
	adjacent_requirements = list(
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/fuel,
	)

/obj/item/nuclear_rod/moderator/diamond_plate/get_ru_names()
	return alist(
		NOMINATIVE = "алмазные отражательные пластины",
		GENITIVE = "алмазных отражательных пластин",
		DATIVE = "алмазным отражательным пластинам",
		ACCUSATIVE = "алмазные отражательные пластины",
		INSTRUMENTAL = "алмазными отражательными пластинами",
		PREPOSITIONAL = "алмазных отражательных пластинах",
	)

/obj/item/nuclear_rod/moderator/platinum_plating
	name = "platinum reflector plating"
	desc = "Продвинутый замедлитель, подобный алмазным пластинам, но улучшенный драгоценными космическими металлами."
	icon_state = "mod_platinum"
	max_durability = 8000
	heat_amp_mod = 8
	power_amp_mod = 3.9
	reactor_overheat_modifier = 300
	craftable = TRUE
	upgrade_required = TRUE
	adjacent_requirements = list(/obj/item/nuclear_rod/fuel/americium)
	materials = list(MAT_TITANIUM = 1000, MAT_GOLD = 2000)

/obj/item/nuclear_rod/moderator/platinum_plating/get_ru_names()
	return alist(
		NOMINATIVE = "платиновое отражательное покрытие",
		GENITIVE = "платинового отражательного покрытия",
		DATIVE = "платиновому отражательному покрытию",
		ACCUSATIVE = "платиновое отражательное покрытие",
		INSTRUMENTAL = "платиновым отражательным покрытием",
		PREPOSITIONAL = "платиновом отражательном покрытии",
	)

/// MARK: Coolant Rods

/obj/item/nuclear_rod/coolant
	name = "any coolant rod"
	abstract_type = /obj/item/nuclear_rod/coolant
	icon_state = "coolant_water"

/obj/item/nuclear_rod/coolant/get_ru_names()
	return alist(
		NOMINATIVE = "любой охлаждающий стержень",
		GENITIVE = "любого охлаждающего стержня",
		DATIVE = "любому охлаждающему стержню",
		ACCUSATIVE = "любой охлаждающий стержень",
		INSTRUMENTAL = "любым охлаждающим стержнем",
		PREPOSITIONAL = "любом охлаждающем стержне",
	)

/obj/item/nuclear_rod/coolant/light_water
	name = "light water circulator"
	desc = "Базовый охлаждающий стержень, прогоняющий дистиллированную воду через ключевые узлы реактора."
	heat_amount = -10
	power_amount = -10 KILO WATTS
	reactor_overheat_modifier = 25
	craftable = TRUE
	adjacent_requirements = list(/obj/item/nuclear_rod/moderator)
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)

/obj/item/nuclear_rod/coolant/light_water/get_ru_names()
	return alist(
		NOMINATIVE = "циркулятор с лёгкой водой",
		GENITIVE = "циркулятора с лёгкой водой",
		DATIVE = "циркулятору с лёгкой водой",
		ACCUSATIVE = "циркулятор с лёгкой водой",
		INSTRUMENTAL = "циркулятором с лёгкой водой",
		PREPOSITIONAL = "циркуляторе с лёгкой водой",
	)

/obj/item/nuclear_rod/coolant/co2_regulator
	name = "carbon dioxide regulator"
	desc = "Специализированный охлаждающий стержень, заполненный углекислым газом. Сглаживает температурные скачки топливных стержней, но крайне неэнергоэффективен."
	icon_state = "coolant_carbon"
	heat_amount = -4
	heat_amp_mod = 0.6
	power_amount = -15 KILO WATTS
	craftable = TRUE
	adjacent_requirements = list(/obj/item/nuclear_rod/moderator)
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 2000, MAT_GLASS = 1000)

/obj/item/nuclear_rod/coolant/co2_regulator/get_ru_names()
	return alist(
		NOMINATIVE = "регулятор углекислого газа",
		GENITIVE = "регулятора углекислого газа",
		DATIVE = "регулятору углекислого газа",
		ACCUSATIVE = "регулятор углекислого газа",
		INSTRUMENTAL = "регулятором углекислого газа",
		PREPOSITIONAL = "регуляторе углекислого газа",
	)

/obj/item/nuclear_rod/coolant/plasma_injector
	name = "plasma injector"
	desc = "Специализированный охлаждающий стержень с газообразной плазмой. Используя уникальные свойства плазмы поглощать тепло, небольшие порции, впрыскиваемые вокруг топливных стержней, нейтрализуют избыточное тепло. Однако баллон быстро опустошается таким образом."
	icon_state = "coolant_plasma"
	max_durability = 1900
	heat_amp_mod = 0.5
	power_amp_mod = 1.5
	craftable = TRUE
	adjacent_requirements = list(/obj/item/nuclear_rod/coolant)
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 2000, MAT_GLASS = 1000)

/obj/item/nuclear_rod/coolant/plasma_injector/get_ru_names()
	return alist(
		NOMINATIVE = "плазменный инжектор",
		GENITIVE = "плазменного инжектора",
		DATIVE = "плазменному инжектору",
		ACCUSATIVE = "плазменный инжектор",
		INSTRUMENTAL = "плазменным инжектором",
		PREPOSITIONAL = "плазменном инжекторе",
	)

/obj/item/nuclear_rod/coolant/nitrogen_circulator
	name = "nitrogen circulator"
	desc = "Специализированный охлаждающий стержень, заполненный азотом. Менее мощный аналогов, зато исключительно стабилен и служит дольше."
	icon_state = "coolant_nitrogen"
	max_durability = 3500
	heat_amount = -10
	power_amp_mod = 0.9
	heat_amp_mod = 0.7
	craftable = TRUE
	reactor_overheat_modifier = 50
	power_amount = -5 KILO WATTS
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 2000, MAT_GLASS = 1000)

/obj/item/nuclear_rod/coolant/nitrogen_circulator/get_ru_names()
	return alist(
		NOMINATIVE = "азотный циркулятор",
		GENITIVE = "азотного циркулятора",
		DATIVE = "азотному циркулятору",
		ACCUSATIVE = "азотный циркулятор",
		INSTRUMENTAL = "азотным циркулятором",
		PREPOSITIONAL = "азотном циркуляторе",
	)

/obj/item/nuclear_rod/coolant/molten_salt
	name = "molten salt circulator"
	desc = "Специализированный охлаждающий стержень, прогоняющий расплавленные соли через сердцевину реактора. Несмотря на то, что он заставляет реактор работать крайне горячо, он обеспечивает первоклассный отвод тепла сверх рабочей температуры."
	icon_state = "coolant_salt"
	power_amount = -20 KILO WATTS
	heat_amount = -60
	heat_amp_mod = 0.8
	max_durability = 8000
	minimum_temp_modifier = 750
	reactor_overheat_modifier = 100
	craftable = TRUE
	upgrade_required = TRUE
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 2000, MAT_GLASS = 1000)
	adjacent_requirements = list(
		/obj/item/nuclear_rod/coolant/nitrogen_circulator,
		/obj/item/nuclear_rod/moderator,
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/fuel,
	)

/obj/item/nuclear_rod/coolant/molten_salt/get_ru_names()
	return alist(
		NOMINATIVE = "циркулятор расплавленных солей",
		GENITIVE = "циркулятора расплавленных солей",
		DATIVE = "циркулятору расплавленных солей",
		ACCUSATIVE = "циркулятор расплавленных солей",
		INSTRUMENTAL = "циркулятором расплавленных солей",
		PREPOSITIONAL = "циркуляторе расплавленных солей",
	)

/obj/item/nuclear_rod/coolant/steam_hammerjet
	name = "steam hammerjet"
	desc = "Специализированный охлаждающий стержень, распыляющий водяной пар по ключевым узлам реактора. Да, реактор работает теплее, но накоплению тепла он противостоит превосходно."
	icon_state = "coolant_steam"
	power_amount = -10 KILO WATTS
	heat_amount = -40
	heat_amp_mod = 0.4
	max_durability = 6000
	minimum_temp_modifier = 450
	reactor_overheat_modifier = 100
	craftable = TRUE
	upgrade_required = TRUE
	adjacent_requirements = list(
		/obj/item/nuclear_rod/coolant/light_water,
		/obj/item/nuclear_rod/coolant/light_water,
	)
	materials = list(MAT_TITANIUM = 1000, MAT_GOLD = 1000)

/obj/item/nuclear_rod/coolant/steam_hammerjet/get_ru_names()
	return alist(
		NOMINATIVE = "паровой ударный инжектор",
		GENITIVE = "парового ударного инжектора",
		DATIVE = "паровому ударному инжектору",
		ACCUSATIVE = "паровой ударный инжектор",
		INSTRUMENTAL = "паровым ударным инжектором",
		PREPOSITIONAL = "паровом ударном инжекторе",
	)

/obj/item/nuclear_rod/coolant/bluespace_displacer
	name = "bluespace heat displacer"
	desc = "Продвинутый охлаждающий стержень, вытягивающий тепло прямо из соседних стержней и отправляющий его... куда-то."
	icon_state = "coolant_bluespace"
	power_amount = -40 KILO WATTS
	heat_amount = -100
	heat_amp_mod = 0.8
	power_amp_mod = 1.3
	max_durability = INFINITY
	reactor_overheat_modifier = 200
	craftable = TRUE
	upgrade_required = TRUE
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 2000, MAT_BLUESPACE = 1000)
	adjacent_requirements = list(/obj/item/nuclear_rod/moderator/bluespace_agitator)

/obj/item/nuclear_rod/coolant/bluespace_displacer/get_ru_names()
	return alist(
		NOMINATIVE = "блюспейс-перемещатель тепла",
		GENITIVE = "блюспейс-перемещателя тепла",
		DATIVE = "блюспейс-перемещателю тепла",
		ACCUSATIVE = "блюспейс-перемещатель тепла",
		INSTRUMENTAL = "блюспейс-перемещателем тепла",
		PREPOSITIONAL = "блюспейс-перемещателе тепла",
	)

/obj/item/nuclear_rod/coolant/iridium_conductor
	name = "iridium conductor coolant rod"
	desc = "Ослепительно красивый стержень с исключительно высокой теплопроводностью. Весьма востребован благодаря простоте и мощности."
	icon_state = "coolant_iridium"
	heat_amp_mod = 0.1
	max_durability = 10000
	reactor_overheat_modifier = 300
	craftable = TRUE
	upgrade_required = TRUE
	adjacent_requirements = list(
		/obj/item/nuclear_rod/moderator/aluminum_reflector,
		/obj/item/nuclear_rod/fuel/uranium_235,
	)
	materials = list(MAT_TITANIUM = 1000, MAT_SILVER = 2000)

/obj/item/nuclear_rod/coolant/iridium_conductor/get_ru_names()
	return alist(
		NOMINATIVE = "иридиевый охлаждающий стержень",
		GENITIVE = "иридиевого охлаждающего стержня",
		DATIVE = "иридиевому охлаждающему стержню",
		ACCUSATIVE = "иридиевый охлаждающий стержень",
		INSTRUMENTAL = "иридиевым охлаждающим стержнем",
		PREPOSITIONAL = "иридиевом охлаждающем стержне",
	)

/obj/item/nuclear_rod/coolant/condensed_spacematter
	name = "condensed spacematter coolant rod"
	desc = "Неизвестно, чем именно заполнен стержень, но его эффективность подавления тепла не подлежит сомнению. Правда, при контакте с чем-либо, кроме своего корпуса, он бурно диссоциирует."
	icon_state = "coolant_spacematter"
	heat_amount = -1500
	heat_amp_mod = 0.2
	materials = list(MAT_METAL = 6000, MAT_PLASMA = 4000, MAT_TITANIUM = 2000)
	craftable = TRUE
	upgrade_required = TRUE
	adjacent_requirements = list(
		/obj/item/nuclear_rod/fuel/enriched_plutonium,
		/obj/item/nuclear_rod/fuel/thorium_salts,
	)

/obj/item/nuclear_rod/coolant/condensed_spacematter/get_ru_names()
	return alist(
		NOMINATIVE = "охлаждающий стержень из уплотнённой космоматерии",
		GENITIVE = "охлаждающего стержня из уплотнённой космоматерии",
		DATIVE = "охлаждающему стержню из уплотнённой космоматерии",
		ACCUSATIVE = "охлаждающий стержень из уплотнённой космоматерии",
		INSTRUMENTAL = "охлаждающим стержнем из уплотнённой космоматерии",
		PREPOSITIONAL = "охлаждающем стержне из уплотнённой космоматерии",
	)
