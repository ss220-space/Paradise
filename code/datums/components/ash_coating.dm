// ============================================================
// ASH COATING ON MOBS
// ============================================================

/mob/living
	var/ash_coating = 0
	var/ash_overlay_key = "ash_coating"
	var/last_ash_storm_tick = 0

/mob/living/proc/update_ash_overlay()
	cut_overlay(ash_overlay_key)
	if(ash_coating > 30)
		var/mutable_appearance/ash_overlay = mutable_appearance(icon, icon_state, layer = layer + 0.05)
		ash_overlay.color = ash_coating > 70 ? "#404040" : "#808080"
		ash_overlay.alpha = clamp((ash_coating - 30) * 2, 0, 100)
		add_overlay(ash_overlay, ash_overlay_key)

/mob/living/Life(seconds_per_tick, times_fired)
	. = ..()
	if(ash_coating > 0 && world.time > last_ash_storm_tick + 3 SECONDS)
		ash_coating = max(ash_coating - 0.1, 0)
		update_ash_overlay()
