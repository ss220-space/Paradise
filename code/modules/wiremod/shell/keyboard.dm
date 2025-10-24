/obj/item/keyboard_shell
	name = "Keyboard Shell"
	icon = 'icons/obj/circuits.dmi'
	icon_state = "setup_small_keyboard"
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_on = FALSE
	w_class = WEIGHT_CLASS_SMALL

/obj/item/keyboard_shell/get_ru_names()
	return list(
		NOMINATIVE = "оболочка клавиатуры",
		GENITIVE = "оболочки клавиатуры",
		DATIVE = "оболочке клавиатуры",
		ACCUSATIVE = "оболочку клавиатуры",
		INSTRUMENTAL = "оболочкой клавиатуры",
		PREPOSITIONAL = "оболочке клавиатуры"
	)

/obj/item/keyboard_shell/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_CLONE_IN_EXPERIMENTATOR, INNATE_TRAIT)
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/keyboard_shell()
	), SHELL_CAPACITY_SMALL)

/obj/item/circuit_component/keyboard_shell
	display_name = "Оболочка клавиатуры"
	desc = "Ручная клавиатура, позволяющая пользователю вводить текст."

	/// Called when the input window is closed
	var/datum/port/output/signal
	/// Entity who used the shell
	var/datum/port/output/entity
	/// The string, entity typed and submitted
	var/datum/port/output/output

/obj/item/circuit_component/keyboard_shell/examine(mob/user)
	. = ..()
	. += span_notice("<b>Используйте в руке</b>, чтобы открыть панель ввода.")

/obj/item/circuit_component/keyboard_shell/populate_ports()
	entity = add_output_port("Пользователь", PORT_TYPE_USER)
	output = add_output_port("Сообщение", PORT_TYPE_STRING)
	signal = add_output_port("Вызвано", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/keyboard_shell/register_shell(atom/movable/shell)
	. = ..()
	RegisterSignal(shell, COMSIG_ITEM_ATTACK_SELF, PROC_REF(send_trigger))

/obj/item/circuit_component/keyboard_shell/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_ITEM_ATTACK_SELF)
	return ..()

/obj/item/circuit_component/keyboard_shell/proc/send_trigger(atom/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(use_keyboard), user)

/obj/item/circuit_component/keyboard_shell/proc/use_keyboard(mob/user)
	if(!user.is_literate())
		to_chat(user, span_warning("Вы начинаете нажимать клавиши в случайном порядке!"))
		return

	var/message = tgui_input_text(user, "Введите текст", "Клавиатура", max_length = MAX_MESSAGE_LEN)
	entity.set_output(user)
	output.set_output(message)
	signal.set_output(COMPONENT_SIGNAL)

