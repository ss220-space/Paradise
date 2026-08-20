/datum/logistics_request
	var/datum/logistics_net/net
	var/datum/weakref/source_ref
	var/datum/weakref/dest_ref
	var/datum/weakref/creator_interface_ref
	var/list/wanted = list()
	var/list/original_wanted = list()
	var/list/reserved = list()
	var/list/delivered = list()
	var/status = LOGISTICS_REQUEST_PENDING
	var/created_at
	var/request_num = 0
	var/creator_name = "Неизвестный"

/datum/logistics_request/New(datum/logistics_net/new_net, datum/component/logistics_interface/source, datum/component/logistics_interface/dest, list/wanted_items)
	net = new_net
	created_at = world.time
	if(source)
		source_ref = WEAKREF(source)
	if(dest)
		dest_ref = WEAKREF(dest)
	if(wanted_items)
		wanted = wanted_items.Copy()
		original_wanted = wanted_items.Copy()

/datum/logistics_request/Destroy()
	net = null
	source_ref = null
	dest_ref = null
	creator_interface_ref = null
	wanted.Cut()
	original_wanted.Cut()
	reserved.Cut()
	delivered.Cut()
	return ..()

/datum/logistics_request/proc/is_finished()
	if(status == LOGISTICS_REQUEST_CANCELLED || status == LOGISTICS_REQUEST_COMPLETE)
		return TRUE
	for(var/stock_name in wanted)
		if(wanted[stock_name] > 0)
			return FALSE
	for(var/stock_name in reserved)
		if(reserved[stock_name] > 0)
			return FALSE
	return TRUE

/datum/logistics_request/proc/reserve(stock_name, amount)
	if(amount <= 0)
		return
	wanted[stock_name] = max((wanted[stock_name] || 0) - amount, 0)
	reserved[stock_name] += amount

/datum/logistics_request/proc/confirm_delivery(stock_name, amount)
	if(amount <= 0)
		return
	var/from_reserved = min(amount, reserved[stock_name] || 0)
	reserved[stock_name] = max((reserved[stock_name] || 0) - from_reserved, 0)
	delivered[stock_name] += from_reserved

/datum/logistics_request/proc/release_reservation(stock_name, amount)
	if(amount <= 0)
		return
	var/from_reserved = min(amount, reserved[stock_name] || 0)
	reserved[stock_name] = max((reserved[stock_name] || 0) - from_reserved, 0)
	wanted[stock_name] += from_reserved

/datum/logistics_request/proc/finalize_shipment(list/manifest, list/undelivered)
	if(!length(manifest))
		return
	for(var/stock_name in manifest)
		var/sent = manifest[stock_name]
		var/failed = undelivered[stock_name] || 0
		var/ok = max(sent - failed, 0)
		if(ok > 0)
			confirm_delivery(stock_name, ok)
		if(failed > 0)
			release_reservation(stock_name, failed)

/datum/logistics_request/proc/get_source()
	return source_ref?.resolve()

/datum/logistics_request/proc/get_dest()
	return dest_ref?.resolve()

/datum/logistics_request/proc/get_creator_interface()
	return creator_interface_ref?.resolve()

/datum/logistics_request/proc/pause()
	if(status != LOGISTICS_REQUEST_ACTIVE)
		return FALSE
	status = LOGISTICS_REQUEST_PAUSED
	return TRUE

/datum/logistics_request/proc/execute()
	if(status != LOGISTICS_REQUEST_PENDING && status != LOGISTICS_REQUEST_PAUSED)
		return FALSE
	status = LOGISTICS_REQUEST_ACTIVE
	return TRUE

/datum/logistics_request/proc/unpause()
	return execute()

/datum/logistics_request/proc/cancel()
	if(status == LOGISTICS_REQUEST_COMPLETE || status == LOGISTICS_REQUEST_CANCELLED)
		return FALSE
	status = LOGISTICS_REQUEST_CANCELLED
	return TRUE

/datum/logistics_request/proc/format_delivered_text()
	if(!length(delivered))
		return "ничего"
	var/list/parts = list()
	for(var/stock_name in delivered)
		parts += "[stock_name] ×[delivered[stock_name]]"
	return parts.Join(", ")

/datum/logistics_request/proc/notify_related(message)
	var/list/datum/component/logistics_interface/targets = list()
	var/datum/component/logistics_interface/dest = get_dest()
	var/datum/component/logistics_interface/source = get_source()
	var/datum/component/logistics_interface/creator = get_creator_interface()
	if(dest)
		targets |= dest
	if(source)
		targets |= source
	if(creator)
		targets |= creator
	for(var/datum/component/logistics_interface/interface as anything in targets)
		interface.announce_status(message)

/datum/logistics_request/proc/ui_serialize()
	var/datum/component/logistics_interface/req_source = get_source()
	var/datum/component/logistics_interface/req_dest = get_dest()
	var/list/wanted_ui = list()
	for(var/stock_name in original_wanted)
		var/remaining = (wanted[stock_name] || 0) + (reserved[stock_name] || 0)
		wanted_ui += list(list(
			"name" = stock_name,
			"amount" = remaining,
			"original" = original_wanted[stock_name] || remaining,
		))
	return list(
		"uid" = UID(),
		"num" = request_num,
		"status" = status,
		"net_id" = net?.net_id,
		"net_name" = net?.net_name,
		"net_color" = net?.net_color,
		"source" = req_source ? req_source.interface_name : "Any",
		"dest" = req_dest ? req_dest.interface_name : "?",
		"wanted" = wanted_ui,
		"creator" = creator_name,
		"created_at" = created_at,
	)
