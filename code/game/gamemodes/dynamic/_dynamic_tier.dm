/datum/dynamic_tier
	var/name = "Tier"
	var/config_tag
	var/tier = DYNAMIC_TIER_GREEN
	var/weight = 0
	var/min_pop = 0
	var/advisory_report
	var/list/ruleset_type_settings = list(
		DYNAMIC_ROUNDSTART = list(
			RULESET_LOW_END = 0,
			RULESET_HIGH_END = 0,
			RULESET_HALF_RANGE_POP = 25,
			RULESET_FULL_RANGE_POP = 50,
		),
		DYNAMIC_MIDROUND = list(
			RULESET_LOW_END = 0,
			RULESET_HIGH_END = 0,
			RULESET_HALF_RANGE_POP = 25,
			RULESET_FULL_RANGE_POP = 40,
			RULESET_TIME_THRESHOLD = 30 MINUTES,
			RULESET_COOLDOWN_LOW = 10 MINUTES,
			RULESET_COOLDOWN_HIGH = 20 MINUTES,
		),
		DYNAMIC_LATEJOIN = list(
			RULESET_LOW_END = 0,
			RULESET_HIGH_END = 0,
			RULESET_HALF_RANGE_POP = 25,
			RULESET_FULL_RANGE_POP = 40,
			RULESET_TIME_THRESHOLD = 5 MINUTES,
			RULESET_COOLDOWN_LOW = 10 MINUTES,
			RULESET_COOLDOWN_HIGH = 20 MINUTES,
		),
	)

/datum/dynamic_tier/proc/get_ruleset_count(category, population_size)
	var/list/settings = ruleset_type_settings[category]
	var/low_end = settings[RULESET_LOW_END]
	var/high_end = settings[RULESET_HIGH_END]
	if(population_size <= settings[RULESET_HALF_RANGE_POP])
		high_end = max(low_end, ceil(high_end * 0.25))
	else if(population_size <= settings[RULESET_FULL_RANGE_POP])
		high_end = max(low_end, ceil(high_end * 0.5))
	return rand(low_end, high_end)

/datum/dynamic_tier/proc/get_time_threshold(category)
	return ruleset_type_settings[category][RULESET_TIME_THRESHOLD]

/datum/dynamic_tier/proc/get_execution_cooldown(category)
	var/list/settings = ruleset_type_settings[category]
	return rand(settings[RULESET_COOLDOWN_LOW], settings[RULESET_COOLDOWN_HIGH])

/datum/dynamic_tier/greenshift
	name = "Greenshift"
	config_tag = "greenshift"
	weight = 2
	advisory_report = "Уровень угрозы: <b>Зелёная Звезда</b>. Разведка не обнаружила в вашем секторе никаких угроз. Хорошей смены."

/datum/dynamic_tier/low
	name = "Low Chaos"
	config_tag = "low chaos"
	tier = DYNAMIC_TIER_LOW
	weight = 8
	min_pop = 5
	advisory_report = "Уровень угрозы: <b>Синяя Звезда</b>. Активность враждебных сил в вашем секторе минимальна, однако мы не исключаем единичных инцидентов."
	ruleset_type_settings = list(
		DYNAMIC_ROUNDSTART = list(
			RULESET_LOW_END = 1,
			RULESET_HIGH_END = 1,
			RULESET_HALF_RANGE_POP = 25,
			RULESET_FULL_RANGE_POP = 40,
		),
		DYNAMIC_MIDROUND = list(
			RULESET_LOW_END = 0,
			RULESET_HIGH_END = 1,
			RULESET_HALF_RANGE_POP = 25,
			RULESET_FULL_RANGE_POP = 40,
			RULESET_TIME_THRESHOLD = 40 MINUTES,
			RULESET_COOLDOWN_LOW = 15 MINUTES,
			RULESET_COOLDOWN_HIGH = 25 MINUTES,
		),
		DYNAMIC_LATEJOIN = list(
			RULESET_LOW_END = 0,
			RULESET_HIGH_END = 1,
			RULESET_HALF_RANGE_POP = 25,
			RULESET_FULL_RANGE_POP = 40,
			RULESET_TIME_THRESHOLD = 10 MINUTES,
			RULESET_COOLDOWN_LOW = 15 MINUTES,
			RULESET_COOLDOWN_HIGH = 25 MINUTES,
		),
	)

/datum/dynamic_tier/lowmedium
	name = "Low-Medium Chaos"
	config_tag = "low-medium chaos"
	tier = DYNAMIC_TIER_LOWMEDIUM
	weight = 46
	min_pop = 10
	advisory_report = "Уровень угрозы: <b>Жёлтая Звезда</b>. Разведка отмечает в вашем секторе умеренную активность враждебных сил. Не теряйте бдительности."
	ruleset_type_settings = list(
		DYNAMIC_ROUNDSTART = list(
			RULESET_LOW_END = 1,
			RULESET_HIGH_END = 2,
			RULESET_HALF_RANGE_POP = 25,
			RULESET_FULL_RANGE_POP = 40,
		),
		DYNAMIC_MIDROUND = list(
			RULESET_LOW_END = 0,
			RULESET_HIGH_END = 2,
			RULESET_HALF_RANGE_POP = 25,
			RULESET_FULL_RANGE_POP = 40,
			RULESET_TIME_THRESHOLD = 30 MINUTES,
			RULESET_COOLDOWN_LOW = 10 MINUTES,
			RULESET_COOLDOWN_HIGH = 20 MINUTES,
		),
		DYNAMIC_LATEJOIN = list(
			RULESET_LOW_END = 1,
			RULESET_HIGH_END = 2,
			RULESET_HALF_RANGE_POP = 25,
			RULESET_FULL_RANGE_POP = 40,
			RULESET_TIME_THRESHOLD = 5 MINUTES,
			RULESET_COOLDOWN_LOW = 10 MINUTES,
			RULESET_COOLDOWN_HIGH = 20 MINUTES,
		),
	)

/datum/dynamic_tier/mediumhigh
	name = "Medium-High Chaos"
	config_tag = "medium-high chaos"
	tier = DYNAMIC_TIER_MEDIUMHIGH
	weight = 34
	min_pop = 15
	advisory_report = "Уровень угрозы: <b>Красная Звезда</b>. В вашем секторе зафиксирована повышенная активность враждебных организаций. Будьте бдительны."
	ruleset_type_settings = list(
		DYNAMIC_ROUNDSTART = list(
			RULESET_LOW_END = 2,
			RULESET_HIGH_END = 3,
			RULESET_HALF_RANGE_POP = 25,
			RULESET_FULL_RANGE_POP = 40,
		),
		DYNAMIC_MIDROUND = list(
			RULESET_LOW_END = 1,
			RULESET_HIGH_END = 3,
			RULESET_HALF_RANGE_POP = 25,
			RULESET_FULL_RANGE_POP = 40,
			RULESET_TIME_THRESHOLD = 25 MINUTES,
			RULESET_COOLDOWN_LOW = 10 MINUTES,
			RULESET_COOLDOWN_HIGH = 15 MINUTES,
		),
		DYNAMIC_LATEJOIN = list(
			RULESET_LOW_END = 1,
			RULESET_HIGH_END = 3,
			RULESET_HALF_RANGE_POP = 25,
			RULESET_FULL_RANGE_POP = 40,
			RULESET_TIME_THRESHOLD = 5 MINUTES,
			RULESET_COOLDOWN_LOW = 10 MINUTES,
			RULESET_COOLDOWN_HIGH = 15 MINUTES,
		),
	)

/datum/dynamic_tier/high
	name = "High Chaos"
	config_tag = "high chaos"
	tier = DYNAMIC_TIER_HIGH
	weight = 10
	min_pop = 25
	advisory_report = "Уровень угрозы: <b>Чёрная Звезда</b>. Ваш сектор находится под пристальным вниманием враждебных сил. Ожидайте худшего."
	ruleset_type_settings = list(
		DYNAMIC_ROUNDSTART = list(
			RULESET_LOW_END = 2,
			RULESET_HIGH_END = 4,
			RULESET_HALF_RANGE_POP = 25,
			RULESET_FULL_RANGE_POP = 40,
		),
		DYNAMIC_MIDROUND = list(
			RULESET_LOW_END = 2,
			RULESET_HIGH_END = 4,
			RULESET_HALF_RANGE_POP = 25,
			RULESET_FULL_RANGE_POP = 40,
			RULESET_TIME_THRESHOLD = 20 MINUTES,
			RULESET_COOLDOWN_LOW = 5 MINUTES,
			RULESET_COOLDOWN_HIGH = 15 MINUTES,
		),
		DYNAMIC_LATEJOIN = list(
			RULESET_LOW_END = 2,
			RULESET_HIGH_END = 4,
			RULESET_HALF_RANGE_POP = 25,
			RULESET_FULL_RANGE_POP = 40,
			RULESET_TIME_THRESHOLD = 5 MINUTES,
			RULESET_COOLDOWN_LOW = 5 MINUTES,
			RULESET_COOLDOWN_HIGH = 15 MINUTES,
		),
	)
