/datum/engi_event/supermatter_event
	name = "Unknown X-K (Report this to coders)"
	var/obj/machinery/atmospherics/supermatter_crystal/supermatter
	var/turf/supermatter_turf

/datum/engi_event/supermatter_event/New(obj/machinery/atmospherics/supermatter_crystal/_supermatter)
	. = ..()
	supermatter = _supermatter
	supermatter_turf = get_turf(supermatter)
	if(!supermatter)
		stack_trace("a /datum/engi_event/supermatter_event was called without an involved supermatter.")
		return
	if(!istype(supermatter))
		stack_trace("a /datum/engi_event/supermatter_event was called with (name: [supermatter], type: [supermatter.type]) instead of a supermatter!")
		return

/datum/engi_event/supermatter_event/start_event()
	supermatter.event_active = src
	supermatter.investigate_log("event [src] has been triggered", INVESTIGATE_ENGINE)
	. = ..()

/datum/engi_event/supermatter_event/on_end()
	sm_radio_say(span_bold("Аномальная кристаллическая активность прекратилась."))
	supermatter.heat_penalty_threshold = SUPERMATTER_HEAT_PENALTY_THRESHOLD
	supermatter.gas_multiplier = 1
	supermatter.power_additive = 0
	supermatter.heat_multiplier = 1
	supermatter.event_active = null

/datum/engi_event/supermatter_event/proc/sm_radio_say(announcement_text)
	if(!announcement_text)
		return
	radio_announce(announcement_text, supermatter.name, ENG_FREQ, supermatter)

/datum/engi_event/supermatter_event/proc/general_radio_say(announcement_text)
	if(!announcement_text)
		return
	radio_announce(announcement_text, supermatter.name, PUB_FREQ, supermatter)

// Below this are procs used for the SM events, in order of severity
// MARK: D class events
/datum/engi_event/supermatter_event/delta_tier
	threat_level = SM_EVENT_THREAT_D
	duration = 10 SECONDS

/datum/engi_event/supermatter_event/delta_tier/alert_engi()
	sm_radio_say("Обнаружена аномальная кристаллическая активность! Класс активности: [name].")

// sleeping gas
/datum/engi_event/supermatter_event/delta_tier/sleeping_gas
	name = "D-1"

/datum/engi_event/supermatter_event/delta_tier/sleeping_gas/on_start()
	var/datum/gas_mixture/air_mixture = new()
	air_mixture.set_sleeping_agent(2000)
	supermatter_turf.blind_release_air(air_mixture)

// nitrogen
/datum/engi_event/supermatter_event/delta_tier/nitrogen
	name = "D-2"

/datum/engi_event/supermatter_event/delta_tier/nitrogen/on_start()
	var/datum/gas_mixture/air_mixture = new()
	air_mixture.set_nitrogen(2000)
	supermatter_turf.blind_release_air(air_mixture)

// carbon dioxide
/datum/engi_event/supermatter_event/delta_tier/carbon_dioxide
	name = "D-3"

/datum/engi_event/supermatter_event/delta_tier/carbon_dioxide/on_start()
	var/datum/gas_mixture/air_mixture = new()
	air_mixture.set_carbon_dioxide(2000)
	supermatter_turf.blind_release_air(air_mixture)

// MARK: C class events
/datum/engi_event/supermatter_event/charlie_tier
	threat_level = SM_EVENT_THREAT_C
	duration = 15 SECONDS

/datum/engi_event/supermatter_event/charlie_tier/alert_engi()
	sm_radio_say("Обнаружена аномальная кристаллическая активность! Класс активности: [name]. Может потребоваться вмешательство обслуживающего персонала.")

// oxygen
/datum/engi_event/supermatter_event/charlie_tier/oxygen
	name = "C-1"

/datum/engi_event/supermatter_event/charlie_tier/oxygen/on_start()
	var/datum/gas_mixture/air_mixture = new()
	air_mixture.set_oxygen(2000)
	supermatter_turf.blind_release_air(air_mixture)

// plasma
/datum/engi_event/supermatter_event/charlie_tier/plasma
	name = "C-2"

/datum/engi_event/supermatter_event/charlie_tier/plasma/on_start()
	var/datum/gas_mixture/air_mixture = new()
	air_mixture.set_toxins(2000)
	supermatter_turf.blind_release_air(air_mixture)

// lowers the temp required for the SM to take damage.
/datum/engi_event/supermatter_event/charlie_tier/heat_penalty_threshold
	name = "C-3"
	duration = 5 MINUTES

/datum/engi_event/supermatter_event/charlie_tier/heat_penalty_threshold/on_start()
	supermatter.heat_penalty_threshold -= 173

// hydrogen
/datum/engi_event/supermatter_event/charlie_tier/hydrogen
	name = "C-4"

/datum/engi_event/supermatter_event/charlie_tier/hydrogen/on_start()
	var/datum/gas_mixture/air_mixture = new()
	air_mixture.set_hydrogen(2000)
	supermatter_turf.blind_release_air(air_mixture)

//water vapor
/datum/engi_event/supermatter_event/charlie_tier/water_vapor
	name = "C-5"

/datum/engi_event/supermatter_event/charlie_tier/water_vapor/on_start()
	var/datum/gas_mixture/air_mixture = new()
	air_mixture.set_water_vapor(2000)
	supermatter_turf.blind_release_air(air_mixture)

// MARK: B class events
/datum/engi_event/supermatter_event/bravo_tier
	threat_level = SM_EVENT_THREAT_B
	duration = 1 MINUTES

/datum/engi_event/supermatter_event/bravo_tier/alert_engi()
	sm_radio_say(span_bold("Обнаружена аномальная кристаллическая активность! Класс активности: [name]. Требуется вмешательство обслуживающего персонала!"))

// more gas
/datum/engi_event/supermatter_event/bravo_tier/gas_multiply
	name = "B-1"

/datum/engi_event/supermatter_event/bravo_tier/gas_multiply/on_start()
	supermatter.gas_multiplier = 3

/datum/engi_event/supermatter_event/bravo_tier/heat_multiplier
	name = "B-2"

/datum/engi_event/supermatter_event/bravo_tier/heat_multiplier/on_start()
	supermatter.heat_multiplier = 3

/datum/engi_event/supermatter_event/bravo_tier/power_additive
	name = "B-3"

/datum/engi_event/supermatter_event/bravo_tier/power_additive/on_start()
	supermatter.power += 3000
	duration = 10 SECONDS

// MARK: A class events
/datum/engi_event/supermatter_event/alpha_tier
	threat_level = SM_EVENT_THREAT_A
	duration = 10 SECONDS

/datum/engi_event/supermatter_event/alpha_tier/alert_engi()
	sm_radio_say(span_big("ВНИМАНИЕ! Обнаружена критическая аномальная кристаллическая активность! Класс активности: [name]. НЕОБХОДИМО НЕМЕДЛЕННОЕ ВМЕШАТЕЛЬСТВО ОБСЛУЖИВАЮЩЕГО ПЕРСОНАЛА!"))

/datum/engi_event/supermatter_event/alpha_tier/apc_short
	name = "A-1"

/datum/engi_event/supermatter_event/alpha_tier/apc_short/on_start()
	var/area/current_area = get_area(supermatter)
	var/obj/machinery/power/apc/area_apc = current_area.get_apc()
	area_apc.apc_short()

/datum/engi_event/supermatter_event/alpha_tier/air_siphon
	name = "A-2"

/datum/engi_event/supermatter_event/alpha_tier/air_siphon/on_start()
	var/area/current_area = get_area(supermatter)
	for(var/obj/machinery/alarm/air_alarm in current_area)
		air_alarm.mode = AALARM_MODE_OFF
		air_alarm.apply_mode()

/datum/engi_event/supermatter_event/alpha_tier/gas_multiplier
	name = "A-3"
	duration = 2 MINUTES

/datum/engi_event/supermatter_event/alpha_tier/gas_multiplier/on_start()
	supermatter.gas_multiplier = 4

// S-tier events are special. They are very dangerous, but give a 5 minute warning to the engis.
// MARK: S class events
/datum/engi_event/supermatter_event/sierra_tier
	threat_level = SM_EVENT_THREAT_S
	duration = 7 MINUTES // 2 MINUTES of s-tier anomaly

/datum/engi_event/supermatter_event/sierra_tier/alert_engi()
	general_radio_say(span_big("ВНИМАНИЕ! Ожидается аномальное состояние суперматерии через 5 минут!"))
	sm_radio_say(span_reallybig("ЭКСТРЕННОЕ ПРЕДУПРЕЖДЕНИЕ! 5 МИНУТ ДО ТОГО, КАК [supermatter] ПРОЯВИТ АНОМАЛЬНУЮ АКТИВНОСТЬ В КЛАССЕ [name]!"))

/datum/engi_event/supermatter_event/sierra_tier/on_start()
	addtimer(CALLBACK(src, PROC_REF(start_sierra_event)), 5 MINUTES)
	supermatter.has_run_sclass = TRUE

/datum/engi_event/supermatter_event/sierra_tier/proc/start_sierra_event()
	general_radio_say(span_big("ВНИМАНИЕ! ОБНАРУЖЕНО АНОМАЛЬНОЕ СОСТОЯНИЕ СВЕРХМАТЕРИИ!"))
	sm_radio_say(span_reallybig("ЭКСТРЕННОЕ ПРЕДУПРЕЖДЕНИЕ! В классе [name] наблюдается аномальное поведение!"))

//Arc-type
/datum/engi_event/supermatter_event/sierra_tier/arc
	name = "S-ARC"

/datum/engi_event/supermatter_event/sierra_tier/arc/start_sierra_event()
	..()
	supermatter.power_additive = 6000

// Laminate type
/datum/engi_event/supermatter_event/sierra_tier/laminate
	name = "S-LAMINATE REJECTION"

/datum/engi_event/supermatter_event/sierra_tier/laminate/start_sierra_event()
	..()
	supermatter.heat_multiplier = 25
	supermatter.gas_multiplier = 25
	empulse(supermatter, 3, 6, TRUE, "S-laminite event")
