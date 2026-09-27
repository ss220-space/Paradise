/*!
 * Void storm for the void heretic ascension
 *
 * Follows the heretic around and acts like an aura with damaging effects for non-heretics
 */
/datum/proximity_monitor/advanced/void_storm
	edge_is_a_field = TRUE
	// lazylist that keeps track of the overlays added
	var/list/turf_effects
	var/static/image/storm_overlay = image('icons/effects/weather_effects.dmi', "snow_storm")


/datum/proximity_monitor/advanced/void_storm/New(atom/_host, range, works_when_not_on_turf)
	. = ..()
	recalculate_field(full_recalc = TRUE)


/datum/proximity_monitor/advanced/void_storm/recalculate_field(full_recalc)
	. = ..()
	var/turf/host_turf = get_turf(host)
	if(!host_turf)
		return
	for(var/turf/target as anything in turf_effects)
		var/obj/effect/abstract/effect = turf_effects[target]
		effect.alpha = 255 - get_dist(target, host_turf) * 23


/datum/proximity_monitor/advanced/void_storm/cleanup_field_turf(turf/target)
	. = ..()
	var/obj/effect/abstract/effect = LAZYACCESS(turf_effects, target)
	LAZYREMOVE(turf_effects, target)
	if(!effect)
		return

	qdel(effect)


/datum/proximity_monitor/advanced/void_storm/setup_field_turf(turf/target)
	. = ..()
	var/obj/effect/abstract/effect = new(target) // Makes the field visible to players.
	// master220's /obj/effect/abstract base is INVISIBILITY_ABSTRACT (tg's is visible) - unhide it
	// or the whole storm aura renders as nothing.
	effect.invisibility = INVISIBILITY_NONE
	effect.alpha = 255 - get_dist(target, host.loc) * 23
	effect.color = COLOR_BLACK
	effect.icon = storm_overlay.icon
	effect.icon_state = storm_overlay.icon_state
	effect.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	effect.layer = ABOVE_ALL_MOB_LAYER
	SET_PLANE(effect, ABOVE_GAME_PLANE, target)
	LAZYSET(turf_effects, target, effect)
