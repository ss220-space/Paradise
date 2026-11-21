/datum/overmap_sector/proc/spawn_patrols(chance)
	for(var/attempt in 1 to OVERMAP_SECTOR_PATROL_ATTEMPTS)
		if(!prob(chance))
			continue
		var/marders = rand(0, 1)
		var/iltis = rand(0, 2)
		if(!marders && !iltis)
			continue
		if(!SSovermap.ai_controller)
			SSovermap.ai_controller = new
		var/datum/overmap_ai_controller/controller = SSovermap.ai_controller
		try
			var/list/plans = list()
			if(marders)
				plans += list(controller.patrol_ship_plan("Marder", "_maps/map_files/shuttles/eisenwehr/erw_marder.dmm"))
			if(iltis)
				var/list/plan = controller.patrol_ship_plan("Iltis", "_maps/map_files/shuttles/eisenwehr/erw_iltis.dmm")
				for(var/i in 1 to iltis)
					plans += list(plan)
			var/x = rand(OVERMAP_EDGE + 1, size - OVERMAP_EDGE)
			var/y = rand(OVERMAP_EDGE + 1, size - OVERMAP_EDGE)
			controller.spawn_fleet(src, x, y, plans, "syndicate")
		catch(var/exception/error)
			log_world("Overmap: failed to spawn a Syndicate patrol in [id]: [error]")

/datum/overmap_ai_controller/proc/patrol_ship_plan(ship_name, path)
	var/static/list/plans = list()
	if(!plans[path])
		var/datum/map_template/template = new(path, WRAP_FILE(path), ship_name)
		if(!template.width || !template.height)
			qdel(template)
			throw EXCEPTION("Overmap: invalid patrol ship template [path].")
		plans[path] = list("name" = ship_name, "role" = "light", "template" = template)
	return plans[path]

/datum/overmap_ai_controller/proc/spawn_fleet(datum/overmap_sector/sector, x, y, list/plans, faction, group, name_template = OVERMAP_SHIP_NAME_TEMPLATE, radio_silence = FALSE, datum/callback/can_continue)
	if(!length(plans))
		return list()
	if(!length(group))
		group = "[faction]-fleet-[++next_fleet]"
	var/list/created = list()
	try
		for(var/list/plan as anything in plans)
			if(QDELETED(sector) || (can_continue && !can_continue.Invoke()))
				throw EXCEPTION("Создание соединения отменено.")
			var/obj/overmap/entity/virtual_structure/ai/ship = new(null)
			created += ship
			var/datum/map_template/template = plan["template"]
			var/datum/overmap_ai_profile/profile = GLOB.overmap_ai_profiles[plan["role"]]
			var/loaded = template ? ship.load_template(template, TRUE) : ship.build_hull(profile, !plan["unarmed"])
			if(!loaded || !ship.prepare_ai(profile))
				throw EXCEPTION("Не удалось загрузить корпус или подготовить управление кораблём.")
			if(QDELETED(sector) || (can_continue && !can_continue.Invoke()))
				throw EXCEPTION("Создание соединения отменено.")
			var/turf/spot = spawn_position(sector, x, y, ship.hull_radius)
			if(!spot)
				throw EXCEPTION("В секторе нет свободного места для соединения.")
			sector.add_object(ship, spot)
			ship.ship_basename = plan["name"]
			ship.registration_class = plan["ship_class"]
			ship.ship_name_format = name_template
			ship.radio_silence = radio_silence
			ship.ship_ai = new(ship, src, plan["role"], faction, group)
			CHECK_TICK
	catch(var/exception/error)
		QDEL_LIST(created)
		index_until = 0
		throw error
	index_until = 0
	return created

/datum/overmap_ai_controller/proc/spawn_position(datum/overmap_sector/sector, wanted_x, wanted_y, radius)
	var/turf/best
	var/best_score = INFINITY
	var/span = OVERMAP_TILE_SPAN * sector.tile_travel
	var/list/blockers = list()
	for(var/obj/overmap/entity/ship in sector.objects)
		if(!QDELETED(ship) && isturf(ship.loc) && (ship.hull_radius || ship.physical_space))
			blockers += list(list(ship.get_world_x(), ship.get_world_y(), overmap_ai_radius(ship) + radius + 8))
	for(var/ix in OVERMAP_EDGE + 1 to sector.size - OVERMAP_EDGE)
		for(var/iy in OVERMAP_EDGE + 1 to sector.size - OVERMAP_EDGE)
			var/score = (ix - wanted_x) ** 2 + (iy - wanted_y) ** 2
			if(score >= best_score)
				continue
			var/turf/spot = sector.locate_local(ix, iy)
			if(!spot || sector.turf_occupied(spot))
				continue
			var/blocked = FALSE
			for(var/list/circle as anything in blockers)
				if((spot.x * span - circle[1]) ** 2 + (spot.y * span - circle[2]) ** 2 < circle[3] ** 2)
					blocked = TRUE
					break
			if(blocked)
				continue
			if(!score)
				return spot
			best = spot
			best_score = score
	return best
