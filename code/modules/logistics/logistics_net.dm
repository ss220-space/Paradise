GLOBAL_VAR_INIT(logistics_net_next_id, 1)

/datum/logistics_net
	var/list/obj/structure/logistics_pipe/pipes = list()
	var/list/datum/component/logistics_interface/interfaces = list()
	var/list/datum/logistics_request/requests = list()
	var/list/obj/structure/logistics_holder/in_flight = list()
	var/list/logs = list()
	var/list/archived_orders = list()
	var/rebuilding = FALSE
	var/net_id
	var/net_name
	var/net_color
	var/auto_execute = FALSE
	var/next_request_num = 1
	var/next_dispatch_at = 0

/datum/logistics_net/New()
	net_id = GLOB.logistics_net_next_id++
	net_name = "Сеть #[net_id]"
	var/list/palette = LOGISTICS_NET_COLORS
	net_color = palette[(net_id - 1) % length(palette) + 1]
	GLOB.logistics_nets += src

/datum/logistics_net/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	GLOB.logistics_nets -= src
	for(var/obj/structure/logistics_pipe/pipe as anything in pipes)
		if(pipe.logistics_net == src)
			pipe.logistics_net = null
	pipes.Cut()
	for(var/datum/component/logistics_interface/interface as anything in interfaces)
		if(interface.net == src)
			interface.net = null
	interfaces.Cut()
	QDEL_LIST(requests)
	in_flight.Cut()
	return ..()

/datum/logistics_net/proc/add_log(text)
	logs += "[station_time_timestamp()] - [text]"
	if(length(logs) > LOGISTICS_MAX_LOGS)
		logs.Cut(1, length(logs) - LOGISTICS_MAX_LOGS + 1)

/datum/logistics_net/proc/archive_order(datum/logistics_request/request, result_text)
	if(!request)
		return
	var/list/entry = request.ui_serialize()
	entry["result"] = result_text
	entry["finished_at"] = station_time_timestamp()
	archived_orders.Insert(1, list(entry))
	if(length(archived_orders) > LOGISTICS_MAX_ARCHIVE)
		archived_orders.Cut(LOGISTICS_MAX_ARCHIVE + 1)

/datum/logistics_net/proc/add_pipe(obj/structure/logistics_pipe/pipe)
	if(!pipe || (pipe in pipes))
		return
	pipes += pipe
	pipe.logistics_net = src
	pipe.try_link_interface()

/datum/logistics_net/proc/add_interface(datum/component/logistics_interface/interface)
	if(!interface || (interface in interfaces))
		return
	interfaces += interface
	interface.net = src

/datum/logistics_net/proc/remove_interface(datum/component/logistics_interface/interface)
	interfaces -= interface
	if(interface.net == src)
		interface.net = null

/datum/logistics_net/proc/remove_pipe(obj/structure/logistics_pipe/pipe)
	if(rebuilding)
		pipes -= pipe
		if(pipe.logistics_net == src)
			pipe.logistics_net = null
		return
	pipes -= pipe
	if(pipe.logistics_net == src)
		pipe.logistics_net = null
	if(!length(pipes))
		qdel(src)
		return
	split_if_needed()

/datum/logistics_net/proc/merge(datum/logistics_net/other)
	if(!other || other == src || other.rebuilding || rebuilding)
		return
	other.rebuilding = TRUE
	for(var/obj/structure/logistics_pipe/pipe as anything in other.pipes)
		add_pipe(pipe)
	for(var/datum/component/logistics_interface/interface as anything in other.interfaces)
		add_interface(interface)
	for(var/datum/logistics_request/request as anything in other.requests)
		request.net = src
		requests += request
	other.requests.Cut()
	for(var/obj/structure/logistics_holder/holder as anything in other.in_flight)
		holder.origin_net = src
	in_flight += other.in_flight
	other.in_flight.Cut()
	logs += other.logs
	archived_orders += other.archived_orders
	if(length(logs) > LOGISTICS_MAX_LOGS)
		logs.Cut(1, length(logs) - LOGISTICS_MAX_LOGS + 1)
	if(length(archived_orders) > LOGISTICS_MAX_ARCHIVE)
		archived_orders.Cut(LOGISTICS_MAX_ARCHIVE + 1)
	if(other.auto_execute)
		auto_execute = TRUE
	add_log("Сети объединены.")
	qdel(other)
	refresh_processing()

/datum/logistics_net/proc/split_if_needed()
	rebuilding = TRUE
	var/list/remaining = pipes.Copy()
	var/list/groups = list()
	while(length(remaining))
		var/obj/structure/logistics_pipe/seed = remaining[1]
		var/list/group = flood_pipes(seed)
		groups += list(group)
		remaining -= group
	rebuilding = FALSE
	if(length(groups) <= 1)
		refresh_interfaces()
		return
	var/list/keep = groups[1]
	pipes = keep
	for(var/obj/structure/logistics_pipe/pipe as anything in keep)
		pipe.logistics_net = src
	refresh_interfaces()
	for(var/i in 2 to length(groups))
		var/datum/logistics_net/new_net = new
		for(var/obj/structure/logistics_pipe/pipe as anything in groups[i])
			new_net.add_pipe(pipe)
		new_net.refresh_interfaces()
		new_net.add_log("Сеть отделилась после разрыва труб.")
	add_log("Сеть разделилась после разрыва труб.")
	rehome_after_topology_change()
	refresh_processing()

/datum/logistics_net/proc/rehome_after_topology_change()
	for(var/obj/structure/logistics_holder/holder as anything in in_flight.Copy())
		var/datum/logistics_net/pipe_net
		if(istype(holder.loc, /obj/structure/logistics_pipe))
			var/obj/structure/logistics_pipe/pipe = holder.loc
			pipe_net = pipe.logistics_net
		if(!pipe_net || pipe_net == src)
			continue
		in_flight -= holder
		pipe_net.in_flight += holder
		holder.origin_net = pipe_net

	for(var/datum/logistics_request/request as anything in requests.Copy())
		var/datum/component/logistics_interface/dest = request.get_dest()
		var/datum/component/logistics_interface/source = request.get_source()
		var/datum/logistics_net/target_net = dest?.net
		if(!dest || !target_net)
			cancel_request(request)
			continue
		if(source && source.net && source.net != target_net)
			cancel_request(request)
			continue
		if(target_net == src)
			continue
		requests -= request
		request.net = target_net
		target_net.requests += request
		target_net.refresh_processing()

/datum/logistics_net/proc/flood_pipes(obj/structure/logistics_pipe/start)
	. = list()
	if(!start)
		return
	var/list/queue = list(start)
	var/idx = 1
	while(idx <= length(queue))
		var/obj/structure/logistics_pipe/current = queue[idx++]
		if(current in .)
			continue
		. += current
		for(var/obj/structure/logistics_pipe/neighbor as anything in current.get_neighbors())
			if(!(neighbor in .) && (neighbor in pipes))
				queue += neighbor

/datum/logistics_net/proc/refresh_interfaces()
	var/list/datum/component/logistics_interface/found = list()
	for(var/obj/structure/logistics_pipe/pipe as anything in pipes)
		if(pipe.linked_interface)
			found += pipe.linked_interface
			pipe.linked_interface.net = src
	for(var/datum/component/logistics_interface/interface as anything in interfaces)
		if(!(interface in found))
			interface.net = null
	interfaces = found

/datum/logistics_net/proc/refresh_processing()
	for(var/datum/logistics_request/request as anything in requests)
		if(request.status == LOGISTICS_REQUEST_ACTIVE)
			START_PROCESSING(SSprocessing, src)
			return
	STOP_PROCESSING(SSprocessing, src)

/datum/logistics_net/proc/create_request(datum/component/logistics_interface/source, datum/component/logistics_interface/dest, list/wanted_items, mob/user, datum/component/logistics_interface/creator)
	if(!length(wanted_items))
		return null
	var/datum/logistics_request/request = new(src, source, dest, wanted_items)
	request.request_num = next_request_num++
	request.creator_name = logistics_get_creator_name(user)
	if(creator)
		request.creator_interface_ref = WEAKREF(creator)
	if(auto_execute)
		request.status = LOGISTICS_REQUEST_ACTIVE
	else
		request.status = LOGISTICS_REQUEST_PENDING
	requests += request
	add_log("Создан заказ #[request.request_num] ([request.creator_name]).")
	if(request.status == LOGISTICS_REQUEST_ACTIVE)
		request.notify_related("Заказ #[request.request_num] выполняется.")
	refresh_processing()
	return request

/datum/logistics_net/proc/cancel_request(datum/logistics_request/request)
	if(!request || !(request in requests))
		return FALSE
	if(!request.cancel())
		return FALSE
	abort_request_holders(request)
	archive_order(request, "отменён")
	add_log("Заказ #[request.request_num] отменён.")
	request.notify_related("Заказ #[request.request_num] отменён.")
	requests -= request
	qdel(request)
	refresh_processing()
	return TRUE

/datum/logistics_net/proc/abort_request_holders(datum/logistics_request/request)
	if(!request)
		return
	for(var/obj/structure/logistics_holder/holder as anything in in_flight.Copy())
		if(holder.request_ref?.resolve() != request)
			continue
		holder.abort_shipment()
	for(var/stock_name in request.reserved)
		var/amount = request.reserved[stock_name]
		if(amount > 0)
			request.release_reservation(stock_name, amount)

/datum/logistics_net/proc/pause_request(datum/logistics_request/request)
	if(!request || !(request in requests))
		return FALSE
	if(request.pause())
		add_log("Заказ #[request.request_num] приостановлен.")
		request.notify_related("Заказ #[request.request_num] приостановлен.")
		refresh_processing()
		return TRUE
	return FALSE

/datum/logistics_net/proc/execute_request(datum/logistics_request/request)
	if(!request || !(request in requests))
		return FALSE
	if(request.execute())
		add_log("Заказ #[request.request_num] выполняется.")
		request.notify_related("Заказ #[request.request_num] выполняется.")
		refresh_processing()
		return TRUE
	return FALSE

/datum/logistics_net/proc/unpause_request(datum/logistics_request/request)
	return execute_request(request)

/datum/logistics_net/proc/move_request(datum/logistics_request/request, direction)
	if(!request || !(request in requests))
		return FALSE
	var/index = requests.Find(request)
	if(!index)
		return FALSE
	var/new_index = index + direction
	if(new_index < 1 || new_index > length(requests))
		return FALSE
	requests.Swap(index, new_index)
	return TRUE

/datum/logistics_net/process()
	if(!length(requests))
		return PROCESS_KILL
	if(world.time < next_dispatch_at)
		return
	var/packets_sent = 0
	var/list/claimed = list()
	var/has_active = FALSE
	for(var/datum/logistics_request/request as anything in requests.Copy())
		if(QDELETED(request) || request.status != LOGISTICS_REQUEST_ACTIVE)
			continue
		has_active = TRUE
		packets_sent += try_fulfill(request, claimed)
		try_complete_request(request)
		if(packets_sent > 0)
			break
	if(!has_active)
		return PROCESS_KILL
	next_dispatch_at = world.time + LOGISTICS_SHIPMENT_INTERVAL
	if(!length(requests))
		return PROCESS_KILL

/datum/logistics_net/proc/try_complete_request(datum/logistics_request/request)
	if(QDELETED(request) || !(request in requests))
		return FALSE
	if(request.status != LOGISTICS_REQUEST_ACTIVE)
		return FALSE
	if(!request.is_finished())
		return FALSE
	request.status = LOGISTICS_REQUEST_COMPLETE
	archive_order(request, "выполнен")
	requests -= request
	add_log("Заказ #[request.request_num] выполнен ([request.format_delivered_text()]).")
	request.notify_related("Заказ #[request.request_num] выполнен. Доставлено: [request.format_delivered_text()].")
	qdel(request)
	refresh_processing()
	return TRUE

/datum/logistics_net/proc/try_fulfill(datum/logistics_request/request, list/claimed)
	. = 0
	if(length(in_flight) >= LOGISTICS_MAX_IN_FLIGHT)
		return
	var/datum/component/logistics_interface/dest = request.get_dest()
	if(request.dest_ref && QDELETED(dest))
		cancel_request(request)
		return
	if(!dest || dest.net != src)
		return

	var/list/datum/component/logistics_interface/candidate_sources = list()
	for(var/stock_name in request.wanted)
		if(request.wanted[stock_name] <= 0)
			continue
		for(var/datum/component/logistics_interface/source as anything in get_sources_for(request, stock_name, dest))
			candidate_sources |= source

	for(var/datum/component/logistics_interface/source as anything in candidate_sources)
		if(length(in_flight) >= LOGISTICS_MAX_IN_FLIGHT)
			return
		if(dispatch_shipment_batch(request, source, dest, claimed))
			return 1

/datum/logistics_net/proc/dispatch_shipment_batch(datum/logistics_request/request, datum/component/logistics_interface/source, datum/component/logistics_interface/dest, list/claimed)
	if(!source || !dest || !request)
		return FALSE
	var/obj/structure/logistics_pipe/start = source.linked_pipe
	var/obj/structure/logistics_pipe/goal = dest.linked_pipe
	if(!start || !goal)
		return FALSE

	var/remaining_capacity = LOGISTICS_MAX_SHIPMENT_ITEMS
	var/list/packed = list()
	var/total_packed = 0

	for(var/stock_name in request.wanted)
		if(remaining_capacity <= 0)
			break
		if(request.wanted[stock_name] <= 0)
			continue
		var/available = source.get_available_amount(stock_name)
		var/claim_key = "[source.UID()]|[stock_name]"
		available -= claimed[claim_key]
		if(available <= 0)
			continue
		if(!dest.adapter.can_accept_stock(stock_name))
			continue
		var/send_amount = min(request.wanted[stock_name], available, remaining_capacity)
		var/accept_cap = dest.adapter.get_accept_capacity(stock_name)
		if(dest.adapter.uses_shared_unit_capacity())
			accept_cap = min(accept_cap, dest.adapter.get_free_sheets() - total_packed)
		send_amount = min(send_amount, accept_cap)
		if(send_amount <= 0)
			continue
		packed[stock_name] = send_amount
		remaining_capacity -= send_amount
		total_packed += send_amount

	if(!total_packed)
		return FALSE

	var/local_transfer = (start == goal)
	var/list/path_dirs
	if(!local_transfer)
		path_dirs = logistics_build_path(start, goal)
		if(isnull(path_dirs))
			return FALSE

	var/atom/holder_loc = local_transfer ? source.parent : start
	var/obj/structure/logistics_holder/holder = new(holder_loc)
	holder.dest_interface = dest
	holder.origin_net = src
	holder.request_num = request.request_num
	holder.request_ref = WEAKREF(request)

	for(var/stock_name in packed)
		var/want = packed[stock_name]
		var/extracted = source.extract_into(stock_name, want, holder)
		if(extracted <= 0)
			packed -= stock_name
			continue
		if(extracted < want)
			packed[stock_name] = extracted
		var/claim_key = "[source.UID()]|[stock_name]"
		claimed[claim_key] += extracted
		request.reserve(stock_name, extracted)
		holder.shipment_manifest[stock_name] += extracted

	if(!length(holder.contents) && !length(holder.shipment_manifest))
		qdel(holder)
		return FALSE

	source.play_send_sound()
	var/list/manifest_parts = list()
	for(var/stock_name in holder.shipment_manifest)
		manifest_parts += "[holder.shipment_manifest[stock_name]] x [logistics_stock_display_name(stock_name)]"
	var/manifest_text = manifest_parts.Join(", ")

	if(local_transfer)
		holder.deliver(dest)
		add_log("Заказ #[request.request_num]: локальная передача [manifest_text]: [source.interface_name] -> [dest.interface_name].")
		return TRUE

	holder.path_dirs = path_dirs
	in_flight += holder
	holder.start_moving()
	add_log("Заказ #[request.request_num]: отправка [manifest_text]: [source.interface_name] -> [dest.interface_name].")
	return TRUE

/datum/logistics_net/proc/get_sources_for(datum/logistics_request/request, stock_name, datum/component/logistics_interface/dest)
	. = list()
	var/datum/component/logistics_interface/forced = request.get_source()
	if(request.source_ref)
		if(forced && forced.can_export(stock_name) && forced != dest)
			. += forced
		return
	var/list/primary = list()
	var/list/fallback = list()
	for(var/datum/component/logistics_interface/interface as anything in interfaces)
		if(interface == dest)
			continue
		if(!interface.can_export(stock_name))
			continue
		if(interface.mode == LOGISTICS_MODE_SEND)
			primary += interface
		else
			fallback += interface
	. = primary + fallback

/proc/logistics_get_creator_name(mob/user)
	if(!user)
		return "Неизвестный"
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		return human_user.get_visible_name()
	if(isobserver(user))
		return "Неизвестный"
	return user.name || "Неизвестный"

/proc/logistics_build_path(obj/structure/logistics_pipe/start, obj/structure/logistics_pipe/goal)
	if(!start || !goal)
		return null
	if(start == goal)
		return list()
	var/list/queue = list(start)
	var/list/came_from = list()
	var/list/came_dir = list()
	came_from[start] = start
	var/idx = 1
	while(idx <= length(queue))
		var/obj/structure/logistics_pipe/current = queue[idx++]
		if(current == goal)
			break
		for(var/dir_iter in GLOB.cardinal)
			if(!(current.dpdir & dir_iter))
				continue
			var/turf/next_turf = get_step(current, dir_iter)
			if(!next_turf)
				continue
			for(var/obj/structure/logistics_pipe/next in next_turf)
				if(!(next.dpdir & REVERSE_DIR(dir_iter)))
					continue
				if(came_from[next])
					continue
				came_from[next] = current
				came_dir[next] = dir_iter
				queue += next
	if(start != goal && !came_from[goal])
		return null
	var/list/dirs = list()
	var/obj/structure/logistics_pipe/walk = goal
	while(walk != start)
		if(!came_dir[walk])
			return null
		dirs += came_dir[walk]
		walk = came_from[walk]
	for(var/i in 1 to round(length(dirs) / 2))
		dirs.Swap(i, length(dirs) - i + 1)
	return dirs
