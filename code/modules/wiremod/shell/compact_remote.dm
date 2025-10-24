/**
 * # Compact Remote
 *
 * A handheld device with one big button.
 */
/obj/item/compact_remote
	name = "compact remote"
	icon = 'icons/obj/circuits.dmi'
	icon_state = "setup_small_simple"
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_on = FALSE
	w_class = WEIGHT_CLASS_TINY

/obj/item/compact_remote/get_ru_names()
	return list(
		NOMINATIVE = "компактный пульт дистанционного управления",
		GENITIVE = "компактного пульта дистанционного управления",
		DATIVE = "компактному пульту дистанционного управления",
		ACCUSATIVE = "компактный пульт дистанционного управления",
		INSTRUMENTAL = "компактным пультом дистанционного управления",
		PREPOSITIONAL = "компактном пульте дистанционного управления"
	)

/obj/item/compact_remote/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_CLONE_IN_EXPERIMENTATOR, INNATE_TRAIT)
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/compact_remote()
	), SHELL_CAPACITY_SMALL)

/obj/item/circuit_component/compact_remote
	display_name = "Компактный пульт"
	desc = "Используется для получения входных сигналов от компактного пульта дистанционного управления.\
			Используйте пульт в руке для активации выходного сигнала."

	/// Called when attack_self is called on the shell.
	var/datum/port/output/signal
	/// The user who used the bot
	var/datum/port/output/entity

/obj/item/circuit_component/compact_remote/populate_ports()
	entity = add_output_port("Пользователь", PORT_TYPE_USER)
	signal = add_output_port("Вызвано", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/compact_remote/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_ITEM_ATTACK_SELF, PROC_REF(send_trigger))

/obj/item/circuit_component/compact_remote/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_ITEM_ATTACK_SELF)

/**
 * Called when the shell item is used in hand.
 */
/obj/item/circuit_component/compact_remote/proc/send_trigger(atom/source, mob/user)
	SIGNAL_HANDLER
	source.balloon_alert(user, "нажата большая красная кнопка")
	playsound(source, "terminal_type", 25, FALSE)
	entity.set_output(user)
	signal.set_output(COMPONENT_SIGNAL)
