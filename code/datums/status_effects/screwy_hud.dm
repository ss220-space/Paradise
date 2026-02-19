/**
 * Screwy hud status.
 *
 * Applied to carbons, it will make their health bar look like it's incorrect -
 * in crit (SCREWYHUD_CRIT), dead (SCREWYHUD_DEAD), or fully healthy (SCREWYHUD_HEALTHY)
 *
 * Grouped status effect, so multiple sources can add a screwyhud without
 * accidentally removing another source's hud.
 */
/datum/status_effect/grouped/screwy_hud
	alert_type = null
	/// The priority of this screwyhud over other screwyhuds.
	var/priority = -1
	/// The icon we override our owner's healths.icon_state with
	var/override_icon
	/// The icon prefix we override our owner's healthdoll
	var/override_prefix
	/// Сhange only species overlays
	var/only_species = FALSE

/datum/status_effect/grouped/screwy_hud/on_apply()
	if(!iscarbon(owner))
		return FALSE

	RegisterSignal(owner, COMSIG_CARBON_UPDATING_HEALTH_HUD, PROC_REF(on_health_hud_updated))
	if(ishuman(owner))
		RegisterSignal(owner, COMSIG_HUMAN_UPDATING_HEALTH_HUD, PROC_REF(on_human_health_hud_updated))
	owner.update_health_hud()
	return TRUE

/datum/status_effect/grouped/screwy_hud/on_remove()
	UnregisterSignal(owner, list(COMSIG_CARBON_UPDATING_HEALTH_HUD, COMSIG_HUMAN_UPDATING_HEALTH_HUD))
	owner.update_health_hud()

/datum/status_effect/grouped/screwy_hud/proc/on_health_hud_updated(mob/living/carbon/source, shown_health_amount)
	SIGNAL_HANDLER

	// Shouldn't even be running if we're dead, but just in case...
	if(source.stat == DEAD)
		return

	// It's entirely possible we have multiple screwy huds on one mob.
	// Defer to priority to determine which to show. If our's is lower, don't show it.
	for(var/datum/status_effect/grouped/screwy_hud/other_screwy_hud in source.status_effects)
		if(other_screwy_hud.priority > priority)
			return

	source.healths.icon_state = override_icon
	return COMPONENT_OVERRIDE_HEALTH_HUD

/datum/status_effect/grouped/screwy_hud/proc/on_human_health_hud_updated(mob/living/carbon/human/source, shown_health_amount)
	SIGNAL_HANDLER

	// Shouldn't even be running if we're dead, but just in case...
	if(source.stat == DEAD)
		return

	// It's entirely possible we have multiple screwy huds on one mob.
	// Defer to priority to determine which to show. If our's is lower, don't show it.
	for(var/datum/status_effect/grouped/screwy_hud/other_screwy_hud in source.status_effects)
		if(other_screwy_hud.priority > priority)
			return

	source.healths.icon_state = override_icon
	if(source.healthdoll)
		var/list/new_overlays = list()

		var/list/cached_overlays = source.healthdoll.cached_healthdoll_overlays
		// Use the dead health doll as the base, since we have proper "healthy" overlays now
		for(var/obj/item/organ/external/bodypart as anything in source.bodyparts)
			var/icon_num = override_prefix
			if(istype(bodypart, /obj/item/organ/external/tail) && bodypart.dna?.species.tail)
				new_overlays |= "[bodypart.dna.species.tail][icon_num]"
			if(istype(bodypart, /obj/item/organ/external/wing) && bodypart.dna?.species.tail)
				new_overlays |= "[bodypart.dna.species.wing][icon_num]"
			else if(!only_species)
				new_overlays |= "[bodypart.limb_zone][icon_num]"

		source.healthdoll.add_overlay(new_overlays - cached_overlays)
		source.healthdoll.cut_overlay(cached_overlays - new_overlays)
		source.healthdoll.cached_healthdoll_overlays = new_overlays
	return COMPONENT_OVERRIDE_HEALTH_HUD

/datum/status_effect/grouped/screwy_hud/fake_dead
	id = "fake_hud_dead"
	priority = 100 // death is absolute
	override_icon = "health7"
	override_prefix = "_DEAD"
	only_species = TRUE

/datum/status_effect/grouped/screwy_hud/fake_crit
	id = "fake_hud_crit"
	priority = 90 // crit is almost death, and death is absolute
	override_icon = "health6"
	override_prefix = 5

/datum/status_effect/grouped/screwy_hud/fake_healthy
	id = "fake_hud_healthy"
	priority = 10 // fully healthy is the opposite of death, which is absolute
	override_icon = "health0"
	override_prefix = 0
