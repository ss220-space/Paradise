/datum/component/npc_friendly
	var/static/list/npc_factions = list(
		"alien",
		"boss",
		"carp",
		"hivebot",
		"hostile",
		"mimic",
		"pirate",
		"spiders",
		"syndicate",
		ROLE_GLITCH,
	)
	var/list/previous_factions

/datum/component/npc_friendly/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/entity = parent
	previous_factions = entity.faction.Copy()
	entity.faction = entity.faction | npc_factions

/datum/component/npc_friendly/Destroy(force = FALSE)
	var/mob/living/entity = parent
	if(!QDELETED(entity))
		entity.faction = previous_factions
	previous_factions = null
	return ..()
