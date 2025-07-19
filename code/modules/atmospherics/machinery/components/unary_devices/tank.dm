
#define AIR_CONTENTS	(25 * ONE_ATMOSPHERE) * (air_contents.volume) / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
/obj/machinery/atmospherics/components/unary/tank
	icon = 'icons/obj/atmospherics/tank.dmi'
	icon_state = "air_map"
	layer = GAS_PIPE_VISIBLE_LAYER
	name = "pressure tank"
	desc = "A large vessel containing pressurized gas."

	max_integrity = 800

	var/volume = 10000 //in liters, 1 meters by 1 meters by 2 meters ~tweaked it a little to simulate a pressure tank without needing to recode them yet

	density = TRUE
	var/gas_type = 0

/obj/machinery/atmospherics/components/unary/tank/New()
	..()
	var/datum/gas_mixture/air_contents = AIR1
	air_contents.volume = volume
	air_contents.temperature = T20C
	if(gas_type)
		air_contents.assert_gas(gas_type)
		air_contents.gases[gas_type][MOLES] = AIR_CONTENTS
		name = "[name] ([air_contents.gases[gas_type][GAS_NAME]])"

/obj/machinery/atmospherics/components/unary/tank/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, NODE1, dir)

/obj/machinery/atmospherics/components/unary/tank/return_analyzable_air()
	return AIR1

/obj/machinery/atmospherics/components/unary/tank/air
	name = "Pressure Tank (Air)"
	icon_state = "air_map"

/obj/machinery/atmospherics/components/unary/tank/air/New()
	..()
	icon_state = "air"
	var/datum/gas_mixture/air_contents = AIR1
	air_contents.assert_gases(GAS_O2, GAS_N2)
	air_contents.gases[GAS_O2][MOLES] = AIR_CONTENTS * 0.2
	air_contents.gases[GAS_N2][MOLES] = AIR_CONTENTS * 0.8

/obj/machinery/atmospherics/components/unary/tank/oxygen
	icon_state = "o2_map"
	gas_type = GAS_O2

/obj/machinery/atmospherics/components/unary/tank/oxygen/New()
	..()
	icon_state = "o2"

/obj/machinery/atmospherics/components/unary/tank/nitrogen
	icon_state = "n2_map"
	gas_type = GAS_N2

/obj/machinery/atmospherics/components/unary/tank/nitrogen/New()
	..()
	icon_state = "n2"

/obj/machinery/atmospherics/components/unary/tank/carbon_dioxide
	icon_state = "co2_map"
	gas_type = GAS_CO2

/obj/machinery/atmospherics/components/unary/tank/carbon_dioxide/New()
	..()
	icon_state = "co2"

/obj/machinery/atmospherics/components/unary/tank/toxins
	icon_state = "toxins_map"
	gas_type = GAS_PL

/obj/machinery/atmospherics/components/unary/tank/toxins/New()
	..()
	icon_state = "toxins"

/obj/machinery/atmospherics/components/unary/tank/nitrous_oxide
	icon_state = "n2o_map"
	gas_type = GAS_N2O

/obj/machinery/atmospherics/components/unary/tank/nitrous_oxide/New()
	..()
	icon_state = "n2o"

/obj/machinery/atmospherics/components/unary/tank/oxygen_agent_b
	name = "Unidentified Gas Tank"
	desc = "A large vessel containing an unknown pressurized gas."
	icon_state = "agent_b_map"
	gas_type = GAS_AGENT_B

/obj/machinery/atmospherics/components/unary/tank/oxygen_agent_b/New()
	..()
	icon_state = "agent_b"

/obj/machinery/atmospherics/components/unary/tank/air/ninja
	name = "Pressure Tank (Air)"
	desc = "Despite looking like CO2 vessel this one definetly contains breathable air. It's even written on it. By something sharp..."
	icon_state = "co2_map"

/obj/machinery/atmospherics/components/unary/tank/air/ninja/New()
	..()
	icon_state = "co2"
