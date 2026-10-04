/datum/aoe_targeting
	var/mob/owner
	var/datum/action/cooldown/spell/parent

/datum/aoe_targeting/New(mob/new_owner, datum/action/cooldown/spell/spell)
	. = ..()
	owner = new_owner
	parent = spell


/datum/aoe_targeting/proc/get_targets(atom/center, aoe_radius)
	RETURN_TYPE(/list)
	return list()
