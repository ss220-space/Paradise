/**
 * # Scanner
 *
 * A handheld device that lets you flash it over people.
 */
/obj/item/wiremod_scanner
	name = "scanner"
	icon = 'icons/obj/circuits.dmi'
	icon_state = "setup_small"
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_on = FALSE
	w_class = WEIGHT_CLASS_SMALL

/obj/item/wiremod_scanner/get_ru_names()
	return list(
		NOMINATIVE = "сканер",
		GENITIVE = "сканера",
		DATIVE = "сканеру",
		ACCUSATIVE = "сканер",
		INSTRUMENTAL = "сканером",
		PREPOSITIONAL = "сканере"
	)

/obj/item/wiremod_scanner/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_CLONE_IN_EXPERIMENTATOR, INNATE_TRAIT)
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/wiremod_scanner()
	), SHELL_CAPACITY_SMALL)

/obj/item/circuit_component/wiremod_scanner
	display_name = "Сканер"
	desc = "Используется для получения отсканированных объектов со сканера."

	/// Called when afterattack is called on the shell.
	var/datum/port/output/signal

	/// The attacker
	var/datum/port/output/attacker

	/// The entity being attacked
	var/datum/port/output/attacking


/obj/item/circuit_component/wiremod_scanner/populate_ports()
	attacker = add_output_port("Пользователь", PORT_TYPE_USER)
	attacking = add_output_port("Цель", PORT_TYPE_ATOM)
	signal = add_output_port("Вызвано", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/wiremod_scanner/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_ITEM_AFTERATTACK, PROC_REF(handle_afterattack))

/obj/item/circuit_component/wiremod_scanner/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_ITEM_AFTERATTACK)

/**
 * Called when the shell item attacks something
 */
/obj/item/circuit_component/wiremod_scanner/proc/handle_afterattack(atom/source, atom/target, mob/user, proximity_flag)
	SIGNAL_HANDLER
	if(!proximity_flag)
		return

	source.balloon_alert(user, "объект отсканирован")
	playsound(source, "terminal_type", 25, FALSE)
	attacker.set_output(user)
	attacking.set_output(target)
	signal.set_output(COMPONENT_SIGNAL)
	return COMPONENT_AFTERATTACK_PROCESSED_ITEM
