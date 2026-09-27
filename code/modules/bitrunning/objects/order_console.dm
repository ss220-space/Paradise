/obj/machinery/computer/bitrunner_orders
	name = "NexaCache order console"
	desc = "Сомнительно подлинное снаряжение для цифрового сорвиголовы. Заказы приезжают грузовым шаттлом."
	icon = 'icons/obj/machines/bitrunning.dmi'
	icon_state = "vendor"
	icon_keyboard = null
	icon_screen = null
	base_icon_state = "vendor"
	circuit = /obj/item/circuitboard/bitrunner_orders
	req_access = list(ACCESS_BITRUNNING)
	var/obj/item/card/id/inserted_id

/obj/machinery/computer/bitrunner_orders/Initialize(mapload)
	. = ..()
	register_context()

/obj/machinery/computer/bitrunner_orders/Destroy()
	eject_id()
	return ..()

/obj/machinery/computer/bitrunner_orders/get_ru_names()
	return alist(
		NOMINATIVE = "консоль заказов NexaCache",
		GENITIVE = "консоли заказов NexaCache",
		DATIVE = "консоли заказов NexaCache",
		ACCUSATIVE = "консоль заказов NexaCache",
		INSTRUMENTAL = "консолью заказов NexaCache",
		PREPOSITIONAL = "консоли заказов NexaCache",
	)

/obj/machinery/computer/bitrunner_orders/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(isnull(held_item))
		return

	if(is_id_card(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Вставить карту"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/computer/bitrunner_orders/examine(mob/user)
	. = ..()
	if(inserted_id)
		. += span_notice("Вставлена карта [inserted_id.registered_name], на счету [inserted_id.bitrunning_points] очков.")

/obj/machinery/computer/bitrunner_orders/update_icon_state()
	icon_state = is_operational() ? base_icon_state : "[base_icon_state]_off"

/obj/machinery/computer/bitrunner_orders/power_change(forced = FALSE)
	..()
	if(inserted_id && !is_operational())
		visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] выплёвывает карту, теряя питание."))
		eject_id()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/computer/bitrunner_orders/attack_hand(mob/user)
	if(..())
		return TRUE

	ui_interact(user)

/obj/machinery/computer/bitrunner_orders/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!is_id_card(tool))
		return ..()

	if(inserted_id)
		balloon_alert(user, "карта уже вставлена!")
		return ITEM_INTERACT_BLOCKING

	if(!user.drop_transfer_item_to_loc(tool, src))
		return ITEM_INTERACT_BLOCKING

	inserted_id = tool
	ui_interact(user)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/computer/bitrunner_orders/proc/eject_id(mob/user)
	if(isnull(inserted_id))
		return

	if(ishuman(user) && Adjacent(user))
		inserted_id.forceMove_turf()
		user.put_in_hands(inserted_id, ignore_anim = FALSE)
	else
		inserted_id.forceMove(drop_location())

	inserted_id = null

/obj/machinery/computer/bitrunner_orders/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MiningVendor", name)
		ui.open()

/obj/machinery/computer/bitrunner_orders/ui_data(mob/user)
	var/list/data = list()
	data["has_id"] = !isnull(inserted_id)
	if(inserted_id)
		data["id"] = list(
			"name" = inserted_id.registered_name,
			"points" = inserted_id.bitrunning_points,
		)

	return data

/obj/machinery/computer/bitrunner_orders/ui_static_data(mob/user)
	var/list/static_data = list()
	static_data["items"] = list()

	for(var/category in GLOB.bitrunner_order_items)
		var/list/category_items = list()
		for(var/order_name in GLOB.bitrunner_order_items[category])
			var/datum/data/mining_equipment/order = GLOB.bitrunner_order_items[category][order_name]
			var/obj/item/ordered_item = order.equipment_path
			category_items[order_name] = list(
				"name" = order_name,
				"price" = order.cost,
				"icon" = ordered_item.icon,
				"icon_state" = ordered_item.icon_state,
			)
		static_data["items"][category] = category_items

	return static_data

/obj/machinery/computer/bitrunner_orders/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE
	switch(action)
		if("logoff")
			eject_id(usr)

		if("purchase")
			try_order(usr, params["cat"], params["name"])

		else
			return FALSE

	add_fingerprint(usr)

/obj/machinery/computer/bitrunner_orders/proc/try_order(mob/user, category, order_name)
	if(isnull(inserted_id))
		return FALSE

	if(!(category in GLOB.bitrunner_order_items) || !(order_name in GLOB.bitrunner_order_items[category]))
		return FALSE

	var/datum/data/mining_equipment/order = GLOB.bitrunner_order_items[category][order_name]
	if(order.cost > inserted_id.bitrunning_points)
		balloon_alert(user, "недостаточно очков!")
		return FALSE

	inserted_id.bitrunning_points -= order.cost
	place_order(order, order_name)
	balloon_alert(user, "заказ отправлен")
	return TRUE

/obj/machinery/computer/bitrunner_orders/proc/place_order(datum/data/mining_equipment/order, order_name)
	var/datum/supply_packs/bitrunning/pack = new()
	pack.name = order_name
	pack.contains = list(order.equipment_path)
	pack.containername = "NexaCache: [order_name]"

	var/datum/supply_order/supply = new()
	supply.ordernum = SSshuttle.ordernum++
	supply.object = pack
	supply.orderedby = inserted_id.registered_name
	supply.orderedbyRank = inserted_id.assignment
	supply.comment = "битраннинг"
	SSshuttle.shoppinglist += supply

	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 30, TRUE)
	radio_announce("Битраннер заказал снаряжение — оно прибудет грузовым шаттлом.", declent_ru(NOMINATIVE), SUP_FREQ, src)
