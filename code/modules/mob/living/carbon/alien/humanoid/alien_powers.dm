/datum/action/innate/alien
	background_icon_state = "bg_alien"

/datum/action/innate/alien/thermal_toogle
	name = "Переключить термальное зрение"
	button_icon_state = "thermal"

/datum/action/innate/alien/thermal_toogle/Activate()
	var/mob/living/carbon/alien/host = owner

	if(!IsAvailable())
		return

	if(!host.nightvision_enabled)
		host.nightvision = 8
		host.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		host.nightvision_enabled = TRUE
		host.balloon_alert(host, "термальное")
		usr.hud_used.nightvisionicon.icon_state = "nightvision1"
		host.update_sight()
		return

	if(host.nightvision_enabled)
		host.nightvision = initial(host.nightvision)
		host.lighting_alpha = initial(host.lighting_alpha)
		host.nightvision_enabled = FALSE
		host.balloon_alert(host, "обычное")
		usr.hud_used.nightvisionicon.icon_state = "nightvision0"
		host.update_sight()
		return

/proc/playsound_xenobuild(object)
	var/turf/object_turf = get_turf(object)

	if(!object_turf)
		return

	playsound(object_turf, pick('sound/creatures/alien/xeno_resin_build1.ogg', \
								'sound/creatures/alien/xeno_resin_build2.ogg', \
								'sound/creatures/alien/xeno_resin_build3.ogg'), 30)
