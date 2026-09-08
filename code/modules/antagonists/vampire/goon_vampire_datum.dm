/datum/antagonist/vampire/goon_vampire
	name = "Goon-Vampire"
	nullification = OLD_NULLIFICATION
	is_garlic_affected = TRUE
	antag_datum_blacklist = list(/datum/antagonist/vampire/new_vampire)
	antag_menu_name = "Goon вампир"
	upgrade_tiers = list(
		/datum/action/cooldown/spell/goon_vamp_rejuvenate = 0,
		/datum/action/cooldown/spell/pointed/vampire_hypnotise = 0,
		/datum/action/cooldown/spell/aoe/goon_vamp_glare = 0,
		/datum/vampire_passive/vision = 100,
		/datum/action/cooldown/spell/vamp_shapeshift = 100,
		/datum/action/cooldown/spell/goon_vamp_cloak = 150,
		/datum/action/cooldown/spell/pointed/goon_vamp_disease = 150,
		/datum/action/cooldown/spell/conjure/goon_vamp_bats = 200,
		/datum/action/cooldown/spell/aoe/goon_vamp_screech = 200,
		/datum/vampire_passive/regen = 200,
		/datum/action/cooldown/spell/teleport/radius_turf/goon_vamp_blink = 250,
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/goon_vamp_jaunt = 300,
		/datum/action/cooldown/spell/pointed/goon_vamp_enthrall = 300,
		/datum/vampire_passive/xray = 500,
		/datum/vampire_passive/full = 500,
	)

/datum/antagonist/vampire/goon_vampire/add_owner_to_gamemode()
	SSticker.mode.goon_vampires += owner

/datum/antagonist/vampire/goon_vampire/remove_owner_from_gamemode()
	SSticker.mode.goon_vampires -= owner

/datum/antagonist/mindslave/thrall/goon_thrall/add_owner_to_gamemode()
	SSticker.mode.goon_vampire_enthralled += owner

/datum/antagonist/mindslave/thrall/goon_thrall/remove_owner_from_gamemode()
	SSticker.mode.goon_vampire_enthralled -= owner

/proc/is_goon_vampire(datum/source)
	if(!source)
		return FALSE

	if(istype(source, /datum/mind))
		var/datum/mind/our_mind = source
		return our_mind.has_antag_datum(/datum/antagonist/vampire/goon_vampire)

	if(!ismob(source))
		return FALSE

	var/mob/mind_holder = source
	if(!mind_holder.mind)
		return FALSE

	return mind_holder.mind.has_antag_datum(/datum/antagonist/vampire/goon_vampire)
