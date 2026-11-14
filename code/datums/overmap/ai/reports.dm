/datum/overmap_ai_report
	var/sender_uid
	var/contact_uid
	var/contact_visit
	var/sector_id
	var/fleet_key
	var/history_key
	var/signature
	var/event
	var/details
	var/lane
	var/expires_at

/datum/overmap_ai_report/New(datum/overmap_ship_ai/brain, report_event, obj/overmap/entity/contact, report_details)
	sender_uid = brain.owner.UID()
	if(!QDELETED(contact))
		contact_uid = contact.UID()
		contact_visit = contact.sector_visit
	sector_id = brain.owner.sector.id
	fleet_key = brain.controller.diplomacy_key(brain)
	history_key = brain.controller.group_key(brain)
	event = report_event
	details = report_details
	lane = event == "retreat" ? "retreat" : (event in list("lost", "destroyed")) ? "casualty" : "normal"
	var/identity = contact_uid || "none"
	signature = "[event]/[identity]/[contact_visit]"
	if(lane != "casualty")
		signature += "/[details]"
	if(lane == "retreat")
		signature += "/[sender_uid]"
	expires_at = world.time + (5 SECONDS)

/datum/overmap_ship_ai/proc/report(event, obj/overmap/entity/contact, details = "")
	if(QDELETED(owner) || owner.radio_silence || !owner.sector || owner.is_ai_destroyed() || !length(GLOB.overmap_ai_report_phrases[event]))
		return FALSE
	var/datum/overmap_ai_report/message = new(src, event, contact, details)
	var/list/history = controller.fleet_reports[message.history_key]
	if(history?[message.signature] > world.time)
		qdel(message)
		return TRUE
	var/key = "[message.fleet_key]/[message.lane]"
	var/list/pending = controller.fleet_report_queue[key]
	if(!pending)
		pending = list()
		controller.fleet_report_queue[key] = pending
	var/pending_id = "[message.history_key]/[message.signature]"
	if(pending[pending_id])
		qdel(message)
		return TRUE
	pending[pending_id] = message
	return TRUE

/datum/overmap_ship_ai/proc/report_is_current(datum/overmap_ai_report/message)
	if(QDELETED(owner) || owner.radio_silence || owner.is_ai_destroyed() || owner.sector?.id != message.sector_id || controller.diplomacy_key(src) != message.fleet_key)
		return FALSE
	var/obj/overmap/entity/contact = locateUID(message.contact_uid)
	if(message.lane == "casualty")
		return TRUE
	if(message.contact_uid && (QDELETED(contact) || contact.sector_visit != message.contact_visit || contact.sector != owner.sector))
		return FALSE
	switch(message.event)
		if("engage", "fire", "flank", "orbit", "standoff", "search")
			return !QDELETED(contact) && (hostile_to(contact) || is_ordered_target(contact))
		if("cancel")
			return !QDELETED(contact) && !hostile_to(contact) && perceived_faction(contact) != "unknown"
		if("warning")
			return !QDELETED(contact) && !has_retaliation(contact) && !is_fleet_member(contact)
		if("retaliate")
			return !QDELETED(contact) && has_retaliation(contact) && !is_fleet_member(contact)
		if("retreat")
			return state == "flee"
		if("patrol")
			return state == "patrol"
		if("suppress")
			return order?["kind"] == "suppress"
	return TRUE

/datum/overmap_ship_ai/proc/send_report(datum/overmap_ai_report/message)
	if(!report_is_current(message))
		return FALSE
	var/public_report = faction == "neutral" || message.event == "warning"
	var/key = public_report ? null : SSovermap.faction_comms_keys[faction]
	if(!public_report && !key)
		return FALSE
	var/obj/overmap/entity/contact = locateUID(message.contact_uid)
	var/contact_name = "указанный район"
	if(!QDELETED(contact))
		if(perceived_faction(contact) == "unknown" && !owner.iff_detects(contact))
			var/list/identity = contact.traffic_identity()
			contact_name = "неопознанный контакт №[identity["number"]]"
		else
			contact_name = contact.get_overmap_display_name()
	var/body = replacetext(pick(GLOB.overmap_ai_report_phrases[message.event]), "$target$", contact_name)
	body = replacetext(body, "$group$", group)
	if(length(message.details))
		body += " [message.details]"
	body += " Сектор: [owner.sector.name]."
	owner.sector.add_comms_message(new /datum/overmap_sector_message(body, key, owner.get_overmap_display_name(), owner.sector.id))
	var/list/history = controller.fleet_reports[message.history_key]
	if(!history)
		history = list()
		controller.fleet_reports[message.history_key] = history
	history[message.signature] = message.lane == "retreat" ? world.time + (30 SECONDS) : INFINITY
	return TRUE

/datum/overmap_ai_controller/proc/clear_report_queue(key)
	var/list/pending = fleet_report_queue[key]
	QDEL_LIST_ASSOC_VAL(pending)
	fleet_report_queue -= key

/datum/overmap_ai_controller/proc/report_sender(datum/overmap_ai_report/message)
	var/obj/overmap/entity/ship = locateUID(message.sender_uid)
	var/datum/overmap_ship_ai/brain = ship?.ship_ai
	if(brain?.controller == src && brain.report_is_current(message))
		return brain
	if(message.event == "lost")
		for(var/datum/overmap_ship_ai/member as anything in ships)
			if(member.report_is_current(message))
				return member
	return null

/datum/overmap_ai_controller/proc/process_reports()
	for(var/key, record in fleet_report_queue)
		var/list/pending = record
		var/list/eligible = list()
		for(var/id, entry in pending)
			var/datum/overmap_ai_report/message = entry
			var/list/history = fleet_reports[message.history_key]
			if(message.expires_at <= world.time || history?[message.signature] > world.time || !report_sender(message))
				pending -= id
				qdel(message)
			else
				eligible += message
		if(!length(eligible))
			clear_report_queue(key)
			continue
		if(fleet_next_report[key] > world.time)
			continue
		var/datum/overmap_ai_report/message = pick(eligible)
		var/datum/overmap_ship_ai/sender = report_sender(message)
		if(sender?.send_report(message))
			fleet_next_report[key] = world.time + (message.lane == "casualty" ? 10 SECONDS : 30 SECONDS)
			clear_report_queue(key)

/datum/overmap_ship_ai/proc/report_state()
	if(state == "flee")
		report("retreat", target)
		return
	if(state == reported_state)
		return
	var/event
	switch(state)
		if("orbit")
			event = "orbit"
		if("flank")
			event = "flank"
		if("standoff")
			event = "standoff"
		if("search")
			event = "search"
		if("patrol")
			event = "patrol"
	if(event && report(event, target))
		reported_state = state

/datum/overmap_ai_controller/proc/report_loss(obj/overmap/entity/victim)
	var/datum/overmap_ship_ai/brain = victim.ship_ai
	if(brain)
		for(var/datum/overmap_ship_ai/member as anything in ships)
			if(member != brain && !QDELETED(member.owner) && !member.owner.is_ai_destroyed() && member.owner.sector == victim.sector && diplomacy_key(member) == diplomacy_key(brain))
				if(member.report("lost", victim, "Потерян корабль [victim.get_overmap_display_name()]. Корабль выведен из строя."))
					break
	var/obj/overmap/entity/attacker = locateUID(victim.last_attacker_uid)
	var/datum/overmap_ship_ai/killer = attacker?.ship_ai
	if(killer && attacker.sector == victim.sector)
		killer.report("destroyed", victim, "Цель [victim.get_overmap_display_name()] утратила боеспособность. Контроль сектора продолжается.")
