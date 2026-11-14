/datum/overmap_ai_controller/proc/diplomacy_key(datum/overmap_ship_ai/brain)
	return "[brain.faction]/[brain.group]"

/datum/overmap_ship_ai/proc/remember_affiliation(obj/overmap/entity/ship, affiliation)
	var/key = controller.group_key(src)
	var/list/memory = controller.fleet_recognized[key]
	if(!memory)
		if(affiliation == "unknown")
			return affiliation
		memory = list()
		controller.fleet_recognized[key] = memory
	var/id = ship.UID()
	var/list/known = memory[id]
	if(affiliation != "unknown")
		if(!known || known["visit"] != ship.sector_visit || known["faction"] != affiliation)
			memory[id] = list("visit" = ship.sector_visit, "faction" = affiliation)
		return affiliation
	if(known && known["visit"] == ship.sector_visit)
		return known["faction"]
	memory -= id
	return affiliation

/datum/overmap_ai_controller/proc/friends_for(datum/overmap_ship_ai/brain)
	var/list/friends = fleet_friends[diplomacy_key(brain)]
	return isnull(friends) ? list(brain.faction, "neutral") : friends

/datum/overmap_ship_ai/proc/contact_relation(obj/overmap/entity/ship)
	var/list/relations = controller.fleet_relations[controller.diplomacy_key(src)]
	var/relation = relations?["ship/[ship.UID()]"]
	if(relation)
		return relation
	if(ship.ship_ai)
		return relations?["fleet/[controller.diplomacy_key(ship.ship_ai)]"] || 0
	return 0

/datum/overmap_ship_ai/proc/has_retaliation(obj/overmap/entity/ship)
	return !is_fleet_member(ship) && contact_relation(ship) < 0

/datum/overmap_ship_ai/proc/hostile_to(obj/overmap/entity/ship)
	if(QDELETED(ship) || ship == owner || ship.is_ai_destroyed() || is_fleet_member(ship))
		return FALSE
	var/relation = contact_relation(ship)
	if(relation)
		return relation < 0
	var/affiliation = perceived_faction(ship)
	if(affiliation == "unknown" && (faction in list("nt", "syndicate")) && !(ship.overmap_kind in list(OVERMAP_KIND_SHUTTLE, OVERMAP_KIND_POD)))
		return FALSE
	return hostile(affiliation)

/datum/overmap_ship_ai/proc/receive_hit(obj/overmap/entity/attacker, obj/projectile/shot, direct = TRUE)
	if(QDELETED(attacker) || attacker == owner || is_fleet_member(attacker) || owner.is_ai_destroyed())
		return
	if(direct)
		owner.last_attacker_uid = attacker.UID()
	var/key = controller.diplomacy_key(src)
	if(key in shot.overmap_hit_groups)
		return
	LAZYADD(shot.overmap_hit_groups, key)
	var/affiliation = remember_affiliation(attacker, overmap_ai_faction(attacker))
	if(contact_relation(attacker) < 0 || (!contact_relation(attacker) && hostile(affiliation)))
		return
	var/list/incidents = controller.fleet_incidents[key]
	if(!incidents)
		incidents = list()
		controller.fleet_incidents[key] = incidents
	var/id = attacker.UID()
	incidents[id] = (incidents[id] || 0) + 1
	var/friendly = contact_relation(attacker) > 0 || (affiliation in controller.friends_for(src))
	var/threshold = faction == "neutral" || !friendly ? 3 : 9
	if(incidents[id] < threshold)
		report("warning", attacker)
		return
	var/list/relations = controller.fleet_relations[key]
	if(!relations)
		relations = list()
		controller.fleet_relations[key] = relations
	var/contact_key = attacker.ship_ai ? "fleet/[controller.diplomacy_key(attacker.ship_ai)]" : "ship/[id]"
	if(attacker.ship_ai)
		relations -= "ship/[id]"
	relations[contact_key] = -1
	report("retaliate", attacker)
	for(var/datum/overmap_ship_ai/member as anything in controller.ships)
		if(controller.diplomacy_key(member) == key)
			member.next_think = 0

/datum/overmap_ship_ai/proc/friendly_to(obj/overmap/entity/ship)
	if(QDELETED(ship))
		return FALSE
	if(ship == owner || is_fleet_member(ship))
		return TRUE
	var/relation = contact_relation(ship)
	if(relation)
		return relation > 0
	var/affiliation = perceived_faction(ship)
	return !hostile(affiliation) && (affiliation in controller.friends_for(src))
