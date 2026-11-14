/obj/projectile/proc/record_overmap_hit(obj/overmap/entity/victim)
	if(QDELETED(victim) || QDELETED(overmap_firer_vessel) || victim == overmap_firer_vessel)
		return
	var/id = victim.UID()
	if(id in overmap_hit_vessels)
		return
	LAZYADD(overmap_hit_vessels, id)
	if(victim.ship_ai?.is_fleet_member(overmap_firer_vessel))
		return
	victim.last_attacker_uid = overmap_firer_vessel.UID()
	victim.ship_ai?.receive_hit(overmap_firer_vessel, src)

	var/datum/overmap_ai_controller/controller = SSovermap.ai_controller
	for(var/datum/overmap_ship_ai/brain as anything in controller?.ships)
		if(QDELETED(brain) || QDELETED(brain.owner) || brain.owner.sector != victim.sector || brain == victim.ship_ai || brain.is_fleet_member(overmap_firer_vessel))
			continue
		if(controller.diplomacy_key(brain) in overmap_hit_groups)
			continue
		if(brain.friendly_to(victim) && controller.contact_for(brain, overmap_firer_vessel) && controller.contact_for(brain, victim))
			brain.receive_hit(overmap_firer_vessel, src, direct = FALSE)
