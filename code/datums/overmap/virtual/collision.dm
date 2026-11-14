/datum/overmap_projectile/proc/virtual_hit(obj/overmap/entity/virtual_structure/structure, x, y, list/pose)
	var/list/cell = structure.cell_at(x, y, TRUE, pose)
	if(!cell)
		return FALSE
	var/obj/machinery/gun = payload.firer_source_atom
	if(istype(gun) && gun.virtual_weapon_owner == structure && cell[1] == gun.virtual_weapon_x && cell[2] == gun.virtual_weapon_y)
		return FALSE
	payload.record_overmap_hit(structure)
	if(ion_impact(x, y))
		return TRUE
	var/key = "[structure.UID()]:[cell[1]],[cell[2]]"
	if(key in payload.ship_pierced_tiles)
		return FALSE
	if(istype(payload, /obj/projectile/ship_round))
		var/obj/projectile/ship_round/round = payload
		var/list/result = round.abstract_hit(key, cell[4])
		structure.damage_cell(cell, result[1])
		if(!result[2])
			round.sector_impact(sector, x, y)
			qdel(src)
			return TRUE
		return FALSE
	var/pierce = payload.try_ship_penetration(key)
	structure.damage_cell(cell, payload.damage)
	if(istype(payload, /obj/projectile/bullet/ship_artillery) && (!pierce || !payload.ship_penetrations))
		detonate_shell(x, y)
		qdel(src)
		return TRUE
	if(!pierce)
		qdel(src)
		return TRUE
	return FALSE
