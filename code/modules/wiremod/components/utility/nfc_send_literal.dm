/**
 * # NFC Transmitter List Literal Component
 *
 * Create a list literal and send a data package through NFC
 *
 * This file is based off of nfc_sendl.dm
 * Any changes made to those files should be copied over with discretion
 */
/obj/item/circuit_component/list_literal/nfc_send
	display_name = "NFC передатчик литералов"
	desc = "Создаёт пакет данных списка литералов и отправляет его через NFC. \
			Если задан ключ шифрования, передаваемые данные будут приняты только получателями с таким же ключом шифрования."
	category = "Utility"

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	/// Encryption key
	var/datum/port/input/enc_key

	/// The targeted circuit
	var/datum/port/input/target

/obj/item/circuit_component/list_literal/nfc_send/populate_ports()
	. = ..()
	enc_key = add_input_port("Ключ", PORT_TYPE_STRING)
	target = add_input_port("Цель", PORT_TYPE_ATOM)

/obj/item/circuit_component/list_literal/nfc_send/input_received(datum/port/input/port)
	. = ..()
	if(!isatom(target.value))
		return

	var/atom/target_enty = target.value
	SEND_SIGNAL(target_enty, COMSIG_CIRCUIT_NFC_DATA_SENT, list("data" = list_output.value, "enc_key" = enc_key.value, "port" = WEAKREF(list_output)))
