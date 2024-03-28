/**
 * Here lie areas that reset your vision.
 * Designed to cancel off xray/meson/thermal vision effects.
 * Special for spooky secret areas and gates. :D
 */

/area/vision_change_area

/area/vision_change_area/Entered(atom/movable/arrived)
	. = ..()
	if(istype(arrived, /mob/living/carbon))
		var/mob/living/carbon/C = arrived
		C.see_invisible = initial(C.see_invisible)
		C.nightvision = initial(C.nightvision)
		C.sight = initial(C.sight)
		C.lighting_alpha = initial(C.lighting_alpha)
		C.sync_lighting_plane_alpha()
		C.AddComponent(/datum/component/vision_reset)

/area/vision_change_area/Exited(atom/movable/gone)
	. = ..()
	if(istype(gone, /mob/living/carbon))
		var/mob/living/carbon/C = gone
		var/datum/component/component = C.GetComponent(/datum/component/vision_reset)
		if(component)
			qdel(component)
		C.update_sight()

/datum/component/vision_reset
	var/mob/living/carbon/my_mob

/datum/component/vision_reset/Initialize(...)
	my_mob = parent
	if(!istype(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(my_mob, COMSIG_MOB_UPDATE_SIGHT, PROC_REF(change_vision))

/datum/component/vision_reset/proc/change_vision()
	my_mob.see_invisible = initial(my_mob.see_invisible)
	my_mob.nightvision = initial(my_mob.nightvision)
	my_mob.sight = initial(my_mob.sight)
	my_mob.lighting_alpha = initial(my_mob.lighting_alpha)
	my_mob.sync_lighting_plane_alpha()

/datum/component/vision_reset/Destroy(force, silent)
	UnregisterSignal(my_mob, COMSIG_MOB_UPDATE_SIGHT)
	my_mob.update_sight()
	return ..()
