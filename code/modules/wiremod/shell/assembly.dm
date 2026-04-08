/**
 * # Assembly Shell
 *
 * An assembly that triggers and can be triggered by wires.
 */
/obj/item/assembly/wiremod
	name = "circuit assembly"
	desc = "Небольшое электронное устройство, в котором может размещаться интегральная схема."
	gender = FEMALE
	icon_state = "wiremod"

/obj/item/assembly/wiremod/get_ru_names()
	return list(
		NOMINATIVE = "программируемая сборка",
		GENITIVE = "программируемой сборки",
		DATIVE = "программируемой сборке",
		ACCUSATIVE = "программируемую сборку",
		INSTRUMENTAL = "программируемой сборкой",
		PREPOSITIONAL = "программируемой сборке"
	)

/obj/item/assembly/wiremod/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_CLONE_IN_EXPERIMENTATOR, INNATE_TRAIT)
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/assembly_input(),
		new /obj/item/circuit_component/assembly_output(),
	), SHELL_CAPACITY_SMALL)

/obj/item/circuit_component/assembly_input
	display_name = "Ввод"
	desc = "Срабатывает при подаче импульса на подключённый порт."

	var/datum/port/output/signal

/obj/item/circuit_component/assembly_input/Destroy()
	signal = null
	. = ..()

/obj/item/circuit_component/assembly_input/populate_ports()
	signal = add_output_port("Вызвано", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/assembly_input/register_shell(atom/movable/shell)
	RegisterSignal(shell, list(COMSIG_ASSEMBLY_PULSED, COMSIG_ITEM_ATTACK_SELF), PROC_REF(on_pulsed))

/obj/item/circuit_component/assembly_input/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(COMSIG_ASSEMBLY_PULSED, COMSIG_ITEM_ATTACK_SELF))

/obj/item/circuit_component/assembly_input/proc/on_pulsed()
	SIGNAL_HANDLER
	signal.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/assembly_output
	display_name = "Вывод"
	desc = "При срабатывании подает импульс на подключённый порт."

	var/obj/item/assembly/attached_assembly

	var/datum/port/input/signal

/obj/item/circuit_component/assembly_output/Destroy()
	if(attached_assembly)
		unregister_shell(attached_assembly)
	signal = null
	. = ..()

/obj/item/circuit_component/assembly_output/populate_ports()
	signal = add_input_port("Вызов", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/assembly_output/register_shell(atom/movable/shell)
	. = ..()
	if(!isassembly(shell))
		return

	attached_assembly = shell

/obj/item/circuit_component/assembly_output/unregister_shell(atom/movable/shell)
	attached_assembly = null
	return ..()

/obj/item/circuit_component/assembly_output/input_received(datum/port/input/port, list/return_values)
	attached_assembly.pulse(FALSE)
