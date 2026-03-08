/**
 * # Pathfinding component
 *
 * Calcualtes a path, returns a list of entities. Each entity is the next step in the path. Can be used with the direction component to move.
 */
/obj/item/circuit_component/pathfind
	display_name = "Следопыт"
	desc = "При срабатывании делает шаг к местоположению цели. \
			Входной порт для удостоверения личности предназначен для учёта доступа к идентификатору при определении маршрута, \
			но не предоставляет оболочке фактический доступ."
	category = "Action"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/datum/port/input/input_X
	var/datum/port/input/input_Y
	var/datum/port/input/id_card

	var/datum/port/output/output
	var/datum/port/output/finished
	var/datum/port/output/failed
	var/datum/port/output/reason_failed

	var/list/path
	var/turf/old_dest
	var/turf/next_turf

	// Cooldown to limit how frequently we can path to the same location.
	var/same_path_cooldown = 5 SECONDS
	var/different_path_cooldown = 5 SECONDS

	var/max_range = 60

/obj/item/circuit_component/pathfind/Destroy()
	input_X = null
	input_Y = null
	id_card = null
	output = null
	finished = null
	failed = null
	reason_failed = null
	LAZYCLEARLIST(path)
	path = null
	old_dest = null
	next_turf = null
	. = ..()

/obj/item/circuit_component/pathfind/get_ui_notices()
	. = ..()
	// Not necessary to show the same path cooldown, since it doesn't change much for the player
	. += create_ui_notice("Перезарядка поиска пути: [DisplayTimeText(different_path_cooldown)]", "orange", "stopwatch")
	. += create_ui_notice("Максимальная дальность: [max_range] тайл[DECL_CREDIT(max_range)]", "orange", "info")

/obj/item/circuit_component/pathfind/populate_ports()
	input_X = add_input_port("X", PORT_TYPE_NUMBER, trigger = null)
	input_Y = add_input_port("Y", PORT_TYPE_NUMBER, trigger = null)
	id_card = add_input_port("ID-карта", PORT_TYPE_ATOM, trigger = null)

	output = add_output_port("Следующий шаг", PORT_TYPE_ATOM)
	finished = add_output_port("Прибыл", PORT_TYPE_SIGNAL)
	failed = add_output_port("Провал", PORT_TYPE_SIGNAL)
	reason_failed = add_output_port("Причина провала", PORT_TYPE_STRING)

/obj/item/circuit_component/pathfind/input_received(datum/port/input/port)
	INVOKE_ASYNC(src, PROC_REF(perform_pathfinding), port)

/obj/item/circuit_component/pathfind/proc/perform_pathfinding(datum/port/input/port)
	var/list/coordinate = get_target_coordinate()
	if(!LAZYLEN(coordinate))
		return

	var/target_X = LAZYACCESS(coordinate, "x")
	var/target_Y = LAZYACCESS(coordinate, "y")

	var/list/access = get_access_list()

	// Get both the current turf and the destination's turf
	var/turf/current_turf = get_location()
	var/turf/destination = locate(target_X, target_Y, current_turf?.z)

	// We're already here! No need to do anything.
	if(current_turf == destination)
		finished.set_output(COMPONENT_SIGNAL)
		old_dest = null
		TIMER_COOLDOWN_END(parent, COOLDOWN_CIRCUIT_PATHFIND_SAME)
		next_turf = null
		return

	if(try_use_cache_path(current_turf, destination))
		return

	calculate_new_path(destination, access)

/obj/item/circuit_component/pathfind/proc/get_target_coordinate()
	var/target_X = input_X.value
	if(isnull(target_X))
		return

	var/target_Y = input_Y.value
	if(isnull(target_Y))
		return

	return list("x" = target_X, "y" = target_Y)

/obj/item/circuit_component/pathfind/proc/get_access_list()
	var/list/access = list()
	if(is_id_card(id_card.value))
		var/obj/item/card/id/id = id_card.value
		access = id.GetAccess()
		return access

	if(!id_card.value)
		return

	failed.set_output(COMPONENT_SIGNAL)
	reason_failed.set_output("Отмеченный объект не имеет идентификатора! Вместо этого используется отсутствие идентификатора.")

/obj/item/circuit_component/pathfind/proc/send_next_step(list/path)
	if(!LAZYLEN(path))
		return

	next_turf = get_turf(path[1])
	output.set_output(next_turf)

/obj/item/circuit_component/pathfind/proc/try_use_cache_path(turf/current_turf, turf/destination)
	// If we're going to the same place and the cooldown hasn't subsided, we're probably on the same path as before
	if(destination != old_dest || TIMER_COOLDOWN_FINISHED(parent, COOLDOWN_CIRCUIT_PATHFIND_SAME))
		return FALSE

	// Check if the current turf is the same as the current turf we're supposed to be in. If so, then we set the next step as the next turf on the list
	if(current_turf != next_turf)
		return FALSE

	popleft(path)
	send_next_step(path)

	// Restart the cooldown since we don't need a new path ( TIMER_COOLDOWN_START might restart the timer by itself and i dont need to call TIMER_COOLDOWN_END, but better safe than sorry )
	TIMER_COOLDOWN_END(parent, COOLDOWN_CIRCUIT_PATHFIND_SAME)
	TIMER_COOLDOWN_START(parent, COOLDOWN_CIRCUIT_PATHFIND_SAME, same_path_cooldown)
	return TRUE

/obj/item/circuit_component/pathfind/proc/calculate_new_path(turf/destination, access)
	// Either we're not going to the same place or the cooldown is over. Either way, we need a new path
	if(destination != old_dest && TIMER_COOLDOWN_RUNNING(parent, COOLDOWN_CIRCUIT_PATHFIND_DIF))
		failed.set_output(COMPONENT_SIGNAL)
		reason_failed.set_output("Все еще перезаряжается!")
		return

	TIMER_COOLDOWN_END(parent, COOLDOWN_CIRCUIT_PATHFIND_SAME)

	old_dest = destination
	path = get_path_to(src, destination, max_range, access = access)

	if(!length(path) || !path)// Check if we can even path there
		next_turf = null
		failed.set_output(COMPONENT_SIGNAL)
		reason_failed.set_output("Нет пути!")
		return

	send_next_step(path)
	TIMER_COOLDOWN_START(parent, COOLDOWN_CIRCUIT_PATHFIND_DIF, different_path_cooldown)
	TIMER_COOLDOWN_START(parent, COOLDOWN_CIRCUIT_PATHFIND_SAME, same_path_cooldown)

