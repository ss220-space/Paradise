/datum/station_trait/carp_infestation
	name = "Нашествие карпов"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Недалеко от станции расположился большой косяк космических карпов"
	trait_to_give = STATION_TRAIT_CARP_INFESTATION

/datum/station_trait/distant_supply_lines
	name = "Проблемы со снабжением"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 3
	show_in_report = TRUE
	report_message = "Из-за чрезвычайного происшествия с шаттлом поставок, все цены в карго повышены."
	//blacklist = list(/datum/station_trait/strong_supply_lines)

/datum/station_trait/distant_supply_lines/on_round_start()
	for(var/set_name in SSshuttle.supply_packs)
		var/datum/supply_packs/pack = SSshuttle.supply_packs[set_name]
		pack.cost *= 1.2

/datum/station_trait/late_arrivals
	name = "Позднее прибытие"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	show_in_report = TRUE
	report_message = "Из-за ошибки в расчетах маршрута, прибытие на станцию произошло гораздо позже, чем ожидалось."
	trait_to_give = STATION_TRAIT_LATE_ARRIVALS
	blacklist = list(/datum/station_trait/random_spawns, /datum/station_trait/hangover)

/datum/station_trait/random_spawns
	name = "Экстренное приземление"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	show_in_report = TRUE
	report_message = "Из-за ошибки с нашей стороны, мы пролетели станцию на несколько световых секунд, поэтому нам пришлось отправить вас на десантных подах. Расходы за высадку лягут на вас."
	trait_to_give = STATION_TRAIT_RANDOM_ARRIVALS
	blacklist = list(/datum/station_trait/late_arrivals, /datum/station_trait/hangover)

/datum/station_trait/hangover
	name = "Похмелье"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	show_in_report = TRUE
	report_message = "Мммм... Обязательный для посещения корпоратив по случаю... мххггг... Возможно мы переборщили с алкоголем..."
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
	report_message = "Из-за перегрузки энергосистем, произошло повреждение станционного освещения. Будьте осторожны и смотрите под ноги."

/datum/station_trait/blackout/on_round_start()
	. = ..()
	for(var/obj/machinery/power/apc/apc in GLOB.apcs)
		if(is_station_level(apc.z) && prob(60))
			INVOKE_ASYNC(apc, TYPE_PROC_REF(/obj/machinery/power/apc, overload_lighting))

/datum/station_trait/empty_maint
	name = "Убранные технические туннели"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Перед началом смены мы убрали практически весь мусор, что находился в технических туннелях."
	//blacklist = list(/datum/station_trait/filled_maint)
	trait_to_give = STATION_TRAIT_EMPTY_MAINT
	// This station trait is checked when loot drops initialize, so it's too late
	can_revert = FALSE

/// Cap is set to 20. As HoP can close only one job per minute, it take some time to fix everythimg, if it's fixable, of course
/datum/station_trait/overflow_job_bureaucracy
	name = "Серьёзная бюрократическая ошибка"
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
	return "<i>[name]</i> — Из-за ошибки с нашей стороны на одну из должностей станции было открыто слишком много слотов. Судя по всему, это [chosen_job_name]. Постарайтесь исправить ситуацию, если это возможно."

/datum/station_trait/overflow_job_bureaucracy/proc/set_overflow_job_override(datum/source)
	SIGNAL_HANDLER
	var/datum/job/picked_job = pick(SSjobs.get_valid_overflow_jobs())
	chosen_job_name = LOWER_TEXT(picked_job.title) // like Chief Engineers vs like chief engineers
	SSjobs.set_overflow_role(picked_job.type)

/datum/station_trait/slow_shuttle
	name = "Медленный шаттл поставок"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Из-за отклонения \"АКН Трурль\" от маршрута, шаттлу поставок потребуется гораздо больше времени, чтобы добраться до станции. Шаттл эвакуации это не затронет."
	//blacklist = list(/datum/station_trait/quick_shuttle)

/datum/station_trait/slow_shuttle/on_round_start()
	. = ..()
	SSshuttle.supply.callTime *= 1.5

/datum/station_trait/bot_languages
	name = "Сбой языковой матрицы роботов"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 4
	cost = STATION_TRAIT_COST_LOW
	show_in_report = TRUE
	report_message = "Из-за ионного шторма, произошедшего на станции, у всех станционных ботов сгорела языковая матрица. Ожидайте сообщения от ботов на странных языках."
	trait_to_give = STATION_TRAIT_BOTS_GLITCHED

// Abstract station trait used for traits that modify a random event in some way (their weight or max occurrences).
// I fucking hate event container system
/datum/station_trait/random_event_weight_modifier
	name = "Модификатор рандомных ивентов"
	report_message = "Один из ивентов был модифицирован. Интересно, как это скажется на игре??"
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
	report_message = "Станция была расположена в эпицентре ионизированной туманности. Ожидайте повышенную вероятность ионных штормов, влияющих на работу ИИ и киборгов."
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 3
	event_names = ("Ионный тайфун")
	event_severity = /datum/event_container/moderate
	weight_multiplier = 5 //500 instead of 100
	//blacklist = list(/datum/station_trait/unique_ai)

/datum/station_trait/random_event_weight_modifier/rad_storms
	name = "Радиационная буря"
	report_message = "Станция была расположена в эпицентре радиоактивной туманности. Ожидайте повышенную вероятность радиационных штормов."
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	event_names = list("Радиационный шторм")
	event_severity = /datum/event_container/moderate
	weight_multiplier = 4 //100 instead of 25
	disable_is_one_shot = TRUE

/datum/station_trait/random_event_weight_modifier/meteor_showers
	name = "Метеорный вал"
	report_message = "Станция была расположена на астероидном кольце. Ожидайте повышенную вероятность попадания по станции метеоритов."
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	event_names = list("Метеорный дождь")
	event_severity = /datum/event_container/moderate
	weight_multiplier = 5 //50 instead of 10. Probably much more, idk event containers SUCK

/datum/station_trait/random_event_weight_modifier/anomaly_storms
	name = "Аномальное созвездие"
	report_message = "Пространство вокруг станции зафиксировало множество неизвестных сигналов и аномалий. Будьте осторожны."
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	event_names = list("Аномалия")
	event_severity = /datum/event_container/moderate
	weight_multiplier = 3 ///1500 instead of 500. Oh god

/datum/station_trait/random_event_weight_modifier/more_antags
	name = "Вражеская активность"
	report_message = "Внимание! В космическом пространстве вокруг станции замечена повышенная активность маломестных шаттлов без активного транспондера. Ожидайте незванных гостей."
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	event_names = list("Космический ниндзя", "Ядерный оперативник", "Дрейфующий Контрактник")
	event_severity = /datum/event_container/moderate
	weight_multiplier = 3
	disable_is_one_shot = TRUE

/datum/station_trait/random_event_weight_modifier/more_majors
	name = "Повышенная опасность биологических угроз"
	report_message = "Внимание! Несколько космических станций в вашем секторе было уничтожено в результате вспышек биоугроз. Будьте предельно осторожны."
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	event_names = list("Блоб", "Заражение ксеноморфами", "Пауки Ужаса", "Космический Дракон")
	event_severity = /datum/event_container/major
	weight_multiplier = 3
