/**
 * # Dispenser
 *
 * Immobile (but not dense) shell that can receive and dispense items.
 */
/obj/structure/dispenser_bot
	name = "dispenser"
	icon = 'icons/obj/circuits.dmi'
	icon_state = "setup_drone_arms"

	light_system = MOVABLE_LIGHT
	light_on = FALSE

	var/max_weight = WEIGHT_CLASS_NORMAL
	var/capacity = 20

	var/list/obj/item/stored_items = list()
	var/locked = FALSE

/obj/structure/dispenser_bot/get_ru_names()
	return list(
		NOMINATIVE = "бот-раздатчик",
		GENITIVE = "бота-раздатчика",
		DATIVE = "боту-раздатчику",
		ACCUSATIVE = "бота-раздатчика",
		INSTRUMENTAL = "ботом-раздатчиком",
		PREPOSITIONAL = "боте-раздатчике"
	)

/obj/structure/dispenser_bot/deconstruct(disassembled)
	for(var/obj/item/stored_item as anything in stored_items)
		remove_item(stored_item)

	return ..()

/obj/structure/dispenser_bot/Destroy()
	QDEL_LIST(stored_items)
	return ..()

/obj/structure/dispenser_bot/proc/add_item(mob/user, obj/item/to_add)
	balloon_alert(user, "объект вставлен")
	stored_items += to_add
	user.drop_transfer_item_to_loc(to_add, src)
	RegisterSignal(to_add, COMSIG_MOVABLE_MOVED, PROC_REF(handle_stored_item_moved))
	RegisterSignal(to_add, COMSIG_QDELETING, PROC_REF(handle_stored_item_deleted))
	SEND_SIGNAL(src, COMSIG_DISPENSERBOT_ADD_ITEM, to_add)

/obj/structure/dispenser_bot/proc/handle_stored_item_moved(obj/item/moving_item, atom/location)
	SIGNAL_HANDLER
	if(location == src)
		return

	remove_item(moving_item)

/obj/structure/dispenser_bot/proc/handle_stored_item_deleted(obj/item/deleting_item)
	SIGNAL_HANDLER
	remove_item(deleting_item)

/obj/structure/dispenser_bot/proc/remove_item(obj/item/to_remove)
	UnregisterSignal(to_remove, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_QDELETING,
	))
	to_remove.forceMove(drop_location())
	stored_items -= to_remove
	SEND_SIGNAL(src, COMSIG_DISPENSERBOT_REMOVE_ITEM, to_remove)

/obj/structure/dispenser_bot/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/dispenser_bot()
	), SHELL_CAPACITY_LARGE)

/obj/structure/dispenser_bot/attackby(obj/item/item, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(item, /obj/item/wrench) || is_circuit_multitool(item) || is_integrated_circuit(item))
		return ..()

	if(item.w_class > max_weight && !istype(item, /obj/item/storage/bag))
		balloon_alert(user, "объект слишком большой!")
		return ATTACK_CHAIN_BLOCKED

	if(length(stored_items) >= capacity)
		balloon_alert(user, "хранилище заполнено!")
		return ATTACK_CHAIN_BLOCKED

	if(!istype(item, /obj/item/storage/bag))
		add_item(user, item)
		return ATTACK_CHAIN_BLOCKED

	for(var/obj/item/bag_item in item.contents)
		if(length(stored_items) >= capacity)
			break

		if(bag_item.w_class > max_weight || istype(bag_item, /obj/item/storage/bag))
			continue

		add_item(user, bag_item)

	return ATTACK_CHAIN_BLOCKED

/obj/structure/dispenser_bot/wrench_act(mob/living/user, obj/item/tool)
	if(locked)
		balloon_alert(user, "закрыто!")
		return

	set_anchored(!anchored)
	tool.play_tool_sound(src)
	balloon_alert(user, "[anchored ? "" : "не"]закреплено")
	return TRUE

/obj/item/circuit_component/dispenser_bot
	display_name = "Раздатчик"
	desc = "Бот-раздатчик, который может выдавать предметы."

	/// The list of items
	var/datum/port/output/item_list
	/// The item that was added/removed.
	var/datum/port/output/item
	/// Called when an item is added.
	var/datum/port/output/on_item_added
	/// Called when an item is removed.
	var/datum/port/output/on_item_removed

	ui_buttons = list(
		"plus" = "add_vend_component",
	)

	/// Vendor components attached to this dispenser bot
	var/list/obj/item/circuit_component/vendor_component/vendor_components = list()

	var/max_vendor_components = 20

/obj/item/circuit_component/dispenser_bot/populate_ports()
	item_list = add_output_port("Объекты", PORT_TYPE_LIST(PORT_TYPE_ATOM))
	item = add_output_port("Объект", PORT_TYPE_ATOM)
	on_item_added = add_output_port("Добавлено", PORT_TYPE_SIGNAL)
	on_item_removed = add_output_port("Изъято", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/dispenser_bot/register_shell(atom/movable/shell)
	. = ..()
	RegisterSignal(shell, COMSIG_DISPENSERBOT_ADD_ITEM, PROC_REF(on_shell_add_item))
	RegisterSignal(shell, COMSIG_DISPENSERBOT_REMOVE_ITEM, PROC_REF(on_shell_remove_item))

/obj/item/circuit_component/dispenser_bot/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(
		COMSIG_DISPENSERBOT_ADD_ITEM,
		COMSIG_DISPENSERBOT_REMOVE_ITEM,
	))
	return ..()

/obj/item/circuit_component/dispenser_bot/proc/on_shell_add_item(obj/structure/dispenser_bot/source, obj/item/added_item)
	SIGNAL_HANDLER
	item.set_output(added_item)
	item_list.set_output(source.stored_items)
	on_item_added.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/dispenser_bot/proc/on_shell_remove_item(obj/structure/dispenser_bot/source, obj/item/added_item)
	SIGNAL_HANDLER
	item.set_output(added_item)
	item_list.set_output(source.stored_items)
	on_item_added.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/dispenser_bot/proc/remove_vendor_component(obj/item/circuit_component/vendor_component/vendor_component)
	SIGNAL_HANDLER
	UnregisterSignal(vendor_component, list(
		COMSIG_QDELETING,
		COMSIG_CIRCUIT_COMPONENT_REMOVED,
	))
	if(!QDELING(vendor_component))
		qdel(vendor_component)

	vendor_components -= vendor_component

/obj/item/circuit_component/dispenser_bot/ui_perform_action(mob/user, action)
	switch(action)
		if("add_vend_component")
			if(length(vendor_components) >= max_vendor_components)
				balloon_alert(user, "отсек для компонентов полон!")
				return

			var/obj/item/circuit_component/vendor_component/vendor_component = new(parent)
			parent.add_component(vendor_component, user)
			vendor_components += vendor_component
			RegisterSignal(vendor_component, list(
				COMSIG_QDELETING,
				COMSIG_CIRCUIT_COMPONENT_REMOVED,
			), PROC_REF(remove_vendor_component))

/obj/item/circuit_component/vendor_component
	display_name = "Выдать"
	desc = "Компонент, используемый для выдачи определенных предметов из бота-раздатчика."

	circuit_flags = CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/obj/structure/dispenser_bot/attached_bot

	/// The item this vendor component should vend
	var/datum/port/input/item_to_vend
	/// Used to vend the item
	var/datum/port/input/vend_item

	circuit_size = 0

/obj/item/circuit_component/vendor_component/register_shell(atom/movable/shell)
	. = ..()
	if(!istype(shell, /obj/structure/dispenser_bot))
		return

	attached_bot = shell
	RegisterSignal(parent, COMSIG_CIRCUIT_SET_LOCKED, PROC_REF(on_set_locked))
	attached_bot.locked = parent.locked

/obj/item/circuit_component/vendor_component/unregister_shell(atom/movable/shell)
	if(attached_bot)
		attached_bot.locked = FALSE
		UnregisterSignal(parent, COMSIG_CIRCUIT_SET_LOCKED)

	attached_bot = null
	return ..()

/obj/item/circuit_component/vendor_component/populate_ports()
	item_to_vend = add_input_port("Объект", PORT_TYPE_ATOM, trigger = null)
	vend_item = add_input_port("Выдать", PORT_TYPE_SIGNAL, trigger = PROC_REF(vend_item))

/obj/item/circuit_component/vendor_component/proc/vend_item(datum/port/input/port, list/return_values)
	CIRCUIT_TRIGGER
	if(!attached_bot)
		return

	var/obj/item/vending_item = locate(item_to_vend.value) in attached_bot.stored_items

	if(!vending_item)
		return

	attached_bot.remove_item(vending_item)

/obj/item/circuit_component/vendor_component/proc/on_set_locked(datum/source, new_value)
	SIGNAL_HANDLER
	if(!attached_bot)
		return

	attached_bot.locked = new_value
