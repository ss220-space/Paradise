/**
 * # Hear Component
 *
 * Listens for messages. Requires a shell.
 */
/obj/item/circuit_component/hear
	display_name = "Голосовой активатор"
	desc = "Компонент, прослушивающий сообщения. Требуется оболочка."
	category = "Entity"

	/// The on/off port
	var/datum/port/input/on

	/// The message heard
	var/datum/port/output/message_port
	/// The speaker name port, usually the name of the person who spoke.
	var/datum/port/output/speaker_name
	/// The speaker entity that is currently speaking. Not necessarily the person who is speaking.
	var/datum/port/output/speaker_port
	/// The trigger sent when this event occurs
	var/datum/port/output/trigger_port

/obj/item/circuit_component/hear/Destroy()
	on = null
	message_port = null
	speaker_name = null
	speaker_port = null
	trigger_port = null
	. = ..()

/obj/item/circuit_component/hear/populate_ports()
	on = add_input_port("Вкл", PORT_TYPE_NUMBER, default = 1)
	message_port = add_output_port("Сообщение", PORT_TYPE_STRING)
	speaker_port = add_output_port("Объект", PORT_TYPE_ATOM)
	speaker_name = add_output_port("Имя", PORT_TYPE_STRING)
	trigger_port = add_output_port("Вызвано", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/hear/register_shell(atom/movable/shell)
	// if(parent.loc != shell)
	RegisterSignal(shell, COMSIG_MOVABLE_HEAR, PROC_REF(on_shell_hear))

/obj/item/circuit_component/hear/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_MOVABLE_HEAR)

/obj/item/circuit_component/hear/proc/on_shell_hear(datum/source, mob/speaker, list/message_pieces)
	SIGNAL_HANDLER
	return Hear(speaker, message_pieces)

/obj/item/circuit_component/hear/proc/Hear(mob/speaker, list/message_pieces)
	if(!on.value)
		return FALSE
	if(speaker == parent?.shell)
		return FALSE
	message_port.set_output(multilingual_to_message(message_pieces))
	speaker_port.set_output(speaker)
	speaker_name.set_output(speaker.GetVoice())
	trigger_port.set_output(COMPONENT_SIGNAL)
	return TRUE
