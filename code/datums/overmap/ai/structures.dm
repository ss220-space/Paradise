/datum/overmap_ship_ai/stationary

/datum/overmap_ship_ai/stationary/New(obj/overmap/entity/ship, datum/overmap_ai_controller/manager, class_id, affiliation, squad)
	..()
	role = "stationary"

/datum/overmap_ship_ai/stationary/think()
	weapon_snapshots.Cut()
	if(QDELETED(owner) || !owner.sector || !isturf(owner.loc))
		return
	weapons = list()
	for(var/obj/machinery/gun in owner.ai_weapons())
		weapons += gun
	acquire_target()
	state = target_visible ? "standoff" : "stopped"
	report_state()
	if(target_visible)
		aim_and_fire()

/datum/overmap_ship_ai/proc/fire_range()
	return owner.stationary_ai ? owner.structure_fire_range : profile.fire_range

/datum/overmap_ship_ai/proc/within_fire_range(obj/machinery/gun, x, y, target_radius = 0)
	var/list/origin = weapon_data(gun)["position"]
	var/reach = fire_range() + (owner.stationary_ai ? 0 : target_radius)
	return fire_range() > 0 && origin && (x - origin[1]) ** 2 + (y - origin[2]) ** 2 <= reach ** 2

