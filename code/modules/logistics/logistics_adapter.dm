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

/// Returns list of lists: id, name, amount, icon, icon_state
/datum/logistics_adapter/proc/list_stock()
	return list()

/datum/logistics_adapter/proc/get_amount(stock_id)
	return 0

/datum/logistics_adapter/proc/get_free_sheets()
	return 0

/// Returns 0-100 fill percent, or null if capacity is unlimited/unknown.
/datum/logistics_adapter/proc/get_fill_percent()
	return null

/datum/logistics_adapter/proc/get_stock_type(stock_id)
	return logistics_stock_path(stock_id)

/datum/logistics_adapter/proc/can_accept_stock(stock_id)
	return FALSE

/datum/logistics_adapter/proc/can_insert_item(obj/item/item)
	return FALSE

/datum/logistics_adapter/proc/item_matches_stock(obj/item/item, stock_id)
	if(!item || !stock_id)
		return FALSE
	var/path = logistics_stock_path(stock_id)
	return path && istype(item, path)

/// Returns TRUE if the item was fully consumed by storage.
/datum/logistics_adapter/proc/insert_item(obj/item/item)
	return FALSE

/// Extracts items totaling amount of stock_id into target. Returns amount extracted.
/datum/logistics_adapter/proc/extract(stock_id, amount, atom/target)
	return 0

/proc/logistics_stock_id_for_item(obj/item/item)
	if(!item)
		return null
	if(isstack(item))
		for(var/datum/material/mat as anything in subtypesof(/datum/material))
			var/sheet_path = initial(mat.sheet_type)
			if(sheet_path && istype(item, sheet_path))
				return "[sheet_path]"
		var/obj/item/stack/stack = item
		if(stack.merge_type)
			return "[stack.merge_type]"
	return "[item.type]"

/proc/logistics_stock_id_for_material(datum/material/material)
	if(!material)
		return null
	if(material.sheet_type)
		return "[material.sheet_type]"
	if(material.id)
		return "mat:[material.id]"
	return null

/proc/logistics_stock_path(stock_id)
	if(!istext(stock_id) || !length(stock_id))
		return null
	if(findtext(stock_id, "mat:") == 1)
		return null
	return text2path(stock_id)

/proc/logistics_stock_display_name(stock_id)
	if(!stock_id)
		return "???"
	for(var/datum/material/mat as anything in subtypesof(/datum/material))
		var/sheet_path = initial(mat.sheet_type)
		if(sheet_path && "[sheet_path]" == stock_id)
			return initial(mat.name)
	var/path = logistics_stock_path(stock_id)
	if(ispath(path, /obj/item))
		var/obj/item/item_path = path
		return initial(item_path.name)
	return stock_id

/datum/logistics_adapter/material_container

/datum/logistics_adapter/material_container/proc/get_container()
	if(!host)
		return null
	return host.GetComponent(/datum/component/material_container)

/datum/logistics_adapter/material_container/proc/find_material_by_stock_id(stock_id)
	var/datum/component/material_container/container = get_container()
	if(!container || !stock_id)
		return null
	for(var/mat_id in container.materials)
		var/datum/material/material = container.materials[mat_id]
		if(logistics_stock_id_for_material(material) == stock_id)
			return material
	return null

/datum/logistics_adapter/material_container/proc/find_material_by_sheet(obj/item/item)
	var/datum/component/material_container/container = get_container()
	if(!container || !item)
		return null
	for(var/mat_id in container.materials)
		var/datum/material/material = container.materials[mat_id]
		if(material.sheet_type && istype(item, material.sheet_type))
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
		var/stock_id = logistics_stock_id_for_material(material)
		if(!stock_id)
			continue
		var/obj/item/stack/sheet_path = material.sheet_type
		. += list(list(
			"id" = stock_id,
			"name" = material.name,
			"amount" = sheets,
			"icon" = sheet_path ? initial(sheet_path.icon) : null,
			"icon_state" = sheet_path ? initial(sheet_path.icon_state) : null,
		))

/datum/logistics_adapter/material_container/get_amount(stock_id)
	var/datum/component/material_container/container = get_container()
	var/datum/material/material = find_material_by_stock_id(stock_id)
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

/datum/logistics_adapter/material_container/can_accept_stock(stock_id)
	if(get_free_sheets() <= 0)
		return FALSE
	return !!find_material_by_stock_id(stock_id)

/datum/logistics_adapter/material_container/can_insert_item(obj/item/item)
	if(!isstack(item))
		return FALSE
	var/datum/component/material_container/container = get_container()
	var/datum/material/material = find_material_by_sheet(item)
	if(!container || !material)
		return FALSE
	return container.get_item_material_amount(item) > 0 && get_free_sheets() > 0

/datum/logistics_adapter/material_container/insert_item(obj/item/item)
	if(!can_insert_item(item))
		return FALSE
	var/obj/item/stack/stack = item
	var/datum/component/material_container/container = get_container()
	var/inserted = container.insert_stack(stack, stack.amount)
	return inserted && QDELETED(stack)

/datum/logistics_adapter/material_container/extract(stock_id, amount, atom/target)
	if(amount <= 0)
		return 0
	var/datum/component/material_container/container = get_container()
	var/datum/material/material = find_material_by_stock_id(stock_id)
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
	var/list/amounts = list()
	var/list/samples = list()
	for(var/obj/item/item in fridge.contents)
		if(!is_storage_item(item))
			continue
		var/stock_id = logistics_stock_id_for_item(item)
		if(!stock_id)
			continue
		amounts[stock_id] += 1
		if(!samples[stock_id])
			samples[stock_id] = item
	for(var/stock_id in amounts)
		var/obj/item/sample = samples[stock_id]
		. += list(list(
			"id" = stock_id,
			"name" = sample.declent_ru(NOMINATIVE),
			"amount" = amounts[stock_id],
			"icon" = sample.icon,
			"icon_state" = sample.icon_state,
		))

/datum/logistics_adapter/smartfridge/get_amount(stock_id)
	var/obj/machinery/smartfridge/fridge = get_fridge()
	if(!fridge || !stock_id)
		return 0
	. = 0
	for(var/obj/item/item in fridge.contents)
		if(!is_storage_item(item))
			continue
		if(logistics_stock_id_for_item(item) == stock_id)
			.++

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

/datum/logistics_adapter/smartfridge/can_accept_stock(stock_id)
	var/obj/machinery/smartfridge/fridge = get_fridge()
	if(!fridge || get_free_sheets() <= 0 || !stock_id)
		return FALSE
	if(get_amount(stock_id) > 0)
		return TRUE
	var/path = logistics_stock_path(stock_id)
	if(!ispath(path, /obj/item))
		return FALSE
	return is_type_in_typecache(path, fridge.accepted_items_typecache)

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

/datum/logistics_adapter/smartfridge/extract(stock_id, amount, atom/target)
	var/obj/machinery/smartfridge/fridge = get_fridge()
	if(!fridge || amount <= 0 || !target || !stock_id)
		return 0
	var/extracted = 0
	for(var/obj/item/item in fridge.contents)
		if(extracted >= amount)
			break
		if(!is_storage_item(item))
			continue
		if(logistics_stock_id_for_item(item) != stock_id)
			continue
		var/item_name = item.declent_ru(NOMINATIVE)
		fridge.item_quants[item_name] = max((fridge.item_quants[item_name] || 0) - 1, 0)
		item.forceMove(target)
		extracted++
	if(extracted)
		fridge.update_icon(UPDATE_OVERLAYS)
	return extracted
