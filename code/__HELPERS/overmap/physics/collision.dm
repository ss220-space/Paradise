/proc/overmap_impact_damage(impact_speed)
	return clamp(impact_speed * 2, 0, 60) * 10

/proc/overmap_contact_health(contact, obj/overmap/entity/owner)
	if(istype(owner, /obj/overmap/entity/virtual_structure))
		var/list/cell = contact
		return max(1, cell[4])
	if(owner?.overmap_pod)
		return max(1, owner.overmap_pod.pod().health)
	var/turf/spot = contact
	if(!spot)
		return 1
	if(istype(spot, /turf/simulated/wall/indestructible))
		return 1000000
	var/health = isspaceturf(spot) ? 0 : 25
	if(iswallturf(spot))
		var/turf/simulated/wall/wall = spot
		health = max(1, wall.damage_cap - wall.damage)
	else if(spot.density)
		return 1000000
	for(var/obj/object in spot)
		if(!object.density || !object.simulated || QDELETED(object))
			continue
		if(object.resistance_flags & INDESTRUCTIBLE)
			return 1000000
		if(isspacepod(object))
			var/obj/spacepod/pod = object
			health += max(0, pod.health)
		else
			health += max(0, object.obj_integrity)
	return max(1, health)

/proc/overmap_contact_damage(energy, own_health, target_health)
	return energy * target_health / max(own_health + target_health, 1)

/proc/overmap_turf_blocked(turf/spot)
	if(!spot)
		return FALSE
	if(spot.density || (locate(/mob/living/silicon/ai) in spot))
		return TRUE
	for(var/obj/object in spot)
		if(object.density && object.simulated && !QDELETED(object))
			return TRUE
	return FALSE

/proc/overmap_impact_loss(resistance, damage)
	return 1 - sqrt(max(0, 1 - clamp(resistance / max(damage, 1), 0, 1)))

/proc/overmap_contact_key(contact)
	if(isturf(contact))
		return contact
	var/list/cell = contact
	return "[cell[1]],[cell[2]]"

/proc/overmap_damage_contact(contact, damage, obj/overmap/entity/owner)
	if(istype(owner, /obj/overmap/entity/virtual_structure))
		var/obj/overmap/entity/virtual_structure/structure = owner
		var/list/cell = contact
		var/health = cell[4]
		structure.damage_cell(cell, damage)
		return cell[4] > 0 ? 1 : overmap_impact_loss(health, damage)
	if(owner?.overmap_pod)
		owner.overmap_pod.pod().deal_damage(damage)
		return owner.overmap_pod.pod().health > 0 ? 1 : 0
	var/turf/spot = contact
	var/x = spot.x
	var/y = spot.y
	var/z = spot.z
	var/absorbed = overmap_damage_turf(spot, damage)
	return overmap_turf_blocked(locate(x, y, z)) ? 1 : overmap_impact_loss(absorbed, damage)

/proc/overmap_damage_turf(turf/spot, damage)
	if(!spot || damage <= 0)
		return
	var/was_wall = iswallturf(spot)
	var/hit_object = FALSE
	var/absorbed = 0
	var/x = spot.x
	var/y = spot.y
	var/z = spot.z
	if(iswallturf(spot) && !istype(spot, /turf/simulated/wall/indestructible))
		var/turf/simulated/wall/wall = spot
		var/cap = wall.rotting ? wall.damage_cap / 10 : wall.damage_cap
		if(damage >= cap - wall.damage)
			absorbed = max(0, cap - wall.damage)
			wall.dismantle_wall(devastated = TRUE)
		else
			wall.take_damage(damage)
			absorbed = damage
		spot = locate(x, y, z)
	var/list/damaged = list()
	for(var/pass in 1 to 4)
		var/hit = FALSE
		for(var/obj/object in spot.contents)
			if(!object.simulated || QDELETED(object) || damaged[object] || (pass > 1 && !object.density))
				continue
			damaged[object] = TRUE
			var/blocking = object.density
			if(blocking)
				hit_object = TRUE
			if(object.resistance_flags & INDESTRUCTIBLE)
				continue
			var/remaining = max(0, damage - absorbed)
			if(!remaining)
				continue
			var/health = max(0, object.obj_integrity)
			if(isspacepod(object))
				var/obj/spacepod/pod = object
				health = max(0, pod.health)
				pod.deal_damage(remaining)
				if(blocking)
					absorbed += clamp(health - max(0, pod.health), 0, remaining)
			else
				object.take_damage(remaining, BRUTE, MELEE, FALSE, null, 100)
				if(blocking)
					absorbed += clamp(health - (QDELETED(object) ? 0 : max(0, object.obj_integrity)), 0, remaining)
			hit = TRUE
		spot = locate(x, y, z)
		if(!hit)
			break
	for(var/mob/living/victim in spot)
		victim.apply_damage(damage, BRUTE)
	if(was_wall || hit_object)
		return absorbed
	if(isfloorturf(spot) && damage >= 25)
		spot.ex_act(EXPLODE_DEVASTATE)
	else if(damage >= 250)
		spot.ex_act(EXPLODE_DEVASTATE)
	else if(damage >= 150)
		spot.ex_act(EXPLODE_HEAVY)
	else if(damage >= 60)
		spot.ex_act(EXPLODE_LIGHT)

/proc/overmap_tiles_overlap(delta_x, delta_y, cosine, sine)
	var/extent = (1 + abs(cosine) + abs(sine)) / 2 - OVERMAP_MOVE_RESOLUTION
	return abs(delta_x) < extent && abs(delta_y) < extent && abs(delta_x * cosine + delta_y * sine) < extent && abs(delta_y * cosine - delta_x * sine) < extent
