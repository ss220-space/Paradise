/**
 * Smart Container — general-purpose item storage with logistics support.
 */
/obj/machinery/smartfridge/smart_container
	name = "Smart Container"
	desc = "Умный контейнер для хранения любых предметов. Вместимость масштабируется с качеством matter bin."
	icon_state = "smart_container"
	status_overlay = "smartfridge"
	max_n_of_items = 63
	fridge_circuit = /obj/item/circuitboard/smart_container
	starting_matter_bins = 4

/obj/machinery/smartfridge/smart_container/get_ru_names()
	return alist(
		NOMINATIVE = "умный контейнер",
		GENITIVE = "умного контейнера",
		DATIVE = "умному контейнеру",
		ACCUSATIVE = "умный контейнер",
		INSTRUMENTAL = "умным контейнером",
		PREPOSITIONAL = "умном контейнере",
	)

/obj/machinery/smartfridge/smart_container/Initialize(mapload)
	. = ..()
	accepted_items_typecache = typecacheof(/obj/item)

/obj/machinery/smartfridge/smart_container/logistics

/obj/machinery/smartfridge/smart_container/logistics/Initialize(mapload)
	. = ..()
	install_logistics_interface(LOGISTICS_MODE_SEND)

/obj/machinery/smartfridge/smart_container/RefreshParts()
	var/rating_sum = 0
	for(var/obj/item/stock_parts/matter_bin/bin in component_parts)
		rating_sum += bin.rating
	max_n_of_items = max(1, round(21 * 3 * rating_sum / 4))

/obj/machinery/smartfridge/smart_container/accept_check(obj/item/I)
	return isitem(I)

/obj/machinery/smartfridge/smart_container/update_fridge_contents()
	var/stored = get_stored_item_count()
	if(stored <= 0)
		fill_level = null
		return
	var/ratio = stored / max(max_n_of_items, 1)
	if(ratio < LOGISTICS_FILL_MEDIUM_THRESHOLD)
		fill_level = LOGISTICS_FILL_LOW
	else if(ratio < LOGISTICS_FILL_HIGH_THRESHOLD)
		fill_level = LOGISTICS_FILL_MEDIUM
	else
		fill_level = LOGISTICS_FILL_HIGH

/obj/item/circuitboard/smart_container
	board_name = "Smart Container"
	build_path = /obj/machinery/smartfridge/smart_container
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 4,
	)
