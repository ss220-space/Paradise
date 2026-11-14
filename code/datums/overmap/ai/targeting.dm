/datum/overmap_ship_ai/proc/choose_target()
	var/list/claims = list()
	var/key = controller.group_key(src)
	for(var/datum/overmap_ship_ai/member as anything in controller.ships)
		if(member != src && !QDELETED(member) && !QDELETED(member.owner) && !member.owner.is_ai_destroyed() && member.enabled && member.target_visible && member.target && controller.group_key(member) == key)
			claims[member.target] = (claims[member.target] || 0) + 1
	var/list/candidates = list()
	for(var/obj/overmap/entity/ship, record in controller.fleet_contacts[key])
		var/list/entry = record
		if(!entry["targetable"] || !can_see(entry) || !hostile_to(ship))
			continue
		var/distance = max(0, sqrt((ship.get_world_x() - owner.get_world_x()) ** 2 + (ship.get_world_y() - owner.get_world_y()) ** 2) - entry["radius"])
		candidates[ship] = 100 / (1 + distance / max(1, fire_range())) - 30 * (claims[ship] || 0) + (ship == target ? 15 : 0)
	var/obj/overmap/entity/best
	var/best_score = -INFINITY
	for(var/index in 1 to min(4, length(candidates)))
		var/obj/overmap/entity/candidate
		var/rough_score = -INFINITY
		for(var/obj/overmap/entity/ship, score in candidates)
			if(score > rough_score)
				candidate = ship
				rough_score = score
		candidates -= candidate
		var/opportunity = firing_opportunity(candidate)
		if(owner.stationary_ai && opportunity <= 0)
			continue
		var/score = rough_score + opportunity
		if(score > best_score)
			best = candidate
			best_score = score
	return best

/datum/overmap_ship_ai/proc/firing_opportunity(obj/overmap/entity/candidate)
	var/x = candidate.get_world_x()
	var/y = candidate.get_world_y()
	if(!owner.stationary_ai && sqrt((x - owner.get_world_x()) ** 2 + (y - owner.get_world_y()) ** 2) - overmap_ai_radius(candidate) > fire_range())
		return 0
	var/score = 0
	for(var/obj/machinery/mount as anything in weapons)
		if(!weapon_operational(mount))
			continue
		if(owner.stationary_ai && !within_fire_range(mount, x, y))
			continue
		var/list/aim = aim_at_point(mount, x, y, candidate.speed[1] * OVERMAP_TILE_SPAN * (1 SECONDS), candidate.speed[2] * OVERMAP_TILE_SPAN * (1 SECONDS))
		if(!aim || !clear_shot(mount, aim, candidate))
			continue
		var/list/origin = weapon_data(mount)["position"]
		var/turn = abs(closer_angle_difference(weapon_data(mount)["heading"], delta_to_angle(aim[1] - origin[1], aim[2] - origin[2])))
		var/available = turn <= weapon_data(mount)["arc"] / 2
		if(owner.stationary_ai && !available)
			continue
		var/value = available ? 180 : 60 * (1 - turn / 180)
		if(available && world.time >= weapon_data(mount)["next_fire"])
			value += 30
		score = max(score, value)
	return score

/datum/overmap_ship_ai/proc/weapon_projectile_type(obj/machinery/gun)
	var/obj/machinery/porta_turret/turret = gun
	if(istype(turret))
		return (turret.lethal || turret.emagged) ? turret.eprojectile : turret.projectile
	return gun.ship_round_type || /obj/projectile/bullet/ship_artillery

/datum/overmap_ship_ai/proc/weapon_target_fit(obj/machinery/gun, obj/overmap/entity/contact)
	var/path = weapon_projectile_type(gun)
	if(!ispath(path, /obj/projectile))
		return 0
	var/obj/projectile/shot = path
	var/caliber = istype(gun, /obj/machinery/porta_turret) ? 1 : 2
	switch(initial(shot.overmap_radar_kind))
		if("light", "laser_light")
			caliber = 1
		if("heavy", "laser_heavy", "guided_missile")
			caliber = 3
		if("capital", "capital_rail", "capital_ion", "laser_capital")
			caliber = 4
	var/target_class = 2
	switch(contact.hull_class())
		if("LC")
			target_class = 1
		if("HC", "SC")
			target_class = 3
		if("FS")
			target_class = 4
		if(null)
			target_class = contact.overmap_kind == OVERMAP_KIND_STATION ? 4 : contact.hull_radius <= 12 ? 1 : contact.hull_radius <= 25 ? 2 : 3
	return max(0.1, 1 - abs(caliber - target_class) * 0.3)

/datum/overmap_ship_ai/proc/select_weapon_targets()
	var/list/previous = weapon_targets
	weapon_targets = list()
	var/list/candidates = list()
	if(order?["kind"] == "attack")
		if(target_visible && !QDELETED(target))
			candidates += target
	else
		for(var/obj/overmap/entity/contact, record in controller.fleet_contacts[controller.group_key(src)])
			var/list/entry = record
			if(entry["targetable"] && can_see(entry) && hostile_to(contact))
				candidates += contact
	var/list/claims = list()
	for(var/obj/machinery/gun as anything in weapons)
		if(!weapon_operational(gun))
			continue
		var/list/scores = list()
		var/list/origin = weapon_data(gun)["position"]
		for(var/obj/overmap/entity/contact as anything in candidates)
			var/x = contact.get_world_x()
			var/y = contact.get_world_y()
			if(!within_fire_range(gun, x, y, overmap_ai_radius(contact)))
				continue
			var/distance = sqrt((x - origin[1]) ** 2 + (y - origin[2]) ** 2)
			var/turn = abs(closer_angle_difference(weapon_data(gun)["heading"], delta_to_angle(x - origin[1], y - origin[2])))
			if(owner.stationary_ai && turn > weapon_data(gun)["arc"] / 2)
				continue
			scores[contact] = 120 * weapon_target_fit(gun, contact) - 15 * distance / max(1, fire_range()) - 2 * (claims[contact] || 0) + (turn <= weapon_data(gun)["arc"] / 2 ? 15 : 0) + (contact == previous[gun] ? 8 : 0)
		for(var/attempt in 1 to min(3, length(scores)))
			var/obj/overmap/entity/best
			var/best_score = -INFINITY
			for(var/obj/overmap/entity/contact, score in scores)
				if(score > best_score)
					best = contact
					best_score = score
			scores -= best
			var/list/aim = aim_at_point(gun, best.get_world_x(), best.get_world_y(), best.speed[1] * OVERMAP_TILE_SPAN * (1 SECONDS), best.speed[2] * OVERMAP_TILE_SPAN * (1 SECONDS))
			if(!aim)
				continue
			var/facing = owner.stationary_ai ? owner.get_facing() : delta_to_angle(aim[1] - origin[1], aim[2] - origin[2]) - weapon_data(gun)["heading"] + owner.get_facing()
			if(!clear_shot(gun, aim, best, facing))
				continue
			weapon_targets[gun] = best
			claims[best] = (claims[best] || 0) + 1
			break
