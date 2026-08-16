// MARK: Gas Effects Registry

GLOBAL_LIST_INIT(reactor_coolant_effects, build_reactor_gas_effects(/datum/reactor_gas_effect/coolant))
GLOBAL_LIST_INIT(reactor_moderator_effects, build_reactor_gas_effects(/datum/reactor_gas_effect/moderator))

/proc/build_reactor_gas_effects(base_type)
	. = list()
	for(var/datum/reactor_gas_effect/effect as anything in valid_subtypesof(base_type))
		var/datum/reactor_gas_effect/instance = new effect()
		.[instance.gas_id] = instance

// MARK: Reactor Gas Effects Datum System

/datum/reactor_gas_effect
	abstract_type = /datum/reactor_gas_effect
	/// Gas id
	var/gas_id
	/// Effect description for UI
	var/desc = ""

/datum/reactor_gas_effect/proc/apply(obj/machinery/atmospherics/fission_reactor/reactor, mole_fraction, mole_multiplier)
	return

/datum/reactor_gas_effect/proc/extra_effects(obj/machinery/atmospherics/fission_reactor/reactor, datum/gas_mixture/gas_mix, mole_fraction)
	return

/datum/reactor_gas_effect/coolant
	abstract_type = /datum/reactor_gas_effect/coolant
	var/overheat_bonus = 0
	var/event_chance_mod = 0
	var/reactivity_bonus = 0

/datum/reactor_gas_effect/coolant/apply(obj/machinery/atmospherics/fission_reactor/reactor, mole_fraction, mole_multiplier, moles_count)
	reactor.gas_overheat_bonus += overheat_bonus * mole_fraction * mole_multiplier
	reactor.gas_event_modifier += event_chance_mod * mole_fraction
	reactor.gas_reactivity_bonus += reactivity_bonus * mole_fraction * mole_multiplier

/datum/reactor_gas_effect/coolant/nitrogen
	gas_id = TLV_N2
	overheat_bonus = 600
	event_chance_mod = -20
	desc = "Повышает порог перегрева и снижает шанс аварий."

/datum/reactor_gas_effect/coolant/nitrous_oxide
	gas_id = TLV_N2O
	overheat_bonus = 300
	event_chance_mod = -20
	desc = "Повышает порог перегрева и снижает шанс аварий."

/datum/reactor_gas_effect/coolant/oxygen
	gas_id = TLV_O2
	reactivity_bonus = 0.8
	event_chance_mod = 50
	desc = "Увеличивает реактивность ценой повышенного шанса аварий."

/datum/reactor_gas_effect/coolant/plasma
	gas_id = TLV_PL
	reactivity_bonus = 0.2
	overheat_bonus = 200
	desc = "Повышает реактивность и порог перегрева."

/datum/reactor_gas_effect/coolant/carbon_dioxide
	gas_id = TLV_CO2
	event_chance_mod = -60
	desc = "Значительно снижает шанс аварийных событий."

/datum/reactor_gas_effect/moderator
	abstract_type = /datum/reactor_gas_effect/moderator
	/// Control rod efficiency modifier
	var/control_mod = 0
	/// Radiation multiplier
	var/radiation_mod = 0
	/// Heat transfer (permeability) modifier
	var/permeability_mod = 0
	/// Fuel rod depletion modifier
	var/depletion_mod = 0
	var/power_per_mole = 0
	var/heat_per_mole = 0
	/// Power multiplier (catalyst)
	var/power_mod = 0
	var/integrity_restore = 0

/datum/reactor_gas_effect/moderator/apply(obj/machinery/atmospherics/fission_reactor/reactor, mole_fraction, mole_multiplier, moles_count)
	reactor.gas_control_mod += control_mod * mole_fraction
	reactor.gas_radiation_mod += radiation_mod * mole_fraction
	reactor.gas_permeability_mod += permeability_mod * mole_fraction
	reactor.gas_depletion_mod += depletion_mod * mole_fraction
	reactor.gas_fuel_heat += heat_per_mole * moles_count

	if(power_per_mole > 0)
		reactor.gas_fuel_power += moles_count * power_per_mole
		reactor.gas_fuel_moles += moles_count
		reactor.gas_is_fueled = TRUE

	if(power_mod * mole_fraction > reactor.gas_power_mod)
		reactor.gas_power_mod = power_mod * mole_fraction

	reactor.adjust_damage(-integrity_restore * mole_fraction)

/datum/reactor_gas_effect/moderator/nitrogen
	gas_id = TLV_N2
	control_mod = 4
	radiation_mod = 0.04
	desc = "Улучшает контроль над реакцией, но повышает радиационный фон."

/datum/reactor_gas_effect/moderator/pluoxium
	gas_id = TLV_PLUOXIUM
	control_mod = 6
	desc = "Значительно улучшает контроль без повышения радиации."

/datum/reactor_gas_effect/moderator/carbon_dioxide
	gas_id = TLV_CO2
	control_mod = 8
	radiation_mod = 0.08
	desc = "Максимальный контроль ценой экстремальной радиации."

/datum/reactor_gas_effect/moderator/bz
	gas_id = TLV_BZ
	permeability_mod = 0.2
	desc = "Улучшает поглощение тепла от стержней."

/datum/reactor_gas_effect/moderator/water_vapor
	gas_id = TLV_H2O
	permeability_mod = 0.4
	desc = "Значительно улучшает поглощение тепла от стержней."

/datum/reactor_gas_effect/moderator/hypernoblium
	gas_id = TLV_HYPERNOBLIUM
	permeability_mod = 2
	desc = "Экстремально улучшает поглощение тепла от стержней."

/datum/reactor_gas_effect/moderator/nitryl
	gas_id = TLV_N2O
	depletion_mod = 0.67
	desc = "Ускоряет износ топливных стержней."

/datum/reactor_gas_effect/moderator/healium
	gas_id = TLV_HEALIUM
	integrity_restore = 1
	desc = "Восстанавливает целостность реактора."

/datum/reactor_gas_effect/moderator/nitryl/extra_effects(obj/machinery/atmospherics/fission_reactor/reactor, datum/gas_mixture/gas_mix, mole_fraction)
	if(prob(5))
		playsound(reactor, SFX_SM_CALM, 100, TRUE)

/datum/reactor_gas_effect/moderator/plasma
	gas_id = TLV_PL
	power_per_mole = 10 WATTS
	heat_per_mole = 5
	desc = "Горит в активной зоне как топливо."

/datum/reactor_gas_effect/moderator/tritium
	gas_id = TLV_TRITIUM
	power_per_mole = 100 WATTS
	heat_per_mole = 50
	radiation_mod = 0.2
	desc = "Сверхэффективное топливо. Повышает радиационный фон."

/datum/reactor_gas_effect/moderator/oxygen
	gas_id = TLV_O2
	power_mod = 10
	desc = "Катализатор для газового топлива, умножает выход энергии."
