/**
 * # View Sensor
 *
 * Returns all movable objects in view.
 */

/obj/item/circuit_component/view_sensor
	display_name = "Датчик наблюдения"
	desc = "Выводит список всех подвижных объектов в поле зрения. \
			Требуется оболочка. Максимальная дальность — 5 тайлов."
	category = "Sensor"

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	energy_usage_per_input = 100 //Normal components have 10

	///Allows setting the range of the view sensor
	var/datum/port/input/range

	/// The result from the output
	var/datum/port/output/result
	var/datum/port/output/cooldown

	var/see_invisible = SEE_INVISIBLE_LIVING
	var/view_cooldown = 1 SECONDS
	var/maximum_range = 5 //Variablised incase admins want to increase it.

/obj/item/circuit_component/view_sensor/populate_ports()
	range = add_input_port("Дальность", PORT_TYPE_NUMBER, default = maximum_range)
	result = add_output_port("Результат", PORT_TYPE_LIST(PORT_TYPE_ATOM))
	cooldown = add_output_port("Поиск", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/view_sensor/get_ui_notices()
	. = ..()
	. += create_ui_notice("Перезарядка сканирования: [DisplayTimeText(view_cooldown)]", "orange", "stopwatch")

/obj/item/circuit_component/view_sensor/input_received(datum/port/input/port)
	if(!parent.shell)
		return

	if(TIMER_COOLDOWN_RUNNING(parent.shell, COOLDOWN_CIRCUIT_VIEW_SENSOR))
		result.set_output(null)
		cooldown.set_output(COMPONENT_SIGNAL)
		return

	if(!parent || !parent.shell)
		result.set_output(null)
		return

	if(!isturf(parent.shell.loc))
		if(isliving(parent.shell.loc))
			var/mob/living/owner = parent.shell.loc
			if(parent.shell != owner.get_active_hand() && parent.shell != owner.get_inactive_hand())
				result.set_output(null)
				return
		else
			result.set_output(null)
			return

	var/range_value = clamp(range.value, 0, maximum_range)
	var/object_list = list()

	for(var/atom/movable/target in view(range_value, get_turf(parent.shell)))
		if(target.mouse_opacity == MOUSE_OPACITY_TRANSPARENT)
			continue
		if(target.invisibility > see_invisible)
			continue
		if(target.IsObscured())
			continue
		object_list += target

	result.set_output(object_list)
	TIMER_COOLDOWN_START(parent.shell, COOLDOWN_CIRCUIT_VIEW_SENSOR, view_cooldown)
