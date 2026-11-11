/datum/overmap_admin_panel/proc/ai_data()
	var/list/result = list("enemy_options" = GLOB.overmap_ai_enemy_options, "default_enemies" = GLOB.overmap_ai_default_enemies, "fleets" = ai_fleet_data(), "targets" = ai_order_targets(), "profiles" = list(), "ships" = list(), "uploads" = list(), "limit" = 32, "feedback" = ai_feedback, "failed" = ai_failed)
	for(var/id, record in GLOB.overmap_ai_profiles)
		var/datum/overmap_ai_profile/profile = record
		result["profiles"] += list(list("id" = id, "name" = profile.name))
	for(var/id, record in ai_uploaded_templates)
		var/datum/map_template/template = record
		result["uploads"] += list(list("id" = id, "kind" = "ai_upload", "name" = template.name, "width" = template.width, "height" = template.height))
	var/datum/overmap_ai_controller/controller = SSovermap?.ai_controller
	if(controller)
		result["limit"] = controller.max_ships
	for(var/datum/overmap_ship_ai/brain as anything in controller?.ships)
		if(QDELETED(brain) || QDELETED(brain.owner))
			continue
		var/obj/overmap/entity/virtual_structure/ai/ship = brain.owner
		var/turf/spot = ship.get_overmap_turf()
		result["ships"] += list(list("id" = ship.UID(), "name" = ship.name, "role" = brain.role, "tactic" = brain.effective_role(), "faction" = brain.faction, "group" = brain.group, "sector" = ship.sector?.name, "x" = spot && ship.sector ? ship.sector.coord_x(spot) : null, "y" = spot && ship.sector ? ship.sector.coord_y(spot) : null, "enabled" = brain.enabled, "ready" = brain.combat_ready(), "destroyed" = ship.ai_destroyed, "hull_loss" = round(ship.ai_destroyed_cells / max(1, ship.ai_hull_cells) * 100, 0.1), "order" = brain.order?["kind"] || "auto", "state" = brain.state, "target" = brain.target_visible ? brain.target?.get_overmap_display_name() : null))
	return result

/datum/overmap_admin_panel/proc/ai_action(action, list/params, mob/user)
	if(!user?.client || !check_rights_for(user.client, R_ADMIN | R_EVENT) || !SSovermap?.initialized)
		return TRUE
	ai_feedback = null
	ai_failed = FALSE
	try
		if(action == "ai_spawn")
			spawn_ai_ships(params, user)
		else if(action == "ai_enemies")
			set_ai_enemies(params, user)
		else if(action == "ai_order")
			issue_ai_order(params, user)
		else if(action == "ai_upload")
			upload_dmm_from_user(user, for_ai = TRUE)
		else
			var/obj/overmap/entity/virtual_structure/ai/ship = locateUID(params["id"])
			if(!istype(ship) || QDELETED(ship) || !ship.ship_ai)
				throw EXCEPTION("ИИ-корабль не найден.")
			var/datum/overmap_ship_ai/brain = ship.ship_ai
			switch(action)
				if("ai_toggle")
					brain.set_enabled(!brain.enabled)
					log_admin("[key_name(user)] set AI control of [ship] to [brain.enabled].")
				if("ai_patrol_here")
					brain.order = null
					brain.home_sector = ship.sector
					brain.home_x = ship.get_world_x()
					brain.home_y = ship.get_world_y()
					brain.goal_x = null
					brain.set_enabled(TRUE)
					log_admin("[key_name(user)] assigned an AI patrol at [ship.sector?.id] to [ship].")
				if("ai_helm")
					brain.set_enabled(FALSE)
					open_admin_helm(ship, user)
				if("ai_delete")
					log_admin("[key_name(user)] deleted AI ship [ship] in [ship.sector?.id].")
					qdel(ship)
	catch(var/exception/error)
		ai_feedback = "[error]"
		ai_failed = TRUE
	return TRUE

/datum/overmap_admin_panel/proc/spawn_ai_ships(list/params, mob/user)
	var/faction = params["faction"]
	var/datum/overmap_sector/sector = SSovermap.sectors[params["sector"]]
	var/list/composition = params["ships"]
	if(!(faction in list("nt", "syndicate", "rogue")) || !sector || !islist(composition) || !length(composition) || length(composition) > 32)
		throw EXCEPTION("Выберите фракцию, сектор и состав соединения от 1 до 32 кораблей.")
	var/list/enemies = validate_ai_enemies(params["enemies"], faction)
	var/list/plans = list()
	for(var/list/entry as anything in composition)
		if(!islist(entry))
			throw EXCEPTION("Некорректный состав соединения.")
		var/datum/overmap_ai_profile/profile = GLOB.overmap_ai_profiles[entry["role"]]
		if(!profile)
			throw EXCEPTION("Выберите роль для каждого корабля.")
		var/datum/map_template/template
		if(entry["template_id"])
			template = entry["template_kind"] == "ai_upload" ? ai_uploaded_templates[entry["template_id"]] : resolve_template(entry["template_id"], entry["template_kind"])
			if(!template || template.width <= 0 || template.height <= 0 || template.width > 64 || template.height > 64)
				throw EXCEPTION("Выберите DMM-шаблон не больше 64×64 для каждого корабля.")
		var/ship_name = istext(entry["name"]) ? trim(strip_html(entry["name"], MAX_NAME_LEN)) : ""
		plans += list(list("role" = entry["role"], "profile" = profile, "template" = template, "name" = ship_name, "unarmed" = !!entry["unarmed"]))
	if(!SSovermap.ai_controller)
		SSovermap.ai_controller = new
	var/datum/overmap_ai_controller/controller = SSovermap.ai_controller
	if(controller.pending_spawns)
		throw EXCEPTION("Дождитесь завершения предыдущего спавна.")
	var/count = length(plans)
	if(length(controller.ships) + count > controller.max_ships)
		throw EXCEPTION("Достигнут предел: [controller.max_ships] ИИ-корабля.")
	var/group = istext(params["group"]) ? trim(strip_html(params["group"], 40)) : ""
	if(!length(group))
		group = "[faction]-fleet-[++controller.next_fleet]"
	var/x = isnum(params["x"]) ? params["x"] : text2num(params["x"])
	var/y = isnum(params["y"]) ? params["y"] : text2num(params["y"])
	x = clamp(round(x || sector.size / 2), OVERMAP_EDGE + 1, sector.size - OVERMAP_EDGE)
	y = clamp(round(y || sector.size / 2), OVERMAP_EDGE + 1, sector.size - OVERMAP_EDGE)
	controller.pending_spawns = count
	var/list/created = list()
	try
		for(var/list/plan as anything in plans)
			if(QDELETED(src) || QDELETED(sector) || !user?.client || !check_rights_for(user.client, R_ADMIN | R_EVENT))
				throw EXCEPTION("Создание соединения отменено.")
			var/obj/overmap/entity/virtual_structure/ai/ship = new(null)
			created += ship
			var/datum/map_template/template = plan["template"]
			var/datum/overmap_ai_profile/profile = plan["profile"]
			var/loaded = template ? ship.load_template(template, TRUE) : ship.build_hull(profile, !plan["unarmed"])
			if(!loaded || length(ship.virtual_weapons) > 16 || !ship.prepare_ai(profile))
				throw EXCEPTION("Не удалось создать корпус; допустимо от 0 до 16 орудий.")
			if(QDELETED(src) || QDELETED(sector) || !user?.client || !check_rights_for(user.client, R_ADMIN | R_EVENT))
				throw EXCEPTION("Создание соединения отменено.")
			var/turf/spot = controller.spawn_position(sector, x, y, ship.hull_radius)
			if(!spot)
				throw EXCEPTION("В секторе нет свободного места для соединения.")
			sector.add_object(ship, spot)
			ship.name = "[plan["name"] || profile.name] [controller.next_slot + 1]"
			ship.ship_ai = new(ship, controller, plan["role"], faction, group)
			CHECK_TICK
	catch(var/exception/error)
		QDEL_LIST(created)
		controller.pending_spawns = 0
		controller.index_until = 0
		throw error
	controller.pending_spawns = 0
	controller.index_until = 0
	selected = created[length(created)]
	var/obj/overmap/entity/virtual_structure/ai/last_ship = selected
	controller.fleet_enemies[controller.group_key(last_ship.ship_ai)] = enemies
	ai_feedback = "Создано соединение [group]: [count] кораблей."
	log_admin("[key_name(user)] spawned virtual AI fleet [group]: [count] ships, [faction], sector [sector.id].")

/datum/overmap_ai_controller/proc/spawn_position(datum/overmap_sector/sector, wanted_x, wanted_y, radius)
	var/turf/best
	var/best_score = INFINITY
	var/span = OVERMAP_TILE_SPAN * sector.tile_travel
	var/list/blockers = list()
	for(var/obj/overmap/entity/ship as anything in SSovermap.vessels)
		if(!QDELETED(ship) && ship.sector == sector && isturf(ship.loc) && (ship.hull_radius || ship.physical_space))
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
			if(!blocked)
				best = spot
				best_score = score
	return best

/datum/overmap_admin_panel/proc/validate_ai_enemies(value, faction)
	if(isnull(value) && faction)
		value = GLOB.overmap_ai_default_enemies[faction]
	if(!islist(value) || length(value) > length(GLOB.overmap_ai_enemy_options))
		throw EXCEPTION("Некорректный список враждебных фракций.")
	var/list/enemies = list()
	for(var/affiliation in value)
		if(!istext(affiliation) || !(affiliation in GLOB.overmap_ai_enemy_options))
			throw EXCEPTION("Неизвестная враждебная фракция.")
		enemies |= affiliation
	return enemies

/datum/overmap_admin_panel/proc/set_ai_enemies(list/params, mob/user)
	var/list/enemies = validate_ai_enemies(params["enemies"])
	var/datum/overmap_ai_controller/controller = SSovermap.ai_controller
	var/list/members = list()
	for(var/datum/overmap_ship_ai/brain as anything in controller?.ships)
		if(!QDELETED(brain) && !QDELETED(brain.owner) && controller.group_key(brain) == params["fleet"])
			members += brain
	if(!length(members))
		throw EXCEPTION("Соединение не найдено.")
	controller.fleet_enemies[params["fleet"]] = enemies
	for(var/datum/overmap_ship_ai/brain as anything in members)
		if(brain.order?["kind"] != "attack")
			brain.target = null
			brain.target_visible = FALSE
		brain.next_think = 0
	controller.index_until = 0
	ai_feedback = "Список врагов соединения обновлён. Прямые приказы атаки сохранены."
	log_admin("[key_name(user)] set enemies of AI fleet [params["fleet"]] to [jointext(enemies, ", ")].")
