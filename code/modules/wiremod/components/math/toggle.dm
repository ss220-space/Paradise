/**
 * # Toggle Component
 *
 * Does a toggle between true and false on trigger
 */
/obj/item/circuit_component/compare/toggle
	display_name = "Переключить"
	desc = "Компонент, который переключается между включением и выключением при срабатывании. \
			Все входные порты, кроме порта переключения, активируют компонент."
	category = "Math"

	/// A signal to reset the toggle back to 0
	var/datum/port/input/toggle_set
	/// A signal to toggle and return the current state
	var/datum/port/input/toggle_and_compare

	var/toggle_state = FALSE

/obj/item/circuit_component/compare/toggle/populate_custom_ports()
	toggle_set = add_input_port("Целевое состояние", PORT_TYPE_NUMBER)
	toggle_and_compare = add_input_port("Переключить и сравнить", PORT_TYPE_SIGNAL)
	toggle_state = FALSE

/obj/item/circuit_component/compare/toggle/input_received(datum/port/input/port)
	if(port == toggle_set)
		toggle_state = !!port.value
		return
	if(COMPONENT_TRIGGERED_BY(toggle_and_compare, port))
		toggle_state = !toggle_state
		if(toggle_state)
			true.set_output(COMPONENT_SIGNAL)
		else
			false.set_output(COMPONENT_SIGNAL)
	return ..()

/obj/item/circuit_component/compare/toggle/do_comparisons()
	return toggle_state
