/**
 * # Compact Remote
 *
 * A handheld device with several buttons.
 * In game, this translates to having different signals for normal usage, alt-clicking, and ctrl-clicking when in your hand.
 */
/obj/item/controller
	name = "controller"
	icon = 'icons/obj/circuits.dmi'
	icon_state = "setup_small_calc"

	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_on = FALSE
	w_class = WEIGHT_CLASS_SMALL

/obj/item/controller/get_ru_names()
	return list(
		NOMINATIVE = "контроллер",
		GENITIVE = "контроллера",
		DATIVE = "контроллеру",
		ACCUSATIVE = "контроллер",
		INSTRUMENTAL = "контроллером",
		PREPOSITIONAL = "контроллере"
	)

/obj/item/controller/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_CLONE_IN_EXPERIMENTATOR, INNATE_TRAIT)
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/controller()
	), SHELL_CAPACITY_MEDIUM)

/obj/item/circuit_component/controller
	display_name = "Контроллер"
	desc = "Используется для получения входных сигналов от корпуса контроллера. \
			Используйте корпус в руке для активации выходного сигнала."
	/// The three separate buttons that are called in attack_hand on the shell.
	var/datum/port/output/signal
	var/datum/port/output/alt
	var/datum/port/output/ctrl

	/// The entity output
	var/datum/port/output/entity

/obj/item/circuit_component/controller/examine(mob/user)
	. = ..()
	. += "Используйте <b>ALT+ЛКМ</b> для подачи альтернативного сигнала, <b>CTRL+ЛКМ</b> для дополнительного."

/obj/item/circuit_component/controller/populate_ports()
	entity = add_output_port("Пользователь", PORT_TYPE_USER)
	signal = add_output_port("Вызвано", PORT_TYPE_SIGNAL)
	alt = add_output_port("Альт-Вызвано", PORT_TYPE_SIGNAL)
	ctrl = add_output_port("Доп-Вызвано", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/controller/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_ITEM_ATTACK_SELF, PROC_REF(send_trigger))
	RegisterSignal(shell, COMSIG_CLICK_ALT, PROC_REF(send_alternate_signal))
	RegisterSignal(shell, COMSIG_CLICK_CTRL, PROC_REF(send_ctrl_signal))

/obj/item/circuit_component/controller/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(
		COMSIG_ITEM_ATTACK_SELF,
		COMSIG_CLICK_CTRL,
		COMSIG_CLICK_ALT,
	))

/obj/item/circuit_component/controller/proc/handle_trigger(atom/source, user, port_name, datum/port/output/port_signal)
	source.balloon_alert(user, "нажата [port_name] кнопка")
	playsound(source, SFX_KEYBOARD_CLICKS, 25, FALSE)
	entity.set_output(user)
	port_signal.set_output(COMPONENT_SIGNAL)

/**
 * Called when the shell item is used in hand
 */
/obj/item/circuit_component/controller/proc/send_trigger(atom/source, mob/user)
	SIGNAL_HANDLER
	if(!user.Adjacent(source))
		return

	handle_trigger(source, user, "главная", signal)

/**
 * Called when the shell item is alt-clicked
 */
/obj/item/circuit_component/controller/proc/send_alternate_signal(atom/source, mob/user)
	SIGNAL_HANDLER

	handle_trigger(source, user, "альтернативная", alt)
	return CLICK_ACTION_SUCCESS


/**
 * Called when the shell item is ctrl-clicked in active hand
 */
/obj/item/circuit_component/controller/proc/send_ctrl_signal(atom/source, mob/user)
	SIGNAL_HANDLER

	if(!user.can_perform_action(source))
		return

	handle_trigger(source, user, "дополнительная", ctrl)
	return CLICK_ACTION_SUCCESS
