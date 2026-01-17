/datum/station_trait/carp_infestation
	name = "Миграция космической фауны"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Сканеры дальнего действия регистрируют массивную миграцию космических карпов в вашем секторе. Соблюдайте осторожность при работе в космосе."
	trait_to_give = STATION_TRAIT_CARP_INFESTATION

/datum/station_trait/distant_supply_lines
	name = "Логистический кризис"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 3
	show_in_report = TRUE
	report_message = "Маршрут шаттла снабжения к вашему объекту был пересмотрен из-за активности пиратов. Для покрытия транспортных расходов на все заказы была введена временная наценка."
	blacklist = list(/datum/station_trait/strong_supply_lines)

/datum/station_trait/distant_supply_lines/on_round_start()
	for(var/set_name in SSshuttle.supply_packs)
		var/datum/supply_packs/pack = SSshuttle.supply_packs[set_name]
		pack.cost *= 1.2

/datum/station_trait/late_arrivals
	name = "Задержка прибытия"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	show_in_report = TRUE
	report_message = "Из-за сбоя навигационной системы шаттл прибытия достиг объекта со значительным опозданием. Приступайте к обязанностям немедленно, время не ждёт."
	trait_to_give = STATION_TRAIT_LATE_ARRIVALS
	blacklist = list(/datum/station_trait/random_spawns, /datum/station_trait/hangover)

/datum/station_trait/random_spawns
	name = "Экстренное приземление"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	show_in_report = TRUE
	report_message = "Пилот шаттла пропустил окно для торможения. Для экономии топлива было принято решение выбросить экипаж в десантных капсулах. Удачи при приземлении."
	trait_to_give = STATION_TRAIT_RANDOM_ARRIVALS
	blacklist = list(/datum/station_trait/late_arrivals, /datum/station_trait/hangover)

/datum/station_trait/hangover
	name = "Последствия корпоратива"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	show_in_report = TRUE
	report_message = "Вчерашний обязательный тимбилдинг прошёл... слишком эффективно. Постарайтесь не дышать перегаром на атмосферные сенсоры."
	trait_to_give = STATION_TRAIT_HANGOVER
	blacklist = list(/datum/station_trait/late_arrivals, /datum/station_trait/random_spawns)

/datum/station_trait/hangover/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/hangover/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned_mob)
	SIGNAL_HANDLER

	if(!prob(35))
		return

	var/obj/item/hat = pick(
		/obj/item/clothing/head/sombrero/green,
		/obj/item/clothing/head/fedora,
		/obj/item/clothing/mask/balaclava,
		/obj/item/clothing/head/ushanka,
		/obj/item/clothing/head/cardborg,
		/obj/item/clothing/head/pirate,
		/obj/item/clothing/head/cone,
		)
	hat = new hat(spawned_mob)
	spawned_mob.equip_to_slot_or_del(hat, ITEM_SLOT_HEAD)

/datum/station_trait/blackout
	name = "Авария энергосистемы"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 3
	show_in_report = TRUE
	report_message = "Халатность прошлого инженерного состава привела к критической перегрузке световой сети. Будьте осторожны и смотрите под ноги."

/datum/station_trait/blackout/on_round_start()
	. = ..()
	for(var/obj/machinery/power/apc/apc in GLOB.apcs)
		if(is_station_level(apc.z) && prob(60))
			INVOKE_ASYNC(apc, TYPE_PROC_REF(/obj/machinery/power/apc, overload_lighting))

/datum/station_trait/empty_maint
	name = "Генеральная уборка"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Объект прошёл полную санитарную обработку перед вашим прибытием. Технические туннели очищены от мусора."
	blacklist = list(/datum/station_trait/filled_maint)
	trait_to_give = STATION_TRAIT_EMPTY_MAINT
	// This station trait is checked when loot drops initialize, so it's too late
	can_revert = FALSE

/// Cap is set to 20. As HoP can close only one job per minute, it take some time to fix everythimg, if it's fixable, of course
/datum/station_trait/overflow_job_bureaucracy
	name = "Бюрократическая ошибка"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	var/chosen_job_name
	// This station trait is checked when subsystems initialize, so it's too late
	can_revert = FALSE

/datum/station_trait/overflow_job_bureaucracy/New()
	. = ..()
	RegisterSignal(SSjobs, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(set_overflow_job_override))

/datum/station_trait/overflow_job_bureaucracy/get_report()
	return "<i>[name]</i> — Из-за сбоя HR-алгоритма на одну из должностей экипажа было назначенно избыточное количество сотрудников. Судя по нашим данным, это [chosen_job_name]."

/datum/station_trait/overflow_job_bureaucracy/proc/set_overflow_job_override(datum/source)
	SIGNAL_HANDLER
	var/datum/job/picked_job = pick(SSjobs.get_valid_overflow_jobs())
	chosen_job_name = LOWER_TEXT(picked_job.title) // like Chief Engineers vs like chief engineers
	SSjobs.set_overflow_role(picked_job.type)

/datum/station_trait/slow_shuttle
	name = "Коррекция маршрута снабжения"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "\"АКН Трурль\" был вынужден совершить гравитационный манёвр. Время подлёта шаттла снабжения значительно увеличено."
	blacklist = list(/datum/station_trait/quick_shuttle)

/datum/station_trait/slow_shuttle/on_round_start()
	. = ..()
	SSshuttle.supply.callTime *= 1.5

/datum/station_trait/bot_languages
	name = "Лингвистический сбой"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 4
	cost = STATION_TRAIT_COST_LOW
	show_in_report = TRUE
	report_message = "Недавний ионный шторм повредил языковые матрицы роботизированных систем. Синтезаторы речи могут выдавать неожиданные диалекты."
	trait_to_give = STATION_TRAIT_BOTS_GLITCHED

/// Abstract station trait used for traits that modify a random event in some way (their weight or max occurrences).
/// I fucking hate event container system
/datum/station_trait/random_event_weight_modifier
	name = "Модификатор рандомных ивентов"
	report_message = "Одно из событий было модифицировано. Интересно, как это скажется на игре?"
	show_in_report = TRUE
	abstract_type = /datum/station_trait/random_event_weight_modifier
	weight = 0

	/// The names of the event we modify.
	var/list/event_names = list()
	/// The severity of the event we modify.
	var/datum/event_container/event_severity
	/// Multiplier applied to the weight of the event. may want to apply to scaling as well
	var/weight_multiplier = 1
	/// Do we want to turn off is one shot?
	var/disable_is_one_shot = FALSE

/datum/station_trait/random_event_weight_modifier/on_round_start()
	. = ..()
	for(var/datum/event_container/event_sever in SSevents.event_containers)
		if(istype(event_sever, event_severity))
			event_severity = event_sever
	var/modified_event = FALSE

	for(var/datum/event_meta/event_meta in event_severity.available_events)
		for(var/i in event_names)
			if(event_meta.name == i)
				event_meta.weight *= weight_multiplier
				for(var/role_weight in event_meta.role_weights)
					event_meta.role_weights[role_weight] *= weight_multiplier
				if(disable_is_one_shot == TRUE)
					event_meta.one_shot = FALSE
				modified_event = TRUE

	if(!modified_event)
		CRASH("[type] could not find a round event controller to modify on round start (likely has an invalid event_name or event_severity set, or an admin removed the event from the list)!")

/datum/station_trait/random_event_weight_modifier/ion_storms
	name = "Ионная буря"
	report_message = "Станция была расположена в эпицентре ионизированной туманности. Ожидайте повышенную вероятность ионных штормов, влияющих на работу роботизированных систем."
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 3
	event_names = list("Ионный тайфун")
	event_severity = /datum/event_container/moderate
	weight_multiplier = 5 //500 instead of 100
	blacklist = list(/datum/station_trait/unique_ai)

/datum/station_trait/random_event_weight_modifier/rad_storms
	name = "Радиационная буря"
	report_message = "Звезда системы вошла в цикл повышенной активности. Ожидайте повышенную вероятность радиационных штормов."
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	event_names = list("Радиационный шторм")
	event_severity = /datum/event_container/moderate
	weight_multiplier = 4 //100 instead of 25
	disable_is_one_shot = TRUE

/datum/station_trait/random_event_weight_modifier/meteor_showers
	name = "Метеорный вал"
	report_message = "Орбита объекта пересекается с метеоритным потоком. Инженерам рекомендуется проверить системы защиты от метеоритов."
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	event_names = list("Метеорный дождь")
	event_severity = /datum/event_container/moderate
	weight_multiplier = 5 //50 instead of 10. Probably much more, idk event containers SUCK

/datum/station_trait/random_event_weight_modifier/anomaly_storms
	name = "Аномальное созвездие"
	report_message = "Сканеры дальнего действия фиксируют истончение ткани реальности в вашем секторе. Ожидается повышенная аномальная активность."
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	event_names = list("Аномалия", "Червоточины")
	event_severity = /datum/event_container/moderate
	weight_multiplier = 3 ///1500 instead of 500. Oh god

/datum/station_trait/random_event_weight_modifier/more_antags
	name = "Вражеская активность"
	report_message = "Разведка докладывает о присутствии враждебных кораблей в секторе. Экипажу объекта соблюдать полную боевую готовность."
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	event_names = list("Космический ниндзя", "Ядерный оперативник", "Дрейфующий Контрактник")
	event_severity = /datum/event_container/moderate
	weight_multiplier = 3
	disable_is_one_shot = TRUE

/datum/station_trait/random_event_weight_modifier/more_majors
	name = "Повышенная биологическая опасность"
	report_message = "В вашем секторе был зафиксирован высокий риск столкновения с биологическими угрозами высшего уровня. Экипажу объекта соблюдать полную боевую готовность."
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 1
	event_names = list("Блоб", "Заражение ксеноморфами", "Пауки Ужаса", "Космический Дракон")
	event_severity = /datum/event_container/major
	weight_multiplier = 3

/datum/station_trait/random_event_weight_modifier/emp_satellite
	name = "ЭМИ-Интерференция"
	report_message = "В секторе объекта был обнаружен замаскированный спутник РЭБ вражеской корпорации. В ближайшее время возможны массовые повреждения электроники. Наши сотрудники уже занимаются его обезвреживанием."
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	event_names = list("Перегрузка ЛКП", "Сбой работы дверей", "Цифровой вирус", "Электрический шторм", "Телекоммуникационный сбой")
	event_severity = /datum/event_container/moderate
	weight_multiplier = 5
	disable_is_one_shot = TRUE

/datum/station_trait/random_event_weight_modifier/spiders
	name = "Инсектоидная угроза"
	report_message = "Экипаж прошлой смены сообщил нам об обнаружении паучьих гнёзд в вентиляционной системе объекта. Рекомендуем проявлять бдительность."
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	event_names = list("Нашествие пауков")
	event_severity = /datum/event_container/moderate
	weight_multiplier = 10 //oh god
	disable_is_one_shot = TRUE

/datum/station_trait/revolutionary_trashing
	name = "Последствия беспорядков"
	report_message = "Экипаж прошлой смены предпринял безуспешную попытку вооружённого переворота. Мы не успели убрать весь беспорядок."
	trait_type = STATION_TRAIT_NEGATIVE
	show_in_report = TRUE
	trait_to_give = STATION_TRAIT_REVOLUTIONARY_TRASHING
	weight = 2
	blacklist = list(/datum/station_trait/post_war)
	/// The IDs of the graffiti designs that we will generate.
	var/static/list/trash_talk = list(
		"youaredead",
		"tunnelsnake",
		"body",
		"end",
		"revolution",
		"uboa",
		"syndicate2",
		"syndicate1",
		"lie",
		"valid",
		"voxpox",
		"shitcurity",
		"peace",
		"cyka",
		"antilizard",
		"Tunnel",
		"Gib",
		"space",
		"prolizard",
	)
	/// Lists of area to trash
	var/static/list/areas_to_trash = list(
		/area/bridge,
		/area/security,
		/area/medical/cmo,
		/area/quartermaster/qm,
		/area/blueshield,
		/area/ntrep,
		/area/lawoffice,
		/area/magistrateoffice,
		/area/crew_quarters/captain,
		/area/crew_quarters/heads,
		/area/crew_quarters/hor,
		/area/crew_quarters/hos,
		/area/crew_quarters/chief,
		/area/crew_quarters/courtroom,
		/area/crew_quarters/recruit,
	)

/datum/station_trait/revolutionary_trashing/on_round_start()
	. = ..()

	INVOKE_ASYNC(src, PROC_REF(trash_this_place)) //Must be called asynchronously

/**
 * "Trashes" the command areas of the station.
 *
 * Creates random graffiti and damages certain machinery/structures in the
 * command areas of the station.
 */

/datum/station_trait/revolutionary_trashing/proc/trash_this_place()
	var/choosen_areas = list()
	for(var/area/command_area as anything in GLOB.areas)
		if(is_type_in_list(command_area, areas_to_trash))
			choosen_areas += command_area

	for(var/area/area_to_trash in choosen_areas)
		for(var/list/zlevel_turfs as anything in area_to_trash.get_zlevel_turf_lists())
			for(var/turf/current_turf as anything in zlevel_turfs)
				if(iswallturf(current_turf))
					continue
				if(prob(25))
					var/obj/effect/decal/cleanable/crayon/created_art
					created_art = new(current_turf, RANDOM_COLOUR, pick(trash_talk))
					created_art.pixel_x = rand(-10, 10)
					created_art.pixel_y = rand(-10, 10)

				if(prob(0.1)) /// prob(1) is too much
					new /obj/effect/mob_spawn/human/corpse/assistant(current_turf)
					continue

				for(var/obj/current_thing as anything in current_turf.contents)
					if(istype(current_thing, /obj/machinery/light) && prob(40))
						var/obj/machinery/light/light_to_smash = current_thing
						light_to_smash.break_light_tube(skip_sound_and_sparks = TRUE)
						continue

					if(istype(current_thing, /obj/structure/window))
						if(prob(45))
							current_thing.take_damage(rand(50, 90)) //fulltile windows will be safe
							continue

					if(istype(current_thing, /obj/structure/table) && prob(40))
						current_thing.take_damage(100)
						continue

					if(istype(current_thing, /obj/structure/chair) && prob(60))
						current_thing.take_damage(300)
						continue

					if(istype(current_thing, /obj/machinery/computer) && prob(30))
						if(istype(current_thing, /obj/machinery/computer/communications))
							continue //To prevent the shuttle from getting autocalled at the start of the round
						current_thing.take_damage(160)
						continue

					if(istype(current_thing, /obj/machinery/vending) && prob(70))
						var/obj/machinery/vending/vendor_to_trash = current_thing
						vendor_to_trash.obj_break()
						continue

					if(istype(current_thing, /obj/structure/closet/fireaxecabinet)) //A staple of revolutionary behavior
						current_thing.take_damage(90)
						continue

					if(istype(current_thing, /obj/item/bedsheet))
						qdel(current_thing)
						continue

					if(istype(current_thing, /obj/item/flag))
						new /obj/item/flag/ussp(current_thing.loc)
						qdel(current_thing)
						continue

					if(istype(current_thing, /obj/machinery/door) && prob(50))
						current_thing.take_damage(rand(200, 400))
						continue

				CHECK_TICK

/datum/station_trait/post_war
	name = "Последствия битвы"
	report_message = "Предыдущий экипаж объекта столкнулся с попыткой штурма оперативниками отряда \"Атом\". Силы ОБР устранили противника, но структурная целостность была серьёзно нарушена."
	trait_type = STATION_TRAIT_NEGATIVE
	show_in_report = TRUE
	trait_to_give = STATION_TRAIT_REVOLUTIONARY_TRASHING
	weight = 1
	blacklist = list(/datum/station_trait/revolutionary_trashing)

/datum/station_trait/post_war/on_round_start()
	. = ..()

	INVOKE_ASYNC(src, PROC_REF(trash_this_place)) //Must be called asynchronously

/datum/station_trait/post_war/proc/trash_this_place()
	for(var/area/area_to_trash in SSmapping.existing_station_areas)
		for(var/list/zlevel_turfs as anything in area_to_trash.get_zlevel_turf_lists())
			for(var/turf/current_turf as anything in zlevel_turfs)
				if(iswallturf(current_turf))
					var/turf/simulated/wall/our_wall = current_turf
					if(prob(15))
						our_wall.add_multiple_dents(rand(1, 10), WALL_DENT_SHOT)
					continue

				if(isfloorturf(current_turf) && prob(20))
					var/turf/simulated/floor/station_floor = current_turf
					if(prob(70))
						station_floor.burn_tile()
					else
						station_floor.break_tile()
					if(prob(45))
						new /obj/item/ammo_casing/c45/empty(current_turf)

				for(var/obj/current_thing as anything in current_turf.contents)
					if(istype(current_thing, /obj/machinery/light) && prob(40))
						var/obj/machinery/light/light_to_smash = current_thing
						light_to_smash.break_light_tube(skip_sound_and_sparks = TRUE)
						continue

					if(istype(current_thing, /obj/structure/window))
						if(prob(45))
							current_thing.take_damage(rand(40, 90)) //fulltile windows will be safe
							continue

					if(istype(current_thing, /obj/machinery/computer) && prob(5))
						if(istype(current_thing, /obj/machinery/computer/communications))
							continue //To prevent the shuttle from getting autocalled at the start of the round
						current_thing.take_damage(rand(150, 300))
						continue

					if(istype(current_thing, /obj/item/flag) && prob(40))
						new /obj/item/flag/syndi(current_thing.loc)
						qdel(current_thing)
						continue

					if(istype(current_thing, /obj/machinery/vending) && prob(5))
						var/obj/machinery/vending/vendor_to_trash = current_thing
						vendor_to_trash.obj_break()
						continue

					if(istype(current_thing, /obj/structure/closet/secure_closet) && prob(20))
						current_thing.emag_act()
						continue

					if(istype(current_thing, /obj/machinery/door) && prob(10))
						if(prob(10))
							current_thing.emag_act()
						else
							current_thing.take_damage(rand(150, 300))
						continue

				CHECK_TICK

/datum/station_trait/cramped_internals
	name = "Бюджетные аварийные наборы"
	report_message = "В целях оптимизации квартального бюджета содержимое экстренных коробок экипажа было сокращено до необходимого минимума."
	trait_type = STATION_TRAIT_NEGATIVE
	show_in_report = TRUE
	trait_to_give = STATION_TRAIT_CRAMPED_INTERNALS
	weight = 2
	blacklist = list(/datum/station_trait/premium_internals_box)

/datum/station_trait/looted_armory
	name = "Разграбленная оружейная"
	report_message = "Из-за острой нехватки финансирования, часть снаряжения в оружейной объекта была списана. В качестве компенсации стоимость заказа вооружения была снижена."
	trait_type = STATION_TRAIT_NEGATIVE
	show_in_report = TRUE
	trait_to_give = STATION_TRAIT_LOOTED_ARMORY
	weight = 2
	blacklist = list(/datum/station_trait/upgraded_armory)

/datum/station_trait/looted_armory/on_round_start()
	. = ..()
	for(var/set_name in SSshuttle.supply_packs)
		var/datum/supply_packs/pack = SSshuttle.supply_packs[set_name]
		if(get_supply_group_name(pack.group) != "Безопасность") //fuck
			continue
		pack.cost *= 0.6

	INVOKE_ASYNC(src, PROC_REF(loot_armory))

/datum/station_trait/looted_armory/proc/loot_armory()
	for(var/area/security/securearmory/armory in GLOB.areas)
		for(var/list/zlevel_turfs as anything in armory.get_zlevel_turf_lists())
			for(var/turf/current_turf as anything in zlevel_turfs)
				for(var/obj/current_thing as anything in current_turf.contents)

					if(istype(current_thing, /obj/item) && prob(50))
						if(istype(current_thing, /obj/item/clothing/suit/armor/reflector))
							continue
						qdel(current_thing)
						continue

					if(istype(current_thing, /obj/vehicle) && prob(70))
						qdel(current_thing)
						continue

					if(istype(current_thing, /obj/machinery/flasher) && prob(60))
						qdel(current_thing)
						continue
					if(istype(current_thing, /obj/machinery/suit_storage_unit) && prob(40))
						qdel(current_thing)
						continue

				CHECK_TICK

/* trait will be added, when modsuits will be merged
/datum/station_trait/outdated_hardsuits
	name = "Устаревшее снаряжение для ВКД"
	report_message = "Из-за острой нехватки финансирования, на ваш объект не были закуплены модульные экзо-костюмы, так что вам придётся довольствоваться устаревшими хардсьютами."
	trait_type = STATION_TRAIT_NEGATIVE
	show_in_report = TRUE
	trait_to_give = STATION_TRAIT_OUTDATED_HARDSUITS
	weight = 2
*/
