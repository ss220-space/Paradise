/**
 * ## List Target spells
 *
 * These spells will prompt the user with a tgui list
 * of all nearby targets that they select on to cast.
 *
 * To add effects on cast, override "cast(atom/cast_on)".
 * The cast_on atom is the atom that was selected by the list.
 */
/datum/action/cooldown/spell/list_target
	/// The message displayed as the title of the tgui target input list.
	var/choose_target_message = "Choose a target."
	/// Radius around the caster that living targets are picked to choose from
	var/target_radius = 7
	var/used_in_radius = TRUE
	var/targeting_type = /datum/aoe_targeting
	var/datum/aoe_targeting/targeting

/datum/action/cooldown/spell/list_target/PreActivate(atom/caster)
	if(isnull(targeting.owner))
		targeting.owner = owner
	var/list/list_targets = get_list_targets(caster, target_radius)
	if(!length(list_targets))
		caster.balloon_alert(caster, "no targets nearby!")
		return FALSE

	var/atom/chosen = tgui_input_list(caster, choose_target_message, name, sort_names(list_targets))
	if(QDELETED(src) || QDELETED(caster) || QDELETED(chosen) || !can_cast_spell())
		return FALSE

	if(get_dist(chosen, caster) > target_radius && used_in_radius)
		caster.balloon_alert(caster, "they're too far!")
		return FALSE

	return Activate(chosen)

/// Get a list of living targets in radius of the center to put in the target list.
/datum/action/cooldown/spell/list_target/proc/get_list_targets(atom/center, target_radius = 7)
	return targeting.get_targets(center, target_radius)

/datum/action/cooldown/spell/list_target/New(Target, original)
	. = ..()
	targeting = new targeting_type(owner, src)
