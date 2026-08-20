/**
 * Storage adapter used by a logistics interface to read and move stock.
 * 
 */
/datum/logistics_adapter
	var/obj/machinery/host

/datum/logistics_adapter/New(obj/machinery/new_host)
	host = new_host

/datum/logistics_adapter/Destroy()
	host = null
	return ..()

/// Returns a list of lists: name, amount, icon, icon_state
/datum/logistics_adapter/proc/list_stock()
	return list()

/datum/logistics_adapter/proc/get_amount(stock_name)
	return 0

/datum/logistics_adapter/proc/get_free_sheets()
	return 0

/// Returns 0-100 fill percent, or null if capacity is unlimited/unknown.
/datum/logistics_adapter/proc/get_fill_percent()
	return null

/datum/logistics_adapter/proc/get_stock_type(stock_name)
	return null

/datum/logistics_adapter/proc/can_accept_name(stock_name, item_type)
	return FALSE

/datum/logistics_adapter/proc/can_insert_item(obj/item/item)
	return FALSE

/datum/logistics_adapter/proc/item_matches_stock(obj/item/item, stock_name)
	return item && (item.declent_ru(NOMINATIVE) == stock_name)

/// Returns TRUE if the item was fully consumed by storage.
/datum/logistics_adapter/proc/insert_item(obj/item/item)
	return FALSE

/// extracts items totaling amount of stock_name into target. Returns the amount actually extracted.
/datum/logistics_adapter/proc/extract(stock_name, amount, atom/target)
	return 0

/datum/logistics_adapter/material_container

/datum/logistics_adapter/material_container/proc/get_container()
	if(!host)
		return null
	return host.GetComponent(/datum/component/material_container)

/datum/logistics_adapter/material_container/proc/find_material_by_name(stock_name)
	var/datum/component/material_container/container = get_container()
	if(!container)
		return null
	for(var/mat_id in container.materials)
		var/datum/material/material = container.materials[mat_id]
		if(material.name == stock_name)
			return material
	return null

/datum/logistics_adapter/material_container/list_stock()
	. = list()
	var/datum/component/material_container/container = get_container()
	if(!container)
		return
	for(var/mat_id in container.materials)
		var/datum/material/material = container.materials[mat_id]
		var/sheets = container.amount2sheet(material.amount)
		if(sheets <= 0)
			continue
		var/obj/item/stack/sheet_path = material.sheet_type
		. += list(list(
			"name" = material.name,
			"amount" = sheets,
			"icon" = sheet_path ? initial(sheet_path.icon) : null,
			"icon_state" = sheet_path ? initial(sheet_path.icon_state) : null,
		))

/datum/logistics_adapter/material_container/get_amount(stock_name)
	var/datum/component/material_container/container = get_container()
	var/datum/material/material = find_material_by_name(stock_name)
	if(!container || !material)
		return 0
	return container.amount2sheet(material.amount)

/datum/logistics_adapter/material_container/get_free_sheets()
	var/datum/component/material_container/container = get_container()
	if(!container)
		return 0
	if(container.max_amount >= INFINITY)
		return INFINITY
	return container.amount2sheet(max(container.max_amount - container.total_amount, 0))

/datum/logistics_adapter/material_container/get_fill_percent()
	var/datum/component/material_container/container = get_container()
	if(!container || container.max_amount <= 0 || container.max_amount >= INFINITY)
		return null
	return round(100 * container.total_amount / container.max_amount)

/datum/logistics_adapter/material_container/get_stock_type(stock_name)
	var/datum/material/material = find_material_by_name(stock_name)
	return material?.sheet_type

/datum/logistics_adapter/material_container/can_accept_name(stock_name, item_type)
	if(!find_material_by_name(stock_name))
		return FALSE
	return get_free_sheets() > 0

/datum/logistics_adapter/material_container/proc/find_material_by_sheet(obj/item/item)
	var/datum/component/material_container/container = get_container()
	if(!container || !item)
		return null
	for(var/mat_id in container.materials)
		var/datum/material/material = container.materials[mat_id]
		if(material.sheet_type && istype(item, material.sheet_type))
			return material
	return null

/datum/logistics_adapter/material_container/can_insert_item(obj/item/item)
	if(!isstack(item))
		return FALSE
	var/datum/component/material_container/container = get_container()
	var/datum/material/material = find_material_by_sheet(item)
	if(!container || !material)
		return FALSE
	return container.get_item_material_amount(item) > 0 && get_free_sheets() > 0

/datum/logistics_adapter/material_container/item_matches_stock(obj/item/item, stock_name)
	var/datum/material/material = find_material_by_sheet(item)
	return material && (material.name == stock_name)

/datum/logistics_adapter/material_container/insert_item(obj/item/item)
	if(!can_insert_item(item))
		return FALSE
	var/obj/item/stack/stack = item
	var/datum/component/material_container/container = get_container()
	var/inserted = container.insert_stack(stack, stack.amount)
	return inserted && QDELETED(stack)

/datum/logistics_adapter/material_container/extract(stock_name, amount, atom/target)
	if(amount <= 0)
		return 0
	var/datum/component/material_container/container = get_container()
	var/datum/material/material = find_material_by_name(stock_name)
	if(!container || !material)
		return 0
	amount = min(amount, container.amount2sheet(material.amount))
	if(amount <= 0)
		return 0
	return container.retrieve_sheets(amount, material.id, target)

/datum/logistics_adapter/smartfridge

/datum/logistics_adapter/smartfridge/proc/get_fridge()
	if(!istype(host, /obj/machinery/smartfridge))
		return null
	return host

/datum/logistics_adapter/smartfridge/proc/is_storage_item(obj/item/item)
	var/obj/machinery/smartfridge/fridge = get_fridge()
	if(!fridge || !item)
		return FALSE
	if(item in fridge.component_parts)
		return FALSE
	return TRUE

/datum/logistics_adapter/smartfridge/list_stock()
	. = list()
	var/obj/machinery/smartfridge/fridge = get_fridge()
	if(!fridge)
		return
	var/list/samples = list()
	for(var/obj/item/item in fridge.contents)
		if(!is_storage_item(item))
			continue
		var/item_name = item.declent_ru(NOMINATIVE)
		if(samples[item_name])
			continue
		samples[item_name] = item
	for(var/item_name in fridge.item_quants)
		var/count = fridge.item_quants[item_name]
		if(count <= 0)
			continue
		var/obj/item/sample = samples[item_name]
		. += list(list(
			"name" = item_name,
			"amount" = count,
			"icon" = sample ? sample.icon : null,
			"icon_state" = sample ? sample.icon_state : null,
		))

/datum/logistics_adapter/smartfridge/get_amount(stock_name)
	var/obj/machinery/smartfridge/fridge = get_fridge()
	if(!fridge)
		return 0
	return fridge.item_quants[stock_name] || 0

/datum/logistics_adapter/smartfridge/proc/get_stored_count()
	var/obj/machinery/smartfridge/fridge = get_fridge()
	if(!fridge)
		return 0
	return fridge.get_stored_item_count()

/datum/logistics_adapter/smartfridge/get_free_sheets()
	var/obj/machinery/smartfridge/fridge = get_fridge()
	if(!fridge)
		return 0
	return max(fridge.max_n_of_items - get_stored_count(), 0)

/datum/logistics_adapter/smartfridge/get_fill_percent()
	var/obj/machinery/smartfridge/fridge = get_fridge()
	if(!fridge || fridge.max_n_of_items <= 0)
		return null
	return round(100 * get_stored_count() / fridge.max_n_of_items)

/datum/logistics_adapter/smartfridge/get_stock_type(stock_name)
	var/obj/machinery/smartfridge/fridge = get_fridge()
	if(!fridge)
		return null
	for(var/obj/item/item in fridge.contents)
		if(!is_storage_item(item))
			continue
		if(item.declent_ru(NOMINATIVE) == stock_name)
			return item.type
	return null

/datum/logistics_adapter/smartfridge/item_matches_stock(obj/item/item, stock_name)
	return is_storage_item(item) && (item.declent_ru(NOMINATIVE) == stock_name)

/datum/logistics_adapter/smartfridge/can_accept_name(stock_name, item_type)
	var/obj/machinery/smartfridge/fridge = get_fridge()
	if(!fridge || get_free_sheets() <= 0)
		return FALSE
	if(fridge.item_quants[stock_name])
		return TRUE
	if(!item_type)
		return FALSE
	if(ispath(item_type))
		return !!fridge.accepted_items_typecache[item_type]
	return fridge.accept_check(item_type)

/datum/logistics_adapter/smartfridge/can_insert_item(obj/item/item)
	var/obj/machinery/smartfridge/fridge = get_fridge()
	if(!fridge || !item)
		return FALSE
	if(get_free_sheets() <= 0)
		return FALSE
	return fridge.accept_check(item)

/datum/logistics_adapter/smartfridge/insert_item(obj/item/item)
	var/obj/machinery/smartfridge/fridge = get_fridge()
	if(!fridge || !can_insert_item(item))
		return FALSE
	if(!fridge.load(item))
		return FALSE
	fridge.update_icon(UPDATE_OVERLAYS)
	return TRUE

/datum/logistics_adapter/smartfridge/extract(stock_name, amount, atom/target)
	var/obj/machinery/smartfridge/fridge = get_fridge()
	if(!fridge || amount <= 0 || !target)
		return 0
	var/extracted = 0
	for(var/obj/item/item in fridge.contents)
		if(extracted >= amount)
			break
		if(!is_storage_item(item))
			continue
		if(item.declent_ru(NOMINATIVE) != stock_name)
			continue
		fridge.item_quants[stock_name] = max((fridge.item_quants[stock_name] || 0) - 1, 0)
		item.forceMove(target)
		extracted++
	if(extracted)
		fridge.update_icon(UPDATE_OVERLAYS)
	return extracted
