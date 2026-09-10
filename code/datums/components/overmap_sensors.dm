/datum/component/overmap_sensors
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/list/contact_memory

	var/list/peel_hit_times
	var/next_peel_at = 0
	var/peel_timer
	var/short_peel_timer

	var/list/short_identified

	var/list/peel_peak

/datum/component/overmap_sensors/Initialize()
	if(!istype(parent, /obj/overmap/entity))
		return COMPONENT_INCOMPATIBLE

/datum/component/overmap_sensors/RegisterWithParent()
	var/obj/overmap/entity/token = parent
	token.sensor_pack = src

/datum/component/overmap_sensors/UnregisterFromParent()
	if(peel_timer)
		deltimer(peel_timer)
		peel_timer = null
	if(short_peel_timer)
		deltimer(short_peel_timer)
		short_peel_timer = null
	var/obj/overmap/entity/token = parent
	if(token.sensor_pack == src)
		token.sensor_pack = null

/datum/component/overmap_sensors/Destroy(force)
	if(peel_timer)
		deltimer(peel_timer)
		peel_timer = null
	if(short_peel_timer)
		deltimer(short_peel_timer)
		short_peel_timer = null
	return ..()

/datum/component/overmap_sensors/proc/has_working_sensor(kind)
	var/obj/overmap/entity/vessel = parent
	for(var/obj/machinery/sensor_array/array as anything in vessel.sensor_arrays)
		if(array.sensor_kind == kind && array.is_ready())
			return TRUE
	return FALSE

/datum/component/overmap_sensors/proc/sensor_ping_active()
	var/obj/overmap/entity/vessel = parent
	return vessel.sensor_ping_until && world.time < vessel.sensor_ping_until

/datum/component/overmap_sensors/proc/signal_view_range()
	var/obj/overmap/entity/vessel = parent
	var/turf/here = vessel.get_overmap_turf()
	if(!here || !vessel.sector)
		return 0
	. = 0
	for(var/obj/overmap/other as anything in vessel.sector.objects)
		if(!always_sees(other) || other == vessel)
			continue
		var/turf/there = other.get_overmap_turf()
		if(!there || there.z != here.z)
			continue
		. = max(., max(abs(here.x - there.x), abs(here.y - there.y)))

/datum/component/overmap_sensors/proc/sensor_journal_range()
	var/obj/overmap/entity/vessel = parent
	. = 0
	if(has_working_sensor(OVERMAP_SENSOR_KIND_LONG) && vessel.long_sensors_on)
		. = max(., OVERMAP_SENSOR_LONG_VIEW)
	if(has_working_sensor(OVERMAP_SENSOR_KIND_SHORT) && vessel.short_sensors_on)
		. = max(., OVERMAP_SENSOR_SHORT_VIEW)
	. = max(., signal_view_range())

/datum/component/overmap_sensors/proc/can_receive_sensor_log()
	var/obj/overmap/entity/vessel = parent
	return (has_working_sensor(OVERMAP_SENSOR_KIND_LONG) && vessel.long_sensors_on) || (has_working_sensor(OVERMAP_SENSOR_KIND_SHORT) && vessel.short_sensors_on)

/proc/sensor_journal_tone(kind)
	switch(kind)
		if("distress", "scanned_by", "dock_fail")
			return "bad"
		if("recall", "undock", "iff_lost")
			return "warn"
		if("dock", "appear")
			return "good"
		if("iff", "ping", "scan")
			return "iff"
	return "info"

/datum/component/overmap_sensors/proc/add_sensor_journal(message, kind = "info", turf/spot, display_name, tone, note)
	var/obj/overmap/entity/vessel = parent
	if(!vessel.sensor_journal)
		vessel.sensor_journal = list()
	if(!spot)
		spot = vessel.get_overmap_turf()
	if(isnull(tone))
		tone = sensor_journal_tone(kind)
	vessel.sensor_journal += list(list(
		"time" = station_time_timestamp(),
		"text" = message,
		"kind" = kind,
		"x" = vessel.sector && spot ? vessel.sector.coord_x(spot) : spot?.x,
		"y" = vessel.sector && spot ? vessel.sector.coord_y(spot) : spot?.y,
		"name" = display_name,
		"tone" = tone,
		"note" = note,
	))
	if(length(vessel.sensor_journal) > OVERMAP_SENSOR_LOG_MAX)
		vessel.sensor_journal.Cut(1, length(vessel.sensor_journal) - OVERMAP_SENSOR_LOG_MAX + 1)
	for(var/obj/machinery/computer/sensors/console as anything in vessel.sensors)
		if(!QDELETED(console))
			console.play_sensor_alert(kind)
			SStgui.update_uis(console)

/proc/overmap_euclid_dist(atom/a, atom/b)
	if(!a || !b)
		return INFINITY
	return sqrt((a.x - b.x) ** 2 + (a.y - b.y) ** 2)

/proc/overmap_in_sensor_circle(atom/a, atom/b, range)
	if(!a || !b || a.z != b.z)
		return FALSE
	var/dx = a.x - b.x
	var/dy = a.y - b.y
	return (dx * dx + dy * dy) <= (range * (range + 1))

/datum/component/overmap_sensors/proc/always_sees(obj/overmap/other)
	var/obj/overmap/entity/vessel = parent
	if(!other || QDELETED(other))
		return FALSE
	if(other == vessel)
		return TRUE
	if(other.visible_without_scanner)
		return TRUE
	var/obj/overmap/entity/contact = other
	if(istype(contact) && contact.identity_distress)
		return TRUE
	if(vessel.iff_detects(other))
		return TRUE
	if(short_knows(other))
		return TRUE
	return FALSE

/datum/component/overmap_sensors/proc/sees_foreign_peel(obj/overmap/other)
	var/obj/overmap/entity/vessel = parent
	var/obj/overmap/entity/contact = other
	if(!istype(contact) || contact == vessel)
		return FALSE
	if(!contact.is_sensor_peeling())
		return FALSE
	var/turf/here = vessel.get_overmap_turf()
	var/turf/there = contact.get_overmap_turf()
	if(!here || !there)
		return FALSE
	return overmap_in_sensor_circle(here, there, OVERMAP_SENSOR_LONG_VIEW)

/datum/component/overmap_sensors/proc/sees_any_foreign_peel()
	var/obj/overmap/entity/vessel = parent
	if(!vessel.sector)
		return FALSE
	for(var/obj/overmap/other as anything in vessel.sector.objects)
		if(sees_foreign_peel(other))
			return TRUE
	return FALSE

/datum/component/overmap_sensors/proc/in_long_peel_range(obj/overmap/other)
	var/obj/overmap/entity/vessel = parent
	if(!has_working_sensor(OVERMAP_SENSOR_KIND_LONG) || !vessel.long_sensors_on)
		return FALSE
	if(!isturf(other.loc))
		return FALSE
	var/turf/here = vessel.get_overmap_turf()
	var/turf/there = other.get_overmap_turf()
	if(!here || !there)
		return FALSE
	if(!overmap_in_sensor_circle(here, there, OVERMAP_SENSOR_LONG_VIEW))
		return FALSE
	var/obj/overmap/entity/contact = other
	if(istype(contact) && !contact.is_long_range_detectable())
		return FALSE
	return TRUE

/datum/component/overmap_sensors/proc/peel_cycle_len()
	return OVERMAP_SENSOR_PEEL_IN + OVERMAP_SENSOR_PEEL_HOLD + OVERMAP_SENSOR_PEEL_OUT

/datum/component/overmap_sensors/proc/peel_active(obj/overmap/other)
	if(!other || !peel_hit_times)
		return FALSE
	var/hit = peel_hit_times[other.UID()]
	if(!hit)
		return FALSE
	return (world.time - hit) < peel_cycle_len()

/datum/component/overmap_sensors/proc/peel_alpha(obj/overmap/other)
	if(!other)
		return 0
	if(!peel_hit_times)
		return 0
	var/hit = peel_hit_times[other.UID()]
	if(!hit)
		return 0
	var/elapsed = world.time - hit
	if(elapsed < 0)
		return 0
	var/peak = peel_peak?[other.UID()] || 255
	var/frac = 0
	if(elapsed < OVERMAP_SENSOR_PEEL_IN)
		frac = elapsed / OVERMAP_SENSOR_PEEL_IN
	else if(elapsed < OVERMAP_SENSOR_PEEL_IN + OVERMAP_SENSOR_PEEL_HOLD)
		frac = 1
	else
		var/fade_t = elapsed - OVERMAP_SENSOR_PEEL_IN - OVERMAP_SENSOR_PEEL_HOLD
		if(fade_t >= OVERMAP_SENSOR_PEEL_OUT)
			return 0
		frac = 1 - (fade_t / OVERMAP_SENSOR_PEEL_OUT)
	return round(peak * frac)

/datum/component/overmap_sensors/proc/contact_map_alpha(obj/overmap/other)
	if(always_sees(other) || sees_foreign_peel(other))
		return 255
	return peel_alpha(other)

/datum/component/overmap_sensors/proc/contact_is_steady(obj/overmap/other)
	return always_sees(other) || sees_foreign_peel(other)

/datum/component/overmap_sensors/proc/in_short_view(obj/overmap/other)
	var/obj/overmap/entity/vessel = parent
	if(!has_working_sensor(OVERMAP_SENSOR_KIND_SHORT) || !vessel.short_sensors_on)
		return FALSE
	if(!isturf(other.loc))
		return FALSE
	var/turf/here = vessel.get_overmap_turf()
	var/turf/there = other.get_overmap_turf()
	if(!here || !there || here.z != there.z)
		return FALSE
	return max(abs(here.x - there.x), abs(here.y - there.y)) <= OVERMAP_SENSOR_SHORT_VIEW

/datum/component/overmap_sensors/proc/can_short_scan(obj/overmap/other)
	var/obj/overmap/entity/vessel = parent
	if(!other || other == vessel || !in_short_view(other))
		return FALSE
	var/turf/here = vessel.get_overmap_turf()
	var/turf/there = other.get_overmap_turf()
	return max(abs(here.x - there.x), abs(here.y - there.y)) <= OVERMAP_SENSOR_SHORT_VIEW

/datum/component/overmap_sensors/proc/short_knows(obj/overmap/other)
	return !!(short_identified?[other.UID()])

/datum/component/overmap_sensors/proc/display_identified(obj/overmap/other, short_console = FALSE)
	var/obj/overmap/entity/vessel = parent
	if(!other)
		return FALSE
	if(other == vessel)
		return TRUE
	if(short_knows(other))
		return TRUE
	if(other.visible_without_scanner)
		return TRUE
	var/obj/overmap/entity/contact = other
	if(istype(contact) && contact.identity_distress)
		return TRUE
	if(vessel.iff_detects(other))
		return TRUE
	return FALSE

/datum/component/overmap_sensors/proc/identify_short(obj/overmap/other)
	if(!other)
		return
	if(!short_identified)
		short_identified = list()
	short_identified[other.UID()] = TRUE
	refresh_sensor_displays()

/datum/component/overmap_sensors/proc/export_short_dump()
	. = list()
	if(!short_identified)
		return
	for(var/uid in short_identified)
		. += uid

/datum/component/overmap_sensors/proc/import_short_dump(list/uids, source_name)
	if(!length(uids))
		return 0
	if(!short_identified)
		short_identified = list()
	var/added = 0
	for(var/uid in uids)
		var/datum/found = locateUID(uid)
		if(!istype(found, /obj/overmap) || QDELETED(found))
			continue
		if(short_identified[uid])
			continue
		short_identified[uid] = TRUE
		added++
	if(added)
		add_sensor_journal(
			"Импорт дампа: +[added] контакт[added == 1 ? "" : "ов"][source_name ? " ([source_name])" : ""]",
			"scan",
			null,
			source_name,
		)
		refresh_sensor_displays()
	return added

/datum/component/overmap_sensors/proc/senses_object(obj/overmap/other)
	if(!other || QDELETED(other))
		return FALSE
	if(always_sees(other))
		return TRUE
	if(sees_foreign_peel(other))
		return TRUE
	if(!isturf(other.loc))
		return FALSE
	return peel_active(other)

/datum/component/overmap_sensors/proc/contact_identified(obj/overmap/other)
	var/obj/overmap/entity/vessel = parent
	if(other == vessel)
		return TRUE
	if(other.visible_without_scanner)
		return TRUE
	var/obj/overmap/entity/contact = other
	if(istype(contact) && contact.identity_distress)
		return TRUE
	if(vessel.iff_detects(other))
		return TRUE
	if(short_knows(other))
		return TRUE
	return FALSE

/datum/component/overmap_sensors/proc/sync_peel_sound()
	var/obj/overmap/entity/vessel = parent
	for(var/obj/machinery/computer/sensors/console as anything in vessel.sensors)
		if(!QDELETED(console))
			console.sync_peel_loop()

/datum/component/overmap_sensors/proc/set_long_sensors(enabled)
	var/obj/overmap/entity/vessel = parent
	if(enabled && !has_working_sensor(OVERMAP_SENSOR_KIND_LONG))
		return FALSE
	vessel.long_sensors_on = enabled
	if(enabled)
		emit_sensor_peel()
	else if(peel_timer)
		deltimer(peel_timer)
		peel_timer = null
	sync_sensor_array_power()
	sync_peel_sound()
	refresh_sensor_blips()
	for(var/obj/machinery/computer/sensors/console as anything in vessel.sensors)
		if(!QDELETED(console))
			SStgui.update_uis(console)
	for(var/obj/machinery/computer/helm/helm as anything in vessel.helms)
		if(!QDELETED(helm))
			SStgui.update_uis(helm)
	return TRUE

/datum/component/overmap_sensors/proc/set_short_sensors(enabled)
	var/obj/overmap/entity/vessel = parent
	if(enabled && !has_working_sensor(OVERMAP_SENSOR_KIND_SHORT))
		return FALSE
	vessel.short_sensors_on = enabled
	if(enabled)
		emit_short_peel()
	else if(short_peel_timer)
		deltimer(short_peel_timer)
		short_peel_timer = null
	sync_sensor_array_power()
	refresh_sensor_blips()
	for(var/obj/machinery/computer/sensors/console as anything in vessel.sensors)
		if(!QDELETED(console))
			SStgui.update_uis(console)
	for(var/obj/machinery/computer/helm/helm as anything in vessel.helms)
		if(!QDELETED(helm))
			SStgui.update_uis(helm)
	return TRUE

/datum/component/overmap_sensors/proc/start_sensor_ping()
	return FALSE

/datum/component/overmap_sensors/proc/sync_sensor_array_power()
	var/obj/overmap/entity/vessel = parent
	for(var/obj/machinery/sensor_array/array as anything in vessel.sensor_arrays)
		array.update_sensor_power()

/datum/component/overmap_sensors/proc/refresh_sensor_displays()
	var/obj/overmap/entity/vessel = parent
	SEND_SIGNAL(vessel, COMSIG_OVERMAP_DISPLAY_CHANGED)

/datum/component/overmap_sensors/proc/refresh_sensor_blips()
	var/obj/overmap/entity/vessel = parent
	for(var/obj/machinery/computer/helm/helm as anything in vessel.helms)
		if(QDELETED(helm) || helm.helm_tab == "dock")
			continue
		helm.update_sensor_ghosts(FALSE)
	for(var/obj/machinery/computer/sensors/console as anything in vessel.sensors)
		if(QDELETED(console) || console.scanning)
			continue
		console.update_contact_blips()

/datum/component/overmap_sensors/proc/emit_sensor_peel()
	var/obj/overmap/entity/vessel = parent
	if(QDELETED(vessel) || !vessel.long_sensors_on || !has_working_sensor(OVERMAP_SENSOR_KIND_LONG))
		if(peel_timer)
			deltimer(peel_timer)
			peel_timer = null
		return
	next_peel_at = world.time + OVERMAP_SENSOR_PEEL_INTERVAL
	vessel.sensor_peel_at = world.time
	if(!peel_hit_times)
		peel_hit_times = list()
	refresh_sensor_blips()
	for(var/obj/machinery/computer/helm/helm as anything in vessel.helms)
		if(!QDELETED(helm) && length(helm.viewers))
			helm.play_inspect_radar(vessel)
	var/turf/here = vessel.get_overmap_turf()
	if(here && vessel.sector)
		for(var/obj/overmap/other as anything in vessel.sector.objects)
			if(!other || QDELETED(other) || other == vessel)
				continue
			if(always_sees(other))
				continue
			if(!in_long_peel_range(other))
				continue
			var/turf/there = other.get_overmap_turf()
			if(!there)
				continue
			var/delay = max(OVERMAP_SENSOR_TIME_DELAY * overmap_euclid_dist(here, there), 1)
			addtimer(CALLBACK(src, PROC_REF(peel_hit), other, 255), delay)
	peel_timer = addtimer(CALLBACK(src, PROC_REF(emit_sensor_peel)), OVERMAP_SENSOR_PEEL_INTERVAL, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)

/datum/component/overmap_sensors/proc/emit_short_peel()
	var/obj/overmap/entity/vessel = parent
	if(QDELETED(vessel) || !vessel.short_sensors_on || !has_working_sensor(OVERMAP_SENSOR_KIND_SHORT))
		if(short_peel_timer)
			deltimer(short_peel_timer)
			short_peel_timer = null
		return
	vessel.short_peel_at = world.time
	if(!peel_hit_times)
		peel_hit_times = list()
	refresh_sensor_blips()
	var/turf/here = vessel.get_overmap_turf()
	if(here && vessel.sector)
		for(var/obj/overmap/other as anything in vessel.sector.objects)
			if(!other || QDELETED(other) || other == vessel)
				continue
			if(always_sees(other))
				continue
			if(!in_short_view(other))
				continue
			var/turf/there = other.get_overmap_turf()
			if(!there)
				continue
			var/dist = max(abs(here.x - there.x), abs(here.y - there.y))
			var/peak = dist <= OVERMAP_SENSOR_PING_RANGE ? 255 : OVERMAP_SENSOR_PEEL_FAR_ALPHA
			var/delay = max(OVERMAP_SENSOR_TIME_DELAY * overmap_euclid_dist(here, there), 1)
			addtimer(CALLBACK(src, PROC_REF(peel_hit), other, peak), delay)
	short_peel_timer = addtimer(CALLBACK(src, PROC_REF(emit_short_peel)), OVERMAP_SENSOR_PEEL_INTERVAL, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)

/datum/component/overmap_sensors/proc/animate_contact_peel(obj/overmap/other, peak_alpha = 255)
	if(!other)
		return
	var/uid = other.UID()
	var/obj/overmap/entity/vessel = parent
	for(var/obj/machinery/computer/helm/helm as anything in vessel.helms)
		if(QDELETED(helm))
			continue
		for(var/atom/movable/screen/overmap_sensor_blip/blip as anything in helm.sensor_blips)
			if(blip.contact_uid == uid)
				overmap_play_peel_blip(blip, peak_alpha)
		helm.animate_inspect_peel(other, peak_alpha)
	for(var/obj/machinery/computer/sensors/console as anything in vessel.sensors)
		if(QDELETED(console))
			continue
		for(var/atom/movable/screen/overmap_sensor_blip/blip as anything in console.contact_blips)
			if(blip.contact_uid == uid)
				overmap_play_peel_blip(blip, peak_alpha)

/datum/component/overmap_sensors/proc/peel_hit(obj/overmap/other, peak_alpha = 255)
	if(QDELETED(src) || QDELETED(other))
		return
	if(!peel_hit_times)
		peel_hit_times = list()
	if(!peel_peak)
		peel_peak = list()
	peel_hit_times[other.UID()] = world.time
	peel_peak[other.UID()] = peak_alpha
	remember_contact(other)
	refresh_sensor_blips()
	animate_contact_peel(other, peak_alpha)

/datum/component/overmap_sensors/proc/prune_peel_hits()
	if(!peel_hit_times)
		return
	for(var/uid in peel_hit_times.Copy())
		var/hit = peel_hit_times[uid]
		if((world.time - hit) < peel_cycle_len())
			continue
		peel_hit_times -= uid
		peel_peak -= uid

/datum/component/overmap_sensors/proc/process_sensors()
	var/obj/overmap/entity/vessel = parent
	prune_peel_hits()
	if(vessel.long_sensors_on || vessel.short_sensors_on || sees_any_foreign_peel() || length(peel_hit_times) || vessel.is_sensor_peeling())
		refresh_sensor_blips()
	expire_contact_memory()
	track_sensor_contacts()

/datum/component/overmap_sensors/proc/journal_coords(turf/spot)
	if(!spot)
		return ""
	var/obj/overmap/entity/vessel = parent
	if(vessel?.sector)
		return "\[[vessel.sector.coord_x(spot)]:[vessel.sector.coord_y(spot)]\]"
	return "\[[spot.x]:[spot.y]\]"

/datum/component/overmap_sensors/proc/remember_contact(obj/overmap/other)
	if(!other || other.hidden_from_contacts)
		return
	var/uid = other.UID()
	var/display = display_identified(other) ? other.get_overmap_display_name() : OVERMAP_UNKNOWN_NAME
	if(!contact_memory)
		contact_memory = list()
	var/list/prev = contact_memory[uid]
	var/fresh = !prev || world.time > prev["remember_until"]
	contact_memory[uid] = list(
		"remember_until" = world.time + OVERMAP_SENSOR_MEMORY_TIME,
		"name" = display,
		"sensed" = TRUE,
	)
	if(fresh)
		add_sensor_journal("Контакт: [display] [journal_coords(other.get_overmap_turf())]", "appear", other.get_overmap_turf(), display)

/datum/component/overmap_sensors/proc/expire_contact_memory()
	if(!contact_memory)
		return
	for(var/uid in contact_memory)
		var/list/prev = contact_memory[uid]
		if(world.time <= prev["remember_until"])
			continue
		var/datum/found = locateUID(uid)
		if(istype(found, /obj/overmap) && always_sees(found))
			prev["remember_until"] = world.time + OVERMAP_SENSOR_MEMORY_TIME
			continue
		add_sensor_journal("Потерян контакт: [prev["name"] || OVERMAP_UNKNOWN_NAME]", "disappear", null, prev["name"])
		contact_memory -= uid

/datum/component/overmap_sensors/proc/track_sensor_contacts(from_ping = FALSE)
	var/obj/overmap/entity/vessel = parent
	if(!can_receive_sensor_log() || !vessel.sector)
		return
	var/turf/here = vessel.get_overmap_turf()
	if(!here)
		return
	if(!contact_memory)
		contact_memory = list()
	for(var/obj/overmap/other as anything in vessel.sector.objects)
		if(!other || QDELETED(other) || other == vessel || other.hidden_from_contacts)
			continue
		var/turf/there = other.get_overmap_turf()
		if(!there || there.z != here.z)
			continue
		if(!always_sees(other) && !sees_foreign_peel(other))
			continue
		var/uid = other.UID()
		var/identified = display_identified(other)
		var/nested = !isturf(other.loc)
		var/obj/overmap/holder = other.loc
		var/host_name = istype(holder) ? holder.name : null
		var/obj/overmap/entity/contact = other
		var/distress = istype(contact) && contact.identity_distress
		var/display = identified ? other.get_overmap_display_name() : OVERMAP_UNKNOWN_NAME
		var/list/prev = contact_memory[uid]
		if(!prev)
			contact_memory[uid] = list(
				"remember_until" = world.time + OVERMAP_SENSOR_MEMORY_TIME,
				"sensed" = TRUE,
				"identified" = identified,
				"name" = display,
				"nested" = nested,
				"host" = host_name,
				"distress" = distress,
			)
			add_sensor_journal("Контакт: [display] [journal_coords(there)]", "appear", there, display)
			continue
		if(prev["nested"] && !nested)
			add_sensor_journal("Отстыковка: [display] от [prev["host"] || "дока"] [journal_coords(there)]", "undock", there, display)
		if(!prev["nested"] && nested)
			add_sensor_journal("Стыковка: [display] → [host_name || "док"] [journal_coords(there)]", "dock", there, display)
		if(!prev["identified"] && identified)
			add_sensor_journal("Сигнал транспондера: [prev["name"] || OVERMAP_UNKNOWN_NAME] → [display] [journal_coords(there)]", "iff", there, display)
		if(prev["identified"] && !identified)
			add_sensor_journal("Потерян сигнал транспондера: [prev["name"] || display] [journal_coords(there)]", "iff_lost", there, prev["name"] || display)
		if(!prev["distress"] && distress)
			add_sensor_journal("Сигнал бедствия: [display] [journal_coords(there)]", "distress", there, display, "bad")
		prev["remember_until"] = world.time + OVERMAP_SENSOR_MEMORY_TIME
		prev["identified"] = identified
		prev["name"] = display
		prev["nested"] = nested
		prev["host"] = host_name
		prev["distress"] = distress

/datum/component/overmap_sensors/proc/is_long_range_detectable()
	var/obj/overmap/entity/vessel = parent
	if(!isturf(vessel.loc))
		return FALSE
	if(vessel.vessel_mass > OVERMAP_SENSOR_STEALTH_MASS_HEAVY)
		return TRUE
	var/displayed_speed = OVERMAP_DISPLAY_SPEED(vessel.get_speed())
	if(vessel.vessel_mass > OVERMAP_SENSOR_STEALTH_MASS_MED)
		return displayed_speed >= OVERMAP_SENSOR_STEALTH_SPEED_MED
	return displayed_speed >= OVERMAP_SENSOR_STEALTH_SPEED_SMALL

/obj/overmap/entity/proc/register_sensor(obj/machinery/computer/sensors/sensor)
	sensors |= sensor
	sensor.vessel = src

/obj/overmap/entity/proc/unregister_sensor(obj/machinery/computer/sensors/sensor)
	sensors -= sensor
	if(sensor.vessel == src)
		sensor.vessel = null

/obj/overmap/entity/proc/register_sensor_array(obj/machinery/sensor_array/array)
	sensor_arrays |= array
	array.vessel = src
	sensor_pack?.sync_sensor_array_power()

/obj/overmap/entity/proc/unregister_sensor_array(obj/machinery/sensor_array/array)
	sensor_arrays -= array
	if(array.vessel == src)
		array.vessel = null
	if(!has_working_sensor(OVERMAP_SENSOR_KIND_LONG))
		long_sensors_on = FALSE
	if(!has_working_sensor(OVERMAP_SENSOR_KIND_SHORT))
		short_sensors_on = FALSE
	sensor_pack?.sync_peel_sound()
	sensor_pack?.sync_sensor_array_power()
	sensor_pack?.refresh_sensor_displays()

/obj/overmap/entity/proc/has_working_sensor(kind)
	return sensor_pack?.has_working_sensor(kind)

/obj/overmap/entity/proc/sensor_ping_active()
	return sensor_pack?.sensor_ping_active()

/obj/overmap/entity/proc/signal_view_range()
	return sensor_pack ? sensor_pack.signal_view_range() : 0

/obj/overmap/entity/proc/sensor_journal_range()
	return sensor_pack ? sensor_pack.sensor_journal_range() : 0

/obj/overmap/entity/proc/can_receive_sensor_log()
	return sensor_pack?.can_receive_sensor_log()

/obj/overmap/entity/proc/add_sensor_journal(message, kind, turf/spot, display_name, tone, note)
	sensor_pack?.add_sensor_journal(message, kind, spot, display_name, tone, note)

/obj/overmap/entity/proc/senses_object(obj/overmap/other)
	return sensor_pack?.senses_object(other)

/obj/overmap/entity/proc/contact_map_alpha(obj/overmap/other)
	return sensor_pack ? sensor_pack.contact_map_alpha(other) : 0

/obj/overmap/entity/proc/contact_is_steady(obj/overmap/other)
	return sensor_pack?.contact_is_steady(other)

/obj/overmap/entity/proc/sees_foreign_peel(obj/overmap/other)
	return sensor_pack?.sees_foreign_peel(other)

/obj/overmap/entity/proc/sees_any_foreign_peel()
	return sensor_pack?.sees_any_foreign_peel()

/obj/overmap/entity/proc/is_sensor_peeling()
	if(!sensor_peel_at)
		return FALSE
	return (world.time - sensor_peel_at) <= (OVERMAP_SENSOR_TIME_DELAY * OVERMAP_SENSOR_LONG_VIEW)

/obj/overmap/entity/proc/contact_identified(obj/overmap/other)
	return sensor_pack ? sensor_pack.contact_identified(other) : iff_detects(other)

/obj/overmap/entity/proc/set_long_sensors(enabled)
	return sensor_pack?.set_long_sensors(enabled)

/obj/overmap/entity/proc/set_short_sensors(enabled)
	return sensor_pack?.set_short_sensors(enabled)

/obj/overmap/entity/proc/can_short_scan(obj/overmap/other)
	return sensor_pack?.can_short_scan(other)

/obj/overmap/entity/proc/short_knows(obj/overmap/other)
	return sensor_pack?.short_knows(other)

/obj/overmap/entity/proc/display_identified(obj/overmap/other, short_console = FALSE)
	return sensor_pack?.display_identified(other, short_console)

/obj/overmap/entity/proc/identify_short(obj/overmap/other)
	sensor_pack?.identify_short(other)

/obj/overmap/entity/proc/export_short_dump()
	return sensor_pack?.export_short_dump() || list()

/obj/overmap/entity/proc/import_short_dump(list/uids, source_name)
	return sensor_pack?.import_short_dump(uids, source_name) || 0

/obj/overmap/entity/proc/play_being_scanned()
	if(!shuttle)
		return
	for(var/area/place as anything in shuttle.shuttle_areas)
		for(var/mob/listener in place)
			if(!listener.client)
				continue
			listener.playsound_local(get_turf(listener), OVERMAP_SENSOR_LOOP_SOUND, 40, FALSE)

/obj/overmap/entity/proc/start_sensor_ping()
	return sensor_pack?.start_sensor_ping()

/obj/overmap/entity/proc/sync_sensor_array_power()
	sensor_pack?.sync_sensor_array_power()

/obj/overmap/entity/proc/refresh_sensor_displays()
	sensor_pack?.refresh_sensor_displays()

/obj/overmap/entity/proc/process_sensors()
	sensor_pack?.process_sensors()

/obj/overmap/entity/proc/is_long_range_detectable()
	return sensor_pack?.is_long_range_detectable()
