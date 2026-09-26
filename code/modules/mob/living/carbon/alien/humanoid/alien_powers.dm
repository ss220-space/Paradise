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

/*******************
//Small sprites
********************/

/datum/action/innate/alien/sprite_toggle
	name = "Переключить спрайт"
	desc = "Остальные продолжат видеть вас огромным."
	button_icon_state = "alien_evolve_larva"
	check_flags = AB_CHECK_CONSCIOUS
	var/small = FALSE
	var/small_icon = 'icons/mob/alien.dmi'
	var/small_icon_state = "alienq_running"

/datum/action/innate/alien/sprite_toggle/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return

	if(!small)
		var/image/I = image(icon = small_icon, icon_state = small_icon_state, loc = owner)
		I.override = TRUE
		I.pixel_w -= owner.pixel_x
		I.pixel_z -= owner.pixel_y
		owner.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic, "smallsprite", I, AA_TARGET_SEE_APPEARANCE | AA_MATCH_TARGET_OVERLAYS)
		small = TRUE
	else
		owner.remove_alt_appearance("smallsprite")
		small = FALSE

/datum/action/innate/alien/sprite_toggle/praetorian
	small_icon_state = "aliens_running"

/*******************
//Leap toggle
********************/

/datum/action/innate/alien/leap_toggle
	name = "Переключить прыжок"
	button_icon_state = "leap_off"
	check_flags = AB_CHECK_CONSCIOUS
	var/mob/living/carbon/alien/humanoid/hunter/alien_hunter

/datum/action/innate/alien/leap_toggle/UpdateButtonIcon()
	. = ..()
	alien_hunter = owner
	button_icon_state = alien_hunter.leap_on_click ? initial(button_icon_state) : "leap_on"

/datum/action/innate/alien/leap_toggle/Trigger(mob/clicker, trigger_flags)
	. = ..()

	if(!isalienhunter(owner))
		return

	UpdateButtonIcon()
	alien_hunter = owner
	alien_hunter.toggle_leap()

