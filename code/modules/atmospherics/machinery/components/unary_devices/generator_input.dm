/obj/machinery/atmospherics/components/unary/generator_input
	icon_state = "heat_exchanger_intact"
	density = TRUE

	name = "generator input"
	desc = "Placeholder"

	var/update_cycle

/obj/machinery/atmospherics/components/unary/generator_input/update_icon_state()
	..()

	if(NODE1)
		icon_state = "heat_exchanger_intact"
	else
		icon_state = "heat_exchanger_exposed"

/obj/machinery/atmospherics/components/unary/generator_input/proc/return_exchange_air()
	return AIR1
