#define COMP_TEXT_LOWER "Нижний"
#define COMP_TEXT_UPPER "Верхний"

/**
 * # Text Component
 *
 * Either makes the text upper case or lower case.
 */
/obj/item/circuit_component/textcase
	display_name = "Регистр"
	desc = "Компонент, который преобразует входные данные в заглавные или строчные буквы."
	category = "String"

	var/datum/port/input/option/textcase_options

	/// The input port
	var/datum/port/input/input_port

	/// The result of the text operation
	var/datum/port/output/output

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/textcase/Destroy()
	textcase_options = null
	input_port = null
	output = null
	. = ..()

/obj/item/circuit_component/textcase/populate_options()
	var/static/component_options = list(
		COMP_TEXT_LOWER,
		COMP_TEXT_UPPER,
	)
	textcase_options = add_option_port("Параметр", component_options)

/obj/item/circuit_component/textcase/populate_ports()
	input_port = add_input_port("Ввод", PORT_TYPE_STRING)
	output = add_output_port("Результат", PORT_TYPE_STRING)

/obj/item/circuit_component/textcase/input_received(datum/port/input/port)

	var/value = input_port.value
	if(isnull(value))
		return

	var/result
	switch(textcase_options.value)
		if(COMP_TEXT_LOWER)
			result = LOWER_TEXT(value)
		if(COMP_TEXT_UPPER)
			result = uppertext(value)

	output.set_output(result)

#undef COMP_TEXT_LOWER
#undef COMP_TEXT_UPPER
