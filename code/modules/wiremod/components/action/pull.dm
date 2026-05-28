/**
 * # Pull Component
 *
 * Tells the shell to start pulling on a designated atom. Only works on movable shells.
 */
/obj/item/circuit_component/pull
	display_name = "Захват"
	desc = "Компонент, который может заставить оболочку тащить объект. \
			Работает только для оболочек дронов."
	category = "Action"

	/// Frequency input
	var/datum/port/input/target
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/pull/Destroy()
	target = null
	. = ..()

/obj/item/circuit_component/pull/populate_ports()
	target = add_input_port("Цель", PORT_TYPE_ATOM)

/obj/item/circuit_component/pull/input_received(datum/port/input/port)
	var/atom/target_atom = target.value
	if(!target_atom)
		return

	var/mob/shell = parent.shell
	if(!istype(shell) || get_dist(shell, target_atom) > 1 || shell.z != target_atom.z)
		return

	INVOKE_ASYNC(shell, TYPE_PROC_REF(/atom/movable, start_pulling), target_atom)
