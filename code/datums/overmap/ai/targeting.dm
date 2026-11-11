/datum/overmap_ship_ai/proc/choose_target()
	var/list/claims = list()
	var/key = controller.group_key(src)
	for(var/datum/overmap_ship_ai/member as anything in controller.ships)
		if(member != src && !QDELETED(member) && !QDELETED(member.owner) && !member.owner.ai_destroyed && member.enabled && member.target_visible && member.target && controller.group_key(member) == key)
			claims[member.target] = (claims[member.target] || 0) + 1
	var/list/candidates = list()
	for(var/obj/overmap/entity/ship, record in controller.fleet_contacts[key])
		var/list/entry = record
		if(!entry["targetable"] || !can_see(entry) || is_fleet_member(ship) || !hostile(perceived_faction(ship)))
			continue
		var/distance = max(0, sqrt((ship.get_world_x() - owner.get_world_x()) ** 2 + (ship.get_world_y() - owner.get_world_y()) ** 2) - entry["radius"])
		candidates[ship] = 100 / (1 + distance / max(1, profile.fire_range)) - 30 * (claims[ship] || 0) + (ship == target ? 15 : 0)
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
		var/score = rough_score + firing_opportunity(candidate)
		if(score > best_score)
			best = candidate
			best_score = score
	return best

/datum/overmap_ship_ai/proc/firing_opportunity(obj/overmap/entity/candidate)
	var/x = candidate.get_world_x()
	var/y = candidate.get_world_y()
	if(sqrt((x - owner.get_world_x()) ** 2 + (y - owner.get_world_y()) ** 2) - overmap_ai_radius(candidate) > profile.fire_range)
		return 0
	var/score = 0
	for(var/datum/component/ship_weapon/mount as anything in weapons)
		if(!weapon_operational(mount))
			continue
		var/list/aim = aim_at_point(mount, x, y, candidate.speed[1] * OVERMAP_TILE_SPAN * (1 SECONDS), candidate.speed[2] * OVERMAP_TILE_SPAN * (1 SECONDS))
		if(!aim || !clear_shot(mount, aim, candidate))
			continue
		var/list/origin = mount.world_position(owner)
		var/turn = abs(closer_angle_difference(mount.heading(owner), delta_to_angle(aim[1] - origin[1], aim[2] - origin[2])))
		var/available = turn <= mount.arc / 2
		var/value = available ? 180 : 60 * (1 - turn / 180)
		if(available && world.time >= mount.next_fire)
			value += 30
		score = max(score, value)
	return score
