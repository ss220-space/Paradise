// ============================================================
// ПЕПЕЛЬНОЕ ЗАГРЯЗНЕНИЕ МОБОВ
// ============================================================

/mob/living
	var/ash_coating = 0
	var/ash_overlay_key = "ash_coating"

/mob/living/proc/update_ash_overlay()
	cut_overlay(ash_overlay_key)
	if(ash_coating > 30)
		var/mutable_appearance/ash_overlay = mutable_appearance(icon, icon_state, layer = layer + 0.05)
		ash_overlay.color = ash_coating > 70 ? "#404040" : "#808080"
		ash_overlay.alpha = clamp((ash_coating - 30) * 2, 0, 100)
		add_overlay(ash_overlay, ash_overlay_key)

/mob/living/Life(seconds_per_tick, times_fired)
	. = ..()
	if(ash_coating > 0)
		if(!is_in_ash_storm())
			ash_coating = max(ash_coating - 0.1, 0)
			update_ash_overlay()
		else if(!istype(loc, /obj/structure/closet/ash_mound))
			ash_coating = min(ash_coating + rand(1,3), 100)
			update_ash_overlay()

/mob/living/proc/is_in_ash_storm()
	var/turf/T = get_turf(src)
	if(!istype(T, /turf/simulated/floor/plating/asteroid))
		return FALSE
	var/datum/weather/ash_storm/storm = locate(/datum/weather/ash_storm) in SSweather.processing
	if(storm && storm.stage == MAIN_STAGE)
		if(z in storm.impacted_z_levels)
			return TRUE
	return FALSE
