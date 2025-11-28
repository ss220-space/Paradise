/// A cable that can connect integrated circuits to anything with a USB port, such as computers and machines.
/obj/item/usb_cable
	name = "usb cable"
	desc = "Кабель, позволяющий подключать интегральные схемы к любому устройству с USB-портом."
	gender = MALE
	icon = 'icons/obj/circuits.dmi'
	icon_state = "usb_cable"
	item_state = "coil_yellow"
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	base_icon_state = "coil"
	w_class = WEIGHT_CLASS_TINY
	materials = list(MAT_METAL=2000)

	/// The currently connected circuit
	var/obj/item/integrated_circuit/attached_circuit

/obj/item/usb_cable/get_ru_names()
	return list(
		NOMINATIVE = "USB-кабель",
		GENITIVE = "USB-кабеля",
		DATIVE = "USB-кабелю",
		ACCUSATIVE = "USB-кабель",
		INSTRUMENTAL = "USB-кабелем",
		PREPOSITIONAL = "USB-кабеле",
	)

/obj/item/usb_cable/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_CLONE_IN_EXPERIMENTATOR, INNATE_TRAIT)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/obj/item/usb_cable/Destroy(force)
	attached_circuit = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/usb_cable/examine(mob/user)
	. = ..()

	if(isnull(attached_circuit))
		return

	. += span_notice("Прикреплён к <b>[attached_circuit.shell.declent_ru(ACCUSATIVE) || attached_circuit.declent_ru(ACCUSATIVE)]</b>.")

// Look, I'm not happy about this either, but moving an object doesn't call Moved if it's inside something else.
// There's good reason for this, but there's no element or similar yet to track it as far as I know.
// SSobj runs infrequently, this is only ran while there's an attached circuit, its performance cost is negligible.
/obj/item/usb_cable/process(seconds_per_tick)
	if(!check_in_range())
		return PROCESS_KILL

/obj/item/usb_cable/pre_attackby(atom/target, mob/living/user, params)
	var/signal_result = SEND_SIGNAL(target, COMSIG_ATOM_USB_CABLE_TRY_ATTACH, src, user)

	var/last_attached_circuit = attached_circuit
	if(signal_result & COMSIG_USB_CABLE_CONNECTED_TO_CIRCUIT)
		if(isnull(attached_circuit))
			CRASH("Producers of COMSIG_USB_CABLE_CONNECTED_TO_CIRCUIT must set attached_circuit")
		balloon_alert(user, "подключено к схеме")

		playsound(src, 'sound/machines/pda_button/pda_button1.ogg', 20, TRUE)

		if(last_attached_circuit != attached_circuit)
			if(!isnull(last_attached_circuit))
				unregister_circuit_signals(last_attached_circuit)
			register_circuit_signals()

		START_PROCESSING(SSobj, src)

		return ATTACK_CHAIN_BLOCKED

	if(signal_result & COMSIG_USB_CABLE_ATTACHED)
		// Short messages are better to read
		var/connection_description = "порту"
		if(istype(target, /obj/machinery/computer))
			connection_description = "консоли"
		else if(ismachinery(target))
			connection_description = "машине"

		balloon_alert(user, "подключено к [connection_description]")
		playsound(src, 'sound/items/screwdriver2.ogg', 20, TRUE)

		return ATTACK_CHAIN_BLOCKED

	if(signal_result & COMSIG_CANCEL_USB_CABLE_ATTACK)
		return ATTACK_CHAIN_BLOCKED

	return ..()

/obj/item/usb_cable/suicide_act(mob/living/user)
	user.visible_message(
		span_suicide("[user] обматыва[PLUR_ET_UT(user)] [declent_ru(ACCUSATIVE)] вокруг шеи! Это выглядит как попытка самоубийства!")
	)
	return OXYLOSS

/obj/item/usb_cable/proc/register_circuit_signals()
	RegisterSignal(attached_circuit, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(attached_circuit, COMSIG_QDELETING, PROC_REF(on_circuit_qdeling))
	RegisterSignal(attached_circuit.shell, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/obj/item/usb_cable/proc/unregister_circuit_signals(obj/item/integrated_circuit/old_circuit)
	UnregisterSignal(attached_circuit, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_QDELETING,
	))

	UnregisterSignal(attached_circuit.shell, COMSIG_MOVABLE_MOVED)

/obj/item/usb_cable/proc/on_moved()
	SIGNAL_HANDLER

	check_in_range()

/obj/item/usb_cable/proc/check_in_range()
	if(isnull(attached_circuit))
		STOP_PROCESSING(SSobj, src)
		return FALSE

	if(!IN_GIVEN_RANGE(attached_circuit, src, USB_CABLE_MAX_RANGE))
		UNLINT(balloon_alert_to_viewers("USB-кабель выскакивает!"))
		unregister_circuit_signals(attached_circuit)
		attached_circuit = null
		STOP_PROCESSING(SSobj, src)
		return FALSE

	return TRUE

/obj/item/usb_cable/proc/on_circuit_qdeling()
	SIGNAL_HANDLER

	attached_circuit = null
	STOP_PROCESSING(SSobj, src)
