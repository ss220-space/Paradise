#define COMP_BAR_OVERLAY_VERTICAL "Вертикальный"
#define COMP_BAR_OVERLAY_HORIZONTAL "Горизонтальный"

/**
 * # Bar Overlay Component
 *
 * Basically an advanced verion of object overlay component that shows a horizontal/vertical bar.
 * Requires a BCI shell.
 */

/obj/item/circuit_component/object_overlay/bar
	display_name = "Отображение графического столбца"
	desc = "Требуется ИМК-оболочка. \
			Компонент, отображающий графический столбец поверх объекта со значениями от 0 до 100."

	var/datum/port/input/bar_number

/obj/item/circuit_component/object_overlay/bar/populate_ports()
	. = ..()
	bar_number = add_input_port("Число", PORT_TYPE_NUMBER)

/obj/item/circuit_component/object_overlay/bar/populate_options()
	var/static/component_options_bar = list(
		COMP_BAR_OVERLAY_VERTICAL = "barvert",
		COMP_BAR_OVERLAY_HORIZONTAL = "barhoriz"
	)
	object_overlay_options = add_option_port("Настройка столбца", component_options_bar)
	options_map = component_options_bar

/obj/item/circuit_component/object_overlay/bar/get_cool_overlay(atom/target_atom)
	var/current_option = object_overlay_options.value
	var/number_clear = clamp(bar_number.value, 0, 100)

	if(current_option == COMP_BAR_OVERLAY_HORIZONTAL)
		number_clear = round(number_clear / 6.25) * 6.25
	else if(current_option == COMP_BAR_OVERLAY_VERTICAL)
		number_clear = round(number_clear / 10) * 10

	return image(icon = 'icons/hud/screen_bci.dmi', loc = target_atom, icon_state = "[options_map[current_option]][number_clear]", layer = RIPPLE_LAYER)

#undef COMP_BAR_OVERLAY_VERTICAL
#undef COMP_BAR_OVERLAY_HORIZONTAL
