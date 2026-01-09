/**
 * # Pressure Sensor
 *
 * Returns the pressure of the tile
 */
/obj/item/circuit_component/pressuresensor
	display_name = "Датчик давления"
	desc = "Считывает значение давления окружающей среды. \
			Возвращает значение в Паскалях."
	category = "Sensor"

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The result from the output
	var/datum/port/output/result

/obj/item/circuit_component/pressuresensor/populate_ports()
	result = add_output_port("Результат", PORT_TYPE_NUMBER)

/obj/item/circuit_component/pressuresensor/input_received(datum/port/input/port)
	//Get current turf
	var/turf/location = get_location()
	if(!location)
		result.set_output(null)
		return
	//Get environment info
	var/datum/gas_mixture/environment = location.get_readonly_air()
	var/total_moles = environment.total_moles()
	var/pressure = environment.return_pressure()
	if(total_moles)
		//If there's atmos, return pressure
		result.set_output(round(pressure,1))
	else
		result.set_output(0)
