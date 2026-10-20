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

/datum/action/innate/alien/toggle_queen_arrow
	name = "Расположение королевы"
	desc = "Включить/выключить указатель направления к Королеве"
	button_icon_state = "queen_arrow"
	var/atom/movable/screen/navigate_arrow/arrow

/datum/action/innate/alien/toggle_queen_arrow/Activate()
	if(!IsAvailable())
		return
	var/mob/living/carbon/alien/host = owner
	if(!host.client)
		return

	if(arrow)
		host.client.screen -= arrow
		qdel(arrow)
		arrow = null
		host.balloon_alert(host, "выключено")
		return

	var/mob/living/carbon/alien/humanoid/queen/Q = locate() in GLOB.aliens_list
	if(!Q || Q.stat == DEAD)
		host.balloon_alert(host, "королевы нет!")
		return

	arrow = new
	host.client.screen += arrow
	update_arrow()
	host.balloon_alert(host, "включено")

/datum/action/innate/alien/toggle_queen_arrow/proc/update_arrow()
	if(!arrow || !owner?.client)
		return
	var/mob/living/carbon/alien/humanoid/queen/Q = locate() in GLOB.aliens_list
	if(!Q || Q.stat == DEAD)
		owner.client.screen -= arrow
		qdel(arrow)
		arrow = null
		owner.balloon_alert(owner, "королева мертва!")
		return
	arrow.start_effect(get_turf(Q), "#947BA1", owner)

/datum/action/innate/alien/toggle_queen_arrow/Destroy()
	if(arrow)
		owner?.client?.screen -= arrow
		QDEL_NULL(arrow)
	return ..()
